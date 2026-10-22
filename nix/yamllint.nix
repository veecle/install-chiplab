{root, ...}: {
  perSystem = {pkgs, ...}: {
    make-shells.default = {
      packages = [pkgs.yamllint];
    };

    checks.yamllint = pkgs.stdenvNoCC.mkDerivation {
      name = "yamllint";
      src = pkgs.lib.fileset.toSource {
        inherit root;
        fileset = pkgs.lib.fileset.unions [
          (pkgs.lib.fileset.fileFilter (file: file.hasExt "yaml" || file.hasExt "yml") root)
          (root + /.yamllint)
        ];
      };
      nativeBuildInputs = [pkgs.yamllint];
      buildPhase = ''
        yamllint --list-files .
        yamllint --config-file .yamllint .
      '';
      installPhase = "touch $out";
    };
  };
}
