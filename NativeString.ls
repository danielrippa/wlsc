
  NativeString = do ->

    char = utf16-as-char = -> String.from-char-code it
    char-as-utf16 = -> it.char-code-at 0

    cc = Ascii.control-code

    separators =

      unit: cc.us
      record: cc.rs
      group: cc.gs
      file: cc.fs

    { record } = separators

    tab = char 9
    lf = char 10

    ff = 12

    replace-crlf = (string, replacement = record) -> string.replace /\r\n/g, replacement
    replace-lf = (string, replacement = record) -> string.replace /\n/g, replacement
    replace-cr = (string, replacement = record) ->

    string-as-records = -> it |> replace-crlf |> replace-lf

    records-as-array = (.split record)
    array-as-records = (.join record)

    records-as-string = (records, separator = '\n') -> records |> records-as-array |> array-as-records _ , separator

    trim-regex = /^[\s\uFEFF\xA0]+|[\s\uFEFF\xA0]+$/g

    trim = -> trim-regex `it.replace` ''

    to-case = -> &0["to#{ &1 }Case"]!

    ucase = -> it `to-case` \Upper
    lcase = -> it `to-case` \Lower

    camel = -> ucase &1 ? ''
    camel-regex = /[-_]+(.)?/g

    camelize = -> camel-regex `it.replace` camel

    upper-lower-regex = /([^-A-Z])([A-Z]+)/g
    upper-regex = /^([A-Z]+)/

    dash-lower-upper = (, lower, upper) -> "#{ lower }-#{ if upper.length > 1 then upper else lcase upper }"
    replace-upper-lower = -> upper-lower-regex `it.replace` dash-lower-upper
    dash-upper = (, upper) -> if upper.length > 1 then "#upper-" else lcase upper
    replace-upper = -> upper-regex `it.replace` dash-upper

    dasherize = -> it |> replace-upper-lower |> replace-upper

    {
      utf16-as-char, char-as-utf16,
      separators, replace-crlf, replace-lf
      trim,
      ucase, lcase,
      camelize, dasherize
    }