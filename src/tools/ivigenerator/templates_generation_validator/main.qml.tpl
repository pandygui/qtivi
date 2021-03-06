{#
# Copyright (C) 2017 Klaralvdalens Datakonsult AB (KDAB).
# Copyright (C) 2017 Pelagicore AG
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
#}
{% include "generated_comment.cpp.tpl" %}

import QtQuick 2.7
import QtQuick.Window 2.2
import QtQuick.Controls 2.1
import org.example.Example 1.0
import {{module.module_name}} 1.0

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("QtIVI {{module.module_name}}")

    ValidationStatus {
        id: validationStatus
    }

    Column {
        anchors.fill: parent
        anchors.margins: 5

        Text {
            text: validationStatus.errorMessage
        }

{% for iface in module.interfaces %}
        {{iface|qml_type}} {
            id: {{iface|lowerfirst}}
        }

        Text {
            text: "{{iface}}"
        }

        ToolSeparator {
            orientation: Qt.Horizontal
        }

{%     for property in iface.properties %}
        Text {
            text: "{{property|upperfirst}}: " + {{iface|lowerfirst}}.{{property}}
        }
{%     endfor %}

{%     for signal in iface.signals %}
        Connections {
            target: {{iface|lowerfirst}}
            on{{signal|upperfirst}}: {
                print("{{signal}}")
{%       for parameter in signal.parameters %}
                print({{parameter}})
{%       endfor %}
            }
        }
{%     endfor %}

{% endfor %}
    }
}
