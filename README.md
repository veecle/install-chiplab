# chiplab-action

Install [chiplab-cli](https://github.com/veecle/chiplab-cli) in GitHub Actions, so your CI can run firmware on [Chiplab](https://chiplab.veecle.ai)'s virtual boards.

## Usage

```yaml
- uses: veecle/chiplab-action@v1
- run: chiplab-cli --help
```

The action downloads the release archive for the runner, verifies it against the release's `sha256sums.txt` and adds `chiplab-cli` to `PATH`.

## Example

Run a test suite on Chiplab against a firmware ELF built earlier in the job:

```yaml
jobs:
  chiplab:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7

      # Build your firmware here.

      - uses: veecle/chiplab-action@v1

      - run: |
          chiplab-cli run-test-suite \
            --project project_... \
            --firmware build/firmware.elf \
            --test-suite chiplab/hello-world.test.ts \
            --board chiplab/my-board.board.json
        env:
          CHIPLAB_TOKEN: ${{ secrets.CHIPLAB_API_KEY }}
```

For a working setup, see [chiplab-smoke.yml](https://github.com/veecle/chiplab/blob/main/.github/workflows/chiplab-smoke.yml).

## Inputs

| Name      | Default  | Description                                                               |
| --------- | -------- | ------------------------------------------------------------------------- |
| `version` | `latest` | chiplab-cli version to install, e.g. `0.1.0` (a leading `v` is accepted). |

Pin `version` for reproducible builds.

## Outputs

| Name      | Description                                  |
| --------- | -------------------------------------------- |
| `version` | Installed chiplab-cli version, e.g. `0.1.0`. |

## Supported runners

Linux (x64, arm64) and macOS (arm64).
Windows and Intel macOS are not supported.

Self-hosted runners need `bash`, `curl`, `shasum`, `awk` and `tar`.

## Development

Run `nix flake check` before pushing.
`nix run .#setup-jj-fix` configures `jj fix` with the same formatters.

## Releasing

Tag the release, move the major tag to it and push both:

```sh
git tag v1.0.0
git tag --force v1 v1.0.0
git push origin v1.0.0
git push --force origin v1
```

Then create a GitHub release from `v1.0.0` to publish it on the Marketplace.

## License

[MIT](LICENSE)
