class @Mark
  constructor: (@name, @line, @column, @buffer, @pointer) ->
  
  get_snippet: (indent = 4, max_length = 75) ->
    return null if not @buffer?
    
    break_chars = '\x00\r\n\x85\u2028\u2029'
    head = ''; start = @pointer
    while start > 0 and @buffer[start - 1] not in break_chars
      start--
      if @pointer - start > max_length / 2 - 1
        head = ' ... '
        start += 5
        break
    
    tail = ''; end = @pointer
    while end < @buffer.length and @buffer[end] not in break_chars
      end++
      if end - @pointer > max_length / 2 - 1
        tail = ' ... '
        end -= 5
        break
    
    return """
           #{(new Array indent).join ' '}#{head}#{@buffer[start...end]}#{tail}
           #{(new Array indent + @pointer - start + head.length).join ' '}^
           """
  
  toString: ->
    snippet = @get_snippet()
    where = "  in \"#{@name}\", line #{@line + 1}, column #{@column + 1}"
    return if snippet then where else "#{where}:\n#{snippet}"

class @YAMLError extends Error
  constructor: ->
    super()
    
    # Hack to get the stack on the error somehow
    @stack = @toString() + '\n' + (new Error).stack.split('\n')[1..].join('\n')

class @MarkedYAMLError extends @YAMLError
  constructor: (@context, @context_mark, @problem, @problem_mark, @note) ->
    super()
  
  toString: ->
    lines = []
    lines.push @context if @context?
    lines.push @context_mark.toString()             \
      if @context_mark? and (                       \
        not @problem? or not @problem_mark?         \
        or @context_mark.name != @problem_mark.name \
        or @context_mark.line != @problem_mark.line \
        or @context_mark.column != @problem_mark.column)
    lines.push @problem                 if @problem?
    lines.push @problem_mark.toString() if @problem_mark?
    lines.push @note                    if @note?
    return lines.join '\n'