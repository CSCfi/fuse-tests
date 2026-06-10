#!/usr/bin/env bash
sbatch --account project_2001659 --partition=interactive --time=0:05:00 --nodes=1 --ntasks-per-node=1 --cpus-per-task=1 --mem 8000 --argos=no <<BASH
#!/bin/bash
module purge
module load julia
julia run.jl "$1"
BASH
