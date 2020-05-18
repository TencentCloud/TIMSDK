
var thunkify = require('./');

var Cal = function (a, b) {
  this.a = a;
  this.b = b;
};

Cal.prototype.plus = function(callback) {
  var self = this;
  setTimeout(function () {
    callback(null, self.a + self.b);
  }, 5);
};

Cal.prototype.minus = function (callback) {
  var self = this;
  setTimeout(function () {
    callback(null, self.a - self.b);
  }, 5);
};

module.exports = Cal;

exports.create1 = function (a, b) {
  return thunkify(new Cal(a, b));
};

// or
exports.create2 = function (a, b) {
  var cal = new Cal(a, b);
  cal.plus = thunkify(cal.plus, cal);
  cal.minus = thunkify(cal.minus, cal);
};

var cal1 = exports.create1(1, 2);

cal1.plus()(function (err, res) {
  console.log('cal1 plus result is ', res);
});
cal1.minus()(function (err, res) {
  console.log('cal1 minus result is ', res);
});

var cal2 = exports.create1(1, 2);

cal1.plus()(function (err, res) {
  console.log('cal2 plus result is ', res);
});
cal1.minus()(function (err, res) {
  console.log('cal2 minus result is ', res);
});
