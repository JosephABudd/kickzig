
## The vendor/ folder

### The known-folders package

[Super Auguste et al's known-folders package](https://github.com/ziglibs/known-folders) provides known file paths for OSs. I need it for the data folder path so I know where to put the sqlite file.

```shell
＄ git clone https://github.com/ziglibs/known-folders.git  src/vendor/known-folders/
```

### The sqlite-zig package

[LeRoyce Pearson's sqlite-zig package](https://github.com/leroycep/sqlite-zig.git)

```shell
＄ git clone https://github.com/leroycep/sqlite-zig.git  src/vendor/sqlite-zig/
```

## The cruds build.zig file

When I vendor a package I need to copy the important parts of it's build.zig file into this application's build.zig file.

You can see those additions to the application's [[build.zig|build.zig]] in the appendix.

## Next

[[Create The Data Store.|Create-The-Data-Store]]
