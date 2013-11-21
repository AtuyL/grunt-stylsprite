Usage
========

File placements (Example)
--------

<pre>
path/to
    |- img
    |    |- icons
    |    |    |- twitter.png
    |    |    |- facebook.png
    |    |    `- gplus.png
    |    `- images
    |        |- twitter.png
    |        |- facebook.png
    |        `- gplus.png
    |
    `- css/example.styl
</pre>

Setting
--------

```coffee
grunt.loadNpmTasks 'grunt-stylsprite'
stylspritePlugin = require 'grunt-stylsprite'
```

Stylsprite-Task Options
--------

```coffee
stylsprite:
    options:
        rootPath:"Document/Root/Dir"
        padding:2
```

### rootPath:{string}

Path to the document root directory.

### padding:{int} [option]

Interval of the image and image.  
default value is 2.

Stylsprite-Plugin Arguments
--------

```coffee
stylus:
    use:[stylspritePlugin("Target/CSS/Dir"[,options])]
```

### First argument

Path to the css directory.

### options.pixelRatio:{int} [option]

default pixelRatio.  
default value is 1.
if you want set to retina, set value of 2.

Grunt task - Multiple Mode
--------

```coffee
stylsprite:
    options:
        rootPath:'path/to'
    simple:'path/to/img/**/*'
stylus:
    options:
        use:[stylspritePlugin('path/to/css')]
    index:
        files:['path/to/css/example.css':'path/to/css/example.styl']
```

### Yield

Generate **path/to/img/icons-xxxx.png** and **path/to/img/images-xxxx.png**

### Usage in path/to/css/example.styl

```coffee
.twitter
    stylsprite url('../img/icons/twitter.png')
```

and Retina support

```coffee
.twitter
    stylsprite url('../img/icons/twitter.png'),2
```

Grunt task - All In One Mode
--------

```coffee
stylsprite:
    options:
        rootPath:'path/to'
    allinone:
        files:['path/to/img/allinone.png':'path/to/img/**/*']
stylus:
    options:
        use:[stylspritePlugin('path/to/css')]
    index:
        files:['path/to/css/example.css':'path/to/css/example.styl']
```

### Yield

Generate **path/to/img/allinone.png**

### Usage in path/to/css/example.styl

```coffee
.twitter
    stylsprite url('../img/allinone/icons/twitter.png')
```

and Retina support

```coffee
.twitter
    stylsprite url('../img/allinone/icons/twitter.png'),2
```