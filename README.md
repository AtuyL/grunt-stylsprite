Usage
========

File placements
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

```
grunt.loadNpmTasks 'grunt-stylsprite'
stylspritePlugin = require 'grunt-stylsprite'
```

Stylsprite-Task Options
--------

```
stylsprite:
    options:
        rootPath:"Document/Root/Dir"
        pixelRatio:1 #<- default pixel ratio. default 1. Retina 2.
```

Stylsprite-Plugin Arguments
--------

```
stylus:
    use:[stylspritePlugin("Target/CSS/Dir")]
```

Grunt task - Multiple Mode
--------

```
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

```
.twitter
    stylsprite url('../img/icons/twitter.png')
```

and Retina support

```
.twitter
    stylsprite url('../img/icons/twitter.png'),2
```

Grunt task - All In One Mode
--------

```
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

```
.twitter
    stylsprite url('../img/allinone/icons/twitter.png')
```

and Retina support

```
.twitter
    stylsprite url('../img/allinone/icons/twitter.png'),2
```