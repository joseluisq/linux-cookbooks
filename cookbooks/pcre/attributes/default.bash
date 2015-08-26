#!/bin/bash -e

export PCRE_DOWNLOAD_URL='ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre2-10.20.tar.gz'

export PCRE_INSTALL_FOLDER='/opt/pcre'

export PCRE_CONFIG=(
    '--enable-bsr-anycrlf'
    '--enable-coverage'
    '--enable-dependency-tracking'
    '--enable-fast-install'
    '--enable-jit'
    '--enable-newline-is-any'
    '--enable-newline-is-anycrlf'
    '--enable-newline-is-cr'
    '--enable-newline-is-crlf'
    '--enable-newline-is-lf'
    '--enable-pcre2-16'
    '--enable-pcre2-32'
    '--enable-pcre2-8'
    '--enable-pcre2grep-libbz2'
    '--enable-pcre2grep-libz'
    '--enable-rebuild-chartables'
    '--enable-shared'
    '--enable-static'
    '--enable-utf'
    '--enable-valgrind'
    "--prefix=${PCRE_INSTALL_FOLDER}"
    '--with-aix-soname=both'
    '--with-gnu-ld=no'
    '--with-link-size=2'
    '--with-match-limit=10000000'
    '--with-match-limit-recursion=MATCH_LIMIT'
    '--with-parens-nest-limit=250'
    '--with-pcre2grep-bufsize=20480'
)