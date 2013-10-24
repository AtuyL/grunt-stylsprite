fs = require 'fs'
path = require 'path'
async = require 'async'
boxpack = require 'boxpack'
imagemagick = require "imagemagick"
lib = require '../lib'

module.exports = (grunt)->

  $generate = (dest,images,options,callback)->
    jsonData = do lib.readJSON

    images = images.filter (filepath,index,array)->
      for spriteId,spriteData of jsonData when spriteData.filepath is filepath then return false
      return true
    if not images.length then return do callback

    id = dest.replace lib.REG.image,''

    if lib.REG.image.test dest
      checksum = null
      shortsum = null
      destdir = path.dirname dest
      extname = lib.REG.image.exec(dest)[1]
      destfile = dest
    else
      checksum = lib.hash dest
      shortsum = checksum[0...5]
      destdir = dest
      extname = 'png'
      destfile = "#{dest}-#{shortsum}.#{extname}"

    tasks = for filepath,index in images then do (filepath,index)->
      (next)->
        imagemagick.identify filepath,(error,image)->
          unless error
            images[index] =
              id:path.relative destdir,filepath
              filepath:filepath
              width:image.width + options.padding
              height:image.height + options.padding
          next error

    items = {}
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
        items[image.id] = image
        width = Math.max width,rect.x + rect.width
        height = Math.max height,rect.y + rect.height
        stack.push image.filepath,"-geometry","+#{rect.x}+#{rect.y}","-composite"
      width -= options.padding
      height -= options.padding
      stack.unshift "-size","#{width}x#{height}","xc:none"
      stack.push destfile

      imagemagick.convert stack,options.timeout,(error)->
        unless error
          jsonData[id] =
            id:id
            extname:extname
            filepath:destfile
            checksum:checksum
            shortsum:shortsum
            width:width
            height:height
            items:items
          lib.writeJSON jsonData
        callback error

  grunt.registerMultiTask 'stylsprite',"wait a minute.",->
    done = do @async
    options = @options
      padding:2
      timeout:10000
    hasDestDir = @data.files and @data.files[0].dest

    tasks = []
    for task in @files then do (task)->
      dest = null
      if not hasDestDir and lib.REG.image.test task.dest
        dest = task.dest
        images = []
        for src in task.src
          if do fs.statSync(src).isDirectory
            for file in fs.readdirSync src when lib.REG.image.test file
              images.push path.join src,file
          else if lib.REG.image.test src and not ~images.indexOf src
            images.push src
        if images.length
          tasks.push do (dest,images)-> (next)-> $generate dest,images,options,next
      else if hasDestDir
        dest = task.dest
        images = []
        for src in task.src when do fs.statSync(src).isDirectory
          images.push path.join src,file for file in fs.readdirSync src when lib.REG.image.test file
        if images.length
          tasks.push do (dest,images)-> (next)-> $generate dest,images,options,next
      else
        for src in task.src when do fs.statSync(src).isDirectory
          dest = src
          images = (path.join src,file for file in fs.readdirSync src when lib.REG.image.test file)
          if images.length
            tasks.push do (dest,images)-> (next)-> $generate dest,images,options,next
    async.parallel tasks,done