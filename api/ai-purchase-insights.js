function getOrdinalDay(dateStr) {
  if (!dateStr) return 'recently';
  const parts = String(dateStr).slice(0, 10).split('-');
  if (parts.length !== 3) return dateStr;
  const day = parseInt(parts[2], 10);
  if (!Number.isFinite(day)) return dateStr;
  if (day > 3 && day < 21) return `${day}th`;
  switch (day % 10) {
    case 1: return `${day}st`;
    case 2: return `${day}nd`;
    case 3: return `${day}rd`;
    default: return `${day}th`;
  }
}

const ITEM_TOPIC_GROUPS = [
  { key: 'shoes', label: 'shoes', budgetCategory: 'Clothing', keywords: ['shoe', 'shoes', 'sneaker', 'sneakers', 'footwear', 'boots', 'sandal', 'trainers', 'running'] },
  { key: 'clothing', label: 'clothing items', budgetCategory: 'Clothing', keywords: ['shirt', 't-shirt', 'pants', 'jeans', 'jacket', 'hoodie', 'dress', 'socks', 'uniqlo', 'apparel'] },
  { key: 'coffee', label: 'coffee/drinks', budgetCategory: 'Food & Dining', keywords: ['coffee', 'latte', 'americano', 'espresso', 'cappuccino', 'macchiato', 'boba', 'matcha', 'tea', 'starbucks', 'zus'] },
  { key: 'snacks', label: 'snacks & treats', budgetCategory: 'Food & Dining', keywords: ['croissant', 'cake', 'pastry', 'donut', 'ice cream', 'chocolate', 'snack', 'bistro'] },
  { key: 'electronics', label: 'electronics accessories', budgetCategory: 'Shopping', keywords: ['cable', 'charger', 'earbuds', 'mouse', 'keyboard', 'battery', 'batteries', 'usb', 'lamp'] },
  { key: 'groceries', label: 'grocery essentials', budgetCategory: 'Groceries', keywords: ['milk', 'bread', 'eggs', 'banana', 'toothpaste', 'sourdough'] }
];

function detectTopicForItem(itemName, categoryName) {
  const lower = `${itemName || ''} ${categoryName || ''}`.toLowerCase();
  for (const group of ITEM_TOPIC_GROUPS) {
    if (group.keywords.some(kw => lower.includes(kw))) {
      return group;
    }
  }
  return null;
}

function buildDeterministicInsight(recentTransactions = [], currentReceipt = null, currency = 'RM') {
  const now = new Date();
  const cutoffMs = now.getTime() - 14 * 86400000;

  const combined = Array.isArray(recentTransactions) ? [...recentTransactions] : [];
  if (currentReceipt && (currentReceipt.merchant || (Array.isArray(currentReceipt.receipt_items) && currentReceipt.receipt_items.length > 0))) {
    combined.unshift({
      id: 'current_scan',
      description: currentReceipt.merchant || currentReceipt.description || 'Recent Purchase',
      category: currentReceipt.category || 'Shopping',
      date: currentReceipt.date || now.toISOString().slice(0, 10),
      amount: Number(currentReceipt.amount || 0),
      type: 'expense',
      receipt_items: Array.isArray(currentReceipt.receipt_items) ? currentReceipt.receipt_items : []
    });
  }

  // Filter to expenses within the last 14 days
  const last14Days = combined.filter(tx => {
    if (!tx || tx.type === 'income') return false;
    const dStr = String(tx.date || tx.transaction_date || '').slice(0, 10);
    if (!dStr) return false;
    const ts = new Date(dStr + 'T12:00:00Z').getTime();
    return Number.isFinite(ts) && ts >= cutoffMs;
  });

  // Collect all itemized records with transaction dates
  const topicOccurrences = {};
  const categoryOccurrences = {};

  for (const tx of last14Days) {
    const dateStr = String(tx.date || tx.transaction_date || '').slice(0, 10);
    const items = Array.isArray(tx.receipt_items) ? tx.receipt_items : [];

    if (items.length > 0) {
      for (const item of items) {
        if (!item || !item.item_name) continue;
        const topic = detectTopicForItem(item.item_name, item.category || tx.category);
        if (topic) {
          if (!topicOccurrences[topic.key]) {
            topicOccurrences[topic.key] = { group: topic, entries: [] };
          }
          topicOccurrences[topic.key].entries.push({
            date: dateStr,
            itemName: item.item_name,
            price: Number(item.price || 0) * (parseInt(item.quantity, 10) || 1),
            category: item.category || topic.budgetCategory
          });
        }

        const subCat = String(item.category || tx.category || '').trim();
        if (subCat) {
          if (!categoryOccurrences[subCat]) categoryOccurrences[subCat] = [];
          categoryOccurrences[subCat].push({ date: dateStr, itemName: item.item_name, price: Number(item.price || 0) });
        }
      }
    } else {
      const topic = detectTopicForItem(tx.description || tx.title, tx.category);
      if (topic) {
        if (!topicOccurrences[topic.key]) {
          topicOccurrences[topic.key] = { group: topic, entries: [] };
        }
        topicOccurrences[topic.key].entries.push({
          date: dateStr,
          itemName: tx.description || tx.title || topic.label,
          price: Number(tx.amount || 0),
          category: topic.budgetCategory
        });
      }
    }
  }

  // Prioritize strong duplicate detections (e.g., shoes, clothing, coffee, snacks)
  const rankedTopics = Object.values(topicOccurrences)
    .filter(bucket => {
      const uniqueDates = new Set(bucket.entries.map(e => e.date));
      return bucket.entries.length >= 2 && (uniqueDates.size >= 2 || bucket.entries.length >= 2);
    })
    .sort((a, b) => {
      // Prioritize Clothing/Shoes or higher spend
      const scoreA = (a.group.key === 'shoes' ? 500 : 0) + a.entries.reduce((s, e) => s + e.price, 0);
      const scoreB = (b.group.key === 'shoes' ? 500 : 0) + b.entries.reduce((s, e) => s + e.price, 0);
      return scoreB - scoreA;
    });

  if (rankedTopics.length > 0) {
    const top = rankedTopics[0];
    const sortedEntries = [...top.entries].sort((a, b) => a.date.localeCompare(b.date));
    const uniqueDates = [...new Set(sortedEntries.map(e => e.date))];
    const totalSpend = sortedEntries.reduce((s, e) => s + (Number(e.price) || 0), 0);
    const ordinalList = uniqueDates.slice(-3).map(d => `the ${getOrdinalDay(d)}`);
    const formattedDates = ordinalList.length === 2
      ? `${ordinalList[0]} and ${ordinalList[1]}`
      : ordinalList.length > 2
        ? `${ordinalList.slice(0, -1).join(', ')}, and ${ordinalList[ordinalList.length - 1]}`
        : `${ordinalList[0]} (${sortedEntries.length}x)`;

    const insight = `✨ FinWise noticed: You bought ${top.group.label} on ${formattedDates} of this month! Treating yourself is great, but keep an eye on your '${top.group.budgetCategory}' budget (${currency} ${totalSpend.toFixed(2)} spent) to avoid overspending this month~`;

    return {
      duplicateDetected: true,
      repeatedTopic: top.group.label,
      repeatedCategory: top.group.budgetCategory,
      occurrences: sortedEntries,
      insight
    };
  }

  // Fallback check: repeated sub-category in receipt_items across >= 2 receipts
  const repeatedCat = Object.entries(categoryOccurrences)
    .filter(([, list]) => new Set(list.map(x => x.date)).size >= 2)
    .sort((a, b) => b[1].length - a[1].length)[0];

  if (repeatedCat) {
    const [catName, list] = repeatedCat;
    const dates = [...new Set(list.map(x => x.date))].sort().slice(-2);
    const insight = `✨ FinWise noticed: You had ${list.length} '${catName}' item purchases on the ${getOrdinalDay(dates[0])} and the ${getOrdinalDay(dates[1])} within 14 days. Batching these trips could help keep your budget on track~`;
    return {
      duplicateDetected: true,
      repeatedTopic: catName.toLowerCase(),
      repeatedCategory: catName,
      occurrences: list,
      insight
    };
  }

  return {
    duplicateDetected: false,
    repeatedTopic: null,
    repeatedCategory: null,
    occurrences: [],
    insight: "✨ FinWise noticed: Your itemized receipt purchases over the last 14 days look well-balanced with no repetitive impulse buys. Keep up the mindful spending!"
  };
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

  try {
    const { recentTransactions = [], currentReceipt = null, currency = 'RM', apiKey = '' } = req.body || {};
    const deterministic = buildDeterministicInsight(recentTransactions, currentReceipt, currency);

    const geminiKey = (apiKey || process.env.GEMINI_API_KEY || '').trim();
    const hasValidKey = geminiKey && !geminiKey.includes('your-gemini') && geminiKey.length > 20;

    // Collect compact 14-day receipt summary for LLM prompt if Gemini is configured
    const now = Date.now();
    const last14Summary = (Array.isArray(recentTransactions) ? recentTransactions : [])
      .filter(tx => {
        if (!tx || tx.type === 'income') return false;
        const dStr = String(tx.date || '').slice(0, 10);
        const ts = new Date(dStr + 'T12:00:00Z').getTime();
        return Number.isFinite(ts) && ts >= now - 14 * 86400000;
      })
      .slice(0, 25)
      .map(tx => ({
        date: String(tx.date || '').slice(0, 10),
        merchant: tx.description || tx.title || '',
        category: tx.category || '',
        amount: tx.amount,
        receipt_items: Array.isArray(tx.receipt_items) ? tx.receipt_items : []
      }));

    const hasAnyItemizedData = last14Summary.some(t => t.receipt_items.length > 0) ||
      (currentReceipt && Array.isArray(currentReceipt.receipt_items) && currentReceipt.receipt_items.length > 0);

    if (hasValidKey && hasAnyItemizedData) {
      try {
        const prompt = `You are FinWise, a warm, friendly personal finance assistant.
Look at the user's itemized receipt purchases from the last 14 days and today's receipt.
Look for duplicate purchases or unusual frequencies and provide a single, short, and friendly piece of financial advice.
Start the sentence with "✨ FinWise noticed:" and keep it concise (1-2 sentences max, currency is ${currency}).

Last 14 days receipts: ${JSON.stringify(last14Summary)}
Today's receipt (if any): ${JSON.stringify(currentReceipt)}

Respond with plain text only (no markdown headings or bullet points).`;

        const controller = new AbortController();
        const timeout = setTimeout(() => controller.abort(), 7000);
        const endpoint = `https://generativelanguage.googleapis.com/v1beta/models/gemini-3.5-flash-lite:generateContent?key=${geminiKey}`;

        const geminiRes = await fetch(endpoint, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          signal: controller.signal,
          body: JSON.stringify({
            contents: [{ parts: [{ text: prompt }] }],
            generationConfig: { temperature: 0.4, maxOutputTokens: 160 }
          })
        });
        clearTimeout(timeout);

        if (geminiRes.ok) {
          const data = await geminiRes.json();
          const llmText = (data?.candidates?.[0]?.content?.parts?.[0]?.text || '').trim();
          if (llmText) {
            return res.status(200).json({
              success: true,
              engine: 'gemini-insights',
              ...deterministic,
              insight: llmText.startsWith('✨') ? llmText : `✨ FinWise noticed: ${llmText}`
            });
          }
        }
      } catch (e) {
        console.warn('Gemini purchase insight fallback notice:', e.message);
      }
    }

    return res.status(200).json({
      success: true,
      engine: 'smart-pattern-agent',
      ...deterministic
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || 'Failed to analyze purchase insights'
    });
  }
};

