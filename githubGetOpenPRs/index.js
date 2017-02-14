const Promise = require('bluebird')
const githubApi = require('github')
const github = new githubApi()

github.authenticate({
  type: 'token',
  token: 'eca6d4f3b3a6a03c36fa9be22b0307403cada4ce'
})

getOpenPullRequests()
  .then((prs)) => console.log(JSON.stringify(prs)))

function getOpenPullRequests() {
  let getPRs = Promise.promisify(github.pullRequests.getAll)
  getPRs({
    owner:   'AmbulnzLLC',
    repo:    'shadow-jsapps',
    state:   'open'
  })
}
