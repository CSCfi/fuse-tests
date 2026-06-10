# FUSE tests

Install tests:

```bash
mkdir -p /scratch/project_2001659/$USER
cd /scratch/project_2001659/$USER
git clone https://github.com/CSCfi/fuse-tests
```

## Performance of reading lots of small files

Test performance of reading lot of small files from FUSE mounted squashfs.

```bash
cd read_small_files
```

Create squashfs:

```bash
module load julia
julia build_files.jl 10000
```

Run benchmark:

```bash
./run.sh 10000
```

## Performance of writing lots of small files

Test performance of writing lots of small files, comparing Lustre scratch
against a `fuse2fs` mounted ext4 image.

```bash
cd write_small_files
```

Create the ext4 image:

```bash
module load julia
julia build_files.jl 10000
```

Run benchmark:

```bash
./run.sh 10000
```
