fs = require 'fs'
path = require 'path'
async = require 'async'
mapper = require 'node-sprite/lib/mapper'
StylSprite = require '../lib/stylsprite'
module.exports = (grunt)->
  generate = (src,options,callback)->
    map = new mapper.VerticalMapper options.padding
    sprite = new StylSprite src, map, options
    sprite.load (err) ->
      sprite.write (err) ->
        callback err,sprite
    sprite

  grunt.registerMultiTask 'stylsprite',"wait a minute.",->
    done = do @async
    options = @options
      prefix:''
      padding:2
    eachSrc = (src,next)->
      if not fs.existsSync src then return next false
      else if not fs.statSync(src).isDirectory() then return next false

      if not options.prefix or path.basename(src).indexOf(options.prefix) isnt 0 then return next false
      
      return generate src,options,next
    async.forEachSeries @filesSrc,eachSrc,done