os = require 'os'
fs = require 'fs'
path = require 'path'
stylus = require 'stylus'
imagesize = require('imagesize').Parser
sumpath = require './lib/sumpath'

plugin = (cssPath,options)->
  # console.log options
  options ?= {}
  rootPath = options.rootPath or ''
  pixelRatio = options.pixelRatio or 1
  prefix = options.prefix or ''

  getImagePath = (params)->
    if params.args
      urlArgs = params.args.nodes[0]
      if urlArgs.nodes.length
        urlChain = []
        for value in urlArgs.nodes
          urlChain.push value.string
        return urlChain.join ''
      else
        return urlArgs.nodes[0]
    else
      return params.val

  convertToLocalPath = (url)->
    if /^\//i.test url
      path.resolve path.join rootPath,url
    else if not /^https?:\/\//i.test url
      path.resolve cssPath,url
    else
      throw new Error 'sorry. unsupport yet.. : ' + url

  stylsprite = (params)->
    imagePath = getImagePath params # hoge/$fuga/foo.png
    localPath = convertToLocalPath imagePath # /User/Piyo/Project/hoge/$fuga/foo.png
    
    extName = path.extname localPath # .png
    dirName = path.dirname localPath # /User/Piyo/Project/hoge/$fuga
    
    jsonPath = path.join os.tmpdir(),sumpath.json(path.resolve dirName)
    
    backgroundImage = null
    backgroundPosition = null
    backgroundSize = null
    backgroundRepeat = null
    width = null
    height = null
    if fs.existsSync jsonPath
      
      jsonStr = fs.readFileSync jsonPath
      json = JSON.parse jsonStr.toString()

      url = "#{path.dirname path.dirname imagePath}/#{json.name}-#{json.shortsum}.png"

      spriteWidth = json.width
      spriteHeight = json.height

      spriteTokenName = path.basename localPath,extName # foo
      for token in json.images when token.name is spriteTokenName
        positionX = token.positionX
        positionY = token.positionY
        width = token.width
        height = token.height
        if pixelRatio isnt 1
          width /= pixelRatio
          height /= pixelRatio
          positionX /= pixelRatio
          positionY /= pixelRatio
          spriteWidth /= pixelRatio
          spriteHeight /= pixelRatio
          backgroundSize = new stylus.nodes.Property ['background-size'],"#{spriteWidth}px #{spriteHeight}px"
        backgroundPosition = new stylus.nodes.Property ['background-position'],"#{-positionX}px #{-positionY}px"
        backgroundImage = new stylus.nodes.Property ['background-image'],"url(#{url})"
    else if fs.existsSync localPath
      imageData = fs.readFileSync localPath
      parser = do imagesize
      switch parser.parse imageData
        when imagesize.EOF or imagesize.INVALID 
          console.log 'invalid:',localPath
          return null
        when imagesize.DONE then {width:width,height:height} = do parser.getResult
      if pixelRatio isnt 1
        width /= pixelRatio
        height /= pixelRatio
        backgroundSize = new stylus.nodes.Property ['background-size'],"#{width}px #{height}px"
      backgroundImage = new stylus.nodes.Property ['background-image'],"url(#{imagePath})"
    else
      return new stylus.nodes.Property ['background-image'],"url(#{imagePath})"
      
    backgroundRepeat = new stylus.nodes.Property ['background-repeat'],"no-repeat"
    width = new stylus.nodes.Property ["width"],"#{width}px"
    height = new stylus.nodes.Property ["height"],"#{height}px"
    if backgroundPosition and backgroundSize
      this.closestBlock.nodes.splice this.closestBlock.index + 1,0,backgroundPosition,backgroundSize,backgroundRepeat,width,height
    else if backgroundPosition
      this.closestBlock.nodes.splice this.closestBlock.index + 1,0,backgroundPosition,backgroundRepeat,width,height
    else if backgroundSize
      this.closestBlock.nodes.splice this.closestBlock.index + 1,0,backgroundSize,width,height
    return backgroundImage
  return -> (context)->
    context.define 'stylsprite',stylsprite

exports = module.exports = plugin
exports.path = __dirname