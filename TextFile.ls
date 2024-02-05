
  TextFile = do ->

    { file-system } = FileSystem
    { text-as-array } = NativeString

    io-mode = reading: 1, writing: 2, appending: 8

    text-stream = (filename, mode) -> file-system!OpenTextFile filename, mode

    use-stream = (stream, fn) -> try result = fn stream ; stream.Close! ; return result

    readable = (filename) -> text-stream filename, io-mode.reading

    read-stream = (filename) -> use-stream (readable filename), (.ReadAll!)

    read = (filename) -> text = read-stream filename ; if text is void then [] else text-as-array text

    {
      read
    }
