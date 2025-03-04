# default to latest supported policy, x86_64
ARG BASEIMAGE=amd64/almalinux:9
ARG POLICY=manylinux_2_34
ARG PLATFORM=x86_64
ARG DEVTOOLSET_ROOTPATH=/opt/rh/gcc-toolset-14/root
ARG LD_LIBRARY_PATH_ARG=${DEVTOOLSET_ROOTPATH}/usr/lib64:${DEVTOOLSET_ROOTPATH}/usr/lib:${DEVTOOLSET_ROOTPATH}/usr/lib64/dyninst:${DEVTOOLSET_ROOTPATH}/usr/lib/dyninst
ARG PREPEND_PATH=/usr/local/bin:${DEVTOOLSET_ROOTPATH}/usr/bin:

FROM $BASEIMAGE AS runtime_base
ARG POLICY
ARG PLATFORM
ARG DEVTOOLSET_ROOTPATH
ARG LD_LIBRARY_PATH_ARG
ARG PREPEND_PATH
LABEL maintainer="The Streamlink project"

ENV AUDITWHEEL_POLICY=${POLICY} AUDITWHEEL_ARCH=${PLATFORM} AUDITWHEEL_PLAT=${POLICY}_${PLATFORM}
ENV LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8
ENV DEVTOOLSET_ROOTPATH=${DEVTOOLSET_ROOTPATH}
ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH_ARG}
ENV PATH=${PREPEND_PATH}${PATH}
ENV PKG_CONFIG_PATH=/usr/local/lib/pkgconfig

# first copy the fixup mirrors script, keep the script around
COPY build_scripts/fixup-mirrors.sh /usr/local/sbin/fixup-mirrors

# setup entrypoint, this will wrap commands with `linux32` with i686 images
RUN --mount=type=bind,target=/build_scripts,source=build_scripts \
    /build_scripts/install-entrypoint.sh
COPY manylinux-entrypoint /usr/local/bin/manylinux-entrypoint
ENTRYPOINT ["manylinux-entrypoint"]

RUN --mount=type=bind,target=/build_scripts,source=build_scripts \
    manylinux-entrypoint /build_scripts/install-runtime-packages.sh

RUN --mount=type=bind,target=/build_scripts,source=build_scripts \
    export AUTOCONF_ROOT=autoconf-2.72 && \
    export AUTOCONF_HASH=afb181a76e1ee72832f6581c0eddf8df032b83e2e0239ef79ebedc4467d92d6e && \
    export AUTOCONF_DOWNLOAD_URL=http://ftp.gnu.org/gnu/autoconf && \
    manylinux-entrypoint /build_scripts/install-autoconf.sh

RUN --mount=type=bind,target=/build_scripts,source=build_scripts \
    export AUTOMAKE_ROOT=automake-1.17 && \
    export AUTOMAKE_HASH=397767d4db3018dd4440825b60c64258b636eaf6bf99ac8b0897f06c89310acd && \
    export AUTOMAKE_DOWNLOAD_URL=http://ftp.gnu.org/gnu/automake && \
    manylinux-entrypoint /build_scripts/install-automake.sh

RUN --mount=type=bind,target=/build_scripts,source=build_scripts \
    export LIBTOOL_ROOT=libtool-2.5.3 && \
    export LIBTOOL_HASH=9322bd8f6bc848fda3e385899dd1934957169652acef716d19d19d24053abb95 && \
    export LIBTOOL_DOWNLOAD_URL=http://ftp.gnu.org/gnu/libtool && \
    manylinux-entrypoint /build_scripts/install-libtool.sh

RUN --mount=type=bind,target=/build_scripts,source=build_scripts \
    export LIBXCRYPT_VERSION=4.4.38 && \
    export LIBXCRYPT_HASH=80304b9c306ea799327f01d9a7549bdb28317789182631f1b54f4511b4206dd6 && \
    export LIBXCRYPT_DOWNLOAD_URL=https://github.com/besser82/libxcrypt/releases/download && \
    manylinux-entrypoint /build_scripts/install-libxcrypt.sh

FROM runtime_base AS build_base
RUN --mount=type=bind,target=/build_scripts,source=build_scripts \
    manylinux-entrypoint /build_scripts/install-build-packages.sh


FROM build_base AS build_git
RUN --mount=type=bind,target=/build_scripts,source=build_scripts \
    export CURL_ROOT=curl-8.12.0 && \
    export CURL_HASH=b72ec874e403c90462dc3019c5b24cc3cdd895247402bf23893b3b59419353bc && \
    export CURL_DOWNLOAD_URL=https://curl.haxx.se/download && \
    manylinux-entrypoint /build_scripts/build-curl.sh
RUN --mount=type=bind,target=/build_scripts,source=build_scripts \
    export GIT_ROOT=git-2.48.1 && \
    export GIT_HASH=51b4d03b1e311ba673591210f94f24a4c5781453e1eb188822e3d9cdc04c2212 && \
    export GIT_DOWNLOAD_URL=https://www.kernel.org/pub/software/scm/git && \
    manylinux-entrypoint /build_scripts/build-git.sh

FROM build_base AS build_sqlite3
RUN --mount=type=bind,target=/build_scripts,source=build_scripts \
    export SQLITE_AUTOCONF_ROOT=sqlite-autoconf-3490000 && \
    export SQLITE_AUTOCONF_HASH=4d8bfa0b55e36951f6e5a9fb8c99f3b58990ab785c57b4f84f37d163a0672759 && \
    export SQLITE_AUTOCONF_DOWNLOAD_URL=https://www.sqlite.org/2025 && \
    manylinux-entrypoint /build_scripts/build-sqlite3.sh

FROM build_base AS build_tcl_tk
RUN --mount=type=bind,target=/build_scripts,source=build_scripts \
    export TCL_ROOT=tcl8.6.16 && \
    export TCL_HASH=91cb8fa61771c63c262efb553059b7c7ad6757afa5857af6265e4b0bdc2a14a5 && \
    export TCL_DOWNLOAD_URL=https://prdownloads.sourceforge.net/tcl && \
    export TK_ROOT=tk8.6.16 && \
    export TK_HASH=be9f94d3575d4b3099d84bc3c10de8994df2d7aa405208173c709cc404a7e5fe && \
    manylinux-entrypoint /build_scripts/build-tcltk.sh

FROM build_base AS build_mpdecimal
RUN --mount=type=bind,target=/build_scripts,source=build_scripts \
    export MPDECIMAL_ROOT=mpdecimal-4.0.0 && \
    export MPDECIMAL_HASH=942445c3245b22730fd41a67a7c5c231d11cb1b9936b9c0f76334fb7d0b4468c && \
    export MPDECIMAL_DOWNLOAD_URL=https://www.bytereef.org/software/mpdecimal/releases && \
    manylinux-entrypoint /build_scripts/build-mpdecimal.sh


FROM build_base AS build_cpython
COPY --from=ghcr.io/sigstore/cosign/cosign:v2.4.2 /ko-app/cosign /usr/local/bin/cosign
COPY --from=build_tcl_tk /manylinux-buildfs /
COPY --from=build_mpdecimal /manylinux-buildfs /
COPY --from=build_sqlite3 /manylinux-buildfs /
RUN --mount=type=bind,target=/build_scripts,source=build_scripts \
    if command -v apk >/dev/null 2>&1; then ldconfig /; else ldconfig; fi && \
    export OPENSSL_ROOT=openssl-3.0.16 && \
    export OPENSSL_HASH=57e03c50feab5d31b152af2b764f10379aecd8ee92f16c985983ce4a99f7ef86 && \
    export OPENSSL_DOWNLOAD_URL=https://github.com/openssl/openssl/releases/download/${OPENSSL_ROOT} && \
    manylinux-entrypoint /build_scripts/build-openssl.sh


FROM build_cpython AS build_cpython313
RUN --mount=type=bind,target=/build_scripts,source=build_scripts \
    manylinux-entrypoint /build_scripts/build-cpython.sh thomas@python.org https://accounts.google.com 3.13.2


FROM runtime_base
COPY --from=build_tcl_tk /manylinux-rootfs /
COPY --from=build_mpdecimal /manylinux-rootfs /
COPY --from=build_sqlite3 /manylinux-rootfs /
COPY --from=build_git /manylinux-rootfs /
COPY build_scripts /opt/_internal/build_scripts/
RUN --mount=type=bind,target=/build_cpython313,from=build_cpython313 \
    mkdir -p /opt/_internal && \
    cp -rf /build_cpython*/opt/_internal/* /opt/_internal/ && \
    manylinux-entrypoint /opt/_internal/build_scripts/finalize.sh

ENV SSL_CERT_FILE=/opt/_internal/certs.pem

CMD ["/bin/bash"]
