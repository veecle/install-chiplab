{root, ...}: {
  perSystem = {pkgs, ...}: let
    # mdslw (MarkDown Sentence Line Wrapper) enforces the "one sentence per line" Markdown style.
    mdslw = let
      version = "0.17.2";
      # Network-free replacement for upstream build.rs:
      # it only stages the bundled "ac" language spec and points the crate at it,
      # skipping the per-language CLDR downloads.
      buildRs = pkgs.writeText "build.rs" ''
        use std::env;
        use std::fs;
        use std::path::{Path, PathBuf};
        use std::str::FromStr;

        fn main() {
            println!("cargo::rerun-if-changed=src/lang/ac");
            println!("cargo::rerun-if-changed=src/cfg.rs");
            let base_path = Path::new(
                &env::var_os("OUT_DIR").expect("OUT_DIR env var must be set"),
            )
            .join("lang");
            if let Ok(true) = fs::exists(&base_path) {
                fs::remove_dir_all(&base_path).expect("failed to remove outdated lang spec dir");
            }
            fs::create_dir(&base_path).expect("failed to create lang spec dir");
            let ac_path =
                PathBuf::from_str("src/lang/ac").expect("failed to build path to lang spec ac");
            fs::copy(ac_path, base_path.join("ac")).expect("failed to copy ac lang specs");
            println!(
                "cargo::rustc-env=MDSLW_LANG_DIR={}",
                base_path.to_string_lossy()
            );
        }
      '';
    in
      pkgs.rustPlatform.buildRustPackage {
        pname = "mdslw";
        inherit version;
        src = pkgs.fetchFromGitHub {
          owner = "razziel89";
          repo = "mdslw";
          tag = version;
          hash = "sha256-4iSQS13tMglOV8nWBw7Zxi8+DcKHKGl99cuHKvOIE7s=";
        };
        cargoHash = "sha256-emaBv9b9WjFKbyN5V0A5N8NHea8YMBvj256gv9P116E=";
        postPatch = ''
          cp ${buildRs} build.rs
          substituteInPlace Cargo.toml --replace-fail '[build-dependencies]
          reqwest = {version = "0.13", features = ["default", "json", "blocking"]}
          serde_json = { version = "1" }' ""
          # `read_stdin` joins lines with `\n`, dropping the file's trailing newline and never
          # restoring it (unlike file mode). Read stdin verbatim so `jj fix` keeps the newline.
          substituteInPlace src/fs.rs --replace-fail 'std::io::stdin()
                  .lines()
                  // Interrupt as soon as one line could not be read.
                  .map_while(Result::ok)
                  .collect::<Vec<_>>()
                  .join("\n")' 'std::io::read_to_string(std::io::stdin()).expect("failed to read stdin")'
        '';
        # Tests require the build-time downloaded language files we skip.
        doCheck = false;
        meta.mainProgram = "mdslw";
      };
  in {
    make-shells.default = {
      packages = [mdslw];
    };

    jj-fix.tools.mdslw = {
      # `./` prefix: for directory-less paths such as `README.md`, `mdslw` fails to locate `.mdslw.toml`
      # and silently falls back to its default config.
      command = ["mdslw" "--stdin-filepath=./$path"];
      patterns = ["glob:**/*.md"];
    };

    checks.mdslw = pkgs.stdenvNoCC.mkDerivation {
      name = "mdslw";
      src = pkgs.lib.fileset.toSource {
        inherit root;
        fileset = pkgs.lib.fileset.unions [
          (pkgs.lib.fileset.fileFilter (file: file.hasExt "md") root)
          (root + /.mdslw.toml)
        ];
      };
      nativeBuildInputs = [mdslw];
      buildPhase = "mdslw --mode=check --report=changed .";
      installPhase = "touch $out";
    };
  };
}
