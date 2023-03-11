
  WlscDependencyManager = do ->

    { new-dependency-factory } = WlscDependencyFactory
    { lcase } = NativeString

    new-dependency-manager = (primary-references) ->

      { new-dependency } = new-dependency-factory!

      resolved-dependencies = {}
      dependencies = []

      add-dependency = (qualified-dependency-name, dependency) ->

        resolved-dependencies[lcase qualified-dependency-name] := dependency
        dependencies[*] := dependency

      #

      get-dependencies = -> dependencies

      get-dependency = (qualified-dependency-name) ->

        dependency = resolved-dependencies[lcase qualified-dependency-name]

        if dependency is void

          dependency = new-dependency qualified-dependency-name

          add-dependency qualified-dependency-name, dependency

        for reference in dependency.dependency-references

          { qualified-dependency-name: referenced-qualified-dependency-name } = reference.dependency-name-metadata

          referenced-dependency = resolved-dependencies[lcase referenced-qualified-dependency-name]

          if referenced-dependency is void

            referenced-dependency = get-dependency referenced-qualified-dependency-name

        dependency

      #

      for primary-reference, index in primary-references

        { qualified-dependency-name: referenced-qualified-dependency-name } = primary-reference.dependency-name-metadata

        get-dependency referenced-qualified-dependency-name

      { get-dependencies }

    {
      new-dependency-manager
    }