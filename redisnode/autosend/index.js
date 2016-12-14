const redis = require('redis');
const redisUrl = process.env.REDIS_URL || 'redis://127.0.0.1:6379';
console.log('redis at: ', redisUrl);
