# has-generators

  feature-detect generators.

## Installation

    npm install has-generators

## API
### require('has-generators') -> Boolean

  * true: Your runtime supports generators! Sweet!
  * false: Your runtime doesn't support generators, aww :(

## Example

```javascript
// foo.js
module.exports = require('has-generators') ? require('./foo.es6') : require('./foo.es5')
```
