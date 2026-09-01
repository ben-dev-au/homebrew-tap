class Fnd < Formula
  desc "Fast, free, keyboard-driven document search for macOS"
  homepage "https://github.com/ben-dev-au/fnd"
  url "https://files.pythonhosted.org/packages/a0/71/8397283237b85833d706718293c353e7f3c19173db2770b1528b80d46c28/fndr-1.0.1.tar.gz"
  sha256 "e0e082ef872cf1f3070968e43f18ab11f84b983016cea319bbd7b95f9fb049db"
  license "AGPL-3.0-or-later"

  bottle do
    root_url "https://github.com/ben-dev-au/homebrew-tap/releases/download/fnd-bottles-1.0.1"
    sha256 cellar: :any, arm64_sonoma: "29e6dbe99040b980353961ee8e39b1f2a257dc01ff34b31924d902d531efa7a8"
  end

  depends_on "python@3.13"
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
