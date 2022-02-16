
{
  description = "Clasp Common Lisp";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/21.11";

  outputs = { self, nixpkgs }: {

    packages.x86_64-linux.clasp = import ./clasp.nix { pkgs = nixpkgs.legacyPackages.x86_64-linux; };

    defaultPackage.x86_64-linux = self.packages.x86_64-linux.clasp;

  };
}
