
  NativeFunction = do ->

    { trim } = NativeString
    { text-as-array } = AsciiSeparatedStrings

    code-of = (fn) ->

      code = fn.to-string!

        range-start = ..index-of '{'
        range-end = ..last-index-of '}'

      code

        |> (.slice range-start + 1, range-end - 1)
        |> text-as-array

        |> (.join ' ')
        |> trim

    {
      code-of
    }