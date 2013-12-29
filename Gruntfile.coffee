module.exports = (grunt)->
	grunt.loadNpmTasks key for key,value of grunt.file.readJSON('package.json').devDependencies when /^grunt-/.test key
	grunt.loadTasks 'tasks'

	stylsprite = require('./')
	stylspriteOptions =
		rootPath:'test/src'
		pixelRatio:2
	
	grunt.initConfig
		clean:['test/dest']
		stylsprite:
			allinone:
				options:
					cwd:'test/src/images'
					dest:'test/dest/img'
				files:[
					'test/dest/img/t.png':'test/src/images/t/**'
				]
			multiple:
				options:
					cwd:'test/src/images'
					dest:'test/dest/img'
				files:[
					expand:true
					cwd:'test/src/images/b'
					src:['**']
					dest:'test/dest/img/b'
				]
		stylus:
			options:
				compress:false
				paths:['test/src/external']
				use:[stylsprite('test/dest','test/dest')]
			test:files:'test/dest/index.css':'test/src/pages/index.styl'
		jade:
			options:
				pretty:true
			test:files:[
				expand:true
				cwd:'test/src/pages'
				src:'**/*.jade'
				dest:'test/dest'
				ext:'.html'
			]
		connect:
			options:
				base:'test/dest'
				open:true
			server:{}
		watch:
			jade:
				files:['test/src/**/*.jade']
				tasks:['jade']
			stylsprite:
				files:['test/src/images/**/*']
				tasks:['stylsprite','stylus']
			stylus:
				files:['test/src/**/*.styl']
				tasks:['stylus']

	grunt.registerTask 'default',['clean','stylsprite','stylus','jade','connect','watch']
	
	grunt.registerTask 'test',=>
		console.log @file.expandMapping 'test/src/images/r/**'