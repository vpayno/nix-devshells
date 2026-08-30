# nix-devshells

Nix flake with `devShells` for multiple programming languages and multiple
versions.

## linting & formatting

Use `nix fmt` to lint and format the repo using
`github:vpayno/nix-treefmt-conf`.

## usage

To show the flake usage message run

```bash
nix run .#default
```

Example output:

```text
$ nix run .#default

Available nix-devshells-20260829.1.1 flake commands:

  nix run .#flakeShowUsage | .#default     # this message

  nix run .#showLatestRustVersions         # Shows the list of the latest Rust versions from the GitHub repo

  nix develop .#default                    # nix-shell
  nix develop .#gcc13                      # gcc-13
  nix develop .#gcc14                      # gcc-14
  nix develop .#gcc15                      # gcc-15
  nix develop .#gcc16                      # gcc-16
  nix develop .#gfortran13                 # gfortran-13
  nix develop .#gfortran14                 # gfortran-14
  nix develop .#gfortran15                 # gfortran-15
  nix develop .#gfortran16                 # gfortran-16
  nix develop .#go_1_25                    # go-1_25
  nix develop .#go_1_26                    # go-1_26
  nix develop .#go_1_27                    # go-1_27
  nix develop .#llvm-clang-18              # llvm-clang-18
  nix develop .#llvm-clang-19              # llvm-clang-19
  nix develop .#llvm-clang-20              # llvm-clang-20
  nix develop .#llvm-clang-21              # llvm-clang-21
  nix develop .#llvm-clang-22              # llvm-clang-22
  nix develop .#mpich2-gcc13               # mpich2-gcc13
  nix develop .#mpich2-gcc14               # mpich2-gcc14
  nix develop .#mpich2-gcc15               # mpich2-gcc15
  nix develop .#mpich2-gcc16               # mpich2-gcc16
  nix develop .#openjdk11                  # openjdk-11
  nix develop .#openjdk11_headless         # openjdk-11
  nix develop .#openjdk17                  # openjdk-17
  nix develop .#openjdk17_headless         # openjdk-17
  nix develop .#openjdk21                  # openjdk-21
  nix develop .#openjdk21_headless         # openjdk-21
  nix develop .#openjdk25                  # openjdk-25
  nix develop .#openjdk25_headless         # openjdk-25
  nix develop .#openjdk8                   # openjdk-8
  nix develop .#openjdk8_headless          # openjdk-8
  nix develop .#openssl-1_0                # openssl-1_0
  nix develop .#openssl-1_1                # openssl-1_1
  nix develop .#openssl-3_0                # openssl-3_0
  nix develop .#openssl-3_1                # openssl-3_1
  nix develop .#openssl-3_2                # openssl-3_2
  nix develop .#openssl-3_3                # openssl-3_3
  nix develop .#openssl-3_4                # openssl-3_4
  nix develop .#openssl-3_5                # openssl-3_5
  nix develop .#openssl-3_6                # openssl-3_6
  nix develop .#openssl-4_0                # openssl-4_0
  nix develop .#openssl-lts                # openssl-3_5
  nix develop .#rust-1_89                  # rust-1_89
  nix develop .#rust-1_90                  # rust-1_90
  nix develop .#rust-1_91                  # rust-1_91
  nix develop .#rust-1_92                  # rust-1_92
  nix develop .#rust-1_93                  # rust-1_93
  nix develop .#rust-1_94                  # rust-1_94
  nix develop .#rust-1_95                  # rust-1_95
  nix develop .#rust-1_96                  # rust-1_96
  nix develop .#rust-1_97                  # rust-1_97
  nix develop .#rust-1_98                  # rust-1_98
```
