module.exports = (req, res) => {
  res.setHeader('Content-Type', 'application/json');
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.status(200).json({
    success: true,
    accounts: {
      "ykwei2005@gmail.com": {
        id: "00000000-0000-4000-8000-000000000001",
        name: "Ken Wei",
        email: "ykwei2005@gmail.com",
        phone: "+60 12-882 1928",
        occupation: "Financial Analyst & Tech Lead",
        currency: "RM",
        monthlyBudget: 2500,
        avatar: "K",
        passwordHash: "989a2c9493e8051c86a809ae60c025b6fff7a79de475aa91ebac2e2b562fb322"
      },
      "ptutm.kengwei@gmail.com": {
        id: "00000000-0000-4000-8000-000000000002",
        name: "John Yeoh",
        email: "ptutm.kengwei@gmail.com",
        phone: "+60 17-331 4982",
        occupation: "Senior Product Designer",
        currency: "RM",
        monthlyBudget: 3000,
        avatar: "J",
        passwordHash: "989a2c9493e8051c86a809ae60c025b6fff7a79de475aa91ebac2e2b562fb322"
      }
    }
  });
};

