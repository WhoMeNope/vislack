let
  # Look here for information about how to generate `nixpkgs-version.json`.
  #  → https://nixos.wiki/wiki/FAQ/Pinning_Nixpkgs
  pinnedVersion = builtins.fromJSON (builtins.readFile ./.nixpkgs-version.json);
  pinnedPkgs = import (builtins.fetchGit {
    inherit (pinnedVersion) url rev;

    ref = "nixos-unstable";
  }) {};
in

# This allows overriding pkgs by passing `--arg pkgs ...`
{ pkgs ? pinnedPkgs }:

with pkgs;

mkShell {
  buildInputs = [
    stack
  ];
  shellHook = ''
    unset NIX_SSL_CERT_FILE
    GIT_SSL_CAINFO=/etc/ssl/certs/ca-certificates.crt
    SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
  '';
}
