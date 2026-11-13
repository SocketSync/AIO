const defaultSeedTransactions = [
  {
    "id": "tx_seed_001",
    "title": "Monthly Tech Salary",
    "description": "Monthly Tech Salary",
    "amount": 4800.0,
    "type": "income",
    "category": "Salary",
    "category_id": "salary",
    "date": "2026-11-12",
    "receipt_items": []
  },
  {
    "id": "tx_seed_002",
    "title": "AEON Mall Supermarket & Footwear",
    "description": "AEON Mall Supermarket & Footwear",
    "amount": 224.0,
    "type": "expense",
    "category": "Shopping",
    "category_id": "shopping",
    "date": "2026-11-01",
    "receipt_items": [
      { "item_name": "Nike Sneakers", "price": 199.00, "quantity": 1, "category": "Clothing" },
      { "item_name": "Colgate Toothpaste", "price": 12.50, "quantity": 2, "category": "Groceries" }
    ]
  },
  {
    "id": "tx_seed_003",
    "title": "JD Sports Mid Valley",
    "description": "JD Sports Mid Valley",
    "amount": 189.0,
    "type": "expense",
    "category": "Shopping",
    "category_id": "shopping",
    "date": "2026-11-03",
    "receipt_items": [
      { "item_name": "Casual Running Shoes", "price": 169.00, "quantity": 1, "category": "Clothing" },
      { "item_name": "Athletic Crew Socks", "price": 20.00, "quantity": 1, "category": "Clothing" }
    ]
  },
  {
    "id": "tx_seed_004",
    "title": "Village Grocer Weekly",
    "description": "Village Grocer Weekly",
    "amount": 142.5,
    "type": "expense",
    "category": "Groceries",
    "category_id": "groceries",
    "date": "2026-11-12",
    "receipt_items": [
      { "item_name": "Organic Bananas", "price": 14.50, "quantity": 1, "category": "Groceries" },
      { "item_name": "Farm Fresh Milk 2L", "price": 18.90, "quantity": 2, "category": "Groceries" },
      { "item_name": "Artisan Sourdough Loaf", "price": 16.00, "quantity": 1, "category": "Groceries" }
    ]
  },
  {
    "id": "tx_seed_005",
    "title": "Coffee & Bistro Lunch",
    "description": "Coffee & Bistro Lunch",
    "amount": 28.0,
    "type": "expense",
    "category": "Food & Dining",
    "category_id": "food_dining",
    "date": "2026-11-11",
    "receipt_items": [
      { "item_name": "Flat White Coffee", "price": 13.00, "quantity": 1, "category": "Food & Dining" },
      { "item_name": "Sourdough Avocado Toast", "price": 15.00, "quantity": 1, "category": "Food & Dining" }
    ]
  },
  {
    "id": "tx_seed_006",
    "title": "Electricity & Water Utilities",
    "description": "Electricity & Water Utilities",
    "amount": 115.8,
    "type": "expense",
    "category": "Bills & Utilities",
    "category_id": "bills_utilities",
    "date": "2026-11-10",
    "receipt_items": []
  },
  {
    "id": "tx_seed_007",
    "title": "Touch N Go / Transit Reload",
    "description": "Touch N Go / Transit Reload",
    "amount": 50.0,
    "type": "expense",
    "category": "Transportation",
    "category_id": "transportation",
    "date": "2026-11-07",
    "receipt_items": []
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
