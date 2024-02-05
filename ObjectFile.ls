
  ObjectFile = do ->

    { read: read-textfile } = TextFile
    { text-as-array, trim } = NativeString

    read = (filename) ->

      instance = {}

      for line in read-textfile filename

        trimmed = trim line

        continue \
          if trimmed is ''

        continue \
          if trimmed.0 is '#'

        index = line.index-of ' '

        if index is -1

          instance[line] = void

        else

          key = line.slice 0, index
          value = line.slice index + 1

          instance[key] = value

      instance

    {
      read
    }