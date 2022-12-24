--[[============================================================================
Renoise Scripting Reference and HOWTOs - Introduction
============================================================================]]--

Welcome to the Renoise scripting Guide. In all the various "Documention" files,
we will give you an overview on how to write tools for Renoise; how to debug
them, what's possible to "script", what's not, and much more. Please read this
introduction carefully to get an idea on how to get started, and to avoid common
pitfalls and FAQs.

---

## -- Scripting Development Tools in Renoise

By default Renoise has all scripting utilities hidden; to keep things as easy as
possible for those who don't want to mess around with code. If you want to write
scripts, then the first thing you have to do is enable the hidden development
tools that are built into Renoise. This can be done by:

- Launching the Renoise executable with the argument "--scripting-dev"

- Opening Renoise's config.xml file from the preferences folder, and setting the
  <ShowScriptingDevelopmentTools> property to "true". This way, you don't have
  to pass the above mentioned argument every time you launch Renoise.

Enabling scripting will add a new main menu entry "Tools" (or add new
entries there if it already exists).

In the "Tools" menu you will find:

- **Reload All Tools:** This will force a reload of all installed and running
  scripting tools. This can be handy when adding new tools by hand or when
  changing them.

- **Scripting Console & Editor:** This is the main developing scripting tool.
  It allows you to:

  - Evaluate scripts or commands in realtime with a terminal (command-line)
  - Watch any script's output (all "print"s and errors will be redirected here)
  - Create, view and edit Lua, text, and XML files that will make up tools
    for Renoise. More about this later...

- Show **Example Tools** that target script developers.

---

## -- What can be scripted, what can't? What's this scripting all about?

Right now (in this Renoise release), you can make use of scripts in the
following places:

- Run scripts and commands via a terminal in realtime using the
  "Scripting Console & Editor".

- Create tools: Add new and custom functionality to Renoise. Tools are small
  file bundles with Lua script(s) and a description file (manifest.xml) that
  make use of the Renoise API. Tools can be distributed and installed via
  drag and drop (by bundling them and hiding the code). This way, not only
  developers can use scripts, but also users who don't want to mess around with
  technical details. We'll describe these types bundles later on...

  Some examples of what you can do with Renoise Tools:

  - New context menu entries and keyboard shortcuts. Think "My Improved Pattern
    Jump", "My Bypass all DSP Devices in Track", "My Generate Chip Sound
    Sample" commands, and so on.

  - Custom graphical user interface elements with the look and feel of Renoise
    itself. Perfectly integrate your tools into Renoise, and make them easy to
    use for other users.

  - Manipulate Renoise's main window or song (patterns, tracks, instruments,
    anything that makes up a song). Generate, filter, or process song data in
    any way you can think of. E.g. for algorithmic composition, instrument
    creation, automation, etc. The sky is the limit.

  - Nibbles ;)

- MIDI controller scripting: Create bidirectional MIDI or OSC implementations
  for any controller hardware:

  For example, make your Launchpad or Monome behave exactly how you want them
  to, and share your settings with others. Tools like these can be a simple auto
  mapping of your MIDI controller, like plug & play support for Mackie Control,
  Behringer MIDI Mixers, and so on.

  To make this easier, Renoise offers a tool called "Duplex" which already has
  support for several MIDI/OSC controllers. Duplex is a very flexible,
  object-oriented approach to handling MIDI controllers in Renoise, and also
  offers virtual UIs for the MIDI controllers that are supported by Duplex.
  This way you can virtually test and use such controllers in Renoise without
  even owning them. ;)

  NB: You don't have to use Duplex to write MIDI/OSC controller scripts in
  Renoise, but it is a nice (and supported) framework that makes this type of
  development easier.

- Create, configure, or override Renoise's default MIDI/OSC bindings:
  Renoise has a default set of MIDI mappings that can be assigned manually by
  the user. These can be inherited, extended and tweaked to fit your needs.
  Renoise also has a default OSC implementation which can tweaked and overriden
  to do "your stuff."

What's _NOT_ possible with Renoise tools:

- Change Renoise's existing behaviour. Like, you can't make all C-4s in the
  pattern editor yellow instead of white. You can write your own pattern
  editor, but not change the existing one.

- Realtime access. Except for OSC and MIDI IO, you can't write scripts that
  run in the audio player. In other words, you can not script new realtime
  DSPs - yet. But you can, for example, write a tool that creates samples or
  manipulates existing samples. This limitation might change in the future.
  For now you can make a VST, AudioUnit, or LADSPA/DSSI plug-in.

---

## -- Renoise Lua API Overview

The XXX.API files in this documentation folder will list all available Lua
functions and classes that can be accessed from scripts in Renoise.
If you are familiar with Renoise, the names of the classes, functions and
properties should be self explanitory.

Here is a small overview of what the API exposes:

**Renoise.API**  
Renoise API version number and some global accessors like "song", "app" are here.

**Renoise.Application.API**  
Access to the main Renoise application and window, main user interface.

**Renoise.Song.API**  
Access to the song and all its components (instruments, samples, tracks...)

**Renoise.Document.API**  
Generic "observer pattern" document creation and access, used by the
song/app and to create persistent data (preferences, presets).

**Renoise.ScriptingTool.API**  
Available to XRNX tools only: Interact with Renoise; create menus, keybindings.

**Renoise.Socket.API**  
Inter-process and network communication functions and classes.

**Renoise.OSC.API**  
Tools to generate and receive OSC messages, bundles over the network.

**Renoise.Midi.API**  
"Raw" MIDI device interaction (send, receive MIDI messages from any devices.)

A note about the general API design:

- Whatever you do with the API, you should never be able to fatally crash
  Renoise. If you manage to do this, then please file a bug report in our forums
  so we can fix it. All errors, as stupid they might be, should always result in
  a clean error message from Lua.

- The Renoise Lua API also allows global File IO and external program execution
  (via os.execute()) which can obviously be hazardous. Please be careful with
  these, as you would with programming in general...

Some notes about the documentation, and a couple of tips:

- All classes, functions in the API, are nested in the namespace (Lua table)
  "renoise". E.g: to get the application object, you will have to type
  "renoise.app()"

- The API is object-oriented, and thus split into classes. The references
  will first note the class name (e.g. 'renoise.Application'), then list its
  Constants, Properties, Functions and Operators.
  All properties and functions are always listed with their full path to make
  it clear where they belong and how to access them.

- Return values (or arguments / types of properties) are listed in brackets.
  "-> [string]" means that a string is returned. When no brackets are listed,
  the function will not return anything.

- Nearly all functions are actually "methods", so you have to invoke them
  via the colon operator ":" E.g. 'renoise.app():show_status("Status Message")'
  If you're new to Lua, this takes a while to get used to. Don't worry, it'll
  make sense sooner or later. ;)

- Properties are syntactic sugar for get/set functions. "song().comments"
  will invoke a function which returns "comments". But not all properties
  have setters, and thus can only be used as read-only "getters". Those are
  marked as "[read-only, type]".
  Again mind the colon; which you don't need when accessing properties!

- All exposed "objects" are read-only (you can not add new fields, properties).
  In contrast, the "classes" are not. This means you can extend the API classes
  with your own helper functions, if needed, but can not add new properties to
  objects. Objects, like for example the result of "song()", are read-only to
  make it easier to catch typos. `song().transport.bmp = 80` will fire an error,
  because there is no such property 'bmp.' You probably meant
  `song().transport.bpm = 80` here. If you need to store data somewhere,
  do it in your own tables, objects instead of using the Renoise API objects.

- "some_property, \_observable" means, that there is also an observer object
  available for the property. An observable object allows you to attach
  notifiers (global functions or methods) that will be called as soon as a
  value has changed. Please see Renoise.Document.API for more info about
  observables and related classes.

  A small example using bpm:

        renoise.song().transport.bpm_observable:add_notifier(function()
          print("bpm changed")
        end)

        -- will print "bpm changed", but only if the bpm was not 120 before
        renoise.song().transport.bpm = 120

  The above notifier is called when anything changes the bpm, including your
  script, other scripts, or anything else in Renoise (you've automated the
  BPM in the song, entered a new BPM value in Renoise's GUI, whatever...)

  Lists like "renoise.song().tracks[]" can also have notifiers. But these
  will only fire when the list layout has changed: an element was added,
  removed or elements in the list changed their order. They will not fire when
  the list values changed. Attach notifiers to the list elements to get such
  notifications.

- Can't remember what the name of function XYZ was? In the scripting terminal
  you can list all methods/properties of API objects (or your own class objects)
  via the global function `oprint(some_object)` - e.g. `oprint(renoise.song())`.
  To dump the renoise module/class layout, use `rprint(renoise)`.

---

## -- Creating Renoise Tools

- Developing XRNX tools:
  As previously mentioned, Renoise tools are file bundles with an XRNX
  extension. Tools have the following layout:

  - /some.bundle.id.xrnx/
  - manifest.xml -> XML file with information about the tool (author, id...)
  - main.lua -> entry point: loaded by Renoise to execute the tool

  You can import other Lua files into "main.lua" via Lua's "require" function
  if appropriate, and also include resource files (icons, bitmaps, text files,
  or executables) into your bundles as needed.

  For a detailed description of the bundle layout and the main.lua,
  manifest.lua specifications, have a look at the "com.renoise.Example.xrnx"
  tool please.

- Distributing XRNX tools:
  To share your tools with others, you can create Zip files out of your
  bundles, which can then simply be dragged and dropped into Renoise by the
  user.
  To do so, zip all the bundle's content (the !content!, not the bundle folder
  itself), and rename this Zip file to "SomeName.xrnx". Renoise will accept such
  XRNX zips as drag and drop targets, copy, install and activate the tool
  automatically.

---

## -- MIDI Controller Scripting with Duplex

If you want to add support for your MIDI controller into Duplex, or help extend
the Duplex framework, have a look at the Duplex XRNX tool.

In the XRNX bundle you'll find some information about the Duplex API and
how to create new controller mappings.

The Duplex code can also be viewed online in the XRNX repository at:
<https://github.com/renoise/xrnx/tree/master/Tools/com.renoise.Duplex.xrnx>

More information can be found in Duplex manual, available here:
<https://github.com/renoise/xrnx/blob/master/Tools/com.renoise.Duplex.xrnx/Docs/GettingStarted.md>

---

## -- Debugging Renoise Scripts

If tracing/debugging in the console with print, oprint and rprint isn't enough,
you can try attaching a command-line based debugger to your scripts. Have a look
at the Debugging document for more information and a small tutorial.

-- Enjoy extending, customizing and automating Renoise ;)

--[[============================================================================
Renoise Script Debugging HowTo
============================================================================]]--

In addition to the usual print & trace stuff via the Renoise scripting console
(all 'print's will be dumped there), Renoise offers a simple command-line
debugger. This debugger can even be used to debug scripts remotely; scripts
running on other computers.

Please read the INTRODUCTION first to get an overview about the complete
API, and scripting for Renoise in general...

--==============================================================================
-- Remdebug
--==============================================================================

Remdebug is a command-line based remote debugger for Lua, which is included with
Renoise.

---

## -- Prerequisites

To use the debugger you will need:

- Renoise's "remdebug" module, which can be found in "Scripts/Libraries/remdebug"
  (no installation required - included in Renoise)

- Lua support on your system's command-line with the Lua "socket" module
  See http://w3.impa.br/~diego/software/luasocket/

---

## -- Overview

The debugger will be controlled via a command-line Lua interpreter, outside
of Renoise via the remdebug/controller.lua script. To start a local debug
session from within Renoise you can use the function "debug.start()":

    -- Opens a debugger controller in a new terminal/cmd window and
    -- attaches the debugger to this script. Immediately breaks execution.
    debug.start()

You can add this anywhere in any script that runs in Renoise. This will
work in a tool's main.lua main() body, just like a local function that you
include. It also works in the TestPad.lua script that is used in Renoise's
Scripting Editor.

---

## -- Step By Step Guide

Let's debug the following small test script, paste into
RENOISE_PREFERENCES/Scripts/TestPad.lua:

    debug.start()

    local function sum(a, b)
      return a + b
    end

    local c = sum(1, 2)
    print(c)

    debug.stop()

- Launch Renoise's scripting editor, open "TestPad.lua", and hit the "Execute"
  button to run the script.

  If Lua is correctly installed on your system, and remdebug was found, Renoise
  should be frozen now, with a terminal window opened showing something like:

        > "Lua Remote Debugger"
        > "Paused at file RENOISE_PREFERENCES_FOLDER/Scripts/TestPad.lua line 5"
        >
        > 1    debug.start()
        > 2
        > 3    local function sum(a, b)
        > 4      return a + b
        > 5*** end
        > 6
        > 7    local c = sum(1, 2)
        > 8    print(c)
        > 9
        > 10   debug.stop()
        >
        >>

- To step through the code, you can use the "s" and "n" commands in the terminal.
  Let's do so by entering "s" (Return) until we've reached line 8. Anything you
  type into the debugger, which is not a debugger command, will get evaluated in
  your running script as an expression. So let's try this by entering: `c=99`

- Then step over the line by entering "n" (Return) to evaluate the "print(c)"
  on line 9 in the script. You should see a "99" dumped out. To watch the value
  again, enter for example a `print(c)`. You should again see a "99" dumped out.

You can also set break and watchpoints in the debugger. Type 'help' in the
terminal to get more info about this. Those who are familiar with gdb on the
command-line may be able to quickly get up to speed when using the most common
shortcuts (c,b,q, and so on...).

Please note that although "debug.stop()" is not necessary (you can
simply quit the controller at any time to exit), its recommended and will
be more comfortable when running a session over and over again.

---

## -- Remote and Lua Editor debugging

Renoise's remdebug is fully compatible with the original remdebug controller
from the kepler project. This means you can, in theory, also use debugger GUIs
that use the original remdebug, like Lua Eclipse or SciTE for Lua.

However, this is often a PITA to setup and configure, and might not be
worth the trouble. Try at your own risk...

The debugger can also be used to remote debug scripts, scripts running on other
computers. To do so, use remdebug.engine.start/stop instead of "debug".
debug.start/stop is just a shortcut to remdebug.session.start/stop.

"remdebug.engine.start" will only attach the debugger to your script and break
execution. You then have to run the debugger controller manually on another
computer. To do so, launch the remdebug.controller.lua file manually in a
terminal:

- First we start the debugger controller. To do so, open a command-line on your
  system and invoke the remdebug/controller.lua script. You should see
  something like:

        lua RENOISE_RESOURCE_FOLDER/Scripts/Libraries/remdebug/controller.lua
        "Lua Remote Debugger"
        "Run the program you wish to debug with 'remdebug.engine.start()' now"

- Now you can connect to this controller by running a script with
  `remdebug.engine.start()`, configured to find the controller on another
  machine (or the same one.)

        require "remdebug.engine"
        -- default config is "localhost" on port 8171
        remdebug.engine.configure { host = "some_host", port = 1234 }
        remdebug.engine.start()

--==============================================================================
-- Autoreloading Tool Scripts
--==============================================================================

When working with Renoise's Scripting Editor, saving a script will
automatically reload the tool that belongs to the file. This way you can simply
change your files and immediately see/test the changes.
When changing any files that are part of the "Libraries" folder, all scripts
will get reloaded.

When working with an external text editor, you can enable the following debug
option somewhere in the tool's main.lua file:

    _AUTO_RELOAD_DEBUG = function()
      -- do tests like showing a dialog, prompts whatever, or simply do nothing
    end

As soon as you save your script outside of Renoise, and then focus Renoise again
(alt-tab to Renoise, for example), your script will instantly get reloaded and
the notifier is called.

If you don't need a notifier to be called each time the script reloads, you
can also simply set \_AUTO_RELOAD_DEBUG to true:

    _AUTO_RELOAD_DEBUG = true

--[[============================================================================
Renoise Scripting Editor And Terminal
============================================================================]]--

The built-in Script Editor and Terminal can be opened by clicking "Scripting
Terminal & Editor..." in the "Tools" menu. It allows you to:

- Create, view and edit Lua, text, and XML files.

- Evaluate scripts or commands in realtime using the Terminal.

- Watch any scripts output in the Terminal. For example:
  all "print"s and errors from scripts will be redirected here

---

## -- Browser Shortcuts

Note: 'Command' below is the _Control_ key on Windows & Linux, _Command_ on OSX.

- 'Command + E' Switch to Editor
- 'Command + N' Create a new File
- 'Command + O' Open an existing File
- 'Command + T' Switch to Terminal

---

## -- Editor Shortcuts

- 'Command + A' Select all
- 'Command + B' Switch to Browser
- 'Command + C' Copy
- 'Command + D' Delete
- 'Command + E' Set Find string from current selection
- 'Command + F' Open Find Dialog
- 'Command + F3' Find Next under Cursor or Selection
- 'Command + F4' Close current tab
- 'Command + G' Find Next
- 'Command + H' Replace Next
- 'Command + L' Jump to Line
- 'Command + N' Create a new File
- 'Command + O' Open an existing File
- 'Command + P' Paste
- 'Command + R' Save and Run the current Tabs File
- 'Command + S' Save current File (Tool Scripts will automatically reload)
- 'Command + Shift + F4' Close all except current Tab
- 'Command + Shift + S' Save all open files
- 'Command + Shift + Tab' Switch to Previous Tab
- 'Command + Shift + W' Close all except current Tab
- 'Command + T' Switch to Terminal
- 'Command + Tab' Switch to Next Tab
- 'Command + W' Close current tab
- 'Command + X' Cut
- 'Command + Y' Redo ('Command + Shift + Z' on OSX, LINUX)
- 'Command + Z' Undo
- 'F3' Find Next
- 'Shift + Tab' Unindent Selection
- 'Tab' Indent Selection

---

## -- Terminal Shortcuts

- 'Arrow Down' Next Command
- 'Arrow Up' Previous Command
- 'Command + B' Switch to Browser
- 'Command + C' Copy Selection \_in Output
- 'Command + E' Switch to Editor
- 'Command + K' Clear Output
- 'Command + L' Clear Output
- 'Command + N' Create a new File
- 'Command + O' Open an existing File

---

## -- Tips & Tricks

- To enter multiple lines in the terminal, end a line with a \
  The terminal will then prompt for another line until you hit enter twice

- `oprint(some_object)` prints out info about a Lua class object:
  try for example `oprint(renoise.song())` to see all properties
  and methods for song(). To list all available modules, try `rprint(renoise)`
  or `rprint(_G)`

- Take a look at the example tools in the 'Resource Scripts' node on the
  left for a detailed description of a tool script's layout

- If you just want to test out some code without writing a 'tool', create a new
  script file in the 'Scripts' folder and not in the 'Scripts/Tools' folder.
  Such Scripts can then be launched by hitting the 'Run Script' button or
  via 'Command + R'. A default file called 'TestPad.lua' should already
  be present which you can use for testing.

- The full Renoise API reference is included in the left tree view
  as well, in case you want to lookup something without leaving Renoise

--[[============================================================================
Lua Standard Library and Extensions
============================================================================]]--

--[[

This is a reference for standard global Lua functions and tools that were
added/changed by Renoise.

All standard Lua libraries are included in Renoise as well. You can find the
full reference here: <http://www.lua.org/manual/5.1/manual.html#5>

Do not try to execute this file. It uses a .lua extension for markup only.

]]--

---

## -- globals

-------- Added

-- An iterator like ipairs, but in reverse order
-- > examples: t = {"a", "b", "c"}  
-- > for k,v in ripairs(t) do print(k, v) end -> "3 c, 2 b, 1 a"
ripairs(table) -> [iterator function]

-- Return a string which lists properties and methods of class objects
objinfo(class_object) -> [string]

-- Recursively dumps a table and all its members to the std out (console)
rprint(table)

-- Dumps properties and methods of class objects (like renoise.app())
oprint(table)

-------- Changed

-- Also returns a class object's type name. For all other types the standard
-- Lua type function is used
-- > examples: class "MyClass"; function MyClass:\_\_init() end  
-- > print(type(MyClass)) -> "MyClass class"  
-- > print(type(MyClass())) -> "MyClass"
type(class_object or class or anything else) -> [string]

-- Also compares object identities of Renoise API class objects:
-- > examples:
-- > print(rawequal(renoise.app(), renoise.app())) --> true  
-- > print(rawequal(renoise.song().track[1],
-- > renoise.song().track[1]) --> true  
-- > print(rawequal(renoise.song().track[1],
-- > renoise.song().track[2]) --> false
rawequal(obj1, obj2) -> [boolean]

---

## -- debug

------- Added

-- Shortcut to remdebug.session.start(), which starts a debug session:
-- launches the debugger controller and breaks script execution. See
-- "Debugging.txt" in the documentation root folder for more info.
debug.start()

-- Shortcut to remdebug.session.stop: stops a running debug session
debug.stop()

---

## -- table

------- Added

-- Create a new, or convert an exiting table to an object that uses the global
-- 'table.XXX' functions as methods, just like strings in Lua do.
-- > examples: t = table.create(); t:insert("a"); rprint(t) -> [1] = a;  
-- t = table.create{1,2,3}; print(t:concat("|")); -> "1|2|3";
table.create([t]) -> [table]

-- Returns true when the table is empty, else false and will also work
-- for non indexed tables
-- > examples: t = {}; print(table.is_empty(t)); -> true;  
-- > t = {66}; print(table.is_empty(t)); -> false;  
-- > t = {["a"] = 1}; print(table.is_empty(t)); -> false;
table.is_empty(t) -> [boolean]

-- Count the number of items of a table, also works for non index
-- based tables (using pairs).
-- > examples: t = {["a"]=1, ["b"]=1}; print(table.count(t)) -> 2
table.count(t) -> [number]

-- Find first match of 'value' in the given table, starting from element
-- number 'start_index'. Returns the first !key! that matches the value or nil
-- > examples: t = {"a", "b"}; table.find(t, "a") -> 1;  
-- > t = {a=1, b=2}; table.find(t, 2) -> "b"  
-- > t = {"a", "b", "a"}; table.find(t, "a", 2) -> "3"  
-- > t = {"a", "b"}; table.find(t, "c") -> nil
table.find(t, value [,start_index]) -> [key or nil]

-- Return an indexed table of all keys that are used in the table
-- > examples: t = {a="aa", b="bb"}; rprint(table.keys(t)); -> "a", "b"  
-- > t = {"a", "b"}; rprint(table.keys(t)); -> 1, 2
table.keys(t) -> [table]

-- Return an indexed table of all values that are used in the table
-- > examples: t = {a="aa", b="bb"}; rprint(table.values(t)); -> "aa", "bb"  
-- > t = {"a", "b"}; rprint(table.values(t)); -> "a", "b"
table.values(t) -> [table]

-- Copy the metatable and all first level elements of the given table into a
-- new table. Use table.rcopy to do a recursive copy of all elements
table.copy(t) -> [table]

-- Deeply copy the metatable and all elements of the given table recursively
-- into a new table - create a clone with unique references.
table.rcopy(t) -> [table]

-- Recursively clears and removes all table elements
table.clear(t)

---

## -- os

------- Added

-- Returns the platform the script is running on:
-- "WINDOWS", "MACINTOSH" or "LINUX"
os.platform() -> [string]

-- Returns the current working dir. Will always be the scripts directory
-- when executing a script from a file
os.currentdir() -> [string]

-- Returns a list of directory names (names, not full paths) for the given
-- parent directory. Passed directory must be valid, or an error will be thrown.
os.dirnames(path) -> [table of strings]

-- Returns a list file names (names, not full paths) for the given
-- parent directory. Second optional argument is a list of file extensions that
-- should be searched for, like {"_.wav", "_.txt"}. By default all files are
-- matched. The passed directory must be valid, or an error will be thrown.
os.filenames(path [, {file_extensions}]) -> [table of strings]

-- Creates a new directory. mkdir can only create one new sub directory at the
-- same time. If you need to create more than one sub dir, call mkdir multiple
-- times. Returns true if the operation was successful; in case of error, it
-- returns nil plus an error string.
os.mkdir(path) -> [boolean, error_string or nil]

-- Moves a file or a directory from path 'src' to 'dest'. Unlike 'os.rename'
-- this also supports moving a file from one file system to another one. Returns
-- true if the operation was successful; in case of error, it returns nil plus
-- an error string.
os.move(src, dest) -> [boolean, error_string or nil]

------- Changed

-- Replaced with a temp directory and name which renoise will clean up on exit
-- extension will be ".tmp" when not specified
os.tmpname([extension]) -> [string]

-- Replaced with a high precision timer (still expressed in milliseconds)
os.clock() -> [number]

-- Will not exit, but fire an error that os.exit() can not be called
os.exit()

---

## -- io

------- Added

-- Returns true when a file, folder or link at the given path and name exists
io.exists(filename) -> [boolean]

-- Returns a table with status info about the file, folder or link at the given
-- path and name, else nil the error and the error code is returned.
--
-- The returned valid stat table contains the following fields:
--
-- + dev, (number): device number of filesystem
-- + ino, (number): inode number
-- + mode, (number): unix styled file permissions
-- + type, (string): type ("file", "directory", "link", "socket",
-- "named pipe", "char device" or "block device")
-- + nlink, (number): number of (hard) links to the file
-- + uid, (number): numeric user ID of file's owner
-- + gid, (number): numeric group ID of file's owner
-- + rdev, (number): the device identifier (special files only)
-- + size, (number): total size of file, in bytes
-- + atime, (number): last access time in seconds since the epoch
-- + mtime, (number): last modify time in seconds since the epoch
-- + ctime, (number): inode change time (NOT creation time!) in seconds
io.stat(filename) -> [table or (nil, error, error no)]

-- Change permissions of a file, folder or link. mode is a unix permission
-- styled octal number (like 755 - WITHOUT a leading octal 0). Executable,
-- group and others flags are ignored on windows and won't fire errors
io.chmod(filename, mode) -> [true or (nil, error, error no)]

------- Changed

-- All io functions use UTF8 as encoding for the file names and paths. UTF8
-- is used for LUA in the whole API as default string encoding...

---

## -- math

------- Added

-- Converts a linear value to a db value. db values will be clipped to
-- math.infdb
-- > example: print(math.lin2db(1.0)) -> 0  
-- > print(math.lin2db(0.0)) -> -200 (math.infdb)
math.lin2db(number) -> [number]

-- Converts a dB value to a linear value
-- > example: print(math.db2lin(math.infdb)) -> 0  
-- > print(math.db2lin(6.0)) -> 1.9952623149689
math.db2lin(number) -> [number]

-- Converts a dB value to a normalized linear fader value between 0-1 within
-- the given dB range.
-- > example: print(math.db2fader(-96, 0, 1)) -> 0  
-- > print(math.db2fader(-48, 6, 0)) -> 0.73879611492157
math.db2fader(min_dB, max_dB, dB_to_convert)

-- Converts a normalized linear mixer fader value to a db value within
-- the given dB range.
-- > example: print(math.fader2db(-96, 0, 1)) -> 0  
-- > print(math.fader2db(-96, 0, 0)) -> -96
math.fader2db(min_dB, max_dB, fader_value)

-- db values at and below this value will be treated as silent (linearly 0)
math.infdb -> [-200]

---

## -- bit (added)

-- Integer, Bit Operations, provided by <http://bitop.luajit.org/>
-- Take a look at <http://bitop.luajit.org/api.html> for the complete reference
-- and examples please...

-- Normalizes a number to the numeric range for bit operations and returns it.
-- This function is usually not needed since all bit operations already
-- normalize all of their input arguments.
bit.tobit(x) -> [number]

-- Converts its first argument to a hex string. The number of hex digits is
-- given by the absolute value of the optional second argument. Positive
-- numbers between 1 and 8 generate lowercase hex digits. Negative numbers
-- generate uppercase hex digits. Only the least-significant 4\*|n| bits are
-- used. The default is to generate 8 lowercase hex digits.
bit.tohex(x [,n]) -> [string]

-- Returns the bitwise not of its argument.
bit.bnot(x) -> [number]

-- Returns either the bitwise or, bitwise and, or bitwise xor of all of its
-- arguments. Note that more than two arguments are allowed.
bit.bor(x1 [,x2...]) -> [number]
bit.band(x1 [,x2...]) -> [number]
bit.bxor(x1 [,x2...]) -> [number]

-- Returns either the bitwise logical left-shift, bitwise logical right-shift,
-- or bitwise arithmetic right-shift of its first argument by the number of
-- bits given by the second argument.
bit.lshift(x, n) -> [number]
bit.rshift(x, n) -> [number]
bit.arshift(x, n) -> [number]

-- Returns either the bitwise left rotation, or bitwise right rotation of its
-- first argument by the number of bits given by the second argument. Bits
-- shifted out on one side are shifted back in on the other side.
bit.rol(x, n) -> [number]
bit.ror(x, n) -> [number]

-- Swaps the bytes of its argument and returns it. This can be used to convert
-- little-endian 32 bit numbers to big-endian 32 bit numbers or vice versa.
bit.bswap(x) -> [number]

--[[============================================================================
Renoise Application API Reference
============================================================================]]--

--[[

This reference lists the content of the main "renoise" namespace. All Renoise
related functions and classes are nested in this namespace.

Please read the INTRODUCTION first to get an overview about the complete
API, and scripting for Renoise in general...

Do not try to execute this file. It uses a .lua extension for markup only.

]]--

---

## -- renoise

-------- Constants

-- Currently 6.1. Any changes in the API which are not backwards compatible,
-- will increase the internal API's major version number (e.g. from 1.4 -> 2.0).
-- All other backwards compatible changes, like new functionality, new functions
-- and classes which do not break existing scripts, will increase only the minor
-- version number (e.g. 1.0 -> 1.1).
renoise.API_VERSION -> [number]

-- Renoise Version "Major.Minor.Revision[ AlphaBetaRcVersion][ demo]"
renoise.RENOISE_VERSION -> [string]

-------- Functions

renoise.app() -> [renoise.Application object]
renoise.song() -> [renoise.Song object]
renoise.tool() -> [renoise.ScriptingTool object]

-- Not much else going on here...
-- for renoise.Application, see Renoise.Application.API,
-- for renoise.Song, see Renoise.Song.API,
-- for renoise.ScriptingTool, see Renoise.ScriptingTool.API,
-- and so on.

--[[============================================================================
Renoise Application API Reference
============================================================================]]--

--[[

This reference lists all available Lua functions and classes that control
the Renoise application. The Application is the Lua interface to Renoise's main
GUI and window (Application and ApplicationWindow).

Please read the INTRODUCTION first to get an overview about the complete
API, and scripting for Renoise in general...

Do not try to execute this file. It uses a .lua extension for markup only.

]]--

---

## -- renoise

-------- Functions

renoise.app()
-> [renoise.Application object]

---

## -- renoise.Application

-------- Functions

-- Shows an info message dialog to the user.
renoise.app():show_message(message)

-- Shows an error dialog to the user.
renoise.app():show_error(message)

-- Shows a warning dialog to the user.
renoise.app():show_warning(message)

-- Shows a message in Renoise's status bar to the user.
renoise.app():show_status(message)

-- Opens a modal dialog with a title, text and custom button labels.
renoise.app():show_prompt(title, message, {button_labels})
-> [pressed_button_label]

-- Opens a modal dialog with a title, custom content and custom button labels.
-- See Renoise.ViewBuilder.API for more info. key_handler is an optional
-- notifier function for keyboard events in the dialog. key_handler_options is
-- an optional table with the fields
-- { "send_key_repeat": true/false, "send_key_release": true/false }
-- when not specified, "send_key_repeat" = true and "send_key_release" = false
renoise.app():show_custom_prompt(title, content_view,
{button_labels} [, key_handler, key_handler_options])
-> [pressed_button_label]

-- Shows a non modal dialog (a floating tool window) with custom content.
-- Again see Renoise.ViewBuilder.API for more info about custom views.
-- key_handler is an optional notifier function for keyboard events that are
-- received by the dialog. key_handler_options is an optional table with the
-- fields { "send_key_repeat": true/false, "send_key_release": true/false }
renoise.app():show_custom_dialog(title, content_view
[, key_handler, key_handler_options])
-> [renoise.Dialog object]

-- Opens a modal dialog to query an existing directory from the user.
renoise.app():prompt_for_path(dialog_title)
-> [valid path or empty string]

-- Opens a modal dialog to query a filename and path to read from a file.
-- The given extension(s) should be something like {"wav", "aiff"
-- or "\*" (any file) }
renoise.app():prompt_for_filename_to_read({file_extensions}, dialog_title)
-> [filename or empty string]

-- Same as 'prompt_for_filename_to_read' but allows the user to select
-- more than one file.
renoise.app():prompt_for_multiple_filenames_to_read({file_extensions}, dialog_title)
-> [list of filenames or empty list]

-- Open a modal dialog to get a filename and path for writing.
-- When an existing file is selected, the dialog will ask whether or not to
-- overwrite it, so you don't have to take care of this on your own.
renoise.app():prompt_for_filename_to_write(file_extension, dialog_title)
-> [filename or empty string]

-- Opens the default internet browser with the given URL. The URL can also be
-- a file that browsers can open (like xml, html files...).
renoise.app():open_url(url)
-- Opens the default file browser (explorer, finder...) with the given path.
renoise.app():open_path(file_path)

-- Install, update or uninstall a tool. Any errors are shown to the user
-- during (un)installation. Installing an already existing tool will upgrade
-- the tool without confirmation. Upgraded tools will automatically be
-- re-enabled, if necessary.
renoise.app().install_tool(file_path_to_xrnx)
renoise.app().uninstall_tool(file_path_to_xrnx)

-- Create a new song document (will ask the user to save changes if needed).
-- The song is not created immediately, but soon after the call was made and
-- the user did not aborted the operation. In order to continue execution
-- with the new song, attach a notifier to 'app_new_document_observable'
-- See renoise.ScriptingTool.API.lua for more info.
renoise.app():new_song()
renoise.app():new_song_no_template()

-- Load a new song document from the given filename (will ask to save
-- changes if needed, any errors are shown to the user).
-- Just like new_song(), the song is not loaded immediately, but soon after
-- the call was made. See 'renoise.app():new_song()' for details.
renoise.app():load_song(filename)
-- Load a file into the currently selected components (selected instrument,
-- track, sampl, ...) of the song. If no component is selected it will be
-- created when possible. Any errors during the export are shown to the user.
-- returns success.
renoise.app():load_track_device_chain(filename)
-> [boolean]
renoise.app():load_track_device_preset(filename)
-> [boolean]
renoise.app():load_instrument(filename)
-> [boolean]
renoise.app():load_instrument_multi_sample(filename)
-> [boolean]
renoise.app():load_instrument_device_chain(filename)
-> [boolean]
renoise.app():load_instrument_device_preset(filename)
-> [boolean]
renoise.app():load_instrument_modulation_set(filename)
-> [boolean]
renoise.app():load_instrument_phrase(filename)
-> [boolean]
renoise.app():load_instrument_sample(filename)
-> [boolean]
renoise.app():load_theme(filename)

-- Quicksave or save the current song under a new name. Any errors
-- during the export are shown to the user.
renoise.app():save_song()
renoise.app():save_song_as(filename)
-- Save a currently selected components of the song. Any errors
-- during the export are shown to the user. returns success
renoise.app():save_track_device_chain(filename)
-> [boolean]
renoise.app():save_instrument(filename)
-> [boolean]
renoise.app():save_instrument_multi_sample(filename)
-> [boolean]
renoise.app():save_instrument_device_chain(filename)
-> [boolean]
renoise.app():save_instrument_modulation_set(filename)
-> [boolean]
renoise.app():save_instrument_phrase(filename)
-> [boolean]
renoise.app():save_instrument_sample(filename)
-> [boolean]
renoise.app():save_theme(filename)

-------- Properties

-- Access to the application's full log filename and path. Will already be opened
-- for writing, but you nevertheless should be able to read from it.
renoise.app().log_filename
-> [read-only, string]

-- Get the apps main document, the song. The global "renoise.song()" function
-- is, in fact, a shortcut to this property.
renoise.app().current_song
-> [read-only, renoise.Song object]

-- List of recently loaded/saved song files.
renoise.app().recently_loaded_song_files
-> [read-only, array of strings, filenames]
renoise.app().recently_saved_song_files
-> [read-only, array of strings, filenames]

-- Returns information about all currently installed tools.
renoise.app().installed_tools
-> [read-only, array of tables with tool info]

-- Access keyboard modifier states.
renoise.app().key_modifier_states
-> [read-only, table with all modifier names and their states]

-- Access to the application's window.
renoise.app().window
-> [read-only, renoise.ApplicationWindow object]

-- Get or set globally used clipboard "slots" in the application.
renoise.app().active_clipboard_index
-> [number, 1-4]

---

## -- renoise.ApplicationWindow

-------- Constants

renoise.ApplicationWindow.UPPER_FRAME_TRACK_SCOPES
renoise.ApplicationWindow.UPPER_FRAME_MASTER_SPECTRUM

renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR
renoise.ApplicationWindow.MIDDLE_FRAME_MIXER
renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_PHRASE_EDITOR
renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_KEYZONES
renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EDITOR
renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_MODULATION
renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EFFECTS
renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_PLUGIN_EDITOR
renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_MIDI_EDITOR

renoise.ApplicationWindow.LOWER_FRAME_TRACK_DSPS
renoise.ApplicationWindow.LOWER_FRAME_TRACK_AUTOMATION

renoise.ApplicationWindow.MIXER_FADER_TYPE_24DB
renoise.ApplicationWindow.MIXER_FADER_TYPE_48DB
renoise.ApplicationWindow.MIXER_FADER_TYPE_96DB
renoise.ApplicationWindow.MIXER_FADER_TYPE_LINEAR

-------- Functions

-- Expand the window over the entire screen, without hiding menu bars,
-- docks and so on.
renoise.app().window:maximize()

-- Minimize the window to the dock or taskbar, depending on the OS.
renoise.app().window:minimize()

-- "un-maximize" or "un-minimize" the window, or just bring it to front.
renoise.app().window:restore()

-- Select/enable one of the global view presets, to memorize/restore
-- the user interface 'layout'.
renoise.app().window:select_preset(preset_index)

-------- Properties

-- Get/set if the application is running fullscreen.
renoise.app().window.fullscreen
-> [boolean]

-- Window status flags.
renoise.app().window.is_maximized
-> [read-only, boolean]
renoise.app().window.is_minimized
-> [read-only, boolean]

-- When true, the middle frame views (like the pattern editor) will
-- stay focused unless alt or middle mouse is clicked.
renoise.app().window.lock_keyboard_focus
-> [boolean]

-- Dialog for recording new samples, floating above the main window.
renoise.app().window.sample_record_dialog_is_visible
-> [boolean]

-- Diskbrowser Panel.
renoise.app().window.disk_browser_is_visible, \_observable
-> [boolean]

-- InstrumentBox.
renoise.app().window.instrument_box_is_visible, \_observable
-> [boolean]

-- Instrument Editor detaching.
renoise.app().window.instrument_editor_is_detached, \_observable
-> [boolean]

-- Mixer View detaching.
renoise.app().window.mixer_view_is_detached, \_observable
-> [boolean]

-- Frame with the scopes/master spectrum...
renoise.app().window.upper_frame_is_visible, \_observable
-> [boolean]
renoise.app().window.active_upper_frame, \_observable
-> [enum = UPPER_FRAME]

-- Frame with the pattern editor, mixer...
renoise.app().window.active_middle_frame, \_observable
-> [enum = MIDDLE_FRAME]

-- Frame with the DSP chain view, automation, etc.
renoise.app().window.lower_frame_is_visible, \_observable
-> [boolean]
renoise.app().window.active_lower_frame, \_observable
-> [enum = LOWER_FRAME]

-- Pattern matrix, visible in pattern editor and mixer only...
renoise.app().window.pattern_matrix_is_visible, \_observable
-> [boolean]

-- Pattern advanced edit, visible in pattern editor only...
renoise.app().window.pattern_advanced_edit_is_visible, \_observable
-> [boolean]

-- Mixer views Pre/Post volume setting.
renoise.app().window.mixer_view_post_fx, \_observable
-> [boolean]

-- Mixer fader type setting.
renoise.app().window.mixer_fader_type, \_observable
-> [enum=MIXER_FADER_TYPE_XXX]

--[[============================================================================
Renoise Document API Reference
============================================================================]]--

--[[

The renoise.Document namespace covers all document related Renoise API
functions. This includes:

- Accessing existing Renoise document objects. The Renoise API uses these types
  of document structs, e.g. all "\_observables" found in the Renoise Lua API are
  renoise.Document.Observable objects

- Create new documents (e.g persistent options, presets for your tools)
  which can be loaded and saved as XML files by your scripts. These can also be
  bound to custom views, or "your own" document listeners
  -> see renoise.Document.create()

Please read the INTRODUCTION first to get an overview about the complete
API, and scripting for Renoise in general...

Do not try to execute this file. It uses a .lua extension for markup only.

-------- Observables

Documents and Views in the Renoise API are modelled after the observer pattern
(have a look at <http://en.wikipedia.org/wiki/Observer_pattern> if this is new
to you). This means, in order to track changes, a document is basically just a
set of raw data (booleans, numbers, lists, nested nodes) which anything can
attach notifier function (listeners) to. For example, a view in the Renoise
API is an Observer, which listens to observable values in Documents.

Attaching and removing notifiers can be done with the functions 'add_notifier',
'remove_notifier' from the Observable base class. These support multiple kinds
of callbacks, plain functions and methods (functions with a context). Please
see renoise.Document.Observable for more details. Here is a simple example:

    function bpm_changed()
      print(("something changed the BPM to %s"):format(
        renoise.song().transport.bpm))
    end

    renoise.song().transport.bpm_observable:add_notifier(bpm_changed)
    -- later on, maybe:
    renoise.song().transport.bpm_observable:remove_notifier(bpm_changed)

When adding notifiers to lists (like the track list in a song) an additional
context parameter is passed to your notifier function. This way you know what
happened to the list:

    function tracks_changed(notification)
      if (notification.type == "insert") then
        print(("new track was inserted at index: %d"):format(notification.index))

      elseif (notification.type == "remove") then
        print(("track got removed from index: %d"):format(notification.index))

      elseif (notification.type == "swap") then
        print(("track at index: %d and %d swapped their positions"):format(
          notification.index1, notification.index2))
      end
    end

    renoise.song().tracks_observable:add_notifier(tracks_changed)

If you only want to use the existing "\_observables" in the Renoise API,
then this is all you need to know. If you want to create your own documents,
read on.

-------- Overall API Design

All renoise.Document classes are wrappers for Renoise's internal document
classes. The Lua wrappers are not really "the Lua way" of solving
and expressing things. e.g: theres no support for mixed types in lists,
tuples at the moment.

The reason behind this limitation is to allow both worlds (Lua in scripts
and the internal C++ objects) to fully interact with each others: scripts
can use existing Renoise objects, Renoise documents can be extended with
Lua classes, and so on.

If all you need is a generic XML import/export (or JSON, or "insert trendy
format here") and you don't need an Observable mechanism for your values, then
you should look into using using a generic Lua table serializer instead.
See <http://lua-users.org/wiki/TableSerialization> to start.

Related to this, import of renoise.Documents from XML will NOT create new object
models from the source XML files, but will only assign existing corresponding
values in your document object (except for lists which are instantiated
dynamically). This means values which are not present in the original model
will silently be ignored during import. This behaviour is, most of the time, the
desired one. For example, when extending an already existing document format.
However, when dealing with unknown models or formats, you will need to research
other options.

-------- Document Basetypes, Building Blocks

Types that can be in used in renoise.Documents, things that can make up a
document are:

- ObservableBoolean/Number/String (wrappers for the "raw" Lua base types)
- ObservableBoolean/String/NumberList (wrappers of lists for the Lua base types)
- other document objects (create document trees)
- lists of document objects (dynamically sized lists of other document nodes)

ObservableBoolean/Number/String is a simple wrapper for the raw Lua base types.
Basically, it just stores the corresponding value (a boolean, number, or string)
and maintains a list of attached notifiers. Each Observable object is strongly
typed, can only hold a predefined Lua base type, defined when constructing the
property. Same is true for the basetype list wrappers: Lists can not contain
multiple objects of different types.

Lua's other fundamental type, the table, has no direct representation in the
Document API: You can either use strongly typed lists in order to get Lua
index based table alike behaviour, or use nested document nodes or lists
(documents in documents) to get an associative table alike layout/behaviour.

Except for the strong typing, ObservableBoolean/String/NumberList and
DocumentList will behave more or less like Lua tables with number based indices
(Arrays).

You can use the `#` operator or `[]` operators just like you do with tables, but
can also query all this info via list methods (:size(), :property(name), [...]).

-------- Creating Documents via "renoise.Document.create()" (models)

An empty document (node) object can be created with the function

> renoise.Document.create("MyDoc"){}

Such document objects can be extended with the document's "add_property"
function. Existing properties can also be removed again with the
"remove_property" function:

    -- creates an empty document, using "MyDoc" as the model name (a type name)
    local my_document = renoise.Document.create("MyDoc"){ }

    -- adds a number to the document with the initial value 1
    my_document:add_property("value1", 1)

    -- adds a string
    my_document:add_property("value2", "bla")

    -- create another document and adds it
    local node = renoise.Document.create("MySubDoc"){ }
    node:add_property("another_value", 1)

    -- add another already existing node
    my_document:add_property("nested_node", node)

    -- removes a previously added node
    my_document:remove_property(node)

    -- access properties
    local value1 = my_document.value1
    value1 = my_document:property("value1")

A more comfortable, and often more readable way of creating simple
document trees, structs, can be done by passing a table to the create()
function:

    my_document = renoise.Document.create("MyDoc") {
      age = 1,
      name = "bla", -- implicitly specify a property type
      is_valid = renoise.Document.ObservableBoolean(false), -- or explicitly
      age_list = {1, 2, 3},
      another_list = renoise.Document.ObservableNumberList(),
      sub_node = {
        sub_value1 = 2,
        sub_value2 = "bla2"
      }
    }

This will create a document node which is !modeled! after the the passed table.
The table is not used internally by the document after construction, and will
only be referenced to construct new instances. Also note that you need to assign
values for all passed table properties in order to automatically determine it's
type, or specify the types explicitly -> renoise.Document.ObservableXXX().

The passed name ("MyDoc" in the example above) is used to identify the document
when loading/saving it (loading a XML file which was saved with a different
model will fail) and to generally specify the "type".

Additionally, once "create" is called, you can use the specified model name to
create new instances. For example:

    -- create a new instance of "MyDoc"
    my_other_document = renoise.Document.instantiate("MyDoc")

-------- Creating Documents via inheritance (custom Doc classes)

As an alternative to "renoise.Document.create", you can also inherit from
renoise.Document.DocumentNode in order to create your own document classes.
This is especially recommended when dealing with more complex docs, because you
can also use additional methods to deal with your properties, the data.

Here is a simple example:

    class "MyDocument"(renoise.Document.DocumentNode)

      function MyDocument:__init()
        -- important! call super first
        renoise.Document.DocumentNode.__init(self)

        -- add properties to construct the document model
        self:add_property("age", 1)
        self:add_property("name", renoise.Document.ObservableString("value"))

        -- other doc renoise.Document.DocumentNode object
        self:add_property("sub_node", MySubNode())

        -- list of renoise.Document.DocumentNode objects
        self:add_property("doc_list", renoise.Document.DocumentList())

        -- or the create() way:
        self:add_properties {
          something = "else"
        }
      end

instantiating such document objects can be done, as previously stated, by
calling the constructor:

    my_document = MyDocument()
    -- do something with my_document, load/save, add/remove more properties

-------- Accessing Document Properties

Accessing "renoise.Document.DocumentNode" can be done more or less just like you
do with tables in Lua, except that if you want to get/set the value of some
property, you have to query the value explicitly. Using my_document from
the example above:

    -- this returns the !ObservableNumber object, not a number!
    local age_observable = my_document.age

    -- this sets the value of the object
    my_document.age.value = 2

    -- this accesses/prints the value of the object
    print(my_document.age.value)

    -- add notifiers
    my_document.age:add_notifier(function()
      print("something changed 'age'!")
    end)

    -- inserts a new entry to the list
    my_document.age_list:insert(22)

    -- queries the length of the list
    print(#my_document.age_list)

    -- access a list member
    local entry = my_document.age_list[1]

    -- list members are observables as well
    my_document.age_list[2].value = 33

For more details about document construction and notifiers, have a look
at the class docs below.

]]--

--==============================================================================
-- renoise.Document
--==============================================================================

-------- Construction

-- Create an empty DocumentNode or a DocumentNode that is modelled after the
-- passed table. See the general description in this file for more info about
-- creating documents. "model name" will be used to identify the documents type
-- when loading/saving. It also allows you to instantiate new document
-- objects (see renoise.Document.instantiate).
renoise.Document.create(model_name) {[table]}
-> [renoise.Document.DocumentNode object]

-- create a new instance of the given document model. model_name must have been
-- registered with renoise.Document.create before.
renoise.Document.instantiate(model_name)
-> [renoise.Document.DocumentNode object]

---

## -- renoise.Document.Serializable

-------- Functions

-- Serialize an object to a string.
serializable:to_string()
-> [string]

-- Assign the object's value from a string - when possible. Errors are
-- silently ignored.
serializable:from_string(string)

---

## -- renoise.Document.Observable

-------- Functions

-- Checks if the given function, method was already registered as notifier.
observable:has_notifier(function or (object, function) or (function, object))
-> [boolean]

-- Register a function or method as a notifier, which will be called as soon as
-- the observable's value changed.
observable:add_notifier(function or (object, function) or (function, object))

-- Unregister a previously registered notifier. When only passing an object to
-- remove_notifier, all notifier functions that match the given object will be
-- removed; a.k.a. all methods of the given object are removed. They will not
-- fire errors when none are attached.
observable:remove_notifier(function or (object, function) or
(function, object) or (object))

---

## -- renoise.Document.ObservableBang (inherits Observable)

-- Observable without a value which sends out notifications when "banging" it.

-------- Functions

-- fire a notification, calling all registered notifiers.
observable:bang()

---

## -- renoise.Document.ObservableBoolean/Number/String (inherits Observable, Serializable)

-- Observables which send out notifications on value changes.

-------- Properties

-- Read/write access to the value of an Observable.
observable.value
-> [boolean, number or string]

---

## -- renoise.Document.ObservableBoolean/String/NumberList (inherits Observable, Serializable)

-------- Operators

-- Query a list's size (item count).
#observable_list
-> [Number]

-- Access an observable item of the list by index (returns nil for non
-- existing items).
observable_list[number]
-> [renoise.Document.Observable object]

-------- Functions

-- Returns the number of entries of the list.
observable_list:size()
-> [number]

-- List item access (returns nil for non existing items).
observable_list:property(index)
-> [nil or an renoise.Document.Observable object]

-- Find a value in the list by comparing the list values with the passed
-- value. The first successful match is returned. When no match is found, nil
-- is returned.
observable_list:find([start_pos,] value)
-> [nil or number (the index)]

-- Insert a new item to the end of the list when no position is specified, or
-- at the specified position. Returns the newly created and inserted Observable.
observable_list:insert([pos,] value)
-> [inserted Observable object]

-- Removes an item (or the last one if no index is specified) from the list.
observable_list:remove([pos])

-- Swaps the positions of two items without adding/removing the items.
-- With a series of swaps you can move the item from/to any position.
observable_list:swap(pos1, pos2)

-------- Notifiers

--[[

Notifiers from renoise.Document.Observable are available for lists as well,
but will not broadcast changes made to the items, only changes to the
!list! layout.

This means you will get notified as soon as an item is added, removed or
changes its position, but not when an item's value has changed. If you are
interested in value changes, attach notifiers directly to the items and
not to the list...

List notifiers will also pass a table with information about what
happened to the list as the first argument to the notifier, example:

`function my_list_changed_notifier(notification)`

When a new element gets added, the "notification" is:

> { type = "insert",  
> index = index_where_element_got_added }

When a element gets removed, the "notification" is:

> { type = "remove",  
> index = index_where_element_got_removed_from }

When two entries swap their position, the "notification" is:

> { type = "swap",  
> index1 = index_swap_pos1,  
> index2 = index_swap_pos2 }

Please note that all notifications are fired !after! the list is
changed, so the removed object is no longer available at the index you get
back in the notification. Also, newly inserted objects will already be present
in the destination index, and so on...

See renoise.Document.Observable for more info about has/add/remove_notifier

]]--

observable_list:has_notifier(function or (object, function) or
(function, object)) -> [boolean]

observable_list:add_notifier(function or (object, function) or
(function, object))

observable_list:remove_notifier(function or (object, function) or
(function, object) or (object))

---

## -- renoise.Document.DocumentList

-------- Operators

-- Query a list's size (item count).
#doc_list
-> [Number]

-- Access a document item from the list by index (returns nil for non
-- existing items).
doc_list[number]
-> [renoise.Document.DocumentNode object]

-------- Functions

-- Returns the number of entries in the list.
doc_list:size()
-> [number]

-- List item access by index (returns nil for non existing items).
doc_list:property(index)
-> [nil or renoise.Document.DocumentNode object]

-- Insert a new item to the end of the list when no position is specified, or
-- at the specified position. Returns the inserted DocumentNode.
doc_list:insert([pos,] doc_object)
-> [inserted renoise.Document.DocumentNode object]

-- Removes an item (or the last one if no index is specified) from the list.
doc_list:remove([pos])

-- Swaps the positions of two items without adding/removing them.
-- With a series of swaps you can move the item from/to any position.
doc_list:swap(pos1, pos2)

-------- Notifiers

-- Notifiers behave exactly like renoise.Document.ObservableXXXLists. Please
-- have a look at those for more info.

doc_list:has_notifier(function or (object, function) or
(function, object)) -> [boolean]

doc_list:add_notifier(function or (object, function) or
(function, object))

doc_list:remove_notifier(function or (object, function) or
(function, object) or (object))

---

## -- renoise.Document.DocumentNode

-------- Operators

doc[property_name]
-> [nil or (Observable, ObservableList or DocumentNode, DocumentList object)]

-------- Functions

doc:has_property(property_name)
-> [boolean]

-- Access a property by name. Returns the property, or nil when there is no
-- such property.
doc:property(property_name)
-> [nil or (Observable, ObservableList or DocumentNode, DocumentList object)]

-- Add a new property. Name must be unique: overwriting already existing
-- properties with the same name is not allowed and will fire an error.
doc:add_property(name, boolean_value)
-> [newly created ObservableBoolean object]
doc:add_property(name, number_value)
-> [newly created ObservableNumber object]
doc:add_property(name, string_value)
-> [newly created ObservableString object]
doc:add_property(name, list)
-> [newly created ObservableList object]
doc:add_property(name, node)
-> [newly created DocumentNode object]
doc:add_property(name, node_list)
-> [newly created DocumentList object]

-- Remove a previously added property. Property must exist.
doc:remove_property(document or observable object)

-- Save the whole document tree to an XML file. Overwrites all contents of the
-- file when it already exists.
doc:save_as(file_name)
-> [success, error_string or nil on success]

-- Load the document tree from an XML file. This will NOT create new properties,
-- except for list items, but will only assign existing property values in the
-- document node with existing property values from the XML.
-- This means: nodes that only exist in the XML will silently be ignored.
-- Nodes that only exist in the document, will not be altered in any way.
-- The loaded document's type must match the document type that saved the XML
-- data.
-- A document's type is specified in the renoise.Document.create() function
-- as 'model_name'. For classes which inherit from renoise.Document.DocumentNode
-- it's the class name.
doc:load_from(file_name)
-> [success, error_string or nil on success]

-- Serialize the whole document tree to a XML string.
doc:to_string()
-> [string]

-- Parse document tree from the given string data. See doc:load_from for details
-- about how properties are parsed and errors are handled.
doc:from_string(string)
-> [boolean, error_String]

--[[============================================================================
Renoise Midi API Reference
============================================================================]]--

--[[

This reference describes the raw MIDI IO support for scripts in Renoise; the
ability to send and receive MIDI data.

Please read the INTRODUCTION first to get an overview about the complete
API, and scripting for Renoise in general...

Do not try to execute this file. It uses a .lua extension for markup only.

-------- Overview

The Renoise MIDI API allows you to access any installed MIDI input or output
device. You can also access unused MIDI in/outputs via Renoise's MIDI Remote,
Sync settings, and so on; as set up in the preferences.

-------- Error Handling

When accessing a new device, not used by Renoise nor by your or other scripts,
Renoise will try to open that device's driver. If something goes wrong an error
will be shown to the user. Something like ("MIDI Device Foo failed to open
(error)"). In contrast, none of the MIDI API functions will fail. In other
words, if a "real" device fails to open this is not your problem, but the user's
problem. This is also the reason why none of the MIDI API functions return error
codes.

All other types of logic errors, such as sending MIDI to a manually closed
device, sending bogus messages and so on, will be fired as typical Lua runtime
errors.

-------- Examples

For some simple examples on how to use MIDI IO in Renoise, have a look at the
"Snippets/Midi.lua" file.

]]--

--==============================================================================
-- Midi
--==============================================================================

---

## -- renoise.Midi

-------- Device Enumeration

-- Return a list of strings with the currently available devices. This list can
-- change when devices are hot-plugged. See 'devices_changed_observable'
renoise.Midi.available_input_devices()
-> [list of strings]
renoise.Midi.available_output_devices()
-> [list of strings]

-- Fire notifications as soon as new devices become active or a previously
-- added device gets removed/unplugged.
-- This will only happen on Linux and OSX with real devices. On Windows this
-- may happen when using ReWire slaves. ReWire adds virtual MIDI devices to
-- Renoise.
-- Already opened references to devices which are no longer available will
-- do nothing. Aka, you can use them as before and they will not fire any
-- errors. The messages will simply go into the void...
renoise.Midi.devices_changed_observable()
-> [renoise.Observable object]

-------- Device Creation

-- Listen to incoming MIDI data: opens access to a MIDI input device by
-- specifying a device name. Name must be one of "available_input_devices".
-- Returns a ready to use MIDI input device object.
-- One or both callbacks should be valid, and should either point to a function
-- with one parameter(message_table), or a table with an object and class,
-- a method.
-- All MIDI messages except active sensing will be forwarded to the callbacks.
-- When Renoise is already listening to this device, your callback and Renoise
-- (or even other scripts) will also handle the message.
-- Messages are received until the device reference is manually closed (see
-- midi_device:close()) or until the MidiInputDevice object gets garbage
-- collected.
renoise.Midi.create_input_device(device_name [,callback] [, sysex_callback])
-> [MidiInputDevice object]

-- Send MIDI: open access to a MIDI device by specifying the device name.
-- Name must be one of "available_input_devices". All other device names will
-- fire an error. Returns a ready to use output device.
-- The real device driver gets automatically closed when the MidiOutputDevice
-- object gets garbage collected or when the device is explicitly closed
-- via midi_device:close() and nothing else references it.
renoise.Midi.create_output_device(device_name)
-> [MidiOutputDevice object]

---

## -- renoise.Midi.MidiDevice

-------- Properties

-- Returns true while the device is open (ready to send or receive messages).
-- Your device refs will never be auto-closed, "is_open" will only be false if
-- you explicitly call "midi_device:close()" to release a device.
midi_device.is_open
-> [boolean]

-- The name of a device. This is the name you create a device with (via
-- 'create_input_device' or 'create_output_device')
midi_device.name
-> [string]

-------- Functions

-- Close a running MIDI device. When no other client is using a device, Renoise
-- will also shut off the device driver so that, for example, Windows OS other
-- applications can use the device again. This is automatically done when
-- scripts are closed or your device objects are garbage collected.
midi_device:close()

---

## -- renoise.Midi.MidiInputDevice

-- No public properties or functions.

---

## -- renoise.Midi.MidiOutputDevice

-------- Functions

-- Send raw 1-3 byte MIDI messages or sysex messages. The message is expected
-- to be an array of numbers. It must not be empty and can only contain
-- numbers >= 0 and <= 0xFF (bytes). Sysex messages must be sent in one block,
-- must start with 0xF0, and end with 0xF7.
midi_device:send(message_table)

--[[============================================================================
Renoise OSC API Reference
============================================================================]]--

--[[

This reference describes the built-in OSC (Open Sound Control) support for
Lua scripts in Renoise. OSC can be used in combination with sockets to
send/receive OSC tagged data over process boundaries, or to exchange data
across computers in a network (Internet).

Have a look at <http://opensoundcontrol.org> for general info about OSC.

Please read the INTRODUCTION first to get an overview about the complete
API, and scripting for Renoise in general...

Do not try to execute this file. It uses a .lua extension for markup only.

-------- Examples

-- For some small examples on how to use the OSC and Sockets API, have a
-- look at the code snippets in "Snippets/Osc.lua".

]]--

--==============================================================================
-- Osc
--==============================================================================

---

## -- renoise.Osc

-- De-packetizing raw (socket) data to OSC messages or bundles
-- converts the binary data to an OSC message or bundle. If the data does not
-- look like an OSC message, or the message contains errors, nil is returned
-- as first argument and the second return value will contain the error.
-- If de-packetizing was successful, either a renoise.Osc.Bundle or Message
-- object is returned. Bundles may contain multiple messages or nested bundles.
renoise.Osc.from_binary_data(binary_data)
-> [Osc.Bundle or Osc.Message object or nil, error or nil]

---

## -- renoise.Osc.Message

-------- Create

-- Create a new OSC message with the given pattern and optional arguments.
-- When arguments are specified, they must be specified as a table of:
--
-- > { tag="X", value=SomeValue }
--
-- "tag" is a standard OSC type tag. "value" is the arguments value expressed
-- by a Lua type. The value must be convertible to the specified tag, which
-- means, you cannot for example specify an "i" (integer) as type and then pass
-- a string as the value. Use a number value instead. Not all tags require a
-- value, like the T,F boolean tags. Then a "value" field should not be
-- specified. For more info, see: <http://opensoundcontrol.org/spec-1_0>
--
-- Valid tags are (OSC Type Tag, Type of corresponding value)
--
-- + i, int32
-- + f, float32
-- + s, OSC-string
-- + b, OSC-blob
-- + h, 64 bit big-endian two's complement integer
-- + t, OSC-timetag
-- + d, 64 bit ("double") IEEE 754 floating point number
-- + S, Alternate type represented as an OSC-string
-- + c, An ascii character, sent as 32 bits
-- + r, 32 bit RGBA color
-- + m, 4 byte MIDI message. Bytes from MSB to LSB are: port id,
-- status byte, data1, data2
-- + T, True. No value needs to be specified.
-- + F, False. No value needs to be specified.
-- + N, Nil. No value needs to be specified.
-- + I, Infinitum. No value needs to be specified.
-- + [ ], Indicates the beginning, end of an array. (Currently not
-- supported by Renoise.)
--
renoise.Osc.Message(pattern [, table of {tag, value} arguments])

-------- Properties

-- The message pattern (e.g. "/renoise/transport/start")
message.pattern
-> [read-only, string]

-- Table of `{tag="X", value=SomeValue}` that represents the message arguments.
-- see renoise.Osc.Message "create" for more info.
message.arguments
-> [read-only, table of {tag, value} tables]

-- Raw binary representation of the messsage, as needed when e.g. sending the
-- message over the network through sockets.
message.binary_data
-> [read-only, raw string]

---

## -- renoise.Osc.Bundle

-------- Create

-- Create a new bundle by specifying a time-tag and one or more messages.
-- If you do not know what to do with the time-tag, use os.clock(),
-- which simply means "now". Messages must be renoise.Osc.Message objects.
-- Nested bundles (bundles in bundles) are right now not supported.
renoise.Osc.Bundle(pattern, single_message_or_table_of_messages)

-------- Properties

-- Time value of the bundle.
bundle.timetag
-> [read-only, number]

-- Access to the bundle elements (table of messages or bundle objects)
bundle.elements
-> [read-only, table of renoise.Osc.Message or renoise.Osc.Bundle objects]

-- Raw binary representation of the bundle, as needed when e.g. sending the
-- message over the network through sockets.
bundle.binary_data
-> [read-only, raw string]

--[[============================================================================
Renoise ScriptingTool API Reference
============================================================================]]--

--[[

This reference lists all available Lua functions and classes that are available
to Renoise XRNX "scripting tool" packages. The scripting tool interface allows
your tool to interact with Renoise by injecting or creating menu entries and
keybindings into Renoise; or by attaching it to some common tool related
notifiers.

Please read the INTRODUCTION first to get an overview about the complete
API, and scripting for Renoise in general...

Have a look at the com.renoise.ExampleTool.xrnx for more info about XRNX tools.

Do not try to execute this file. It uses a .lua extension for markup only.

]]--

---

## -- renoise

-------- Functions

-- Access your tool's interface to Renoise. Only valid for XRNX tools.
renoise.tool()
-> [renoise.ScriptingTool object]

---

## -- renoise.ScriptingTool

-------- Functions

--[[

menu_entries: Insert a new menu entry somewhere in Renoise's existing
context menus or the global app menu. Insertion can be done during
script initialization, but can also be done dynamically later on.

The Lua table passed to 'add_menu_entry' is defined as:

- Required fields:

  - ["name"] = Name and 'path' of the entry as shown in the global menus or
    context menus to the user
  - ["invoke"] = A function that is called as soon as the entry is clicked

- Optional fields:
  - ["active"] = A function that should return true or false. When returning
    false, the action will not be invoked and will be "greyed out" in
    menus. This function is always called before "invoke", and every time
    prior to a menu becoming visible.
  - ["selected"] = A function that should return true or false. When
    returning true, the entry will be marked as "this is a selected option"

Positioning entries:

You can place your entries in any context menu or any window menu in Renoise.
To do so, use one of the specified categories in its name:

- "Window Menu" -- Renoise icon menu in the window caption on Windows/Linux
- "Main Menu" (:File", ":Edit", ":View", ":Tools" or ":Help") -- Main menu
- "Scripting Menu" (:File", or ":Tools") -- Scripting Editor & Terminal
- "Disk Browser Directories"
- "Disk Browser Files"
- "Instrument Box"
- "Pattern Sequencer"
- "Pattern Editor"
- "Pattern Matrix"
- "Pattern Matrix Header"
- "Phrase Editor"
- "Phrase Mappings"
- "Phrase Grid"
- "Sample Navigator"
- "Sample Editor"
- "Sample Editor Ruler"
- "Sample Editor Slice Markers"
- "Sample List"
- "Sample Mappings"
- "Sample FX Mixer"
- "Sample Modulation Matrix"
- "Mixer"
- "Track Automation"
- "Track Automation List"
- "DSP Chain"
- "DSP Chain List"
- "DSP Device"
- "DSP Device Header"
- "DSP Device Automation"
- "Modulation Set"
- "Modulation Set List"

Separating entries:

To divide entries into groups (separate entries with a line), prepend one or
more dashes to the name, like "--- Main Menu:Tools:My Tool Group Starts Here"

]]

-- Returns true if the given entry already exists, otherwise false.
renoise.tool():has_menu_entry(menu_entry_name)
-> [boolean]

-- Add a new menu entry as described above.
renoise.tool():add_menu_entry(menu_entry_definition_table)

-- Remove a previously added menu entry by specifying its full name.
renoise.tool():remove_menu_entry(menu_entry_name)

--[[

keybindings: Register key bindings somewhere in Renoise's existing
set of bindings.

The Lua table passed to add_keybinding is defined as:

- Required fields:

  - ["name"] = The scope, name and category of the key binding.
  - ["invoke"] = A function that is called as soon as the mapped key is
    pressed. The callback has one argument: "repeated", indicating
    if its a virtual key repeat.
    The key binding's 'name' must have 3 parts, separated by ":" e.g.
    [scope:topic_name:binding_name]

- 'scope' is where the shortcut will be applied, just like those
  in the categories list for the keyboard assignment preference pane.
- 'topic_name' is useful when grouping entries in the key assignment pane.
  Use "tool" if you can't come up with something meaningful.
- 'binding_name' is the name of the binding.

Currently available scopes are:

> "Global", "Automation", "Disk Browser", "Instrument Box", "Mixer",
> "Pattern Editor", "Pattern Matrix", "Pattern Sequencer", "Sample Editor"
> "Track DSPs Chain"

Using an unavailable scope will not fire an error, instead it will render the
binding useless. It will be listed and mappable, but never be invoked.

There's no way to define default keyboard shortcuts for your entries. Users
manually have to bind them in the keyboard prefs pane. As soon as they do,
they'll get saved just like any other key binding in Renoise.

]]

-- Returns true when the given keybinging already exists, otherwise false.
renoise.tool():has_keybinding(keybinding_name)
-> [boolean]

-- Add a new keybinding entry as described above.
renoise.tool():add_keybinding(keybinding_definition_table)

-- Remove a previously added key binding by specifying its name and path.
renoise.tool():remove_keybinding(keybinding_name)

--[[

midi_mappings: Extend Renoise's default MIDI mapping set, or add custom MIDI
mappings for your tools.

The Lua table passed to 'add_midi_mapping' is defined as:

- Required fields:
  - ["name"] = The group, name of the midi mapping; as visible to the user.
  - ["invoke"] = A function that is called to handle a bound MIDI message.

The mappings 'name' should have more than 1 part, separated by ":" e.g.
[topic_name:optional_sub_topic_name:name]

topic_name and optional sub group names will create new groups in the list
of MIDI mappings, as seen in Renoise's MIDI mapping dialog.
If you can't come up with a meaningful string, use your tool's name as the topic
name. Existing global mappings from Renoise can be overridden. In this case the
original mappings are no longer called, only your tool's mapping.

The "invoke" function gets called with one argument, the midi message, which
is modeled as:

    class "renoise.ScriptingTool.MidiMessage"

      -- returns if action should be invoked
      function is_trigger() -> boolean

      -- check which properties are valid
      function: is_switch() -> boolean
      function: is_rel_value() -> boolean
      function: is_abs_value() -> boolean

      -- [0 - 127] for abs values, [-63 - 63] for relative values
      -- valid when is_rel_value() or is_abs_value() returns true, else undefined
      property: int_value

      -- valid [true OR false] when :is_switch() returns true, else undefined
      property: boolean_value

A tool's MIDI mappings can be used just like the regular mappings in Renoise.
Either by manually looking up the mapping in the MIDI mapping
list, then binding it to a MIDI message, or when your tool has a custom GUI,
specifying the mapping via a control's "control.midi_mapping" property. Such
controls will get highlighted as soon as the MIDI mapping dialog is opened.
Then, users simply click on the highlighted control to map MIDI messages.

]]

-- Returns true when the given mapping already exists, otherwise false.
renoise.tool():has_midi_mapping(midi_mapping_name)
-> [boolean]

-- Add a new midi_mapping entry as described above.
renoise.tool():add_midi_mapping(midi_mapping_definition_table)

-- Remove a previously added midi mapping by specifying its name.
renoise.tool():remove_midi_mapping(midi_mapping_name)

--[[

file_import_hooks: Add support for new filetypes in Renoise. Registered file
types will show up in Renoise's disk browser and can also be loaded by drag and
dropping the files onto the Renoise window. When adding hooks for files which
Renoise already supports, your tool's import functions will override the internal
import functions.

Always load the file into the currently selected component, like
'renoise.song().selected_track','selected_instrument','selected_sample'.

Preloading/prehearing sample files is not supported via tools.

The Lua table passed to 'add_file_import_hook' is defined as:

- Required fields:
  - ["category"] = in which disk browser category the file type shows up.
    "song", "instrument", "effect chain", "effect preset", "modulation set",
    "phrase", "sample" or "theme"
  - ["extensions"] = a list of strings, file extensions, that will invoke
    your hook, like for example {"txt", "swave"}
  - ["invoke"] = function that is called to do the import. return true when
    the import succeeded, else false.
    ]]

-- Returns true when the given hook already exists, otherwise false.
renoise.tool():has_file_import_hook(category, extensions_table)
-> [boolean]

-- Add a new file import hook as described above.
renoise.tool():add_file_import_hook(file_import_hook_definition_table)

-- Remove a previously added file import hook by specifying its category
-- and extension(s)
renoise.tool():remove_file_import_hook(category, extensions_table)

--[[

Register a timer function or table with a function and context (a method)
that periodically gets called by the app_idle_observable for your tool.

Modal dialogs will avoid that timers are called. To create a one-shot timer,
simply call remove_timer at the end of your timer function. Timer_interval_in_ms
must be > 0. The exact interval your function is called will vary
a bit, depending on workload; e.g. when enough CPU time is available the
rounding error will be around +/- 5 ms.

]]

-- Returns true when the given function or method was registered as a timer.
renoise.tool():has_timer(function or {object, function} or {function, object})
-> [boolean]

-- Add a new timer as described above.
renoise.tool():add_timer(function or {object, function} or {function, object},
timer_interval_in_ms)

-- Remove a previously registered timer.
renoise.tool():remove_timer(timer_func)

-------- Properties

-- Full absolute path and name to your tool's bundle directory.
renoise.tool().bundle_path
-> [read-only, string]

-- Invoked when the tool finished loading/initializing and no errors happened. When
-- the tool has preferences, they are loaded here as well when the notification fires,
-- but 'renoise.song()' may not yet be available.
-- See also 'renoise.tool().app_new_document_observable'.
renoise.tool().tool_finished_loading_observable
-> [renoise.Document.Observable object]

-- Invoked right before a tool gets unloaded: either because it got disabled, reloaded
-- or the application exists. You can cleanup resources or connections to other devices
-- here if necessary.
renoise.tool().tool_will_unload_observable
-> [renoise.Document.Observable object]

-- Invoked as soon as the application becomes the foreground window.
-- For example, when you ATL-TAB to it, or activate it with the mouse
-- from another app to Renoise.
renoise.tool().app_became_active_observable
-> [renoise.Document.Observable object]

-- Invoked as soon as the application looses focus and another app
-- becomes the foreground window.
renoise.tool().app_resigned_active_observable
-> [renoise.Document.Observable object]

-- Invoked periodically in the background, more often when the work load
-- is low, less often when Renoise's work load is high.
-- The exact interval is undefined and can not be relied on, but will be
-- around 10 times per sec.
-- You can do stuff in the background without blocking the application here.
-- Be gentle and don't do CPU heavy stuff please!
renoise.tool().app_idle_observable
-> [renoise.Document.Observable object]

-- Invoked each time before a new document gets created or loaded: this is the
-- last time renoise.song() still points to the old song before a new one arrives.
-- You can explicitly release notifiers to the old document here, or do your own
-- housekeeping. Also called right before the application exits.
renoise.tool().app_release_document_observable
-> [renoise.Document.Observable object]

-- Invoked each time a new document (song) is created or loaded. In other words:
-- each time the result of renoise.song() is changed. Also called when the script
-- gets reloaded (only happens with the auto_reload debugging tools), in order
-- to connect the new script instance to the already running document.
renoise.tool().app_new_document_observable
-> [renoise.Document.Observable object]

-- invoked each time the app's document (song) is successfully saved.
-- renoise.song().file_name will point to the filename that it was saved to.
renoise.tool().app_saved_document_observable
-> [renoise.Document.Observable object]

--[[

Get or set an optional renoise.Document.DocumentNode object, which will be
used as set of persistent "options" or preferences for your tool.
By default nil. When set, the assigned document object will automatically be
loaded and saved by Renoise, to retain the tools state.
The preference XML file is saved/loaded within the tool bundle as
"com.example.your_tool.xrnx/preferences.xml".

A simple example:

    -- create a document
    my_options = renoise.Document.create("ScriptingToolPreferences") {
     some_option = true,
     some_value = "string_value"
    }

Or:

    -- create a document
    class "ExampleToolPreferences"(renoise.Document.DocumentNode)

      function ExampleToolPreferences:__init()
        renoise.Document.DocumentNode.__init(self)
        self:add_property("some_option", true)
        self:add_property("some_value", "string_value")
      end

      my_options = ExampleToolPreferences()

      -- values can be accessed (read, written) via
      my_options.some_option.value, my_options.some_value.value

      -- also notifiers can be added to listen to changes to the values
      -- done by you, or after new values got loaded or a view changed the value:
      my_options.some_option:add_notifier(function() end)

And assign it:

    -- 'my_options' will be loaded/saved automatically with the tool now:
    renoise.tool().preferences = my_options

]]

-- Please see Renoise.Document.API for more info about renoise.DocumentNode
-- and for info on Documents in general.
renoise.tool().preferences
-> [renoise.Document.DocumentNode object or nil]

--[[============================================================================
Renoise Socket API Reference
============================================================================]]--

--[[

This reference describes the built-in socket support for Lua scripts in Renoise.
Sockets can be used to send/receive data over process boundaries, or exchange
data across computers in a network (Internet). The socket API in Renoise has
server support (which can respond to multiple connected clients) and client
support (send/receive data to/from a server).

Right now UDP and TCP protocols are supported. The class interfaces for UDP
and TCP sockets behave exactly the same. That is, they don't depend on the
protocol, so both are easily interchangeable when needed.

Please read the INTRODUCTION first to get an overview about the complete
API, and scripting for Renoise in general...

Do not try to execute this file. It uses a .lua extension for markup only.

-------- Overview

The socket server interface in Renoise is asynchronous (callback based), which
means server calls never block or wait, but are served in the background.
As soon a connection is established or messages arrive, a set of specified
callbacks are invoked to respond to messages.

Socket clients in Renoise do block with timeouts to receive messages, and
assume that you only expect a response from a server after having sent
something to it (i.e.: GET HTTP).
To constantly poll a connection to a server, for example in idle timers,
specify a timeout of 0 in "receive(message, 0)". This will only check if there
are any pending messages from the server and read them. If there are no pending
messages it will not block or timeout.

-------- Error Handling

All socket functions which can fail, will return an error string as an optional
second return value. They do not call Lua's error() handler, so you can decide
yourself how to deal with expected errors like connection timeouts,
connection failures, and so on. This also means you don't have to "pcall"
socket functions to handle such "expected" errors.

Logic errors (setting invalid addresses, using disconnected sockets, passing
invalid timeouts, and so on) will fire Lua's runtime error (abort your scripts
and spit out an error). If you get such an error, then this usually means you
did something wrong: fed or used the sockets in a way that does not make sense.
Never "pcall" such errors, fix the problem instead.

-------- Examples

For examples on how to use sockets, have a look at the corresponding
"CodeSnippets" file.

]]

--==============================================================================
-- Socket
--==============================================================================

---

## -- renoise.Socket

-------- Constants

renoise.Socket.PROTOCOL_TCP
renoise.Socket.PROTOCOL_UDP

------ Creating Socket Servers

-- Creates a connected UPD or TCP server object. Use "localhost" to use your
-- system's default network address. Protocol can be renoise.Socket.PROTOCOL_TCP
-- or renoise.Socket.PROTOCOL_UDP (by default TCP).
-- When instantiation and connection succeed, a valid server object is
-- returned, otherwise "socket_error" is set and the server object is nil.
-- Using the create function with no server_address allows you to create a
-- server which allows connections to any address (for example localhost
-- and some IP)
renoise.Socket.create_server( [server_address, ] server_port [, protocol]) ->
[server (SocketServer or nil), socket_error (string or nil)]

------ Creating Socket Clients

-- Create a connected UPD or TCP client. Protocol can be
-- renoise.Socket.PROTOCOL_TCP or renoise.Socket.PROTOCOL_UDP (by default TCP)
-- Timeout is the time to wait until the connection is established (1000 ms
-- by default). When instantiation and connection succeed, a valid client
-- object is returned, otherwise "socket_error" is set and the client object
-- is nil
renoise.Socket.create_client(server_address, server_port [, protocol] [, timeout]) ->
[client (SocketClient or nil), socket_error (string or nil)]

---

## -- renoise.Socket.SocketBase

-- SocketBase is the base class for socket clients and servers. All
-- SocketBase properties and functions are available for servers and clients.

-------- Properties

-- Returns true when the socket object is valid and connected. Sockets can
-- manually be closed (see socket:close()). Client sockets can also actively be
-- closed/refused by the server. In this case the client:receive() calls will
-- fail and return an error.
socket.is_open -> [boolean]

-- The socket's resolved local address (for example "127.0.0.1" when a socket
-- is bound to "localhost")
socket.local_address -> [string]

-- The socket's local port number, as specified when instantiated.
socket.local_port -> [number]

-------- Functions

-- Closes the socket connection and releases all resources. This will make
-- the socket useless, so any properties, calls to the socket will result in
-- errors. Can be useful to explicitly release a connection without waiting for
-- the dead object to be garbage collected, or if you want to actively refuse a
-- connection.
socket:close()

---

## -- renoise.Socket.SocketClient (inherits from SocketBase)

-- A SocketClient can connect to other socket servers and send and receive data
-- from them on request. Connections to a server can not change, they are
-- specified when constructing a client. You can not reconnect a client; create
-- a new client instance instead.

-------- Properties

-- Address of the socket's peer, the socket address this client is connected to.
socket_client.peer_address -> [string]

-- Port of the socket's peer, the socket this client is connected to.
socket_client.peer_port -> [number]

-------- Functions

-- Send a message string (or OSC messages or bundles) to the connected server.
-- When sending fails, "success" return value will be false and "error_message"
-- is set, describing the error in a human readable format.
-- NB: when using TCP instead of UDP as protocol for OSC messages, !no! SLIP
-- encoding and no size prefixing of the passed OSC data will be done here.
-- So, when necessary, do this manually by your own please.
socket_client:send(message) ->
[success (boolean), error_message (string or nil)]

-- Receive a message string from the the connected server with the given
-- timeout in milliseconds. Mode can be one of "*line", "*all" or a number > 0,
-- like Lua's io.read. \param timeout can be 0, which is useful for
-- receive("*all"). This will only check and read pending data from the
-- sockets queue.
--
-- + mode "*line": Will receive new data from the server or flush pending data
-- that makes up a "line": a string that ends with a newline. remaining data
-- is kept buffered for upcoming receive calls and any kind of newlines
-- are supported. The returned line will not contain the newline characters.
--
-- + mode "*all": Reads all pending data from the peer socket and also flushes
-- internal buffers from previous receive line/byte calls (when present).
-- This will NOT read the entire requested content, but only the current
-- buffer that is queued for the local socket from the peer. To read an
-- entire HTTP page or file you may have to call receive("*all") multiple
-- times until you got all you expect to get.
--
-- + mode "number > 0": Tries reading \param NumberOfBytes of data from the
-- peer. Note that the timeout may be applied more than once, if more than
-- one socket read is needed to receive the requested block.
--
-- When receiving fails or times-out, the returned message will be nil and
-- error_message is set. The error message is "timeout" on timeouts,
-- "disconnected" when the server actively refused/disconnected your client.
-- Any other errors are system dependent, and should only be used for display
-- purposes.
--
-- Once you get an error from receive, and this error is not a "timeout", the
-- socket will already be closed and thus must be recreated in order to retry
-- communication with the server. Any attempt to use a closed socket will
-- fire a runtime error.
socket_client:receive(mode, timeout_ms) ->
[message (string or nil), error_message (string or nil)]

---

## -- renoise.Socket.SocketServer (inherits from SocketBase)

-- A SocketServer handles one or more clients in the background, interacts
-- only with callbacks from connected clients. This background polling can be
-- start and stop on request.

-------- Properties

-- Returns true while the server is running (the server is up and running)
server_socket.is_running -> [boolean]

-------- Functions

-- Start running the server by specifying a class or table which defines the
-- callback functions for the server (see "callbacks" below for more info).
server_socket:run(notifier_table_or_call)

-- Stop a running server.
server_socket:stop()

-- Suspends the calling thread by the given timeout, and calls the server's
-- callback methods as soon as something has happened in the server while
-- waiting. Should be avoided whenever possible.
server_socket:wait(timeout_ms)

-------- Callbacks

--[[

All callback properties are optional. So you can, for example, skip specifying
"socket_accepted" if you have no use for this.

Notifier table example:

    notifier_table = {
      socket_error = function(error_message)
        -- An error happened in the servers background thread.
      end,

      socket_accepted = function(socket)
         -- FOR TCP CONNECTIONS ONLY: called as soon as a new client
         -- connected to your server. The passed socket is a ready to use socket
         -- object, representing a connection to the new socket.
      end,

      socket_message = function(socket, message)
        -- A message was received from a client: The passed socket is a ready
        -- to use connection for TCP connections. For UDP, a "dummy" socket is
        -- passed, which can only be used to query the peer address and port
        -- -> socket.port and socket.address
      end
    }

Notifier class example:  
Note: You must pass an instance of a class, like server_socket:run(MyNotifier())

    class "MyNotifier"

      MyNotifier::__init()
        -- could pass a server ref or something else here, or simply do nothing
      end

      function MyNotifier:socket_error(error_message)
        -- An error happened in the servers background thread.
      end

      function MyNotifier:socket_accepted(socket)
        -- FOR TCP CONNECTIONS ONLY: called as soon as a new client
        -- connected to your server. The passed socket is a ready to use socket
        -- object, representing a connection to the new socket.
      end

      function MyNotifier:socket_message(socket, message)
        -- A message was received from a client: The passed socket is a ready
        -- to use connection for TCP connections. For UDP, a "dummy" socket is
        -- passed, which can only be used to query the peer address and port
        -- -> socket.port and socket.address
      end

]]--

--[[============================================================================
Renoise Song API Reference
============================================================================]]--

--[[

This reference lists all available Lua functions and classes that control
Renoise's main document - the song - and the corresponding components such as
Instruments, Tracks, Patterns, and so on.

Please read the INTRODUCTION first to get an overview about the complete
API, and scripting for Renoise in general...

Do not try to execute this file. It uses a .lua extension for markup only.

]]--

---

## -- renoise

-------- Functions

-- Access to the one and only loaded song in the app. Always valid after the
-- application is initialized. NOT valid when called from the XRNX globals while
-- a tool is still initializing; XRNX tools are initialized before the initial
-- song is created.
renoise.song()
-> [renoise.Song object or nil]

---

## -- renoise.SongPos

-- Helper class used in Transport and Song, representing a position in the song.

-------- Properties

-- Position in the pattern sequence.
song_pos.sequence
-> [number]

-- Position in the pattern at the given pattern sequence.
song_pos.line
-> [number]

-------- Operators

==(song_pos, song_pos) -> [boolean]
~=(song_pos, song_pos) -> [boolean]

> (song_pos, song_pos) -> [boolean]
> =(song_pos, song_pos) -> [boolean]
> <(song_pos, song_pos) -> [boolean]
> <=(song_pos, song_pos) -> [boolean]

---

## -- renoise.Song

-------- Constants

renoise.Song.MAX_NUMBER_OF_INSTRUMENTS

renoise.Song.SUB_COLUMN_NOTE
renoise.Song.SUB_COLUMN_INSTRUMENT
renoise.Song.SUB_COLUMN_VOLUME
renoise.Song.SUB_COLUMN_PANNING
renoise.Song.SUB_COLUMN_DELAY
renoise.Song.SUB_COLUMN_SAMPLE_EFFECT_NUMBER
renoise.Song.SUB_COLUMN_SAMPLE_EFFECT_AMOUNT

renoise.Song.SUB_COLUMN_EFFECT_NUMBER
renoise.Song.SUB_COLUMN_EFFECT_AMOUNT

-------- Functions

-- Test if something in the song can be undone.
renoise.song():can_undo()
-> [boolean]
-- Undo the last performed action. Will do nothing if nothing can be undone.
renoise.song():undo()

-- Test if something in the song can be redone.
renoise.song():can_redo()
-> [boolean]
-- Redo a previously undo action. Will do nothing if nothing can be redone.
renoise.song():redo()

-- When modifying the song, Renoise will automatically add descriptions for
-- undo/redo by looking at what first changed (a track was inserted, a pattern
-- line changed, and so on). When the song is changed from an action in a menu
-- entry callback, the menu entry's label will automatically be used for the
-- undo description.
-- If those auto-generated names do not work for you, or you want to use
-- something more descriptive, you can (!before changing anything in the song!)
-- give your changes a custom undo description (like: "Generate Synth Sample")
renoise.song():describe_undo(description)

-- Insert a new track at the given index. Inserting a track behind or at the
-- Master Track's index will create a Send Track. Otherwise, a regular track is
-- created.
renoise.song():insert_track_at(index)
-> [new renoise.Track object]
-- Delete an existing track. The Master track can not be deleted, but all Sends
-- can. Renoise needs at least one regular track to work, thus trying to
-- delete all regular tracks will fire an error.
renoise.song():delete_track_at(index)
-- Swap the positions of two tracks. A Send can only be swapped with a Send
-- track and a regular track can only be swapped with another regular track.
-- The Master can not be swapped at all.
renoise.song():swap_tracks_at(index1, index2)

-- Access to a single track by index. Use properties 'tracks' to iterate over
-- all tracks and to query the track count.
renoise.song():track(index)
-> [renoise.Track object]

-- Set the selected track to prev/next relative to the current track. Takes
-- care of skipping over hidden tracks and wrapping around at the edges.
renoise.song():select_previous_track()
renoise.song():select_next_track()

-- Insert a new group track at the given index. Group tracks can only be
-- inserted before the Master track.
renoise.song():insert_group_at(index)
-> [new renoise.GroupTrack object]

-- Add track at track_index to group at group_index by first moving it to the
-- right spot to the left of the group track, and then adding it. If group_index
-- is not a group track, a new group track will be created and both tracks
-- will be added to it.
renoise.song():add_track_to_group(track_index, group_index)
-- Removes track from its immediate parent group and places it outside it to
-- the left. Can only be called for tracks that are actually part of a group.
renoise.song():remove_track_from_group(track_index)
-- Delete the group with the given index and all its member tracks.
-- Index must be that of a group or a track that is a member of a group.
renoise.song():delete_group_at(index)

-- Insert a new instrument at the given index. This will remap all existing
-- notes in all patterns, if needed, and also update all other instrument links
-- in the song. Can't have more than MAX_NUMBER_OF_INSTRUMENTS in a song.
renoise.song():insert_instrument_at(index)
-> [new renoise.Instrument object]
-- Delete an existing instrument at the given index. Renoise needs at least one
-- instrument, thus trying to completely remove all instruments is not allowed.
-- This will remap all existing notes in all patterns and update all other
-- instrument links in the song.
renoise.song():delete_instrument_at(index)
-- Swap the position of two instruments. Will remap all existing notes in all
-- patterns and update all other instrument links in the song.
renoise.song():swap_instruments_at(index2, index2)

-- Access to a single instrument by index. Use properties 'instruments' to iterate
-- over all instruments and to query the instrument count.
renoise.song():instrument(index)
-> [renoise.Instrument object]

-- Captures the current instrument (selects the instrument) from the current
-- note column at the current cursor pos. Changes the selected instrument
-- accordingly, but does not return the result. When no instrument is present at
-- the current cursor pos, nothing will be done.
renoise.song():capture_instrument_from_pattern()

-- Tries to captures the nearest instrument from the current pattern track,
-- starting to look at the cursor pos, then advancing until an instrument is
-- found. Changes the selected instrument accordingly, but does not return
-- the result. When no instruments (notes) are present in the current pattern
-- track, nothing will be done.
renoise.song():capture_nearest_instrument_from_pattern()

-- Access to a single pattern by index. Use properties 'patterns' to iterate
-- over all patterns and to query the pattern count.
renoise.song():pattern(index)
-> [renoise.Pattern object]

-- When rendering (see renoise.song().rendering, renoise.song().rendering_progress),
-- the current render process is canceled. Otherwise, nothing is done.
renoise.song():cancel_rendering()

-- Start rendering a section of the song or the whole song to a WAV file.
-- Rendering job will be done in the background and the call will return
-- back immediately, but the Renoise GUI will be blocked during rendering. The
-- passed 'rendering_done_callback' function is called as soon as rendering is
-- done, e.g. successfully completed.
-- While rendering, the rendering status can be polled with the song().rendering
-- and song().rendering_progress properties, for example, in idle notifier
-- loops. If starting the rendering process fails (because of file IO errors for
-- example), the render function will return false and the error message is set
-- as the second return value. On success, only a single "true" value is
-- returned. Parameter 'options' is a table with the following fields, all optional:
--
-- options = {
-- start_pos, -- renoise.SongPos object. by default the song start.
-- end_pos, -- renoise.SongPos object. by default the song end.
-- sample_rate, -- one of 22050, 44100, 48000, 88200, 96000, 192000. \
-- -- by default the players current rate.
-- bit_depth , -- number, one of 16, 24 or 32. by default 32.
-- interpolation, -- string, one of 'default', 'precise'. by default default'.
-- priority, -- string, one "low", "realtime", "high". \
-- -- by default "high".
-- }
--
-- To render only specific tracks or columns, mute the undesired tracks/columns
-- before starting to render.
-- Parameter 'file_name' must point to a valid, maybe already existing file. If it
-- already exists, the file will be silently overwritten. The renderer will
-- automatically add a ".wav" extension to the file_name, if missing.
-- Parameter 'rendering_done_callback' is ONLY called when rendering has succeeded.
-- You can do something with the file you've passed to the renderer here, like
-- for example loading the file into a sample buffer.
renoise.song():render([options, ] filename, rendering_done_callback)
-> [boolean, error_message or nil]

-- Load/save all global MIDI mappings in the song into a XRNM file.
-- Returns true when loading/saving succeeded, else false and the error_message.
renoise.song():load_midi_mappings(filename)
-> [boolean, error_message or nil]
renoise.song():save_midi_mappings(filename)
-> [boolean, error_message or nil]

-- clear all MIDI mappings in the song
renoise.song():clear_midi_mappings()

-------- Properties

-- When the song is loaded from or saved to a file, the absolute path and name
-- to the XRNS file is returned. Otherwise, an empty string is returned.
renoise.song().file_name
-> [read-only, string]

-- Song Comments  
-- Note: All property tables of basic types in the API are temporary copies.
-- In other words `renoise.song().comments = { "Hello", "World" }` will work,
-- `renoise.song().comments[1] = "Hello"; renoise.song().comments[2] = "World"`
-- will _not_ work.
renoise.song().artist, \_observable
-> [string]
renoise.song().name, \_observable
-> [string]
renoise.song().comments[], \_observable
-> [array of strings]

-- Notifier is called as soon as any paragraph in the comments change.
renoise.song().comments_assignment_observable
-> [read-only, renoise.Observable object]
-- Set this to true to show the comments dialog after loading a song
renoise.song().show_comments_after_loading, \_observable
-> [boolean]

-- Inject/fetch custom XRNX scripting tool data into the song. Can only be called
-- from scripts that are running in Renoise scripting tool bundles; attempts to
-- access the data from e.g. the scripting terminal will result in an error.
-- Returns nil when no data is present.
--
-- Each tool gets it's own data slot in the song, which is resolved by the tool's
-- bundle id, so this data is unique for every tool and persistent accross tools
-- with the same bundle id (but possibly different versions).
-- If you want to store renoise.Document data in here, you can use the
-- renoise.Document's 'to_string' and 'from_string' functions to serialize the data.
-- Alternatively, write your own serializers for your custom data.
renoise.song().tool_data
-> [string or nil]

-- See renoise.song():render(). Returns true while rendering is in progress.
renoise.song().rendering
-> [read-only, boolean]

-- See renoise.song():render(). Returns the current render progress amount.
renoise.song().rendering_progress
-> [read-only, number, 0.0-1.0]

-- See renoise.Transport for more info.
renoise.song().transport
-> [read-only, renoise.Transport object]

-- See renoise.PatternSequencer for more info.
renoise.song().sequencer
-> [read-only, renoise.PatternSequencer object]

-- See renoise.PatternIterator for more info.
renoise.song().pattern_iterator
-> [read-only, renoise.PatternIterator object]

-- number of normal playback tracks (non-master or sends) in song.
renoise.song().sequencer_track_count
-> [read-only, number]
-- number of send tracks in song.
renoise.song().send_track_count
-> [read-only, number]

-- Instrument, Pattern, and Track arrays
renoise.song().instruments[], \_observable
-> [read-only, array of renoise.Instrument objects]
renoise.song().patterns[], \_observable
-> [read-only, array of renoise.Pattern objects]
renoise.song().tracks[], \_observable
-> [read-only, array of renoise.Track objects]

-- Selected in the instrument box. Never nil.
renoise.song().selected_instrument, \_observable
-> [read-only, renoise.Instrument object]
renoise.song().selected_instrument_index, \_observable
-> [number]

-- Currently selected phrase the instrument's phrase map piano
-- view. Can be nil.
renoise.song().selected_phrase, \_observable
-> [read-only, renoise.InstrumentPhrase object or nil]
renoise.song().selected_phrase_index
-> [number, index or 0 when no phrase is selected]

-- Selected in the instrument's sample list. Only nil when no samples
-- are present in the selected instrument.
renoise.song().selected_sample, \_observable
-> [read-only, renoise.Sample object or nil]
renoise.song().selected_sample_index
-> [number, index or 0 when no sample is selected (no samples are present)]

-- Selected in the instrument's modulation view. Can be nil.
renoise.song().selected_sample_modulation_set, \_observable
-> [read-only, renoise.SampleModulationSet object or nil]
renoise.song().selected_sample_modulation_set_index
-> [number, index or 0 when no set is selected]

-- Selected in the instrument's effects view. Can be nil.
renoise.song().selected_sample_device_chain, \_observable
-> [read-only, renoise.SampleDeviceChain object or nil]
renoise.song().selected_sample_device_chain_index
-> [number, index or 0 when no set is selected]

-- Selected in the sample effect mixer. Can be nil.
renoise.song().selected_sample_device, \_observable
-> [read-only, renoise.AudioDevice object or nil]
renoise.song().selected_sample_device_index
-> [number, index or 0 (when no device is selected)]

-- Selected in the pattern editor or mixer. Never nil.
renoise.song().selected_track, \_observable
-> [read-only, renoise.Track object]
renoise.song().selected_track_index, \_observable
-> [number]

-- Selected in the track DSP chain editor. Can be nil.
renoise.song().selected_track_device, \_observable
-> [read-only, renoise.AudioDevice object or nil]
renoise.song().selected_track_device_index
-> [number, index or 0 (when no device is selected)]

-- DEPRECATED - alias for new 'selected_track_device' property
renoise.song().selected_device, \_observable
-> [read-only, renoise.AudioDevice object or nil]
renoise.song().selected_device_index
-> [number, index or 0 (when no device is selected)]

-- DEPRECATED - alias for new 'selected_automation_parameter' property
renoise.song().selected_parameter, \_observable
-> [renoise.DeviceParameter object or nil]

-- Selected parameter in the automation editor. Can be nil.
-- When setting a new parameter, parameter must be automateable and
-- must be one of the currently selected track device chain.
renoise.song().selected_automation_parameter, \_observable
-> [renoise.DeviceParameter object or nil]
-- parent device of 'selected_automation_parameter'. not settable.
renoise.song().selected_automation_device, \_observable
-> [renoise.AudioDevice object or nil]

-- The currently edited pattern. Never nil.
renoise.song().selected_pattern, \_observable
-> [read-only, renoise.Pattern object]
renoise.song().selected_pattern_index, \_observable
-> [number]

-- The currently edited pattern track object. Never nil.
-- and selected_track_observable for notifications.
renoise.song().selected_pattern_track, \_observable
-> [read-only, renoise.PatternTrack object]

-- The currently edited sequence position.
renoise.song().selected_sequence_index, \_observable
-> [number]

-- The currently edited line in the edited pattern.
renoise.song().selected_line
-> [read-only, renoise.PatternLine object]
renoise.song().selected_line_index
-> [number]

-- The currently edited column in the selected line in the edited
-- sequence/pattern. Nil when an effect column is selected.
renoise.song().selected_note_column
-> [read-only, renoise.NoteColumn object or nil], [renoise.Line object or nil]
renoise.song().selected_note_column_index
-> [number, index or 0 (when an effect column is selected)]

-- The currently edited column in the selected line in the edited
-- sequence/pattern. Nil when a note column is selected.
renoise.song().selected_effect_column
-> [read-only, renoise.EffectColumn or nil], [renoise.Line object or nil]
renoise.song().selected_effect_column_index
-> [number, index or 0 (when a note column is selected)]

-- The currently edited sub column type within the selected note/effect column.
renoise.song().selected_sub_column_type
-> [read-only, enum = SUB_COLUMN]

-- Read/write access to the selection in the pattern editor.
-- The property is a table with the following members:
--
-- {
-- start_line, -- Start pattern line index
-- start_track, -- Start track index
-- start_column, -- Start column index within start_track  
--
-- end_line, -- End pattern line index
-- end_track, -- End track index
-- end_column -- End column index within end_track
-- }
--
-- Line indexes are valid from 1 to renoise.song().patterns[].number_of_lines
--
-- Track indexes are valid from 1 to #renoise.song().tracks
--
-- Column indexes are valid from 1 to
-- (renoise.song().tracks[].visible_note_columns +
-- renoise.song().tracks[].visible_effect_columns)
--
-- When setting the selection, all members are optional. Combining them in
-- various different ways will affect how specific the selection is. When
-- 'selection_in_pattern' returns nil or is set to nil, no selection is present.
--
-- Examples:
-- renoise.song().selection_in_pattern = {}
-- --> clear
-- renoise.song().selection_in_pattern = { start_line = 1, end_line = 4 }
-- --> select line 1 to 4, first to last track
-- renoise.song().selection_in_pattern =
-- { start_line = 1, start_track = 1, end_line = 4, end_track = 1 }
-- --> select line 1 to 4, in the first track only
--
renoise.song().selection_in_pattern
-> [table of start/end values or nil]
-- same as 'selection_in_pattern' but for the currently selected phrase (if any).
-- there are no tracks in phrases, so only 'line' and 'column' fields are valid.
renoise.song().selection_in_phrase
-> [table of start/end values or nil]

---

## -- renoise.Transport

-------- Constants

renoise.Transport.PLAYMODE_RESTART_PATTERN
renoise.Transport.PLAYMODE_CONTINUE_PATTERN

renoise.Transport.RECORD_PARAMETER_MODE_PATTERN
renoise.Transport.RECORD_PARAMETER_MODE_AUTOMATION

renoise.Transport.TIMING_MODEL_SPEED
renoise.Transport.TIMING_MODEL_LPB

-------- Functions

-- Panic.
renoise.song().transport:panic()

-- Mode: enum = PLAYMODE
renoise.song().transport:start(mode)
-- start playing the currently edited pattern at the given line offset
renoise.song().transport:start_at(line)
-- start playing a the given renoise.SongPos (sequence pos and line)
renoise.song().transport:start_at(song_pos)

-- stop playing. when already stopped this just stops all playing notes.
renoise.song().transport:stop()

-- Immediately start playing at the given sequence position.
renoise.song().transport:trigger_sequence(sequence_pos)
-- Append the sequence to the scheduled sequence list. Scheduled playback
-- positions will apply as soon as the currently playing pattern play to end.
renoise.song().transport:add_scheduled_sequence(sequence_pos)
-- Replace the scheduled sequence list with the given sequence.
renoise.song().transport:set_scheduled_sequence(sequence_pos)

-- Move the block loop one segment forwards, when possible.
renoise.song().transport:loop_block_move_forwards()
-- Move the block loop one segment backwards, when possible.
renoise.song().transport:loop_block_move_backwards()

-- Start a new sample recording when the sample dialog is visible,
-- otherwise stop and finish it.
renoise.song().transport:start_stop_sample_recording()
-- Cancel a currently running sample recording when the sample dialog
-- is visible, otherwise do nothing.
renoise.song().transport:cancel_sample_recording()

-------- Properties

-- Playing.
renoise.song().transport.playing, \_observable
-> [boolean]

-- Old school speed or new LPB timing used?
-- With TIMING_MODEL_SPEED, tpl is used as speed factor. The lpb property
-- is unused then. With TIMING_MODEL_LPB, tpl is used as event rate for effects
-- only and lpb defines relationship between pattern lines and beats.
renoise.song().transport.timing_model
-> [read-only, enum = TIMING_MODEL]

-- BPM, LPB, and TPL.
renoise.song().transport.bpm, \_observable
-> [number, 32-999]
renoise.song().transport.lpb, \_observable
-> [number, 1-256]
renoise.song().transport.tpl, \_observable
-> [number, 1-16]

-- Playback position.
renoise.song().transport.playback_pos
-> [renoise.SongPos object]
renoise.song().transport.playback_pos_beats
-> [number, 0-song_end_beats]

-- Edit position.
renoise.song().transport.edit_pos
-> [renoise.SongPos object]
renoise.song().transport.edit_pos_beats
-> [number, 0-sequence_length]

-- Song length.
renoise.song().transport.song_length
-> [read-only, SongPos]
renoise.song().transport.song_length_beats
-> [read-only, number]

-- Loop.
renoise.song().transport.loop_start
-> [read-only, SongPos]
renoise.song().transport.loop_end
-> [read-only, SongPos]
renoise.song().transport.loop_range[]
-> [array of two renoise.SongPos objects]

renoise.song().transport.loop_start_beats
-> [read-only, number within 0-song_end_beats]
renoise.song().transport.loop_end_beats
-> [read-only, number within 0-song_end_beats]
renoise.song().transport.loop_range_beats[]
-> [array of two numbers, 0-song_end_beats]

renoise.song().transport.loop_sequence_start
-> [read-only, 0 or 1-sequence_length]
renoise.song().transport.loop_sequence_end
-> [read-only, 0 or 1-sequence_length]
renoise.song().transport.loop_sequence_range[]
-> [array of two numbers, 0 or 1-sequence_length or empty to disable]

renoise.song().transport.loop_pattern, \_observable
-> [boolean]

renoise.song().transport.loop_block_enabled
-> [boolean]
renoise.song().transport.loop_block_start_pos
-> [read-only, renoise.SongPos object]
renoise.song().transport.loop_block_range_coeff
-> [number, 2-16]

-- Edit modes.
renoise.song().transport.edit_mode, \_observable
-> [boolean]
renoise.song().transport.edit_step, \_observable
-> [number, 0-64]
renoise.song().transport.octave, \_observable
-> [number, 0-8]

-- Metronome.
renoise.song().transport.metronome_enabled, \_observable
-> [boolean]
renoise.song().transport.metronome_beats_per_bar, \_observable
-> [1-16]
renoise.song().transport.metronome_lines_per_beat, \_observable
-> [number, 1-256 or 0 = songs current LPB]

-- Metronome precount.
renoise.song().transport.metronome_precount_enabled, \_observable
-> [boolean]
renoise.song().transport.metronome_precount_bars, \_observable
-> [number, 1-4]

-- Quantize.
renoise.song().transport.record_quantize_enabled, \_observable
-> [boolean]
renoise.song().transport.record_quantize_lines, \_observable
-> [number, 1-32]

-- Record parameter.
renoise.song().transport.record_parameter_mode, \_observable
-> [enum = RECORD_PARAMETER_MODE]

-- Follow, wrapped pattern, single track modes.
renoise.song().transport.follow_player, \_observable
-> [boolean]
renoise.song().transport.wrapped_pattern_edit, \_observable
-> [boolean]
renoise.song().transport.single_track_edit_mode, \_observable
-> [boolean]

-- Groove. (aka Shuffle)
renoise.song().transport.groove_enabled, \_observable
-> [boolean]
renoise.song().transport.groove_amounts[]
-> [array of numbers, 0.0-1.0]
-- Attach notifiers that will be called as soon as any
-- groove amount value changed.
renoise.song().transport.groove_assignment_observable
-> [renoise.Observable object]

-- Global Track Headroom.
-- To convert to dB: dB = math.lin2db(renoise.song().transport.track_headroom)
-- To convert from dB: renoise.song().transport.track_headroom = math.db2lin(dB)
renoise.song().transport.track_headroom, \_observable
-> [number, math.db2lin(-12)-math.db2lin(0)]

-- Computer Keyboard Velocity.
-- Will return the default value of 127 when keyboard_velocity_enabled == false.
renoise.song().transport.keyboard_velocity_enabled, \_observable
-> [boolean]
renoise.song().transport.keyboard_velocity, \_observable
-> [number, 0-127]

---

## -- renoise.PatternSequencer

-------- Functions

-- Insert the specified pattern at the given position in the sequence.
renoise.song().sequencer:insert_sequence_at(sequence_pos, pattern_index)
-- Insert an empty, unreferenced pattern at the given position.
renoise.song().sequencer:insert_new_pattern_at(sequence_pos)
-> [number, new pattern index]
-- Delete an existing position in the sequence. Renoise needs at least one
-- sequence in the song for playback. Completely removing all sequence positions
-- is not allowed.
renoise.song().sequencer:delete_sequence_at(sequence_pos)

-- Access to a single sequence by index (the pattern number). Use properties
-- 'pattern_sequence' to iterate over the whole sequence and to query the
-- sequence count.
renoise.song().sequencer:pattern(sequence_pos)
-> [number, pattern index]

-- Clone a sequence range, appending it right after to_sequence_pos.
-- Slot muting is copied as well.
renoise.song().sequencer:clone_range(from_sequence_pos, to_sequence_pos)
-- Make patterns in the given sequence pos range unique, if needed.
renoise.song().sequencer:make_range_unique(from_sequence_pos, to_sequence_pos)

-- Sort patterns in the sequence in ascending order, keeping the old pattern
-- data in place. Aka, this will only change the visual order of patterns, but
-- not change the song's structure.
renoise.song().sequencer:sort()

-- Access to pattern sequence sections. When the 'is_start_of_section flag' is
-- set for a sequence pos, a section ranges from this pos to the next pos
-- which starts a section, or till the end of the song when there are no others.
renoise.song().sequencer:sequence_is_start_of_section(sequence_index)
-> [boolean]
renoise.song().sequencer:set_sequence_is_start_of_section(
sequence_index, true_or_false)
renoise.song().sequencer:sequence_is_start_of_section_observable(sequence_index)
-> [renoise.Observable object]

-- Access to a pattern sequence section's name. Section names are only visible
-- for a sequence pos which starts the section (see sequence_is_start_of_section).
renoise.song().sequencer:sequence_section_name(sequence_index)
-> [string]
renoise.song().sequencer:set_sequence_section_name(sequence_index, string)
renoise.song().sequencer:sequence_section_name_observable(sequence_index)
-> [renoise.Observable object]

-- Returns true if the given sequence pos is part of a section, else false.
renoise.song().sequencer:sequence_is_part_of_section(sequence_index)
-> [boolean]
-- Returns true if the given sequence pos is the end of a section, else false
renoise.song().sequencer:sequence_is_end_of_section(sequence_index)
-> [boolean]

-- Observable, which is fired, whenever the section layout in the sequence
-- changed in any way, i.e. new sections got added, existing ones got deleted
renoise.song().sequencer:sequence_sections_changed_observable()
-> [renoise.Observable object]

-- Access to sequencer slot mute states. Mute slots are memorized in the
-- sequencer and not in the patterns.
renoise.song().sequencer:track_sequence_slot_is_muted(track_index, sequence_index)
-> [boolean]
renoise.song().sequencer:set_track_sequence_slot_is_muted(
track_index, sequence_index, muted)

-- Access to sequencer slot selection states.
renoise.song().sequencer:track_sequence_slot_is_selected(track_index, sequence_index)
-> [boolean]
renoise.song().sequencer:set_track_sequence_slot_is_selected(
track_index, sequence_index, selected)

-------- Properties

-- When true, the sequence will be auto sorted.
renoise.song().sequencer.keep_sequence_sorted, \_observable
-> [boolean]

-- Access to the selected slots in the sequencer. When no selection is present
-- {0,0} is returned, else a range between (1-#sequencer.pattern_sequence)
renoise.song().sequencer.selection_range[], \_observable
-> [array of two numbers, a range]

-- Pattern order list: Notifiers will only be fired when sequence positions are
-- added, removed or their order changed. To get notified of pattern assignment
-- changes use the property 'pattern_assignments_observable'.
renoise.song().sequencer.pattern_sequence[], \_observable
-> [array of numbers]
-- Attach notifiers that will be called as soon as any pattern assignment
-- at any sequence position changes.
renoise.song().sequencer.pattern_assignments_observable
-> [renoise.Observable object]

-- Attach notifiers that will be fired as soon as any slot muting property
-- in any track/sequence slot changes.
renoise.song().sequencer.pattern_slot_mutes_observable
-> [renoise.Observable object]

---

## -- renoise.PatternIterator

-- General remarks: Iterators can only be use in "for" loops like you would use
-- "pairs" in Lua, example:

-- for pos,line in pattern_iterator:lines_in_song do [...]

-- The returned 'pos' is a table with "pattern", "track", "line" fields, and an
-- additional "column" field for the note/effect columns.

-- The "visible_only" flag controls if all content should be traversed, or only
-- the currently used patterns, columns, and so on:
-- With "visible_patters_only" set, patterns are traversed in the order they
-- are referenced in the pattern sequence, but each pattern is accessed only
-- once. With "visible_columns_only" set, hidden columns are not traversed.

-------- Song

-- Iterate over all pattern lines in the song.
renoise.song().pattern_iterator:lines_in_song(boolean visible_patterns_only)
-> [iterator with pos, line (renoise.PatternLine object)]

-- Iterate over all note/effect\_ columns in the song.
renoise.song().pattern_iterator:note_columns_in_song(boolean visible_only)
-> [iterator with pos, column (renoise.NoteColumn object)]
renoise.song().pattern_iterator:effect_columns_in_song(boolean visible_only)
-> [iterator with pos, column (renoise.EffectColumn object)]

------- Pattern

-- Iterate over all lines in the given pattern only.
renoise.song().pattern_iterator:lines_in_pattern(pattern_index)
-> [iterator with pos, line (renoise.PatternLine object)]

-- Iterate over all note/effect columns in the specified pattern.
renoise.song().pattern_iterator:note_columns_in_pattern(
pattern_index, boolean visible_only)
-> [iterator with pos, column (renoise.NoteColumn object)]

renoise.song().pattern_iterator:effect_columns_in_pattern(
pattern_index, boolean visible_only)
-> [iterator with pos, column (renoise.EffectColumn object)]

------- Track

-- Iterate over all lines in the given track only.
renoise.song().pattern_iterator:lines_in_track(
track_index, boolean visible_patterns_only)
-> [iterator with pos, column (renoise.PatternLine object)]

-- Iterate over all note/effect columns in the specified track.
renoise.song().pattern_iterator:note_columns_in_track(
track_index, boolean visible_only)
-> [iterator with pos, line (renoise.NoteColumn object)]

renoise.song().pattern_iterator:effect_columns_in_track(
track_index, boolean visible_only)
-> [iterator with pos, column (renoise.EffectColumn object)]

------- Track in Pattern

-- Iterate over all lines in the given pattern, track only.
renoise.song().pattern_iterator:lines_in_pattern_track(
pattern_index, track_index)
-> [iterator with pos, line (renoise.PatternLine object)]

-- Iterate over all note/effect columns in the specified pattern track.
renoise.song().pattern_iterator:note_columns_in_pattern_track(
pattern_index, track_index, boolean visible_only)
-> [iterator with pos, column (renoise.NoteColumn object)]

renoise.song().pattern_iterator:effect_columns_in_pattern_track(
pattern_index, track_index, boolean visible_only)
-> [iterator with pos, column (renoise.EffectColumn object)]

---

## -- renoise.Track

-------- Constants

renoise.Track.TRACK_TYPE_SEQUENCER
renoise.Track.TRACK_TYPE_MASTER
renoise.Track.TRACK_TYPE_SEND
renoise.Track.TRACK_TYPE_GROUP

renoise.Track.MUTE_STATE_ACTIVE
renoise.Track.MUTE_STATE_OFF
renoise.Track.MUTE_STATE_MUTED

-------- Functions

-- Insert a new device at the given position. "device_path" must be one of
-- renoise.song().tracks[].available_devices.
renoise.song().tracks[]:insert_device_at(device_path, device_index)
-> [newly created renoise.AudioDevice object]
-- Delete an existing device in a track. The mixer device at index 1 can not
-- be deleted from a track.
renoise.song().tracks[]:delete_device_at(device_index)
-- Swap the positions of two devices in the device chain. The mixer device at
-- index 1 can not be swapped or moved.
renoise.song().tracks[]:swap_devices_at(device_index1, device_index2)

-- Access to a single device by index. Use properties 'devices' to iterate
-- over all devices and to query the device count.
renoise.song().tracks:device(index)
-> [renoise.AudioDevice object]

-- Uses default mute state from the prefs. Not for the master track.
renoise.song().tracks[]:mute()
renoise.song().tracks[]:unmute()
renoise.song().tracks[]:solo()

-- Note column mutes. Only valid within (1-track.max_note_columns)
renoise.song().tracks[]:column_is_muted(column)
-> [boolean]
renoise.song().tracks[]:column_is_muted_observable(column)
-> [Observable object]
renoise.song().tracks[]:set_column_is_muted(column, muted)

-- Note column names. Only valid within (1-track.max_note_columns)
renoise.song().tracks[]:column_name(column)
-> [string]
renoise.song().tracks[]:column_name_observable(column)
-> [Observable object]
renoise.song().tracks[]:set_column_name(column, name)

-- Swap the positions of two note or effect columns within a track.
renoise.song().tracks[]:swap_note_columns_at(index1, index2)
renoise.song().tracks[]:swap_effect_columns_at(index1, index2)

-------- Properties

-- Type, name, color.
renoise.song().tracks[].type
-> [read-only, enum = TRACK_TYPE]
renoise.song().tracks[].name, \_observable
-> [string]
renoise.song().tracks[].color[], \_observable
-> [array of 3 numbers (0-0xFF), RGB]

renoise.song().tracks[].color_blend, \_observable
-> [number, 0-100]

-- Mute and solo states. Not available for the master track.
renoise.song().tracks[].mute_state, \_observable
-> [enum = MUTE_STATE]

renoise.song().tracks[].solo_state, \_observable
-> [boolean]

-- Volume, panning, width.
renoise.song().tracks[].prefx_volume
-> [renoise.DeviceParameter object]
renoise.song().tracks[].prefx_panning
-> [renoise.DeviceParameter object]
renoise.song().tracks[].prefx_width
-> [renoise.DeviceParameter object]

renoise.song().tracks[].postfx_volume
-> [renoise.DeviceParameter object]
renoise.song().tracks[].postfx_panning
-> [renoise.DeviceParameter object]

-- Collapsed/expanded visual appearance.
renoise.song().tracks[].collapsed, \_observable
-> [boolean]

-- Returns most immediate group parent or nil if not in a group.
renoise.song().tracks[].group_parent
-> [renoise.GroupTrack object or nil]

-- Output routing.
renoise.song().tracks[].available_output_routings[]
-> [read-only, array of strings]
renoise.song().tracks[].output_routing, \_observable
-> [string, one of 'available_output_routings']

-- Delay.
renoise.song().tracks[].output_delay, \_observable
-> [number, -100.0-100.0]

-- Pattern editor columns.
renoise.song().tracks[].max_effect_columns
-> [read-only, number, 8 OR 0 depending on the track type]
renoise.song().tracks[].min_effect_columns
-> [read-only, number, 1 OR 0 depending on the track type]

renoise.song().tracks[].max_note_columns
-> [read-only, number, 12 OR 0 depending on the track type]
renoise.song().tracks[].min_note_columns
-> [read-only, number, 1 OR 0 depending on the track type]

renoise.song().tracks[].visible_effect_columns, \_observable
-> [number, 1-8 OR 0-8, depending on the track type]
renoise.song().tracks[].visible_note_columns, \_observable
-> [number, 0 OR 1-12, depending on the track type]

renoise.song().tracks[].volume_column_visible, \_observable
-> [boolean]
renoise.song().tracks[].panning_column_visible, \_observable
-> [boolean]
renoise.song().tracks[].delay_column_visible, \_observable
-> [boolean]
renoise.song().tracks[].sample_effects_column_visible, \_observable
-> [boolean]

-- Devices.
renoise.song().tracks[].available_devices[]
-> [read-only, array of strings]

-- Returns a list of tables containing more information about the devices.
-- Each table has the following fields:
-- {
-- path, -- The device's path used by insert_device_at()
-- name, -- The device's name
-- short_name, -- The device's name as displayed in shortened lists
-- favorite_name, -- The device's name as displayed in favorites
-- is_favorite, -- true if the device is a favorite
-- is_bridged -- true if the device is a bridged plugin
-- }
renoise.song().tracks[].available_device_infos[]
-> [read-only, array of strings]

renoise.song().tracks[].devices[], \_observable
-> [read-only, array of renoise.AudioDevice objects]

---

## -- renoise.GroupTrack (inherits from renoise.Track)

-------- Functions

-- All member tracks of this group (including subgroups and their tracks).
renoise.song().tracks[].members[]
-> [read-only, array of member tracks]

-- Collapsed/expanded visual appearance of whole group.
renoise.song().tracks[].group_collapsed
-> [boolean]

---

## -- renoise.TrackDevice

-- DEPRECATED - alias for renoise.AudioDevice

---

## -- renoise.AudioDevice

-------- Functions

-- Access to a single preset name by index. Use properties 'presets' to iterate
-- over all presets and to query the presets count.
renoise.song().tracks[].devices[]:preset(index)
-> [string]

-- Access to a single parameter by index. Use properties 'parameters' to iterate
-- over all parameters and to query the parameter count.
renoise.song().tracks[].devices[]:parameter(index)
-> [renoise.DeviceParameter object]

-------- Properties

-- Fixed name of the device.
renoise.song().tracks[].devices[].name
-> [read-only, string]
renoise.song().tracks[].devices[].short_name
-> [read-only, string]

-- Configurable device display name.
renoise.song().tracks[].devices[].display_name, observable
-> [string, long device name or custom name]

-- Enable/bypass the device.
renoise.song().tracks[].devices[].is_active, \_observable
-> [boolean, not active = bypassed]

-- Maximize state in DSP chain.
renoise.song().tracks[].devices[].is_maximized, \_observable
-> [boolean]

-- Preset handling.
renoise.song().tracks[].devices[].active_preset, \_observable
-> [number, 0 when none is active or available]
renoise.song().tracks[].devices[].active_preset_data
-> [string, raw serialized data in XML format of the active preset]
renoise.song().tracks[].devices[].presets[]
-> [read-only, array of strings]

-- Parameters.
renoise.song().tracks[].devices[].is_active_parameter
-> [read-only, renoise.DeviceParameter object]

renoise.song().tracks[].devices[].parameters[]
-> [read-only, array of renoise.DeviceParameter objects]

-- Returns whether or not the device provides its own custom GUI (only
-- available for some plugin devices)
renoise.song().tracks[].devices[].external_editor_available
-> [read-only, boolean]

-- When the device has no custom GUI an error will be fired (see
-- external_editor_available), otherwise the external editor is opened/closed.
renoise.song().tracks[].devices[].external_editor_visible
-> [boolean, true to show the editor, false to close it]

-- Returns a string that uniquely identifies the device, from "available_devices".
-- The string can be passed into: renoise.song().tracks[]:insert_device_at()
renoise.song().tracks[].devices[].device_path
-> [read-only, string]

---

## -- renoise.DeviceParameter

-------- Constants

renoise.DeviceParameter.POLARITY_UNIPOLAR
renoise.DeviceParameter.POLARITY_BIPOLAR

-------- Functions

-- Set a new value and write automation when the MIDI mapping
-- "record to automation" option is set. Only works for parameters
-- of track devices, not for instrument devices.
renoise.song().tracks[].devices[].parameters[]:record_value(value)

-------- Properties

-- Device parameters.
renoise.song().tracks[].devices[].parameters[].name
-> [read-only, string]

renoise.song().tracks[].devices[].parameters[].polarity
-> [read-only, enum = POLARITY]

renoise.song().tracks[].devices[].parameters[].value_min
-> [read-only, number]
renoise.song().tracks[].devices[].parameters[].value_max
-> [read-only, number]
renoise.song().tracks[].devices[].parameters[].value_quantum
-> [read-only, number]
renoise.song().tracks[].devices[].parameters[].value_default
-> [read-only, number]

-- The minimum interval in pattern lines (as a number) at which a parameter can
-- have automation points. It is 1/256 for most parameters, but 1 for e.g. song
-- tempo, LPB and TPL which can only be automated once per pattern line.
renoise.song().tracks[].devices[].parameters[].time_quantum
-> [read-only, number]

-- Not valid for parameters of instrument devices. Returns true if creating
-- envelope automation is possible for the parameter (see also
-- renoise.song().patterns[].tracks[]:create_automation)
renoise.song().tracks[].devices[].parameters[].is_automatable
-> [read-only, boolean]

-- Is automated. Not valid for parameters of instrument devices.
renoise.song().tracks[].devices[].parameters[].is_automated, \_observable
-> [read-only, boolean]

-- parameter has a custom MIDI mapping in the current song.
renoise.song().tracks[].devices[].parameters[].is_midi_mapped, \_observable
-> [read-only, boolean]

-- Show in mixer. Not valid for parameters of instrument devices.
renoise.song().tracks[].devices[].parameters[].show_in_mixer, \_observable
-> [boolean]

-- Values.
renoise.song().tracks[].devices[].parameters[].value, \_observable
-> [number]
renoise.song().tracks[].devices[].parameters[].value_string, \_observable
-> [string]

---

## -- renoise.Instrument

-------- Constants

renoise.Instrument.TAB_SAMPLES
renoise.Instrument.TAB_PLUGIN
renoise.Instrument.TAB_EXT_MIDI

renoise.Instrument.PHRASES_OFF
renoise.Instrument.PHRASES_PLAY_SELECTIVE
renoise.Instrument.PHRASES_PLAY_KEYMAP

renoise.Instrument.LAYER_NOTE_DISABLED
renoise.Instrument.LAYER_NOTE_ON
renoise.Instrument.LAYER_NOTE_OFF

renoise.Instrument.OVERLAP_MODE_ALL
renoise.Instrument.OVERLAP_MODE_CYCLED
renoise.Instrument.OVERLAP_MODE_RANDOM

renoise.Instrument.NUMBER_OF_MACROS

renoise.Instrument.MAX_NUMBER_OF_PHRASES

-------- Functions

-- Reset, clear all settings and all samples.
renoise.song().instruments[]:clear()

-- Copy all settings from the other instrument, including all samples.
renoise.song().instruments[]:copy_from(
other renoise.Instrument object)

-- Access a single macro by index [1-NUMBER_OF_MACROS].
-- See also property 'macros'.
renoise.song().instruments[]:macro(index)
-> [returns renoise.InstrumentMacro]

-- Insert a new phrase behind the given phrase index (1 for the first one).
renoise.song().instruments[]:insert_phrase_at(index)
-> [returns newly created renoise.InstrumentPhrase]
-- Delete a new phrase at the given phrase index.
renoise.song().instruments[]:delete_phrase_at(index)

-- Access a single phrase by index. Use properties 'phrases' to iterate
-- over all phrases and to query the phrase count.
renoise.song().instruments[]:phrase(index)
-> [renoise.InstrumentPhrase object]

-- Returns true if a new phrase mapping can be inserted at the given
-- phrase mapping index (see See renoise.song().instruments[].phrase_mappings).
-- Passed phrase must exist and must not have a mapping yet.
-- Phrase note mappings may not overlap and are sorted by note, so there
-- can be max 119 phrases per instrument when each phrase is mapped to
-- a single key only. To make up room for new phrases, access phrases by
-- index, adjust their note_range, then call 'insert_phrase_mapping_at' again.
renoise.song().instruments[]:can_insert_phrase_mapping_at(index)
-> [boolean]
-- Insert a new phrase mapping behind the given phrase mapping index.
-- The new phrase mapping will by default use the entire free (note) range
-- between the previous and next phrase (if any). To adjust the note range
-- of the new phrase change its 'new_phrase_mapping.note_range' property.
renoise.song().instruments[]:insert_phrase_mapping_at(index, phrase)
-> [returns newly created renoise.InstrumentPhraseMapping]
-- Delete a new phrase mapping at the given phrase mapping index.
renoise.song().instruments[]:delete_phrase_mapping_at(index)

-- Access to a phrase note mapping by index. Use property 'phrase_mappings' to
-- iterate over all phrase mappings and to query the phrase (mapping) count.
renoise.song().instruments[]:phrase_mapping(index)
-> [renoise.InstrumentPhraseMapping object]

-- Insert a new empty sample. returns the new renoise.Sample object.
-- Every newly inserted sample has a default mapping, which covers the
-- entire key and velocity range, or it gets added as drum kit mapping
-- when the instrument used a drum-kit mapping before the sample got added.
renoise.song().instruments[]:insert_sample_at(index)
-> [new renoise.Sample object]
-- Delete an existing sample.
renoise.song().instruments[]:delete_sample_at(index)
-- Swap positions of two samples.
renoise.song().instruments[]:swap_samples_at(index1, index2)

-- Access to a single sample by index. Use properties 'samples' to iterate
-- over all samples and to query the sample count.
renoise.song().instruments[]:sample(index)
-> [renoise.Sample object]

-- Access to a sample mapping by index. Use property 'sample_mappings' to
-- iterate over all sample mappings and to query the sample (mapping) count.
renoise.song().instruments[]:sample_mapping(layer, index)
-> [renoise.SampleMapping object]

-- Insert a new modulation set at the given index
renoise.song().instruments[]:insert_sample_modulation_set_at(index)
-> [new renoise.SampleModulationSet object]
-- Delete an existing modulation set at the given index.
renoise.song().instruments[]:delete_sample_modulation_set_at(index)
-- Swap positions of two modulation sets.
renoise.song().instruments[]:swap_sample_modulation_sets_at(index1, index2)

-- Access to a single sample modulation set by index. Use property
-- 'sample_modulation_sets' to iterate over all sets and to query the set count.
renoise.song().instruments[]:sample_modulation_set(index)
-> [renoise.SampleModulationSet object]

-- Insert a new sample device chain at the given index.
renoise.song().instruments[]:insert_sample_device_chain_at(index)
-> [returns newly created renoise.SampleDeviceChain]
-- Delete an existing sample device chain at the given index.
renoise.song().instruments[]:delete_sample_device_chain_at(index)
-- Swap positions of two sample device chains.
renoise.song().instruments[]:swap_sample_device_chains_at(index1, index2)

-- Access to a single device chain by index. Use property 'sample_device_chains'
-- to iterate over all chains and to query the chain count.
renoise.song().instruments[]:sample_device_chain(index)
-> [renoise.SampleDeviceChain object]

-------- Properties

-- Currently active tab in the instrument GUI (samples, plugin or MIDI).
renoise.song().instruments[].active_tab, \_observable
-> [enum = TAB]

-- Instrument's name.
renoise.song().instruments[].name, \_observable
-> [string]

-- Instrument's comment list. See renoise.song().comments for more info on
-- how to get notified on changes and how to change it.
renoise.song().instruments[].comments[], \_observable
-> [array of strings]
-- Notifier which is called as soon as any paragraph in the comments change.
renoise.song().instruments[].comments_assignment_observable
-> [renoise.Observable object]
-- Set this to true to show the comments dialog after loading a song
renoise.song().instruments[].show_comments_after_loading, \_observable
-> [boolean]

-- Macro parameter pane visibility in the GUI.
renoise.song().instruments[].macros_visible, \_observable
-> [boolean]

-- Macro parameters.
renoise.song().instruments[].macros[]
-> [read-only, array of NUMBER_OF_MACROS renoise.InstrumentMacro objects]

-- Access the MIDI pitch-bend macro
renoise.song().instruments[].pitchbend_macro
-> [returns renoise.InstrumentMacro]

-- Access the MIDI modulation-wheel macro
renoise.song().instruments[].modulation_wheel_macro
-> [returns renoise.InstrumentMacro]

-- Access the MIDI channel pressure macro
renoise.song().instruments[].channel_pressure_macro
-> [returns renoise.InstrumentMacro]

-- Global linear volume of the instrument. Applied to all samples, MIDI and
-- plugins in the instrument.
renoise.song().instruments[].volume, \_observable
-> [number, 0-math.db2lin(6)]

-- Global relative pitch in semi tones. Applied to all samples, MIDI and
-- plugins in the instrument.
renoise.song().instruments[].transpose, \_observable
-> [number, -120-120]

-- Global trigger options (quantization and scaling options).
-- See renoise.InstrumentTriggerOptions for more info.
renoise.song().instruments[].trigger_options
-> [renoise.InstrumentTriggerOptions object]

-- Sample mapping's overlap trigger mode.
renoise.song().instruments[]:sample_mapping_overlap_mode, observable
-> [enum=OVERLAP_MODE]

-- Phrase editor pane visibility in the GUI.
renoise.song().instruments[].phrase_editor_visible, \_observable
-> [boolean]

-- Phrase playback. See PHRASES_XXX values.
renoise.song().instruments[].phrase_playback_mode, \_observable
-> [enum=PHRASES]
-- Phrase playback program: 0 = Off, 1-126 = specific phrase, 127 = keymap.
renoise.song().instruments[].phrase_program, \_observable
-> [number]

-- Phrases.
renoise.song().instruments[].phrases[], \_observable
-> [read-only, array of renoise.InstrumentPhrase objects]
-- Phrase mappings.
renoise.song().instruments[].phrase_mappings[], \_observable
-> [read-only, array of renoise.InstrumentPhraseMapping objects]

-- Samples slots.
renoise.song().instruments[].samples[], \_observable
-> [read-only, array of renoise.Sample objects]

-- Sample mappings (key/velocity to sample slot mappings).
-- sample_mappings[LAYER_NOTE_ON/OFF][]. Sample mappings also can
-- be accessed via renoise.song().instruments[].samples[].sample_mapping
renoise.song().instruments[].sample_mappings[], \_observable
-> [read-only, array of tables of renoise.SampleMapping objects]

-- Sample modulation sets.
renoise.song().instruments[].sample_modulation_sets, \_observable
-> [read-only, table of renoise.SampleModulationSet objects]

-- Sample device chains.
renoise.song().instruments[].sample_device_chains
-> [read-only, table of renoise.SampleDeviceChain objects]

-- MIDI input properties.
renoise.song().instruments[].midi_input_properties
-> [read-only, renoise.InstrumentMidiInputProperties object]

-- MIDI output properties.
renoise.song().instruments[].midi_output_properties
-> [read-only, renoise.InstrumentMidiOutputProperties object]

-- Plugin properties.
renoise.song().instruments[].plugin_properties
-> [read-only, renoise.InstrumentPluginProperties object]

---

## -- renoise.InstrumentTriggerOptions

-------- Constants

renoise.InstrumentTriggerOptions.QUANTIZE_NONE
renoise.InstrumentTriggerOptions.QUANTIZE_LINE
renoise.InstrumentTriggerOptions.QUANTIZE_BEAT
renoise.InstrumentTriggerOptions.QUANTIZE_BAR

-------- Properties

-- List of all available scale modes.
renoise.song().instruments[].trigger_options.available_scale_modes
-> [read-only, table of strings]

-- Scale to use when transposing. One of 'available_scales'.
renoise.song().instruments[].trigger_options.scale_mode, \_observable
-> [string, one of 'available_scales']

-- Scale-key to use when transposing (1=C, 2=C#, 3=D, ...)
renoise.song().instruments[].trigger_options.scale_key, \_observable
-> [number]

-- Trigger quantization mode.
renoise.song().instruments[].trigger_options.quantize, \_observable
-> [enum = QUANTIZE]

-- Mono/Poly mode.
renoise.song().instruments[].trigger_options.monophonic, \_observable
-> [boolean]

-- Glide amount when monophonic. 0 == off, 255 = instant
renoise.song().instruments[].trigger_options.monophonic_glide, \_observable
-> [number]

---

## -- renoise.InstrumentMacro

-------- Functions

-- Access to a single attached parameter mapping by index. Use property
-- 'mappings' to query mapping count.
renoise.song().instruments[].macros[]:mapping(index)
-> [renoise.InstrumentMacroMapping object]

-------- Properties

-- Macro name as visible in the GUI when mappings are presents.
renoise.song().instruments[].macros[].name, \_observable
-> [string]

-- Macro value.
renoise.song().instruments[].macros[].value, \_observable
-> [number, 0-1]
-- Macro value string (0-100).
renoise.song().instruments[].macros[].value_string, \_observable
-> [string]

-- Macro mappings, target parameters.
renoise.song().instruments[].macros[].mappings[], \_observable
-> [read-only, array of renoise.InstrumentMacroMapping objects]

---

## -- renoise.InstrumentMacroMapping

-------- Constants

renoise.InstrumentMacroMapping.SCALING_LOG_FAST
renoise.InstrumentMacroMapping.SCALING_LOG_SLOW
renoise.InstrumentMacroMapping.SCALING_LINEAR
renoise.InstrumentMacroMapping.SCALING_EXP_SLOW
renoise.InstrumentMacroMapping.SCALING_EXP_FAST

-------- Properties

-- Linked parameter. Can be a sample FX- or modulation parameter. Never nil.
renoise.song().instruments[].macros[].mappings[].parameter
-> [read-only, renoise.DeviceParameter]

-- Min/max range in which the macro applies its value to the target parameter.
-- Max can be < than Min. Mapping is then flipped.
renoise.song().instruments[].macros[].mappings[].parameter_min, \_observable
-> [number, 0-1]
renoise.song().instruments[].macros[].mappings[].parameter_max, \_observable
-> [number, 0-1]

-- Scaling which gets applied within the min/max range to set the dest value.
renoise.song().instruments[].macros[].mappings[].parameter_scaling, \_observable
-> [enum = SCALING]

---

## -- renoise.InstrumentPhrase

-- General remarks: Phrases do use renoise.PatternLine objects just like the
-- pattern tracks do. When the instrument column is enabled and used,
-- not instruments, but samples are addressed/triggered in phrases.

-------- Constants

-- Maximum number of lines that can be present in a phrase.
renoise.InstrumentPhrase.MAX_NUMBER_OF_LINES

-- Min/Maximum number of note columns that can be present in a phrase.
renoise.InstrumentPhrase.MIN_NUMBER_OF_NOTE_COLUMNS
renoise.InstrumentPhrase.MAX_NUMBER_OF_NOTE_COLUMNS

-- Min/Maximum number of effect columns that can be present in a phrase.
renoise.InstrumentPhrase.MIN_NUMBER_OF_EFFECT_COLUMNS
renoise.InstrumentPhrase.MAX_NUMBER_OF_EFFECT_COLUMNS

-- See InstrumentPhraseMapping KEY_TRACKING
renoise.InstrumentPhrase.KEY_TRACKING_NONE
renoise.InstrumentPhrase.KEY_TRACKING_TRANSPOSE
renoise.InstrumentPhrase.KEY_TRACKING_OFFSET

-------- Functions

-- Deletes all lines.
renoise.song().instruments[].phrases[]:clear()

-- Copy contents from another phrase.
renoise.song().instruments[].phrases[]:copy_from(
other renoise.InstrumentPhrase object)

-- Access to a single line by index. Line must be [1-MAX_NUMBER_OF_LINES]).
-- This is a !lot! more efficient than calling the property: lines[index] to
-- randomly access lines.
renoise.song().instruments[].phrases[]:line(index)
-> [renoise.PatternLine object]
-- Get a specific line range (index must be [1-MAX_NUMBER_OF_LINES])
renoise.song().instruments[].phrases[]:lines_in_range(index_from, index_to)
-> [array of renoise.PatternLine objects]

-- Check/add/remove notifier functions or methods, which are called by
-- Renoise as soon as any of the phrases's lines have changed.
-- See renoise.song().patterns[]:has_line_notifier for more details.
renoise.song().instruments[].phrases[]:has_line_notifier(func [, obj])
-> [boolean]
renoise.song().instruments[].phrases[]:add_line_notifier(func [, obj])
renoise.song().instruments[].phrases[]:remove_line_notifier(func [, obj])

-- Same as line_notifier above, but the notifier only fires when the user
-- added, changed or deleted a line with the computer keyboard.
renoise.song().instruments[].phrases[]:has_line_edited_notifier(func [, obj])
-> [boolean]
renoise.song().instruments[].phrases[]:add_line_edited_notifier(func [, obj])
renoise.song().instruments[].phrases[]:remove_line_edited_notifier(func [, obj])

-- Note column mute states. Only valid within (1-MAX_NUMBER_OF_NOTE_COLUMNS)
renoise.song().instruments[].phrases[]:column_is_muted(column)
-> [boolean]
renoise.song().instruments[].phrases[]:column_is_muted_observable(column)
-> [Observable object]
renoise.song().instruments[].phrases[]:set_column_is_muted(column, muted)

-- Note column names. Only valid within (1-MAX_NUMBER_OF_NOTE_COLUMNS)
renoise.song().instruments[].phrases[]:column_name(column)
-> [string]
renoise.song().instruments[].phrases[]:column_name_observable(column)
-> [Observable object]
renoise.song().instruments[].phrases[]:set_column_name(column, name)

-- Swap the positions of two note or effect columns within a phrase.
renoise.song().instruments[].phrases[]:swap_note_columns_at(index1, index2)
renoise.song().instruments[].phrases[]:swap_effect_columns_at(index1, index2)

-------- Properties

-- Name of the phrase as visible in the phrase editor and piano mappings.
renoise.song().instruments[].phrases[].name, \_observable
-> [string]

-- (Key)Mapping properties of the phrase or nil when no mapping is present.
renoise.song().instruments[].phrases[].mapping
-> [renoise.InstrumentPhraseMapping object or nil]

-- Quickly check if a phrase has some non empty pattern lines.
renoise.song().instruments[].phrases[].is_empty, \_observable
-> [read-only, boolean]

-- Number of lines the phrase currently has. 16 by default. Max is
-- renoise.InstrumentPhrase.MAX_NUMBER_OF_LINES, min is 1.
renoise.song().instruments[].phrases[].number_of_lines, \_observable
-> [number, 1-MAX_NUMBER_OF_LINES]

-- Get all lines in a range [1, number_of_lines_in_pattern]
renoise.song().instruments[].phrases[].lines[]
-> [read-only, array of renoise.PatternLine objects]

-- How many note columns are visible in the phrase.
renoise.song().instruments[].phrases[].visible_note_columns, \_observable
-> [number, MIN_NUMBER_OF_NOTE_COLUMNS-MAX_NUMBER_OF_NOTE_COLUMNS]
-- How many effect columns are visible in the phrase.
renoise.song().instruments[].phrases[].visible_effect_columns, \_observable
-> [number, MIN_NUMBER_OF_EFFECT_COLUMNS-MAX_NUMBER_OF_EFFECT_COLUMNS]

-- Phrase's key-tracking mode.
renoise.song().instruments[].phrases[].key_tracking, \_observable
-> [enum = KEY_TRACKING]

-- Phrase's base-note. Only relevant when key_tracking is set to transpose.
renoise.song().instruments[].phrases[].base_note, \_observable
-> [number, 0-119, c-4=48]

-- Loop mode. The phrase plays as one-shot when disabled.
renoise.song().instruments[].phrases[].looping, \_observable
-> [boolean]

-- Loop start. Playback will start from the beginning before entering loop
renoise.song().instruments[].phrases[].loop_start, \_observable
-> [number, 1-number_of_lines]
-- Loop end. Needs to be > loop_start and <= number_of_lines
renoise.song().instruments[].phrases[].loop_end, \_observable
-> [number, loop_start-number_of_lines]

-- Phrase autoseek settings.
renoise.song().instruments[].phrases[].autoseek, \_observable
-> [boolean]

-- Phrase local lines per beat setting. New phrases get initialized with
-- the song's current LPB setting. TPL can not be configured in phrases.
renoise.song().instruments[].phrases[].lpb, \_observable
-> [number, 1-256]

-- Shuffle groove amount for a phrase.
-- 0.0 = no shuffle (off), 1.0 = full shuffle
renoise.song().instruments[].phrases[].shuffle, \_observable
-> [number, 0-1]

-- Column visibility.
renoise.song().instruments[].phrases[].instrument_column_visible, \_observable
-> [boolean]
renoise.song().instruments[].phrases[].volume_column_visible, \_observable
-> [boolean]
renoise.song().instruments[].phrases[].panning_column_visible, \_observable
-> [boolean]
renoise.song().instruments[].phrases[].delay_column_visible, \_observable
-> [boolean]
renoise.song().instruments[].phrases[].sample_effects_column_visible, \_observable
-> [boolean]

-------- Operators

-- Compares line content. All other properties are ignored.
==(InstrumentPhrase object, InstrumentPhrase object)
-> [boolean]
~=(InstrumentPhrase object, InstrumentPhrase object)
-> [boolean]

---

## -- renoise.InstrumentPhraseMapping

-------- Constants

-- Every note plays back the phrase unpitched from line 1.
renoise.InstrumentPhraseMapping.KEY_TRACKING_NONE
-- Play the phrase transposed relative to the phrase's base_note.
renoise.InstrumentPhraseMapping.KEY_TRACKING_TRANSPOSE
-- Trigger phrase from the beginning (note_range start) up to the end (note_range end).
renoise.InstrumentPhraseMapping.KEY_TRACKING_OFFSET

-------- Properties

-- Linked phrase.
renoise.song().instruments[].phrases[].mapping.phrase
-> [renoise.InstrumentPhrase object]

-- Phrase's key-tracking mode.
renoise.song().instruments[].phrases[].mapping.key_tracking, \_observable
-> [enum = KEY_TRACKING]

-- Phrase's base-note. Only relevant when key_tracking is set to transpose.
renoise.song().instruments[].phrases[].mapping.base_note, \_observable
-> [number, 0-119, c-4=48]

-- Note range the mapping is triggered at. Phrases may not overlap, so
-- note_range start can only be set behind previous's (if any) end and
-- note_range end can only be set before next mapping's (if any) start.
renoise.song().instruments[].phrases[].mapping.note_range, \_observable
-> [table with two numbers (0-119, c-4=48)]

-- Loop mode. The phrase plays as one-shot when disabled.
renoise.song().instruments[].phrases[].mapping.looping, \_observable
-> [boolean]
renoise.song().instruments[].phrases[].mapping.loop_start, \_observable
-> [number]
renoise.song().instruments[].phrases[].mapping.loop_end, \_observable
-> [number]

---

## -- renoise.InstrumentMidiInputProperties

-------- Properties

-- When setting new devices, device names must be one of
-- renoise.Midi.available_input_devices.
-- Devices are automatically opened when needed. To close a device, set its
-- name to "", e.g. an empty string.
renoise.song().instruments[].midi_input_properties.device_name, \_observable
-> [string]
renoise.song().instruments[].midi_input_properties.channel, \_observable
-> [number, 1-16, 0=Omni]
renoise.song().instruments[].midi_input_properties.note_range, \_observable
-> [table with two numbers (0-119, c-4=48)]
renoise.song().instruments[].midi_input_properties.assigned_track, \_observable
-> [number, 1-renoise.song().sequencer_track_count, 0 = Current track]

---

## -- renoise.SampleModulationDevice

--------- Constants

renoise.SampleModulationDevice.TARGET_VOLUME
renoise.SampleModulationDevice.TARGET_PANNING
renoise.SampleModulationDevice.TARGET_PITCH
renoise.SampleModulationDevice.TARGET_CUTOFF
renoise.SampleModulationDevice.TARGET_RESONANCE
renoise.SampleModulationDevice.TARGET_DRIVE

renoise.SampleModulationDevice.OPERATOR_ADD
renoise.SampleModulationDevice.OPERATOR_SUB
renoise.SampleModulationDevice.OPERATOR_MUL
renoise.SampleModulationDevice.OPERATOR_DIV

--------- functions

-- Reset the device to its default state.
renoise.song().instruments[].sample_modulation_sets[].devices[]:init()

-- Copy a device's state from another device. 'other_device' must be of the
-- same type.
renoise.song().instruments[].sample_modulation_sets[].devices[]:copy_from(
other renoise.SampleModulationDevice object)

-- Access to a single parameter by index. Use properties 'parameters' to iterate
-- over all parameters and to query the parameter count.
renoise.song().instruments[].sample_modulation_sets[].devices[]:parameter(index)
-> [renoise.DeviceParameter object]

--------- properties

-- Fixed name of the device.
renoise.song().instruments[].sample_modulation_sets[].devices[].name
-> [read-only, string]
renoise.song().instruments[].sample_modulation_sets[].devices[].short_name
-> [read-only, string]

-- Configurable device display name.
renoise.song().instruments[].sample_modulation_sets[].devices[].display_name, observable
-> [string]

-- DEPRECATED: use 'is_active' instead
renoise.song().instruments[].sample_modulation_sets[].devices[].enabled, \_observable
-> [boolean]
-- Enable/bypass the device.
renoise.song().instruments[].sample_modulation_sets[].devices[].is_active, \_observable
-> [boolean, not active = bypassed]

-- Maximize state in modulation chain.
renoise.song().instruments[].sample_modulation_sets[].devices[].is_maximized, \_observable
-> [boolean]

-- Where the modulation gets applied (Volume, Pan, Pitch, Cutoff, Resonance).
renoise.song().instruments[].sample_modulation_sets[].devices[].target
-> [read-only, enum = TARGET]

-- Modulation operator: how the device applies.
renoise.song().instruments[].sample_modulation_sets[].devices[].operator, \_observable
-> [enum = OPERATOR]

-- Modulation polarity: when bipolar, the device applies it's values in a -1 to 1 range,
-- when unipolar in a 0 to 1 range.
renoise.song().instruments[].sample_modulation_sets[].devices[].bipolar, observable
-> [boolean]

-- When true, the device has one of more time parameters, which can be switched to operate
-- in synced or unsynced mode (see tempo_synced)
renoise.song().instruments[].sample_modulation_sets[].devices[].tempo_sync_switching_allowed
-> [read-only, boolean]
-- When true and the device supports sync switching (see 'tempo_sync_switching_allowed'),
-- the device operates in wall-clock (ms) instead of beat times.
renoise.song().instruments[].sample_modulation_sets[].devices[].tempo_synced, observable
-> [boolean]

-- Generic access to all parameters of this device.
renoise.song().instruments[].sample_modulation_sets[].devices[].is_active_parameter
-> [read-only, renoise.DeviceParameter object]

renoise.song().instruments[].sample_modulation_sets[].devices[].parameters[]
-> [read-only, array of renoise.DeviceParameter objects]

---

## -- renoise.SampleOperandModulationDevice (inherits from renoise.SampleModulationDevice)

-------- Properties

-- Operand value.
renoise.song().instruments[].sample_modulation_sets[].devices[].value
-> [renoise.DeviceParameter object, -1-1]

---

## -- renoise.SampleFaderModulationDevice (inherits from renoise.SampleModulationDevice)

--------- Constants

renoise.SampleFaderModulationDevice.SCALING_LOG_FAST
renoise.SampleFaderModulationDevice.SCALING_LOG_SLOW
renoise.SampleFaderModulationDevice.SCALING_LINEAR
renoise.SampleFaderModulationDevice.SCALING_EXP_SLOW
renoise.SampleFaderModulationDevice.SCALING_EXP_FAST

-------- Properties

-- Scaling mode.
renoise.song().instruments[].sample_modulation_sets[].devices[].scaling, \_observable
-> [enum = SCALING]

-- Start & Target value.
renoise.song().instruments[].sample_modulation_sets[].devices[].from
-> [renoise.DeviceParameter object, 0-1]
renoise.song().instruments[].sample_modulation_sets[].devices[].to
-> [renoise.DeviceParameter object, 0-1]

-- Duration.
renoise.song().instruments[].sample_modulation_sets[].devices[].duration
-> [renoise.DeviceParameter object, 0-1]

-- Delay.
renoise.song().instruments[].sample_modulation_sets[].devices[].delay
-> [renoise.DeviceParameter object, 0-1]

---

## -- renoise.SampleAhdrsModulationDevice (inherits from renoise.SampleModulationDevice)

-------- Properties

-- Attack duration.
renoise.song().instruments[].sample_modulation_sets[].devices[].attack
-> [renoise.DeviceParameter object, 0-1]

-- Hold duration.
renoise.song().instruments[].sample_modulation_sets[].devices[].hold
-> [renoise.DeviceParameter object, 0-1]

-- Duration.
renoise.song().instruments[].sample_modulation_sets[].devices[].duration
-> [renoise.DeviceParameter object, 0-1]

-- Sustain amount.
renoise.song().instruments[].sample_modulation_sets[].devices[].sustain
-> [renoise.DeviceParameter object, 0-1]

-- Release duration.
renoise.song().instruments[].sample_modulation_sets[].devices[].release
-> [renoise.DeviceParameter object, 0-1]

---

## -- renoise.SampleKeyTrackingModulationDevice (inherits from renoise.SampleModulationDevice)

-------- Properties

-- Min/Max key value.
renoise.song().instruments[].sample_modulation_sets[].devices[].min
-> [renoise.DeviceParameter object, 0-119]
renoise.song().instruments[].sample_modulation_sets[].devices[].max
-> [renoise.DeviceParameter object, 0-119]

---

## -- renoise.SampleVelocityTrackingModulationDevice (inherits from renoise.SampleModulationDevice)

--------- Constants

renoise.SampleVelocityTrackingModulationDevice.MODE_CLAMP
renoise.SampleVelocityTrackingModulationDevice.MODE_SCALE

-------- Properties

-- Mode.
renoise.song().instruments[].sample_modulation_sets[].devices[].mode, \_observable
-> [enum = MODE]

-- Min/Max velocity.
renoise.song().instruments[].sample_modulation_sets[].devices[].min
-> [renoise.DeviceParameter object, 0-127]
renoise.song().instruments[].sample_modulation_sets[].devices[].max
-> [renoise.DeviceParameter object, 0-127]

---

## -- renoise.SampleEnvelopeModulationDevice (inherits from renoise.SampleModulationDevice)

--------- Constants

renoise.SampleEnvelopeModulationDevice.PLAYMODE_POINTS
renoise.SampleEnvelopeModulationDevice.PLAYMODE_LINES
renoise.SampleEnvelopeModulationDevice.PLAYMODE_CURVES

renoise.SampleEnvelopeModulationDevice.LOOP_MODE_OFF
renoise.SampleEnvelopeModulationDevice.LOOP_MODE_FORWARD
renoise.SampleEnvelopeModulationDevice.LOOP_MODE_REVERSE
renoise.SampleEnvelopeModulationDevice.LOOP_MODE_PING_PONG

renoise.SampleEnvelopeModulationDevice.MIN_NUMBER_OF_POINTS
renoise.SampleEnvelopeModulationDevice.MAX_NUMBER_OF_POINTS

-------- Functions

-- Reset the envelope back to its default initial state.
renoise.song().instruments[].sample_modulation_sets[].devices[]:init()

-- Copy all properties from another SampleEnvelopeModulation object.
renoise.song().instruments[].sample_modulation_sets[].devices[]:copy_from(
other renoise.SampleEnvelopeModulationDevice object)

-- Remove all points from the envelope.
renoise.song().instruments[].sample_modulation_sets[].devices[]:clear_points()
-- Remove points in the given [from, to) time range from the envelope.
renoise.song().instruments[].sample_modulation_sets[].devices[]:clear_points_in_range(
-- from_time, to_time)

-- Copy all points from another SampleEnvelopeModulation object.
renoise.song().instruments[].sample_modulation_sets[].devices[]:copy_points_from(
other SampleEnvelopeModulationDevice object)

-- Test if a point exists at the given time.
renoise.song().instruments[].sample_modulation_sets[].devices[]:has_point_at(time)
-> [boolean]
-- Add a new point value (or replace any existing value) at time.
renoise.song().instruments[].sample_modulation_sets[].devices[]:add_point_at(
time, value [, scaling])
-- Removes a point at the given time. Point must exist.
renoise.song().instruments[].sample_modulation_sets[].devices[]:remove_point_at(time)

-------- Properties

-- External editor visibility.
renoise.song().instruments[].sample_modulation_sets[].devices[].external_editor_visible
-> [boolean, set to true to show he editor, false to close it]

-- Play mode (interpolation mode).
renoise.song().instruments[].sample_modulation_sets[].devices[].play_mode, \_observable
-> [enum = PLAYMODE]

-- Envelope length.
renoise.song().instruments[].sample_modulation_sets[].devices[].length, \_observable
-> [number, 6-1000]

-- Loop.
renoise.song().instruments[].sample_modulation_sets[].devices[].loop_mode, \_observable
-> [enum = LOOP_MODE]
renoise.song().instruments[].sample_modulation_sets[].devices[].loop_start, \_observable
-> [number, 1-envelope.length]
renoise.song().instruments[].sample_modulation_sets[].devices[].loop_end, \_observable
-> [number, 1-envelope.length]

-- Sustain.
renoise.song().instruments[].sample_modulation_sets[].devices[].sustain_enabled, \_observable
-> [boolean]
renoise.song().instruments[].sample_modulation_sets[].devices[].sustain_position, \_observable
-> [number, 1-envelope.length]

-- Fade amount. (Only applies to volume envelopes)
renoise.song().instruments[].sample_modulation_sets[].devices[].fade_amount, \_observable
-> [number, 0-4095]

-- Get all points of the envelope. When setting a new list of points,
-- items may be unsorted by time, but there may not be multiple points
-- for the same time. Returns a copy of the list, so changing
-- `points[1].value` will not do anything. Instead, change them via
-- `points = { something }` instead.
renoise.song().instruments[].sample_modulation_sets[].devices[].points[], \_observable
-> [array of {time, value} tables]

-- An envelope point's time.
renoise.song().instruments[].sample_modulation_sets[].devices[].points[].time
-> [number, 1 - envelope.length]
-- An envelope point's value.
renoise.song().instruments[].sample_modulation_sets[].devices[].points[].value
-> [number, 0.0 - 1.0]
-- An envelope point's scaling (used in 'lines' playback mode only - 0.0 is linear).
renoise.song().instruments[].sample_modulation_sets[].devices[].points[].scaling
-> [number, -1.0 - 1.0]

---

## -- renoise.SampleStepperModulationDevice (inherits from renoise.SampleModulationDevice)

--------- Constants

renoise.SampleStepperModulationDevice.PLAYMODE_POINTS
renoise.SampleStepperModulationDevice.PLAYMODE_LINES
renoise.SampleStepperModulationDevice.PLAYMODE_CURVES

renoise.SampleStepperModulationDevice.MIN_NUMBER_OF_POINTS
renoise.SampleStepperModulationDevice.MAX_NUMBER_OF_POINTS

-------- Functions

-- Reset the envelope back to its default initial state.
renoise.song().instruments[].sample_modulation_sets[].devices[]:init()

-- Copy all properties from another SampleStepperModulation object.
renoise.song().instruments[].sample_modulation_sets[].devices[]:copy_from(
other renoise.SampleStepperModulationDevice object)

-- Remove all points from the envelope.
renoise.song().instruments[].sample_modulation_sets[].devices[]:clear_points()
-- Remove points in the given [from, to) time range from the envelope.
renoise.song().instruments[].sample_modulation_sets[].devices[]:clear_points_in_range(
-- from_time, to_time)

-- Copy all points from another SampleStepperModulation object.
renoise.song().instruments[].sample_modulation_sets[].devices[]:copy_points_from(
other SampleStepperModulationDevice object)

-- Test if a point exists at the given time.
renoise.song().instruments[].sample_modulation_sets[].devices[]:has_point_at(time)
-> [boolean]
-- Add a new point value (or replace any existing value) at time.
renoise.song().instruments[].sample_modulation_sets[].devices[]:add_point_at(
time, value [, scaling])
-- Removes a point at the given time. Point must exist.
renoise.song().instruments[].sample_modulation_sets[].devices[]:remove_point_at(time)

-------- Properties

-- External editor visibility.
renoise.song().instruments[].sample_modulation_sets[].devices[].external_editor_visible
-> [boolean, set to true to show he editor, false to close it]

-- Play mode (interpolation mode).
renoise.song().instruments[].sample_modulation_sets[].devices[].play_mode, \_observable
-> [enum = PLAYMODE]

-- Step size. -1 is the same as choosing RANDOM
renoise.song().instruments[].sample_modulation_sets[].devices[].play_step, \_observable
-> [number, -1-16]

-- Envelope length.
renoise.song().instruments[].sample_modulation_sets[].devices[].length, \_observable
-> [number, 1-256]

-- Get all points of the envelope. When setting a new list of points,
-- items may be unsorted by time, but there may not be multiple points
-- for the same time. Returns a copy of the list, so changing
-- `points[1].value` will not do anything. Instead, change them via
-- `points = { something }`.
renoise.song().instruments[].sample_modulation_sets[].devices[].points[], \_observable
-> [array of {time, value} tables]

-- An envelope point's time.
renoise.song().instruments[].sample_modulation_sets[].devices[].points[].time
-> [number, 1 - envelope.length]
-- An envelope point's value.
renoise.song().instruments[].sample_modulation_sets[].devices[].points[].value
-> [number, 0.0 - 1.0]
-- An envelope point's scaling (used in 'lines' playback mode only - 0.0 is linear).
renoise.song().instruments[].sample_modulation_sets[].devices[].points[].scaling
-> [number, -1.0 - 1.0]

---

## -- renoise.SampleLfoModulationDevice (inherits from renoise.SampleModulationDevice)

-------- Constants

renoise.SampleLfoModulationDevice.MODE_SIN
renoise.SampleLfoModulationDevice.MODE_SAW
renoise.SampleLfoModulationDevice.MODE_PULSE
renoise.SampleLfoModulationDevice.MODE_RANDOM

-------- Properties

-- LFO mode.
renoise.song().instruments[].sample_modulation_sets[].devices[].mode
-> [enum = MODE]

-- Phase.
renoise.song().instruments[].sample_modulation_sets[].devices[].phase
-> [renoise.DeviceParameter object, 0-360]

-- Frequency.
renoise.song().instruments[].sample_modulation_sets[].devices[].frequency
-> [renoise.DeviceParameter object, 0-1]

-- Amount.
renoise.song().instruments[].sample_modulation_sets[].devices[].amount
-> [renoise.DeviceParameter object, 0-1]

-- Delay.
renoise.song().instruments[].sample_modulation_sets[].devices[].delay
-> [renoise.DeviceParameter object, 0-1]

---

## -- renoise.SampleModulationSet

-------- Functions

-- Reset all chain back to default initial state. Removing all devices too.
renoise.song().instruments[].sample_modulation_sets[]:init()

-- Copy all devices from another SampleModulationSet object.
renoise.song().instruments[].sample_modulation_sets[]:copy_from(
other renoise.SampleModulationSet object)

-- Insert a new device at the given position. "device_path" must be one of
-- renoise.song().instruments[].sample_modulation_sets[].available_devices.
renoise.song().instruments[].sample_modulation_sets[]:insert_device_at(device_path, index)
-> [returns new renoise.SampleModulationDevice object]
-- Delete a device at the given index.
renoise.song().instruments[].sample_modulation_sets[]:delete_device_at(index)
-- Access a single device by index.  
renoise.song().instruments[].sample_modulation_sets[]:device(index)
-> [renoise.SampleModulationDevice object]

-- upgrade filter type to the latest version. Tries to find a somewhat matching
-- filter in the new version, but things quite likely won't sound the same.
renoise.song().instruments[].sample_modulation_sets[]:upgrade_filter_version()

-------- Properties

-- Name of the modulation set.
renoise.song().instruments[].sample_modulation_sets[].name, \_observable
-> [string]

-- Input value for the volume domain
renoise.song().instruments[].sample_modulation_sets[].volume_input
-> [renoise.DeviceParameter object]

-- Input value for the panning domain
renoise.song().instruments[].sample_modulation_sets[].panning_input
-> [renoise.DeviceParameter object]

-- Input value for the pitch domain
renoise.song().instruments[].sample_modulation_sets[].pitch_input
-> [renoise.DeviceParameter object]

-- Input value for the cutoff domain
renoise.song().instruments[].sample_modulation_sets[].cutoff_input
-> [renoise.DeviceParameter object]

-- Input value for the resonance domain
renoise.song().instruments[].sample_modulation_sets[].resonance_input
-> [renoise.DeviceParameter object]

-- Input value for the drive domain
renoise.song().instruments[].sample_modulation_sets[].drive_input
-> [renoise.DeviceParameter object]

-- Pitch range in semitones
renoise.song().instruments[].sample_modulation_sets[].pitch_range, \_observable
-> [number, 1 - 96]

-- All available devices, to be used in 'insert_device_at'.
renoise.song().instruments[].sample_modulation_sets[].available_devices[]
-> [read-only, array of strings]

-- Device list access.
renoise.song().instruments[].sample_modulation_sets[].devices[], observable
-> [read-only, array of renoise.SampleModulationDevice objects]

-- Filter version. See also function 'upgrade_filter_version'
renoise.song().instruments[].sample_modulation_sets[].filter_version, observable
-> [read-only, number - 1,2 or 3 which is the latest version]

-- Filter type.
renoise.song().instruments[].sample_modulation_sets[].available_filter_types
-> [read-only, list of strings]
renoise.song().instruments[].sample_modulation_sets[].filter_type, \_observable
-> [string, one of 'available_filter_types']

---

## -- renoise.SampleDeviceChain

-------- Functions

-- Insert a new device at the given position. "device_path" must be one of
-- renoise.song().instruments[].sample_device_chains[].available_devices.
renoise.song().instruments[].sample_device_chains[]:insert_device_at(
device_path, index) -> [returns new device]
-- Delete an existing device from a chain. The mixer device at index 1 can not
-- be deleted.
renoise.song().instruments[].sample_device_chains[]:delete_device_at(index)
-- Swap the positions of two devices in the device chain. The mixer device at
-- index 1 can not be swapped or moved.
renoise.song().instruments[].sample_device_chains[]:swap_devices_at(index, index)

-- Access to a single device in the chain.
renoise.song().instruments[].sample_device_chains[]:device(index)
-> [renoise.AudioDevice object]

-------- Properties

-- Name of the audio effect chain.
renoise.song().instruments[].sample_device_chains[].name, \_observable
-> [string]

-- Allowed, available devices for 'insert_device_at'.
renoise.song().instruments[].sample_device_chains[].available_devices[]
-> [read-only, array of strings]
-- Returns a list of tables containing more information about the devices.
-- see renoise.Track available_device_infos for more info
renoise.song().instruments[].sample_device_chains[].available_device_infos[]
-> [read-only, array of device info tables]

-- Device access.
renoise.song().instruments[].sample_device_chains[].devices[], observable
-> [read-only, array of renoise.AudioDevice objects]

-- Output routing.
renoise.song().instruments[].sample_device_chains[].available_output_routings[]
-> [read-only, array of strings]
renoise.song().instruments[].sample_device_chains[].output_routing, \_observable
-> [string, one of 'available_output_routings']

---

## -- renoise.InstrumentMidiOutputProperties

-------- Constants

renoise.InstrumentMidiOutputProperties.TYPE_EXTERNAL
renoise.InstrumentMidiOutputProperties.TYPE_LINE_IN_RET
renoise.InstrumentMidiOutputProperties.TYPE_INTERNAL -- REWIRE

-------- Properties

-- Note: ReWire device always start with "ReWire: " in the device_name and
-- will always ignore the instrument_type and channel properties. MIDI
-- channels are not configurable for ReWire MIDI, and instrument_type will
-- always be "TYPE_INTERNAL" for ReWire devices.
renoise.song().instruments[].midi_output_properties.instrument_type, \_observable
-> [enum = TYPE]

-- When setting new devices, device names must be one of:
-- renoise.Midi.available_output_devices.
-- Devices are automatically opened when needed. To close a device, set its name
-- to "", e.g. an empty string.
renoise.song().instruments[].midi_output_properties.device_name, \_observable
-> [string]
renoise.song().instruments[].midi_output_properties.channel, \_observable
-> [number, 1-16]
renoise.song().instruments[].midi_output_properties.transpose, \_observable
-> [number, -120-120]
renoise.song().instruments[].midi_output_properties.program, \_observable
-> [number, 1-128, 0 = OFF]
renoise.song().instruments[].midi_output_properties.bank, \_observable
-> [number, 1-65536, 0 = OFF]
renoise.song().instruments[].midi_output_properties.delay, \_observable
-> [number, 0-100]
renoise.song().instruments[].midi_output_properties.duration, \_observable
-> [number, 1-8000, 8000 = INF]

---

## -- renoise.InstrumentPluginProperties

-------- Functions

-- Load an existing, new, non aliased plugin. Pass an empty string to unload
-- an already assigned plugin. plugin_path must be one of:
-- plugin_properties.available_plugins.
renoise.song().instruments[].plugin_properties:load_plugin(plugin_path)
-> [boolean, success]

-------- Properties

-- List of all currently available plugins. This is a list of unique plugin
-- names which also contains the plugin's type (VST/AU/DSSI/...), not including
-- the vendor names as visible in Renoise's GUI. Aka, its an identifier, and not
-- the name as visible in the GUI. When no plugin is loaded, the identifier is
-- an empty string.
renoise.song().instruments[].plugin_properties.available_plugins[]
-> [read_only, array of strings]

-- Returns a list of tables containing more information about the plugins.
-- Each table has the following fields:
-- {
-- path, -- The plugin's path used by load_plugin()
-- name, -- The plugin's name
-- short_name, -- The plugin's name as displayed in shortened lists
-- favorite_name, -- The plugin's name as displayed in favorites
-- is_favorite, -- true if the plugin is a favorite
-- is_bridged -- true if the plugin is a bridged plugin
-- }
renoise.song().instruments[].plugin_properties.available_plugin_infos[]
-> [read-only, array of plugin info tables]

-- Returns true when a plugin is present; loaded successfully.
-- see 'plugin_properties.plugin_device_observable' for related notifications.
renoise.song().instruments[].plugin_properties.plugin_loaded
-> [read-only, boolean]

-- Valid object for successfully loaded plugins, otherwise nil. Alias plugin
-- instruments of FX will return the resolved device, will link to the device
-- the alias points to.
-- The observable is fired when the device changes: when a plugin gets loaded or
-- unloaded or a plugin alias is assigned or unassigned.
renoise.song().instruments[].plugin_properties.plugin_device, \_observable
-> [renoise.InstrumentPluginDevice object or renoise.AudioDevice object or nil]

-- Valid for loaded and unloaded plugins.
renoise.song().instruments[].plugin_properties.alias_instrument_index, \_observable
-> [read-only, number or 0 (when no alias instrument is set)]
renoise.song().instruments[].plugin_properties.alias_fx_track_index, \_observable
-> [read-only, number or 0 (when no alias FX is set)]
renoise.song().instruments[].plugin_properties.alias_fx_device_index, \_observable
-> [read-only, number or 0 (when no alias FX is set)]

-- Valid for loaded and unloaded plugins. target instrument index or 0 of the
-- plugin's MIDI output (when present)
renoise.song().instruments[].plugin_properties.midi_output_routing_index, \_observable
-> [read-only, number. 0 when no routing is set]

-- Valid for loaded and unloaded plugins.
renoise.song().instruments[].plugin_properties.channel, \_observable
-> [number, 1-16]
renoise.song().instruments[].plugin_properties.transpose, \_observable
-> [number, -120-120]

-- Valid for loaded and unloaded plugins.
renoise.song().instruments[].plugin_properties.volume, \_observable
-> [number, linear gain, 0-4]

-- Valid for loaded and unloaded plugins.
renoise.song().instruments[].plugin_properties.auto_suspend, \_observable
-> [boolean]

---

## -- renoise.InstrumentDevice

-- DEPRECATED - alias for renoise.InstrumentPluginDevice

---

## -- renoise.InstrumentPluginDevice

-------- Functions

-- Access to a single preset name by index. Use properties 'presets' to iterate
-- over all presets and to query the presets count.
renoise.song().instruments[].plugin_properties.plugin_device:preset(index)
-> [string]

-- Access to a single parameter by index. Use properties 'parameters' to iterate
-- over all parameters and to query the parameter count.
renoise.song().instruments[].plugin_properties.plugin_device:parameter(index)
-> [renoise.DeviceParameter object]

-------- Properties

-- Device name.
renoise.song().instruments[].plugin_properties.plugin_device.name
-> [read-only, string]
renoise.song().instruments[].plugin_properties.plugin_device.short_name
-> [read-only, string]

-- Preset handling.
renoise.song().instruments[].plugin_properties.plugin_device.active_preset, \_observable
-> [number, 0 when none is active or available]

renoise.song().instruments[].plugin_properties.plugin_device.active_preset_data
-> [string, raw XML data of the active preset]

renoise.song().instruments[].plugin_properties.plugin_device.presets[]
-> [read-only, array of strings]

-- Parameters.
renoise.song().instruments[].plugin_properties.plugin_device.parameters[]
-> [read-only, array of renoise.DeviceParameter objects]

-- Returns whether or not the plugin provides its own custom GUI.
renoise.song().instruments[].plugin_properties.plugin_device.external_editor_available
-> [read-only, boolean]

-- When the plugin has no custom GUI, Renoise will create a dummy editor for it which
-- lists the plugin parameters.
renoise.song().instruments[].plugin_properties.plugin_device.external_editor_visible
-> [boolean, set to true to show the editor, false to close it]

-- Returns a string that uniquely identifies the plugin, from "available_plugins".
-- The string can be passed into: plugin_properties:load_plugin()
renoise.song().instruments[].plugin_properties.plugin_device.device_path
-> [read_only, string]

---

## -- renoise.SampleMapping

-- General remarks: Sample mappings of sliced samples are read-only: can not be
-- modified. See `sample_mappings[].read_only`

-------- Properties

-- True for sliced instruments. No sample mapping properties are allowed to
-- be modified, but can be read.
renoise.song().instruments[].sample_mappings[].read_only
-> [read-only, boolean]

-- Linked sample.
renoise.song().instruments[].sample_mappings[].sample
-> [renoise.Sample object]

-- Mapping's layer (triggered via Note-Ons or Note-Offs?).
renoise.song().instruments[].sample_mappings[].layer, \_observable
-> [enum = renoise.Instrument.LAYER]

-- Mappings velocity->volume and key->pitch options.
renoise.song().instruments[].sample_mappings[].map_velocity_to_volume, \_observable
-> [boolean]
renoise.song().instruments[].sample_mappings[].map_key_to_pitch, \_observable
-> [boolean]

-- Mappings base-note. Final pitch of the played sample is:
-- played_note - mapping.base_note + sample.transpose + sample.finetune
renoise.song().instruments[].sample_mappings[].base_note, \_observable
-> [number (0-119, c-4=48)]

-- Note range the mapping is triggered for.
renoise.song().instruments[].sample_mappings[].note_range, \_observable
-> [table with two numbers (0-119, c-4=48)]

-- Velocity range the mapping is triggered for.
renoise.song().instruments[].sample_mappings[].velocity_range, \_observable
-> [table with two numbers (0-127)]

---

## -- renoise.Sample

-------- Constants

renoise.Sample.INTERPOLATE_NONE
renoise.Sample.INTERPOLATE_LINEAR
renoise.Sample.INTERPOLATE_CUBIC
renoise.Sample.INTERPOLATE_SINC

renoise.Sample.BEAT_SYNC_REPITCH
renoise.Sample.BEAT_SYNC_PERCUSSION
renoise.Sample.BEAT_SYNC_TEXTURE

renoise.Sample.NEW_NOTE_ACTION_NOTE_CUT
renoise.Sample.NEW_NOTE_ACTION_NOTE_OFF
renoise.Sample.NEW_NOTE_ACTION_SUSTAIN

renoise.Sample.LOOP_MODE_OFF
renoise.Sample.LOOP_MODE_FORWARD
renoise.Sample.LOOP_MODE_REVERSE
renoise.Sample.LOOP_MODE_PING_PONG

-------- Functions

-- Reset, clear all sample settings and sample data.
renoise.song().instruments[].samples[]:clear()

-- Copy all settings, including sample data from another sample.
renoise.song().instruments[].samples[]:copy_from(
other renoise.Sample object)

-- Insert a new slice marker at the given sample position. Only samples in
-- the first sample slot may use slices. Creating slices will automatically
-- create sample aliases in the following slots: read-only sample slots that
-- play the sample slice and are mapped to notes. Sliced sample lists can not
-- be modified manually then. To update such aliases, modify the slice marker
-- list instead.
-- Existing 0S effects or notes will be updated to ensure that the old slices
-- are played back just as before.
renoise.song().instruments[].samples[]:insert_slice_marker(marker_sample_pos)
-- Delete an existing slice marker. marker_sample_pos must point to an existing
-- marker. See also property 'samples[].slice_markers'. Existing 0S effects or
-- notes will be updated to ensure that the old slices are played back just as
-- before.
renoise.song().instruments[].samples[]:delete_slice_marker(marker_sample_pos)
-- Change the sample position of an existing slice marker. see also property
-- 'samples[].slice_markers'.
-- When moving a marker behind or before an existing other marker, existing 0S
-- effects or notes will automatically be updated to ensure that the old slices
-- are played back just as before.
renoise.song().instruments[].samples[]:move_slice_marker(
old_marker_pos, new_marker_pos)

-------- Properties

-- True, when the sample slot is an alias to a sliced master sample. Such sample
-- slots are read-only and automatically managed with the master samples slice
-- list.
renoise.song().instruments[].samples[].is_slice_alias
-> [read-only, boolean]

-- Read/write access to the slice marker list of a sample. When new markers are
-- set or existing ones unset, existing 0S effects or notes to existing slices
-- will NOT be remapped (unlike its done with the insert/remove/move_slice_marker
-- functions). See function insert_slice_marker for info about marker limitations
-- and preconditions.
renoise.song().instruments[].samples[].slice_markers, \_observable
-> [table of numbers, sample positions]

-- Name.
renoise.song().instruments[].samples[].name, \_observable
-> [string]

-- Panning, volume.
renoise.song().instruments[].samples[].panning, \_observable
-> [number, 0.0-1.0]
renoise.song().instruments[].samples[].volume, \_observable
-> [number, 0.0-4.0]

-- Tuning.
renoise.song().instruments[].samples[].transpose, \_observable
-> [number, -120-120]
renoise.song().instruments[].samples[].fine_tune, \_observable
-> [number, -127-127]

-- Beat sync.
renoise.song().instruments[].samples[].beat_sync_enabled, \_observable
-> [boolean]
renoise.song().instruments[].samples[].beat_sync_lines, \_observable
-> [number, 1-512]
renoise.song().instruments[].samples[].beat_sync_mode, \_observable
-> [enum = BEAT_SYNC]

-- Interpolation, new note action, oneshot, mute_group, autoseek, autofade.
renoise.song().instruments[].samples[].interpolation_mode, \_observable
-> [enum = INTERPOLATE]
renoise.song().instruments[].samples[].oversample_enabled, \_observable
-> [boolean]

renoise.song().instruments[].samples[].new_note_action, \_observable
-> [enum = NEW_NOTE_ACTION]
renoise.song().instruments[].samples[].oneshot, \_observable
-> [boolean]
renoise.song().instruments[].samples[].mute_group, \_observable
-> [number, 0-15 with 0=none]
renoise.song().instruments[].samples[].autoseek, \_observable
-> [boolean]
renoise.song().instruments[].samples[].autofade, \_observable
-> [boolean]

-- Loops.
renoise.song().instruments[].samples[].loop_mode, \_observable
-> [enum = LOOP_MODE]
renoise.song().instruments[].samples[].loop_release, \_observable
-> [boolean]
renoise.song().instruments[].samples[].loop_start, \_observable
-> [number, 1-num_sample_frames]
renoise.song().instruments[].samples[].loop_end, \_observable
-> [number, 1-num_sample_frames]

-- The linked modulation set. 0 when disable, else a valid index for the
-- instruments[].sample_modulation_sets table
renoise.song().instruments[].sample[].modulation_set_index, \_observable
-> [number]

-- The linked instrument device chain. 0 when disable, else a valid index for the
-- instruments[].sample_device_chain table
renoise.song().instruments[].sample[].device_chain_index, \_observable
-> [number]

-- Buffer.
renoise.song().instruments[].samples[].sample_buffer, \_observable
-> [read-only, renoise.SampleBuffer object]

-- Keyboard Note/velocity mapping
renoise.song().instruments[].samples[].sample_mapping
-> [read-only, renoise.SampleMapping object]

---

## -- renoise.SampleBuffer

-------- Constants

renoise.SampleBuffer.CHANNEL_LEFT
renoise.SampleBuffer.CHANNEL_RIGHT
renoise.SampleBuffer.CHANNEL_LEFT_AND_RIGHT

-------- Functions

-- Create new sample data with the given rate, bit-depth, channel and frame
-- count. Will trash existing sample data. Initial buffer is all zero.
-- Will only return false when memory allocation fails (you're running out
-- of memory). All other errors are fired as usual.
renoise.song().instruments[].samples[].sample_buffer:create_sample_data(
sample_rate, bit_depth, num_channels, num_frames)
-> [boolean, success]
-- Delete existing sample data.
renoise.song().instruments[].samples[].sample_buffer:delete_sample_data()

-- Read access to samples in a sample data buffer.
renoise.song().instruments[].samples[].sample_buffer:sample_data(
channel_index, frame_index)
-> [number -1-1]

-- Write access to samples in a sample data buffer. New samples values must be
-- within [-1, 1] and will be clipped automatically. Sample buffers may be
-- read-only (see property 'read_only'). Attempts to write on such buffers
-- will result into errors.
-- IMPORTANT: before modifying buffers, call 'prepare_sample_data_changes'.
-- When you are done, call 'finalize_sample_data_changes' to generate undo/redo
-- data for your changes and update sample overview caches!
renoise.song().instruments[].samples[].sample_buffer:set_sample_data(
channel_index, frame_index, sample_value)

-- To be called once BEFORE sample data gets manipulated via 'set_sample_data'.
-- This will prepare undo/redo data for the whole sample. See also
-- 'finalize_sample_data_changes'.
renoise.song().instruments[].samples[].sample_buffer:prepare_sample_data_changes()
-- To be called once AFTER the sample data is manipulated via 'set_sample_data'.
-- This will create undo/redo data for the whole sample, and also update the
-- sample view caches for the sample. The reason this isn't automatically
-- invoked is to avoid performance overhead when changing sample data 'sample by
-- sample'. Don't forget to call this after any data changes, or changes may not
-- be visible in the GUI and can not be un/redone!
renoise.song().instruments[].samples[].sample_buffer:finalize_sample_data_changes()

-- Load sample data from a file. Files can be any audio format Renoise supports.
-- Possible errors are shown to the user, otherwise success is returned.
renoise.song().instruments[].samples[].sample_buffer:load_from(filename)
-> [boolean, success]
-- Export sample data to a file. Possible errors are shown to the user,
-- otherwise success is returned. Valid export types are 'wav' or 'flac'.
renoise.song().instruments[].samples[].sample_buffer:save_as(filename, format)
-> [boolean, success]

-------- Properties

-- Has sample data?
renoise.song().instruments[].samples[].sample_buffer.has_sample_data
-> [read-only, boolean]

-- _NOTE: All following properties are invalid when no sample data is present,
-- 'has_sample_data' returns false:_

-- True, when the sample buffer can only be read, but not be modified. true for
-- sample aliases of sliced samples. To modify such sample buffers, modify the
-- sliced master sample buffer instead.
renoise.song().instruments[].samples[].sample_buffer.read_only
-> [read-only, boolean]

-- The current sample rate in Hz, like 44100.
renoise.song().instruments[].samples[].sample_buffer.sample_rate
-> [read-only, number]

-- The current bit depth, like 32, 16, 8.
renoise.song().instruments[].samples[].sample_buffer.bit_depth
-> [read-only, number]

-- The number of sample channels (1 or 2)
renoise.song().instruments[].samples[].sample_buffer.number_of_channels
-> [read-only, number]

-- The sample frame count (number of samples per channel)
renoise.song().instruments[].samples[].sample_buffer.number_of_frames
-> [read-only, number]

-- The first sample displayed in the sample editor view. Set together with
-- DisplayLength to control zooming.
renoise.song().instruments[].samples[].sample_buffer.display_start, \_observable
-> [number >= 1 <= number_of_frames]

-- The number of samples displayed in the sample editor view. Set together with
-- DisplayStart to control zooming.
renoise.song().instruments[].samples[].sample_buffer.display_length, \_observable
-> [number >= 1 <= number_of_frames]

-- The start and end points of the sample editor display.
renoise.song().instruments[].samples[].sample_buffer.display_range[], \_observable
-> [array of two numbers, 1-number_of_frames]

-- The vertical zoom level where 1.0 is fully zoomed out.
renoise.song().instruments[].samples[].sample_buffer.vertical_zoom_factor, \_observable
-> [number, 0.0-1.0]

-- Selection range as visible in the sample editor. always valid. returns the entire
-- buffer when no selection is present in the UI.
renoise.song().instruments[].samples[].sample_buffer.selection_start, \_observable
-> [number >= 1 <= number_of_frames]
renoise.song().instruments[].samples[].sample_buffer.selection_end, \_observable
-> [number >= 1 <= number_of_frames]
renoise.song().instruments[].samples[].sample_buffer.selection_range[], \_observable
-> [array of two numbers, 1-number_of_frames]

-- The selected channel.
renoise.song().instruments[].samples[].sample_buffer.selected_channel, \_observable
-> [enum = CHANNEL_LEFT, CHANNEL_RIGHT, CHANNEL_LEFT_AND_RIGHT]

---

## -- renoise.Pattern

-------- Constants

-- Maximum number of lines that can be present in a pattern.
renoise.Pattern.MAX_NUMBER_OF_LINES

-------- Functions

-- Deletes all lines & automation.
renoise.song().patterns[]:clear()

-- Copy contents from other patterns, including automation, when possible.
renoise.song().patterns[]:copy_from(
other renoise.Pattern object)

-- Access to a single pattern track by index. Use properties 'tracks' to
-- iterate over all tracks and to query the track count.
renoise.song().patterns[]:track(index)
-> [renoise.PatternTrack object]

-- Check/add/remove notifier functions or methods, which are called by Renoise
-- as soon as any of the pattern's lines have changed.
-- The notifiers are called as soon as a new line is added, an existing line
-- is cleared, or existing lines are somehow changed (notes, effects, anything)
--
-- A single argument is passed to the notifier function: "pos", a table with the
-- fields "pattern", "track" and "line", which defines where the change has
-- happened, e.g:
--
-- function my_pattern_line_notifier(pos)
-- -- check pos.pattern, pos.track, pos.line (all are indices)
-- end
--
-- Please be gentle with these notifiers, don't do too much stuff in there.
-- Ideally just set a flag like "pattern_dirty" which then gets picked up by
-- an app_idle notifier: The danger here is that line change notifiers can
-- be called hundreds of times when, for example, simply clearing a pattern.
--
-- If you are only interested in changes that are made to the currently edited
-- pattern, dynamically attach and detach to the selected pattern's line
-- notifiers by listening to "renoise.song().selected_pattern_observable".
renoise.song().patterns[]:has_line_notifier(func [, obj])
-> [boolean]
renoise.song().patterns[]:add_line_notifier(func [, obj])
renoise.song().patterns[]:remove_line_notifier(func [, obj])

-- Same as line_notifier above, but the notifier only fires when the user
-- added, changed or deleted a line with the computer or MIDI keyboard.
renoise.song().patterns[]:has_line_edited_notifier(func [, obj])
-> [boolean]
renoise.song().patterns[]:add_line_edited_notifier(func [, obj])
renoise.song().patterns[]:remove_line_edited_notifier(func [, obj])

-------- Properties

-- Quickly check if any track in a pattern has some non empty pattern lines.
-- This does not look at track automation.
renoise.song().patterns[].is_empty
-> [read-only, boolean]

-- Name of the pattern, as visible in the pattern sequencer.
renoise.song().patterns[].name, \_observable
-> [string]

-- Number of lines the pattern currently has. 64 by default. Max is
-- renoise.Pattern.MAX_NUMBER_OF_LINES, min is 1.
renoise.song().patterns[].number_of_lines, \_observable
-> [number]

-- Access to the pattern tracks. Each pattern has #renoise.song().tracks amount
-- of tracks.
renoise.song().patterns[].tracks[]
-> [read-only, array of renoise.PatternTrack]

-------- Operators

-- Compares all tracks and lines, including automation.
==(Pattern object, Pattern object) -> [boolean]
~=(Pattern object, Pattern object) -> [boolean]

---

## -- renoise.PatternTrack

-------- Functions

-- Deletes all lines & automation.
renoise.song().patterns[].tracks[]:clear()

-- Copy contents from other pattern tracks, including automation when possible.
renoise.song().patterns[].tracks[]:copy_from(
other renoise.PatternTrack object)

-- Access to a single line by index. Line must be [1-MAX_NUMBER_OF_LINES]).
-- This is a !lot! more efficient than calling the property: lines[index] to
-- randomly access lines.
renoise.song().patterns[].tracks[]:line(index)
-> [renoise.PatternLine]

-- Get a specific line range (index must be [1-Pattern.MAX_NUMBER_OF_LINES])
renoise.song().patterns[].tracks[]:lines_in_range(index_from, index_to)
-> [array of renoise.PatternLine objects]

-- Returns the automation for the given device parameter or nil when there is
-- none.
renoise.song().patterns[].tracks[]:find_automation(parameter)
-> [renoise.PatternTrackAutomation or nil]

-- Creates a new automation for the given device parameter.
-- Fires an error when an automation for the given parameter already exists.
-- Returns the newly created automation. Passed parameter must be automatable,
-- which can be tested with 'parameter.is_automatable'.
renoise.song().patterns[].tracks[]:create_automation(parameter)
-> [renoise.PatternTrackAutomation object]

-- Remove an existing automation the given device parameter. Automation
-- must exist.
renoise.song().patterns[].tracks[]:delete_automation(parameter)

-------- Properties

-- Ghosting (aliases)
renoise.song().patterns[].tracks[].is_alias
-> [read-only, boolean]
-- Pattern index the pattern track is aliased or 0 when its not aliased.
renoise.song().patterns[].tracks[].alias_pattern_index , \_observable
-> [number, index or 0 when no alias is present]

-- Color.
renoise.song().patterns[].tracks[].color, \_observable
-> [table with 3 numbers (0-0xFF, RGB) or nil when no custom slot color is set]

-- Returns true when all the track lines are empty. Does not look at automation.
renoise.song().patterns[].tracks[].is_empty, \_observable
-> [read-only, boolean]

-- Get all lines in range [1, number_of_lines_in_pattern]
renoise.song().patterns[].tracks[].lines[]
-> [read-only, array of renoise.PatternLine objects]

-- Automation.
renoise.song().patterns[].tracks[].automation[], \_observable
-> [read-only, array of renoise.PatternTrackAutomation objects]

-------- Operators

-- Compares line content and automation. All other properties are ignored.
==(PatternTrack object, PatternTrack object) -> [boolean]
~=(PatternTrack object, PatternTrack object) -> [boolean]

---

## -- renoise.PatternTrackAutomation

-- General remarks: Automation "time" is specified in lines + optional 1/256
-- line fraction for the sub line grid. The sub line grid has 256 units per
-- line. All times are internally quantized to this sub line grid.
-- For example a time of 1.5 means: line 1 with a note column delay of 128

-------- Constants

renoise.PatternTrackAutomation.PLAYMODE_POINTS
renoise.PatternTrackAutomation.PLAYMODE_LINES
renoise.PatternTrackAutomation.PLAYMODE_CURVES

-------- Functions

-- Removes all points from the automation. Will not delete the automation
-- from tracks[]:automation, instead the resulting automation will not do
-- anything at all.
renoise.song().patterns[].tracks[].automation[]:clear()
-- Remove all existing points in the given [from, to) time range from the
-- automation.
renoise.song().patterns[].tracks[].automation[]:clear_range(from_time, to_time)

-- Copy all points and playback settings from another track automation.
renoise.song().patterns[].tracks[].automation[]:copy_from(
other renoise.PatternTrackAutomation object)

-- Test if a point exists at the given time (in lines
renoise.song().patterns[].tracks[].automation[]:has_point_at(time)
-> [boolean]
-- Insert a new point, or change an existing one, if a point in
-- time already exists.
renoise.song().patterns[].tracks[].automation[]:add_point_at(
time, value [, scaling])
-- Removes a point at the given time. Point must exist.
renoise.song().patterns[].tracks[].automation[]:remove_point_at(time)

-------- Properties

-- Destination device. Can in some rare circumstances be nil, i.e. when
-- a device or track is about to be deleted.
renoise.song().patterns[].tracks[].automation[].dest_device
-> [renoise.AudioDevice or nil]

-- Destination device's parameter. Can in some rare circumstances be nil,
-- i.e. when a device or track is about to be deleted.
renoise.song().patterns[].tracks[].automation[].dest_parameter
-> [renoise.DeviceParameter or nil]

-- play-mode (interpolation mode).
renoise.song().patterns[].tracks[].automation[].playmode, \_observable
-> [enum = PLAYMODE]

-- Max length (time in lines) of the automation. Will always fit the patterns length.
renoise.song().patterns[].tracks[].automation[].length
-> [number, 1-NUM_LINES_IN_PATTERN]

-- Selection range as visible in the automation editor. always valid.
-- returns the automation range no selection is present in the UI.
renoise.song().patterns[].tracks[].automation[].selection_start, \_observable
-> [number >= 1 <= automation.length+1]
renoise.song().patterns[].tracks[].automation[].selection_end, \_observable
-> [number >= 1 <= automation.length+1]
-- Get or set selection range. when setting an empty table, the existing
-- selection, if any, will be cleared.
renoise.song().patterns[].tracks[].automation[].selection_range[], \_observable
-> [array of two numbers, 1-automation.length+1]

-- Get all points of the automation. When setting a new list of points,
-- items may be unsorted by time, but there may not be multiple points
-- for the same time. Returns a copy of the list, so changing
-- `points[1].value` will not do anything. Instead, change them via
-- `points = { something }` instead.
renoise.song().patterns[].tracks[].automation[].points[], \_observable
-> [array of {time, value} tables]

-- An automation point's time in pattern lines.
renoise.song().patterns[].tracks[].automation[].points[].time
-> [number, 1 - NUM_LINES_IN_PATTERN]
-- An automation point's value [0-1.0]
renoise.song().patterns[].tracks[].automation[].points[].value
-> [number, 0 - 1.0]
-- An envelope point's scaling (used in 'lines' playback mode only - 0.0 is linear).
renoise.song().patterns[].tracks[].automation[].points[].scaling
-> [number, -1.0 - 1.0]

-------- Operators

-- Compares automation content only, ignoring dest parameters.
==(PatternTrackAutomation object, PatternTrackAutomation object)
-> [boolean]
~=(PatternTrackAutomation object, PatternTrackAutomation object)
-> [boolean]

---

## -- renoise.PatternTrackLine

-- DEPRECATED - alias for renoise.PatternLine

---

## -- renoise.PatternLine

-------- Constants

renoise.PatternLine.EMPTY_NOTE
renoise.PatternLine.NOTE_OFF

renoise.PatternLine.EMPTY_INSTRUMENT
renoise.PatternLine.EMPTY_VOLUME
renoise.PatternLine.EMPTY_PANNING
renoise.PatternLine.EMPTY_DELAY

renoise.PatternLine.EMPTY_EFFECT_NUMBER
renoise.PatternLine.EMPTY_EFFECT_AMOUNT

-------- Functions

-- Clear all note and effect columns.
renoise.song().patterns[].tracks[].lines[]:clear()

-- Copy contents from other_line, trashing column content.
renoise.song().patterns[].tracks[].lines[]:copy_from(
other renoise.PatternLine object)

-- Access to a single note column by index. Use properties 'note_columns'
-- to iterate over all note columns and to query the note_column count.
-- This is a !lot! more efficient than calling the property:
-- note_columns[index] to randomly access columns. When iterating over all
-- columns, use pairs(note_columns).
renoise.song().patterns[].tracks[].lines[]:note_column(index)
-> [renoise.NoteColumn object]

-- Access to a single effect column by index. Use properties 'effect_columns'
-- to iterate over all effect columns and to query the effect_column count.
-- This is a !lot! more efficient than calling the property:
-- effect_columns[index] to randomly access columns. When iterating over all
-- columns, use pairs(effect_columns).
renoise.song().patterns[].tracks[].lines[]:effect_column(index)
-> [renoise.EffectColumn object]

-------- Properties

-- Is empty.
renoise.song().patterns[].tracks[].lines[].is_empty
-> [boolean]

-- Columns.
renoise.song().patterns[].tracks[].lines[].note_columns[]
-> [read-only, array of renoise.NoteColumn objects]
renoise.song().patterns[].tracks[].lines[].effect_columns[]
-> [read-only, array of renoise.EffectColumn objects]

-------- Operators

-- Compares all columns.
==(PatternLine object, PatternLine object)
-> [boolean]
~=(PatternLine object, PatternLine object)
-> [boolean]

-- Serialize a line.
tostring(PatternLine object)
-> [string]

---

## -- renoise.NoteColumn

-- General remarks: instrument columns are available for lines in phrases
-- but are ignored. See renoise.InstrumentPhrase for detail.

-------- Functions

-- Clear the note column.
renoise.song().patterns[].tracks[].lines[].note_columns[]:clear()

-- Copy the column's content from another column.
renoise.song().patterns[].tracks[].lines[].note_columns[]:copy_from(
other renoise.NoteColumn object)

-------- Properties

-- True, when all note column properties are empty.
renoise.song().patterns[].tracks[].lines[].note_columns[].is_empty
-> [read-only, boolean]

-- True, when this column is selected in the pattern or phrase
-- editors current pattern.
renoise.song().patterns[].tracks[].lines[].note_columns[].is_selected
-> [read-only, boolean]

-- Access note column properties either by values (numbers) or by strings.
-- The string representation uses exactly the same notation as you see
-- them in Renoise's pattern or phrase editor.

renoise.song().patterns[].tracks[].lines[].note_columns[].note_value
-> [number, 0-119, 120=Off, 121=Empty]
renoise.song().patterns[].tracks[].lines[].note_columns[].note_string
-> [string, 'C-0'-'G-9', 'OFF' or '---']

renoise.song().patterns[].tracks[].lines[].note_columns[].instrument_value
-> [number, 0-254, 255==Empty]
renoise.song().patterns[].tracks[].lines[].note_columns[].instrument_string
-> [string, '00'-'FE' or '..']

renoise.song().patterns[].tracks[].lines[].note_columns[].volume_value
-> [number, 0-127, 255==Empty when column value is <= 0x80 or is 0xFF,
i.e. is used to specify volume]
[number, 0-65535 in the form 0x0000xxyy where
xx=effect char 1 and yy=effect char 2,
when column value is > 0x80, i.e. is used to specify an effect]
renoise.song().patterns[].tracks[].lines[].note_columns[].volume_string
-> [string, '00'-'ZF' or '..']

renoise.song().patterns[].tracks[].lines[].note_columns[].panning_value
-> [number, 0-127, 255==Empty when column value is <= 0x80 or is 0xFF,
i.e. is used to specify pan]
[number, 0-65535 in the form 0x0000xxyy where
xx=effect char 1 and yy=effect char 2,
when column value is > 0x80, i.e. is used to specify an effect]
renoise.song().patterns[].tracks[].lines[].note_columns[].panning_string
-> [string, '00'-'ZF' or '..']

renoise.song().patterns[].tracks[].lines[].note_columns[].delay_value
-> [number, 0-255]
renoise.song().patterns[].tracks[].lines[].note_columns[].delay_string
-> [string, '00'-'FF' or '..']

renoise.song().patterns[].tracks[].lines[].note_columns[].effect_number_value
-> [int, 0-65535 in the form 0x0000xxyy where xx=effect char 1 and yy=effect char 2]
song().patterns[].tracks[].lines[].note_columns[].effect_number_string
-> [string, '00' - 'ZZ']

renoise.song().patterns[].tracks[].lines[].note_columns[].effect_amount_value
-> [int, 0-255]
renoise.song().patterns[].tracks[].lines[].note_columns[].effect_amount_string
-> [string, '00' - 'FF']

-------- Operators

-- Compares the whole column.
==(NoteColumn object, NoteColumn object) -> [boolean]
~=(NoteColumn object, NoteColumn object) -> [boolean]

-- Serialize a column.
tostring(NoteColumn object) -> [string]

---

## -- renoise.EffectColumn

-------- Functions

-- Clear the effect column.
renoise.song().patterns[].tracks[].lines[].effect_columns[]:clear()

-- Copy the column's content from another column.
renoise.song().patterns[].tracks[].lines[].effect_columns[]:copy_from(
other renoise.EffectColumn object)

-------- Properties

-- True, when all effect column properties are empty.
renoise.song().patterns[].tracks[].lines[].effect_columns[].is_empty
-> [read-only, boolean]

-- True, when this column is selected in the pattern or phrase editor.
renoise.song().patterns[].tracks[].lines[].effect_columns[].is_selected
-> [read-only, boolean]

-- Access effect column properties either by values (numbers) or by strings.
renoise.song().patterns[].tracks[].lines[].effect_columns[].number_value
-> [number, 0-65535 in the form 0x0000xxyy where xx=effect char 1 and yy=effect char 2]

renoise.song().patterns[].tracks[].lines[].effect_columns[].number_string
-> [string, '00'-'ZZ']

renoise.song().patterns[].tracks[].lines[].effect_columns[].amount_value
-> [number, 0-255]
renoise.song().patterns[].tracks[].lines[].effect_columns[].amount_string
-> [string, '00'-'FF']

-------- Operators

-- Compares the whole column.
==(EffectColumn object, EffectColumn object)
-> [boolean]
~=(EffectColumn object, EffectColumn object)
-> [boolean]

-- Serialize a column.
tostring(EffectColumn object) -> [string]

--[[============================================================================
Renoise ViewBuilder API Reference
============================================================================]]--

--[[

This reference lists all "View" related functions in the API. View means
classes and functions that are used to build custom GUIs; GUIs for your
scripts in Renoise.

Please read the INTRODUCTION first to get an overview about the complete
API, and scripting for Renoise in general...

For a small tutorial and more details about how to create and use views, have
a look at the "com.renoise.ExampleToolGUI.xrnx" tool. This tool is included in
the scripting dev started pack at <http://scripting.renoise.com>

Do not try to execute this file. It uses a .lua extension for markup only.

]]--

-------- Introduction

## -- Currently there are two ways to to create custom views:

-- Shows a modal dialog with a title, custom content and custom button labels:
renoise.app():show_custom_prompt(
title, content_view, {button_labels} [, key_handler_func, key_handler_options])
-> [pressed button]

-- _(and)_ Shows a non modal dialog, a floating tool window, with custom
-- content:
renoise.app():show_custom_dialog(
title, content_view [, key_handler_func, key_handler_options])
-> [dialog object]

-- key_handler_func is optional. When defined, it should point to a function
-- with the signature noted below. "key" is a table with the fields:
-- > key = {  
-- > name, -- name of the key, like 'esc' or 'a' - always valid  
-- > modifiers, -- modifier states. 'shift + control' - always valid  
-- > character, -- character representation of the key or nil  
-- > note, -- virtual keyboard piano key value (starting from 0) or nil  
-- > state, -- optional (see below) - is the key getting pressed or released?
-- > repeated, -- optional (see below) - true when the key is soft repeated (held down)
-- > }
--
-- The "repeated" field will not be present when 'send_key_repeat' in the key
-- handler options is set to false. The "state" field only is present when the
-- 'send_key_release' in the key handler options is set to true. So by default only
-- key presses are send to the key handler.
--
-- key_handler_options is an optional table with the fields:
-- > options = {
-- > send_key_repeat=true OR false -- by default true
-- > send_key_release=true OR false -- by default false
-- > }
-- >
-- Returned "dialog" is a reference to the dialog the keyhandler is running on.
--
-- function my_keyhandler_func(dialog, key) end
--
-- When no key handler is specified, the Escape key is used to close the dialog.
-- For prompts, the first character of the button labels is used to invoke
-- the corresponding button.
--
-- When returning the passed key from the key-handler function, the
-- key will be passed back to Renoise's key event chain, in order to allow
-- processing global Renoise key-bindings from your dialog. This will not work
-- for modal dialogs. This also only applies to global shortcuts in Renoise,
-- because your dialog will steal the focus from all other Renoise views such as
-- the Pattern Editor, etc.

--==============================================================================
-- Views
--==============================================================================

---

## -- renoise.Views.View

-- View is the base class for all child views. All View properties can be
-- applied to any of the following specialized views.

----------- Functions

-- Dynamically create view hierarchies.
view:add_child(View child_view)
view:remove_child(View child_view)

----------- Properties

-- Set visible to false to hide a view (make it invisible without removing
-- it). Please note that view.visible will also return false when any of its
-- parents are invisible (when its implicitly invisible).
-- By default a view is visible.
view.visible
-> [boolean]

-- Get/set a view's size. All views must have a size > 0.
-- By default > 0: How much exactly depends on the specialized view type.
--
-- Note: in nested view_builder notations you can also specify relative
-- sizes, like for example `vb:text { width = "80%"}`. The percentage values are
-- relative to the view's parent size and will automatically update on size
-- changes.
view.width
-> [number]
view.height
-> [number]

-- Get/set a tooltip text that should be shown for this view.
-- By default empty (no tip will be shown).
view.tooltip
-> [string]

---

## -- renoise.Views.Control (inherits from View)

-- Control is the base class for all views which let the user change a value or
-- some "state" from the UI.

----------- Properties

-- Instead of making a control invisible, you can also make it inactive.
-- Deactivated controls will still be shown, and will still show their
-- currently assigned values, but will not allow changes. Most controls will
-- display as "grayed out" to visualize the deactivated state.
control.active
-> [boolean]

-- When set, the control will be highlighted when Renoise's MIDI mapping dialog
-- is open. When clicked, it selects the specified string as a MIDI mapping
-- target action. This target acton can either be one of the globally available
-- mappings in Renoise, or those that were created by the tool itself.
-- Target strings are not verified. When they point to nothing, the mapped MIDI
-- message will do nothing and no error is fired.
control.midi_mapping
-> [string]

---

## -- renoise.Views.Rack (inherits from View, 'column' or 'row' in ViewBuilder)

-- A Rack has no content on its own. It only stacks child views. Either
-- vertically (ViewBuilder.column) or horizontally (ViewBuilder.row). It allows
-- you to create view layouts.

----------- Functions

-- DEPRECATED: Adding new child views to a rack automatically enlarges and
-- shrinks the rack since API_VERSION 2.0. calling this function will have no
-- effect.
rack:resize()

----------- Properties

-- Set the "borders" of the rack (left, right, top and bottom inclusively)
-- By default 0 (no borders).
rack.margin
-> [number]

-- Setup the amount stacked child views are separated by (horizontally in
-- rows, vertically in columns).
-- By default 0 (no spacing).
rack.spacing
-> [number]

## -- Setup a background style for the rack. Available styles are:

-- + "invisible" -> no background
-- + "plain" -> undecorated, single coloured background
-- + "border" -> same as plain, but with a bold nested border
-- + "body" -> main "background" style, as used in dialog backgrounds
-- + "panel" -> alternative "background" style, beveled
-- + "group" -> background for "nested" groups within body
--
-- By default "invisible".
rack.style
-> [string]

-- When set to true, all child views in the rack are automatically resized to
-- the max size of all child views (width in ViewBuilder.column, height in
-- ViewBuilder.row). This can be useful to automatically align all sub
-- columns/panels to the same size. Resizing is done automatically, as soon
-- as a child view size changes or new children are added.
-- By default disabled, false.
rack.uniform
-> [boolean]

---

-- renoise.Views.Aligner (inherits from View, 'horizontal_aligner' or
-- 'vertical_aligner' in ViewBuilder)

---

-- Just like a Rack, the Aligner shows no content on its own. It just aligns
-- child views vertically or horizontally. As soon as children are added, the
-- Aligner will expand itself to make sure that all children are visible
-- (including spacing & margins).
-- To make use of modes like "center", you manually have to setup a size that
-- is bigger than the sum of the child sizes.

----------- Properties

-- Setup "borders" for the aligner (left, right, top and bottom inclusively)
-- By default 0 (no borders).
aligner.margin
-> [number]

-- Setup the amount child views are separated by (horizontally in rows,
-- vertically in columns).
-- By default 0 (no spacing).
aligner.spacing
-> [number]

## -- Setup the alignment mode. Available mode are:

-- + "left" -> align from left to right (for horizontal_aligner only)
-- + "right" -> align from right to left (for horizontal_aligner only)
-- + "top" -> align from top to bottom (for vertical_aligner only)
-- + "bottom" -> align from bottom to top (for vertical_aligner only)
-- + "center" -> center all views
-- + "justify" -> keep outer views at the borders, distribute the rest
-- + "distribute" -> equally distributes views over the aligners width/height
--
-- By default "left" for a horizontal_aligner, "top" for a vertical_aligner.
aligner.mode
-> [string]

---

## -- renoise.Views.Text (inherits from View, 'text' in ViewBuilder)

-- Shows a "static" text string. Static just means that its not linked, bound
-- to some value and has no notifiers. The text can not be edited by the user.
-- Nevertheless you can of course change the text at run-time with the "text"
-- property.

-- See renoise.Views.TextField for texts that can be edited by the user.

--[[

--.. Text, Bla

![Text](___REPLACE_URL___/Text.png)
]]--

----------- Properties

-- Get/set the text that should be displayed. Setting a new text will resize
-- the view in order to make the text fully visible (expanding only).
-- By default empty.
text.text
-> [string]

-- Get/set the style that the text should be displayed with.
-- Available font styles are:
-- > "normal"  
-- > "big"  
-- > "bold"
-- > "italic"  
-- > "mono"
--
-- By default "normal".
text.font
-> [string]

-- Get/set the color style the text should be displayed with.
-- Available styles are:
-- > "normal"
-- > "strong"
-- > "disabled"
--
-- By default "normal".
text.style
-> [string]

-- Setup the text's alignment. Applies only when the view's size is larger than
-- the needed size to draw the text.
-- Available mode are:
-- > "left"  
-- > "right"  
-- > "center"
--
-- By default "left".
text.align
-> [string]

---

## -- renoise.Views.MultiLineText (inherits from View, 'multiline_text' in the builder)

-- Shows multiple lines of text, auto-formatting and auto-wrapping paragraphs
-- into lines. Size is not automatically set. As soon as the text no longer fits
-- into the view, a vertical scroll bar will be shown.

-- See renoise.Views.MultilineTextField for multiline texts that can be edited
-- by the user.

--[[

--. +--------------+-+
--. | Text, Bla 1 |+|
--. | Text, Bla 2 | |
--. | Text, Bla 3 | |
--. | Text, Bla 4 |+|
--. +--------------+-+

![MultiLineText](___REPLACE_URL___/MultiLineText.png)
]]--

----------- Functions

-- When a scroll bar is visible (needed), scroll the text to show the last line.
multiline_text:scroll_to_last_line()

-- When a scroll bar is visible, scroll the text to show the first line.
multiline_text:scroll_to_first_line()

-- Append text to the existing text. Newlines in the text will create new
-- paragraphs, just like in the "text" property.
multiline_text:add_line(text)

-- Clear the whole text, same as multiline_text.text="".
multiline_text:clear()

----------- Properties

-- Get/set the text that should be displayed on a single line. Newlines
-- (Windows, Mac or Unix styled newlines) in the text can be used to create
-- paragraphs.
-- By default empty.
multiline_text.text
-> [string]

-- Get/set an array (table) of text lines, instead of specifying a single text
-- line with newline characters like "text" does.
-- By default empty.
multiline_text.paragraphs
-> [string]

-- Get/set the style that the text should be displayed with.
-- Available font styles are:
-- > "normal"  
-- > "big"  
-- > "bold  
-- > "italic"  
-- > "mono"
--
-- By default "normal".
multiline_text.font
-> [string]

-- Setup the text view's background:
-- > "body" -> simple text color with no background  
-- > "strong" -> stronger text color with no background  
-- > "border" -> text on a bordered background
--
-- By default "body".
multiline_text.style
-> [string]

---

## -- renoise.Views.TextField (inherits from View, 'textfield' in the builder)

-- Shows a text string that can be clicked and edited by the user.

--[[

--. +----------------+
--. | Editable Te|xt |
--. +----------------+

![TextField](___REPLACE_URL___/TextField.png)
]]--

----------- Functions

-- Add/remove value change (text change) notifiers.
textfield:add_notifier(function or {object, function} or {function, object})
textfield:remove_notifier(function or {object, function} or {function, object})

----------- Properties

-- When false, text is displayed but can not be entered/modified by the user.
-- By default true.
textfield.active
-> [boolean]

-- The currently shown value / text. The text will not be updated when editing,
-- rather only after editing is complete (return is pressed, or focus is lost).
-- By default empty.
textfield.value
-> [string]

-- Exactly the same as "value"; provided for consistency.
textfield.text
-> [string]

-- Setup the text field's text alignment, when not editing.
-- Valid values are:
-- > "left"  
-- > "right"  
-- > "center"
--
-- By default "left".
textfield.align

-- True when the text field is focused. setting the edit_mode programatically
-- will focus the text field or remove the focus (focus the dialog) accordingly.
-- By default false.
textfield.edit_mode
-> [boolean]

-- Valid in the construction table only: Set up a notifier for text changes.
-- See add_notifier/remove_notifier below.
textfield.notifier
-> [function()]

-- Valid in the construction table only: Bind the view's value to a
-- renoise.Document.ObservableString object. Will change the Observable
-- value as soon as the views value changes, and change the view's value as
-- soon as the Observable's value changes - automatically keeps both values
-- in sync.
-- Notifiers can be added to either the view or the Observable object.
textfield.bind
-> [ObservableString Object]

---

-- renoise.Views.MultilineTextField (inherits from View,
-- 'multiline_textfield' in the builder)

---

-- Shows multiple text lines of text, auto-wrapping paragraphs into lines. The
-- text can be edited by the user.

--[[

--. +--------------------------+-+
--. | Editable Te|xt. |+|
--. | | |
--. | With multiple paragraphs | |
--. | and auto-wrapping |+|
--. +--------------------------+-+

![MultilineTextField](___REPLACE_URL___/MultilineTextField.png)
]]--

----------- Functions

-- Add/remove value change (text change) notifiers.
multiline_textfield:add_notifier(function or {object, function} or {function, object})
multiline_textfield:remove_notifier(function or {object, function} or {function, object})

-- When a scroll bar is visible, scroll the text to show the last line.
multiline_textfield:scroll_to_last_line()

-- When a scroll bar is visible, scroll the text to show the first line.
multiline_textfield:scroll_to_first_line()

-- Append a new text to the existing text. Newline characters in the string will
-- create new paragraphs, othwerise a single paragraph is appended.
multiline_textfield:add_line(text)

-- Clear the whole text.
multiline_textfield:clear()

-------- Properties

-- When false, text is displayed but can not be entered/modified by the user.
-- By default true.
multiline_textfield.active
-> [boolean]

-- The current text as a single line, uses newline characters to specify
-- paragraphs.
-- By default empty.
multiline_textfield.value
-> [string]

-- Exactly the same as "value"; provided for consistency.
multiline_textfield.text
-> [string]

-- Get/set a list/table of text lines instead of specifying the newlines as
-- characters.
-- By default empty.
multiline_textfield.paragraphs
-> [string]

-- Get/set the style that the text should be displayed with.
-- Available font styles are:
-- > "normal"  
-- > "big"  
-- > "bold"  
-- > "italic"  
-- > "mono"
--
-- By default "normal".
multiline_textfield.font
-> [string]

-- Setup the text view's background style.
-- > "body" -> simple body text color with no background  
-- > "strong" -> stronger body text color with no background  
-- > "border" -> text on a bordered background
--
-- By default "border".
multiline_textfield.style
-> [string]

-- Valid in the construction table only: Set up a notifier for text changes.
-- See add_notifier/remove_notifier above.
multiline_textfield.notifier
-> [function()]

-- Valid in the construction table only: Bind the view's value to a
-- renoise.Document.ObservableStringList object. Will change the Observable
-- value as soon as the view's value changes, and change the view's value as
-- soon as the Observable's value changes - automatically keeps both values
-- in sync.
-- Notifiers can be added to either the View or the Observable object.
multiline_textfield.bind
-> [ObservableStringList Object]

-- True when the text field is focused. setting the edit_mode programatically
-- will focus the text field or remove the focus (focus the dialog) accordingly.
-- By default false.
multiline_textfield.edit_mode
-> [boolean]

---

## -- renoise.Views.Bitmap (inherits from Control, 'bitmap' in the builder)

--[[

--. \*
--. _\*\*
--. + _
--. / \
--. +---+
--. | O | o
--. +---+ |
--. ||||||||||||

![Bitmap](___REPLACE_URL___/Bitmap.png)
]]--

-- Draws a bitmap, or a draws a bitmap which acts like a button (as soon as a
-- notifier is specified). The notifier is called when clicking the mouse
-- somewhere on the bitmap. When using a re-colorable style (see 'mode'), the
-- bitmap is automatically recolored to match the current theme's colors. Mouse
-- hover is also enabled when notifies are present, to show that the bitmap can
-- be clicked.

-------- Functions

-- Add/remove mouse click notifiers
bitmapview:add_notifier(function or {object, function} or {function, object})
bitmapview:remove_notifier(function or {object, function} or {function, object})

-------- Properties

-- Setup how the bitmap should be drawn, recolored. Available modes are:
-- > "plain" -> bitmap is drawn as is, no recoloring is done  
-- > "transparent" -> same as plain, but black pixels will be fully transparent  
-- > "button_color" -> recolor the bitmap, using the theme's button color  
-- > "body_color" -> same as 'button_back' but with body text/back color  
-- > "main_color" -> same as 'button_back' but with main text/back colors
--
-- By default "plain".
bitmapview.mode
-> [string]

-- Bitmap name and path. You should use a relative path that uses Renoise's
-- default resource folder as base (like "Icons/ArrowRight.bmp"). Or specify a
-- file relative from your XRNX tool bundle:
-- Lets say your tool is called "com.foo.MyTool.xrnx" and you pass
-- "MyBitmap.bmp" as the name. Then the bitmap is loaded from
-- "PATH_TO/com.foo.MyTool.xrnx/MyBitmap.bmp".
-- Supported bitmap file formats are _.bmp, _.png or \*.tif (no transparency).
bitmapview.bitmap
-> [string]

-- Valid in the construction table only: Set up a click notifier. See
-- add_notifier/remove_notifier above.
bitmapview.notifier
-> [function()]

---

## -- renoise.Views.Button (inherits from Control, 'button' in the builder)

-- A simple button that calls a custom notifier function when clicked.
-- Supports text or bitmap labels.

--[[

--. +--------+
--. | Button |
--. +--------+

![Button](___REPLACE_URL___/Button.png)
]]--

-------- Functions

-- Add/remove button hit/release notifier functions.
-- When a "pressed" notifier is set, the release notifier is guaranteed to be
-- called as soon as the mouse is released, either over your button or anywhere
-- else. When a "release" notifier is set, it is only called when the mouse
-- button is pressed !and! released over your button.
button:add_pressed_notifier(function or {object, function} or {function, object})
button:add_released_notifier(function or {object, function} or {function, object})
button:remove_pressed_notifier(function or {object, function} or {function, object})
button:remove_released_notifier(function or {object, function} or {function, object})

-------- Properties

-- The text label of the button
-- By default empty.
button.text
-> [string]

-- When set, existing text is cleared. You should use a relative path
-- that either assumes Renoises default resource folder as base (like
-- "Icons/ArrowRight.bmp"). Or specify a file relative from your XRNX tool
-- bundle:
-- Lets say your tool is called "com.foo.MyTool.xrnx" and you pass
-- "MyBitmap.bmp" as name. Then the bitmap is loaded from
-- "PATH_TO/com.foo.MyTool.xrnx/MyBitmap.bmp".
-- The only supported bitmap format is ".bmp" (Windows bitmap) right now.
-- Colors will be overridden by the theme colors, using black as transparent
-- color, white is the full theme color. All colors in between are mapped
-- according to their gray value.
button.bitmap
-> [string]

-- Table of RGB values like {0xff,0xff,0xff} -> white. When set, the
-- unpressed button's background will be drawn in the specified color.
-- A text color is automatically selected to make sure its always visible.
-- Set color {0,0,0} to enable the theme colors for the button again.
button.color
-> [table with 3 numbers (0-255)]

-- Valid in the construction table only: set up a click notifier.
button.pressed
-> [function()]
-- Valid in the construction table only: set up a click release notifier.
button.released
-> [function()]

-- synonymous for 'button.released'.
button.notifier
-> [function()]

---

## -- renoise.Views.CheckBox (inherits from Control, 'checkbox' in the builder)

-- A single button with a checkbox bitmap, which can be used to toggle
-- something on/off.

--[[

--. +----+
--. | \_/ |
--. +----+

![CheckBox](___REPLACE_URL___/CheckBox.png)
]]--

-------- Functions

-- Add/remove value notifiers
checkbox:add_notifier(function or {object, function} or {function, object})
checkbox:remove_notifier(function or {object, function} or {function, object})

-------- Properties

-- The current state of the checkbox, expressed as boolean.
-- By default "false".
checkbox.value
-> [boolean]

-- Valid in the construction table only: Set up a value notifier.
checkbox.notifier
-> [function(boolean_value)]

-- Valid in the construction table only: Bind the view's value to a
-- renoise.Document.ObservableBoolean object. Will change the Observable
-- value as soon as the views value changes, and change the view's value as
-- soon as the Observable's value changes - automatically keeps both values
-- in sync.
-- Notifiers can be added to either the view or the Observable object.
checkbox.bind
-> [ObservableBoolean Object]

---

## -- renoise.Views.Switch (inherits from Control, 'switch' in the builder)

-- A set of horizontally aligned buttons, where only one button can be enabled
-- at the same time. Select one of multiple choices, indices.

--[[

--. +-----------+------------+----------+
--. | Button A | +Button+B+ | Button C |
--. +-----------+------------+----------+

![Switch](___REPLACE_URL___/Switch.png)
]]--

-------- Functions

-- Add/remove index change notifiers.
switch:add_notifier(function or {object, function} or {function, object})
switch:remove_notifier(function or {object, function} or {function, object})

-------- Properties

-- Get/set the currently shown button labels. Item list size must be >= 2.
switch.items
-> [list of strings]

-- Get/set the currently pressed button index.
switch.value
-> [number]

-- Valid in the construction table only: Set up a value notifier.
switch.notifier
-> [function(index)]

-- Valid in the construction table only: Bind the view's value to a
-- renoise.Document.ObservableNumber object. Will change the Observable
-- value as soon as the views value changes, and change the view's value as
-- soon as the Observable's value changes - automatically keeps both values
-- in sync.
-- Notifiers can be added to either the view or the Observable object.
switch.bind
-> [ObservableNumber Object]

---

## -- renoise.Views.Popup (inherits from Control, 'popup' in the builder)

-- A drop-down menu which shows the currently selected value when closed.
-- When clicked, it pops up a list of all available items.

--[[

--. +--------------++---+
--. | Current Item || ^ |
--. +--------------++---+

![Popup](___REPLACE_URL___/Popup.png)
]]--

-------- Functions

-- Add/remove index change notifiers.
popup:add_notifier(function or {object, function} or {function, object})
popup:remove_notifier(function or {object, function} or {function, object})

-------- Properties

-- Get/set the currently shown items. Item list can be empty, then "None" is
-- displayed and the value won't change.
popup.items
-> [list of strings]

-- Get/set the currently selected item index.
popup.value
-> [number]

-- Valid in the construction table only: Set up a value notifier.
popup.notifier
-> [function(index)]

-- Valid in the construction table only: Bind the view's value to a
-- renoise.Document.ObservableNumber object. Will change the Observable
-- value as soon as the views value changes, and change the view's value as
-- soon as the Observable's value changes - automatically keeps both values
-- in sync.
-- Notifiers can be added to either the view or the Observable object.
popup.bind
-> [ObservableNumber Object]

---

## -- renoise.Views.Chooser (inherits from Control, 'chooser' in the builder)

-- A radio button like set of vertically stacked items. Only one value can be
-- selected at a time.

--[[

--. . Item A
--. o Item B
--. . Item C

![Chooser](___REPLACE_URL___/Chooser.png)
]]--

-------- Functions

-- Add/remove index change notifiers.
chooser:add_notifier(function or {object, function} or {function, object})
chooser:remove_notifier(function or {object, function} or {function, object})

-------- Properties

-- Get/set the currently shown items. Item list size must be >= 2.
chooser.items
-> [list of strings]

-- Get/set the currently selected items index.
chooser.value
-> [number]

-- Valid in the construction table only: Set up a value notifier.
chooser.notifier
-> [function(index)]

-- Valid in the construction table only: Bind the view's value to a
-- renoise.Document.ObservableNumber object. Will change the Observable
-- value as soon as the views value changes, and change the view's value as
-- soon as the Observable's value changes - automatically keeps both values
-- in sync.
-- Notifiers can be added to either the view or the Observable object.
chooser.bind
-> [ObservableNumber Object]

---

## -- renoise.Views.ValueBox (inherits from Control, 'valuebox' in the builder)

-- A box with arrow buttons and a text field that can be edited by the user.
-- Allows showing and editing natural numbers in a custom range.

--[[

--. +---+-------+
--. |<|>| 12 |
--. +---+-------+

![ValueBox](___REPLACE_URL___/ValueBox.png)
]]--

-------- Functions

-- Add/remove value change notifiers.
valuebox:add_notifier(function or {object, function} or {function, object})
valuebox:remove_notifier(function or {object, function} or {function, object})

-------- Properties

-- Get/set the min/max values that are expected, allowed.
-- By default 0 and 100.
valuebox.min
-> [number]
valuebox.max
-> [number]

-- Get/set inc/dec step amounts when clicking the <> buttons.
-- First value is the small step (applied on left clicks), second value is the
-- big step (applied on right clicks)
valuebox.steps
-> [{1=Number,2=Number}]

-- Get/set the current value
valuebox.value
-> [number]

-- Valid in the construction table only: Setup custom rules on how the number
-- should be displayed. Both 'tostring' and 'tonumber' must be set, or neither.
-- If none are set, a default string/number conversion is done, which
-- simply reads/writes the number as integer value.
--
-- When defined, 'tostring' must be a function with one parameter, the
-- conversion procedure, and must return a string or nil.
-- 'tonumber' must be a function with one parameter, also the conversion
-- procedure, and return a a number or nil. When returning nil, no conversion is
-- done and the value is not changed.
--
-- Note: when any of the callbacks fail with an error, both will be disabled
-- to avoid a flood of error messages.
valuebox.tostring
-> (function(number) -> [string])
valuebox.tonumber
-> (function(string) -> [number])

-- Valid in the construction table only: Set up a value notifier.
valuebox.notifier
-> [function(number)]

-- Valid in the construction table only: Bind the view's value to a
-- renoise.Document.ObservableNumber object. Will change the Observable
-- value as soon as the views value changes, and change the view's value as
-- soon as the Observable's value changes - automatically keeps both values
-- in sync.
-- Notifiers can be added to either the view or the Observable object.
valuebox.bind
-> [ObservableNumber Object]

---

## -- renoise.Views.Value (inherits from View, 'value' in the builder)

-- A static text view. Shows a string representation of a number and
-- allows custom "number to string" conversion.
-- See 'Views.ValueField' for a value text field that can be edited by the user.

--[[

--. +---+-------+
--. | 12.1 dB |
--. +---+-------+

![Value](___REPLACE_URL___/Value.png)
]]--

-------- Functions

-- Add/remove value change notifiers.
value:add_notifier(function or {object, function} or {function, object})
value:remove_notifier(function or {object, function} or {function, object})

-------- Properties

-- Get/set the current value.
value.value
-> [number]

-- Get/set the style that the text should be displayed with.
-- Available font styles are:
-- > "normal"  
-- > "big"  
-- > "bold"  
-- > "italic"  
-- > "mono"
--
-- By default "normal".
value.font
-> [string]

-- Setup the value's text alignment. Valid values are:
-- > "left"  
-- > "right"  
-- > "center"
--
-- By default "left".
value.align
-> [string]

-- Valid in the construction table only: Setup a custom rule on how the
-- number should be displayed. When defined, 'tostring' must be a function
-- with one parameter, the conversion procedure, and must return a string
-- or nil.
--
-- Note: When the callback fails with an error, it will be disabled to avoid
-- a flood of error messages.
value.tostring
-> (function(number) -> [string])

-- Valid in the construction table only: Set up a value notifier.
value.notifier
-> [function(number)]

-- Valid in the construction table only: Bind the views value to a
-- renoise.Document.ObservableNumber object. Will change the Observable
-- value as soon as the views value changes, and change the view's value as
-- soon as the Observable's value changes - automatically keeps both values
-- in sync.
-- Notifiers can be added to either the view or the Observable object.
value.bind
-> [ObservableNumber Object]

---

## -- renoise.Views.ValueField (inherits from Control, 'valuefield' in the builder)

-- A text view, which shows a string representation of a number and allows
-- custom "number to string" conversion. The value's text can be edited by the
-- user.

--[[

--. +---+-------+
--. | 12.1 dB |
--. +---+-------+

![ValueField](___REPLACE_URL___/ValueField.png)
]]--

-------- Functions

-- Add/remove value change notifiers.
valuefield:add_notifier(function or {object, function} or {function, object})
valuefield:remove_notifier(function or {object, function} or {function, object})

-------- Properties

-- Get/set the min/max values that are expected, allowed.
-- By default 0.0 and 1.0.
valuefield.min
-> [number]
valuefield.max
-> [number]

-- Get/set the current value.
valuefield.value
-> [number]

-- Setup the text alignment. Valid values are:
-- > "left"  
-- > "right"  
-- > "center"
--
-- By default "left".
valuefield.align
-> [string]

-- Valid in the construction table only: setup custom rules on how the number
-- should be displayed. Both, 'tostring' and 'tonumber' must be set, or none
-- of them. If none are set, a default string/number conversion is done, which
-- simply shows the number with 3 digits after the decimal point.
--
-- When defined, 'tostring' must be a function with one parameter, the to be
-- converted number, and must return a string or nil.
-- 'tonumber' must be a function with one parameter and gets the to be
-- converted string passed, returning a a number or nil. When returning nil,
-- no conversion will be done and the value is not changed.
--
-- Note: when any of the callbacks fail with an error, both will be disabled
-- to avoid a flood of error messages.
valuefield.tostring
-> (function(number) -> [string])
valuefield.tonumber
-> (function(string) -> [number])

-- Valid in the construction table only: Set up a value notifier function.
valuefield.notifier
-> [function(number)]

-- Valid in the construction table only: Bind the view's value to a
-- renoise.Document.ObservableNumber object. Will change the Observable
-- value as soon as the views value changes, and change the view's value as
-- soon as the Observable's value changes - automatically keeps both values
-- in sync.
-- Notifiers can be added to either the view or the Observable object.
valuefield.bind
-> [ObservableNumber Object]

---

## -- renoise.Views.Slider (inherits from Control, 'slider' in the builder)

-- A slider with arrow buttons, which shows and allows editing of values in a
-- custom range. A slider can be horizontal or vertical; will flip its
-- orientation according to the set width and height. By default horizontal.

--[[

--. +---+---------------+
--. |<|>| --------[] |
--. +---+---------------+

![Slider](___REPLACE_URL___/Slider.png)
]]--

-------- Functions

-- Add/remove value change notifiers.
slider:add_notifier(function or {object, function} or {function, object})
slider:remove_notifier(function or {object, function} or {function, object})

-------- Properties

-- Get/set the min/max values that are expected, allowed.
-- By default 0.0 and 1.0.
slider.min
-> [number]
slider.max
-> [number]

-- Get/set inc/dec step amounts when clicking the <> buttons.
-- First value is the small step (applied on left clicks), second value is the
-- big step (applied on right clicks)
slider.steps
-> [{1=Number,2=Number}]

-- Get/set the default value (applied on double-click).
slider.default
-> [number]

-- Get/set the current value.
slider.value
-> [number]

-- Valid in the construction table only: Set up a value notifier function.
slider.notifier
-> [function(number)]

-- Valid in the construction table only: Bind the view's value to a
-- renoise.Document.ObservableNumber object. Will change the Observable
-- value as soon as the views value changes, and change the view's value as
-- soon as the Observable's value changes - automatically keeps both values
-- in sync.
-- Notifiers can be added to either the view or the Observable object.
slider.bind
-> [ObservableNumber Object]

---

## -- renoise.Views.MiniSlider (inherits from Control, 'minislider' in the builder)

-- Same as a slider, but without arrow buttons and a really tiny height. Just
-- like the slider, a mini slider can be horizontal or vertical. It will flip
-- its orientation according to the set width and height. By default horizontal.

--[[

--. --------[]

![MiniSlider](___REPLACE_URL___/MiniSlider.png)
]]--

-------- Functions

-- Add/remove value change notifiers.
minislider:add_notifier(function or {object, function} or {function, object})
minislider:remove_notifier(function or {object, function} or {function, object})

-------- Properties

-- Get/set the min/max values that are expected, allowed.
-- By default 0.0 and 1.0.
minislider.min
-> [number]
minislider.max
-> [number]

-- Get/set the default value (applied on double-click).
minislider.default
-> [number]

-- Get/set the current value.
minislider.value
-> [number]

-- Valid in the construction table only: Set up a value notifier.
minislider.notifier
-> [function(number)]

-- Valid in the construction table only: Bind the view's value to a
-- renoise.Document.ObservableNumber object. Will change the Observable
-- value as soon as the views value changes, and change the view's value as
-- soon as the Observable's value changes - automatically keeps both values
-- in sync.
-- Notifiers can be added to either the view or the Observable object.
minislider.bind
-> [ObservableNumber Object]

---

## -- renoise.Views.RotaryEncoder (inherits from Control, 'rotary' in the builder)

-- A slider which looks like a potentiometer.
-- Note: when changing the size, the minimum of either width or height will be
-- used to draw and control the rotary, therefor you should always set both
-- equally when possible.

--[[

--. +-+
--. / \ \
--.| o |
--. \ | /
--. +-+

![RotaryEncoder](___REPLACE_URL___/RotaryEncoder.png)
]]--

-------- Functions

-- Add/remove value change notifiers.
rotary:add_notifier(function or {object, function} or {function, object})
rotary:remove_notifier(function or {object, function} or {function, object})

-------- Properties

-- Get/set the min/max values that are expected, allowed.
-- By default 0.0 and 1.0.
rotary.min
-> [number]
rotary.max
-> [number]

-- Get/set the default value (applied on double-click).
rotary.default
-> [number]

-- Get/set the current value.
rotary.value
-> [number]

-- Valid in the construction table only: Set up a value notifier function.
rotary.notifier
-> [function(number)]

-- Valid in the construction table only: Bind the view's value to a
-- renoise.Document.ObservableNumber object. Will change the Observable
-- value as soon as the view's value changes, and change the view's value as
-- soon as the Observable's value changes - automatically keeps both values
-- in sync.
-- Notifiers can be added to either the view or the Observable object.
rotary.bind
-> [ObservableNumber Object]

---

## -- renoise.Views.XYPad (inherits from Control, 'xypad' in the builder)

-- A slider like pad which allows for controlling two values at once. By default
-- it freely moves the XY values, but it can also be configured to snap back to
-- a predefined value when releasing the mouse button.
--
-- All values, notifiers, current value or min/max properties will act just
-- like a slider or a rotary's properties, but nstead of a single number, a
-- table with the fields `{x = xvalue, y = yvalue}` is expected, returned.

--[[

--. +-------+
--. | o |
--. | + |
--. | |
--. +-------+

![XYPad](___REPLACE_URL___/XYPad.png)
]]--

-------- Functions

-- Add/remove value change notifiers.
xypad:add_notifier(function or {object, function} or {function, object})
xypad:remove_notifier(function or {object, function} or {function, object})

-------- Properties

-- Get/set a table of allowed min/max values.
-- By default 0.0 and 1.0 for both, x and y.
xypad.min
-> [{x=Number,y=Number}]
xypad.max
-> [{x=Number,y=Number}]

-- Get/set the pad's current value in a table.
xypad.value
-> [{x=Number,y=Number}]

-- When snapback is enabled an XY table is returned, else nil. To enable
-- snapback, pass an XY table with desired values. Pass nil or an empty table
-- to disable snapback.
-- When snapback is enabled, the pad will revert its values to the specified
-- snapback values as soon as the mouse button is released in the pad. When
-- disabled, releasing the mouse button will not change the value.
xypad.snapback
-> [{x=Number,y=Number}]

-- Valid in the construction table only: Set up a value notifier function.
xypad.notifier
-> [function(value={x=Number,y=Number})]

-- Valid in the construction table only: Bind the view's value to a pair of
-- renoise.Document.ObservableNumber objects. Will change the Observable
-- values as soon as the views value changes, and change the view's values as
-- soon as the Observable's value changes - automatically keeps both values
-- in sync.
-- Notifiers can be added to either the view or the Observable object.
-- Just like in the other XYPad properties, a table with the fields X and Y
-- is expected here and not a single value. So you have to bind two
-- ObservableNumber object to the pad.
xypad.bind
-> [{x=ObservableNumber Object, y=ObservableNumber Object}]

--==============================================================================
-- renoise.Dialog
--==============================================================================

-- Dialogs can not created with the viewbuilder, but only by the application.
-- See "create custom views" on top of this file how to do so.

-------- Functions

-- Bring an already visible dialog to front and make it the key window.
dialog:show()

-- Close a visible dialog.
dialog:close()

-------- Properties

-- Check if a dialog is alive and visible.
dialog.visible
-> [read-only, boolean]

--==============================================================================
-- renoise.ViewBuilder
--==============================================================================

-- Class which is used to construct new views. All view properties, as listed
-- above, can optionally be in-lined in a passed construction table:
--
-- local vb = renoise.ViewBuilder() -- create a new ViewBuilder
-- vb:button { text = "ButtonText" } -- is the same as
-- my_button = vb:button(); my_button.text = "ButtonText"
--
-- Besides the listed class properties, you can also specify the following
-- "extra" properties in the passed table:
--
-- _ id = "SomeString": Can be use to resolve the view later on, e.g.
-- `vb.views.SomeString` or `vb.views["SomeString"]`
--
-- _ notifier = some_function or notifier = {some_obj, some_function} to
-- register value change notifiers in controls (views which represent values)
--
-- _ bind = a_document_value (Observable) to bind a view's value directly
-- to an Observable object. Notifiers can be added to the Observable or
-- the view. After binding a value to a view, the view will automatically
-- update its value as soon as the Observable's value changes, and the
-- Observable's value will automatically be updated as soon as the view's
-- value changes.
-- See "Renoise.Document.API.lua" for more general info about Documents &
-- Observables.
--
-- _ Nested child views: Add a child view to the currently specified view.
-- For example:
--
-- vb:column {
-- margin = 1,
-- vb:text {
-- text = "Text1"
-- },
-- vb:text {
-- text = "Text1"
-- }
-- }
--
-- Creates a column view with `margin = 1` and adds two text views to the column.

-------- Constants

-- Default sizes for views and view layouts. Should be used instead of magic
-- numbers, also useful to inherit global changes from the main app.
renoise.ViewBuilder.DEFAULT_CONTROL_MARGIN
renoise.ViewBuilder.DEFAULT_CONTROL_SPACING
renoise.ViewBuilder.DEFAULT_CONTROL_HEIGHT
renoise.ViewBuilder.DEFAULT_MINI_CONTROL_HEIGHT
renoise.ViewBuilder.DEFAULT_DIALOG_MARGIN
renoise.ViewBuilder.DEFAULT_DIALOG_SPACING
renoise.ViewBuilder.DEFAULT_DIALOG_BUTTON_HEIGHT

-------- Functions

-- Column, row.
vb:column { Rack Properties and/or child views }
-> [Rack object]
vb:row { Rack Properties and/or child views }
-> [Rack object]

-- Aligners.
vb:horizontal_aligner { Aligner Properties and/or child views }
-> [Aligner object]
vb:vertical_aligner { Aligner Properties and/or child views }
-> [Aligner object]

-- Space.
vb:space { View Properties and/or child views }
-> [View object]

-- Text.
vb:text { Text Properties }
-> [Text object]
vb:multiline_text { MultiLineText Properties }
-> [MultilineText object]
vb:textfield { TextField Properties }
-> [TextField object]

-- Bitmap.
vb:bitmap { Bitmap Properties }
-> [Bitmap object]

-- Button.
vb:button { Button Properties }
-> [Button object]

-- Checkbox, switch, popup, chooser.
vb:checkbox { Rack Properties }
-> [CheckBox object]
vb:switch { Switch Properties }
-> [Switch object]
vb:popup { Popup Properties }
-> [Popup object]
vb:chooser { Chooser Properties }
-> [Chooser object]

-- Values.
vb:valuebox { ValueBox Properties }
-> [ValueBox object]

vb:value { Value Properties }
-> [Value object]
vb:valuefield { ValueField Properties }
-> [ValueField object]

-- Sliders, rotary, XYPad.
vb:slider { Slider Properties }
-> [Slider object]
vb:minislider { MiniSlider Properties }
-> [MiniSlider object]

vb:rotary { RotaryEncoder Properties }
-> [RotaryEncoder object]

vb:xypad { XYPad Properties }
-> [XYPad object]

-------- Properties

-- View id is the table key, the table's value is the view's object.
-- > e.g.: vb:text{ id="my*view", text="some_text"}  
-- > vb.views.my_view.visible = false *(or)\_  
-- > vb.views["my_view"].visible = false
vb.views
-> [table of views, which got registered via the "id" property]
