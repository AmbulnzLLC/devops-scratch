const redis = require('redis');
const redisUrl = process.env.REDIS_URL || 'redis://127.0.0.1:6379';
const coreClient = redis.createClient(redisUrl);

coreClient.set("user_8675309", "Jenny");
coreClient.get("user_8675309", (err, reply) => console.log("User 8675309: ", err || reply));

const pubClient = redis.createClient(redisUrl);
const subClient = redis.createClient(redisUrl);

subClient.on("subscribe", (channel, count) => pubClient.publish("channel0", "Welcome to " + channel));
subClient.on("message", (channel, message) => console.log(channel + ":", message));
subClient.subscribe("channel0");

subClient.quit();
pubClient.quit();
