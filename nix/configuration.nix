{ self, inputs, ... }: {

  imports = [
    inputs.files.flakeModules.default
    inputs.hydra-coding-standards.flakeModule
  ];

  perSystem = { pkgs, system, lib, ... }: rec {
    coding.standards.hydra.enable = true;
    packages.default =
      let
        stdlib = pkgs.fetchzip {
          url = "https://github.com/aiken-lang/stdlib/archive/v2.2.0.zip";
          hash = "sha256-BDaM+JdswlPasHsI03rLl4OR7u5HsbAd3/VFaoiDTh4=";
        };
        vodka = pkgs.fetchzip {
          url = "https://github.com/sidan-lab/vodka/archive/0.1.16.zip";
          hash = "sha256-SYeuBW2F5vsR7aJyJAtGTvnsyID0gNKYkMyrlJM2pwQ=";
        };
      in
      pkgs.stdenv.mkDerivation {
        name = "hydra-htlc";
        src = lib.cleanSource "${self}/htlc";
        buildInputs = [
          inputs.aiken.packages.${system}.default
        ];
        buildPhase = ''
          export HOME=$TMPDIR
          mkdir -p build/packages
          touch build/aiken-compile.lock
          cp -r ${stdlib} build/packages/aiken-lang-stdlib
          cp -r ${vodka} build/packages/sidan-lab-vodka
          aiken build -t compact
        '';
        installPhase = ''
          cp -r plutus.json $out
        '';
      };
    devShells.default = pkgs.mkShell {
      name = "htlc-devshell";
      buildInputs = [
        inputs.aiken.packages.${system}.default
      ];
    };
    files.files = [{
      path_ = "htlc/plutus.json";
      drv = packages.default;
    }];

  };
}
