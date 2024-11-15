# Start with an Ubuntu 20.04 base image
FROM ubuntu:20.04

# Set environment variables for non-interactive installation
ENV DEBIAN_FRONTEND=noninteractive
ENV PREFIX="/usr/local/cross"
ENV TARGET=i686-elf
ENV PATH="$PREFIX/bin:$PATH"

# Install necessary packages including tzdata for time zone configuration
RUN apt-get update && \
    apt-get install -y build-essential gcc g++ make gawk curl bison flex libgmp3-dev libmpc-dev libmpfr-dev texinfo wget tzdata && \
    ln -fs /usr/share/zoneinfo/Etc/UTC /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

# Download, build, and install GMP
RUN mkdir /tmp/build-gmp && cd /tmp/build-gmp && \
    wget https://gmplib.org/download/gmp/gmp-6.3.0.tar.xz && \
    tar -xvf gmp-6.3.0.tar.xz && \
    mkdir gmp-build && cd gmp-build && \
    ../gmp-6.3.0/configure --prefix=$PREFIX && \
    make && make install && \
    cd / && rm -rf /tmp/build-gmp
	
# Download, build, and install MPFR
RUN mkdir /tmp/build-mpfr && cd /tmp/build-mpfr && \
    wget https://www.mpfr.org/mpfr-current/mpfr-4.2.1.tar.gz && \
    tar -xvf mpfr-4.2.1.tar.gz && \
    mkdir mpfr-build && cd mpfr-build && \
    ../mpfr-4.2.1/configure --prefix=$PREFIX --with-gmp=$PREFIX && \
    make && make install && \
    cd / && rm -rf /tmp/build-mpfr
	
# Download, build, and install MPC
RUN mkdir /tmp/build-mpc && cd /tmp/build-mpc && \
    wget https://ftp.gnu.org/gnu/mpc/mpc-1.3.1.tar.gz && \
    tar -xvf mpc-1.3.1.tar.gz && \
    mkdir mpc-build && cd mpc-build && \
    ../mpc-1.3.1/configure --prefix=$PREFIX --with-gmp=$PREFIX --with-mpfr=$PREFIX && \
    make && make install && \
    cd / && rm -rf /tmp/build-mpc

# Download, build, and install Binutils
RUN mkdir /tmp/build-binutils && cd /tmp/build-binutils && \
    wget https://ftp.gnu.org/gnu/binutils/binutils-2.43.tar.gz && \
    tar -xvf binutils-2.43.tar.gz && \
    mkdir binutils-build && cd binutils-build && \
    ../binutils-2.43/configure --target=$TARGET --prefix=$PREFIX --with-sysroot --disable-nls --disable-werror && \
    make && make install && \
    cd / && rm -rf /tmp/build-binutils

# Download, build, and install GCC
RUN mkdir /tmp/build-gcc && cd /tmp/build-gcc && \
    wget https://ftp.gnu.org/gnu/gcc/gcc-12.2.0/gcc-12.2.0.tar.gz && \
    tar -xvf gcc-12.2.0.tar.gz && \
    mkdir gcc-build && cd gcc-build && \
    ../gcc-12.2.0/configure --target=$TARGET --prefix=$PREFIX --disable-nls --enable-languages=c,c++ --without-headers && \
    make all-gcc && make all-target-libgcc && \
    make install-gcc && make install-target-libgcc && \
    cd / && rm -rf /tmp/build-gcc

# Set entrypoint to shell
ENTRYPOINT ["/bin/bash"]
