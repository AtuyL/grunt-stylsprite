fs = require 'fs'
path = require 'path'
crypto = require 'crypto'
os = require 'os'

module.exports =
  hash:(value)->
    md5sum = crypto.createHash 'md5'
    md5sum.update value,'utf8'
    md5sum.digest 'hex'
  getJSONPath:(key=null)->
    key = key or do process.cwd
    dir = do os.tmpdir
    jsonFile = this.hash(key) + '.json'
    jsonPath = path.join dir,jsonFile
  readJSON:(key=null)->
    jsonPath = this.getJSONPath key
    if fs.existsSync jsonPath then JSON.parse fs.readFileSync jsonPath else {}
  writeJSON:(key=null,data=null)->
    jsonPath = this.getJSONPath key
    if not data and fs.existsSync jsonPath
      fs.unlinkSync jsonPath
    else
      fs.writeFileSync jsonPath,JSON.stringify(data)
  normalizePath:(value)->
    path.normalize value.replace /\/*$/i,''
  REG:
    image:/\.(png|gif|jpe?g)$/i