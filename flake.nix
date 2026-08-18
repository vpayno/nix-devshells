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

    nixpkgs-2611.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-2605.url = "github:nixos/nixpkgs?ref=nixos-26.05";
    nixpkgs-2511.url = "github:nixos/nixpkgs?ref=nixos-25.11";
    nixpkgs-2505.url = "github:nixos/nixpkgs?ref=nixos-25.05";
    nixpkgs-2411.url = "github:nixos/nixpkgs?ref=nixos-24.11";
    nixpkgs-2405.url = "github:nixos/nixpkgs?ref=nixos-24.05";
    nixpkgs-2311.url = "github:nixos/nixpkgs?ref=nixos-23.11";
    nixpkgs-2305.url = "github:nixos/nixpkgs?ref=nixos-23.05";
    nixpkgs-2211.url = "github:nixos/nixpkgs?ref=nixos-22.11";
    nixpkgs-2205.url = "github:nixos/nixpkgs?ref=nixos-22.05";
    nixpkgs-2111.url = "github:nixos/nixpkgs?ref=nixos-21.11";
    nixpkgs-2105.url = "github:nixos/nixpkgs?ref=nixos-21.05";
    nixpkgs-2009.url = "github:nixos/nixpkgs?ref=nixos-20.09";
    nixpkgs-2003.url = "github:nixos/nixpkgs?ref=nixos-20.03";
  };

  outputs =
    {
      self,
      nixpkgs,
      systems,
      flake-utils,
      treefmt-conf,
      rust-overlay,
      ...
    }@inputs:
    flake-utils.lib.eachDefaultSystem (system: {
      formatter = treefmt-conf.formatter.${system};
    })
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        pname = "nix-devshells";
        version = "20260817.0.0";
        name = "${pname}-${version}";

        flake_repo_url = "github:vpayno/nix-devshells";

        context = {
          systems = import systems; # get the list of systems

          # https://releases.rs/
          # https://endoflife.date/rust
          # can't decide if I want all the versions from packages.x86_64-linux.rust_1_x or just a select few
          # just adding the last 10 versions for now
          rustVersions = [
            "1.88.0"
            "1.89.0"
            "1.90.0"
            "1.91.1"
            "1.92.0"
            "1.93.1"
            "1.94.1"
            "1.95.0"
            "1.96.1"
            "1.97.1"
          ];

          rustLabels = builtins.map getVersionLabel context.rustVersions;

          # https://github.com/openssl/openssl/releases
          # https://endoflife.date/openssl
          opensslVersions = [
            "4.0.1"
            "3.6.3"
            "3.5.7" # LTS, EOL 2030-04
            "3.4.6"
            "3.3.7"
            "3.2.5"
            "3.1.8"
            "3.0.21" # LTS, EOL 2026-09
            "1.1.1w" # LTS, EOL 2023-09
            "1.0.2u" # LTS, EOL 2019-12
          ];

          opensslLabels = builtins.map getVersionLabel context.opensslVersions;

          openjdkVersions = [
            "8"
            "11"
            "17"
            "21"
            "25"
          ];

          openjdkLabels = builtins.map getVersionLabel context.openjdkVersions;
        };

        overlays = [ (import rust-overlay) ];

        pkgs = import nixpkgs {
          inherit system overlays;
        };

        pkgs-2611 = pkgs;

        pkgs-2605 = import inputs.nixpkgs-2605 {
          inherit system;
          config = {
            permittedInsecurePackages = [
              "openssl-1.1.1w" # EOL 2023-09
            ];
          };
        };

        pkgs-2511 = import inputs.nixpkgs-2511 {
          inherit system;
        };

        pkgs-2505 = import inputs.nixpkgs-2505 {
          inherit system;
        };

        pkgs-2411 = import inputs.nixpkgs-2411 {
          inherit system;
        };

        pkgs-2405 = import inputs.nixpkgs-2405 {
          inherit system;
        };

        pkgs-2311 = import inputs.nixpkgs-2311 {
          inherit system;
        };

        pkgs-2305 = import inputs.nixpkgs-2305 {
          inherit system;
        };

        pkgs-2211 = import inputs.nixpkgs-2211 {
          inherit system;
        };

        pkgs-2205 = import inputs.nixpkgs-2205 {
          inherit system;
        };

        pkgs-2111 = import inputs.nixpkgs-2111 {
          inherit system;
          config = {
            permittedInsecurePackages = [
              "openssl-1.0.2u" # EOL 2019-12
            ];
          };
        };

        pkgs-2105 = import inputs.nixpkgs-2105 {
          inherit system;
        };

        pkgs-2009 = import inputs.nixpkgs-2009 {
          inherit system;
        };

        pkgs-2003 = import inputs.nixpkgs-2003 {
          inherit system;
        };

        flakeMetaData = {
          homepage = "https://github.com/vpayno/nix-devshells";
          description = "My generic single languge devShells Nix Flake";
          license = with pkgs.lib.licenses; [ mit ];
          # maintainers = with pkgs.lib.maintainers; [vpayno];
          maintainers = [
            {
              email = "vpayno@users.noreply.github.com";
              github = "vpayno";
              githubId = 3181575;
              name = "Victor Payno";
            }
          ];
          mainProgram = "flake-show-usage";
        };

        usageMessagePre = ''
          Available ${name} flake commands:

            nix run .#flakeShowUsage | .#default     # this message
        '';

        toolScripts = pkgs.lib.mapAttrsToList (name: _: scripts."${name}") scripts;

        generatePackagesFromScripts = pkgs.lib.mapAttrs (
          name: _:
          scripts."${name}"
          // {
            inherit (scriptMetadata."${name}") pname;
            inherit version;
            name = "${self.packages.${system}."${name}".pname}-${self.packages.${system}."${name}".version}";
          }
        ) scripts;

        generateAppsFromScripts = pkgs.lib.mapAttrs (name: _: {
          type = "app";
          inherit (self.packages.${system}.${name}) meta;
          program = "${pkgs.lib.getExe self.packages.${system}.${name}}";
        }) scripts;

        configs = {
        };

        scriptMetadata = {
          flakeShowUsage = rec {
            pname = "flake-show-usage";
            inherit version;
            name = "${pname}-${version}";
            description = "Show Nix flake usage text";
          };

          showLatestRustVersions = rec {
            pname = "show-latest-rust-versions";
            inherit version;
            name = "${pname}-${version}";
            description = "Shows the list of the latest Rust versions from the GitHub repo";
          };
        };

        makeShellScripts =
          scripts: pkgs.lib.mapAttrsToList (name: script: pkgs.writeShellScriptBin name script) scripts;

        commonShellScripts = makeShellScripts {
          scriptname = ''
            : script body
          '';
        };

        scripts = {
          flakeShowUsage = pkgs.writeShellApplication {
            name = scriptMetadata.flakeShowUsage.pname;
            runtimeInputs = with pkgs; [
              coreutils
              jq
              gnugrep
              nix
            ];
            text = ''
              declare json_text
              declare -a commands
              declare -a comments
              declare -i i

              printf "\n"
              printf "%s" "${usageMessagePre}"
              printf "\n"

              json_text="$(nix flake show --json 2>/dev/null | jq --sort-keys .)"

              mapfile -t commands < <(printf "%s" "$json_text" | jq -r --arg system "${system}" '.apps[$system] | to_entries[] | select(.key | test("^(default|flakeShowUsage)$") | not) | "\("nix run .#")\(.key)"')
              mapfile -t comments < <(printf "%s" "$json_text" | jq -r --arg system "${system}" '.apps[$system] | to_entries[] | select(.key | test("^(default|flakeShowUsage)$") | not) | "\("# ")\(.value.description)"')

              for ((i = 0; i < ''${#commands[@]}; i++)); do
                printf "  %-40s %s\n" "''${commands[$i]}" "''${comments[$i]}"
              done

              printf "\n"

              mapfile -t commands < <(printf "%s" "$json_text" | jq -r --arg system "${system}" '.devShells[$system] | to_entries[] | "\("nix develop .#")\(.key)"')
              mapfile -t comments < <(printf "%s" "$json_text" | jq -r --arg system "${system}" '.devShells[$system] | to_entries[] | "\("# ")\(.value.name)"')

              for ((i = 0; i < ''${#commands[@]}; i++)); do
                printf "  %-40s %s\n" "''${commands[$i]}" "''${comments[$i]}"
              done

              printf "\n"
            '';
            meta = scriptMetadata.flakeShowUsage;
          };

          showLatestRustVersions = pkgs.writeShellApplication {
            name = scriptMetadata.showLatestRustVersions.pname;
            runtimeInputs = with pkgs; [
              coreutils
              git
              gnused
              gnugrep
            ];
            text = ''
              declare -i count="''${1:-10}"
              git ls-remote --ref --tags git@github.com:rust-lang/rust.git | sed -r -e 's:.*tags/::g' |
                grep -E '^[0-9]+[.][0-9]+[.][0-9]+$' | sort -Vr | head -n "''${count}"
            '';
            meta = scriptMetadata.showLatestRustVersions;
          };
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
          if stdenv.hostPlatform.isLinux then
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
            rustycli
          ]
          ++ rustLinuxOnlyPkgs;

        rustDevShellHookCommon = ''
          export RUST_SRC_PATH="${pkgs.rustPlatform.rustLibSrc}";
          export RUSTC_WRAPPER="${pkgs.sccache}/bin/sccache";
          export CARGO_HOME="$PWD/.cargo"
          [[ -d $CARGO_HOME/bin ]] && mkdir -pv "$CARGO_HOME/bin"
          export PATH="$CARGO_HOME/bin:$PATH"

          rustc --version
          printf "\n"
        '';

        opensslDevShellHookCommon = ''
          openssl version
          printf "\n"
        '';

        openjdkDevShellHookCommon = ''
          java -version
          printf "\n"
        '';

        getVersionLabel =
          packageVersion:
          let
            versionParts = pkgs.lib.strings.splitString "." packageVersion;
          in
          pkgs.lib.strings.concatStringsSep "_" (pkgs.lib.lists.take 2 versionParts);

        defineRustPackage =
          packageVersion: pkgs.rust-bin.stable."${packageVersion}".default # or .minimal
        ;

        defineRustDevShell =
          rustVersion:
          let
            shellLabel = getVersionLabel rustVersion;
            extraPackages = [ ]; # to be overridden
            rustBuildInputs =
              rustDevShellBuildInputs
              ++ commonDevShellBuildInputs
              ++ [ pkgs.rust-bin.stable."${rustVersion}".default ];
            myShellHook = rustDevShellHookCommon;
            myPackages = [
              toolBundle
            ]
            ++ extraPackages;
          in
          mkShell "rust" rustVersion shellLabel myPackages rustBuildInputs myShellHook;

        defineOpensslDevShell =
          opensslVersion:
          let
            versionLabel = getVersionLabel opensslVersion;
            extraPackages = [ ]; # to be overridden
            opensslBuildInputs = [ ];
            myShellHook = opensslDevShellHookCommon;
            myPackages = [
              toolBundle
              self.packages.${system}."openssl-${versionLabel}"
            ]
            ++ extraPackages;
          in
          mkShell "openssl" opensslVersion versionLabel myPackages opensslBuildInputs myShellHook;

        defineOpenjdkDevShell =
          openjdkVersion:
          let
            versionLabel = getVersionLabel openjdkVersion;
            extraPackages = [ ]; # to be overridden
            openjdkBuildInputs = [ ];
            myShellHook = openjdkDevShellHookCommon;
            myPackages = [
              toolBundle
              self.packages.${system}."openjdk${versionLabel}"
            ]
            ++ extraPackages;
          in
          mkShell "openjdk" openjdkVersion versionLabel myPackages openjdkBuildInputs myShellHook;

        mkShell =
          myName: myVersion: myLabel: myPackages: myBuildInputs: myShellHook:
          pkgs.mkShell rec {
            shellLabel = myLabel;
            pname = myName;
            version = myVersion;
            name = "${pname}-${myLabel}";
            packages =
              with pkgs;
              [
                bashInteractive
                coreutils
                findutils
                gawk
                gnugrep
                patchutils
                util-linux
              ]
              ++ myPackages;
            nativeBuildInputs = myBuildInputs;
            SHELLMOTD = ''
              Welcome to nix develop ${flake_repo_url}#${myName}-${myLabel} devShell...
            '';
            shellHook = ''
              ${pkgs.lib.getExe pkgs.cowsay} "${SHELLMOTD}"
              printf "\n"
              ${myShellHook}
            '';
          };

        getRustDevShell = rustVersion: {
          "rust-${getVersionLabel rustVersion}" = defineRustDevShell rustVersion;
        };

        getRustPackage = rustVersion: {
          "rust-${getVersionLabel rustVersion}" = defineRustPackage rustVersion;
        };

        getOpensslDevShell = opensslVersion: {
          "openssl-${getVersionLabel opensslVersion}" = defineOpensslDevShell opensslVersion;
        };

        getOpenjdkDevShell = openjdkVersion: {
          "openjdk-${getVersionLabel openjdkVersion}" = defineOpenjdkDevShell openjdkVersion;
        };

        extend = lhs: rhs: lhs // rhs;

        tmpShells = { };
        tmpPackages = { };

        getRustDevShells = pkgs.lib.foldl extend tmpShells (
          builtins.map (name: getRustDevShell name) context.rustVersions
        );

        getRustPackages = pkgs.lib.foldl extend tmpPackages (
          builtins.map (name: getRustPackage name) context.rustVersions
        );

        getOpensslDevShells = pkgs.lib.foldl extend tmpShells (
          builtins.map (name: getOpensslDevShell name) context.opensslVersions
        );

        getOpenjdkDevShells = pkgs.lib.foldl extend tmpShells (
          builtins.map (name: getOpenjdkDevShell name) context.openjdkVersions
        );

        opensslPackages = {
          openssl-lts = self.packages.${system}."openssl-3_5";
          openssl-4_0 = pkgs-2611.openssl_4_0; # 4.0.1
          openssl-3_6 = pkgs-2611.openssl_3_6; # 3.6.3
          openssl-3_5 = pkgs-2611.openssl_3_5; # 3.5.7
          openssl-3_4 = pkgs-2505.openssl_3_4; # 3.4.3
          openssl-3_3 = pkgs-2411.openssl_3_3; # 3.3.3
          openssl-3_2 = pkgs-2405.openssl_3_2; # 3.2.2
        }
        // (
          if pkgs.stdenv.hostPlatform.isLinux then
            {
              openssl-3_1 = pkgs-2311.openssl_3_1; # 3.1.6
            }
          else
            { }
        )
        // {
          openssl-3_0 = pkgs-2605.openssl_3; # 3.0.21
          openssl-1_1 = pkgs-2605.openssl_1_1; # 1.1.1w
          openssl-1_0 = pkgs-2111.openssl_1_0_2; # 1.0.2u
        };

        opensslBundle = pkgs.buildEnv {
          name = "openssl-bundle";
          buildInputs = with pkgs; [
          ];
          paths = [
          ];
          pathsToLink = [
          ];
          postBuild = ''
            mkdir -pv "$out/bin"
            cd $out/bin || exit
            for p in ${self.packages.${system}.openssl-4_0}/bin/*; do ln -sv "$p" $(basename "$p")-4_0; done
            for p in ${self.packages.${system}.openssl-3_6}/bin/*; do ln -sv "$p" $(basename "$p")-3.6; done
            for p in ${self.packages.${system}.openssl-3_5}/bin/*; do ln -sv "$p" $(basename "$p")-3.5; done
            for p in ${self.packages.${system}.openssl-3_4}/bin/*; do ln -sv "$p" $(basename "$p")-3.4; done
            for p in ${self.packages.${system}.openssl-3_3}/bin/*; do ln -sv "$p" $(basename "$p")-3.3; done
            for p in ${self.packages.${system}.openssl-3_2}/bin/*; do ln -sv "$p" $(basename "$p")-3.2; done
          ''
          + (
            if pkgs.stdenv.hostPlatform.isLinux then
              ''
                for p in ${self.packages.${system}.openssl-3_1}/bin/*; do ln -sv "$p" $(basename "$p")-3.1; done
              ''
            else
              ""
          )
          + ''
            for p in ${self.packages.${system}.openssl-3_0}/bin/*; do ln -sv "$p" $(basename "$p")-3.0; done
            for p in ${self.packages.${system}.openssl-1_1}/bin/*; do ln -sv "$p" $(basename "$p")-1.1; done
            for p in ${self.packages.${system}.openssl-1_0}/bin/*; do ln -sv "$p" $(basename "$p")-1.0; done
            ls -lh "$out/bin"
          '';
        };

        goPackages = {
          go-1_26 = pkgs.go;
        };

        openjdkPackages = {
          openjdk8 = pkgs.openjdk8_headless;
          openjdk11 = pkgs.openjdk11_headless;
          openjdk17 = pkgs.openjdk17_headless;
          openjdk21 = pkgs.openjdk21_headless;
          openjdk25 = pkgs.openjdk25_headless;
        };

        toolBundle = pkgs.buildEnv {
          name = "${name}-bundle";
          paths = toolScripts;
          buildInputs = with pkgs; [
            makeWrapper
          ];
          pathsToLink = [
            "/bin"
            "/etc"
          ];
          postBuild = ''
            extra_bin_paths="${pkgs.lib.makeBinPath toolScripts}"
            printf "Adding extra bin paths to wrapper scripts: %s\n" "$extra_bin_paths"
            printf "\n"

            for p in "$out"/bin/*; do
              if [[ ! -x $p ]]; then
                continue
              fi
              if [[ $p =~ /flake-show-usage$ ]]; then
                rm -fv $p
                continue
              fi
              # echo wrapProgram "$p" --set PATH "$extra_bin_paths"
              # wrapProgram "$p" --set PATH "$extra_bin_paths"
            done
          '';
        };
      in
      {
        devShells = {
          default = pkgs.mkShell rec {
            packages =
              with pkgs;
              [
                bashInteractive
                cargo
                clippy
                go
                openjdk25_headless
                openssl
                rustc
                rustfmt
              ]
              ++ [
                toolBundle
                opensslBundle
              ];

            shellMotd = ''
              Starting ${name}

              nix develop ${flake_repo_url}#default shell..
            '';

            shellHook = ''
              ${pkgs.lib.getExe pkgs.cowsay} "${shellMotd}"
              printf "\n"

              ${pkgs.lib.getExe pkgs.tree} "${toolBundle}"
              printf "\n"

              go version
              printf "\n"
              java -version
              printf "\n"
              openssl version
              printf "\n"
              rustc --version
              printf "\n"

              ls "${opensslBundle}"/bin | sort --field-separator=- --key=2,2 | column --fillrows --output-width=79
              printf "\n"
            '';
          };
          openssl-lts = self.devShells.${system}."openssl-3_5";
        }
        // getRustDevShells
        // getOpensslDevShells
        // getOpenjdkDevShells;

        packages = {
          default = toolBundle;
          openssl-bundle = opensslBundle;
          inherit (pkgs) go;
        }
        // generatePackagesFromScripts
        // getRustPackages
        // opensslPackages
        // openjdkPackages;

        apps = {
          default = self.apps.${system}.flakeShowUsage;
        }
        // generateAppsFromScripts;
      }
    );
}
