class Fnd < Formula
  desc "Fast, free, keyboard-driven document search for macOS"
  homepage "https://github.com/ben-dev-au/fnd"
  url "https://files.pythonhosted.org/packages/1c/ab/8970e75bb347d38ebf1dd9ec44c2d40cc713cf7f78c8a3026fb5c1764e9b/fndr-1.1.2.tar.gz"
  sha256 "014302d8015595f794ea2b28266ec707cc8aa1ab3df2f812c85f61626f085694"
  license "AGPL-3.0-or-later"

  bottle do
    root_url "https://github.com/ben-dev-au/homebrew-tap/releases/download/fnd-bottles-1.1.2"
    sha256 cellar: :any, arm64_sequoia: "623ca637dee9fe9cdec011b27ca56a0498fa1346355caaab93ab134b0b4a81b3"
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
