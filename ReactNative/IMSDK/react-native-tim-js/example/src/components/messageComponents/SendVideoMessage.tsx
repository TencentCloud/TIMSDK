import React, { useState } from 'react';
import { Platform } from 'react-native';
import {
    View,
    StyleSheet,
    TouchableOpacity,
    Text,
    Switch,
    Image,
} from 'react-native';
import { TencentImSDKPlugin } from 'react-native-tim-js';
import DocumentPicker, { isInProgress,types } from 'react-native-document-picker';
import CommonButton from '../commonComponents/CommonButton';
import SDKResponseView from '../sdkResponseView';
import CheckBoxModalComponent from '../commonComponents/CheckboxModalComponent';
import BottomModalComponent from '../commonComponents/BottomModalComponent';
import mystylesheet from '../../stylesheets';
import { createThumbnail } from "react-native-create-thumbnail";

const SendVideoMessageComponent = () => {
    const [res, setRes] = useState<any>({});
    const [userName, setUserName] = useState<string>('未选择');
    const [groupName, setGroupName] = useState<string>('未选择');
    const [priority, setPriority] = useState<string>('V2TIM_PRIORITY_DEFAULT')
    const [priorityEnum,setPriorityEnum] = useState<number>(0)
    const [isonlineUserOnly, setIsonlineUserOnly] = useState(false);
    const [isExcludedFromUnreadCount, setIsExcludedFromUnreadCount] =
        useState(false);
    const receiveOnlineUserstoggle = () =>
        setIsonlineUserOnly((previousState) => !previousState);
    const unreadCounttoggle = () =>
        setIsExcludedFromUnreadCount((previousState) => !previousState);
    const [videourl, setVideourl] = useState<string | null>();
    const [snapShotPath, setSnapshotPath] = useState<string>();

    const sendVideoMessage = async () => {
        if (videourl) {
            const messageRes = await TencentImSDKPlugin.v2TIMManager
                .getMessageManager()
                .createVideoMessage(
                    videourl.replace(/file:\/\//, ''),
                    'mp4',
                    8, // 这里需要用其他服获取视频的时长
                    snapShotPath?.replace(/file:\/\//, '') ?? ''
                );
            const id = messageRes.data?.id;
            console.log(id);
            const receiver = userName === '未选择' ? '' : userName;
            const groupID = groupName === '未选择' ? '' : groupName;
            if (id !== undefined) {
                const res = await TencentImSDKPlugin.v2TIMManager
                    .getMessageManager()
                    .sendMessage({
                        id: id.toString(),
                        receiver: receiver,
                        groupID: groupID,
                        onlineUserOnly: isonlineUserOnly,
                        isExcludedFromUnreadCount: isExcludedFromUnreadCount,
                        priority:priorityEnum
                    });
                setRes(res);
            }
        }
    };

    const CodeComponent = () => {
        return res.code !== undefined ? (
            <SDKResponseView codeString={JSON.stringify(res, null, 2)} />
        ) : null;
    };

    const ImgComponent = () => {
        return snapShotPath ? (
            <Image style={styles.selectedimg} source={{ uri: snapShotPath }} />
        ) : null;
    };

    const VideoComponent = () => {
        const handleError = (e: unknown) => {
            if (DocumentPicker.isCancel(e)) {
            } else if (isInProgress(e)) {
                console.log(
                    'multiple pickers were opened, only the last will be considered'
                );
            } else {
                throw e;
            }
        };
        const selectImageHandle = async () => {
            try {
                const pickerRes = await DocumentPicker.pickSingle({
                    presentationStyle: 'fullScreen',
                    copyTo: 'documentDirectory',
                    type: types.video
                })
                if(Platform.OS==='android'){
                    if ([pickerRes][0].fileCopyUri) {
                        const uri = decodeURIComponent([pickerRes][0].fileCopyUri!)
                        setVideourl(uri.replace(/file:\//, ''))
                    }
                }else{
                    setVideourl([pickerRes][0].uri)
                }
                if ([pickerRes][0].uri) {
                    createThumbnail({
                        url:[pickerRes][0].uri,
                    }).then(response => {
                        setSnapshotPath(response.path);
                    }).catch(err => console.log({ err }))
                }
            } catch (e) {
                handleError(e);
            }
        };

        return (
            <View style={styles.friendgroupview}>
                <View style={styles.selectContainer}>
                    <TouchableOpacity onPress={selectImageHandle}>
                        <View style={mystylesheet.buttonView}>
                            <Text style={mystylesheet.buttonText}>选择视频</Text>
                        </View>
                    </TouchableOpacity>
                    <ImgComponent />
                </View>
            </View>
        );
    };

    const FriendComponent = () => {
        const [visible, setVisible] = useState<boolean>(false);

        return (
            <View style={styles.friendgroupview}>
                <View style={styles.selectContainer}>
                    <TouchableOpacity
                        onPress={() => {
                            setVisible(true);
                        }}
                    >
                        <View style={mystylesheet.buttonView}>
                            <Text style={mystylesheet.buttonText}>选择好友</Text>
                        </View>
                    </TouchableOpacity>
                    <Text style={mystylesheet.selectedText}>{userName}</Text>
                </View>
                <CheckBoxModalComponent
                    visible={visible}
                    getVisible={setVisible}
                    getUsername={setUserName}
                    type={'friend'}
                />
            </View>
        );
    };

    const GroupComponent = () => {
        const [visible, setVisible] = useState<boolean>(false);

        return (
            <View style={styles.friendgroupview}>
                <View style={styles.selectContainer}>
                    <TouchableOpacity
                        onPress={() => {
                            setVisible(true);
                        }}
                    >
                        <View style={mystylesheet.buttonView}>
                            <Text style={mystylesheet.buttonText}>选择群组</Text>
                        </View>
                    </TouchableOpacity>
                    <Text style={mystylesheet.selectedText}>{groupName}</Text>
                </View>
                <CheckBoxModalComponent
                    visible={visible}
                    getVisible={setVisible}
                    getUsername={setGroupName}
                    type={'group'}
                />
            </View>
        );
    };

    const PriorityComponent = () => {
        const [visible, setVisible] = useState(false);
        const getSelectedHandler = (selected) => {
            setPriority(selected.name);
            setPriorityEnum(selected.id)
        };
        return (
            <>
                <View style={mystylesheet.userInputcontainer}>
                    <View style={mystylesheet.itemContainergray}>
                        <View style={styles.selectView}>
                            <TouchableOpacity
                                onPress={() => {
                                    setVisible(true);
                                }}
                            >
                                <View style={mystylesheet.buttonView}>
                                    <Text style={mystylesheet.buttonText}>
                                        选择优先级
                                    </Text>
                                </View>
                            </TouchableOpacity>
                            <Text
                                style={styles.selectText}
                            >{`已选：${priority}`}</Text>
                        </View>
                    </View>
                </View>
                <BottomModalComponent
                    type="priorityselect"
                    visible={visible}
                    getSelected={getSelectedHandler}
                    getVisible={setVisible}
                />
            </>
        );
    };

    return (
        <View style={{height: '100%'}}>
            <VideoComponent />
            <FriendComponent />
            <GroupComponent />
            <PriorityComponent />
            <View style={mystylesheet.switchcontainer}>
                <Text style={mystylesheet.switchtext}>是否仅在线用户接受到消息</Text>
                <Switch
                    trackColor={{ false: '#c0c0c0', true: '#81b0ff' }}
                    thumbColor={isonlineUserOnly ? '#2F80ED' : '#f4f3f4'}
                    ios_backgroundColor="#3e3e3e"
                    onValueChange={receiveOnlineUserstoggle}
                    value={isonlineUserOnly}
                />
            </View>
            <View style={mystylesheet.switchcontainer}>
                <Text style={mystylesheet.switchtext}>发送消息是否不计入未读数</Text>
                <Switch
                    trackColor={{ false: '#c0c0c0', true: '#81b0ff' }}
                    thumbColor={
                        isExcludedFromUnreadCount ? '#2F80ED' : '#f4f3f4'
                    }
                    ios_backgroundColor="#3e3e3e"
                    onValueChange={unreadCounttoggle}
                    value={isExcludedFromUnreadCount}
                />
            </View>
            <CommonButton
                handler={() => {
                    sendVideoMessage();
                }}
                content={'发送视频消息'}
            ></CommonButton>
            <CodeComponent></CodeComponent>
        </View>
    );
};

export default SendVideoMessageComponent;

const styles = StyleSheet.create({
    selectContainer: {
        flexDirection: 'row',
    },
    selectView: {
        flexDirection: 'row',
    },
    selectText: {
        marginLeft: 10,
        lineHeight: 35,
        fontSize: 14,
    },
    friendgroupview: {
        marginLeft: 10,
        marginRight: 10,
        marginTop: 10,
    },
    selectedimg: {
        width: 35,
        height: 35,
        marginLeft: 10,
    },
});
