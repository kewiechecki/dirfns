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

          # Make sure R is on PATH at build time, and pkg-config can see libxml2 & gsl:
          nativeBuildInputs = [
            pkgs.R
            pkgs.pkg-config
          ];

          # C‑library dependencies for XML.so and DirichletMultinomial.so
          buildInputs = [
			pkgs.bzip2
			pkgs.curl
            pkgs.gsl
			pkgs.icu75
			pkgs.libpng
            pkgs.libxml2
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
      }
    );
}

