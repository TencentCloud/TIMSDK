
# co-read

Consume a readable stream generator-style. Works with streams1 (push) and
streams2 (pull) streams!

[![build status](https://secure.travis-ci.org/juliangruber/co-read.png)](http://travis-ci.org/juliangruber/co-read)

## Example

Log all chunks from a stream to stdout:

```js
var http = require('http');
var co = require('co');
var read = require('co-read');

co(function*() {
  var stream = createStreamSomehow();
  var buf;
  while(buf = yield read(stream)) {
    console.log(buf);  
  }
});
```

Also check out `/example.js` for a complete example using http streams, both
streams1 and streams2 style.

## API

### read(stream)

Read a chunk from `stream`.

* Returns a truthy value when the stream emits data.
* Returns undefined when the stream ended.
* Throws an `Error` when `stream` emits one.

## Installation

With [npm](https://npmjs.org) do:

```bash
npm install co-read
```

## Kudos

The streams2 part is based on
[previous work](https://github.com/visionmedia/co/commit/d1f03a936a70d7c7cb27c9d95b53ed567a4ded10)
from [TooTallNate](https://github.com/TooTallNate).

## License

(MIT)

Copyright (c) 2013 Julian Gruber &lt;julian@juliangruber.com&gt;

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
