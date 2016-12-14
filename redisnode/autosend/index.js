const redis = require('redis');
const redisUrl = process.env.REDIS_URL || 'redis://127.0.0.1:6379';
const coreClient = redis.createClient(redisUrl);

coreClient.set("user_8675309", "Jenny");
coreClient.get("user_8675309", (err, reply) => console.log("User 8675309: ", err || reply));

coreClient.quit();

console.log('creating pub client');
const pubClient = redis.createClient(redisUrl);
console.log('creating sub client');
const subClient = redis.createClient(redisUrl);

function startLoop(channel, count) {
    pubClient.publish("channel0", "Welcome to " + channel);

}

subClient.on("subscribe", startLoop);
subClient.on("message", (channel, message) => console.log(channel + ":", message));
subClient.subscribe("channel0");
