# nix-clasp

Nix flake that provides a [Clasp Common Lisp](https://github.com/clasp-developers/clasp) package

## Requirements

Nix with flakes support

## Usage

```
nix run github:uthar/nix-clasp
```

## Binary cache information

```nix
{
  nix.binaryCachePublicKeys = [ "cache.galkowski.xyz-1:8itwpvpPypcmgogbwtWf6+/EOFALY2BIrG0zF8LfMCM=" ];
  nix.trustedBinaryCaches = [ "https://cache.galkowski.xyz" ];
}
```
