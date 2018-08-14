class Usbutils < Formula
  desc "Provides 'lsusb' tool for getting detailed info about USB devices"
  # Homepage for multiple Linux USB tools, 'usbutils' is one of them.
  homepage "https://linux-usb.sourceforge.io"
  # The latest version we can use is 007 (from 2013), because the later
  # versions depend on 'libudev': part of Systemd and not in Homebrew.
  url "https://mirrors.edge.kernel.org/pub/linux/utils/usb/usbutils/usbutils-007.tar.xz"
  sha256 "7593a01724bbc0fd9fe48e62bc721ceb61c76654f1d7b231b3c65f6dfbbaefa4"

  bottle do
    root_url "https://dl.bintray.com/mikhailai/bottles-misc"
    sha256 "b8de8fc8be85c77d47b3251dc32153a7bcc43fd7b143069c0f9baa6ae0e90208" => :el_capitan
    sha256 "5e9e8018181e361e61921c4616d3eb0b98691faafce7023e8764f53854b0b53a" => :sierra
    sha256 "d16701763632378ab44c00efd9067edec9497df38f29365147ce51fe1552b071" => :high_sierra
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkg-config" => :build
  depends_on "libusb"

  conflicts_with "lsusb", :because => "a fake 'lsusb' command is already installed"

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    # Clear AM_LDFLAGS to remove unsupported "-Wl,--as-needed"
    # Also, clear/override several other variables, to avoid
    # building/installing linux-specific utilities that rely on sysfs.
    system "make", "install", "AM_LDFLAGS=", "SUBDIRS=", "bin_SCRIPTS=",
                              "man_MANS=lsusb.8"
  end

  test do
    # Run --version only. The normal 'lsusb' run may exit
    # with 1 if executed on a Virtual Machine.
    system "#{bin}/lsusb", "--version"
    # Make sure nothing shows up on stderr - 'lsusb' would print
    # a message if it could not find the USB ids file:
    _, stderr, status = Open3.capture3("#{bin}/lsusb")
    assert_true status.exited?
    assert_equal "", stderr
  end
end
