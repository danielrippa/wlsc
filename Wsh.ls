
  Wsh = do ->

    ws = WScript

      script-name = ..ScriptName

      ..Arguments.Unnamed

        arg = -> ..Item it
        argc = ..Count

    exit = (errorlevel = 0) !-> ws.Quit errorlevel

    [ stdout, stderr ] = do ->

      stream = (name) -> !-> for arg in & => ws["Std#name"].Write arg

      [ (stream name) for name in <[ Out Err ]> ]

    text = -> if (typeof! it) is 'Array' then it * '\n' else it

    fail = (message, errorlevel = 1) !->

      stderr text message \
        if message isnt void
      exit errorlevel

    {
      script-name,
      arg, argc,
      exit, fail,
      stdout, stderr
    }
