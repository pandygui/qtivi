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

checkFileCount() {
    if [ "$#" -eq 3 ]; then
        FILECOUNT=$(find "." -type f -name "${3}" | wc -l)
    else
        FILECOUNT=$(find "." -type f | wc -l)
    fi
    echo "${1} generated: " ${FILECOUNT}
    test ${FILECOUNT} -eq ${2} || die "Not a correct number of files (${2} expected)" 1
}

QFACE_INIT_SCRIPT="src/tools/ivigenerator/qtivi_qface_virtualenv/bin/activate"
# Load virtualenv where qface is installed to
if [ -f $QFACE_INIT_SCRIPT ]; then
    . $QFACE_INIT_SCRIPT
else
    echo "Warning: Can't find qface virtualenv activate script: $QFACE_INIT_SCRIPT"
fi

WORKDIR=$(dirname $0)
GENERATOR=${WORKDIR}/../../../../src/tools/ivigenerator/generate.py
TEST_FILES=(org.example.echo) # org.example.echo.noprivate)
test -x ${GENERATOR} || die "${GENERATOR} does not exists or can't be executed" 1
for idlfile in "${TEST_FILES[@]}"
do
    echo "Testing '$idlfile' ================"
    idldir=$(echo $idlfile | tr . -)
    out_dir=${WORKDIR}/projects/${idldir}
    /bin/rm -rf ${out_dir}/frontend/*.{h,cpp,pri}
    /bin/rm -rf ${out_dir}/backend_simulator/*.{h,cpp,pri}
    ${GENERATOR} --format=frontend --validation_info=True ${WORKDIR}/${idlfile}.qface ${out_dir}/frontend || die "Generator failed" 1
    ${GENERATOR} --format=backend_simulator ${WORKDIR}/${idlfile}.qface ${out_dir}/backend_simulator || die "Generator for backend failed" 1
    ${GENERATOR} --format=generation_validator ${WORKDIR}/${idlfile}.qface ${out_dir}/ui || die "Generator for validator failed" 1
    test -d build/${idldir} && /bin/rm -rf build/${idldir}
    test -d build/${idldir} && die "Cannot remove existing build folder" 1
    mkdir -p build/${idldir} || die "Cannot create build folder" 1
    pushd build/${idldir}
    project_dir=../../projects/${idldir}
    qmake ${project_dir}/${idldir}-project.pro || die "Failed to run qmake" 1
    make || die "Failed to build" 1
if [[ "$OSTYPE" == "linux-gnu" ]]; then
    OLD_LD_PATH=$LD_LIBRARY_PATH
    export LD_LIBRARY_PATH=./out:$LD_LIBRARY_PATH
    #./out/ui || die "Test failed"
    export LD_LIBRARY_PATH=${OLD_LD_PATH}

elif [[ "$OSTYPE" == "darwin"* ]]; then
    OLD_DYLD_PATH=$DYLD_LIBRARY_PATH
    export DYLD_LIBRARY_PATH=./out:$DYLD_LIBRARY_PATH
    #./out/ui.app/Contents/MacOS/ui || die "Test failed"
    export DYLD_LIBRARY_PATH=${OLD_DYLD_PATH}
fi

    popd
    echo "Done '$idlfile' ================"
done

for idlfile in "${TEST_FILES[@]}"
do
    echo "Testing '$idlfile' backend_simulator ================"
    idldir=$(echo $idlfile | tr . -)
    bdir=${WORKDIR}/projects/${idldir}/backend_simulator
    /bin/rm -rf ${bdir}/*.{h,cpp,pri}
    mkdir -p ${bdir}

    ${GENERATOR} --format=backend_simulator ${WORKDIR}/${idlfile}.qface ${bdir} || die "Generator failed" 1

    pushd ${bdir}
    checkFileCount "Total files" 9
    checkFileCount "Plugins" 2 "*plugin.*"
    checkFileCount "Backends" 4 "*backend.*"
    popd

    echo "Done '$idlfile' ================"
done

# Test control panel generation
for idlfile in "${TEST_FILES[@]}"
do
    echo "Testing '$idlfile' backend_simulator ================"
    idldir=$(echo $idlfile | tr . -)
    bdir=${WORKDIR}/projects/${idldir}/control_panel
    /bin/rm -rf ${bdir}/*.{h,cpp,pri}
    mkdir -p ${bdir}

    ${GENERATOR} --format=control_panel ${WORKDIR}/${idlfile}.qface ${bdir} || die "Generator failed" 1
    test -d build/${idldir} && /bin/rm -rf build/${idldir}
    test -d build/${idldir} && die "Cannot remove existing build folder" 1
    mkdir -p build/${idldir} || die "Cannot create build folder" 1
    pushd build/${idldir}
    project_dir=../../projects/${idldir}/control_panel
    qmake ${project_dir}/control_panel.pro || die "Failed to run qmake" 1
    make || die "Failed to build" 1
if [[ "$OSTYPE" == "linux-gnu" ]]; then
    OLD_LD_PATH=$LD_LIBRARY_PATH
    export LD_LIBRARY_PATH=./out:$LD_LIBRARY_PATH
    ./out/control_panel || die "Test failed"
    export LD_LIBRARY_PATH=${OLD_LD_PATH}

elif [[ "$OSTYPE" == "darwin"* ]]; then
    OLD_DYLD_PATH=$DYLD_LIBRARY_PATH
    export DYLD_LIBRARY_PATH=./out:$DYLD_LIBRARY_PATH
    ./out/control_panel.app/Contents/MacOS/control_panel || die "Test failed"
    export DYLD_LIBRARY_PATH=${OLD_DYLD_PATH}
fi
    popd

    echo "Done '$idlfile' ================"
done

die "All OK" 0
