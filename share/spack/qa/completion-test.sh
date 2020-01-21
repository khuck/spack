#!/bin/sh
#
# Copyright 2013-2020 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

#
# This script tests that Spack's tab completion scripts work.
#
# The tests are portable to bash, zsh, and bourne shell, and can be run
# in any of these shells.
#

export QA_DIR=$(dirname "$0")
export SHARE_DIR=$(cd "$QA_DIR/.." && pwd)
export SPACK_ROOT=$(cd "$QA_DIR/../../.." && pwd)

. "$QA_DIR/test-framework.sh"

# Fail on undefined variables
set -u

# Source setup-env.sh before tests
. "$SHARE_DIR/setup-env.sh"
. "$SHARE_DIR/spack-completion.$_sp_shell"

title "Testing spack-completion.$_sp_shell with $_sp_shell"

# Spack command is now available
succeeds which spack

title 'Testing all subcommands'
while IFS= read -r line
do
    # Test that completion with no args works
    succeeds _spack_completions ${line[*]} ''

    # Test that completion with flags works
    contains '-h --help' _spack_completions ${line[*]} -
done <<- EOF
    $(spack commands --aliases --format=subcommands)
EOF

title 'Testing for correct output'
contains 'compiler' _spack_completions spack ''
contains 'install' _spack_completions spack inst
contains 'find' _spack_completions spack help ''
contains 'hdf5' _spack_completions spack list ''
contains 'py-numpy' _spack_completions spack list py-
contains 'mpi' _spack_completions spack providers ''
contains 'builtin' _spack_completions spack repo remove ''
contains 'packages' _spack_completions spack config edit ''
contains 'python' _spack_completions spack extensions ''
contains 'hdf5' _spack_completions spack -d install ''
contains 'hdf5' _spack_completions spack install -v ''

# XFAIL: Fails for Python 2.6 because pkg_resources not found?
#contains 'compilers.py' _spack_completions spack test ''

title 'Testing debugging functions'
COMP_LINE='spack install '
COMP_POINT=${#COMP_LINE}
COMP_WORDS=(spack install '')
COMP_WORDS_NO_FLAGS=(spack install '')
COMP_CWORD=2
COMP_CWORD_NO_FLAGS=2
subfunction=_spack_install
cur=install
prev=spack
contains "['spack', 'install', '']" _pretty_print COMP_WORDS[@]
list_options=true
contains "'True'" _test_vars
list_options=false
contains "'False'" _test_vars
