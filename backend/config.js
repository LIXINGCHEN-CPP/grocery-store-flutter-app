// Backend Configuration
const config = {
  // MongoDB Atlas Connection
  mongodbUri: 'mongodb+srv://xli503441:lxc159357%40GOD@cluster0.isy9cqv.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0',
  databaseName: 'grocery_store',

  // Server Configuration
  port: process.env.PORT || 3000,
  nodeEnv: process.env.NODE_ENV || 'development',

  // CORS Configuration
  corsOrigin: '*',

  // JWT Configuration
  jwtSecret: process.env.JWT_SECRET || 'your-secret-key-here',
  jwtExpire: process.env.JWT_EXPIRE || '1d'
};

module.exports = config; 