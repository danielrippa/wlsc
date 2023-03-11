
  WlsScriptComposer = do ->

    { absolute-path, normalize-filename } = FileSystem
    { read-lines: read-textfile-lines } = TextFile
    { parse-livescript-lines } = LivescriptParser
    { new-dependency-manager } = WlscDependencyManager
    { fail-with } = Wsh
    { indent, comment, uncomment } = WlscUtils
    { map-values, first-value, drop-first } = NativeArray
    { lcase } = NativeString
    { code-of } = NativeFunction

    livescript = ":livescript(bare='true' header='\\n')"

    wsf-header =

      * indent 0, 'job'
        indent 1, 'script'
        indent 2, livescript

    build-dependency-lines = (dependency) ->

      dependency-header =

        * "Livescript dependency '#{ dependency.qualified-dependency-name }'"
          "(#{ dependency.filepath })"

        |> map-values _ , comment
        |> map-values _ , -> indent 3, it

      { header-lines, comment-lines } = dependency

      comment-lines = map-values comment-lines, -> indent 3, comment uncomment it

      lines = [ indent 3, "#{ dependency.qualified-dependency-name } = do ->" ]

      lines ++= (map-values header-lines, -> indent 2, it)

      for line in dependency.livescript-lines

          lines ++= indent 2, line

      dependency-header ++ comment-lines ++ lines

    build-namespaces-lines = (dependencies) ->

      lines = []

      root-namespaces = {}

      for dependency in dependencies

        { qualified-namespace } = dependency

        if qualified-namespace is '' => continue

        namespaces = (lcase dependency.qualified-namespace) / '.'

        root-namespace = first-value namespaces

        if root-namespaces[root-namespace] is void
          root-namespaces[root-namespace] = []

        root-namespaces[root-namespace][*] = drop-first namespaces

      for root-namespace, namespaces of root-namespaces

        lines ++= "#root-namespace = [];"

        for namespace in namespaces

          namespace-generator = code-of !->

            do !->

              ``// vars-declarations``

              namespace-path = root-namespace

              namespace-value = void

              for namespace in namespaces

                namespace-path = "#namespace-path.#namespace"

                namespace-value = eval namespace-path

                if namespace-value is void

                  eval "#namespace-path = {}"

          root-namespace-declaration = "var rootNamespace = '#root-namespace' ;"

          namespace-declaration = [ "'#name'" for name in namespace ]

          namespace-declaration = "var namespaces = [ #namespace-declaration ] ;"

          declarations-interpolation =

            * root-namespace-declaration
              namespace-declaration

            |> (* ' ')

          namespace-generator = namespace-generator.replace '// vars-declarations', declarations-interpolation

          interpolated-generator =

            * '``'
              namespace-generator
              '``'
          lines ++= interpolated-generator

      lines = map-values lines, -> indent 3, it

      lines

    build-dependencies-lines = (dependencies) ->

      namespaces-lines = build-namespaces-lines dependencies

      lines = []

      for dependency in dependencies

        lines ++= build-dependency-lines dependency

      namespaces-lines ++ lines

    build-wls-script-lines = (wls-script) ->

      wls-header = [ indent 3, comment "WSH Livescript file '#{ wls-script.filepath }'" ]

      lines = []

      for line in wls-script.livescript-lines

        lines ++= indent 2, line

      lines

      { header-lines, comment-lines } = wls-script

      comment-lines = map-values comment-lines, -> indent 3, comment uncomment it

      wls-header ++ header-lines ++ comment-lines ++ lines

    parse-wls-file = (filename) ->

      filepath = absolute-path normalize-filename filename, 'wls'

      wls-lines = void

      fail-with [ 2 "Unable to read content of WSL file '#filepath'" ], -> wls-lines := read-textfile-lines filepath

      (parse-livescript-lines wls-lines) <<< { filepath }

    compose-wls-script = (filename) ->

      wls-script = parse-wls-file filename

      dependency-manager = new-dependency-manager wls-script.dependency-references

      dependencies = dependency-manager.get-dependencies!

      wls-script-lines = build-wls-script-lines wls-script

      dependencies-lines = build-dependencies-lines dependencies

      wsf-header ++ dependencies-lines ++ wls-script-lines

    {
      compose-wls-script
    }