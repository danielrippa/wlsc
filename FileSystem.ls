
  FileSystem = do ->

    file-system = -> new ActiveXObject 'Scripting.FileSystemObject'

    fs = file-system!

    file-exists = -> fs.FileExists it
    folder-exists = -> fs.FolderExists it

    absolute-path = -> fs.GetAbsolutePathName it

    build-path = (path, filename) -> fs.BuildPath path, filename

    get-parent-folder = (path) ->

      parent-folder = fs.GetParentFolderName path

      index = path.index-of ':'

      if (index) isnt -1
        parent-folder = parent-folder.slice index + 1

      parent-folder

    parse-filepath = ->

      fs

        return

          name: ..GetBaseName it
          extension: ..GetExtensionName it
          drive: ..GetDriveName it
          path: get-parent-folder it

    normalize-filepath = (filepath, required-extension) ->

      { name, extension, drive, path } = parse-filepath filepath

      extension = required-extension \
        if extension is ''

      path = "#drive#path" \
        if drive isnt ''

      build-path path, "#name.#extension"

    {
      file-system,
      get-parent-folder,
      parse-filepath,
      absolute-path,
      build-path,
      normalize-filepath,
      file-exists, folder-exists
    }