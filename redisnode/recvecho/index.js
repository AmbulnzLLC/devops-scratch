const redis = require('redis');
const redisUrl = process.env.REDIS_URL || 'redis://127.0.0.1:6379';

console.log('creating sub client');
const subClient = redis.createClient(redisUrl);
subClient.on("message", (channel, message) => console.log(channel + ":", message));
subClient.subscribe("channel0");
