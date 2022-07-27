import React, { useEffect, useState } from 'react';
import { StyleSheet, View, Modal, TouchableOpacity, FlatList, Image, TouchableWithoutFeedback } from 'react-native';
import { Text } from 'react-native-paper';


const DATA = {
    groupSelectData: {
        title: '选择群类型',
        data: [
            {
                id: 1,
                name: 'Work 工作群'
            },
            {
                id: 2,
                name: 'Public 公开群'
            },
            {
                id: 3,
                name: 'Meeting 会议群'
            },
            {
                id: 4,
                name: 'AVChatRoom 直播群'
            }
        ]
    },
    genderSelectData: {
        title: '性别',
        data: [
            {
                id: 1,
                name: '男'
            },
            {
                id: 2,
                name: '女'
            },
        ]
    },
    friendVerificationSelectData: {
        title: '加好友验证方式',
        data: [
            {
                id: 1,
                name: '允许所有人加我好友'
            },
            {
                id: 2,
                name: '加好友需我确认'
            },
            {
                id: 3,
                name: '不允许所有人加我好友'
            }
        ]
    },
    imageSelectData: {
        title: '头像',
        data: [
            {
                id: 1,
                name: 'image1',
                url: 'https://imgcache.qq.com/operation/dianshi/other/y2QNRn.efeeba9865fac2e6dbbeb8fafcc62a3d3cc1e0a6.png'
            },
            {
                id: 2,
                name: 'image2',
                url: 'https://imgcache.qq.com/operation/dianshi/other/vmuM7b.38bc8a9b478927da82ab0209773b5c8154d81469.jpeg'
            },
            {
                id: 3,
                name: 'image3',
                url: 'https://imgcache.qq.com/operation/dianshi/other/6vQ3U3.216b02313fa2374d2e44283490df64975712be5a.jpeg'
            },
            {
                id: 4,
                name: 'image4',
                url: 'https://imgcache.qq.com/operation/dianshi/other/jYNR3e.909696a6a93a853a056bf71da21f8938a906d6f3.png'
            }
        ]
    },
    prioritySelectData: {
        title: '优先级',
        data: [
            {
                id: 1,
                name: 'V2TIM_PRIORITY_HIGH',
            },
            {
                id: 0,
                name: 'V2TIM_PRIORITY_DEFAULT',
            },
            {
                id: 3,
                name: 'V2TIM_PRIORITY_LOW',
            },
            {
                id: 2,
                name: 'V2TIM_PRIORITY_NORMAL',
            }
        ]
    },
    friendPrioritySelectData: {
        title: '好友类型',
        data: [
            {
                id: 2,
                name: '双向好友',
            },
            {
                id: 1,
                name: '单向好友',
            }
        ]
    },
    refuseFriendSelectData: {
        title: '请求类型',
        data: [
            {
                id: 1,
                name: '别人发给我的加好友请求',
            },
            {
                id: 2,
                name: '我发给别人的加好友请求',
            }
        ]
    },
    groupTypeSelectData: {
        title: '选择加群类型',
        data: [
            {
                id: 2,
                name: 'V2TIM_GROUP_ADD_ANY',
            },
            {
                id: 1,
                name: 'V2TIM_GROUP_ADD_AUTH',
            },
            {
                id: 0,
                name: 'V2TIM_GROUP_ADD_FORBID'
            }
        ]
    },
    groupPrioritySelectData: {
        title: 'filter',
        data: [
            {
                id: 2,
                name: 'V2TIM_GROUP_MEMBER_FILTER_ADMIN',
            },
            {
                id: 0,
                name: 'V2TIM_GROUP_MEMBER_FILTER_ALL',
            },
            {
                id: 4,
                name: 'V2TIM_GROUP_MEMBER_FILTER_COMMON',
            },
            {
                id: 1,
                name: 'V2TIM_GROUP_MEMBER_FILTER_OWNER'
            }
        ]
    },
    roleSelectData: {
        title: '群角色',
        data: [
            {
                id: 300,
                name: 'V2TIM_GROUP_MEMBER_ROLE_ADMIN',
            },
            {
                id: 200,
                name: 'V2TIM_GROUP_MEMBER_ROLE_MEMBER',
            },
            {
                id: 400,
                name: 'V2TIM_GROUP_MEMBER_ROLE_OWNER',
            },
            {
                id: 0,
                name: ' V2TIM_GROUP_MEMBER_UNDEFINED'
            }
        ]
    },
    historytypeSelectData: {
        title: 'type',
        data: [
            {
                id: 1,
                name: 'V2TIM_GET_CLOUD_OLDER_MSG',
            },
            {
                id: 2,
                name: 'V2TIM_GET_CLOUD_NEWER_MSG',
            },
            {
                id: 3,
                name: 'V2TIM_GET_LOCAL_OLDER_MSG',
            },
            {
                id: 4,
                name: 'V2TIM_GET_LOCAL_NEWER_MSG'
            }
        ]
    }
}


const BottomModalComponent = (props) => {
    const { visible, getSelected, getVisible, type } = props
    const [data, setData] = useState<any>([])
    const [title, setTitle] = useState('')
    useEffect(() => {
        switch (type) {
            case 'groupselect':
                setData(DATA.groupSelectData.data)
                setTitle(DATA.groupSelectData.title)
                break;
            case 'genderselect':
                setData(DATA.genderSelectData.data)
                setTitle(DATA.genderSelectData.title)
                break;
            case 'friendverificationselect':
                setData(DATA.friendVerificationSelectData.data)
                setTitle(DATA.friendVerificationSelectData.title)
                break;
            case 'imageselect':
                setData(DATA.imageSelectData.data)
                break;
            case 'priorityselect':
                setData(DATA.prioritySelectData.data)
                setTitle(DATA.prioritySelectData.title)
                break;
            case 'friendpriorityselect':
                setData(DATA.friendPrioritySelectData.data)
                setTitle(DATA.friendPrioritySelectData.title)
                break;
            case 'deletefriendtypeselect':
                setData(DATA.friendPrioritySelectData.data)
                setTitle('删除类型')
                break;
            case 'checkfriendtypeselect':
                setData(DATA.friendPrioritySelectData.data)
                setTitle('检测类型')
                break;
            case 'refusefriendselect':
                setData(DATA.refuseFriendSelectData.data)
                setTitle(DATA.refuseFriendSelectData.title)
                break;
            case 'grouptypeselect':
                setData(DATA.groupTypeSelectData.data)
                setTitle(DATA.groupTypeSelectData.title)
                break;
            case 'grouppriorityselect':
                setData(DATA.groupPrioritySelectData.data)
                setTitle(DATA.groupPrioritySelectData.title)
                break;
            case 'roleselect':
                setData(DATA.roleSelectData.data)
                setTitle(DATA.roleSelectData.title)
                break;
            case 'historytypeselect':
                setData(DATA.historytypeSelectData.data)
                setTitle(DATA.historytypeSelectData.title)
                break;
            default:
                break;
        }
    }, [])
    const selectedHandle = (selected) => {
        switch (type) {
            case 'groupselect':
                getSelected(selected.name.split(' ')[0])
                break;
            case 'genderselect':
                getSelected(selected.name)
                break;
            case 'friendverificationselect':
                getSelected(selected.name)
                break;
            case 'imageselect':
                getSelected(selected.url)
                break;
            case 'prioritynumberselect':
                getSelected(selected.id)
                break;
            default:
                getSelected(selected)
                break;
        }

        getVisible(false)
    }
    const Item = ({ item }) => {
        if (type === 'imageselect')
            return (
                <Image style={styles.renderItemImage} source={{ uri: item.url }} />
                // <Image style={styles.renderItemImage} source={require('../../icon/persongray.png')} />
            )
        else
            return (
                <Text style={styles.renderItemText}>{item.name}</Text>
            )
    }
    const renderItem = ({ item }) => {
        return (
            <TouchableOpacity style={styles.renderItem} onPress={() => { selectedHandle(item) }}>
                <Item item={item} />
            </TouchableOpacity>
        )
    }

    return (
        <Modal
            visible={visible}
            transparent={true}
        >
            <View style={styles.container}>
                <TouchableWithoutFeedback
                    onPress={() => { getVisible(false) }}
                >
                    <View style={styles.other}>
                    </View>
                </TouchableWithoutFeedback>
                <View style={styles.showContainer}>
                    <Text style={styles.title}>{title}</Text>
                    <FlatList
                        style={styles.flatList}
                        data={data}
                        renderItem={renderItem}
                        keyExtractor={(item, index) => item.name + index}
                    />
                    <TouchableOpacity style={styles.cancelContainer} onPress={() => { getVisible(false) }}>
                        <Text style={styles.cancelText}>Cancel</Text>
                    </TouchableOpacity>
                </View>
            </View>
        </Modal>
    )

}

export default BottomModalComponent

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: 'rgba(0,0,0,0.3)',
        justifyContent: 'flex-end'
    },
    showContainer: {
        width: '100%',
        backgroundColor: 'white',
        borderRadius: 10,
        alignItems: 'center'
    },
    title: {
        marginTop: 15
    },
    flatList: {
        marginBottom: 5,
        marginTop: 5,
        width: '100%'
    },
    renderItem: {
        marginTop: 15,
        marginBottom: 15,
        alignItems: 'center',
        width: '100%'
    },
    renderItemText: {
        fontSize: 19,
        fontWeight: '500'
    },
    renderItemImage: {
        width: 45,
        height: 45
    },
    cancelContainer: {
        marginTop: 5,
        marginBottom: 20
    },
    cancelText: {
        fontSize: 19,
        fontWeight: '500',
        color: '#2F80ED'
    },
    other: {
        flex: 1
    }
})