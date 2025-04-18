{
  description = "Flake to build + develop dirfns R package";

  nixConfig = {
    bash-prompt = "\[dirfns$(__git_ps1 \" (%s)\")\]$ ";
  };

  inputs = {
    nixpkgs.url     = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs  = import nixpkgs { inherit system; config.allowUnfree = true; };
        rpkgs = pkgs.rPackages;

        myPkg = rpkgs.buildRPackage rec {
          name    = "dirfns";
          version = "0.1";
          src     = ./.;

          # R‐side dependencies:
          propagatedBuildInputs = [
              rpkgs.ggplot2
              rpkgs.rtracklayer
          ];

          nativeBuildInputs = [
            pkgs.R
            pkgs.pkg-config
          ];

          # C‑library dependencies
          buildInputs = [
          ];

		  preBuild = ''
		  make build
		  mv build $out
		  '';

          # re‑enable Nix’s R-wrapper so it injects R_LD_LIBRARY_PATH
          dontUseSetLibPath = false;

          meta = with pkgs.lib; {
            description = "…";
            license     = licenses.mit;
            maintainers = [ maintainers.kewiechecki ];
          };
        };
      in rec {
        # 1) allow `nix build` with no extra attr:
        defaultPackage = myPkg;

        # 2) drop you into a shell for interactive R work:
        devShells = {
          default = pkgs.mkShell {
            name = "dirfns-shell";
            buildInputs = [
              pkgs.git
              pkgs.R
              rpkgs.ggplot2
              rpkgs.rtracklayer
            ];
            shellHook = ''
source ${pkgs.git}/share/bash-completion/completions/git-prompt.sh
            '';
          };
        };
      });
}

