
  NativeString = do ->

    char = -> String.from-char-code it

    separators =

      file: 28
      group: char 29
      record: char 30
      unit: char 31

    { record } = separators

    replace-crlf = (.replace /\r\n/g, record)
    replace-lf   = (.replace /\n/g,   record)

    string-as-records = -> it |> replace-crlf |> replace-lf

    records-as-array = (.split record)

    text-as-array = -> it |> string-as-records |> records-as-array

    trim-regex = /^\s+|\s+$/g

    trim = (.replace trim-regex, '')

    lcase = (.to-lower-case!)

    {
      text-as-array,
      trim,
      lcase
    }
