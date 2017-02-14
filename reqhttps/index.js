var https = require('https');

https://am-1876.ambulnz-dev.com:5143/

var options = {
  host: 'am-1876.ambulnz-dev.com',
  port: 5143,
  path: '/'
};

http.get(options, function(res) {
  console.log("Got response: " + res.statusCode);
}).on('error', function(e) {
  console.log("Got error: " + e.message);
});
