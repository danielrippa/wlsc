
  WlsC = do ->

    { absolute-path, normalize-filepath, build-path, file-exists, folder-exists } = FileSystem
    { read: read-textfile } = TextFile
    { fail } = Wsh
    { array-as-object, first-item, last-item, map-items, drop-first } = NativeArray
    { trim, lcase } = NativeString
    { get-working-folder } = Shell
    { read: read-objectfile } = ObjectFile
    { code-of } = NativeFunction

    ##

    indent = (n, string) ->

      indentation = Array (n * 2) + 1 .join ' '
      "#indentation#string"

    comment = -> "``// #it``"

    livescript = ":livescript(bare='true' header='\\n')"

    ##

    is-comment = (line) ->

      chars = (trim line) / ''
      (first-item chars) is '#'

    dependency-keyword = ' dependency '

    is-reference = (line) ->

      (line.index-of dependency-keyword) isnt -1

    parse-members-line = (line) ->

      index = line.index-of '='

      throw new Error "Invalid dependence syntax. Missing '=' character." \
        if index is -1

      members = []

      line = trim line.slice 0, index

      first = line.char-at 0
      last  = line.char-at (line.length - 1)

      brackets-ok = first is \{ and last is \}

      throw new Error "" \
        if not brackets-ok

      line = trim line.slice 1, -1

      [ (trim member) for member in line.split ',' ]

    parse-qualified-dependency-name = (line) ->

      line = trim line

      throw new Error "" \
        if line is ''

      qualified-dependency-name = line

      if (line.index-of '') is -1

        qualified-namespace = ''
        dependency-name = line

      else

        namespaces = line / '.'

        dependency-name = last-item namespaces
        namespaces = namespaces.slice 0, namespaces.length - 1

        qualified-namespace = namespaces * '.'

      { qualified-namespace, dependency-name, qualified-dependency-name }

    parse-reference-line = (line) ->

      [ members-line, dependency-name ] = line.split dependency-keyword

      dependency-name-metadata = parse-qualified-dependency-name dependency-name

      dependency-members = parse-members-line members-line

      { dependency-name-metadata, dependency-members }

    parse-wls-source = (wls-source) ->

      references = {}
      livescript-source = []

      parser-states = array-as-object <[ prelude code ]>

      { prelude, code } = parser-states

      parser-state = prelude

      for line, index in wls-source

        switch parser-state

          | prelude =>

            continue if (trim line) is ''

            if is-comment line

              livescript-source ++= indent 2, comment trim line

              continue

            if is-reference line

              reference = parse-reference-line line

              { dependency-name-metadata, dependency-members } = reference

              { qualified-dependency-name } = dependency-name-metadata

              existing-reference = references[ qualified-dependency-name ]

              if existing-reference is void

                references[ qualified-dependency-name ] = reference

              else

                references[ qualified-dependency-name ].dependency-members ++= dependency-members

            else

              parser-state = code
              livescript-source ++= line

          | code =>

            livescript-source ++= line

      { references, livescript-source }

    ##

    normalize-wls-filepath = -> absolute-path normalize-filepath it, 'wls'

    parse-wls-file = (original-filepath) ->

      normalized-filepath = normalize-wls-filepath original-filepath

      try wls-source = read-textfile normalized-filepath
      catch e

        fail do

          * "Unable to read content of WLS file '#original-filepath' (#normalized-filepath)"
            e.message
          2

      { references, livescript-source } = parse-wls-source wls-source

      {
        original-filepath, normalized-filepath, references, livescript-source
      }

    ##

    get-configuration-namespaces = ->

      filename = 'namespaces.conf'

      return {} \
        unless file-exists filename

      read-objectfile filename

    #

    resolve-filesystem-namespace-path = (qualified-namespace) ->

      working-folder = get-working-folder!

      return working-folder if qualified-namespace is '.'

      namespaces = qualified-namespace / '.'

      ([ working-folder ] ++ namespaces) * '\\'

    #

    new-namespace-path-resolver = ->

      configuration-namespaces = get-configuration-namespaces!
      filesystem-namespaces = {}

      get-filesystem-namespace-path = (qualified-namespace) ->

        namespace-path = filesystem-namespaces[ qualified-namespace ]

        return namespace-path unless namespace-path is void

        namespace-path = resolve-filesystem-namespace-path qualified-namespace

        filesystem-namespaces[ qualified-namespace ] := namespace-path

        namespace-path

      #

      resolve-configuration-namespace-path = (qualified-namespace) ->

        root-configuration-namespace = configuration-namespaces['.']

        if root-configuration-namespace isnt void

          namespaces = qualified-namespace / '.'

          ([ root-configuration-namespace ] ++ namespaces) * '\\'

      get-configuration-namespace-path = (qualified-namespace) ->

        namespace-path = configuration-namespaces[qualified-namespace]

        return namespace-path unless namespace-path is void

        resolve-configuration-namespace-path qualified-namespace

      #

      resolve-namespace-path = (qualified-namespace) ->

        # namespace-path = configuration-namespaces[qualified-namespace]

        namespace-path = get-configuration-namespace-path qualified-namespace

        if namespace-path is void

          namespace-path = get-filesystem-namespace-path qualified-namespace

        namespace-path

      {
        resolve-namespace-path
      }

    ##

    read-dependency-lines = (file-path, qualified-dependency-name) ->

      if not file-exists file-path

        fail do

          * "Unable to read dependency '#qualified-dependency-name'."
            "File '#file-path' not found."
            "Check your 'namespaces.conf' file."
          3

      try dependency-lines = read-textfile file-path
      catch e =>

        fail do

          * "Unable to read dependency '#qualified-dependency-name'."
            e.message
            "Check your 'namespaces.conf' file."
          3

      dependency-lines

    #

    is-do-line = (line) ->

      line = trim line

      return no if line is ''

      if (line.index-of 'do') isnt -1
        if (line.index-of '->') isnt -1

          [ first, last ] = line.split ' '

          first = trim first
          last  = trim last

          if first is 'do'
            if last is '->'

              return yes

      no

    #

    parse-dependency-lines = (dependency-lines, qualified-dependency-name, file-path) ->

      do-line-found = no

      wls-source = []

      for line in dependency-lines

        if is-do-line line

          do-line-found = yes
          continue

        wls-source ++= line

      unless do-line-found

        fail do

          * "Syntax error in dependency '#qualified-dependency-name'"
            "Dependency must start with 'do ->'"
          4

      parse-wls-source wls-source

    #

    new-dependency-builder = ->

      path-resolver = new-namespace-path-resolver!

      build-dependency = ({ qualified-namespace, qualified-dependency-name, dependency-name }) ->

        namespace-path = path-resolver.resolve-namespace-path qualified-namespace

        if namespace-path is void

          fail do

            * "Unable to resolve path of dependency '#qualified-dependency-name'."
              "Check your 'namespaces.conf' file."
            5

        if not folder-exists namespace-path

          fail do

            * "Unable to resolve path of dependency '#qualified-dependency-name'."
              "Folder '#namespace-path' not found."
              "Check your 'namespaces.conf' file."
            6

        file-path = void

        { references, livescript-source } =

          namespace-path

            |> build-path _ , "#dependency-name.ls"
            |> -> file-path := it
            |> read-dependency-lines _ , qualified-dependency-name
            |> parse-dependency-lines _ , qualified-dependency-name, file-path

        {
          qualified-namespace, qualified-dependency-name, dependency-name,
          references, livescript-source,
          file-path
        }

      {
        build-dependency
      }

    #

    new-dependency-manager = (references) ->

      dependency-builder = new-dependency-builder!

      resolved-dependencies = {}
      dependencies = []

      add-dependency = (dependency) ->

        dependency-name = lcase dependency.qualified-dependency-name

        resolved-dependencies[dependency-name] := dependency
        dependencies.push dependency

      resolve-reference = (parent-reference) !->

        { qualified-dependency-name } = parent-reference.dependency-name-metadata

        parent-dependency = resolved-dependencies[ lcase qualified-dependency-name ]

        if parent-dependency is void

          parent-dependency = dependency-builder.build-dependency parent-reference.dependency-name-metadata

        for , child-reference of parent-dependency.references

          { qualified-dependency-name } = child-reference.dependency-name-metadata

          child-dependency = resolved-dependencies[ lcase qualified-dependency-name ]

          if child-dependency is void

            resolve-reference child-reference

        add-dependency parent-dependency

      #

      for , reference of references

        resolve-reference reference

      get-dependencies = -> dependencies

      {
        get-dependencies
      }

    ##

    compose-namespaces-prelude = (dependencies) ->

      lines = [ comment "Namespaces prelude START" ]

      root-namespaces = {}

      for dependency in dependencies

        { qualified-namespace } = dependency

        if qualified-namespace is '' => continue

        namespaces = qualified-namespace / '.'

        root-namespace = first-item namespaces

        if root-namespaces[root-namespace] is void

          root-namespaces[root-namespace] = []

        continue if namespaces.length is 1

        rest = drop-first namespaces

        root-namespaces[root-namespace][*] = rest

      for root-namespace, namespaces of root-namespaces

        continue if root-namespace is ''

        lines ++= "#root-namespace = {};"

        for namespace in namespaces

          namespace-generator = code-of !->

            do !->

              ``// vars-declarations``

              namespace-path = root-namespace

              namespace-value = void

              for namespace in namespaces

                continue if namespace is ''

                namespace-path = "#namespace-path.#namespace"

                namespace-value = eval namespace-path

                if namespace-value is void

                  eval "#namespace-path = {}"

          root-namespace-declaration = "var rootNamespace = '#root-namespace' ;"

          namespaces-literals = [ "'#name'" for name in namespaces ]

          namespaces-declaration = "var namespaces = [ #namespaces-literals ] ;"

          declarations-interpolation =

            * root-namespace-declaration
              namespaces-declaration

            |> (* ' ')

          namespace-generator = namespace-generator.replace do

            '// vars-declarations'
            declarations-interpolation

          interpolated-generator =

            * "``"
              namespace-generator
              "``"

          lines ++= interpolated-generator

      lines ++= [ comment "Namespaces prelude END" ]

      map-items lines, -> indent 3, it

    ##

    get-wsf-header = ->

      * indent 0, \job
        indent 1, \script
        indent 2, livescript

    ##

    compose-references-lines = (references) ->

      lines = []

      for , reference of references

        { dependency-members, dependency-name-metadata } = reference
        { qualified-dependency-name } = dependency-name-metadata

        lines ++= indent 3, "{ #{ dependency-members * ', ' } } = #qualified-dependency-name ;"

      lines

    ##

    compose-script-lines = (wls-script) ->

      { original-filepath, normalized-filepath, livescript-source } = wls-script

      script-header = [ indent 3, comment "WLS script '#original-filepath' (#normalized-filepath)" ]
      references-lines = compose-references-lines wls-script.references
      livescript-source = map-items livescript-source, -> indent 2, it

      script-header ++ references-lines ++ livescript-source

    ##

    compose-dependency-lines = (dependency) ->

      { qualified-dependency-name, file-path } = dependency

      header-lines =

        * indent 3, comment "WLS dependency #qualified-dependency-name"
          indent 3, comment "(#file-path)"

      { livescript-source } = dependency

      livescript-lines = [ indent 3, "#{ qualified-dependency-name } = do ->" ]

      references-lines = compose-references-lines dependency.references

      references-lines = map-items references-lines, -> indent 1, it

      livescript-lines ++= references-lines

      livescript-lines ++= map-items livescript-source, -> indent 2, it

      header-lines ++ livescript-lines

    compose-dependencies-lines = (wls-script) ->

      dependency-manager = new-dependency-manager wls-script.references

      dependencies = dependency-manager.get-dependencies!

      namespaces-prelude = compose-namespaces-prelude dependencies

      dependencies-lines = []

      for dependency in dependencies

        dependencies-lines ++= compose-dependency-lines dependency

      namespaces-prelude ++ dependencies-lines

    ##

    build-wsf-script = (wls-filepath) ->

      wsf-header = get-wsf-header!

      wls-script = parse-wls-file wls-filepath

      dependencies-lines = compose-dependencies-lines wls-script
      script-lines = compose-script-lines wls-script

      wsf-header ++ dependencies-lines ++ script-lines

    {
      build-wsf-script
    }