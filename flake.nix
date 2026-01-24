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
      self,
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
        pname = "nix-misc-tools";
        version = "20260123.0.0";
        name = "${pname}-${version}";

        flake_repo_url = "github:vpayno/nix-misc-tools";

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
              git ls-remote --ref --tags git@github.com:rust-lang/rust.git | sed -r -e 's:.*tags/::g' | grep -E '^[0-9]+[.][0-9]+[.][0-9]+$' | sort -Vr | head
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

            packages =
              with pkgs;
              [
              ]
              ++ [
                toolBundle
              ];

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
        devShells = getRustDevShells;

        packages = {
          default = toolBundle;
        }
        // generatePackagesFromScripts;

        apps = {
          default = self.apps.${system}.flakeShowUsage;
        }
        // generateAppsFromScripts;
      }
    );
}
