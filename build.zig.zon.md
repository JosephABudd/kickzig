## My additions to build.zig.zon

### dvui

* lines 5 - 8 were added by the command `zig fetch https://github.com/david-vanderson/dvui/archive/dc3340403a8c04bf343e6c92215d4908745354eb.tar.gz --save`.

### fridge (sqlite)

* lines 9 - 12 were added by the command `zig fetch https://github.com/cztomsik/fridge/archive/c8a5bebd80f04234b77ce61f145bc55e5067e53e/.tar.gz --save`.

```zig
  1 ⎥ .{
  2 ⎥     .name = "crud",
  3 ⎥     .version = "0.0.0",
  4 ⎥     .dependencies = .{
  5 ⎥         .dvui = .{
  6 ⎥             .url = "https://github.com/david-vanderson/dvui/archive/dc3340403a8c04bf343e6c92215d4908745354eb.tar.gz",
  7 ⎥             .hash = "1220f0f7d58754fa0286ff14b9dd4d3c2dca57e9b372b15de8bf753fec58e22485df",
  8 ⎥         },
  9 ⎥         .fridge = .{
 10 ⎥             .url = "https://github.com/cztomsik/fridge/archive/c8a5bebd80f04234b77ce61f145bc55e5067e53e/.tar.gz",
 11 ⎥             .hash = "12202353d7b264aa664e29e70cfdac5d9a1106294e4d1383c96cc1a2fcd49e288fd5",
 12 ⎥         },
 13 ⎥     },
 14 ⎥     // Specifies the set of files and directories that are included in this package.
 15 ⎥     // Only files and directories listed here are included in the `hash` that
 16 ⎥     // is computed for this package.
 17 ⎥     // Paths are relative to the build root. Use the empty string (`""`) to refer to
 18 ⎥     // the build root itself.
 19 ⎥     // A directory listed here means that all files within, recursively, are included.
 20 ⎥     .paths = .{
 21 ⎥         // This makes *all* files, recursively, included in this package. It is generally
 22 ⎥         // better to explicitly list the files and directories instead, to insure that
 23 ⎥         // fetching from tarballs, file system paths, and version control all result
 24 ⎥         // in the same contents hash.
 25 ⎥         "",
 26 ⎥         // For example...
 27 ⎥         //"build.zig",
 28 ⎥         //"build.zig.zon",
 29 ⎥         //"src",
 30 ⎥         //"LICENSE",
 31 ⎥         //"README.md",
 32 ⎥     },
 33 ⎥ 
 ```
