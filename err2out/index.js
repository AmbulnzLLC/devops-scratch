let winston = require('winston')
let exec = require('child_process').exec

winston.info('This is informative.')
winston.error('This is erronious.')
exec('(./inner.sh) 2>&1')
