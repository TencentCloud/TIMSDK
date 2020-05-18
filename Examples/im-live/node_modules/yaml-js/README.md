yaml-js
===

yaml-js is currently a YAML loader, and eventually a YAML dumper, ported pretty
much line-for-line from [PyYAML](http://pyyaml.org/).  The goal is to create a
reliable and specification-complete YAML processor in pure Javascript.  You can
try it out [here](http://connec.github.com/yaml-js/).

Current Status
---

Currently loading works well, and passes the
[yaml-spec](https://github.com/connec/yaml-spec) test suite.

If you use the library and find any bugs, don't hesitate to create an
[issue](https://github.com/connec/yaml-js/issues).

How Do I Get It?
---

    npm install yaml-js

How Do I Use It?
---

In node (CoffeeScript):

```coffeescript
yaml = require 'yaml-js'
console.log yaml.load '''
  ---
  phrase1:
    - hello
    - &world world
  phrase2:
    - goodbye
    - *world
  phrase3: >
    What is up
    in this place.
'''
# { phrase1: [ 'hello', 'world' ],
#   phrase2: [ 'goodbye', 'world' ],
#   phrase3: 'What is up in this place.' }
```

In the browser:

```html
<script src='yaml.min.js'></script>
<script>
  console.log(yaml.load('hello: world'));
  // { 'hello' : 'world' }
</script>
```

License
---

[WTFPL](http://sam.zoy.org/wtfpl/)