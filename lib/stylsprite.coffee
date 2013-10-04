fs = require 'fs'
path = require 'path'
stylus = require 'stylus'
plugin = (css,img,sprite)->
	stylsprite = (params)->
		# console.log '================================'
		# console.log 'do sprite--------\n',css,img,sprite

		urlArgs = params.args.nodes[0]
		if urlArgs.nodes.length
			urlChain = []
			for value in urlArgs.nodes
				urlChain.push value.string
			url = urlChain.join ''
		else
			url = urlArgs.nodes[0]
		
		dirName = path.dirname url
		spriteName = path.basename dirName
		spriteTokenName = path.basename url,'.png'
		jsonPath = path.join sprite,spriteName + '.json'
		imagePath = dirName + '.png'
		# console.log 'resolved--------\n',jsonPath,imagePath
		# console.log 'tokens  --------\n',spriteName,spriteTokenName
		jsonStr = fs.readFileSync jsonPath
		json = JSON.parse jsonStr.toString()
		for token in json.images when token.name is spriteTokenName
			backgroundPosition = new stylus.nodes.Property ['background-position'],"#{-token.positionX}px #{-token.positionY}px"
			width = new stylus.nodes.Property ["width"],"#{token.width}px"
			height = new stylus.nodes.Property ["height"],"#{token.height}px"
			@closestBlock.nodes.splice @closestBlock.index + 1,0,backgroundPosition,width,height
			break
		return new stylus.nodes.Property ['background-image'],"url(#{imagePath})"
	return -> (context)->
		context.define 'sprite',stylsprite

exports = module.exports = plugin
exports.path = __dirname