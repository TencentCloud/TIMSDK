
# co-from-stream

  Create a [co generator stream](https://github.com/juliangruber/co-stream)
  from a [node stream](http://nodejs.org/api/stream.html).

## Usage

```js
var co = require('co');
var fs = require('fs');
var fromStream = require('co-from-stream');

co(function*(){
  var read = fromStream(fs.createReadStream('index.js'));
  
  var data;
  while (data = yield read()) console.log(data.toString());
})();
```

## API

### fromStream(stream)

  Create a co generator stream from `stream`.

## Installation

```bash
$ npm install co-from-stream
```

## License

  MIT
