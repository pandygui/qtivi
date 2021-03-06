#!/bin/bash -e

# Copyright (C) 2017 Klaralvdalens Datakonsult AB (KDAB).
# Contact: https://www.qt.io/licensing/
#
# This file is part of the QtIvi module of the Qt Toolkit.
#
# $QT_BEGIN_LICENSE:BSD-QTAS$
# Commercial License Usage
# Licensees holding valid commercial Qt Automotive Suite licenses may use
# this file in accordance with the commercial license agreement provided
# with the Software or, alternatively, in accordance with the terms
# contained in a written agreement between you and The Qt Company.  For
# licensing terms and conditions see https://www.qt.io/terms-conditions.
# For further information use the contact form at https://www.qt.io/contact-us.
#
# BSD License Usage
# Alternatively, you may use this file under the terms of the BSD license
# as follows:
#
# "Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#   * Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#   * Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in
#     the documentation and/or other materials provided with the
#     distribution.
#   * Neither the name of The Qt Company Ltd nor the names of its
#     contributors may be used to endorse or promote products derived
#     from this software without specific prior written permission.
#
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
#
# $QT_END_LICENSE$
#
# SPDX-License-Identifier: BSD-3-Clause

# A die helper function
# $1: The exit message
# $2: The exit code
die() {
    echo "${1}"
    exit ${2}
}

WORKDIR=$(dirname $0)
GENERATOR=${WORKDIR}/../../src/tools/ivigenerator/generate.py
test -x ${GENERATOR} || die "${GENERATOR} does not exists or can't be executed" 1
out_dir=${WORKDIR}
idlfile=qface-ivi-climate
/bin/rm -rf ${out_dir}/frontend/*.{h,cpp,pri}
/bin/rm -rf ${out_dir}/backend_simulator/*.{h,cpp,pri}
${GENERATOR} --format=frontend ${WORKDIR}/${idlfile}.qface ${out_dir}/frontend || die "Generator failed" 1
${GENERATOR} --format=backend_simulator ${WORKDIR}/${idlfile}.qface ${out_dir}/backend_simulator || die "Generator for backend failed" 1
test -d build && /bin/rm -rf build
test -d build && die "Cannot remove existing build folder" 1
mkdir -p build || die "Cannot create build folder" 1
pushd build
project_dir=..
qmake ${project_dir}/${idlfile}.pro || die "Failed to run qmake" 1
make || die "Failed to build" 1
popd

die "All OK" 0
