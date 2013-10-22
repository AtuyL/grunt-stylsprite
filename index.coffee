os = require 'os'
fs = require 'fs'
path = require 'path'
stylus = require 'stylus'
crypto = require 'crypto'
imagesize = require('imagesize').Parser

plugin = (cssPath,options={})->
  TMPDIR = do os.tmpdir

  hash = (value)->
    md5sum = crypto.createHash 'md5'
    md5sum.update value,'utf8'
    md5sum.digest('hex')

  rootPath = options.rootPath or ''

  parseUrl = (params)->
    if params.args
      urlArgs = params.args.nodes[0]
      if urlArgs.nodes.length
        url = (value.string for value in urlArgs.nodes).join ''
      else
        url = urlArgs.nodes[0]
    else
      url = params.val

  parsePath = (url)->
    if /^\//i.test url
      path.join path.relative(cssPath,rootPath),url
    else if not /^https?:\/\//i.test url
      url
    else
      throw new Error 'sorry. unsupport yet.. : ' + url

  stylsprite = (url,pixelRatio)->
    jsonFile = hash(do process.cwd) + '.json'
    jsonPath = path.join TMPDIR,jsonFile
    jsonData = if fs.existsSync jsonPath then JSON.parse fs.readFileSync jsonPath else null

    url = parseUrl url
    imagePath = parsePath url
    pixelRatio = parseFloat(pixelRatio?.val or options.pixelRatio) or 1
    
    targetPath = path.join cssPath,imagePath

    nodesIndex = this.closestBlock.index + 1
    backgroundRepeat = new stylus.nodes.Property ['background-repeat'],"no-repeat"

    for spriteId,spriteData of jsonData when targetPath.indexOf(spriteId) is 0
      itemId = targetPath.replace(spriteId + '/','')
      itemData = spriteData.items[itemId]
      spriteWidth = spriteData.width / pixelRatio
      spriteHeight = spriteData.height / pixelRatio
      if itemData
        x = itemData.x / pixelRatio
        y = itemData.y / pixelRatio
        width = itemData.width / pixelRatio
        height = itemData.height / pixelRatio
        url = imagePath.replace '/' + itemData.id,".#{spriteData.extname}"
        width = new stylus.nodes.Property ["width"],"#{width}px"
        height = new stylus.nodes.Property ["height"],"#{height}px"
        backgroundImage = new stylus.nodes.Property ['background-image'],"url(#{url})"
        backgroundPosition = new stylus.nodes.Property ['background-position'],"#{-x}px #{-y}px"
        backgroundSize = new stylus.nodes.Property ['background-size'],"#{spriteWidth}px #{spriteHeight}px"
        this.closestBlock.nodes.splice nodesIndex,0,width,height,backgroundImage,backgroundPosition,backgroundSize
        return null

    if fs.existsSync targetPath
      imageData = fs.readFileSync targetPath
      parser = do imagesize
      switch parser.parse imageData
        when imagesize.EOF or imagesize.INVALID 
          console.log 'invalid:',localPath
          return null
        when imagesize.DONE then {width:width,height:height} = do parser.getResult
      spriteWidth = width / pixelRatio
      spriteHeight = height / pixelRatio
      width = new stylus.nodes.Property ["width"],"#{spriteWidth}px"
      height = new stylus.nodes.Property ["height"],"#{spriteHeight}px"
      backgroundImage = new stylus.nodes.Property ['background-image'],"url(#{url})"
      backgroundSize = new stylus.nodes.Property ['background-size'],"#{spriteWidth}px #{spriteHeight}px"
      this.closestBlock.nodes.splice nodesIndex,0,width,height,backgroundImage,backgroundSize
      return null
    
    return new stylus.nodes.Property ['background-image'],"url(#{url})"
  -> (context)-> context.define 'stylsprite',stylsprite

exports = module.exports = plugin
exports.path = __dirname