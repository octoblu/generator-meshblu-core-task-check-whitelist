path    = require 'path'
fs      = require 'fs-extra'
helpers = require 'yeoman-test'
assert  = require 'yeoman-assert'

TASKNAME = 'do-something'
DEST     = path.join __dirname, '..', 'tmp', "meshblu-core-task-#{TASKNAME}"

describe 'do-something', ->
  before (done) ->
    fs.mkdirsSync DEST
    helpers
      .run path.join __dirname, '..', 'app'
      .inDir DEST
      .withOptions
        realname: 'Octoblu, Inc'
        githubUrl: 'https://github.com/octoblu'
      .withPrompts
        githubUser: 'octoblu'
        taskName: TASKNAME
      .on 'end', done

  it 'creates expected files', ->
    assert.file [
      'src/do-something.coffee'
      'test/mocha.opts'
      'test/do-something-spec.coffee'
      'test/test_helper.coffee'
      'index.js'
      '.gitignore'
      '.travis.yml'
      'LICENSE'
      'README.md'
      'package.json'
    ]
