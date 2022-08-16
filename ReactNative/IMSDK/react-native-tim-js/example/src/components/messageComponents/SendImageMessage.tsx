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
import CommonButton from '../commonComponents/CommonButton';
import SDKResponseView from '../sdkResponseView';
import CheckBoxModalComponent from '../commonComponents/CheckboxModalComponent';
import BottomModalComponent from '../commonComponents/BottomModalComponent';
import mystylesheet from '../../stylesheets';

const SendImageMessageComponent = () => {
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
    const [imageurl, setImageurl] = useState<string | null>();

    const sendImageMessage = async () => {
        if (imageurl) {
            const messageRes = await TencentImSDKPlugin.v2TIMManager
                .getMessageManager()
                .createImageMessage(imageurl.replace(/file:\/\//, ''));
            const id = messageRes.data?.id;
            console.log(id);
            const receiver = userName === '未选择' ? '' : userName;
            const groupID = groupName === '未选择' ? '' : groupName;
            if (id !== undefined) {
                const res = await TencentImSDKPlugin.v2TIMManager
                    .getMessageManager()
                    .sendMessage({
                        id:id.toString(),
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

    const ImageComponent = () => {
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
                    mediaType: 'photo',
                });
                if (pickerRes.assets) {
                    setImageurl(
                        pickerRes.assets[0]?.uri
                    );
                    console.log(pickerRes.assets[0]?.uri)
                }
            } catch (e) {
                handleError(e);
            }
        };

        const ImgComponent = () => {
            return imageurl ? (
                <Image style={styles.selectedimg} source={{ uri: imageurl }} />
            ) : null;
        };
        return (
            <View style={styles.friendgroupview}>
                <View style={styles.selectContainer}>
                    <TouchableOpacity onPress={selectImageHandle}>
                        <View style={mystylesheet.buttonView}>
                            <Text style={mystylesheet.buttonText}>选择图片</Text>
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
            <ImageComponent />
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
                    sendImageMessage();
                }}
                content={'发送图片消息'}
            ></CommonButton>
            <CodeComponent></CodeComponent>
        </View>
    );
};

export default SendImageMessageComponent;
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
