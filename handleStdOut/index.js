const exec = require('child-process-promise').exec

exec('ecko this')
  .then((data) => console.log(`STD::OUT: ${data.stdout} STD::ERR: ${data.stderr}`))
  .catch((err) => console.log(`ERROR: ${err}`))
