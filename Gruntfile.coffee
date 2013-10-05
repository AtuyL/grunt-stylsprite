module.exports = (grunt)->
	@loadNpmTasks 'grunt-contrib-stylus'
	@loadNpmTasks 'grunt-contrib-clean'
	@loadNpmTasks 'grunt-contrib-copy'
	@loadNpmTasks 'grunt-contrib-watch'
	@loadTasks 'tasks'
	stylsprite = require('./')
	stylspriteOptions =
		rootPath:'test/dest'
		pixelRatio:2
	
	@initConfig
		clean:[
			'test/src/img/**/*.json'
			'test/dest/img'
		]
		stylsprite:
			test:'test/src/img/**/$*'
		copy:
			test: files: [
				expand: true
				cwd: 'test/src/img'
				src: ['**/*.+(png|jpg)']
				dest: 'test/dest/img'
			]
		stylus:
			options:
				compress: false
				use: [stylsprite('test/src/css',stylspriteOptions)]
			test:
				files: ['test/dest/css/test.css':'test/src/styl/test.styl']
		watch:
			stylsprite:
				files:['test/src/img/**/*']
				tasks:['stylsprite','copy','stylus']
			stylus:
				files:['test/src/**/*.styl']
				tasks:['stylus']
	# @loadTasks 'tasks'

	@registerTask 'default',['clean','stylsprite','copy','stylus','watch']