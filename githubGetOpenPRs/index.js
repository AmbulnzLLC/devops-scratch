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
