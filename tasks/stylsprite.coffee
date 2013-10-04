module.exports = (grunt)->
  fs = require 'fs'
  path = require 'path'
  nodeSprite = require 'node-sprite'
  async = grunt.util.async

  grunt.registerMultiTask 'stylsprite',"wait a minute.",->
    done = do @async
    options = @options()
    eachTask = (task,next)->
      imgDir = task.dest
      spriteDir = task.src[0]
      # console.log 'imgDir:',imgDir
      # console.log 'spriteDir:',spriteDir
      if not fs.statSync(spriteDir).isDirectory() then return next true
      nodeSprite.sprites path:spriteDir,(err,result)->
        # console.log result
        if err then return next true
        for key,spriteData of result
          jsonPath = path.join spriteDir,"#{spriteData.name}.json"
          # console.log jsonPath,spriteDir
          jsonBuffer = fs.readFileSync jsonPath
          json = JSON.parse jsonBuffer
          spritePath = path.join spriteDir,"#{spriteData.name}-#{json.shortsum}.png"
          destPath = "#{imgDir}/#{spriteData.name}.png"
          fs.renameSync spritePath,destPath
        next false
    async.forEach @files,eachTask,done