assetManager = require 'connect-assetmanager'
assetHandler = require 'connect-assetmanager-handlers'

stitch = require "stitch"
express = require("express")

package = stitch.createPackage
  paths: [__dirname + '/src/vendor', __dirname + '/src/client']

root = __dirname + '/public'

assetManagerGroups =
  js:
    route: /\/static\/js\/[0-9]+\/.*\.js/
    path: "./public/javascripts/"
    dataType: "javascript"
    files: [ 
      "jquery.reveal.js"
      "jquery.orbit-1.3.0.js"
      "forms.jquery.js"
      "jquery.customforms.js"
      "jquery.placeholder.min.js"
      "prettify.js"
    ]

  css:
    route: /\/static\/css\/[0-9]+\/.*\.css/
    path: "./public/stylesheets/"
    dataType: "css"
    files: [ 
      "globals.css"
      "typography.css"
      "grid.css"
      "ui.css"
      "forms.css"
      "orbit.css"
      "reveal.css"
      "app.css"
      "mobile.css"
    ]
    preManipulate:
      MSIE: [ assetHandler.yuiCssOptimize, assetHandler.fixVendorPrefixes, assetHandler.fixGradients, assetHandler.stripDataUrlsPrefix ]
      "^": [ assetHandler.yuiCssOptimize, assetHandler.fixVendorPrefixes, assetHandler.fixGradients, assetHandler.replaceImageRefToBase64(root) ]

# Server
app = module.exports = express.createServer()
app.configure ->
  app.set "views", __dirname + "/views"
  app.set "view engine", "jade"
  app.use express.bodyParser()
  app.use express.methodOverride()
  # app.use express.conditionalGet()
  # app.use express.cache()
  # app.use express.gzip()
  app.use assetManager(assetManagerGroups)
  app.use express.static(__dirname + "/public")
  app.use app.router

app.configure "development", ->
  app.use express.errorHandler(
    dumpExceptions: true
    showStack: true
  )

app.configure "production", ->
  app.use express.errorHandler()

app.get "/application.js", package.createServer()
#app.get "/application.css", css.createServer()
#app.get "/foundation.js", foundation.createServer()

app.get "/", (req, res) ->
  res.render "welcome",
    title: "welcome - Wilbur.io"

app.get "/posts/:page", (req, res) ->
  res.render "posts/#{req.params.page}",
    title: "#{req.params.page} - Wilbur.io"

app.get "/:page", (req, res) ->
  res.render req.params.page,
    title: "#{req.params.page} - Wilbur.io"


app.listen process.env.VMC_APP_PORT or process.env.C9_PORT or 3000
console.log "Express server listening on port %d in %s mode", app.address().port, app.settings.env