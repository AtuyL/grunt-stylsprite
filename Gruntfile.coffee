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
			options:
				debug:true
			simple:
				options:
					cwd:'test/src/images' # it is required in "simple" mode.
					dest:'test/dest/img' # it is required in "simple" mode.
				files:[
					'test/dest/img/bl.png':'test/src/images/b/l'
					'test/dest/img/tl.png':'test/src/images/t/l'
					'test/dest/img/br.png':'test/src/images/b/r'
					'test/dest/img/tr.png':'test/src/images/t/r'
				]
			allinone:
				options:
					dest:'test/dest/img' # it is required in "all-in-one" mode.
				files:[
					expand:false # it is required in "all-in-one" mode.
					cwd:'test/src/images'
					src:['**']
					dest:'test/dest/img/allinone.png'
				]
			multiple:
				files:[
					expand:true # multiple mode
					cwd:'test/src/images'
					src:['**']
					dest:'test/dest/img'
				]
		stylus:
			options:
				compress:false
				paths:['test/src/external']
				use:[stylsprite('test/dest/css','test/dest',debug:true)]
			test:files:'test/dest/css/index.css':'test/src/pages/index.styl'
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
	grunt.registerTask 'simple',['clean','stylsprite:simple','stylus','jade','connect','watch']
	grunt.registerTask 'allinone',['clean','stylsprite:allinone','stylus','jade','connect','watch']
	grunt.registerTask 'multiple',['clean','stylsprite:multiple','stylus','jade','connect','watch']
	
	grunt.registerTask 'test',=>
		console.log @file.expandMapping 'test/src/images/r/**'