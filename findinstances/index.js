const aws = require('aws-sdk')

aws.config.update({ region: 'us-west-2'})

const tags = process.argv.slice(2)
const instances = getInstancesWithTags(tags, () => {}, console.log);



function getInstancesWithTags(tags, callback) {
  console.log(`Seeking tags ${tags}`)
  const ec2 = new aws.EC2({apiVersion: '2016-11-15'})
  ec2.describeInstances({}, (err, data) => {
    if(err) return console.log(err)
    var allInstances = data.Reservations.reduce(
      (sum, res) => sum.concat(res.Instances),
      [])
    var taggedInstances = allInstances.filter(i => true)
    callback(taggedInstances)
  })
}
