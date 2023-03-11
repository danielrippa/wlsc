
  NativeObject = do ->

    object-as-array = (object, fn) -> [ (fn name, value) for name,value of object ]
    array-as-object = (array) -> { [ value, value ] for value in array }
    arrays-as-object = (names, values) -> { [ name, values[index] ] for name,index in names }

    map-object-keys = (object, fn) -> { [ (fn name, value), value ] for name, value of object }
    map-object-values = (object, fn) -> { [ name, (fn value, name) ] for name, value of object }

    map-object = (object, key-fn, value-fn) -> { [ (key-fn name, value), (value-fn value, name) ] for name, value of object }

    {
      object-as-array, array-as-object, arrays-as-object,
      map-object-keys, map-object-values, map-object
    }