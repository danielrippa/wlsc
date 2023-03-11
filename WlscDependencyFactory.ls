
  WlscDependencyFactory = do ->

    { parse-qualified-dependency-name } = WlscUtils
    { build-path, file-exists } = FileSystem
    { parse-livescript-lines } = LivescriptParser
    { read-lines: read-textfile-lines } = TextFile
    { new-namespace-path-resolver } = WlscNamespacePathResolver
    { fail-with } = Wsh
    { trim } = NativeString

    read-dependency-lines = (filepath, qualified-dependency-name) ->

      dependency-lines = void

      message =

        * "Unable to build dependency '#qualified-dependency-name'."
          "File '#filepath' not found."

      fail-with [ 3, message ], -> dependency-lines := read-textfile-lines filepath

      dependency-lines

    is-do-line = ->

      line = trim it

      return no if line is ''

      if (line.index-of 'do') isnt -1

        if line.index-of '->' isnt -1

          [ first, last ] = line.split ' '

          first = trim first
          last =  trim last

          if first is 'do'
            if last is '->'

              return yes

      no

    parse-dependency-lines = (qualified-dependency-name, filepath, dependency-lines) ->

      # dependency-lines must start with 'do ->'

      lines = []

      do-line-found = no

      for dependency-line in dependency-lines

        if is-do-line dependency-line
          do-line-found = yes
          continue

        lines ++= dependency-line

      if not do-line-found

        fail do
          * "Syntax error in dependency #qualified-dependency-name"
            "Dependency must start with 'do ->'"
          4

      parse-livescript-lines lines

    new-dependency-factory = ->

      { resolve-namespace-path } = new-namespace-path-resolver!

      new-dependency: (qualified-dependency-name) ->

        { qualified-namespace, dependency-name } = parse-qualified-dependency-name qualified-dependency-name

        namespace-path = resolve-namespace-path qualified-namespace, qualified-dependency-name

        filepath = build-path namespace-path, "#dependency-name.ls"

        dependency-lines = read-dependency-lines filepath, qualified-dependency-name

        { dependency-references, comment-lines, header-lines, livescript-lines } = parse-dependency-lines qualified-dependency-name, filepath, dependency-lines

        {
          qualified-dependency-name, qualified-namespace, dependency-name,
          filepath,
          comment-lines, header-lines, livescript-lines,
          dependency-references
        }

    {
      new-dependency-factory
    }