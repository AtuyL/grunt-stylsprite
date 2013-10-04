// Generated by CoffeeScript 1.6.3
module.exports = function(grunt) {
  var async, fs, nodeSprite, path;
  fs = require('fs');
  path = require('path');
  nodeSprite = require('node-sprite');
  async = grunt.util.async;
  return grunt.registerMultiTask('stylsprite', "wait a minute.", function() {
    var destDir, done, options, task, _i, _len, _ref, _results;
    done = this.async();
    options = this.options();
    _ref = this.files;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      task = _ref[_i];
      destDir = task.dest;
      _results.push(async.forEach(task.src, function(srcPath, next) {
        if (!fs.statSync(srcPath).isDirectory()) {
          return next(true);
        }
        console.log('process:', srcPath);
        return nodeSprite.sprites({
          path: srcPath
        }, function(err, result) {
          var destPath, json, jsonBuffer, jsonPath, key, name;
          if (err) {
            return next(true);
          }
          for (key in result) {
            name = result[key].name;
            jsonPath = path.join(srcPath, "" + name + ".json");
            jsonBuffer = fs.readFileSync(jsonPath);
            json = JSON.parse(jsonBuffer);
            srcPath = path.join(srcPath, "" + name + "-" + json.shortsum + ".png");
            destPath = "" + destDir + "/" + name + ".png";
            fs.renameSync(srcPath, destPath);
          }
          return next(false);
        });
      }, function(err) {
        return done(!err);
      }));
    }
    return _results;
  });
};