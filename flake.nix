{
  description = "A very basic flake";

  inputs = {
    coq.url = "github:ms-jpq/coq_nvim";
    coq.flake = false;

    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    flake-utils.url = "github:numtide/flake-utils";

    mach-nix.url = "github:DavHau/mach-nix";
  };

  outputs = { self, nixpkgs, coq, flake-utils, mach-nix }:
    flake-utils.lib.eachSystem ["x86_64-linux"] (system:
      let
        pkgs = import nixpkgs { inherit system; };
        machNix = import mach-nix { inherit pkgs; };
      in
      rec {
        packages = flake-utils.lib.flattenTree ({
          coq = machNix.mkPython {
            requirements = ''
              pynvim==0.4.3
              PyYAML==5.4.1
            '';
            packagesExtra = [
              "https://github.com/ms-jpq/std2/archive/4a7eec16d03c6a6510a604cf6caea69aaffa8c51.tar.gz"
              "https://github.com/ms-jpq/pynvim_pp/archive/db2a630b4d98ee626b16bf9450c9a48f954aa11f.tar.gz"
            ];
          };

          coqNeovimPlugin = pkgs.vimUtils.buildVimPluginFrom2Nix {
            name = "coq-nvim";
            version = "latest";
            src = coq;
            passthru.python3Dependencies = ps: [ packages.coq ];
          };
        });
        defaultPackage = packages.coq;
      }
    );
}
