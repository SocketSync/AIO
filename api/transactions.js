const defaultSeedTransactions = [
  {
    "id": "tx_seed_001",
    "title": "Monthly Tech Salary",
    "description": "Monthly Tech Salary",
    "amount": 4800.0,
    "type": "income",
    "category": "Salary",
    "category_id": "salary",
    "date": "2026-11-12"
  },
  {
    "id": "tx_seed_002",
    "title": "Village Grocer Weekly",
    "description": "Village Grocer Weekly",
    "amount": 142.5,
    "type": "expense",
    "category": "Groceries",
    "category_id": "groceries",
    "date": "2026-11-12"
  },
  {
    "id": "tx_seed_003",
    "title": "Coffee & Bistro Lunch",
    "description": "Coffee & Bistro Lunch",
    "amount": 28.0,
    "type": "expense",
    "category": "Food & Dining",
    "category_id": "food_dining",
    "date": "2026-11-11"
  },
  {
    "id": "tx_seed_004",
    "title": "Electricity & Water Utilities",
    "description": "Electricity & Water Utilities",
    "amount": 115.8,
    "type": "expense",
    "category": "Bills & Utilities",
    "category_id": "bills_utilities",
    "date": "2026-11-10"
  },
  {
    "id": "tx_seed_005",
    "title": "Freelance Mobile Consulting",
    "description": "Freelance Mobile Consulting",
    "amount": 750.0,
    "type": "income",
    "category": "Freelance",
    "category_id": "freelance",
    "date": "2026-11-08"
  },
  {
    "id": "tx_seed_006",
    "title": "Touch N Go / Transit Reload",
    "description": "Touch N Go / Transit Reload",
    "amount": 50.0,
    "type": "expense",
    "category": "Transportation",
    "category_id": "transportation",
    "date": "2026-11-07"
  }
];

module.exports = (req, res) => {
  res.setHeader('Content-Type', 'application/json');
  res.setHeader('Access-Control-Allow-Origin', '*');
  if (req.method === 'OPTIONS') return res.status(200).end();

  res.status(200).json({
    success: true,
    version: 1,
    count: defaultSeedTransactions.length,
    transactions: defaultSeedTransactions
  });
};
