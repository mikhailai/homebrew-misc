class Usbutils < Formula
  # Some of the information is based on Macports 'usbutils':
  # https://github.com/macports/macports-ports/blob/master/sysutils/usbutils/Portfile
  desc "Provides 'lsusb' tool for getting detailed info about USB devices"
  # This is actually a homepage for a bunch of Linux USB things, 'usbutils' is
  # among them:
  homepage "https://linux-usb.sourceforge.io"
  # The 'usbutils' package contains several utilities, but all the ones besides
  # 'lsusb' are linux-specific (use sysfs).
  # Note, the latest version we can use is 007 (from 2013), because the later
  # versions depend on 'libudev'. The 'libudev' is not in Homebrew and is a
  # part of Systemd - may be very hard to port.
  url "https://mirrors.edge.kernel.org/pub/linux/utils/usb/usbutils/usbutils-007.tar.xz"
  sha256 "7593a01724bbc0fd9fe48e62bc721ceb61c76654f1d7b231b3c65f6dfbbaefa4"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkg-config" => :build
  depends_on "libusb"

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    # Clear/override several variables, to avoid building/installing
    # utilities that don't work on Mac.
    system "make", "install", "SUBDIRS=", "AM_LDFLAGS=", "bin_SCRIPTS=",
                              "man_MANS=lsusb.8"
  end

  test do
    # Run --version only. The normal 'lsusb' run may exit with 1 if executed
    # on a Virtual Machine.
    system "#{bin}/lsusb", "--version"
    # Make sure it does not print anything to stderr - it would print
    # a message if it could not find the USB ids:
    _, stderr, status = Open3.capture3("#{bin}/lsusb")
    assert_true status.exited?
    assert_equal "", stderr
  end
end
