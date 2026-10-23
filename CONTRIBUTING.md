# Contributing

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
