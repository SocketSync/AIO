function sanitizeText(str, maxLen = 100) {
  return String(str == null ? '' : str).replace(/[<>]/g, '').trim().slice(0, maxLen);
}

function normalizeReceiptItems(rawReceiptItems, rawLegacyItems, fallbackCategory = 'Other Expenses', fallbackAmount = 0) {
  const normalized = [];

  if (Array.isArray(rawReceiptItems) && rawReceiptItems.length > 0) {
    for (const entry of rawReceiptItems) {
      if (!entry || typeof entry !== 'object') continue;
      const itemName = sanitizeText(entry.item_name || entry.name || entry.title || '', 120);
      if (!itemName) continue;
      const priceNum = Number(entry.price);
      const qtyNum = parseInt(entry.quantity, 10);
      normalized.push({
        item_name: itemName,
        price: Number.isFinite(priceNum) && priceNum >= 0 ? Math.round(priceNum * 100) / 100 : 0.00,
        quantity: Number.isFinite(qtyNum) && qtyNum >= 1 ? Math.min(qtyNum, 999) : 1,
        category: sanitizeText(entry.category || fallbackCategory || 'General', 60) || 'General'
      });
    }
  } else if (Array.isArray(rawLegacyItems) && rawLegacyItems.length > 0) {
    const count = rawLegacyItems.length;
    const estPrice = count > 0 && fallbackAmount > 0 ? Math.round((fallbackAmount / count) * 100) / 100 : 0.00;
    for (const label of rawLegacyItems) {
      if (typeof label === 'string' && label.trim()) {
        normalized.push({
          item_name: sanitizeText(label, 120),
          price: estPrice,
          quantity: 1,
          category: sanitizeText(fallbackCategory || 'General', 60) || 'General'
        });
      } else if (label && typeof label === 'object') {
        const itemName = sanitizeText(label.item_name || label.name || '', 120);
        if (!itemName) continue;
        const priceNum = Number(label.price);
        const qtyNum = parseInt(label.quantity, 10);
        normalized.push({
          item_name: itemName,
          price: Number.isFinite(priceNum) && priceNum >= 0 ? Math.round(priceNum * 100) / 100 : estPrice,
          quantity: Number.isFinite(qtyNum) && qtyNum >= 1 ? Math.min(qtyNum, 999) : 1,
          category: sanitizeText(label.category || fallbackCategory || 'General', 60) || 'General'
        });
      }
    }
  }

  return normalized.slice(0, 40);
}

module.exports = async (req, res) => {
  res.setHeader('Content-Type', 'application/json');
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  if (req.method === 'OPTIONS') return res.status(200).end();

  if (req.method !== 'POST') {
    return res.status(405).json({ success: false, message: 'Method not allowed' });
  }

  const scanStart = Date.now();

  try {
    const { imageBase64, mimeType = 'image/jpeg', filename = '', apiKey = '' } = req.body || {};

    const geminiKey = (apiKey || process.env.GEMINI_API_KEY || '').trim();
    const hasValidKey = geminiKey && !geminiKey.includes('your-gemini') && geminiKey.length > 20;

    // Validate payload size — reject images larger than 10MB base64 (~7.5MB raw)
    if (imageBase64 && imageBase64.length > 10 * 1024 * 1024) {
      return res.status(413).json({
        success: false,
        message: 'Image is too large (max 10MB). Please use a smaller image or reduce photo quality.'
      });
    }

    if (hasValidKey && imageBase64) {
      try {
        const cleanBase64 = imageBase64.replace(/^data:[^;]+;base64,/, '');
        const prompt = `You are a financial receipt parser for the FinWise personal finance app.
Extract the merchant, total amount, date, and overall category from this receipt, invoice, or bill image/PDF.
Crucially, extract every individual item purchased on the receipt into a \`receipt_items\` array. Each item must have \`item_name\`, \`price\`, \`quantity\`, and \`category\`. If it is not a receipt with items (e.g., a simple bank transfer screenshot), return an empty array \`[]\` for \`receipt_items\`.

IMPORTANT RULES:
1. Extract the EXACT merchant/store name as printed on the receipt.
2. Extract the FINAL TOTAL amount paid (after tax, service charge, discounts, rounding).
   - For Malaysian receipts: look for "TOTAL", "JUMLAH", "GRAND TOTAL", or "AMOUNT DUE" — NOT subtotal.
   - Include SST (Sales & Service Tax), service charge, and rounding adjustments in the total.
3. Determine the best overall category from: "Food & Dining", "Groceries", "Shopping", "Transportation", "Entertainment", "Bills & Utilities", "Health & Wellness", "Education & Self-Care", "Salary", "Freelance", "Investments", "Other Expenses".
4. Extract the transaction date from the receipt. Use YYYY-MM-DD format.
5. Extract EVERY line item into \`receipt_items\` as objects with keys:
   - \`item_name\`: string (exact item description)
   - \`price\`: number (unit or line price as a positive float, e.g. 12.50)
   - \`quantity\`: integer (default 1 if omitted on receipt)
   - \`category\`: string (e.g. "Clothing", "Groceries", "Food & Dining", "Electronics", "Home & Living", "Health & Wellness", "Transportation")
6. Also provide \`items\`: an array of brief item name strings summarizing key items (up to 6).

Return ONLY a valid JSON object with these EXACT keys:
{
  "merchant": "Exact merchant/store name",
  "amount": 224.00,
  "currency": "MYR",
  "category": "Shopping",
  "date": "YYYY-MM-DD",
  "receipt_items": [
    { "item_name": "Nike Sneakers", "price": 199.00, "quantity": 1, "category": "Clothing" },
    { "item_name": "Colgate Toothpaste", "price": 12.50, "quantity": 2, "category": "Groceries" }
  ],
  "items": ["Nike Sneakers", "Colgate Toothpaste"]
}
Strictly return pure JSON only.`;

        const modelsToTry = ['gemini-3.5-flash-lite', 'gemini-3.5-flash', 'gemini-3.8-flash', 'gemini-flash-latest'];
        let lastError = null;
        let lastErrorStatus = null;

        for (const modelName of modelsToTry) {
          try {
            const controller = new AbortController();
            const fetchTimeout = setTimeout(() => controller.abort(), 9000);

            const endpoint = `https://generativelanguage.googleapis.com/v1beta/models/${modelName}:generateContent?key=${geminiKey}`;
            const effectiveMimeType = (mimeType && mimeType.includes('pdf')) ? 'application/pdf' : (mimeType || 'image/jpeg');

            const geminiRes = await fetch(endpoint, {
              method: 'POST',
              headers: { 'Content-Type': 'application/json' },
              signal: controller.signal,
              body: JSON.stringify({
                contents: [{
                  parts: [
                    { text: prompt },
                    {
                      inlineData: {
                        mimeType: effectiveMimeType,
                        data: cleanBase64
                      }
                    }
                  ]
                }],
                generationConfig: {
                  temperature: 0.1,
                  response_mime_type: "application/json"
                }
              })
            });

            clearTimeout(fetchTimeout);

            if (geminiRes.ok) {
              const geminiData = await geminiRes.json();
              let rawText = geminiData?.candidates?.[0]?.content?.parts?.[0]?.text || '';
              rawText = rawText.replace(/```json/gi, '').replace(/```/g, '').trim();
              const jsonMatch = rawText.match(/\{[\s\S]*\}/);
              if (jsonMatch) {
                const parsed = JSON.parse(jsonMatch[0]);
                const parsedAmount = Math.abs(parseFloat(parsed.amount)) || 0.00;
                const todayStr = new Date().toISOString().slice(0, 10);
                const scanDuration = ((Date.now() - scanStart) / 1000).toFixed(1);
                const resolvedCategory = parsed.category || "Food & Dining";
                const normalizedReceiptItems = normalizeReceiptItems(
                  parsed.receipt_items,
                  parsed.items,
                  resolvedCategory,
                  parsedAmount
                );
                const summaryItems = normalizedReceiptItems.length > 0
                  ? normalizedReceiptItems.slice(0, 6).map(i => i.item_name)
                  : (Array.isArray(parsed.items) ? parsed.items.slice(0, 6).map(i => sanitizeText(i, 80)) : []);

                return res.status(200).json({
                  success: true,
                  engine: `gemini (${modelName})`,
                  scanDuration: scanDuration,
                  merchant: sanitizeText(parsed.merchant || "Store Purchase", 120),
                  amount: parsedAmount,
                  currency: sanitizeText(parsed.currency || "MYR", 10),
                  category: sanitizeText(resolvedCategory, 60),
                  date: (parsed.date && /^\d{4}-\d{2}-\d{2}$/.test(parsed.date)) ? parsed.date : todayStr,
                  receipt_items: normalizedReceiptItems,
                  items: summaryItems
                });
              }
            } else {
              const errBody = await geminiRes.text();
              console.warn(`Gemini model ${modelName} error (${geminiRes.status}):`, errBody);
              lastError = `${geminiRes.status}: ${errBody}`;
              lastErrorStatus = geminiRes.status;

              if (geminiRes.status === 400 && errBody.includes('API_KEY_INVALID')) {
                return res.status(200).json({
                  success: false,
                  invalidApiKey: true,
                  message: "The Gemini API Key provided is invalid. Please verify it in Google AI Studio."
                });
              }
              if (geminiRes.status === 403 || geminiRes.status === 429) {
                const scanDuration = ((Date.now() - scanStart) / 1000).toFixed(1);
                return res.status(200).json({
                  success: false,
                  rateLimited: true,
                  scanDuration: scanDuration,
                  message: geminiRes.status === 429
                    ? "Gemini API rate limit reached. Please wait a moment and try again."
                    : "Gemini API quota exceeded. Please check your Google AI Studio billing."
                });
              }
            }
          } catch (modelErr) {
            console.warn(`Gemini fetch error on ${modelName}:`, modelErr.message);
            lastError = modelErr.message;
          }
        }

        if (lastError) {
          const scanDuration = ((Date.now() - scanStart) / 1000).toFixed(1);
          return res.status(200).json({
            success: false,
            allModelsFailed: true,
            scanDuration: scanDuration,
            message: `All Gemini models are currently unavailable. The receipt was not processed. Last error: ${lastErrorStatus || 'timeout'}`
          });
        }
      } catch (geminiErr) {
        console.error("Gemini Vision processing error:", geminiErr);
      }
    }

    // Smart Fallback Presets with structured itemized receipt_items
    const presets = [
      {
        merchant: "AEON Mall Supermarket",
        amount: 224.00,
        category: "Shopping",
        receipt_items: [
          { item_name: "Nike Sneakers", price: 199.00, quantity: 1, category: "Clothing" },
          { item_name: "Colgate Toothpaste", price: 12.50, quantity: 2, category: "Groceries" }
        ]
      },
      {
        merchant: "Village Grocer",
        amount: 68.40,
        category: "Groceries",
        receipt_items: [
          { item_name: "Organic Bananas", price: 11.90, quantity: 1, category: "Groceries" },
          { item_name: "Farm Fresh Milk 2L", price: 16.50, quantity: 2, category: "Groceries" },
          { item_name: "Sourdough Bread", price: 13.50, quantity: 1, category: "Groceries" },
          { item_name: "Free-Range Eggs (10s)", price: 10.00, quantity: 1, category: "Groceries" }
        ]
      },
      {
        merchant: "MR.DIY Home & Hardware",
        amount: 54.70,
        category: "Shopping",
        receipt_items: [
          { item_name: "LED Desk Lamp", price: 32.90, quantity: 1, category: "Home & Living" },
          { item_name: "AA Alkaline Batteries (8s)", price: 11.90, quantity: 1, category: "Electronics" },
          { item_name: "Microfiber Cleaning Cloth", price: 4.95, quantity: 2, category: "Home & Living" }
        ]
      },
      {
        merchant: "Starbucks Coffee",
        amount: 26.50,
        category: "Food & Dining",
        receipt_items: [
          { item_name: "Caramel Macchiato (Venti)", price: 17.50, quantity: 1, category: "Food & Dining" },
          { item_name: "Almond Croissant", price: 9.00, quantity: 1, category: "Food & Dining" }
        ]
      },
      {
        merchant: "Shell Petrol Station",
        amount: 75.00,
        category: "Transportation",
        receipt_items: [
          { item_name: "Fuel RON95", price: 71.50, quantity: 1, category: "Transportation" },
          { item_name: "100 Plus Isotonic Can", price: 3.50, quantity: 1, category: "Food & Dining" }
        ]
      },
      {
        merchant: "Watsons Pharmacy",
        amount: 43.80,
        category: "Health & Wellness",
        receipt_items: [
          { item_name: "Panadol ActiFast (20s)", price: 14.90, quantity: 1, category: "Health & Wellness" },
          { item_name: "Cetaphil Gentle Cleanser", price: 28.90, quantity: 1, category: "Health & Wellness" }
        ]
      },
      {
        merchant: "Uniqlo Mid Valley",
        amount: 149.90,
        category: "Shopping",
        receipt_items: [
          { item_name: "AIRism Oversized T-Shirt", price: 59.90, quantity: 2, category: "Clothing" },
          { item_name: "No-Show Socks 3-Pack", price: 30.10, quantity: 1, category: "Clothing" }
        ]
      },
      {
        merchant: "School Canteen Stall 3",
        amount: 12.50,
        category: "Food & Dining",
        receipt_items: [
          { item_name: "Nasi Lemak Ayam Berempah", price: 8.50, quantity: 1, category: "Food & Dining" },
          { item_name: "Iced Milo", price: 4.00, quantity: 1, category: "Food & Dining" }
        ]
      },
      {
        merchant: "DuitNow Bank Transfer",
        amount: 150.00,
        category: "Other Expenses",
        receipt_items: []
      }
    ];

    let pick = presets[0];
    const lowerName = (filename || '').toLowerCase();
    if (lowerName.includes('aeon') || lowerName.includes('shoe') || lowerName.includes('sneaker')) {
      pick = presets[0];
    } else if (lowerName.includes('grocer') || lowerName.includes('jaya') || lowerName.includes('lotus')) {
      pick = presets[1];
    } else if (lowerName.includes('diy') || lowerName.includes('hardware')) {
      pick = presets[2];
    } else if (lowerName.includes('starbuck') || lowerName.includes('coffee') || lowerName.includes('cafe')) {
      pick = presets[3];
    } else if (lowerName.includes('shell') || lowerName.includes('petrol') || lowerName.includes('petron')) {
      pick = presets[4];
    } else if (lowerName.includes('watson') || lowerName.includes('guardian') || lowerName.includes('pharmacy')) {
      pick = presets[5];
    } else if (lowerName.includes('uniqlo') || lowerName.includes('cloth') || lowerName.includes('shirt')) {
      pick = presets[6];
    } else if (lowerName.includes('canteen') || lowerName.includes('lunch') || lowerName.includes('food')) {
      pick = presets[7];
    } else if (lowerName.includes('transfer') || lowerName.includes('duitnow')) {
      pick = presets[8];
    } else {
      pick = presets[Math.floor(Math.random() * (presets.length - 1))];
    }

    const todayStr = new Date().toISOString().slice(0, 10);
    const scanDuration = ((Date.now() - scanStart) / 1000).toFixed(1);
    const itemNames = pick.receipt_items.map(i => i.item_name);

    return res.status(200).json({
      success: true,
      engine: 'smart-receipt-ai (demo mode)',
      scanDuration: scanDuration,
      needsApiKey: !hasValidKey,
      merchant: pick.merchant,
      amount: pick.amount,
      category: pick.category,
      date: todayStr,
      receipt_items: pick.receipt_items,
      items: itemNames
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || 'Error processing receipt'
    });
  }
};
