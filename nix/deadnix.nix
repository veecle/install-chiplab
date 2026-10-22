{root, ...}: {
  perSystem = {pkgs, ...}: {
    checks.deadnix = pkgs.stdenvNoCC.mkDerivation {
      name = "deadnix";
      src = pkgs.lib.fileset.toSource {
        inherit root;
        fileset = pkgs.lib.fileset.fileFilter (file: file.hasExt "nix") root;
      };
      nativeBuildInputs = [pkgs.deadnix];
      buildPhase = "deadnix --fail";
      installPhase = "touch $out";
    };
  };
}
