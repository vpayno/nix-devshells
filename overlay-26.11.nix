# overlay-26.11.nix
final: prev: {
  # cargo-spellcheck = prev.cargo-spellcheck.overrideAttrs (oldAttrs: {
  #   nativeBuildInputs =
  #     (oldAttrs.nativeBuildInputs or [ ])
  #     ++ (with prev; [
  #       pkg-config
  #     ]);
  #   buildInputs =
  #     (oldAttrs.buildInputs or [ ])
  #     ++ (with prev; [
  #       oniguruma
  #     ]);
  # });
}
