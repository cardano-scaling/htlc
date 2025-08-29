{ self, inputs, ... }: {

  imports = [
    inputs.hydra-coding-standards.flakeModule
  ];

  perSystem = { pkgs, system, lib, ... }: {
    coding.standards.hydra.enable = true;
    packages.default = pkgs.stdenv.mkDerivation {
      name = "my-file-package-1.0";
      src = lib.cleanSource "${self}/htlc/plutus.json";
      dontUnpack = true;
      installPhase = ''
        cp $src $out
      '';
    };
    devShells.default = pkgs.mkShell {
      name = "htlc-devshell";
      buildInputs = [
        inputs.aiken.packages.${system}.default
      ];
    };

  };
}
