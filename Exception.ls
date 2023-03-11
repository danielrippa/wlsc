
  Exception = do ->

    try-catch = (proc) ->

      failed = yes

      code = ''
      description = ''

      try proc! ; failed = no
      catch

        if e.number isnt void
          code = "#{ e.number .>>. 16 .&. 0x1fff }"

        if e.description isnt void
          description = e.description

      if code isnt ''
        code = "Error Code: #code"

      if description isnt ''
        description = "Error Description: '#description'"

      separator = ''

      if code isnt ''
        if description isnt ''
          separator = '\n'

      failure-description = "#code#separator#description"

      { failed, failure-description }

    {
      try-catch
    }