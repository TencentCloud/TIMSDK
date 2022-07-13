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
    const { getSelect, type, getType, groupID } = props
    const setSelectedHandler = (val) => {
        if (getType) {
            getType(val.type)
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
                GetMemberList()
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

    const GetMemberList = async () => {
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

    return (
        <BouncyCheckboxGroup
            data={checkboxData}
            style={{ flexDirection: 'column'}}
            onChange={(selectedItem: ICheckboxButton) => {
                if (selectedItem.text) setSelectedHandler(selectedItem)
            }}
        />

    )

}

export default CheckboxComponent