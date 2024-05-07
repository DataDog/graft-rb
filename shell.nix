{
  pkgs ? import <nixpkgs> {},
  pinned ? import(fetchTarball("https://github.com/NixOS/nixpkgs/archive/25865a40d14b.tar.gz")) {},
}:
let
  ruby = pinned.ruby_3_3;
  llvm = pinned.llvmPackages_16;
in llvm.stdenv.mkDerivation {
  name = "shell";

  buildInputs = [
    ruby
    pinned.libyaml.dev
  ];

  shellHook = ''
    export RUBY_VERSION="$(ruby -e 'puts RUBY_VERSION.gsub(/\d+$/, "0")')"
    export GEM_HOME="$(pwd)/vendor/bundle/ruby/$RUBY_VERSION"
    export BUNDLE_PATH="$(pwd)/vendor/bundle"
    export PATH="$GEM_HOME/bin:$PATH"
  '';
}
