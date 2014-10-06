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
    id: titlebar
    width: 100
    height: 53
    color: imageBack? "#66ffffff" : "#403F3A"

    property int current
    property bool isChat: Telegram.dialogIsChat(current)
    property bool fakes: false

    property DialogItem dialog

    signal clicked()

    onDialogChanged: {
        title.text = dialog.name
        last_time.text = dialog.isChat? qsTr("Chat Room") : formatDate(dialog.lastSeenOnline)
    }

    Connections {
        target: Telegram
        onUserIsTyping: {
            if( chat_id != titlebar.current )
                return

            is_typing.user = user_id
            typing_timer.restart()
        }
        onUserStatusChanged: {
            if( titlebar.current != user_id )
                return

            fakes = true
            fakes = false
        }
    }

    Timer {
        id: typing_timer
        interval: 5000
        repeat: false
        onTriggered: is_typing.user = 0
    }

    MouseArea {
        anchors.fill: parent
        onClicked: titlebar.clicked()
    }

    Column {
        id: column
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right

        Text {
            id: title
            font.pointSize: 15
            anchors.horizontalCenter: column.horizontalCenter
            color: imageBack? "#333333" : "#bbbbbb"
            font.family: globalNormalFontFamily
        }

        Text {
            id: last_time
            font.pointSize: 10
            font.family: globalNormalFontFamily
            anchors.horizontalCenter: parent.horizontalCenter
            color: imageBack? "#333333" : "#bbbbbb"
            visible: !is_typing.visible

            property int fakeCurrent: fakes? 0 : titlebar.current
        }

        Text {
            id: is_typing
            font.pointSize: 10
            font.family: globalNormalFontFamily
            anchors.horizontalCenter: parent.horizontalCenter
            color: imageBack? "#333333" : "#bbbbbb"
            text: user==0? "" : Telegram.dialogTitle(user) + qsTr(" is typing...")
            visible: user!=0

            property int user
        }
    }
}
