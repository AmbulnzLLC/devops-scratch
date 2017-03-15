const aws = require('aws-sdk');
const awsLogs = new aws.CloudWatchLogs({apiVersion: '2016-11-15'});
const winston = require('winston'); 

function createLogGroup(prName) {
  awsLogs.createLogGroup(
    { "logGroupName": `ambulnz-${prName}` }, 
    (err, data) => { 
      if(err) { winston.info(`error: ${err}`) } else {
        winston.info(`data: ${data}`)
      } 
    })
  winston.log('created log group')
}

createLogGroup(process.argv[2]);
