# wlsc Windows LiveScript Compiler

Takes [LiveScript files](https://livescript.net/) as an input and emits a [Windows Script File](https://en.wikipedia.org/wiki/Windows_Script_File) to be used with [Microsoft cscript](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/cscript) as output.

The main file (usually with a .wls file extension) uses a slightly different syntax from the livescript ones (usually with a .ls file extension).

## How to use

WLSC.CMD must be in the system path and the .WLS file is passed as an argument.

E. g.

```
WLSC somescript.wls
```

Atfer compilation a new .WSF file with the same basename as the .WLS one will be created.

## Dependency keyword

WlsC introduces the `dependency` keyword in order to be able to access other source files located in arbitrary locations in the filesystem. These locations are expressed as namespaces that can be either actual filesystem folder hierarchies or declared via an additional optional file named `namespaces.conf`.

In the optional namespace configuration file `namespaces.conf` namespaces are declared in each line using the following syntax `qualified.namespace <space> actual\filesystem\location`. This allows to declare conceptually unified namespaces but located in completely arbitrary filesystem locations.

E.g.

```
os c:\scripts\os\
os.microsoft d:\users\danielr\windows-scripts\
os.linux h:\linux\scripts\
```

The `dependency` keyword can be used both in .wls and .ls files.

## Wls file syntax

Wls files are the main driver and one .WSF file will be emitted for each .WLS file.

## Livescript file syntax
