
  Wsh = do ->

    { try-catch } = Exception

    ws = WScript

    script-name = ws.ScriptName

    ws.Arguments.Unnamed

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

    fail-with = ([ errorlevel = 1, message = '' ], proc) !->

      { failed, failure-description } = try-catch proc

      if failed

        if message isnt void
          message = text message
          failure-description = "#message\n#failure-description"

        fail failure-description, errorlevel

    {
      script-name,
      arg, argc,
      exit, fail, fail-with,
      stdout, stderr
    }

