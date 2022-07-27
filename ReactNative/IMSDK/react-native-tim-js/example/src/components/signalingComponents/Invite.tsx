import React, { useState } from 'react';
import { View, StyleSheet, TouchableOpacity, Text, Switch } from 'react-native';
import { TencentImSDKPlugin } from 'react-native-tim-js';
import CommonButton from '../commonComponents/CommonButton';
import SDKResponseView from '../sdkResponseView';
import CheckBoxModalComponent from '../commonComponents/CheckboxModalComponent';
import UserInputComponent from '../commonComponents/UserInputComponent';
import mystylesheet from '../../stylesheets';
const InviteComponent = () => {
  const [res, setRes] = useState<any>({});
  const [isonlineUserOnly, setIsonlineUserOnly] = useState<boolean>(false);
  const [input, setInput] = useState<string>('');
  const receiveOnlineUserstoggle = () => setIsonlineUserOnly(previousState => !previousState);
  const [inviteeID, setInviteeID] = useState<string>('未选择')

  const invite = async () => {
    const res = await TencentImSDKPlugin.v2TIMManager.getSignalingManager().invite(inviteeID, input)
    setRes(res)
  };

  const CodeComponent = () => {
    return res.code !== undefined ? (
      <SDKResponseView codeString={JSON.stringify(res, null, 2)} />
    ) : null;
  };

  const FriendSelectComponent = () => {
    const [visible, setVisible] = useState<boolean>(false)
    return (
      <>
        <View style={styles.selectContainer}>
          <TouchableOpacity onPress={() => { setVisible(true) }}>
            <View style={mystylesheet.buttonView}>
              <Text style={mystylesheet.buttonText}>选择好友</Text>
            </View>
          </TouchableOpacity>
          <Text style={mystylesheet.selectedText}>{inviteeID}</Text>
        </View>
        <CheckBoxModalComponent visible={visible} getVisible={setVisible} getUsername={setInviteeID} type={'friend'} />
      </>
    )
  }
  return (
    <View style={{height: '100%'}}>
      <View style={styles.container}>
        <UserInputComponent content={'发送文本'} placeholdercontent={'发送文本'} getContent={setInput} />
      </View>
      <FriendSelectComponent />
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
        handler={() => { invite() }}
        content={'邀请'}
      ></CommonButton>
      <CodeComponent></CodeComponent>
    </View>
  );
};

export default InviteComponent;
const styles = StyleSheet.create({
  container: {
    margin: 10
  },
  selectContainer: {
    flexDirection: 'row',
    marginLeft: 10,
    marginRight: 10
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
})