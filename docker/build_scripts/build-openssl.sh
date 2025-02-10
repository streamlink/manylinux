#!/bin/bash
# Top-level build script called from Dockerfile

# Stop at any error, show all commands
set -exuo pipefail

# Get script directory
MY_DIR=$(dirname "${BASH_SOURCE[0]}")

# Get build utilities
# shellcheck source-path=SCRIPTDIR
source "${MY_DIR}/build_utils.sh"

# Install a more recent openssl
check_var "${OPENSSL_ROOT}"
check_var "${OPENSSL_HASH}"
check_var "${OPENSSL_DOWNLOAD_URL}"

OPENSSL_VERSION=${OPENSSL_ROOT#*-}

if [ "${OS_ID_LIKE}" = "rhel" ];then
	manylinux_pkg_remove openssl-devel
elif [ "${OS_ID_LIKE}" = "debian" ];then
	manylinux_pkg_remove libssl-dev
elif [ "${OS_ID_LIKE}" = "alpine" ]; then
	manylinux_pkg_remove openssl-dev
fi

PREFIX=/opt/_internal/openssl-${OPENSSL_VERSION%.*}

fetch_source "${OPENSSL_ROOT}.tar.gz" "${OPENSSL_DOWNLOAD_URL}"
check_sha256sum "${OPENSSL_ROOT}.tar.gz" "${OPENSSL_HASH}"
tar -xzf "${OPENSSL_ROOT}.tar.gz"
pushd "${OPENSSL_ROOT}"
./Configure \
	"--prefix=${PREFIX}" \
	"--openssldir=${PREFIX}" \
	--libdir=lib \
	CPPFLAGS="${MANYLINUX_CPPFLAGS}" \
	CFLAGS="${MANYLINUX_CFLAGS}" \
	CXXFLAGS="${MANYLINUX_CXXFLAGS}" \
	LDFLAGS="${MANYLINUX_LDFLAGS} -Wl,-rpath,\$(LIBRPATH)"
make
make install_sw
popd
rm -rf "${OPENSSL_ROOT}" "${OPENSSL_ROOT}.tar.gz"

strip_ "${PREFIX}"

"${PREFIX}/bin/openssl" version
