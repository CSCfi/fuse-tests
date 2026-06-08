Test performance of reading lot of small files from FUSE mounted squashfs.

Create squashfs

```bash
./build_squashfs 10000
```

Run benchmark:

```bash
srun --account project_2001659 --partition=interactive --time=0:05:00 --nodes=1 --ntasks-per-node=1 --cpus-per-task=1 --mem 8000 --pty ./run_read.sh
```
