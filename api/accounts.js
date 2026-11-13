module.exports = (req, res) => {
  res.setHeader('Content-Type', 'application/json');
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Cache-Control', 'no-store');
  if (req.method === 'OPTIONS') return res.status(200).end();

  // SECURITY (Confidentiality): Never expose passwordHash or sensitive tokens in API responses
  res.status(200).json({
    success: true,
    accounts: {
      "demo@finwise-app.xyz": {
        id: "00000000-0000-4000-8000-000000000001",
        name: "Demo Finwise",
        email: "demo@finwise-app.xyz",
        phone: "",
        occupation: "",
        currency: "RM",
        monthlyBudget: 2500,
        avatar: "D"
      }
    }
  });
};
