fs = require 'fs'
path = require 'path'
stylus = require 'stylus'
plugin = (options)->
	options ?= {}
	cssPath = options.cssPath or ''
	imgPath = options.imgPath or ''
	spritePath = options.spritePath or ''
	pixelRatio = options.pixelRatio or 1
	stylsprite = (params)->
		# console.log '================================'
		# console.log 'do spritePath--------\n',cssPath,imgPath,spritePath

		urlArgs = params.args.nodes[0]
		if urlArgs.nodes.length
			urlChain = []
			for value in urlArgs.nodes
				urlChain.push value.string
			url = urlChain.join ''
		else
			url = urlArgs.nodes[0]

		extName = path.extname url
		dirName = path.dirname url
		spriteName = path.basename dirName
		spriteTokenName = path.basename url,extName
		jsonPath = path.join spritePath,spriteName + '.json'
		imagePath = dirName + extName
		# console.log 'resolved--------\n',jsonPath,imagePath
		# console.log 'tokens  --------\n',spriteName,spriteTokenName
		jsonStr = fs.readFileSync jsonPath
		json = JSON.parse jsonStr.toString()
		
		spriteWidth = 0
		spriteHeight = 0
		for token in json.images
			spriteWidth = Math.max spriteWidth,token.positionX + token.width
			spriteHeight = Math.max spriteHeight,token.positionY + token.height

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
			width = new stylus.nodes.Property ["width"],"#{width}px"
			height = new stylus.nodes.Property ["height"],"#{height}px"
			if backgroundSize
				this.closestBlock.nodes.splice this.closestBlock.index + 1,0,backgroundPosition,backgroundSize,width,height
			else
				this.closestBlock.nodes.splice this.closestBlock.index + 1,0,backgroundPosition,width,height
			break
		return new stylus.nodes.Property ['background-image'],"url(#{imagePath})"
	return -> (context)->
		context.define 'stylsprite',stylsprite

exports = module.exports = plugin
exports.path = __dirname