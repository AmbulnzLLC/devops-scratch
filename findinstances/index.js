const aws = require('aws-sdk')

const tags = process.argv.slice(2)
const instances = getInstancesWithTags(tags);
console.log(instances);

function getInstancesWithTags(tags) {
  console.log(`Seeking tags ${tags}`)
}
