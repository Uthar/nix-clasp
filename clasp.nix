{ pkgs }:

let

  inherit (pkgs)
    llvmPackages_13
    python3;

  Cleavir = builtins.fetchTarball {
    url = https://github.com/s-expressionists/Cleavir/archive/b6b610fc2ec6acf32a83bd636f94985e1be05950.tar.gz;
    sha256 = "1l4apipjs5mzmapcg60zyqbqr61lbvrdhchyyphz7dfg5lgh3vn8";
  };
  Concrete-Syntax-Tree = builtins.fetchTarball {
    url = https://github.com/s-expressionists/Concrete-Syntax-Tree/archive/4f01430c34f163356f3a2cfbf0a8a6963ff0e5ac.tar.gz;
    sha256 = "169ibaz1vv7pphib28443zzk3hf1mrcarhzfm8hnbdbk529cnxyi";
  };
  closer-mop = builtins.fetchTarball {
    url = https://github.com/pcostanza/closer-mop/archive/d4d1c7aa6aba9b4ac8b7bb78ff4902a52126633f.tar.gz;
    sha256 = "1amcv0f3vbsq0aqhai7ki5bi367giway1pbfxyc47r7q3hq5hw3c";
  };
  Acclimation = builtins.fetchTarball {
    url = https://github.com/robert-strandh/Acclimation/archive/dd15c86b0866fc5d8b474be0da15c58a3c04c45c.tar.gz;
    sha256 = "0ql224qs3zgflvdhfbca621v3byhhqfb71kzy70bslyczxv1bsh2";
  };
  Eclector = builtins.fetchTarball {
    url = https://github.com/s-expressionists/Eclector/archive/dddb4d8af3eae78017baae7fb9b99e73d2a56e6b.tar.gz;
    sha256 = "00raw4nfg9q73w1pj4r001g90g97n2rq6q3zijg5j6j7iq81df9s";
  };
  alexandria = builtins.fetchTarball {
    url = https://gitlab.common-lisp.net/alexandria/alexandria/-/archive/v1.4/alexandria-v1.4.tar.gz;
    sha256 = "0r1adhvf98h0104vq14q7y99h0hsa8wqwqw92h7ghrjxmsvz2z6l";
  };
  esrap = builtins.fetchTarball {
    url = https://github.com/scymtym/esrap/archive/c99c33a33ff58ca85e8ba73912eba45d458eaa72.tar.gz;
    sha256 = "0dcylqr93r959blz1scb5yd79qplqdsl3hbji0icq2yyxvam7cyi";
  };
  trivial-with-current-source-form = builtins.fetchTarball {
    url = https://github.com/scymtym/trivial-with-current-source-form/archive/3898e09f8047ef89113df265574ae8de8afa31ac.tar.gz;
    sha256 = "1114iibrds8rvwn4zrqnmvm8mvbgdzbrka53dxs1q61ajv44x8i0";
  };
  mps = builtins.fetchTarball {
    url = https://github.com/Ravenbrook/mps/archive/b8a05a3846430bc36c8200f24d248c8293801503.tar.gz;
    sha256 = "1q2xqdw832jrp0w9yhgr8xihria01j4z132ac16lr9ssqznkprv6";
  };
  asdf = builtins.fetchTarball {
    url = https://gitlab.common-lisp.net/asdf/asdf/-/archive/3.3.5/asdf-3.3.5.tar.gz;
    sha256 = "1b62p3ln1mwiqfwja8fbnhgrli761hk1h6vqw1597bz8lvwlbf70";
  };

clasp =

  llvmPackages_13.stdenv.mkDerivation {
    pname = "clasp";
    version = "1.0.0";
    src = builtins.fetchTarball {
      url = https://github.com/clasp-developers/clasp/archive/1.0.0.tar.gz;
      sha256 = "1yyxclwfk64rqia3j76wkd877zjv4r0yav7r6wj6ksgcfylbsn0j";
    };
    preConfigure = ''
    ./waf configure
  '';
    postPatch = ''
      substituteInPlace waf \
        --replace '/usr/bin/env python3' ${python3.interpreter}

      mkdir -pv src/lisp/kernel/contrib/Cleavir
      mkdir -pv src/lisp/kernel/contrib/Concrete-Syntax-Tree
      mkdir -pv src/lisp/kernel/contrib/closer-mop
      mkdir -pv src/lisp/kernel/contrib/Acclimation
      mkdir -pv src/lisp/kernel/contrib/Eclector
      mkdir -pv src/lisp/kernel/contrib/alexandria
      mkdir -pv src/scraper/dependencies/alexandria
      mkdir -pv src/scraper/dependencies/esrap
      mkdir -pv src/scraper/dependencies/trivial-with-current-source-form
      mkdir -pv src/mps
      mkdir -pv src/lisp/modules/asdf

      cp -rfT "${Cleavir}" src/lisp/kernel/contrib/Cleavir
      cp -rfT "${Concrete-Syntax-Tree}" src/lisp/kernel/contrib/Concrete-Syntax-Tree
      cp -rfT "${closer-mop}" src/lisp/kernel/contrib/closer-mop
      cp -rfT "${Acclimation}" src/lisp/kernel/contrib/Acclimation
      cp -rfT "${Eclector}" src/lisp/kernel/contrib/Eclector
      cp -rfT "${alexandria}" src/lisp/kernel/contrib/alexandria
      cp -rfT "${alexandria}" src/scraper/dependencies/alexandria
      cp -rfT "${esrap}" src/scraper/dependencies/esrap
      cp -rfT "${trivial-with-current-source-form}" src/scraper/dependencies/trivial-with-current-source-form
      cp -rfT "${mps}" src/mps
      cp -rfT "${asdf}" src/lisp/modules/asdf

     substituteInPlace tools-for-build/fetch-git-revision.sh \
       --replace 'cd "$path" || exit $?' 'cd "$path" && exit 0'

      substituteInPlace include/clasp/core/character.h \
        --replace "en_US.UTF-8" ""

      echo "PREFIX = \"$out\"" > wscript.config
    '';
    buildInputs = with pkgs; [
      python310 git sbcl gmp libffi boehmgc libelf libbsd
      boost175.dev boost175
      llvmPackages_13.llvm.dev
      llvmPackages_13.libclang
    ];
  };

fixup = clasp: pkgs.stdenv.mkDerivation {
  inherit (clasp) pname version;
  src = clasp;
  buildPhase = ''
    mkdir -pv $out
    cp -r * $out
    rm -rf $out/lib/clasp/src/lisp/kernel/contrib/{alexandria,closer-mop}
    mv $out/bin/iclasp-boehm $out/bin/clasp
  '';
  dontInstall = true;
  dontFixup = true;
  dontStrip = true;
};

in fixup clasp
