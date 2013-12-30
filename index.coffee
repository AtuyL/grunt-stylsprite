os = require 'os'
fs = require 'fs'
path = require 'path'
stylus = require 'stylus'
imagesize = require('imagesize').Parser
lib = require './lib'

exports = module.exports = (cssPath,rootPath,options={})->
  if typeof rootPath isnt 'string'
    options = rootPath
    rootPath = options.dest or options.rootPath or options.documentRoot or ''
  debug = options.debug

  toURLString = (url)->
    unless url.args then return url.val
    urlArgs = url.args.nodes[0]
    if urlArgs.nodes.length
      return (value.string for value in urlArgs.nodes).join ''
    return urlArgs.nodes[0]

  toAbsolutePath = (url)->
    if /^\//i.test url
      return path.join rootPath,url
    else if /^https?:\/\//i.test url
      throw new Error 'sorry. not supported yet.. : ' + url
    else
      return path.relative '.',path.join cssPath,url

  stylsprite = (url,pixelRatio)->
    jsonData = do lib.readJSON

    url = toURLString url
    isRelative = not /^(\/|https?:\/\/)/.test url
    targetPath = toAbsolutePath url
    
    if debug
      console.log ''
      console.log 'url:',url
      console.log '  ->',targetPath
    
    pixelRatio = parseFloat(if pixelRatio then pixelRatio.val else options.pixelRatio) or 1
    if not pixelRatio or pixelRatio <= 0 then pixelRatio = 1
    
    nodes = @closestBlock.nodes
    nodesIndex = @closestBlock.index + 1
    backgroundRepeat = new stylus.nodes.Property ['background-repeat'],"no-repeat"

    if spriteData = jsonData[targetPath]

      spriteWidth = spriteData.dest.width / pixelRatio
      spriteHeight = spriteData.dest.height / pixelRatio
      x = spriteData.x / pixelRatio
      y = spriteData.y / pixelRatio
      width = spriteData.width / pixelRatio
      height = spriteData.height / pixelRatio

      if isRelative
        url = path.relative cssPath,spriteData.dest.file
      else
        url = '/' + path.relative rootPath,spriteData.dest.file

      nodes.splice nodesIndex,0,
        new stylus.nodes.Property ["width"],"#{width}px"
        new stylus.nodes.Property ["height"],"#{height}px"
        new stylus.nodes.Property ['background-image'],"url('#{url}')"
        new stylus.nodes.Property ['background-position'],"#{-x}px #{-y}px"
        new stylus.nodes.Property ['background-size'],"#{spriteWidth}px #{spriteHeight}px"
        backgroundRepeat
      return null

    if fs.existsSync targetPath
      # get image size
      imageData = fs.readFileSync targetPath
      parser = do imagesize
      switch parser.parse imageData
        when imagesize.EOF or imagesize.INVALID
          console.log 'invalid:',targetPath
          return null
        when imagesize.DONE
          rect = do parser.getResult
          width = rect.width
          height = rect.height
        else
          console.log 'unknown error:',targetPath
          return null

      spriteWidth = width / pixelRatio
      spriteHeight = height / pixelRatio

      nodes.splice nodesIndex,0,
        new stylus.nodes.Property ["width"],"#{spriteWidth}px"
        new stylus.nodes.Property ["height"],"#{spriteHeight}px"
        new stylus.nodes.Property ['background-image'],"url('#{url}')"
        new stylus.nodes.Property ['background-size'],"#{spriteWidth}px #{spriteHeight}px"
        backgroundRepeat
      return null

    return new stylus.nodes.Property ['background-image'],"url('#{url}')"
  -> (context)-> context.define 'stylsprite',stylsprite
