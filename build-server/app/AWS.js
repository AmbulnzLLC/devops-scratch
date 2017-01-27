const awsImageId = 'ami-0b33d91d'
const awsSecurityGroupIds = 'sg-a86ad7d4'
const awsKeyName = 'eph-key-pair'
const awsRegion = 'us-east-1'
const awsInstanceType = 't2.micro'
const exec = require('child_process').exec

function startInstance() {
  // Generate a random number in the range 0 - 9999
  const dockerContainerIds = Math.floor(Math.random() * 10000)

  exec(`aws ec2 run-instances --image-id ${awsImageId} --security-group-ids ${awsSecurityGroupIds} --count 1 --instance-type ${awsInstanceType} --region ${awsRegion} --key-name ${awsKeyName} --user-data ${dockerContainerIds}`, function(error, stdout, stderr) {
    if (error) {
      return console.log('Error starting instance', error)
    } else {
      console.log(stdout)
    }
  })
}

module.exports.startInstance = startInstance
