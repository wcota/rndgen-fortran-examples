# rndgen-fortran-examples

Examples and tests for the [`rndgen-fortran`](https://github.com/wcota/rndgen-fortran) library, which implements multiple pseudo-random number generators (PRNGs) as Fortran objects. This repository provides comprehensive examples, benchmarks, and statistical tests comparing the available generators.

## Generators

### xoshiro256\*\* (recommended for general use)

**xoshiro256\*\*** (XOR/shift/rotate, 256 bits) by David Blackman and Sebastiano Vigna is the primary recommended generator. The original C implementation is available at <https://prng.di.unimi.it/xoshiro256starstar.c> and is dedicated to the **public domain** worldwide (Creative Commons CC0). The Fortran implementation in this library is adapted from [`fortran-lang/stdlib`](https://github.com/fortran-lang/stdlib).

Key properties:

- **256-bit state**, period $2^{256} − 1$
- Excellent sub-nanosecond speed
- Passes all known statistical tests (BigCrush, PractRand)
- 4-dimensionally equidistributed
- Provides jump functions (equivalent to $2^{128}$ and $2^{192}$ calls) for non-overlapping parallel streams
- State seeded via SplitMix64 from a single integer seed
- Adopted as default PRNG by GNU Fortran, .NET, Lua, and others

More information: <https://prng.di.unimi.it/>

### KISS (Keep It Simple Stupid)

**KISS05** is a classical 32-bit generator combining three sub-generators:

The KISS implementation is adapted from [Thomas Vojta](http://thomasvojta.com/)'s code at <http://web.mst.edu/~vojtat/class_5403/kiss05/rkiss05.f90>:

```txt
! Random number generator KISS05 after a suggestion by George Marsaglia
! in "Random numbers for C: The END?" posted on sci.crypt.random-numbers
! in 1999
!
! version as in "double precision RNGs" in  sci.math.num-analysis
! http://sci.tech-archive.net/Archive/sci.math.num-analysis/2005-11/msg00352.html
!
! The  KISS (Keep It Simple Stupid) random number generator. Combines:
! (1) The congruential generator x(n)=69069*x(n-1)+1327217885, period 2^32.
! (2) A 3-shift shift-register generator, period 2^32-1,
! (3) Two 16-bit multiply-with-carry generators, period 597273182964842497>2^59
! Overall period > 2^123
!
!
! A call to rkiss05() gives one random real in the interval [0,1),
! i.e., 0 <= rkiss05 < 1
!
! Before using rkiss05 call kissinit(seed) to initialize
! the generator by random integers produced by Park/Millers
! minimal standard LCG.
! Seed should be any positive integer.
!
! FORTRAN implementation by Thomas Vojta, vojta@mst.edu
! built on a module found at www.fortran.com
!
!
! History:
!        v0.9     Dec 11, 2010    first implementation
!        V0.91    Dec 11, 2010    inlined internal function for the SR component
!        v0.92    Dec 13, 2010    extra shuffle of seed in kissinit
!        v093     Aug 13, 2012    changed inter representation test to avoid data statements
```

## Benchmark Results

Tests were run generating 500,000,000 double-precision values (array fill), comparing KISS, xoshiro256\*\*, the Fortran intrinsic `random_number`, and the Numerical Recipes ran2 generator.

### Benchmark Environment

| Property | Value |
|---|---|
| CPU model | Intel(R) Core(TM) i7-14700 |
| Pinned logical CPU | 16 |
| CPU type | E-core (single-threaded core in this topology) |
| CPU frequency (CPU 16) | min 800.0000 MHz, max 4200.0000 MHz |
| CPU affinity | `taskset -c 16` |


### Performance (500 M doubles)

| Generator | Time (s) | Throughput (M/s) |
|---|---|---|
| **xoshiro256\*\*** | **1.63** | **~307 M** |
| Fortran Intrinsic | 6.53 | ~76.5 M |
| KISS | 2.27 | ~219.8 M |
| ran2 | 6.97 | ~71.8 M |

Reference: `test/output/gfortran/-O3/benchmark_duel.txt`.

### Compiler and Optimization Comparison

The benchmark artifacts in `test/output/{gfortran,ifx}/-O{0,1,2,3}/benchmark_duel.txt` allow direct comparison of optimization level and compiler choice.

| Compiler | Opt | xoshiro256\*\* (s) | KISS (s) | Intrinsic (s) | ran2 (s) |
|---|---|---:|---:|---:|---:|
| gfortran | -O0 | 5.8292 | 7.8227 | 7.3918 | 10.7509 |
| gfortran | -O1 | 1.9456 | 2.7632 | 6.6771 | 7.3670 |
| gfortran | -O2 | 1.6235 | 2.9214 | 6.5278 | 7.2672 |
| gfortran | -O3 | 1.6260 | 2.2748 | 6.5325 | 6.9686 |
| ifx | -O0 | 5.2652 | 5.7013 | 7.5891 | 14.3881 |
| ifx | -O1 | 1.8683 | 2.7610 | 6.4842 | 7.4048 |
| ifx | -O2 | 1.8745 | 2.7660 | 6.5711 | 7.3734 |
| ifx | -O3 | 1.8712 | 2.7604 | 6.4163 | 7.5204 |

Quick reading:

- `-O1` already delivers most of the speedup for both compilers.
- Best xoshiro256\*\* result in this dataset is `gfortran -O2` (1.6235 s), statistically tied with `gfortran -O3` (1.6260 s).
- `ifx -O1` is the fastest ifx configuration for xoshiro256\*\* (1.8683 s), very close to `-O3` (1.8712 s).
- Functionality is stable across all tested optimization levels (`-O0` to `-O3`) for both `gfortran` and `ifx` in the provided test output set.

### Statistical Quality

| Test | KISS | xoshiro256\*\* | Intrinsic | ran2 |
|---|---|---|---|---|
| Mean ≈ 0.5 | ✓ | ✓ | ✓ | ✓ |
| Variance ≈ 1/12 | ✓ | ✓ | ✓ | ✓ |
| Lag-1 autocorrelation ≈ 0 | ✓ | ✓ | ✓ | ✓ |
| Bit balance (monobit) | ✗ bias | **✓** | ✗ bias | ✗ bias |
| Native bit width | 32-bit | **64-bit** | 64-bit | 64-bit |

**xoshiro256\*\*** is the fastest generator and the only one to pass the raw bit balance test, making it the recommended choice for general-purpose scientific simulations.

## Usage

Add the library as a dependency using the [Fortran Package Manager](https://fpm.fortran-lang.org/) (fpm):

```toml
[dependencies]
rndgen-fortran = {git = "https://github.com/wcota/rndgen-fortran", tag = "v2"}
```

```fortran
use rndgen_mod
implicit none

! Use xoshiro256** (default)
type(rndgen_t) :: rng

call rng%init(iseed = 42)

print *, rng%rnd()          ! real in [0, 1)
print *, rng%int(1, 100)    ! integer in [1, 100]
print *, rng%real(-1.0d0, 1.0d0)  ! real in [-1, 1)
```

To use KISS instead, use `rndgen_kiss_t` instead of `rndgen_t`. Both types share the same interface via the `rndgen_base_t` abstract base class.

## Running Examples

```bash
fpm run --example simple
fpm run --example arrays
fpm run --example vojta
fpm run --example save
fpm run --example 2gen -- 12345 67890
fpm run --example 2gen-invert -- 12345 67890
fpm run --example PL
fpm run --example PL-arrays
```

Expected outputs are available at [example/output-*.txt](example/).

### Parallel Example

The OpenMP parallel example requires passing `--flag="-fopenmp"` so that the runtime and compiler enable OpenMP support:

```bash
fpm run --example parallel --flag="-fopenmp"
```

To compare compilers and optimization levels in a controlled way, you can pin execution to a CPU range and vary the compiler/optimization flags:

```bash
taskset -c 16-27 fpm run --example parallel --compiler=gfortran --flag="-fopenmp -O2"
taskset -c 16-27 fpm run --example parallel --compiler=ifx --flag="-fopenmp -O2"
```

The example uses 12 OpenMP threads in this run set and jumps the xoshiro state per thread, so the result is thread-safe and reproducible for the chosen seed.

## Running Tests

```bash
fpm test
```

Tests cover: core functionality, integer generation, real generation, array generation, state save/restore, statistical properties (mean, variance), autocorrelation, bit balance, avalanche effect, period estimation, and head-to-head benchmarks.

Expected outputs are available at [test/output-*.txt](test/).

### Parallel Benchmark Summary

The parallel Monte Carlo Pi example was benchmarked on CPUs 16-27 with 12 threads. Lower wall time is better; CPU time shows total work consumed across all threads.

| Compiler | Opt | Wall Time (s) | CPU Time (s) |
|---|---|---:|---:|
| gfortran | -O0 | 1.3782 | 11.9053 |
| gfortran | -O1 | 0.4583 | 3.8012 |
| gfortran | -O2 | 0.3687 | 2.4404 |
| gfortran | -O3 | 0.4178 | 3.3189 |
| ifx | -O0 | 1.7515 | 15.7293 |
| ifx | -O1 | 0.8522 | 7.8766 |
| ifx | -O2 | 1.8997 | 15.9266 |
| ifx | -O3 | 0.8765 | 7.8759 |

Quick reading:

- Best wall time in this run set is `gfortran -O2` at 0.3687 s.
- `gfortran` is consistently faster than `ifx` for this parallel example on the selected CPU range.
- `-O2` is the best overall setting here for `gfortran`; for `ifx`, `-O1` and `-O3` are close, with `-O1` slightly ahead on wall time.

## Compilers

Tested with `gfortran`, `ifort`, and `ifx`. To use a specific compiler:

```bash
fpm test --compiler=ifort
```
