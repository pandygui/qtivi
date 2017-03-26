#!/bin/bash -e

# Copyright (C) 2017 Klaralvdalens Datakonsult AB (KDAB).
# Contact: https://www.qt.io/licensing/
#
# This file is part of the QtIvi module of the Qt Toolkit.
#
# $QT_BEGIN_LICENSE:LGPL-QTAS$
# Commercial License Usage
# Licensees holding valid commercial Qt Automotive Suite licenses may use
# this file in accordance with the commercial license agreement provided
# with the Software or, alternatively, in accordance with the terms
# contained in a written agreement between you and The Qt Company.  For
# licensing terms and conditions see https://www.qt.io/terms-conditions.
# For further information use the contact form at https://www.qt.io/contact-us.
#
# GNU Lesser General Public License Usage
# Alternatively, this file may be used under the terms of the GNU Lesser
# General Public License version 3 as published by the Free Software
# Foundation and appearing in the file LICENSE.LGPL3 included in the
# packaging of this file. Please review the following information to
# ensure the GNU Lesser General Public License version 3 requirements
# will be met: https://www.gnu.org/licenses/lgpl-3.0.html.
#
# GNU General Public License Usage
# Alternatively, this file may be used under the terms of the GNU
# General Public License version 2.0 or (at your option) the GNU General
# Public license version 3 or any later version approved by the KDE Free
# Qt Foundation. The licenses are as published by the Free Software
# Foundation and appearing in the file LICENSE.GPL2 and LICENSE.GPL3
# included in the packaging of this file. Please review the following
# information to ensure the GNU General Public License requirements will
# be met: https://www.gnu.org/licenses/gpl-2.0.html and
# https://www.gnu.org/licenses/gpl-3.0.html.
#
# $QT_END_LICENSE$
#
# SPDX-License-Identifier: LGPL-3.0

# A die helper function
# $1: The exit message
# $2: The exit code
die() {
    echo "${1}"
    exit ${2}
}

WORKDIR=$(dirname $0)
GENERATOR=${WORKDIR}/../../../src/ivicore/qface/generate.py
test -x ${GENERATOR} || die "${GENERATOR} does not exists or can't be executed" 1
mkdir -p out || die "Cannot create 'out' folder" 1
test -d out/org-example-echo && /bin/rm -rf out/org-example-echo
test -d out/org-example-echo && die "Cannot remove existing output folder" 1
${GENERATOR} --format=cpp ${WORKDIR}/org.example.echo.qface ./out || die "Generator failed" 1
test -d build/org-example-echo && /bin/rm -rf build/org-example-echo
test -d build/org-example-echo && die "Cannot remove existing build folder" 1
mkdir -p build/org-example-echo || die "Cannot create build folder" 1
pushd build/org-example-echo
qmake ../../out/org-example-echo/org-example-echo.pro || die "Failed to run qmake" 1
make || die "Failed to build" 1
popd
die "All OK" 0