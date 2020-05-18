[![NPM](https://nodei.co/npm/co-fs-extra.png?downloads=true&downloadRank=true&stars=true)](https://nodei.co/npm/co-fs-extra/)

# co-fs-extra

  'fs-extra' wrapped functions that return thunks for [co](https://github.com/visionmedia/co).

## Installation

```
$ npm install co-fs-extra --save
```

## API

see more -> [fs-extra](https://www.npmjs.org/package/fs-extra)

## Example

 Use all the regular async fs functions without callback hell:

```js
var json = yield fs.readFile('package.json', 'utf8')
var file = yield fs.ensureFile('hello.txt')
```

## License

  MIT
