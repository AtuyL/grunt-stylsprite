fs = require 'fs'
path = require 'path'
stylus = require 'stylus'
plugin = (cssPath,options)->
  console.log options
  options ?= {}
  rootPath = options.rootPath or ''
  imgPath = options.imgPath or ''
  spritePath = options.spritePath or ''
  pixelRatio = options.pixelRatio or 1

  getImagePath = (params)->
    urlArgs = params.args.nodes[0]
    if urlArgs.nodes.length
      urlChain = []
      for value in urlArgs.nodes
        urlChain.push value.string
      url = urlChain.join ''
    else
      url = urlArgs.nodes[0]

  convertToLocalPath = (url)->
    if /^\//i.test url
      path.resolve path.join rootPath,url
    else if not /^http:\/\//i.test url
      path.resolve cssPath,url
    else
      throw new Error 'sorry. unsupport yet.. : ' + url


  stylsprite = (params)->
    console.log '================================'
    # console.log 'do spritePath--------\n',cssPath,imgPath,spritePath

    imagePath = getImagePath params
    localPath = convertToLocalPath imagePath
    extName = path.extname localPath
    dirName = path.dirname localPath
    spriteName = path.basename dirName
    spriteTokenName = path.basename localPath,extName
    jsonPath = "#{path.dirname dirName}/$#{spriteName}/#{spriteName}.json"
    console.log jsonPath
    if fs.existsSync jsonPath
      jsonStr = fs.readFileSync jsonPath
      json = JSON.parse jsonStr.toString()
      spriteWidth = json.width
      spriteHeight = json.height
      for token in json.images when token.name is spriteTokenName
        positionX = token.positionX
        positionY = token.positionY
        width = token.width
        height = token.height
        backgroundSize = null
        if pixelRatio isnt 1
          width /= pixelRatio
          height /= pixelRatio
          positionX /= pixelRatio
          positionY /= pixelRatio
          spriteWidth /= pixelRatio
          spriteHeight /= pixelRatio
          backgroundSize = new stylus.nodes.Property ['background-size'],"#{spriteWidth}px #{spriteHeight}px"
        backgroundPosition = new stylus.nodes.Property ['background-position'],"#{-positionX}px #{-positionY}px"
        backgroundRepeat = new stylus.nodes.Property ['background-repeat'],"no-repeat"
        width = new stylus.nodes.Property ["width"],"#{width}px"
        height = new stylus.nodes.Property ["height"],"#{height}px"
        if backgroundSize
          this.closestBlock.nodes.splice this.closestBlock.index + 1,0,backgroundPosition,backgroundSize,backgroundRepeat,width,height
        else
          this.closestBlock.nodes.splice this.closestBlock.index + 1,0,backgroundPosition,width,height
        break
      return new stylus.nodes.Property ['background-image'],"url(#{imagePath})"
    return null
  return -> (context)->
    context.define 'stylsprite',stylsprite

exports = module.exports = plugin
exports.path = __dirname
