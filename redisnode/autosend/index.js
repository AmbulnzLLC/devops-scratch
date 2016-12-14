const redis = require('redis');
const redisUrl = process.env.REDIS_URL || 'redis://127.0.0.1:6379';
const client = redis.createClient(redisUrl);

client.set("user_8675309", "Jenny");
client.get("user_8675309", (err, reply) => console.log("User 8675309: ", err || reply));
