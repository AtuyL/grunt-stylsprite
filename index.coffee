os = require 'os'
fs = require 'fs'
path = require 'path'
stylus = require 'stylus'
imagesize = require('imagesize').Parser
lib = require './lib'

exports = module.exports = (cssPath,options={})->
  rootPath = options.rootPath or ''

  toURLString = (url)->
    if url.args
      urlArgs = url.args.nodes[0]
      if urlArgs.nodes.length
        return (value.string for value in urlArgs.nodes).join ''
      else
        return urlArgs.nodes[0]
    return url.val

  toRelativePath = (url)->
    if /^\//i.test url
      return path.join path.relative(cssPath,rootPath),url
    else if not /^https?:\/\//i.test url
      return url
    else
      throw new Error 'sorry. unsupport yet.. : ' + url

  stylsprite = (url,pixelRatio)->
    jsonData = do lib.readJSON

    url = toURLString url
    relativePath = toRelativePath url
    
    pixelRatio = parseFloat(if pixelRatio then pixelRatio.val else options.pixelRatio) or 1
    if not pixelRatio or pixelRatio <= 0 then pixelRatio = 1
    
    targetPath = path.join cssPath,relativePath

    nodes = @closestBlock.nodes
    nodesIndex = @closestBlock.index + 1
    backgroundRepeat = new stylus.nodes.Property ['background-repeat'],"no-repeat"

    for spriteId,spriteData of jsonData when targetPath.indexOf(spriteId) is 0
      itemId = targetPath.replace(spriteId + '/','')
      itemData = spriteData.items[itemId]
      unless itemData then continue

      spriteWidth = spriteData.width / pixelRatio
      spriteHeight = spriteData.height / pixelRatio
      x = itemData.x / pixelRatio
      y = itemData.y / pixelRatio
      width = itemData.width / pixelRatio
      height = itemData.height / pixelRatio

      if spriteData.shortsum
        url = url.replace '/' + itemData.id,"-#{spriteData.shortsum}.#{spriteData.extname}"
      else
        url = url.replace '/' + itemData.id,".#{spriteData.extname}"

      nodes.splice nodesIndex,0,
        new stylus.nodes.Property ["width"],"#{width}px"
        new stylus.nodes.Property ["height"],"#{height}px"
        new stylus.nodes.Property ['background-image'],"url(\"#{url}\")"
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
        new stylus.nodes.Property ['background-image'],"url(#{url})"
        new stylus.nodes.Property ['background-size'],"#{spriteWidth}px #{spriteHeight}px"
        backgroundRepeat
      return null
    
    return new stylus.nodes.Property ['background-image'],"url(#{url})"
  -> (context)-> context.define 'stylsprite',stylsprite
