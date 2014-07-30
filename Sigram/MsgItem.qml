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

Item {
    id: item
    width: 100
    height: msg_row.height + itemMargins*4

    property bool messageOut: false
    property int messageUnread: 0
    property int messageUnsent

    property int msgId

    property real itemMargins: 10

    property string messageFromThumbnail
    property string fwdThumbnail

    property string messageFromId
    property string messageFromName
    property string messageFwdName
    property string messageBody
    property string messageDate

    property int messageFwdId

    signal contactSelected( int uid )

    Row {
        id: msg_row
        layoutDirection: item.messageOut? Qt.RightToLeft : Qt.LeftToRight
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 20
        height: msg_column.height
        y: item.itemMargins
        spacing: 10

        ContactImage {
            id: img
            width: 64
            height: width
            smooth: true
            borderColor: "#222222"
            onlineState: true
            source: messageFromThumbnail
        }

        ContactImage {
            id: fwd_img
            width: 64
            height: width
            smooth: true
            borderColor: "#222222"
            onlineState: true
            visible: messageFwdId != 0
            source: fwdThumbnail
        }

        Item {
            height: 10
            width: 20
        }

        Item {
            id: frame
            width: msg_column.width + 2*itemMargins
            height: msg_column.height + 2*itemMargins

            MsgPointCanvas {
                id: msg_point
                fillColor: item.messageOut? "#2DA1B3" : "#CCCCCC"
                x: item.messageOut? frame.width - width/2 : -width/2
                y: img.height/2 - height/2
            }

            Rectangle {
                anchors.fill: parent
                color: item.messageOut? "#33B7CC" : "#E6E6E6"

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.RightButton
                    onClicked: item.showMenu()
                }
            }

            Column {
                id: msg_column
                width: maxWidth
                x: itemMargins
                y: itemMargins
                spacing: 5

                property real maxWidth: Math.max( msg_details.width, Math.max(txt.width,(media.visible?media.width:user.width) ) )

                Text {
                    id: user
                    font.pointSize: 8
                    font.family: globalTextFontFamily
                    text: messageFromName + (messageFwdId==0?"":qsTr(" ,Fwd: ") + messageFwdName)
                    color: item.messageOut? "#ffffff" : "#333333"
                }

                TextEdit {
                    id: txt
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    width: msgWidth>item.width*0.6? item.width*0.6 : msgWidth
                    text: Emojis.textToEmojiText( messageBody )
                    color: item.messageOut? "#ffffff" : "#333333"
                    font.family: globalTextFontFamily
                    font.pointSize: 9
                    textFormat: TextEdit.RichText
                    visible: messageBody.length != 0
                    readOnly: true
                    selectByMouse: true
                    selectionColor: "#0d80ec"
                    onLinkActivated: Gui.openUrl(link)

                    property real msgWidth: Gui.htmlWidth(text)
                }

                MsgMedia {
                    id: media
                    height: 192
                    width: 192
                    msgId: msgId
                    out: item.messageOut
                    visible: !txt.visible
                }

                Row {
                    id: msg_details
                    height: 10
                    anchors.right: parent.right
                    layoutDirection: Qt.RightToLeft
                    spacing: 5

                    Item {
                        id: state_indict
                        width: 12
                        height: 8
                        anchors.verticalCenter: parent.verticalCenter
                        visible: item.messageOut

                        Image {
                            id: seen_indict
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            width: 8
                            height: width
                            visible: item.messageUnread != 1 && item.messageOut
                            source: "files/sent.png"
                            sourceSize: Qt.size(width,height)
                        }

                        Image {
                            id: sent_indict
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            width: 8
                            height: width
                            visible: !item.messageUnsent && item.messageOut
                            source: "files/sent.png"
                            sourceSize: Qt.size(width,height)
                        }

                        Indicator {
                            id: idct
                            anchors.fill: parent
                            indicatorSize: 12
                            visible: !seen_indict.visible && !sent_indict.visible && item.messageOut
                            onVisibleChanged: {
                                if( visible )
                                    start()
                                else
                                    stop()
                            }
                        }
                    }

                    Text {
                        id: msg_date
                        color: item.messageOut? "#ffffff" : "#333333"
                        anchors.verticalCenter: parent.verticalCenter
                        text: messageDate
                    }
                }
            }
        }
    }

    function showMenu() {
        var acts = [ qsTr("Copy"), qsTr("Delete"), qsTr("Forward") ]

        var res = Gui.showMenu( acts )
        switch( res ) {
        case 0:
            if( txt.selectedText.length != 0 )
                txt.copy()
            else
                Gui.copyText( messageBody )
            break;

        case 1:
            tgClient.messagesDeleteMessages(msgId)
            break;

        case 2:
            forwarding = msgId
            forwardingDialog = messageFromId
            forwardingText = messageBody
            break;
        }
    }
}
