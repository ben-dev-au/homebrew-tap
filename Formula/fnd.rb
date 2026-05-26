class Fnd < Formula
  desc "Fast, free, keyboard-driven document search for macOS"
  homepage "https://github.com/ben-dev-au/fnd"
  url "https://files.pythonhosted.org/packages/9e/5f/2c09ec86138d697b08f74ba71e9a1dedc72016eec86e10814b8b9f00672f/fndr-0.0.1.tar.gz"
  sha256 "1c315050283342cb0a5cdc1ecdbf1a146deabd9bb4ee396876e8469ebb14d0d8"
  license "MIT"

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
    # MuPDF's C++ bindings (built inside pymupdf via mupdfwrap.py) need >=C++14
    # (thread_local, vector init); CI's clang defaults older and errors in C++98
    # mode. Forcing it on CXX (the compiler itself) reaches every C++ compile,
    # including the bindings — the same proven lever homebrew-core/mupdf uses.
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
