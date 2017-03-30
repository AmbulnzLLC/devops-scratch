const dateTime = require('node-datetime');
dateTime.setOffsetInHours(-5);

const dt = dateTime.create();
const formattedDt = dt.format('Y-m-d H:M:S');

console.log(formattedDt);
