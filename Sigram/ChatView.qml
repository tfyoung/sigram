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
import QtGraphicalEffects 1.0
import org.sialan.telegram 1.0
import Telegram 0.1

Rectangle {
    id: chat_view
    width: 100
    height: 62
    clip: true

    property DialogItem currentDialog

    onCurrentDialogChanged: {
        messagesModel.dialogId = currentDialog.id
        messagesModel.peerType = currentDialog.peerType
        messagesModel.updateQuery();
        messagesModel.fetchMore();
        current = currentDialog.id
    }

    property int current: 0
    property int cache

    property real blurRadius: 64

    property alias progressIndicator: indicator
    property bool userConfig: false
    property alias smilies: send_frame.smilies

    property int limit: 20
    property int loadeds: 0

    MessagesModel {
        id: messagesModel
    }

    SortProxyModel {
        id: messagesProxy
        sourceModel: messagesModel
        sortRole: MessagesModel.DateRole
        ascending: false
    }

    StaticObjectHandler {
        id: msg_obj_handler
        createMethod: "createMsgItem"
        createObject: chat_view
    }

    Item {
        id: chat_list_frame
        anchors.fill: parent

        Image {
            id: image_back
            anchors.fill: parent
            sourceSize: Qt.size(width,height)
            fillMode: Image.PreserveAspectCrop
            smooth: true
            source: Gui.background.length != 0? "file://" + Gui.background : ""
        }

        ListView {
            id: chat_list
            anchors.fill: parent
            model: messagesModel

            spacing: 5
            onCountChanged: goToEnd()

            footer: Item {
                width: chat_list.width
                height: send_frame.height + (smilies_frame.visible? smilies_frame.height : 0)
            }

            header: Item {
                width: chat_list.width
                height: title_bar.height
            }

            delegate: Item {
                id: item
                width: chat_list.width
                height: itemObj? itemObj.height : 100

                property variant itemObj
                property int msgId: model.id

                onMsgIdChanged: if(itemObj) refresh()

                Component.onCompleted: {
//                    itemObj = createMsgItem()
                    itemObj = msg_obj_handler.newObject()
                    refresh()
                    item.data = [itemObj]
                    itemObj.anchors.left = item.left
                    itemObj.anchors.right = item.right
                }
                Component.onDestruction: {
                    msg_obj_handler.freeObject(itemObj)
                }

                function refresh() {
                    itemObj.msgId = model.id
                    itemObj.messageBody = text
                    itemObj.messageFromName = fromFirstName + " " + fromLastName
                    itemObj.messageOut = out
                    itemObj.messageUnread = unread
                    itemObj.messageFromId = model.fromId
                    itemObj.messageFromThumbnail = fromThumbnail
                    itemObj.messageDate = formatDate(model.date)
//                    itemObj.messageFwdId = fwdFromId
                    if( model.id == currentDialog.topMessage )
                        itemObj.ding()
                }
            }

            function goToEnd() {
                Gui.call( chat_list, "positionViewAtEnd" )
            }
        }
    }

    NormalWheelScroll {
        flick: chat_list
    }

    PhysicalScrollBar {
        scrollArea: chat_list; width: 8
        anchors.right: parent.right; anchors.top: title_bar.bottom;
        anchors.bottom: smilies_frame.top; color: "#ffffff"
    }

    Item {
        id: footer_blur_frame
        anchors.fill: send_frame
        clip: true

        Mirror {
            width: chat_view.width
            height: chat_view.height
            anchors.bottom: parent.bottom
            source: chat_list_frame
        }
    }

    Item {
        id: header_blur_frame
        anchors.fill: title_bar
        clip: true

        Mirror {
            width: chat_view.width
            height: chat_view.height
            anchors.top: parent.top
            source: chat_list_frame
        }
    }

    Item {
        id: down_blur_frame
        anchors.fill: down_button
        clip: true
        opacity: down_button.opacity

        Mirror {
            width: chat_view.width
            height: chat_view.height
            anchors.bottom: parent.bottom
            anchors.bottomMargin: -send_frame.height
            source: chat_list_frame
        }
    }

    ChatTitleBar {
        id: title_bar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        dialog: chat_view.currentDialog
        onClicked: if(currentDialog) showConfigure(chat_view.currentDialog)

        Indicator {
            id: indicator
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            width: height
        }

        Button {
            id: conf_btn
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            width: height
            normalColor: "#00000000"
            highlightColor: "#66ffffff"
            icon: "files/configure.png"
            iconHeight: 22
            onClicked: showConfigure(Telegram.me)
        }
    }

    Button {
        id: down_button
        anchors.bottom: send_frame.top
        anchors.left: send_frame.left
        anchors.right: send_frame.right
        height: 30
        normalColor: imageBack? "#55ffffff" : "#77ffffff"
        highlightColor: "#994098BF"
        icon: "files/down.png"
        iconHeight: 18
        opacity: chat_list.atYEnd? 0 : 1
        visible: opacity != 0
        onClicked: chat_list.goToEnd()

        Behavior on opacity {
            NumberAnimation{ easing.type: Easing.OutCubic; duration: 400 }
        }
    }

    Item {
        id: smilies_blur_frame
        anchors.fill: smilies_frame
        clip: true
        opacity: smilies_frame.opacity

        Mirror {
            width: chat_view.width
            height: chat_view.height
            anchors.bottom: parent.bottom
            anchors.bottomMargin: -send_frame.height
            source: chat_list_frame
        }
    }

    Smilies {
        id: smilies_frame
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: send_frame.top
        height: chat_view.smilies? 100 : 0
        visible: height > 0
        onSelected: {
            send_frame.textInput.insert( send_frame.textInput.cursorPosition, code )
        }

        onHeightChanged: {
            if( height == 100 )
                chat_list.goToEnd()
            else
            if( height == 0 )
                chat_list.goToEnd()
        }

        Behavior on height {
            NumberAnimation{ easing.type: Easing.OutBack; duration: 300 }
        }
    }

    SendFrame {
        id: send_frame
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        current: currentDialog
    }

    Item {
        id: config_frame
        height: parent.height
        width: userConfig? parent.width : 0
        anchors.right: parent.right
        clip: true
        visible: width != 0

        onVisibleChanged: u_config.focus = visible

        Behavior on width {
            NumberAnimation{ easing.type: Easing.OutBack; duration: 400 }
        }

        Mirror {
            width: chat_view.width
            height: chat_view.height
            anchors.right: parent.right
            anchors.top: parent.top
            source: chat_list_frame
            visible: imageBack
        }

        Rectangle {
            anchors.fill: parent
            color: imageBack? "#88ffffff" : "#d9d9d9"
        }

        UserConfig {
            id: u_config
            width: chat_view.width
            height: chat_view.height
            anchors.left: parent.left
            anchors.top: parent.top
            onBackRequest: userConfig = false
            onChatRequest: main.current = uid
        }
    }

    Component {
        id: msg_component
        Item {
            id: item
            width: chat_list.width
            height: msg_item.visible? msg_item.height : msg_action.height

            property int service: 0
            property bool disableAnims: false

            property alias msgId: msg_item.msgId
            property alias messageBody: msg_item.messageBody
            property alias messageFromName: msg_item.messageFromName
            property alias messageOut: msg_item.messageOut
            property alias messageUnread: msg_item.messageUnread
            property alias messageFromThumbnail: msg_item.messageFromThumbnail
            property alias messageDate: msg_item.messageDate
            property alias messageFwdId: msg_item.messageFwdId
            property alias messageFromId: msg_item.messageFromId

            MsgAction {
                id: msg_action
                anchors.centerIn: parent
                visible: item.service != 0
            }

            MsgItem {
                id: msg_item
                width: parent.width
                visible: item.service == 0
                transformOrigin: Item.Center

                onContactSelected: {
                    u_config.userId = uid
                    chat_view.userConfig = true
                }

                Behavior on y {
                    NumberAnimation{ easing.type: Easing.OutCubic; duration: chat_list.disableAnims? 0 : 600 }
                }
                Behavior on scale {
                    NumberAnimation{ easing.type: Easing.OutCubic; duration: chat_list.disableAnims? 0 : 600 }
                }

                Component.onCompleted: {
                    y = 0
                    scale = 1
                }

                function ding() {
                    if( chat_list.disableAnims )
                        return
                    if( !msg_item.visible )
                        return

                    chat_list.disableAnims = true
                    msg_item.y = msg_item.height
                    msg_item.scale = 1.1
                    chat_list.disableAnims = false
                    msg_item.y = 0
                    msg_item.scale = 1
                }
            }
        }
    }

    function showConfigure( dlg ) {
        u_config.dialog = dlg
        userConfig = true
    }

    function createMsgItem() {
        return msg_component.createObject(chat_view)
    }
}
