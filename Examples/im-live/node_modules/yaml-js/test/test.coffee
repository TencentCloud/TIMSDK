yaml = require '..'

spec =
  generic:    require './yaml-spec/spec'
  javascript: require './yaml-spec/platform/javascript'

for type, suite of spec
  for name, tests of suite
    describe name, ->
      for test, i in tests then do (test) ->
        it "##{i + 1}", ->
          received = yaml.load test.yaml
          if test.result isnt test.result
            # NaN is the only value that does not equal itself, so if `a !== a` and `b !== b` then
            # a and b are NaN (and therefore equal...)
            expect( received ).not.to.equal received
          else
            expect( received ).to.deep.equal test.result