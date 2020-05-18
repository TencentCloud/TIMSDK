class @Event
  constructor: (@start_mark, @end_mark) ->

class @NodeEvent extends @Event
  constructor: (@anchor, @start_mark, @end_mark) ->

class @CollectionStartEvent extends @NodeEvent
  constructor: (@anchor, @tag, @implicit, @start_mark, @end_mark) ->

class @CollectionEndEvent extends @Event

class @StreamStartEvent extends @Event
  constructor: (@start_mark, @end_mark, @explicit, @version, @tags) ->

class @StreamEndEvent extends @Event

class @DocumentStartEvent extends @Event
  constructor: (@start_mark, @end_mark, @explicit, @version, @tags) ->

class @DocumentEndEvent extends @Event
  constructor: (@start_mark, @end_mark, @explicit) ->

class @AliasEvent extends @NodeEvent

class @ScalarEvent extends @NodeEvent
  constructor: \
    (@anchor, @tag, @implicit, @value, @start_mark, @end_mark, @style) ->

class @SequenceStartEvent extends @CollectionStartEvent

class @SequenceEndEvent extends @CollectionEndEvent

class @MappingStartEvent extends @CollectionStartEvent

class @MappingEndEvent extends @CollectionEndEvent