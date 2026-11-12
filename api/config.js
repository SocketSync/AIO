module.exports = (req, res) => {
  res.setHeader('Content-Type', 'application/json');
  res.setHeader('Access-Control-Allow-Origin', '*');
  if (req.method === 'OPTIONS') return res.status(200).end();

  // Only public client configuration (anon key) is exposed here; never service_role keys
  res.status(200).json({
    success: true,
    supabaseUrl: process.env.SUPABASE_URL || 'https://vcxxsffdsznmqtpghrss.supabase.co',
    supabaseAnonKey: process.env.SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZjeHhzZmZkc3pubXF0cGdocnNzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTQyMjgwOTMsImV4cCI6MjEwOTgwNDA5M30.bxxoU1PgcSeOMkss5kx71dI3P67eTL9bk9TzaJC_1VM',
    appUrl: process.env.APP_URL || 'https://www.finwise-app.xyz'
  });
};
