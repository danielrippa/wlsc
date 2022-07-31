
  WScript

    script-name = ..ScriptName

    ..Arguments

      ..Unnamed

        arg = -> ..Item it
        argc = ..Count

    exit = -> ..Quit it

    [ stdout, stderr ] = do ->

      std = (stream) -> -> for arg in arguments => ..["Std#stream"].Write arg

      [ (std name) for name in <[ Out Err ]> ]

  fail = (message, errorlevel = 1) !->

    if message isnt void then stderr message
    exit errorlevel

  [ file-exists, get-content, set-content ] = do ->

    io-mode = reading: 1, writing: 2, appending: 8

    new ActiveXObject 'Scripting.FileSystemObject'

      exists = -> ..FileExists it

      text-stream = (filename, mode) -> ..OpenTextFile filename, mode

      use-stream = (stream, fn) !-> try result = fn stream ; stream.Close! ; return result

      readable = (filename) -> text-stream filename, io-mode.reading
      writeable = (filename, appending) -> text-stream filename, (io-mode => if appending then ..appending else ..writing)

      read = (filename) -> use-stream (readable filename), (.ReadAll!)
      write = (filename, content, appending = no) !-> use-stream (writeable filename, appending), (.Write content)

    [ exists, read, write ]

  [ trim, text-as-lines, chars ] = do ->

    trim = (.replace /^[\s]+|[\s]+$/g, '')

    lines = (.split '\n')

    chars = (.split '')

    [ trim, lines, chars ]

  [ textfile-lines ] = do ->

    read = (filename, resource-type, errorlevel) ->

      if not file-exists filename

        fail "#resource-type file '#filename' not found.", errorlevel

      text-as-lines get-content filename

    [ read ]