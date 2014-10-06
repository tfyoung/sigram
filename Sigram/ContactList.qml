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
import Telegram 0.1

Rectangle {
    id: contact_list
    width: 100
    height: 62
    color: "#ffffff"

    property int current
    property DialogItem currentDialog

    DialogsModel {
        id: dialogsModel
    }

    DialogsProxy {
        id: dialogsProxy
        sourceModel: dialogsModel
        sortRole: DialogsModel.TopMessageDateRole
        ascending: false
    }

    Rectangle {
        id: clist_frame
        anchors.fill: parent

        Indicator {
            id: indicator
            anchors.fill: parent
            source: "files/indicator.png"
            Component.onCompleted: start()
        }

        ListView {
            id: dialogsListView
            anchors.fill: parent
            anchors.rightMargin: 8
            model: dialogsModel
            header: Item{ height: cl_header.height }
            delegate: ContactListItem {
                id: item
                height: 57
                width: dialogsListView.width
                dialogItem: dialogsModel.get(index)
                selected: dialogItem == currentDialog
                subText: model.topMessageFromFirstName + ": " + model.topMessageText + (model.typing ? dialogsModel.whoisTyping + "typing" : "");
                date: formatDate(model.topMessageDate)
                onClicked: {
                    if( forwarding != 0 ) {
                        forwardTo = dialogItem.id
                        return
                    }

                    currentDialog = dialogItem
                }
            }

            section.property: "type"
            section.delegate: Item {
                height: 38
                width: dialogsListView.width

                Image {
                    id: sec_img
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    anchors.leftMargin: 10
                    anchors.bottomMargin: 4
                    width: 14
                    height: 14
                    sourceSize: Qt.size(width,height)
                    source: section==1? "files/favorite.png" : (section==0? "files/love.png" : "files/contact.png")
                }
            }
        }

        NormalWheelScroll {
            flick: dialogsListView
        }

        PhysicalScrollBar {
            scrollArea: dialogsListView; height: dialogsListView.height; width: 8
            anchors.right: parent.right; anchors.top: dialogsListView.top; color: "#333333"
            anchors.topMargin: cl_header.height
        }
    }

    Item {
        id: header_blur_frame
        anchors.fill: cl_header
        clip: true

        Mirror {
            width: clist_frame.width
            height: clist_frame.height
            anchors.top: parent.top
            source: clist_frame
        }
    }

    ContactListHeader {
        id: cl_header
        height: 53
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        onSelected: {
            cnct_change_timer.uid = uid
            cnct_change_timer.restart()
            menu.stop()
        }
        onClose: {
            menu.stop()
        }

        Timer {
            id: cnct_change_timer
            interval: 400
            repeat: false
            onTriggered: {
                contact_list.current = uid
                chatFrame.chatView.progressIndicator.stop()
            }
            property int uid
        }
    }
}
