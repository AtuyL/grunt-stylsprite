nodeSprite = require 'node-sprite'
Fiber = require 'fibers'
Future = require 'fibers/future'

main = Fiber ->
	cwd = process.cwd()
	generate = ->
		future = new Future
		nodeSprite.sprites path:cwd+'/test/src/sprites',(err,result)->
			future.return result
		future.wait()
	generate = generate.future()
	return generate().wait()
main.run()
console.log Fiber.current

# console.log seq.run()