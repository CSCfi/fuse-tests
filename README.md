Test performance of reading lot of small files from FUSE mounted squashfs.

Create squashfs

```bash
./build_squashfs 10000
```

Run benchmark:

```bash
./run_read.sh
```
