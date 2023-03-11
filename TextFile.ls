
  TextFile = do ->

    { file-system: fs } = FileSystem
    { text-as-array } = NativeString

    io-mode = reading: 1, writing: 2, appending: 8

    text-stream = (filename, mode) -> fs!OpenTextFile filename, mode

    use-stream = (stream, fn) !-> try result = fn stream ; stream.Close! ; return result

    readable = (filename) -> text-stream filename, io-mode.reading
    writeable = (filename, appending) -> text-stream filename, (io-mode => if appending then ..appending else ..writing)

    read = (filename) -> use-stream (readable filename), (.ReadAll!)
    write = (filename, content, appending = no) !-> use-stream (writeable filename, appending), (.Write content)

    append = (filename, content) -> write filename, content, yes

    read-lines = (filename) -> text = read filename ; if text is void then [] else text-as-array text

    {
      read, read-lines,
      write, append
    }
