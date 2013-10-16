os = require 'os'
fs = require 'fs'
path = require 'path'
async = require 'async'
boxpack = require 'boxpack'
crypto = require 'crypto'
imagemagick = require "imagemagick"
sumpath = require '../lib/sumpath'
module.exports = (grunt)->
  generate = (src,options,callback)->
    src = path.resolve src
    md5sum = crypto.createHash 'md5'
    md5sum.update src,'utf8'
    checksum = md5sum.digest('hex')
    shortsum = checksum[0...5]

    jsondata =
      name:path.basename src
      checksum:checksum
      shortsum:shortsum
      width:0
      height:0
      images:null

    destpath = src.replace /\/?$/,"-#{shortsum}.png"
    images = fs.readdirSync src
    images = images.filter (value,index,array)-> /\.(png|gif|jpe?g)$/i.test value
    images = images.map (value,index,array)-> path.join src,value

    tasks = for filepath,index in images then do (filepath,index)->
      (next)->
        imagemagick.identify filepath,(error,image)->
          unless error
            images[index] =
              name:path.basename filepath.replace /\.[^\.]+$/,''
              filepath:filepath
              width:image.width + options.padding
              height:image.height + options.padding
          next error
    async.parallel tasks,->
      width = 0
      height = 0
      stack = []
      boxpack().pack(images).forEach (rect,index,array)->
        image = images[index]
        image.x = rect.x
        image.y = rect.y
        image.width = rect.width - options.padding
        image.height = rect.height - options.padding
        width = Math.max width,rect.x + rect.width
        height = Math.max height,rect.y + rect.height
        stack.push image.filepath,"-geometry","+#{rect.x}+#{rect.y}","-composite"
      width -= options.padding
      height -= options.padding
      stack.unshift "-size","#{width}x#{height}","xc:none"
      stack.push destpath
      imagemagick.convert stack,options.timeout,(error)->
        jsondata.width = width
        jsondata.height = height
        jsondata.images = images
        jsonpath = path.join os.tmpdir(),sumpath.json(src)
        fs.writeFileSync jsonpath,JSON.stringify(jsondata)
        callback error

  grunt.registerMultiTask 'stylsprite',"wait a minute.",->
    done = do @async
    options = @options
      padding:2
      timeout:10000
    tasks = for src in @filesSrc then do (src)->
      (next)->
        if not fs.existsSync src then return next false
        else if not fs.statSync(src).isDirectory() then return next false
        return generate src,options,next
    async.parallel tasks,done