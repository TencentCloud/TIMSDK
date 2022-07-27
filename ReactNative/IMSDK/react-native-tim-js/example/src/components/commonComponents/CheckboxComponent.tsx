import React, { useState, useEffect } from 'react'
import BouncyCheckboxGroup, { ICheckboxButton } from 'react-native-bouncy-checkbox-group';
import { TencentImSDKPlugin } from 'react-native-tim-js';


const styles = {
    textStyle: { textDecorationLine: 'none' },
    iconStyle: {
        height: 20,
        width: 20,
        borderRadius: 5,
        borderColor: '#c0c0c0',
        margin: 5
    }
}


const CheckboxComponent = (props) => {
    const [checkboxData, setCheckboxData] = useState<any>([])
    const { getSelect, type, getType, groupID, conversationID, getApplicationInfo } = props

    const setSelectedHandler = (val) => {
        if (val.type) {
            getType(val.type)
        }
        if (val.info) {
            getApplicationInfo(val.info)
        }
        getSelect(val.text)
    }
    useEffect(() => {
        switch (type) {
            case 'friend':
                getFriendList()
                break;
            case 'group':
                getGroupList()
                break;
            case 'friendapplication':
                getFriendApplicationList()
                break;
            case 'selectgroup':
                getFriendGroupList()
                break;
            case 'member':
                getMemberList()
                break;
            case 'conversation':
                getConversationList()
                break;
            case 'message':
                getMessageList()
                break;
            case 'application':
                getApplicationList()
                break;
            default:
                break;
        }

    }, [])

    const getFriendList = async () => {
        const res = await TencentImSDKPlugin.v2TIMManager.getFriendshipManager().getFriendList()
        const dataArr: any = []
        if (res.code === 0) {
            res.data?.forEach((val, index) => {
                dataArr.push({
                    id: index,
                    text: `userID: ${val.userID}`,
                    fillColor: '#2F80ED',
                    unfillColor: 'white',
                    textStyle: styles.textStyle,
                    iconStyle: styles.iconStyle
                })
            })
        }
        setCheckboxData(dataArr)

    }

    const getGroupList = async () => {
        const res = await TencentImSDKPlugin.v2TIMManager.getGroupManager().getJoinedGroupList()
        const dataArr: any = []
        if (res.code === 0) {
            res.data?.forEach((val, index) => {
                dataArr.push({
                    id: index,
                    text: `groupID: ${val.groupID}`,
                    fillColor: '#2F80ED',
                    unfillColor: 'white',
                    textStyle: styles.textStyle,
                    iconStyle: styles.iconStyle
                })
            })
        }
        setCheckboxData(dataArr)

    }

    const getFriendApplicationList = async () => {
        const res = await TencentImSDKPlugin.v2TIMManager.getFriendshipManager().getFriendApplicationList()
        const dataArr: any = []
        if (res.code === 0) {
            res.data?.friendApplicationList?.forEach((val, index) => {
                dataArr.push({
                    id: index,
                    text: `userID: ${val.userID}`,
                    fillColor: '#2F80ED',
                    unfillColor: 'white',
                    textStyle: styles.textStyle,
                    iconStyle: styles.iconStyle,
                    type: val.type
                })
            })
        }
        setCheckboxData(dataArr)
    }

    const getFriendGroupList = async () => {
        const res = await TencentImSDKPlugin.v2TIMManager.getFriendshipManager().getFriendGroups()
        const dataArr: any = []
        console.log(res)
        if (res.code === 0) {
            res.data?.forEach((val, index) => {
                dataArr.push({
                    id: index,
                    text: `name: ${val.name}`,
                    fillColor: '#2F80ED',
                    unfillColor: 'white',
                    textStyle: styles.textStyle,
                    iconStyle: styles.iconStyle,
                })
            })
        }
        setCheckboxData(dataArr)
    }

    const getMemberList = async () => {

        const res = await TencentImSDKPlugin.v2TIMManager.getGroupManager().getGroupMemberList(groupID, 0, '0')
        console.log(res)
        const dataArr: any = []
        if (res.code === 0) {
            res.data?.memberInfoList?.forEach((val, index) => {
                dataArr.push({
                    id: index,
                    text: `memberID: ${val.userID}`,
                    fillColor: '#2F80ED',
                    unfillColor: 'white',
                    textStyle: styles.textStyle,
                    iconStyle: styles.iconStyle,
                })
            })
        }
        setCheckboxData(dataArr)
    }

    const getConversationList = async () => {
        const dataArr: any = []
        const res = await TencentImSDKPlugin.v2TIMManager.getConversationManager().getConversationList(100, '0')
        if (res.code === 0) {
            res.data?.conversationList?.forEach((val, index) => {
                dataArr.push({
                    id: index,
                    text: `ID: ${val.conversationID}`,
                    fillColor: '#2F80ED',
                    unfillColor: 'white',
                    textStyle: styles.textStyle,
                    iconStyle: styles.iconStyle,
                })
            })
        }
        setCheckboxData(dataArr)
    }

    const getMessageList = async () => {
        const dataArr: any = []
        const res = await TencentImSDKPlugin.v2TIMManager.getConversationManager().getConversationListByConversaionIds([conversationID])
        console.log(res)
        if (res.code === 0) {
            res.data?.forEach((val, index) => {
                if (val.lastMessage) {
                    dataArr.push({
                        id: index,
                        text: `messageID: ${val.lastMessage?.msgID}`,
                        fillColor: '#2F80ED',
                        unfillColor: 'white',
                        textStyle: styles.textStyle,
                        iconStyle: styles.iconStyle,
                    })
                }
            })
        }
        setCheckboxData(dataArr)
    }

    const getApplicationList = async () => {
        const dataArr: any = []
        const res = await TencentImSDKPlugin.v2TIMManager.getGroupManager().getGroupApplicationList()
        if (res.code === 0) {
            res.data?.groupApplicationList?.forEach((val, index) => {
                dataArr.push({
                    id: index,
                    text: `groupID:${val.groupID},fromUser: ${val.fromUser}`,
                    fillColor: '#2F80ED',
                    unfillColor: 'white',
                    textStyle: styles.textStyle,
                    iconStyle: styles.iconStyle,
                    info:{
                        groupID:val.groupID,
                        toUser: val.toUser,
                        addTime: val.addTime,
                        type:val.typeƒ
                    }
                })

            })
        }
        setCheckboxData(dataArr)
    }
    return (
        <BouncyCheckboxGroup
            data={checkboxData}
            style={{ flexDirection: 'column' }}
            onChange={(selectedItem: ICheckboxButton) => {
                if (selectedItem.text) setSelectedHandler(selectedItem)
            }}
        />

    )

}

export default CheckboxComponent