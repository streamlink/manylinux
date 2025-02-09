# streamlink/manylinux

This is a fork of the [`pypa/manylinux`](https://github.com/pypa/manylinux) repository.

The purpose of this fork is having slim manylinux image builds that are used as the build environment
for [Streamlink's AppImages](https://github.com/streamlink/streamlink-appimage).

Please see the upstream docs for more information.

## Key changes

- only Streamlink-relevant CPython builds
- only x86\_64 and aarch64 image builds
- forced OpenSSL builds
- built on GitHub actions and deployed to GHCR

Upstream changes will be merged back regularly. A big thank you to the upstream manylinux maintainers.
