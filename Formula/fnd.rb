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
    pybin = Formula["python@3.13"].opt_libexec/"bin/python3"
    system pybin, "-m", "venv", libexec
    pip = libexec/"bin/pip"
    # pillow from source with xcb disabled: under Homebrew's env it otherwise
    # mis-links libxcb (flat-namespace `_xcb_connect`) and fails to load. fnd
    # never uses ImageGrab. Fresh build (--no-cache-dir) so the broken cached
    # wheel isn't reused. Pinned to the version fndr resolves.
    system pip, "install", "-v", "--no-cache-dir", "--no-binary", "pillow",
           "--config-settings=xcb=disable", "pillow==12.2.0"
    # fndr + the remaining native deps from source (pillow already satisfied).
    # pymupdf builds its own MuPDF (default path); backends arrive as wheels.
    system pip, "install", "-v", "--no-binary", "tantivy,pydantic-core,pymupdf,lxml", buildpath
    bin.install_symlink libexec/"bin/fnd"
    bin.install_symlink libexec/"bin/fndr"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/fnd version")
  end
end
