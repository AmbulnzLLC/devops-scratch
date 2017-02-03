const aws = require('aws-sdk')

aws.config.update({ region: 'us-west-2'})

const tags = process.argv.slice(2)
const instances = getInstancesWithTags(tags[0], tags[1], 
  (ai) => ai.forEach((i) => console.log(i.InstanceId)));

function getInstancesWithTags(repo, pr, callback) {
  const ec2 = new aws.EC2({apiVersion: '2016-11-15'})
  ec2.describeInstances({}, (err, data) => {
    if(err) return console.log(err)
    var allInstances = data.Reservations.reduce(
      (sum, res) => sum.concat(res.Instances),
      [])
    var taggedInstances = allInstances.filter(i => {
      var repoTag = i.Tags.filter(t => t.Key === 'Github Repo' && t.Value === repo) 
      var prTag =   i.Tags.filter(t => t.Key === 'Pull Request' && t.Value === pr)
      return repoTag.length > 0 && prTag.length > 0
    })
    callback(taggedInstances)
  })
}
