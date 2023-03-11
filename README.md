# wlsc Windows LiveScript Compiler

Takes [LiveScript files](https://livescript.net/) as an input and emits a [Windows Script File](https://en.wikipedia.org/wiki/Windows_Script_File) to be used with [Microsoft cscript](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/cscript).

The main file (usually with a .wls file extension) references livescript ones (usually with a .ls file extension) who in turn can further reference other .ls files.

## How to use

WLSC.CMD must be in the system path and the .WLS file is passed as an argument.

E. g.

```
WLSC somescript.wls
```

After compilation a new .WSF file with the same basename as the .WLS one will be created.
Code in all referenced dependencies will be included in the final .WSF output file.

## Dependency keyword

WlsC introduces the `dependency` keyword in order to be able to access other source files located in arbitrary locations in the filesystem. These locations are expressed as namespaces that can be either actual filesystem folder hierarchies or virtual namespaces declared via an additional optional file named `namespaces.conf`.

In the optional namespace configuration file `namespaces.conf` namespaces are declared in each line with the syntax `qualified.namespace <space> actual\filesystem\location`. This allows to declare conceptually unified namespaces located in completely arbitrary filesystem locations.

E.g.

```
os c:\scripts\os\
os.microsoft.windows d:\users\danielr\windows-scripts\
os.linux.ubuntu h:\linux\scripts\ubuntu\
```

The `dependency` keyword can be used both in .wls and .ls files.

## Comment lines

Comment lines are preserved in the final code if declared immediatly before or after the code using the `dependency` keyword.

E.g.

```
  do ->
  
    # os.wmi.monikers.WmiMoniker

    # https://www.itprotoday.com/devops-and-software-development/wmi-monikers

    #   In WMI, you can specify a moniker that returns a reference to the WMI Scripting Library's SWbemServices object,
    #   which you can use to invoke one of SWbemServices' methods (e.g., ExecQuery, Get, InstancesOf).
    #   You can specify a moniker that returns a reference to an SWbemObjectSet representing a collection of WMI objects to manage.
    #   And you can create a moniker that returns a reference to a discrete SWbemObject.

    # https://docs.microsoft.com/en-us/windows/win32/wmisdk/constructing-a-moniker-string

    #   A moniker has the following parts:

    #     The prefix WinMgmts: (mandatory). The prefix instructs the Windows Script Host (WSH) that the following code will be using the Scripting API objects.
    #     A security settings component (optional).
    #     A WMI object path component (optional).

    # https://www.itprotoday.com/devops-and-software-development/wmi-monikers

    { array-as-object } = dependency native.NativeArray
    { braces } = dependency native.NativeString
    { object-as-array } = dependency native.NativeObject
    
    { new-security-setting } = dependency os.wmi.SecuritySetting
    { new-object-path } = dependency os.wmi.ObjectPath

    # Creates a new wmi moniker using standard defaults if not provided.

    new-wmi-moniker = (prefix = 'WinMgmts', security-settings = new-security-setting!, object-path = new-object-path!) ->
      ...
      
```

All comments before the lines using the `dependency` keyword and the lines right after them will be preserved in the final .WSF file.

In the example all comments up to the `new-wmi-moniker` line will be preserved.
Any comments further in the code will be consumed by the LiveScript compiler as usual.

## Livescript file syntax

.LS files MUST start with `do ->` in order to avoid polluting the global namespace. Compilation will not continue if `do ->` is missing in .LS files.
Other .LS files can be referenced using the `dependency` keyword.
.LS files must return an object whose members can be used in the referencing files.

E.g.

```
do ->
  
  { wql-instances } = dependency os.wmi.Wql
  
  network-adapters = wql-instances 'Win32_NetworkAdapterConfiguration', "IPEnabled = 'True'"
  
  {
    network-adapters
  }
  
```

## Wls file syntax

Wls files are the main driver and one .WSF file will be emitted for each .WLS file.

The content of all .LS files referenced with the `dependency` keyword will be included in the .WSF file, even those indirectly  referenced by the .LS files that were also referenced by the .LS files themselves.

WLS files use a slightly different syntax from .LS files where `do ->` is not needed and considered redundant.

E.g.

```
# GetEventLogRetentionDays.wls
# Returns RSOP (Resultant Set of Policy) EventLog retention days setting

{ fail, stdout } = dependency wsh.Wsh
{ get-args } = dependency wsh.Args
{ get-eventlog-retention-days } = dependency os.policies.rsop.EventLogSetting

{ log-name } = get-args <[ log-name ]>

if log-name is void => fail "Missing log-name argument."

retention-days = get-eventlog-retention-days log-name
stdout "Event Log #log-name retention days: #retention-days"

```
