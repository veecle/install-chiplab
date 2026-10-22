{root, ...}: {
  perSystem = {pkgs, ...}: {
    make-shells.default = {
      packages = [pkgs.actionlint pkgs.shellcheck];
    };

    checks.actionlint = pkgs.stdenvNoCC.mkDerivation {
      name = "actionlint";
      src = pkgs.lib.fileset.toSource {
        inherit root;
        fileset = pkgs.lib.fileset.unions [
          (root + /.github/workflows)
          (root + /action.yaml)
        ];
      };
      # actionlint runs shellcheck on `run:` scripts when it is on PATH.
      nativeBuildInputs = [pkgs.actionlint pkgs.shellcheck];
      # actionlint only treats a directory with `.git` as a project. Without one it skips
      # checking `uses: ./` against `action.yaml`.
      buildPhase = ''
        touch .git
        actionlint -verbose
      '';
      installPhase = "touch $out";
    };

    # actionlint does not lint `action.yaml`, so shellcheck its composite `run:` scripts directly.
    checks.action-shellcheck = pkgs.stdenvNoCC.mkDerivation {
      name = "action-shellcheck";
      src = pkgs.lib.fileset.toSource {
        inherit root;
        fileset = root + /action.yaml;
      };
      nativeBuildInputs = [pkgs.shellcheck pkgs.yq-go];
      buildPhase = ''
        steps='[.runs.steps[] | select(has("run"))]'
        count="$(yq "$steps | length" action.yaml)"
        test "$count" -gt 0
        for i in $(seq 0 $((count - 1))); do
          yq "$steps[$i].run" action.yaml > "step-$i.sh"
          shellcheck --shell=bash "step-$i.sh"
        done
      '';
      installPhase = "touch $out";
    };
  };
}
