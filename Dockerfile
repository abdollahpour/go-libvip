FROM golang:1.17.3 as builder
ARG VIPS_VERSION=8.9.2
ARG LIBHEIF_VERSION=1.9.1

# Installs libvips + required libraries
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update && \
    apt-get install --no-install-recommends -y \
    ca-certificates \
    automake build-essential curl \
    gobject-introspection gtk-doc-tools libglib2.0-dev libjpeg62-turbo-dev libpng-dev \
    libwebp-dev libtiff5-dev libgif-dev libexif-dev libxml2-dev libpoppler-glib-dev \
    swig libmagickwand-dev libpango1.0-dev libmatio-dev libopenslide-dev libcfitsio-dev \
    libgsf-1-dev fftw3-dev liborc-0.4-dev librsvg2-dev libimagequant-dev libaom-dev && \
    cd /tmp && \
    curl -fsSLO https://github.com/strukturag/libheif/releases/download/v${LIBHEIF_VERSION}/libheif-${LIBHEIF_VERSION}.tar.gz && \
    tar zvxf libheif-${LIBHEIF_VERSION}.tar.gz && \
    cd /tmp/libheif-${LIBHEIF_VERSION} && \
    ./configure --prefix=/vips && \
    make && \
    make install && \
    echo '/vips/lib' > /etc/ld.so.conf.d/vips.conf && \
    ldconfig -v && \
    export LD_LIBRARY_PATH="/vips/lib:$LD_LIBRARY_PATH" && \
    export PKG_CONFIG_PATH="/vips/lib/pkgconfig:$PKG_CONFIG_PATH" && \
    cd /tmp && \
    curl -fsSLO https://github.com/libvips/libvips/releases/download/v${LIBVIPS_VERSION}/vips-${LIBVIPS_VERSION}.tar.gz && \
    tar zvxf vips-${LIBVIPS_VERSION}.tar.gz && \
    cd /tmp/vips-${LIBVIPS_VERSION} && \
    CFLAGS="-g -O3" CXXFLAGS="-D_GLIBCXX_USE_CXX11_ABI=0 -g -O3" \
    ./configure \
    --disable-debug \
    --disable-dependency-tracking \
    --disable-introspection \
    --disable-static \
    --enable-gtk-doc-html=no \
    --enable-gtk-doc=no \
    --enable-pyvips8=no \
    --prefix=/vips && \
    make && \
    make install && \
    ldconfig