module.exports = (grunt)->
  fs = require 'fs'
  path = require 'path'
  async = grunt.util.async

  nodeSprite = require 'node-sprite'
  mapper = require 'node-sprite/lib/mapper'

  # extends from node-sprite lib
  Sprite = require 'node-sprite/lib/sprite'
  Image = require 'node-sprite/lib/image'
  class StylSprite extends Sprite
    constructor: (dir, mapper) ->
      name = path.basename(dir).replace /^\$/,''
      Sprite.call this,name,dir,mapper,false
    _getFiles: (cb) ->
      fs.readdir "#{@path}", (err, files) ->
        files = files.filter (file) -> file.match /\.(png|gif|jpg|jpeg)$/
        cb err, files
    _getImage: (filename, cb) ->
      image = new Image(filename, "#{@path}")
      image.readDimensions (err) ->
        cb null, if err then null else image
    filename: -> "#{@name}.png"
    url: -> "#{path.dirname @path}/#{@filename()}"
    write: (cb) ->
      self = this
      jsonUrl = @jsonUrl()
      url = @url()
      async.series
        checkJson:(cb)->
          fs.exists jsonUrl, (exists) =>
            if exists then fs.unlink jsonUrl,cb
            else do cb
        checkSprite:(cb)->
          fs.exists url, (exists) =>
            if exists then fs.unlink url,cb
            else do cb
        (err)->
          if not err then self._write cb
          else throw new Error err
    _toJson: ->
      info =
        name: @name
        checksum: @checksum()
        shortsum: @shortsum()
        width: @mapper.width
        height: @mapper.height
        padding: @mapper.padding
        images: []

      for image in @images
        imageInfo =
          name: image.name
          filename: image.filename
          checksum: image.checksum
          width: image.width
          height: image.height
          positionX: image.positionX
          positionY: image.positionY
        info.images.push imageInfo

      info = JSON.stringify(info, null, '  ')
      fs.writeFileSync @jsonUrl(), info
    _fromJson: ->
      # now omitting yet ..

  generate = (src,options,callback)->
    options ?= {}
    padding = options.padding || 2

    map = new mapper.VerticalMapper padding
    sprite = new StylSprite src, map
    sprite.load (err) ->
      sprite.write (err) ->
        callback err,sprite
    sprite

  grunt.registerMultiTask 'stylsprite',"wait a minute.",->
    done = do @async
    options = @options()
    eachSrc = (src,next)->
      if not fs.statSync(src).isDirectory() then return next false
      generate src,options,(err,result)->
        # console.log result
        return next err
    async.forEachSeries @filesSrc,eachSrc,done