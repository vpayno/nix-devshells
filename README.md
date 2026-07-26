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
Available nix-devshells-20260725.0.2 flake commands:

  nix run .#flakeShowUsage | .#default     # this message

  nix run .#showLatestRustVersions         # Shows the list of the latest Rust versions from the GitHub repo

  nix develop .#default                    # nix-shell
  nix develop .#openjdk-11                 # openjdk-11
  nix develop .#openjdk-17                 # openjdk-17
  nix develop .#openjdk-21                 # openjdk-21
  nix develop .#openjdk-25                 # openjdk-25
  nix develop .#openjdk-8                  # openjdk-8
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
  nix develop .#rust-1_88                  # rust-1_88
  nix develop .#rust-1_89                  # rust-1_89
  nix develop .#rust-1_90                  # rust-1_90
  nix develop .#rust-1_91                  # rust-1_91
  nix develop .#rust-1_92                  # rust-1_92
  nix develop .#rust-1_93                  # rust-1_93
  nix develop .#rust-1_94                  # rust-1_94
  nix develop .#rust-1_95                  # rust-1_95
  nix develop .#rust-1_96                  # rust-1_96
  nix develop .#rust-1_97                  # rust-1_97
```
