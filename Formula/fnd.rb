class Fnd < Formula
  desc "Fast, free, keyboard-driven document search for macOS"
  homepage "https://github.com/ben-dev-au/fnd"
  url "https://files.pythonhosted.org/packages/7a/a0/045037d55c4bb40324ee82ff3407523366e0fabbd76f707c4e8a3e9b3f60/fndr-1.0.0.tar.gz"
  sha256 "f2004af43da995e6218a56a7436c64b85823d7422ecc33d952f7f922410c5a6e"
  license "AGPL-3.0-or-later"

  depends_on "python@3.13"
  depends_on "swig" => :build
  depends_on "rust" => :build
  depends_on "libxml2"
  depends_on "libxslt"
  depends_on "jpeg-turbo"
  depends_on "freetype"
  depends_on "little-cms2"
  depends_on "openjpeg"

  def install
    # pymupdf's bundled MuPDF C++ bindings need >=C++14; CI clang defaults older
    # and fails. Set it on CXX (not CXXFLAGS, which never reaches the bindings).
    ENV.append "CXX", "-std=c++14"
    python = Formula["python@3.13"].opt_libexec/"bin/python3"
    # MuPDF 1.28's SWIG bindings still emit PyString_FromString, dropped in SWIG
    # 4.5.0. Setting PYMUPDF_SETUP_SWIG stops pymupdf requesting `swig` as a
    # backend dependency — a phase pip resolves without applying PIP_CONSTRAINT.
    system python, "-m", "venv", buildpath/"swig-tool"
    system buildpath/"swig-tool/bin/pip", "install", "--no-cache-dir", "swig==4.4.1"
    ENV["PYMUPDF_SETUP_SWIG"] = (buildpath/"swig-tool/bin/swig").to_s
    system python, "-m", "venv", libexec
    pip = libexec/"bin/pip"
    # pillow from source with xcb disabled (mis-links libxcb under brew's env).
    system pip, "install", "-v", "--no-cache-dir", "--no-binary", "pillow",
           "--config-settings=xcb=disable", "pillow==12.2.0"
    # fndr + remaining natives from source; pymupdf builds its own MuPDF (now
    # compiles cleanly thanks to the CXX -std fix).
    system pip, "install", "-v", "--no-cache-dir", "--no-binary",
           "tantivy,pydantic-core,pymupdf,lxml", buildpath
    bin.install_symlink libexec/"bin/fnd"
    bin.install_symlink libexec/"bin/fndr"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/fnd version")
  end
end
