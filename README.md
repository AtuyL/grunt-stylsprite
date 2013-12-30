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
 |    |- t
 |    |  |- l
 |    |  |  |- tl.png
 |    |  |  |- tr.png
 |    |  |  |- bl.png
 |    |  |  `- br.png
 |    |  |
 |    |  `- r
 |    |     |- tl.png
 |    |     |- tr.png
 |    |     |- bl.png
 |    |     `- br.png
 |    `- b
 |       |- l
 |       |  |- tl.png
 |       |  |- tr.png
 |       |  |- bl.png
 |       |  `- br.png
 |       |
 |       `- r
 |          |- tl.png
 |          |- tr.png
 |          |- bl.png
 |          `- br.png
 |
 `- css
     `- example.styl
</pre>

Settings
--------

### Example (coffee-style)

```coffee
grunt.loadNpmTasks 'grunt-stylsprite'
```

Stylsprite-Task Options
--------

### Example (coffee-style)

```coffee
simple:
    options:
        cwd:'src/images' # it is required in "simple" mode.
        dest:'dest/img' # it is required in "simple" mode.
    files:[
        'dest/img/bl.png':'src/images/b/l'
        'dest/img/tl.png':'src/images/t/l'
        'dest/img/br.png':'src/images/b/r'
        'dest/img/tr.png':'src/images/t/r'
    ]
```

```coffee
allinone:
    options:
        dest:'dest/img' # it is required in "all-in-one" mode.
    files:[
        expand:false # it is required in "all-in-one" mode.
        cwd:'src/images'
        src:['**']
        dest:'dest/img/allinone.png'
    ]
```

```coffee
multiple:
    files:[
        expand:true # it is required in "multiple" mode.
        cwd:'src/images'
        src:['**']
        dest:'dest/img'
    ]
```

### Options

#### cwd
Type: `string`  
Require: `simple-mode`

Path to the image-sources.

#### dest
Type: `string`  
Require: `simple-mode` and `allinone-mode`

Path to the images-destination.

#### padding (option)
Type: `int`  
Default: `2`

Interval of the image and image.

Grunt task - Simple Mode
--------

```coffee
simple:
    options:
        cwd:'test/src/images' # it is required in "simple" mode.
        dest:'test/dest/img' # it is required in "simple" mode.
    files:[
        'test/dest/img/tl.png':'test/src/images/t/l'
        'test/dest/img/tr.png':'test/src/images/t/r'
        'test/dest/img/bl.png':'test/src/images/b/l'
        'test/dest/img/br.png':'test/src/images/b/r'
    ]
```

### Yield

Generate `dest/img/tl.png` and `dest/img/tr.png` and `dest/img/bl.png` and `dest/img/br.png`

Grunt task - Multiple Mode
--------

```coffee
stylsprite:
    multiple:
        files:[
            expand:true # it is required in "multiple" mode.
            cwd:'src/images'
            src:['**']
            dest:'dest/img'
        ]
```

### Yield

Generate `dest/img/t/l.png` and `dest/img/t/r.png` and `dest/img/b/l.png` and `dest/img/b/r.png`

Grunt task - All In One Mode
--------

```coffee
allinone:
    options:
        dest:'dest/img' # it is required in "all-in-one" mode.
    files:[
        expand:false # it is required in "all-in-one" mode.
        cwd:'src/images'
        src:['**']
        dest:'dest/img/allinone.png'
    ]
```

### Yield

Generate `dest/img/allinone.png`

--------

Stylsprite-Plugin Arguments
--------

### Settings

load stylus plugin

```coffee
stylspritePlugin = require 'grunt-stylsprite'
```

and stylus-task settings.

```coffee
stylus:
    options:
        use:[stylspritePlugin("dest/css","dest"[,options])]
    index:
        files:
            'dest/css/example.css':'src/css/example.styl'
```

### First argument
Type: `string`

Path to the css directory.

### Second argument
Type: `string`

Path to the document root directory.

### options.pixelRatio (option)
Type: `int`
Default: `1`

default pixelRatio.  
if you want set to retina for all-sprites, set value of 2.

### Usage in src/css/example.styl

#### Task settings

```coffee
stylus:
    options:
        use:[stylspritePlugin("dest/css","dest")]
    index:
        files:[
            'dest/css/example.css':'src/css/example.styl'
        ]
```

#### and use stylsprite function in example.styl

<pre>
.t
  .l
    .tl
      stylsprite '../img/t/l/tl.png'
    .tr
      stylsprite '../img/t/l/tr.png'
    .bl
      stylsprite '../img/t/l/bl.png'
    .br
      stylsprite '../img/t/l/br.png'
</pre>

or

<pre>
.t
  .l
    .tl
      stylsprite url('../img/t/l/tl.png')
    .tr
      stylsprite url('../img/t/l/tr.png')
    .bl
      stylsprite url('../img/t/l/bl.png')
    .br
      stylsprite url('../img/t/l/br.png')
</pre>

and Retina support

<pre>
.t
  .l
    .tl
      stylsprite url('../img/t/l/tl.png'),2
    .tr
      stylsprite url('../img/t/l/tr.png'),2
    .bl
      stylsprite url('../img/t/l/bl.png'),2
    .br
      stylsprite url('../img/t/l/br.png'),2
</pre>

# For more information, please see below.
`node_modules/grunt-stylsprite/gruntfile.coffee`