"use strict";

var timeago = function() {

  var o = {
    second: 1000,
    minute: 60 * 1000,
    hour: 60 * 1000 * 60,
    day: 24 * 60 * 1000 * 60,
    week: 7 * 24 * 60 * 1000 * 60,
    month: 30 * 24 * 60 * 1000 * 60,
    year: 365 * 24 * 60 * 1000 * 60
  };
  var obj = {};

  obj.ago = function(nd, s) {
    var r = Math.round,
        dir = ' ago',
      pl = function(v, n) {
        return (s === undefined) ? n + ' ' + v + (n > 1 ? 's' : '') + dir : n + v.substring(0, 1)
      },
      ts = Date.now() - new Date(nd).getTime(),
      ii;
    if( ts < 0 )
    {
      ts *= -1;
      dir = ' from now';
    }
    for (var i in o) {
      if (r(ts) < o[i]) return pl(ii || 'm', r(ts / (o[ii] || 1)))
      ii = i;
    }
    return pl(i, r(ts / o[i]));
  }

  obj.today = function() {
    var now = new Date();
    var Weekday = new Array("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday");
    var Month = new Array("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December");
    return Weekday[now.getDay()] + ", " + Month[now.getMonth()] + " " + now.getDate() + ", " + now.getFullYear();
  }

  obj.timefriendly = function(s) {
    var t = s.match(/(\d).([a-z]*?)s?$/);
    return t[1] * eval(o[t[2]]);
  }

  obj.mintoread = function(text, altcmt, wpm) {
    var m = Math.round(text.split(' ').length / (wpm || 200));
    return (m || '< 1') + (altcmt || ' min to read');
  }

  return obj;
}

if (typeof module !== 'undefined' && module.exports)
  module.exports = timeago();
