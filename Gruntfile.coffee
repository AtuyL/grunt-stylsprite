module.exports = (grunt)->
	@loadNpmTasks 'grunt-contrib-stylus'
	@loadNpmTasks 'grunt-contrib-clean'
	@loadNpmTasks 'grunt-contrib-watch'
	@loadTasks 'tasks'
	stylsprite = require('./lib/stylsprite')
	
	@initConfig
		clean:[
			'test/src/sprites/*.+(png|json)'
			'test/dest/img/*.+(png|json)'
		]
		stylsprite:
			test:
				files:['test/dest/img':['test/src/sprites']]
		stylus:
			options:
				compress: false
				use: [stylsprite 'test/dest/css','test/dest/img','test/src/sprites']
			test:
				files: ['test/dest/css/test.css':'test/src/styl/test.styl']
		watch:
			stylsprite:
				files:['test/src/sprites/**/*']
				tasks:['stylsprite','stylus']
			stylus:
				files:['test/src/**/*.styl']
				tasks:['stylus']
	# @loadTasks 'tasks'

	@registerTask 'default',['clean','stylsprite','stylus','watch']