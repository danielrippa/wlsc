
  NativeArray = do ->

    first-item = (.0)
    last-item = -> index = it.length - 1 ; it[index]

    map-items = (items, fn) -> [ (fn item, index) for item,index in items ]

    array-as-object = (items) -> { [ item, item ] for item in items }

    drop-first = (items, n = 1) -> items.slice n

    drop-last = (items, n = 1) -> items.slice 0, -n

    {
      first-item,
      last-item,
      map-items,
      array-as-object,
      drop-first, drop-last
    }