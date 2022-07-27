import React, { useState } from 'react';
import { Text, View, StyleSheet, TouchableOpacity, } from 'react-native';
import { TencentImSDKPlugin } from 'react-native-tim-js';
import CommonButton from '../commonComponents/CommonButton';
import SDKResponseView from '../sdkResponseView';
import CheckBoxModalComponent from '../commonComponents/CheckboxModalComponent';
import mystylesheet from '../../stylesheets';

const RefuseGroupApplicationComponent = () => {
  const [groupID, setGroupID] = useState<string>('未选择')
  const [fromUser, setFromUser] = useState<string>('未选择')
  const [type, setType] = useState<number>(0)
  const [addTime, setAddTime] = useState<number>(0)
  const [toUser, setToUser] = useState<string>('')
  const refuseGroupApplication = async () => {
    const res = await TencentImSDKPlugin.v2TIMManager.getGroupManager().refuseGroupApplication(
      groupID,
      fromUser,
      toUser,
      type,
      addTime
    )
    setRes(res)
  }
  const setInfoHandle = (info) => {
    setGroupID(info.groupID)
    setType(info.type)
    setAddTime(info.addTime)
    setToUser(info.toUser)
  }
  const [res, setRes] = React.useState<any>({})
  const CodeComponent = () => {
    return (
      res.code !== undefined ?
        (<SDKResponseView codeString={JSON.stringify(res)} />) : null
    );
  }
  const [visible, setVisible] = useState<boolean>(false)

  return (
    <>
      <View style={styles.container}>
        <View style={styles.selectContainer}>
          <TouchableOpacity onPress={() => { setVisible(true) }}>
            <View style={mystylesheet.buttonView}>
              <Text style={mystylesheet.buttonText}>查看申请人</Text>
            </View>
          </TouchableOpacity>
          <Text style={mystylesheet.selectedText}>{fromUser}</Text>
        </View>
        <CheckBoxModalComponent visible={visible} getVisible={setVisible} getUsername={setFromUser} type={'application'} groupID={groupID} getApplicationInfo={setInfoHandle} />
      </View>
      <CommonButton handler={() => refuseGroupApplication()} content={'拒绝群申请'}></CommonButton>
      <CodeComponent></CodeComponent>
    </>
  )
}

export default RefuseGroupApplicationComponent
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