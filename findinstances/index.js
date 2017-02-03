const aws = require('aws-sdk')

const tags = process.argv.slice(2)
const instances = getInstancesWithTags(tags, console.log);


function getInstancesWithTags(tags, callback) {
  console.log(`Seeking tags ${tags}`)
  const ec2 = new aws.EC2({apiVersion: '2016-11-15'})
  ec2.describeInstances((err, {region: 'us-west-2'}, data) => {
    if(err) return console.log(err)
    console.log(JSON.stringify(data))
  })
}
