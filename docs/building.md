# Building from source, requirements and measured results

This page is about building and testing the layer itself. Nothing here needs, reads
or ships game files; `cargo test --workspace` runs without them.

## Requirements

To build and test:

- Windows 10 or 11, x64
- Rust **1.98.1**, pinned in `rust-toolchain.toml` (`rustup` installs it on the first
  `cargo` command), with the MSVC build tools
- Disk: the `target\` folder grows to several GB for a debug plus a release build

To run the layer (from the rest of this repository's documentation; not re-checked here):

- A CPU with AVX2
- A Direct3D 12 GPU with shader model 6.6, and mesh shaders for the world. Windows 10
  stops at 6.5 without the D3D12 Agility SDK (see the README)
- 32 GB of RAM or more is what the README asks for, plus an SSD. With less, see
  [windows-memory.md](windows-memory.md): Windows error 1455 means the commit limit
  was reached
- An NVIDIA GeForce RTX card for DLSS. Frame generation limits by card are in the
  README's first table

## Frame rates

Frame rates in this repository's documentation were measured by their authors on
their own machines (named next to each figure). They are not a promise for any other
machine. **A stable 30 frames a second on your hardware is unverified until you
measure it yourself.**

## Commands, as CI runs them

```powershell
cargo build --workspace --locked
cargo clippy --workspace --all-targets --locked -- -D warnings
cargo clippy --workspace --all-targets --all-features --locked -- -D warnings
cargo test --workspace --locked
cargo xtask policy        # nothing proprietary in the tree
```

Some timing tests are `#[ignore]`d micro-benchmarks on synthetic data, for example
`cargo test -p victory-gpu --release -- --ignored --nocapture copy_costs`.

For a PC with 16 GB of RAM and an 8 GB card, `victory play --low-memory` (see
[windows-memory.md](windows-memory.md)) sets Series S at its smallest scene, no
frame generation, a 7,168 MB budget for the card and two pipeline workers. It has
not been measured in play.

## Measured results

On one PC: Intel Core i5-12400F (6 cores, 12 threads), 16 GB DDR4-3200, GeForce
RTX 3050 8 GB, Windows 11 Pro (build 26300), SSD; Rust 1.98.1. No game files were
used. Build and test times include compiling.

| Command (2026-11-28, from a warm `target\`) | Result | Time |
| --- | --- | --- |
| `cargo build --workspace --locked` | ok | 97 s |
| `cargo test --workspace --locked` | 1,126 passed, 0 failed, 49 ignored (upstream `63b902f`) | 416 s |
| `cargo xtask policy` | 295 files ok | 2 s |

Micro-benchmarks on synthetic data (release build, best of several runs, each run twice):

| What | Before | After |
| --- | --- | --- |
| Ordering the texture queue's due slots, 40,000 slots, a pass of 4,096 (`due_order_costs`) | 0.94-1.14 ms | 0.41-0.57 ms |
| The same, 10,000 slots | 0.28 ms | 0.22 ms |
| The same, a pass of 65,536 (all of them: still a full sort) | 1.41-1.48 ms | 1.35-1.49 ms |
| Mirroring the slots a descriptor copy wrote, per slot, copies of 8 / 64 / 256 slots, host heap not made yet (`mirror_costs`) | 25.5 / 27.3 / 27.1 ns | 5.1 / 3.2 / 2.8 ns |
| The same, copies of 1 slot | 25.4 ns | 25.9 ns |

The first rows include making the queue (0.03-0.2 ms). The mirroring rows measure
the lookup and locking around each slot, not making the host descriptor. What either
change does to a real frame depends on the title's own work, and was not measured.
