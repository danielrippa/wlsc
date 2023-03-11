
  ObjectFile = do ->

    { read: read-textfile } = TextFile
    { text-as-array } = AsciiSeparatedStrings
    { trim } = NativeString

    read = (filename) ->

      instance = {}

      content = read-textfile filename

      lines = text-as-array content

      for line, index in lines

        trimmed = trim line

        continue \
          if trimmed is ''

        continue \
          if trimmed.0 is '#'

        index = line.index-of ' '

        if index is -1

          instance[line] = void

        else

          name = line.slice 0, index
          value = line.slice index + 1

          instance[name] = value

      instance

    {
      read
    }