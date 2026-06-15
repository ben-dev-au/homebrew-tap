class Fnd < Formula
  desc "Fast, free, keyboard-driven document search for macOS"
  homepage "https://github.com/ben-dev-au/fnd"
  url "https://files.pythonhosted.org/packages/81/3c/bdf8ad64cb82fdb8b3ca90e60910a266913fdb6a869c70058b50f276cd54/fndr-0.0.3.tar.gz"
  sha256 "e7fc6e75c88deec11023078aea52e7732d8da13209bbd0ebf4bb83235d4c05bf"
  license "MIT"

  bottle do
    root_url "https://github.com/ben-dev-au/homebrew-tap/releases/download/fnd-bottles-0.0.2"
    sha256 cellar: :any, arm64_sonoma: "5ba521f45773dcc85c1ff4f4fbd34a6df048ae5eec80fd6c6c7bf8214e23cd00"
  end

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
    system Formula["python@3.13"].opt_libexec/"bin/python3", "-m", "venv", libexec
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
