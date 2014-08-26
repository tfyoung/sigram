/*
    Copyright (C) 2014 Sialan Labs
    http://labs.sialan.org

    Sigram is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Sigram is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.0
import Telegram 0.1

Rectangle {
    id: item
    width: 100
    height: 62
    color: marea.pressed || selected? "#E65245" : "#ffffff"

    property DialogItem dialogItem
    property bool selected: false

    property alias subText: last_msg.text
    property alias date: dateItem.text

    signal clicked()

    MouseArea {
        id: marea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: item.clicked()
    }

    Row {
        id: row
        anchors.fill: parent
        anchors.margins: 4
        spacing: 4

        ContactImage {
            id: img
            anchors.top: row.top
            anchors.bottom: row.bottom
            width: height
            smooth: true
            source: item.dialogItem.thumbnail
            borderColor: "#ffffff"
            onlineState: dialogItem.userOnline
        }

        Column {
            id: column
            width: row.width - img.width - row.spacing - 4
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4

            Item {
                anchors.left: parent.left
                width: parent.width
                height: txt.height

                Text {
                    id: txt
                    text: dialogItem.name
                    anchors.left: parent.left
                    width: parent.width - dateItem.width - 18
                    font.pointSize: 10
                    font.weight: Font.DemiBold
                    font.family: globalNormalFontFamily
                    horizontalAlignment: Text.AlignLeft
                    maximumLineCount: 1
                    elide: Text.ElideRight
                    wrapMode: Text.WrapAnywhere
                    color: marea.pressed || item.selected? "#ffffff" : "#333333"
                }

                Text {
                    id: dateItem
                    anchors.right: parent.right
                    font.pointSize: 9
                    font.weight: Font.Normal
                    font.family: globalNormalFontFamily
                    color: marea.pressed || item.selected? "#dddddd" : "#555555"
                }
            }

            Item {
                anchors.left: parent.left
                width: parent.width
                height: last_msg.height

                Text {
                    id: last_msg
                    anchors.left: parent.left
                    width: parent.width
                    font.pointSize: 9
                    font.weight: Font.Normal
                    font.family: globalTextFontFamily
                    horizontalAlignment: Text.AlignLeft
                    maximumLineCount: 1
                    elide: Text.ElideRight
                    wrapMode: Text.WrapAnywhere
                    color: marea.pressed || item.selected? "#dddddd" : "#555555"
                }
            }
        }
    }

    UnreadItem {
        anchors.verticalCenter: item.verticalCenter
        anchors.right: item.right
        anchors.margins: 5
        unread: dialogItem.unreadCount
        visible: unread != 0 && !item.selected
    }

    ContactListTools {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 4
        anchors.rightMargin: dateItem.width + 6
        height: 22
        width: 60
        uid: dialogItem.id
        show: marea.containsMouse
    }
}
