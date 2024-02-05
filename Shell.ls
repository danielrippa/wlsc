
  Shell = do ->

    shell = -> new ActiveXObject 'WScript.Shell'

    get-working-folder = -> shell!CurrentDirectory

    {
      get-working-folder
    }