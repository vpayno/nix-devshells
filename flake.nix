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
        context = {
          systems = import systems; # get the list of systems

          # https://releases.rs/
          # can't decide if I want all the versions from packages.x86_64-linux.rust_1_x or just a select few
          # just adding the last 5 versions for now
          rustVersions = [
            "1.86.0"
            "1.88.0"
            "1.89.0"
            "1.90.0"
            "1.91.1"
            "1.92.0"
          ];

          rustLabels = builtins.map getShellLabel context.rustVersions;
        };

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
            taplo
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
            cargo-deb
            cargo-deny
            cargo-edit
            cargo-flamegraph
            cargo-fuzz
            cargo-hack
            cargo-info
            cargo-license
            cargo-lock
            cargo-msrv
            cargo-outdated
            cargo-readme
            cargo-seek
            cargo-sort
            cargo-spellcheck
            cargo-tarpaulin
            cargo-toml-lint
            cargo-ui
            cargo-update
            cargo-vet
            cargo-watch
            grcov
            rust-analyzer
            rust-code-analysis
          ]
          ++ rustLinuxOnlyPkgs;

        rustDevShellHookCommon = ''
          export CARGO_HOME="$PWD/.cargo"
          [[ -d $CARGO_HOME/bin ]] && mkdir -pv "$CARGO_HOME/bin"
          export PATH="$CARGO_HOME/bin:$PATH"

          rustc --version
        '';

        getShellLabel =
          packageVersion:
          let
            versionParts = pkgs.lib.strings.splitString "." packageVersion;
          in
          pkgs.lib.strings.concatStringsSep "_" (pkgs.lib.lists.take 2 versionParts);

        defineRustPackage =
          packageVersion: with pkgs; [
            rust-bin.stable."${packageVersion}".default # or .minimal
          ];

        defineRustDevShell =
          rustVersion:
          let
            shellLabel = getShellLabel rustVersion;
            pname = "rust";
            version = "${rustVersion}";
            name = "${pname}-${shellLabel}";
          in
          pkgs.mkShell rec {
            inherit pname version name;

            # to be overridden
            extraPackages = [ ];

            buildInputs =
              rustDevShellBuildInputs
              ++ commonDevShellBuildInputs
              ++ extraPackages
              ++ [ pkgs.rust-bin.stable."${rustVersion}".default ];

            RUST_SRC_PATH = pkgs.rustPlatform.rustLibSrc;
            RUSTC_WRAPPER = "${pkgs.sccache}/bin/sccache";

            shellHook = ''
              ${pkgs.lib.getExe pkgs.cowsay} "Welcome to the #${name} (${version}) devShell!"
              ${rustDevShellHookCommon}
            '';
          };

        getRustDevShell = rustVersion: {
          "rust-${getShellLabel rustVersion}" = defineRustDevShell rustVersion;
        };

        extend = lhs: rhs: lhs // rhs;

        tmpShells = { };

        getRustDevShells = pkgs.lib.foldl extend tmpShells (
          builtins.map (name: getRustDevShell name) context.rustVersions
        );
      in
      {
        devShells = getRustDevShells;
      }
    );
}
