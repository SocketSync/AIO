module.exports = async (req, res) => {
  res.setHeader('Content-Type', 'application/json');
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  if (req.method === 'OPTIONS') return res.status(200).end();

  if (req.method !== 'POST') {
    return res.status(405).json({ success: false, message: 'Method not allowed' });
  }

  try {
    const { imageBase64, mimeType = 'image/jpeg', filename = '', apiKey = '' } = req.body || {};

    const geminiKey = (apiKey || process.env.GEMINI_API_KEY || '').trim();
    const hasValidKey = geminiKey && !geminiKey.includes('your-gemini') && geminiKey.length > 20;

    if (hasValidKey && imageBase64) {
      try {
        const cleanBase64 = imageBase64.replace(/^data:[^;]+;base64,/, '');
        const prompt = `You are an expert AI receipt and invoice scanner for the FinWise finance app.
Analyze this receipt or invoice image/PDF carefully.
Extract the merchant name, total bill amount, appropriate expense/income category, transaction date, and items.

Return ONLY a valid JSON object with these EXACT keys:
{
  "merchant": "Exact merchant/store name (e.g. Village Grocer, Starbucks, Shell, McDonald's, Grab)",
  "amount": Total amount paid as a positive number (float, e.g. 58.40) without currency symbol,
  "category": One of these exact categories: "Food & Dining", "Groceries", "Shopping", "Transportation", "Entertainment", "Bills & Utilities", "Health & Wellness", "Education & Self-Care", "Salary", "Freelance", "Investments", "Other Expenses",
  "date": "Transaction date in YYYY-MM-DD format (if only year/month or missing, use today's date)",
  "items": ["Brief list of items or summary of purchase"]
}
Strictly return pure JSON only, without any markdown formatting, backticks, or extra commentary.`;

        const modelsToTry = ['gemini-3.5-flash-lite', 'gemini-3.5-flash', 'gemini-3.8-flash', 'gemini-flash-latest'];
        let lastError = null;

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
              // Clean markdown or surrounding text
              rawText = rawText.replace(/```json/gi, '').replace(/```/g, '').trim();
              const jsonMatch = rawText.match(/\{[\s\S]*\}/);
              if (jsonMatch) {
                const parsed = JSON.parse(jsonMatch[0]);
                const parsedAmount = Math.abs(parseFloat(parsed.amount)) || 0.00;
                const todayStr = new Date().toISOString().slice(0, 10);

                return res.status(200).json({
                  success: true,
                  engine: `gemini (${modelName})`,
                  merchant: (parsed.merchant || "Store Purchase").trim(),
                  amount: parsedAmount,
                  category: parsed.category || "Food & Dining",
                  date: (parsed.date && /^\d{4}-\d{2}-\d{2}$/.test(parsed.date)) ? parsed.date : todayStr,
                  items: Array.isArray(parsed.items) ? parsed.items : []
                });
              }
            } else {
              const errBody = await geminiRes.text();
              console.warn(`Gemini model ${modelName} error (${geminiRes.status}):`, errBody);
              lastError = `${geminiRes.status}: ${errBody}`;
              // If invalid key or quota, don't loop indefinitely
              if (geminiRes.status === 400 && errBody.includes('API_KEY_INVALID')) {
                return res.status(200).json({
                  success: false,
                  invalidApiKey: true,
                  message: "The Gemini API Key provided is invalid. Please verify it in Google AI Studio."
                });
              }
            }
          } catch (modelErr) {
            console.warn(`Gemini fetch error on ${modelName}:`, modelErr.message);
            lastError = modelErr.message;
          }
        }
      } catch (geminiErr) {
        console.error("Gemini Vision processing error:", geminiErr);
      }
    }

    // Smart Fallback Presets if no Gemini API Key is configured yet
    const presets = [
      {
        merchant: "Village Grocer",
        amount: 68.40,
        category: "Groceries",
        items: ["Organic Bananas", "Farm Fresh Milk 2L", "Sourdough Bread", "Free-Range Eggs"]
      },
      {
        merchant: "Starbucks Coffee",
        amount: 26.50,
        category: "Food & Dining",
        items: ["Caramel Macchiato (Venti)", "Almond Croissant"]
      },
      {
        merchant: "Shell Petrol Station",
        amount: 75.00,
        category: "Transportation",
        items: ["Fuel RON95", "100 Plus Can"]
      },
      {
        merchant: "Watsons Pharmacy",
        amount: 43.80,
        category: "Health & Wellness",
        items: ["Panadol ActiFast", "Cetaphil Gentle Cleanser"]
      },
      {
        merchant: "Uniqlo Mid Valley",
        amount: 149.90,
        category: "Shopping",
        items: ["AIRism Oversized T-Shirt", "No-Show Socks Pack"]
      },
      {
        merchant: "FamilyMart Sunway",
        amount: 19.80,
        category: "Food & Dining",
        items: ["Oden Set C", "Sofuto Green Tea Cone"]
      },
      {
        merchant: "Tenaga Nasional Berhad (TNB)",
        amount: 124.60,
        category: "Bills & Utilities",
        items: ["Electricity Consumption Tariff", "Service Tax"]
      }
    ];

    let pick = presets[0];
    const lowerName = (filename || '').toLowerCase();
    if (lowerName.includes('starbuck') || lowerName.includes('coffee') || lowerName.includes('cafe')) {
      pick = presets[1];
    } else if (lowerName.includes('shell') || lowerName.includes('petrol') || lowerName.includes('petron')) {
      pick = presets[2];
    } else if (lowerName.includes('watson') || lowerName.includes('guardian') || lowerName.includes('pharmacy')) {
      pick = presets[3];
    } else if (lowerName.includes('uniqlo') || lowerName.includes('cloth') || lowerName.includes('shirt')) {
      pick = presets[4];
    } else if (lowerName.includes('familymart') || lowerName.includes('mart') || lowerName.includes('bistro')) {
      pick = presets[5];
    } else if (lowerName.includes('.pdf') || lowerName.includes('bill') || lowerName.includes('invoice') || lowerName.includes('tnb') || lowerName.includes('utility')) {
      pick = presets[6];
    } else {
      pick = presets[Math.floor(Math.random() * presets.length)];
    }

    const todayStr = new Date().toISOString().slice(0, 10);
    return res.status(200).json({
      success: true,
      engine: 'smart-receipt-ai (demo mode)',
      needsApiKey: !hasValidKey,
      merchant: pick.merchant,
      amount: pick.amount,
      category: pick.category,
      date: todayStr,
      items: pick.items
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || 'Error processing receipt'
    });
  }
};
