
  FileSystem = do ->

    file-system = -> new ActiveXObject 'Scripting.FileSystemObject'

    fso = file-system!

    file-exists = -> fso.FileExists it
    folder-exists = -> fso.FolderExists it

    absolute-path = -> fso.GetAbsolutePathName it

    build-path = (path, filename) -> fso.BuildPath path, filename

    get-filename-path = (filename) ->

      index = filename.last-index-of '\\'
      if index is -1 then '' else filename.slice index

    get-parent-folder = (filename) ->

      path = fso.GetParentFolderName filename

      index = path.index-of ':'

      if (index) isnt -1

        path = path.slice index + 1

      path

    parse-filename = (filename) ->

      fso

        return

          name: ..GetBaseName filename
          extension: ..GetExtensionName filename
          drive: ..GetDriveName filename
          path: get-parent-folder filename

    normalize-filename = (filename, required-extension) ->

      { name, extension, drive, path } = parse-filename filename

      if extension is '' then extension = required-extension

      if drive isnt ''
        path = "#drive#path"

      build-path path, "#name.#extension"

    {
      file-system,
      file-exists, folder-exists, absolute-path,
      build-path,
      parse-filename, normalize-filename
    }