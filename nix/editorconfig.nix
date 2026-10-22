{root, ...}: {
  perSystem = {pkgs, ...}: {
    make-shells.default = {
      packages = [pkgs.editorconfig-checker];
    };

    checks.editorconfig = pkgs.stdenvNoCC.mkDerivation {
      name = "editorconfig";
      src = root;
      nativeBuildInputs = [pkgs.editorconfig-checker];
      buildPhase = "editorconfig-checker -verbose .";
      installPhase = "touch $out";
    };
  };
}
