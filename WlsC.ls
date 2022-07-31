
  filename-parts = (filename) ->

    last-index = filename.last-index-of '.'

    [ filepath, extension ] = if last-index is -1
      [ filename, void ]
    else
      * filename.slice 0, last-index
        filename.slice last-index + 1

  normalized-filename = (resource-name, default-extension) ->

    [ filepath, extension ] = filename-parts resource-name

    if extension is void
      extension = default-extension

    "#filepath.#extension"

  is-empty-line = (line) -> (trim line).length is 0

  parse-comment = (line) ->

    line = trim line

    if (line.char-at 0) is '#'

      match line.length

        | (> 2) => line.slice 2
        | _ => ''

  parse-dependency = (line) ->

    line = trim line

    if (line.char-at 0) is '{'

      line = line.slice 1

      index = line.index-of '}'

      if index isnt -1

        equals-detected = no

        loop

          index++

          switch line.char-at index

            | ' ' =>
            | '=' => equals-detected = yes
            | otherwise =>

              if not equals-detected
                return void
              else
                return line.slice index

  commented = -> "``// #it``"

  indent = (n, str) -> indentation = Array n * 2 + 1 .join ' ' ; "#indentation#str"

  ##

  get-source = (resource-name, default-extension, resource-type, errorlevel) ->

    filename = normalized-filename resource-name, default-extension

    source = textfile-lines filename, resource-type, errorlevel

    { filename, source }

  get-script-source = (script-name) ->

    get-source script-name, 'wls', 'WSH LiveScript', 1

  get-dependency-source = (dependency-name) ->

    get-source dependency-name, 'ls', 'LiveScript', 2

  parse-livescript-source = (lines) ->

    comments = [] ; dependency-names = [] ; source = []

    parsing = 'comments'

    line = void

    consume-dependency = !->

      dependency = parse-dependency line

      if dependency isnt void

        dependency-names[*] := dependency
        source[*] := line

        parsing := 'dependencies'

      else

        source[*] := line
        parsing := 'source'

    consume-comment = !->

      comment = parse-comment line

      if comment isnt void

        comments[*] := comment

      else

        consume-dependency!

    for line in lines

      switch parsing

        | 'comments' => continue if is-empty-line line ; consume-comment!
        | 'dependencies' => continue if is-empty-line line ; consume-dependency!
        | 'source' => source[*] = line

    { comments, dependency-names, source }

  parse-dependency-source = (dependency-name, lines) ->

    source = []

    consuming-dependency-source = no

    for line in lines

      continue if is-empty-line line

      if consuming-dependency-source

        source[*] := line

      else

        if (trim line) is 'do ->'

          consuming-dependency-source := yes

          continue

        else

          fail "Dependency source '#dependency-name' must start with 'do ->'"

    parse-livescript-source source

  get-dependency = (dependency-name) ->

    { filename, source } = get-dependency-source dependency-name

    parse-dependency-source dependency-name, source

  get-dependencies = (primary-names) ->

    dependencies = {}

    for primary in primary-names

      dependency = get-dependency primary

      secondary-dependencies = get-dependencies dependency.dependency-names

      dependencies <<< secondary-dependencies

      dependencies[primary] = dependency

    dependencies

  livescript = ":livescript(bare='true' header='\\n')"

  parse-script = (script-name) ->

    { filename, source } = get-script-source script-name

    script = parse-livescript-source source

    script <<< script-name: filename
    script <<< dependencies: get-dependencies script.dependency-names
