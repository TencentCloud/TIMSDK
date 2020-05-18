timeago
=======

Simple timeago function takes same params as 'new Date(...)'

````
var ta = require('./time-ago.js')  // node.js
var ta = timeago();	          // browser
````

###ta.ago(..., [short])
````
ta.ago(new Date()-1000);  =>  "1 second ago"
ta.ago(new Date()-2000);  =>  "2 seconds ago"

ta.ago(1);  =>  "44 years ago"

// takes twitter's created_at date format, in your timezone
ta.ago('Sun Jun 28 19:44:05 +0000 2013'); => "2 days ago"

// and UTC
ta.ago('1997-07-16T19:20+01:00'); => "16 years ago"

// with optional short parameter
ta.ago(new Date()-1000, true);  =>  "1s"
ta.ago(new Date()-1000 * 60, true); => "1m"
ta.ago(new Date()-1000 * 60 * 60, true); => "1h"

````
###ta.today()
````
ta.today() function shows Day, Month, Date, Yr    
 ==> 'Monday, June 1, 1970'    
````

###ta.timefriendly('x period')
````
ta.timefriendly('1 hour')  // convert to ms: seconds, minutes, hours, days, weeks, months, years
 ==> 3600000

 ta.timefriendly('1 hour')  // convert to ms: seconds, minutes, hours, days, weeks, months, years
 ==> 3600000
````

###ta.mintoread(text, [altcmt, wpm])
Cool Medium like 'x min to read' feature
````
ta.mintoread('six hundred words of text')  // calculate based on 200 wpm reading speed
 ==> "3 min to read"

ta.mintoread('six hundred words of text', ' minutes to finish')  // optional alternate comment
 ==> "3 minutes to finish"

ta.mintoread('six hundred words of text', null, 300)  // alternate wpm
 ==> "2 min to read"
````
