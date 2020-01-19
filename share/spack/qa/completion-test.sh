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

    # Run a second time to hit the caching stage
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
contains 'compilers.py' _spack_completions spack test ''
contains 'packages' _spack_completions spack config edit ''
contains 'python' _spack_completions spack extensions ''
