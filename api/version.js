module.exports = (req, res) => {
  res.setHeader('Content-Type', 'application/json');
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.status(200).json({
    success: true,
    version: 1,
    lastUpdated: Date.now() / 1000,
    count: 6
  });
};
