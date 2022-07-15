import React, { useState } from 'react';
import { View, StyleSheet, TouchableOpacity, Text, Switch} from 'react-native';
import { TencentImSDKPlugin } from 'react-native-tim-js';
import CommonButton from '../commonComponents/CommonButton';
import SDKResponseView from '../sdkResponseView';
import CheckBoxModalComponent from '../commonComponents/CheckboxModalComponent';
import BottomModalComponent from '../commonComponents/BottomModalComponent';
import mystylesheet from '../../stylesheets';
import AudioRecorderPlayer, {
    AVEncoderAudioQualityIOSType,
    AVEncodingOption,
    AudioEncoderAndroidType,
    AudioSet,
    AudioSourceAndroidType,
    RecordBackType,
  } from 'react-native-audio-recorder-player';
const audioRecorderPlayer = new AudioRecorderPlayer();
const SendSoundMessageComponent = () => {
    const [res, setRes] = useState<any>({});
    const [userName, setUserName] = useState<string>('未选择')
    const [groupName, setGroupName] = useState<string>('未选择')
    const [priority, setPriority] = useState<string>('')
    const [isonlineUserOnly, setIsonlineUserOnly] = useState(false);
    const [isExcludedFromUnreadCount, setIsExcludedFromUnreadCount] = useState(false);
    const receiveOnlineUserstoggle = () => setIsonlineUserOnly(previousState => !previousState);
    const unreadCounttoggle = () => setIsExcludedFromUnreadCount(previousState => !previousState);
    const [soundState,setSoundState] = useState<boolean>(false)
    const [fileName, setFileName] = useState<string>('未录制')
    const [soundPath, setSoundPath] = useState<string>('')

    const [recordSecs,setRecordSecs] = useState<number>(0)
    const sendSoundMessage = async () => {
        const messageRes = await TencentImSDKPlugin.v2TIMManager.getMessageManager().createSoundMessage(soundPath,recordSecs)
        console.log(messageRes)
        const id = messageRes.data?.id
        console.log(id)
        const receiver = userName === '未选择' ? '' : userName
        const groupID = groupName === '未选择' ? '' : groupName
        if (id !== undefined) {
            const res = await TencentImSDKPlugin.v2TIMManager.getMessageManager().sendMessage({
                id: id.toString(),
                receiver: receiver,
                groupID: groupID,
                onlineUserOnly: isonlineUserOnly,
                isExcludedFromUnreadCount: isExcludedFromUnreadCount,
            })
            setRes(res)
        }


    };
   

    const CodeComponent = () => {
        return res.code !== undefined ? (
            <SDKResponseView codeString={JSON.stringify(res)} />
        ) : null;
    };

    const soundHandle =()=>{
        setSoundState(!soundState)
        if(!soundState){
            onStartRecord()
        }else{
            onStopRecord()
        }
    }
    const onStartRecord = async () =>{
        const audioSet:AudioSet = {
            AudioEncoderAndroid: AudioEncoderAndroidType.AAC,
            AudioSourceAndroid: AudioSourceAndroidType.MIC,
            AVEncoderAudioQualityKeyIOS: AVEncoderAudioQualityIOSType.high,
            AVNumberOfChannelsKeyIOS: 2,
            AVFormatIDKeyIOS: AVEncodingOption.aac,
          };
        console.log(audioSet)

        const uri = await audioRecorderPlayer.startRecorder(
            undefined,
            audioSet
        )
        audioRecorderPlayer.addRecordBackListener((e:RecordBackType)=>{
            setRecordSecs(e.currentPosition)
        })
        setSoundPath(uri.replace(/file:\/\//, ''))
    }
    const onStopRecord = async ()=>{
        try{
            await audioRecorderPlayer.stopRecorder()
            audioRecorderPlayer.removeRecordBackListener()
            setRecordSecs(0)
            setFileName('finsh')
        }catch(e){
            console.log('stopRecord',e)
        }
    }
    const SoundComponent = () => {
        return (
            <View style={styles.friendgroupview}>
                <View style={styles.selectContainer}>
                    <TouchableOpacity onPress={soundHandle}>
                        <View style={styles.buttonView}>
                            <Text style={styles.buttonText}>{soundState?'结束录音':'开始录音'}</Text>
                        </View>
                    </TouchableOpacity>
                    <Text style={styles.selectedText}>{fileName}</Text>
                </View>
            </View>
        )
    }

    const FriendComponent = () => {
        const [visible, setVisible] = useState<boolean>(false)

        return (
            <View style={styles.friendgroupview}>
                <View style={styles.selectContainer}>
                    <TouchableOpacity onPress={() => { setVisible(true) }}>
                        <View style={styles.buttonView}>
                            <Text style={styles.buttonText}>选择好友</Text>
                        </View>
                    </TouchableOpacity>
                    <Text style={styles.selectedText}>{userName}</Text>
                </View>
                <CheckBoxModalComponent visible={visible} getVisible={setVisible} getUsername={setUserName} type={'friend'} />
            </View>
        )

    };

    const GroupComponent = () => {
        const [visible, setVisible] = useState<boolean>(false)

        return (
            <View style={styles.friendgroupview}>
                <View style={styles.selectContainer}>
                    <TouchableOpacity onPress={() => { setVisible(true) }}>
                        <View style={styles.buttonView}>
                            <Text style={styles.buttonText}>选择群组</Text>
                        </View>
                    </TouchableOpacity>
                    <Text style={styles.selectedText}>{groupName}</Text>
                </View>
                <CheckBoxModalComponent visible={visible} getVisible={setVisible} getUsername={setGroupName} type={'group'} />
            </View>

        )
    };

    const PriorityComponent = () => {
        const [visible, setVisible] = useState(false)
        const getSelectedHandler = (selected) => {
            setPriority(selected.name)
        }
        return (
            <>
                <View style={styles.userInputcontainer}>
                    <View style={mystylesheet.itemContainergray}>
                        <View style={styles.selectView}>
                            <TouchableOpacity onPress={() => { setVisible(true) }}>
                                <View style={styles.buttonView}>
                                    <Text style={styles.buttonText}>选择优先级</Text>
                                </View>
                            </TouchableOpacity>
                            <Text style={styles.selectText}>{`已选：${priority}`}</Text>
                        </View>
                    </View>
                </View>
                <BottomModalComponent type='priorityselect' visible={visible} getSelected={getSelectedHandler} getVisible={setVisible} />
            </>
        )
    };

    return (
        <>
            <SoundComponent />
            <FriendComponent />
            <GroupComponent />
            <PriorityComponent />
            <View style={styles.switchcontainer}>
                <Text style={styles.switchtext}>是否仅在线用户接受到消息</Text>
                <Switch
                    trackColor={{ false: "#c0c0c0", true: "#81b0ff" }}
                    thumbColor={isonlineUserOnly ? "#2F80ED" : "#f4f3f4"}
                    ios_backgroundColor="#3e3e3e"
                    onValueChange={receiveOnlineUserstoggle}
                    value={isonlineUserOnly}
                />
            </View>
            <View style={styles.switchcontainer}>
                <Text style={styles.switchtext}>发送消息是否不计入未读数</Text>
                <Switch
                    trackColor={{ false: "#c0c0c0", true: "#81b0ff" }}
                    thumbColor={isExcludedFromUnreadCount ? "#2F80ED" : "#f4f3f4"}
                    ios_backgroundColor="#3e3e3e"
                    onValueChange={unreadCounttoggle}
                    value={isExcludedFromUnreadCount}
                />
            </View>
            <CommonButton
                handler={() => { sendSoundMessage() }}
                content={'发送录音消息'}
            ></CommonButton>
            <CodeComponent></CodeComponent>
        </>
    );
};

export default SendSoundMessageComponent;
const styles = StyleSheet.create({
    userInputcontainer: {
        marginLeft: 10,
        marginRight: 10,
        justifyContent: 'center'
    },
    selectContainer: {
        flexDirection: 'row'
    },
    selectedText: {
        marginLeft: 10,
        fontSize: 14,
        textAlignVertical: 'center',
        lineHeight: 35
    },
    buttonView: {
        backgroundColor: '#2F80ED',
        borderRadius: 3,
        width: 100,
        height: 35,
        marginLeft: 10
    },
    buttonText: {
        color: '#FFFFFF',
        fontSize: 14,
        textAlign: 'center',
        textAlignVertical: 'center',
        lineHeight: 35
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
        marginTop: 10
    },
    switchcontainer: {
        flexDirection: 'row',
        margin: 10
    },
    switchtext: {
        lineHeight: 35,
        marginRight: 8
    }
})