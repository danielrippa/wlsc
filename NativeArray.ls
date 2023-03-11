
  NativeArray = do ->

    { control-code: { cr-lf } } = Ascii

    array-as-string = (array, separator) -> array.join separator

    array-as-text = (array, separator = cr-lf) -> array-as-string array, separator

    map-values = (array, fn) -> [ (fn value, index) for value,index in array ]

    first-value = (array) -> array.0

    last-value = (array) -> position = array.length - 1 ; array[position]

    drop-first = (array, n = 1) -> array.slice n

    drop-last = (array, n = 1) -> array.slice 0, -n

    {
      array-as-string, array-as-text,
      map-values,
      first-value, last-value,
      drop-first, drop-last
    }