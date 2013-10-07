crypto = require 'crypto'
module.exports.json = (jsonPath)->
  md5sum = crypto.createHash 'md5'
  md5sum.update jsonPath,'utf8'
  sum = md5sum.digest 'hex'
  return "#{sum}.json"