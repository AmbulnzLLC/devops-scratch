const aws = require('aws-sdk')

aws.config.update({ region: 'us-west-2'})

const tags = process.argv.slice(2)
const instances = getInstancesWithTags(tags[0], tags[1], () => {}, console.log);

function getInstancesWithTags(repo, pr, callback) {
  console.log(`Seeking tags ${tags}`)
  const ec2 = new aws.EC2({apiVersion: '2016-11-15'})
  ec2.describeInstances({}, (err, data) => {
    if(err) return console.log(err)
    var allInstances = data.Reservations.reduce(
      (sum, res) => sum.concat(res.Instances),
      [])
    var taggedInstances = allInstances.filter(i => {
      var repoTag = i.Tags.filter(t => t.Key === 'Github Repo' && t.Value === repo) 
      var prTag =   i.Tags.filter(t => t.Key === 'Pull Request' && t.Value === pr)
    })
    callback(taggedInstances)
  })
}
