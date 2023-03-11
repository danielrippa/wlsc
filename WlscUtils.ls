
  WlscUtils = do ->

    { trim } = NativeString
    { last-value } = NativeArray

    comment = (line = '') -> "``// #line``"

    uncomment = (line) ->

      line = trim line

      loop

        break if (line.index-of '#') is -1
        line = line.slice 1

      line

    indent = (n, string) -> indentation = Array (n * 2) + 1 .join ' ' ; "#indentation#string"

    parse-qualified-dependency-name = ->

      qualified-dependency-name = trim it

      [ qualified-namespace, dependency-name ] = if (qualified-dependency-name) is ''

        [ '.', qualified-dependency-name ]

      else

        namespaces = qualified-dependency-name / '.'

        name = last-value namespaces
        namespaces = namespaces.slice 0, namespaces.length - 1

        [ (namespaces * '.'), name ]

      { qualified-dependency-name, qualified-namespace, dependency-name }

    {
      comment, uncomment, indent,
      parse-qualified-dependency-name
    }