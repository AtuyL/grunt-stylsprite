module.exports = (grunt)->
  fs = require 'fs'
  path = require 'path'
  nodeSprite = require 'node-sprite'
  async = grunt.util.async

  grunt.registerMultiTask 'stylsprite',"wait a minute.",->
    done = do @async
    options = @options()
    for task in @files
      destDir = task.dest
      async.forEach task.src,
        (srcPath,next)->
          if not fs.statSync(srcPath).isDirectory() then return next true
          console.log 'process:',srcPath
          nodeSprite.sprites path:srcPath,(err,result)->
            if err then return next true
            for key,{name:name} of result
              jsonPath = path.join srcPath,"#{name}.json"
              jsonBuffer = fs.readFileSync jsonPath
              json = JSON.parse jsonBuffer
              srcPath = path.join srcPath,"#{name}-#{json.shortsum}.png"
              destPath = "#{destDir}/#{name}.png"
              fs.renameSync srcPath,destPath
            next false
        (err)-> done not err