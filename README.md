Usage
========

File placements (Example)
--------

<pre>
dest
  |- css
  `- img
src
  |- img
  |    |- icons
  |    |    |- twitter.png
  |    |    |- facebook.png
  |    |    `- gplus.png
  |    `- header
  |        |- title.png
  |        |- logo.png
  |        `- description.png
  |
  `- css
      `- example.styl
</pre>

Settings
--------

### Example (coffee-style)

<pre>
grunt.loadNpmTasks 'grunt-stylsprite'
stylspritePlugin = require 'grunt-stylsprite'
</pre>

Stylsprite-Task Options
--------

### Example (coffee-style)
<pre>
stylsprite:
    options:
        cwd:'src/img'
        dest:'dest/img'
        padding:2
</pre>

### Options

#### cwd
Type: `string`

Path to the root of image-sources.

#### dest
Type: `string`

Path to the root of images-destination.

#### padding (option)
Type: `int`  
Default: `2`

Interval of the image and image.  

Stylsprite-Plugin Arguments
--------

<pre>
stylus:
    options:
        use:[stylspritePlugin("dest/css","dest"[,options])]
    index:
        files:
            'dest/css/example.css':'src/css/example.styl'
</pre>

### First argument
Type: `string`

Path to the css directory.

### Second argument
Type: `string`

Path to the document root directory.

### options.pixelRatio (option)
Type: `int`

default pixelRatio.  
default value is 1.
if you want set to retina, set value of 2.

Grunt task - Multiple Mode
--------

<pre>
stylsprite:
    options:
        cwd:'src/img'
        dest:'dest/img'
    multiple:
        files:[
            expand:true
            cwd:'src/img'
            src:['**']
            dest:'dest/img'
        ]
</pre>

### Yield

Generate `dest/img/icons.png` and `dest/img/header.png`

### Usage in src/css/example.styl

<pre>
.twitter
    stylsprite('../img/icons/twitter.png')
</pre>

or

<pre>
.twitter
    stylsprite url('../img/icons/twitter.png')
</pre>

and Retina support

<pre>
.twitter
    stylsprite('../img/icons/twitter.png',2)
</pre>

Grunt task - All In One Mode
--------

<pre>
stylsprite:
    options:
        cwd:'src/img'
        dest:'dest/img'
    allinone:
        files:[
          'dest/img/allinone.png':'src/img/**'
        ]
stylus:
    options:
        use:[stylspritePlugin("dest/css","dest")]
    index:
        files:[
            'dest/css/example.css':'src/css/example.styl'
        ]
</pre>

### Yield

Generate `dest/img/allinone.png`

### Usage in src/css/example.styl

<pre>
.twitter
    stylsprite('../img/icons/twitter.png')
</pre>

or

<pre>
.twitter
    stylsprite url('../img/icons/twitter.png')
</pre>

and Retina support

<pre>
.twitter
    stylsprite('../img/icons/twitter.png',2)
</pre>

# For more information, please see below.
`node_modules/grunt-stylsprite/gruntfile.coffee`