import React, { useState } from 'react';
import { Text, View, StyleSheet, TouchableOpacity, Switch} from 'react-native';
import { TencentImSDKPlugin } from 'react-native-tim-js';
import CommonButton from '../commonComponents/CommonButton';
import SDKResponseView from '../sdkResponseView';
import CheckBoxModalComponent from '../commonComponents/CheckboxModalComponent';
import UserInputComponent from '../commonComponents/UserInputComponent';
import MultiCheckBoxModalComponent from '../commonComponents/MultiCheckboxModalComponent';
const InviteInGroupComponent = () => {
  const [groupID, setGroupID] = useState<string>('未选择')
  const [res, setRes] = useState<any>({});
  const [membersName, setMembersName] = useState('');
  const [memberList, setMemberList] = useState([]);
  const [input, setInput] = useState<string>('');
  const [isonlineUserOnly, setIsonlineUserOnly] = useState<boolean>(false);
  const receiveOnlineUserstoggle = () => setIsonlineUserOnly(previousState => !previousState);
  const inviteInGroupComponent = async () => {
    const res = await TencentImSDKPlugin.v2TIMManager.getSignalingManager().inviteInGroup(groupID,memberList,input)
    setRes(res)
  }

  const getMembersHandler = (memberlist)=>{
    setMembersName('['+memberlist.join(',')+']')
    setMemberList(memberlist)
  }
  const CodeComponent = () => {
    return res.code !== undefined ? (
      <SDKResponseView codeString={JSON.stringify(res)} />
    ) : null;
  };

  const GroupSelectComponent = () => {
    const [visible, setVisible] = useState<boolean>(false)
    return (
      <View style={styles.container}>
        <View style={styles.selectContainer}>
          <TouchableOpacity onPress={() => { setVisible(true) }}>
            <View style={styles.buttonView}>
              <Text style={styles.buttonText}>选择群组</Text>
            </View>
          </TouchableOpacity>
          <Text style={styles.selectedText}>{groupID}</Text>
        </View>
        <CheckBoxModalComponent visible={visible} getVisible={setVisible} getUsername={setGroupID} type={'group'} />
      </View>
    )
  };
  const MembersSelectComponent = () => {
    const [visible, setVisible] = useState<boolean>(false)
    return (
      <View style={styles.container}>
        <View style={styles.selectContainer}>
          <TouchableOpacity onPress={() => { setVisible(true) }}>
            <View style={styles.buttonView}>
              <Text style={styles.buttonText}>选择群成员</Text>
            </View>
          </TouchableOpacity>
          <Text style={styles.selectedText}>{membersName}</Text>
        </View>
        <MultiCheckBoxModalComponent visible={visible} getVisible={setVisible} getUsername={getMembersHandler} type={'member'} groupID={groupID}/>
      </View>
    )
  }
  return (
    <>
      <View style={styles.container}>
        <UserInputComponent content={'发送文本'} placeholdercontent={'发送文本'} getContent={setInput} />
      </View>
      <GroupSelectComponent />
      <MembersSelectComponent />
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
      <CommonButton
        handler={() => inviteInGroupComponent()}
        content={'邀请'}
      ></CommonButton>
      <CodeComponent></CodeComponent>
    </>
  );
};

export default InviteInGroupComponent;

const styles = StyleSheet.create({
  container: {
    marginLeft: 10,
  },
  buttonView: {
    backgroundColor: '#2F80ED',
    borderRadius: 3,
    width: 100,
    height: 35,
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
  selectContainer: {
    flexDirection: 'row',
    marginTop: 10
  },
  selectedText: {
    marginLeft: 10,
    fontSize: 14,
    textAlignVertical: 'center',
    lineHeight: 35
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