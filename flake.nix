{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix2container.url = "github:nlewo/nix2container";
  };
  outputs = inputs: {
    packages = builtins.mapAttrs (system: pkgs: rec {
      hello = pkgs.runCommand "hello" { } ''
        ln -s ${pkgs.hello}/bin/hello $out
      '';
      ls-hello = pkgs.runCommand "ls-hello" { } ''
        ls -l ${hello} > $out
      '';
      print-ls-hello = pkgs.writeShellScriptBin "nix-2.18-vs-nix-2.21" ''
        set -ex -o pipefail

        HELLO_FILE="$(${pkgs.nix}/bin/nix build --no-link --print-out-paths ${./.}#hello)"

        ls -l "$HELLO_FILE"

        LS_HELLO=$(< "$(${pkgs.nix}/bin/nix build --no-link --print-out-paths ${./.}#ls-hello)")

        ${pkgs.nix}/bin/nix-store --query --referrers-closure "$HELLO_FILE" | xargs ${pkgs.nix}/bin/nix-store --delete

        echo "$LS_HELLO"
      '';
    }) inputs.nixpkgs.legacyPackages;
  };
}
