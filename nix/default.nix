{ pkgsPath ? <nixpkgs> }:

let
  pkgs = import pkgsPath {};

  gitignoreSrc = pkgs.fetchFromGitHub {
    owner = "hercules-ci";
    repo = "gitignore";
    rev = "7415c4f";
    sha256 = "1zd1ylgkndbb5szji32ivfhwh04mr1sbgrnvbrqpmfb67g2g3r9i";
  };
  inherit (import gitignoreSrc { inherit (pkgs) lib; }) gitignoreSource;

  overlays = builtins.fetchTarball {
    url = https://github.com/anmonteiro/nix-overlays/archive/9b82f4b.tar.gz;
    sha256 = "1fsd3i1rz62vm2sgs3hw0srl7aiphckjc24qfc8l6p1czli2w0lw";
  };

  ocamlPackages = pkgs.ocaml-ng.ocamlPackages_4_09.overrideScope'
    (pkgs.callPackage "${overlays}/ocaml" {});
in
  {
    native = pkgs.callPackage ./generic.nix {
      inherit ocamlPackages gitignoreSource;
    };

    musl64 =
      let pkgs = import "${overlays}/static.nix" {
        inherit pkgsPath;
        ocamlVersion = "4_09";
      };
      in
      pkgs.callPackage ./generic.nix {
        static = true;
        inherit gitignoreSource;
        ocamlPackages = pkgs.ocaml-ng.ocamlPackages_4_09;
      };
  }
