#! /usr/bin/env nix-shell
#! nix-shell -i bash -p coreutils haskellPackages.cabal2nix-unstable git nix -I nixpkgs=.

# This script is used to regenerate nixpkgs' Haskell package set, using the
# tool hackage2nix from the nixos/cabal2nix repo. hackage2nix looks at the
# config files in pkgs/development/haskell-modules/configuration-hackage2nix
# and generates a Nix expression for package version specified there, using the
# Cabal files from the Hackage database (available under all-cabal-hashes) and
# its companion tool cabal2nix.
#
# Related scripts are update-hackage.sh, for updating the snapshot of the
# Hackage database used by hackage2nix, and update-cabal2nix-unstable.sh,
# for updating the version of hackage2nix used to perform this task.

set -euo pipefail

# To prevent hackage2nix fails because of encoding.
# See: https://github.com/NixOS/nixpkgs/pull/122023
export LC_ALL=C.UTF-8

extraction_derivation='with import ./. {}; runCommand "unpacked-cabal-hashes" { } "tar xf ${all-cabal-hashes} --strip-components=1 --one-top-level=$out"'
unpacked_hackage="$(nix-build -E "$extraction_derivation" --no-out-link)"
config_dir=pkgs/development/haskell-modules/configuration-hackage2nix

echo "Starting hackage2nix to regenerate pkgs/development/haskell-modules/hackage-packages.nix ..."
hackage2nix \
   --hackage "$unpacked_hackage" \
   --preferred-versions <(for n in "$unpacked_hackage"/*/preferred-versions; do cat "$n"; echo; done) \
   --nixpkgs "$PWD" \
   --config "$config_dir/main.yaml" \
   --config "$config_dir/stackage.yaml" \
   --config "$config_dir/broken.yaml" \
   --config "$config_dir/transitive-broken.yaml"

if [[ "${1:-}" == "--do-commit" ]]; then
git add pkgs/development/haskell-modules/hackage-packages.nix
git commit -F - << EOF
hackage-packages.nix: Regenerate based on current config

This commit has been generated by maintainers/scripts/haskell/regenerate-hackage-packages.sh
EOF
fi

echo "Regeneration of hackage-packages.nix finished."
