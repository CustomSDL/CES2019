/****************************************************************************
**
** Copyright (C) 2017-2018 Pelagicore AG
** Contact: https://www.qt.io/licensing/
**
** This file is part of the Neptune 3 IVI UI.
**
** $QT_BEGIN_LICENSE:GPL-QTAS$
** Commercial License Usage
** Licensees holding valid commercial Qt Automotive Suite licenses may use
** this file in accordance with the commercial license agreement provided
** with the Software or, alternatively, in accordance with the terms
** contained in a written agreement between you and The Qt Company.  For
** licensing terms and conditions see https://www.qt.io/terms-conditions.
** For further information use the contact form at https://www.qt.io/contact-us.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 3 or (at your option) any later version
** approved by the KDE Free Qt Foundation. The licenses are as published by
** the Free Software Foundation and appearing in the file LICENSE.GPL3
** included in the packaging of this file. Please review the following
** information to ensure the GNU General Public License requirements will
** be met: https://www.gnu.org/licenses/gpl-3.0.html.
**
** $QT_END_LICENSE$
**
** SPDX-License-Identifier: GPL-3.0
**
****************************************************************************/

import application.windows 1.0
import shared.Sizes 1.0
import shared.Style 1.0
import QtWebEngine 1.7
import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

ApplicationCCWindow {
    id: root

    function loadZoomFactor() {
        var url = "file:///opt/neptune3/apps/com.sdl.app/config.json";
        var configFile = new XMLHttpRequest();
        configFile.onreadystatechange = function() {
            if(configFile.readyState == 4 && configFile.status == 200) {
                var jsonObject = JSON.parse(configFile.responseText);
                if(jsonObject.propertyIsEnumerable("zoomFactor")) {
                    hmiView.zoomFactor = jsonObject.zoomFactor;
                    hmiSlider.value = hmiView.zoomFactor;
                }
            }
        }
        configFile.open("GET", url);
        configFile.send();
        return configValue;
    }

    function saveZoomFactor(value) {
        var url = "file:///opt/neptune3/apps/com.sdl.app/config.json";
        var json = {
            "zoomFactor": value
        };
        var str = JSON.stringify(json);
        var request = new XMLHttpRequest();
        request.open("PUT", url, true);
        request.send(str);
    }

    Component.onCompleted: {
        loadZoomFactor()
    }

    ToolBar {
        id:tools
        width: exposedRect.width
        background: null
        y: exposedRect.y
        RowLayout {
            spacing: Sizes.dp(10)
            SwitchDelegate {
                id: zoom
                checked: false
                onToggled: function() {
                    hmiSlider.opacity = zoom.checked ? 1 : 0
                    hmiSlider.enabled = zoom.checked
                }
            }
            Slider {
                id: hmiSlider
                opacity: 0
                enabled: false
                from: 0
                to: 2
                value: 1
                width: exposedRect.width
                onValueChanged: {
                    hmiView.zoomFactor = hmiSlider.value
                    saveZoomFactor(hmiView.zoomFactor)
                }
            }
        }
    }

    WebEngineView {
        id: hmiView
        x: exposedRect.x
        y: tools.y + tools.height
        width: exposedRect.width
        height: exposedRect.height
        url: "file:///opt/sdl/sdl_hmi/index.html"
        webChannel: defaultWebChannel
    }
}
