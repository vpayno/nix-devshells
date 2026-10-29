# overlay-mpi.nix
final: prev:
let
  # TODO: look into overriding stdenv.cc
  mkMpich2WithGcc =
    mpiPackage: gccVersion:
    prev.${mpiPackage}.overrideAttrs (oldAttrs: rec {
      pname = "mpich2-gcc${gccVersion}";
      name = "${pname}-${oldAttrs.version}";
      gccDrv = prev."gcc${gccVersion}";
      gfortranDrv = prev."gfortran${gccVersion}";
      postInstall =
        builtins.replaceStrings
          (with prev; [
            "${stdenv.cc}"
            "${gfortran}"
          ])
          [
            "${gccDrv}"
            "${gfortranDrv}"
          ]
          oldAttrs.postInstall;
    });
in
{
  mpich2-gcc13 = mkMpich2WithGcc "mpich" "13";
  mpich2-gcc14 = mkMpich2WithGcc "mpich" "14";
  mpich2-gcc15 = mkMpich2WithGcc "mpich" "15";
  mpich2-gcc16 = mkMpich2WithGcc "mpich" "16";
}
