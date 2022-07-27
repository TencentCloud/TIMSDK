import React, { useState } from 'react';
import { Text, View, StyleSheet, TouchableOpacity, Switch} from 'react-native';
import { TencentImSDKPlugin } from 'react-native-tim-js';
import CommonButton from '../commonComponents/CommonButton';
import SDKResponseView from '../sdkResponseView';
import CheckBoxModalComponent from '../commonComponents/CheckboxModalComponent';
import UserInputComponent from '../commonComponents/UserInputComponent';
import MultiCheckBoxModalComponent from '../commonComponents/MultiCheckboxModalComponent';
import mystylesheet from '../../stylesheets';
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
      <SDKResponseView codeString={JSON.stringify(res, null, 2)} />
    ) : null;
  };

  const GroupSelectComponent = () => {
    const [visible, setVisible] = useState<boolean>(false)
    return (
      <View style={styles.container}>
        <View style={styles.selectContainer}>
          <TouchableOpacity onPress={() => { setVisible(true) }}>
            <View style={mystylesheet.buttonView}>
              <Text style={mystylesheet.buttonText}>选择群组</Text>
            </View>
          </TouchableOpacity>
          <Text style={mystylesheet.selectedText}>{groupID}</Text>
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
            <View style={mystylesheet.buttonView}>
              <Text style={mystylesheet.buttonText}>选择群成员</Text>
            </View>
          </TouchableOpacity>
          <Text style={mystylesheet.selectedText}>{membersName}</Text>
        </View>
        <MultiCheckBoxModalComponent visible={visible} getVisible={setVisible} getUsername={getMembersHandler} type={'member'} groupID={groupID}/>
      </View>
    )
  }
  return (
    <View style={{height: '100%'}}>
      <View style={styles.container}>
        <UserInputComponent content={'发送文本'} placeholdercontent={'发送文本'} getContent={setInput} />
      </View>
      <GroupSelectComponent />
      <MembersSelectComponent />
      <View style={mystylesheet.switchcontainer}>
        <Text style={mystylesheet.switchtext}>是否仅在线用户接受到消息</Text>
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
    </View>
  );
};

export default InviteInGroupComponent;

const styles = StyleSheet.create({
  container: {
    marginLeft: 10,
  },
  selectView: {
    flexDirection: 'row',
  },
  selectContainer: {
    flexDirection: 'row',
    marginTop: 10
  },

})