fs = require 'fs'
path = require 'path'
crypto = require 'crypto'
os = require 'os'

module.exports =
  hash:(value)->
    md5sum = crypto.createHash 'md5'
    md5sum.update value,'utf8'
    md5sum.digest 'hex'
  getJSONPath:->
    cwd = do process.cwd
    dir = do os.tmpdir
    jsonFile = this.hash(cwd) + '.json'
    jsonPath = path.join dir,jsonFile
  readJSON:->
    jsonPath = do this.getJSONPath
    if fs.existsSync jsonPath then JSON.parse fs.readFileSync jsonPath else {}
  writeJSON:(jsonData)->
    jsonPath = do this.getJSONPath
    fs.writeFileSync jsonPath,JSON.stringify(jsonData)
  normalizePath:(value)->
    path.normalize value.replace /\/*$/i,''
  REG:
    image:/\.(png|gif|jpe?g)$/i