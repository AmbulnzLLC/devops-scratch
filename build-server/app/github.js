const fs = require('fs')
const fx = require('mkdir-recursive')
const exec = require('child_process').exec
const githubApi = require('github')
const github = new githubApi()
const owner = 'hutchiep190'
const AWS = require('./AWS')

github.authenticate({
  type: 'token',
  token: process.env.GITHUB_TOKEN
})

function getPullRequest(repo, number, callback) {
  github.pullRequests.get({
    owner: owner,
    repo: repo,
    number: number
  }, function (err, res) {
    callback(err, res)
  })
}

function dirFor(repo, branch) {
  return `github.com/${owner}/${repo}/${branch}`
}

function cloneRepository(repo, branch, dir, callback) {
  console.log(`cloning ${dir}`)
  fx.mkdir(dir, (err) => {
    exec(`git clone git@github.com:${owner}/${repo} ${dir}`, function(error, stdout, stderr) {
      if (error) {
        return console.log('Error cloning github repo', error)
      }
      if (typeof callback === 'function') {
        callback()
      }
    })
  })
}

function checkoutBranch(branch, dir, callback) {
  console.log(`checking out ${branch} in ${dir}`)
  exec(`cd ${dir}; git fetch`, function(error, stdout, stderr) {
    if (error) {
      return console.log('Error fetching from github', error)
    }
    exec(`cd ${dir}; git reset --hard origin/${branch}`, function(error, stdout, stderr) {
      if (error) {
        return console.log('Error resetting repo', error)
      }
      exec(`cd ${dir}; git checkout -f ${branch}; git branch`, function(error, stdout, stderr) {
        if (error) {
          return console.log('Error checking out branch', error)
        }
        if (typeof callback === 'function') {
          callback()
        }
      })
    })
  })
}

function ensureCheckedOut(repo, branch, dir, callback) {
  fs.access(dir, (err) => {
    if (err) {
      if (err.code === "ENOENT") {
        cloneRepository(repo, branch, dir, () => {
          checkoutBranch(branch, dir, callback)
        })
      } else {
        throw err
      }
    } else {
      checkoutBranch(branch, dir, callback)
    }
  })
}

function mergeBranchInDirectory(dir, branch, callback) {
  exec(`cd ${dir}; git merge origin/${branch} --no-ff -m 'avoid prompt'`, function(error, stdout, stderr) {
    if (error) {
      return console.log('Error merging branch', error)
    }
    if (typeof callback === 'function') {
      callback()
    }
  })
}

function setupRepository(repo, headBranch, baseBranch, callback) {
  const headDir = dirFor(repo, headBranch)
  const baseDir = dirFor(repo, baseBranch)
  ensureCheckedOut(repo, baseBranch, baseDir, () => {
    ensureCheckedOut(repo, headBranch, headDir, () => {
      mergeBranchInDirectory(headDir, baseBranch, callback)
    })
  })
}

function handleAction(repo, number, action) {
  if (action != 'opened') {
    console.log(`Not handling action ${action}`)
    return
  }

  getPullRequest(repo, number, function (err, pullRequest) {
    if (err) {
      return console.log('Error getting pull request', err)
    }
    const baseBranch = pullRequest.base.ref
    const headBranch = pullRequest.head.ref
    console.log(`Handling pull request from branch ${headBranch} to branch ${baseBranch}`)
    setupRepository(repo, headBranch, baseBranch, () => {
      AWS.startInstance()
    })
  })
}

module.exports.handleAction = handleAction
