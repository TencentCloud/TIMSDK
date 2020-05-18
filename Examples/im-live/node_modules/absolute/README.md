absolute
========

Test if a path (string) is absolute

Installation
------------

    npm install absolute

Usage
-----

``` js
var absolute = require('absolute');

absolute('/home/dave');
// => true

absolute('/something');
// => true

absolute('./myfile');
// => false

absolute('temp');
// => false
```

License
-------

MIT
