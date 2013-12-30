fs = require 'fs'
path = require 'path'
async = require 'async'
mkdirp = require 'mkdirp'
boxpack = require 'boxpack'
imagemagick = require "imagemagick"
lib = require '../lib'

module.exports = (grunt)->
  collect = (src,options,callback)->
    if options.debug then console.log '----','collect'

    images = []
    tasks = []
    for dir,index in src then do (dir,index)->
      files = (path.join dir,file for file in fs.readdirSync dir when lib.REG.image.test file)
      unless files.length then return
      for file,i in files then tasks.push do (file,i)->
        (next)->
          imagemagick.identify file,(error,image)->
            unless error
              images.push data =
                src:file
                width:image.width + options.padding
                height:image.height + options.padding
            next error
    unless tasks.length
      callback null,'dir is empty'
    else async.parallel tasks,(error)->
      callback images,error

  packing = (dest,images,options,callback)->
    if options.debug then console.log '----','packing'

    allinone = lib.REG.image.test dest
    destfile = if allinone then dest else dest + '.png'
    destpath = path.relative options.dest,destfile
    destdir = path.dirname destfile

    width = 0
    height = 0
    items = {}
    stack = []
    boxpack().pack(images).forEach (rect,index,array)->
      image = images[index]
      shortPath = path.relative options.cwd,image.src
      id = path.join options.dest,shortPath
      items[id] =
        x: rect.x
        y: rect.y
        width: rect.width - options.padding
        height: rect.height - options.padding
      width = Math.max width,rect.x + rect.width
      height = Math.max height,rect.y + rect.height
      stack.push image.src,"-geometry","+#{rect.x}+#{rect.y}","-composite"
    width -= options.padding
    height -= options.padding
    for key,value of items
      items[key].dest =
        file:destfile
        width:width
        height:height
    stack.unshift "-size","#{width}x#{height}","xc:none"
    stack.push destfile

    unless fs.existsSync(destdir = path.dirname destfile) then mkdirp.sync destdir

    imagemagick.convert stack,options.timeout,(error)->
      unless error
        json = lib.readJSON(null) or {}
        for key,value of items
          json[key] = value
          if options.debug then console.log key,'\t',value.dest.file
        lib.writeJSON null,json
        if options.debug then console.log '----','done'
      callback error

  generate = (src,dest,options,callback)->
    if options.debug then console.log '----------------',src,'->',dest
    # src: ['src/images/blog']
    # dest: 'www/images/blog.png'
    collect src,options,(images,error)->
      unless error
        packing dest,images,options,(error)->
          unless error
            do callback
          else
            console.log error
            do callback
      else
        console.log error
        do callback

  grunt.registerMultiTask 'stylsprite',"Generate css sprite image for stylus.",->
    lib.writeJSON null,null

    done = do @async
    options = @options
      debug:false
      padding:2
      timeout:10000
      cwd:null
      dest:null
    options.cwd = options.cwd or ''
    options.dest = options.dest or options.rootPath or options.documentRoot or ''
    
    files = @files.map (item,index,list)->
      src:do ->
        src = item.src
        if item.cwd and not item.expand
          src = src.map (srcpath,index,list)-> path.join item.cwd,srcpath
        return src.filter (srcpath,index,list)-> do fs.statSync(srcpath).isDirectory
      output:item.dest
      cwd:item.orig.cwd or options.cwd
      dest:item.orig.dest or options.dest
    files = files.filter (item,index,list)->
      item.src.length

    tasks = files.map (item,index,list)->
      item.options =
        debug:options.debug
        padding:options.padding
        timeout:options.timeout
        cwd:options.cwd or item.cwd
        dest:options.dest or item.dest
      (next)->
        generate item.src,item.output,item.options,next
    async.series tasks,done