class Fnd < Formula
  desc "Fast, free, keyboard-driven document search for macOS"
  homepage "https://github.com/ben-dev-au/fnd"
  url "https://files.pythonhosted.org/packages/62/4f/35987778d64a9feb13aae479ddf84fb5f876e42e40cb0aa4c1dfa5705626/fndr-1.1.1.tar.gz"
  sha256 "1a37675a16f0e4dafe0c99d2603c855b54c8a591f3722928c9e07c22803149ac"
  license "AGPL-3.0-or-later"

  bottle do
    root_url "https://github.com/ben-dev-au/homebrew-tap/releases/download/fnd-bottles-1.1.1"
    sha256 cellar: :any, arm64_sequoia: "29c85868f4a7d17c69dfdaa5177635fc1a6599107eb30e6177fd5282a93e2613"
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
