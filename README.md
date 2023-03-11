# wlsc Windows LiveScript Compiler

Takes [LiveScript files](https://livescript.net/) as an input and emits a [Windows Script File](https://en.wikipedia.org/wiki/Windows_Script_File) to be used with [Microsoft cscript](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/cscript).

The main file (usually with a .wls file extension) uses a slightly different syntax from the livescript ones (usually with a .ls file extension).

## How to use

WLSC.CMD must be in the system path and the .WLS file is passed as an argument.

E. g.

```
WLSC somescript.wls
```

After compilation a new .WSF file with the same basename as the .WLS one will be created.

## Dependency keyword

WlsC introduces the `dependency` keyword in order to be able to access other source files located in arbitrary locations in the filesystem. These locations are expressed as namespaces that can be either actual filesystem folder hierarchies or declared via an additional optional file named `namespaces.conf`.

In the optional namespace configuration file `namespaces.conf` namespaces are declared in each line using the following syntax `qualified.namespace <space> actual\filesystem\location`. This allows to declare conceptually unified namespaces located in completely arbitrary filesystem locations.

E.g.

```
os c:\scripts\os\
os.microsoft d:\users\danielr\windows-scripts\
os.linux h:\linux\scripts\
```

The `dependency` keyword can be used both in .wls and .ls files.

## Livescript file syntax

.LS files MUST start with `do ->` in order to avoid polluting the global namespace. Compilation will not continue if `do ->` is missing in .LS files.
Other .LS files can be referenced using the `dependency` keyword.
.LS files must return an object whose members can be used in the referencing files.

E.g.

```
do ->
  
  { wql-instances } = os.wmi.Wql
  
  network-adapters = wql-instances 'Win32_NetworkAdapterConfiguration', "IPEnabled = 'True'"
  
  {
    network-adapters
  }
  
```

## Wls file syntax

Wls files are the main driver and one .WSF file will be emitted for each .WLS file.

The content of all .LS files referenced with the `dependency` keyword will be included in the .WSF file, even those indirectly  referenced by the .LS files that were also referenced by the .LS files themselves.

WLS files use a slightly different syntax from .LS files so that comment lines are preserved in .WLS files as opposed to comments in .LS files that are consumed and not emitted by the LiveScript compiler.

E.g.

```
# GetEventLogRetentionDays.wls
# Returns RSOP (Resultant Set of Policy) EventLog retention days setting

{ fail, stdout } = wsh.Wsh
{ get-args } = wsh.Args
{ get-eventlog-retention-days } = os.policies.rsop.EventLogSetting

{ log-name } = get-args <[ log-name ]>

if log-name is void => fail "Missing log-name argument."

retention-days = get-eventlog-retention-days log-name
stdout "Event Log #log-name retention days: #retention-days"

```
