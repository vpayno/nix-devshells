# flake.nix
{
  description = "Flake with devshells";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    systems.url = "github:vpayno/nix-systems-default";

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };

    treefmt-conf = {
      url = "github:vpayno/nix-treefmt-conf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      systems,
      flake-utils,
      treefmt-conf,
      rust-overlay,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (system: {
      formatter = treefmt-conf.formatter.${system};
    })
    // flake-utils.lib.eachDefaultSystem (
      system:
      let

        overlays = [ (import rust-overlay) ];

        pkgs = import nixpkgs {
          inherit system overlays;
        };

        makeShellScripts =
          scripts: pkgs.lib.mapAttrsToList (name: script: pkgs.writeShellScriptBin name script) scripts;

        commonShellScripts = makeShellScripts {
          scriptname = ''
            : script body
          '';
        };

        commonDevShellBuildInputs =
          with pkgs;
          [
            bashInteractive
            coreutils
            moreutils
            git
            github-cli
            glab
            glow
            runme
            jq
            taplo-cli
            tig
            toml-cli
            toml-sort
            tomlq
            xq-xml
            yq-go

            (lib.lowPrio util-linux) # conflicts with other pkgs
          ]
          ++ commonShellScripts;

        rustLinuxOnlyPkgs =
          with pkgs;
          if stdenv.isLinux then
            [
              cargo-llvm-cov
            ]
          else
            [ ];

        rustDevShellBuildInputs =
          with pkgs;
          [
            bacon
            cargo-audit
            cargo-binutils
            cargo-bump
            cargo-edit
            cargo-flamegraph
            cargo-info
            cargo-license
            cargo-outdated
            cargo-readme
            cargo-sort
            cargo-spellcheck
            cargo-tarpaulin
            cargo-toml-lint
            cargo-update
            cargo-watch
            grcov
            # rust-analyzer # is this in the overlay package?
          ]
          ++ rustLinuxOnlyPkgs;

        rustDevShellHookCommon = ''
          export CARGO_HOME="$PWD/.cargo"
          [[ -d $CARGO_HOME/bin ]] && mkdir -pv "$CARGO_HOME/bin"
          export PATH="$CARGO_HOME/bin:$PATH"

          rustc --version
        '';

        rust-stable = with pkgs; {
          latest = rust-bin.stable.latest.default;
          "1_86" = rust-bin.stable "1.86.0".default; # rust-bin.stable."version".minimal
        };
      in
      {
        devShells = {
          "rust-current" = pkgs.mkShell {
            buildInputs = rustDevShellBuildInputs ++ commonDevShellBuildInputs ++ [ rust-stable.latest ];

            RUST_SRC_PATH = pkgs.rustPlatform.rustLibSrc;
            RUSTC_WRAPPER = "${pkgs.sccache}/bin/sccache";

            shellHook = ''
              ${pkgs.lib.getExe pkgs.cowsay} "Welcome to the #rust-current devShell!"
              ${rustDevShellHookCommon}
            '';
          };

          "rust-1_86" = pkgs.mkShell {
            buildInputs = rustDevShellBuildInputs ++ commonDevShellBuildInputs ++ [ rust-stable.latest ];

            RUST_SRC_PATH = pkgs.rustPlatform.rustLibSrc;
            RUSTC_WRAPPER = "${pkgs.sccache}/bin/sccache";

            shellHook = ''
              ${pkgs.lib.getExe pkgs.cowsay} "Welcome to the #rust-1_86 devShell!"
              ${rustDevShellHookCommon}
            '';
          };
        };
      }
    );
}
