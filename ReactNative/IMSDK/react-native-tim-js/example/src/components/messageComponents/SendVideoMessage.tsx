import React, { useState } from 'react';
import {
    View,
    StyleSheet,
    TouchableOpacity,
    Text,
    Switch,
    Image,
} from 'react-native';
import { TencentImSDKPlugin } from 'react-native-tim-js';
import DocumentPicker, { isInProgress } from 'react-native-document-picker';
import { launchImageLibrary } from 'react-native-image-picker';
// import * as VideoThumbnails from 'expo-video-thumbnails';
import CommonButton from '../commonComponents/CommonButton';
import SDKResponseView from '../sdkResponseView';
import CheckBoxModalComponent from '../commonComponents/CheckboxModalComponent';
import BottomModalComponent from '../commonComponents/BottomModalComponent';
import mystylesheet from '../../stylesheets';

const SendVideoMessageComponent = () => {
    const [res, setRes] = useState<any>({});
    const [userName, setUserName] = useState<string>('未选择');
    const [groupName, setGroupName] = useState<string>('未选择');
    const [priority, setPriority] = useState<string>('');
    const [isonlineUserOnly, setIsonlineUserOnly] = useState(false);
    const [isExcludedFromUnreadCount, setIsExcludedFromUnreadCount] =
        useState(false);
    const receiveOnlineUserstoggle = () =>
        setIsonlineUserOnly((previousState) => !previousState);
    const unreadCounttoggle = () =>
        setIsExcludedFromUnreadCount((previousState) => !previousState);
    const [videourl, setVideourl] = useState<string | null>();
    const [snapShotPath] = useState<string>();

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
                        id: id,
                        receiver: receiver,
                        groupID: groupID,
                        onlineUserOnly: isonlineUserOnly,
                        isExcludedFromUnreadCount: isExcludedFromUnreadCount,
                    });
                setRes(res);
            }
        }
    };

    const CodeComponent = () => {
        return res.code !== undefined ? (
            <SDKResponseView codeString={JSON.stringify(res)} />
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
                console.warn('cancelled');
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
                const pickerRes = await launchImageLibrary({
                    mediaType: 'video',
                });
                if (pickerRes.assets) {
                    setVideourl(pickerRes.assets[0]?.uri);
                    // setVideoName(pickerRes.assets[0]?.fileName);
                    if (pickerRes.assets[0]?.uri) {
                        // const res = await VideoThumbnails.getThumbnailAsync(
                        //     pickerRes.assets[0]?.uri
                        // );
                        // console.log(res);
                        // setSnapshotPath(res.uri);
                    }
                }
            } catch (e) {
                handleError(e);
            }
        };

        return (
            <View style={styles.friendgroupview}>
                <View style={styles.selectContainer}>
                    <TouchableOpacity onPress={selectImageHandle}>
                        <View style={styles.buttonView}>
                            <Text style={styles.buttonText}>选择视频</Text>
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
                        <View style={styles.buttonView}>
                            <Text style={styles.buttonText}>选择好友</Text>
                        </View>
                    </TouchableOpacity>
                    <Text style={styles.selectedText}>{userName}</Text>
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
                        <View style={styles.buttonView}>
                            <Text style={styles.buttonText}>选择群组</Text>
                        </View>
                    </TouchableOpacity>
                    <Text style={styles.selectedText}>{groupName}</Text>
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
        };
        return (
            <>
                <View style={styles.userInputcontainer}>
                    <View style={mystylesheet.itemContainergray}>
                        <View style={styles.selectView}>
                            <TouchableOpacity
                                onPress={() => {
                                    setVisible(true);
                                }}
                            >
                                <View style={styles.buttonView}>
                                    <Text style={styles.buttonText}>
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
        <>
            <VideoComponent />
            <FriendComponent />
            <GroupComponent />
            <PriorityComponent />
            <View style={styles.switchcontainer}>
                <Text style={styles.switchtext}>是否仅在线用户接受到消息</Text>
                <Switch
                    trackColor={{ false: '#c0c0c0', true: '#81b0ff' }}
                    thumbColor={isonlineUserOnly ? '#2F80ED' : '#f4f3f4'}
                    ios_backgroundColor="#3e3e3e"
                    onValueChange={receiveOnlineUserstoggle}
                    value={isonlineUserOnly}
                />
            </View>
            <View style={styles.switchcontainer}>
                <Text style={styles.switchtext}>发送消息是否不计入未读数</Text>
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
        </>
    );
};

export default SendVideoMessageComponent;

const styles = StyleSheet.create({
    userInputcontainer: {
        marginLeft: 10,
        marginRight: 10,
        justifyContent: 'center',
    },
    selectContainer: {
        flexDirection: 'row',
    },
    selectedText: {
        marginLeft: 10,
        fontSize: 14,
        textAlignVertical: 'center',
        lineHeight: 35,
    },
    buttonView: {
        backgroundColor: '#2F80ED',
        borderRadius: 3,
        width: 100,
        height: 35,
        marginLeft: 10,
    },
    buttonText: {
        color: '#FFFFFF',
        fontSize: 14,
        textAlign: 'center',
        textAlignVertical: 'center',
        lineHeight: 35,
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
    switchcontainer: {
        flexDirection: 'row',
        margin: 10,
    },
    switchtext: {
        lineHeight: 35,
        marginRight: 8,
    },
    selectedimg: {
        width: 35,
        height: 35,
        marginLeft: 10,
    },
});
