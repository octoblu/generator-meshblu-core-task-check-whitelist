require 'coffee-errors'

_          = require 'lodash'
util       = require 'util'
path       = require 'path'
url        = require 'url'
GitHubApi  = require 'github'
yeoman     = require 'yeoman-generator'
HTMLWiring = require 'html-wiring'

getCoreTaskName = (appname) ->
  slugged = _.kebabCase appname
  match = slugged.match /^meshblu-core-task-(.+)/
  return match[1].toLowerCase() if match and match.length is 2
  slugged

githubUserInfo = (name, cb) ->
  github = new GitHubApi version: '3.0.0'
  github.user.getFrom user: name, cb

class MeshbluCoreTaskGenerator extends yeoman.Base
  constructor: (args, options, config) ->
    super
    @currentYear = (new Date()).getFullYear()
    {@realname, @githubUrl} = options
    @on 'end', => @installDependencies skipInstall: options['skip-install']
    @pkg = JSON.parse HTMLWiring.readFileAsString path.join __dirname, '../package.json'

  askFor: ->
    done = @async()
    taskName = getCoreTaskName @appname

    prompts = [
      name: 'githubUser'
      message: 'Would you mind telling me your username on GitHub?'
      default: 'octoblu'
    ,
      name: 'taskName'
      message: 'What\'s the base name of your task?'
      default: taskName
    ]

    @prompt prompts, (props) =>
      @githubUser = props.githubUser
      @taskName = props.taskName
      @appname = "meshblu-core-task-#{@taskName}"
      @className = _.upperFirst(_.camelCase(@taskName))
      @methodName = _.camelCase(@taskName).replace(/Whitelist/, '')
      done()

  userInfo: ->
    return if @realname? and @githubUrl?

    done = @async()

    githubUserInfo @githubUser, (err, res) =>
      @realname = res.name
      @email = res.email
      @githubUrl = res.html_url
      done()

  projectfiles: ->
    @template 'src/_task.coffee', "src/#{@taskName}.coffee"
    @template 'test/_mocha.opts', 'test/mocha.opts'
    @template 'test/_test_helper.coffee', 'test/test_helper.coffee'
    @template 'test/_task-spec.coffee', "test/#{@taskName}-spec.coffee"
    @template 'test/_mocha.opts', 'test/mocha.opts'
    @template '_index.js', 'index.js'
    @template '_package.json', 'package.json'
    @template '_travis.yml', '.travis.yml'
    @template 'README.md'
    @template 'LICENSE'

  gitfiles: ->
    @copy '_gitignore', '.gitignore'

  app: ->

  templates: ->

  tests: ->

module.exports = MeshbluCoreTaskGenerator
