import React, { useState } from 'react';
import { Text, View, StyleSheet, TouchableOpacity, } from 'react-native';
import { TencentImSDKPlugin } from 'react-native-tim-js';
import CommonButton from '../commonComponents/CommonButton';
import SDKResponseView from '../sdkResponseView';
import CheckBoxModalComponent from '../commonComponents/CheckboxModalComponent';
import mystylesheet from '../../stylesheets';
const AcceptGroupApplicationComponent = () => {
  const [fromUser, setFromUser] = useState<string>('未选择')
  const [visible, setVisible] = useState<boolean>(false)
  const [info, setInfo] = useState<{
    groupID: string
    toUser: string,
    addTime: number,
  }>()
  const acceptGroupApplication = async () => {
    if (info) {
      console.log(info)
      const res = await TencentImSDKPlugin.v2TIMManager.getGroupManager().acceptGroupApplication(
        info.groupID,
        fromUser,
        info.toUser,
      )
      setRes(res)
    }

  }
  const setInfoHandle = (info) => {
    console.log(info)
    setInfo(info) 
  }
  const [res, setRes] = React.useState<any>({})
  const CodeComponent = () => {
    return (
      res.code !== undefined ?
        (<SDKResponseView codeString={JSON.stringify(res)} />) : null
    );
  }

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
        <CheckBoxModalComponent visible={visible} getVisible={setVisible} getUsername={setFromUser} type={'application'} getApplicationInfo={setInfoHandle} />
      </View>
      <CommonButton handler={() => acceptGroupApplication()} content={'同意群申请'}></CommonButton>
      <CodeComponent></CodeComponent>
    </>
  )
}

export default AcceptGroupApplicationComponent
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