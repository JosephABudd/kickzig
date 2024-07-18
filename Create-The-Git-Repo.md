1. At github.com, I created an empty "crud" repo.
2. Then on my laptop I
   1. cloned it,
   1. cd'd into the cloned crud/ folder,
   1. created the framework,
   1. fetch my external packages,
   1. built it using zig version 13,
   1. ran it.

```shell
＄ git clone https://github.com/JosephABudd/crud.git
＄ cd crud
＄ kickzig framework
＄ zig fetch https://github.com/david-vanderson/dvui/archive/dc3340403a8c04bf343e6c92215d4908745354eb.tar.gz --save
＄ zig fetch https://github.com/cztomsik/fridge/archive/c8a5bebd80f04234b77ce61f145bc55e5067e53e/.tar.gz --save
＄ zig13 build -freference-trace=255
＄ ./zig-out/bin/crud
```

![The framework.](./images/crud_framework.png)

## Next

[[Create The Data Store.|Create-The-Data-Store]]
