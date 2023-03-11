
  WlscNamespacePathResolver = do ->

    { file-exists, folder-exists } = FileSystem
    { read: read-object-file } = ObjectFile
    { shell } = Shell

    current-folder = shell!CurrentDirectory

    get-configuration-namespaces = ->

      filename = 'namespaces.conf'

      return {} if not file-exists filename

      read-object-file filename

    resolve-filesystem-namespace-path = (qualified-namespace) ->

      return current-folder if qualified-namespace is ''

      namespaces = qualified-namespace / '.'

      ([ current-folder ] ++ qualified-namespace / '.') * '\\'

    #

    fail-if-namespace-path-not-found = (qualified-dependency-name, namespace-path) !->

      if not folder-exists namespace-path

        errorlevel = 3

        fail do

          * "Unable to resolve path of dependency '#qualified-dependency-name'."
            "Folder '#namespace-path' not found."

          errorlevel
    #

    new-namespace-path-resolver = ->

      configuration-namespaces = get-configuration-namespaces!
      filesystem-namespaces = {}

      get-filesystem-namespace-path = (qualified-namespace) ->

        return filesystem-namespaces[qualified-namespace] unless that is void

        if resolve-filesystem-namespace-path qualified-namespace

          filesystem-namespaces[qualified-namespace] := that ; return that

      resolve-namespace-path: (qualified-namespace, qualified-dependency-name) ->

        namespace-path = configuration-namespaces[qualified-namespace]

        return namespace-path unless namespace-path is void

        namespace-path = get-filesystem-namespace-path qualified-namespace

        fail-if-namespace-path-not-found qualified-dependency-name, namespace-path

        namespace-path

    {
      new-namespace-path-resolver
    }