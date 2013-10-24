module.exports = (grunt)->
	@loadNpmTasks 'grunt-contrib-stylus'
	@loadNpmTasks 'grunt-contrib-clean'
	@loadNpmTasks 'grunt-contrib-copy'
	@loadNpmTasks 'grunt-contrib-watch'
	@loadTasks 'tasks'
	stylsprite = require('./')
	stylspriteOptions =
		rootPath:'test/src'
		pixelRatio:2
	
	@initConfig
		clean:['test/dest/**/*.+(png,css)']
		stylsprite:
			options: stylspriteOptions
			allinone:files:['test/src/img/allinone.png':'test/src/img/**/*']
			nodest:'test/src/img/**/*'
			srcdest:files:['test/src/img/srcdest.png':'test/src/img/*']
			multisrc:
				options:test:true
				files:['test/src/img/multisrc.png':['test/src/img/icons','test/src/img/subdir/icons/*']]
			hasdestexpand:files:[
				expand: true
				cwd: 'test/src/img'
				src: ['*']
				dest: 'test/src/img'
			]
			nodestexpand:files:[
				expand: true
				cwd: 'test/src/img'
				src: ['*']
			]
		copy:
			rootimg: files: [ 'test/dest/timer.png':'test/src/css/img/timer.png' ]
			rootimgdir: files: [
				expand: true
				cwd: 'test/src/img'
				src: ['**/*.+(png|jpg)']
				dest: 'test/dest/img'
			]
			brosimgdir: files: [
				expand: true
				cwd: 'test/src/img'
				src: ['**/*.+(png|jpg)']
				dest: 'test/dest/css/img'
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