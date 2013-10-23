fs = require 'fs'
path = require 'path'
crypto = require 'crypto'
tmpdir = do require('os').tmpdir

module.exports.hash = hash = (value)->
  md5sum = crypto.createHash 'md5'
  md5sum.update value,'utf8'
  md5sum.digest 'hex'

jsonFile = hash(do process.cwd) + '.json'
jsonPath = path.join tmpdir,jsonFile

module.exports.readJSON = ->
  if fs.existsSync jsonPath then JSON.parse fs.readFileSync jsonPath else {}

module.exports.writeJSON = (jsonData)->
  fs.writeFileSync jsonPath,JSON.stringify(jsonData)

module.exports.REG =
  image:/\.(png|gif|jpe?g)$/i