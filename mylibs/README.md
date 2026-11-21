# Bundled allocator

`libmimalloc.a` is built from Microsoft mimalloc **v3.7.0** (MIT; see
`mimalloc.LICENSE`), tag commit
`1ed67b5156a763441d2ec3c20221a7b3cd866129`.

The build script downloads the fixed commit archive from
https://github.com/microsoft/mimalloc/archive/1ed67b5156a763441d2ec3c20221a7b3cd866129.tar.gz
and checks SHA256
`a207a0802234ff9d21e7511eee52375e6299fa2ac7b25eb4ce26b579a7735c8c`.
The official tag archive https://github.com/microsoft/mimalloc/archive/v3.7.0.tar.gz
has SHA256 `1b8653b9ff9b841a97f2c50fd996e89e1a0cb712c3c5b0980ef16a027eb7acf8`;
both archives were checked to contain identical source files.

The bundled archive was built with GCC 16.2.1 and CMake 3.31.6 on x86-64 Linux.
Its SHA256 is `58eb1139534933c5f13d18c5a20e50d89f647e335441eb38cb92499379146c2e`.

From the packaging repository root, run `sh mylibs/build-mimalloc.sh` with
GCC, CMake, Ninja, curl and pkg-config available. It builds a Release static
archive with PIC and standard allocator overrides, disables statistics and
profiling, and uses dlopen-compatible local-dynamic TLS. The upstream security
default is retained; architecture-specific flags are disabled so the compiler's
default ISA/tuning is used. No C++ or OpenMP runtime is introduced. Only the
upstream API and API-fill tests are built and run before replacing the archive.
`CC` and `JOBS` may select the compiler and parallelism (default: GCC and 4).
Build/download artifacts stay in the ignored `tmp/mimalloc-3.7.0/` directory
and may be removed after inspection; nothing is installed on the host.

`mimalloc.pc` remains relocatable for the workflow's `/tmp/mylibs` location.
Consumers keep ordinary `-lmimalloc` archive extraction, with no whole-archive
or artificial allocator anchor. Check standard allocator definitions and dynamic
bindings in the final executable when changing consumer link flags.

Local PIE/LTO consumer checks passed both without an extra export flag and with
the Linux `--export-dynamic` flag used by QEMU's GLib module export dependency.
The standard allocator aliases, dynamic exports, dlopen plugin cross-frees and
four-thread allocations were checked. This is not a full QEMU/package build.

There is intentionally no bundled `libm.a`: `-lm` must resolve to the system
math library, not OpenLibm. Keep the library search path for mimalloc.
