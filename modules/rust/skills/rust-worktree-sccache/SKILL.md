---
name: rust-worktree-sccache
description: Before running Cargo builds, checks, tests, or benchmarks, detect linked Git worktrees and configure invocation-local incremental compilation and sccache settings. Use especially for temporary Rust worktrees; preserve the main checkout's normal incremental compilation.
---

# Rust compilation in linked worktrees

This user's Rust module installs sccache and normally exports `RUSTC_WRAPPER`,
`SCCACHE_DIR`, and `SCCACHE_CACHE_SIZE`. Linked worktrees should prefer the shared
compiler cache over incremental state specific to a short-lived checkout.

## Detect the checkout

Run from the directory where Cargo will run, including when inside a crate:

```bash
git_dir=$(git rev-parse --path-format=absolute --git-dir) &&
common_dir=$(git rev-parse --path-format=absolute --git-common-dir) &&
test "$git_dir" != "$common_dir"
```

Only unequal paths after both successful queries identify a linked worktree.
Equal paths mean the main checkout. A failed Git query does not establish either
case. A `.git` file alone is insufficient: submodules and separate Git directories
also use files. Branch names and folder naming conventions are not evidence.

## Configure the Cargo invocation

In a linked worktree, set `CARGO_INCREMENTAL=0` for Cargo commands that compile
code, including build, check, test, clippy, bench, and run. Keep each worktree's
target directory separate. Do not persist this override in global session
variables, Cargo.toml, or repository Cargo configuration, and do not delete
existing build artifacts. In the main checkout or outside Git, preserve the
existing incremental setting. Explicit user instructions take precedence.

Confirm that sccache is available and inspect the effective wrapper, including
`RUSTC_WRAPPER`, `RUSTC_WORKSPACE_WRAPPER`, and applicable Cargo configuration.
Preserve an existing sccache wrapper. If no wrapper is configured, supply
`RUSTC_WRAPPER="$(command -v sccache)"` for this invocation. Do not silently replace
a different wrapper or an explicit wrapper disable; explain any resulting cache
limitation. If sccache is unavailable, report that and preserve the existing
compilation settings rather than disabling incremental for no cache benefit.

With the module's sccache wrapper already active:

```bash
env CARGO_INCREMENTAL=0 cargo build
```

Put these environment settings on the actual Cargo process, after entering any
Nix shell or other environment boundary. A systemd service does not automatically
inherit the calling shell's environment: pass the wrapper and cache settings
explicitly when needed. Keep all repository-required memory limits and other
build constraints in place.

## Check the result without overstating caching

Rust incremental compilation is incompatible with sccache caching. Disabling it
only makes otherwise eligible compilations cacheable; it does not ensure a hit.
Crates that invoke the linker (including binaries and proc macros) are not cached,
and metadata-only `cargo check` invocations may not be cacheable. Toolchain, flags,
source paths, and inputs can also change cache keys across worktrees.

When verifying cache behavior, compare `sccache --show-stats` before and after an
actual compilation. A Cargo-fresh build does not exercise sccache. Shared counters
may include other processes, so do not treat their delta as isolated proof. Do not
clear the shared cache, reset shared statistics, or clean target directories just
to demonstrate a hit. Do not introduce path-remapping flags without separately
evaluating their effects on diagnostics and debugging.

Reference: [sccache Rust support](https://github.com/mozilla/sccache/blob/main/docs/Rust.md).
