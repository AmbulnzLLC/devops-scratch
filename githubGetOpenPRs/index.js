const githubApi = require('github')
const github = new githubApi()

github.authenticate({
  type: 'token',
  token: 'eca6d4f3b3a6a03c36fa9be22b0307403cada4ce'
})

getOpenPullRequests()

function getOpenPullRequests() {
  github.pullRequests.getAll({
    owner:   'AmbulnzLLC',
    repo:    'shadow-jsapps',
    state:   'open'
  }, (err, res) => {
    console.log(`Open Pull Requests: ${JSON.stringify(res)}`)
  })
}
