os = require 'os'
fs = require 'fs'
path = require 'path'
async = require 'async'
boxpack = require 'boxpack'
crypto = require 'crypto'
imagemagick = require "imagemagick"

module.exports = (grunt)->
  TMPDIR = do os.tmpdir
  
  TYPE =
    ALL_IN_ONE:'ALL_IN_ONE'
    DIRECTORY:'DIRECTORY'
    GENERATE:'GENERATE'

  REG =
    image:/\.(png|gif|jpe?g)$/i

  hash = (value)->
    md5sum = crypto.createHash 'md5'
    md5sum.update value,'utf8'
    md5sum.digest('hex')

  $generate = (type,dest,images,options,callback)->
    id = dest.replace REG.image,''
    items = {}

    if REG.image.test dest
      checksum = hash dest.replace REG.image,''
      shortsum = checksum[0...5]
      destdir = path.dirname dest
      destfile = dest
    else
      checksum = hash dest
      shortsum = checksum[0...5]
      destdir = dest
      destfile = "#{dest}-#{shortsum}.png"

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
          jsonFile = hash(do process.cwd) + '.json'
          jsonPath = path.join TMPDIR,jsonFile
          jsonData = if fs.existsSync jsonPath then JSON.parse fs.readFileSync jsonPath else {}
          jsonData[id] =
            id:id
            filepath:destfile
            checksum:checksum
            shortsum:shortsum
            width:width
            height:height
            items:items
          fs.writeFileSync jsonPath,JSON.stringify(jsonData)
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
      if not hasDestDir and REG.image.test task.dest
        dest = task.dest
        images = []
        for src in task.src
          if do fs.statSync(src).isDirectory
            for file in fs.readdirSync src when REG.image.test file
              images.push path.join src,file
          else if REG.image.test src and not ~images.indexOf src
            images.push src
        if images.length
          tasks.push do (dest,images)-> (next)-> $generate TYPE.ALL_IN_ONE,dest,images,options,next
      else if hasDestDir
        dest = task.dest
        images = []
        for src in task.src when do fs.statSync(src).isDirectory
          images.push path.join src,file for file in fs.readdirSync src when REG.image.test file
        if images.length
          tasks.push do (dest,images)-> (next)-> $generate TYPE.DIRECTORY,dest,images,options,next
      else
        for src in task.src when do fs.statSync(src).isDirectory
          dest = src
          images = (path.join src,file for file in fs.readdirSync src when REG.image.test file)
          if images.length
            tasks.push do (dest,images)-> (next)-> $generate TYPE.GENERATE,dest,images,options,next
    async.parallel tasks,done