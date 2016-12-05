'use strict';

const express = require('express');

// Constants
const PORT = 80;

// App
const app = express();
app.get('/', function (req, res) {
  res.send('<h1>Hello Ambulnz</h1>\n');
});

app.listen(PORT);
console.log('Running on 0.0.0.0:' + PORT);
