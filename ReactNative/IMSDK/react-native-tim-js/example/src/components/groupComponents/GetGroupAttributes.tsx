import React, { useState } from 'react';

import { Text, View, StyleSheet, Image, TouchableOpacity, FlatList } from 'react-native';
import { TencentImSDKPlugin } from 'react-native-tim-js';
import CommonButton from '../commonComponents/CommonButton';
import mystylesheet from '../../stylesheets';
import SDKResponseView from '../sdkResponseView';
import AddFieldModalComponent from '../commonComponents/AddFieldModalComponent';

const GetGroupAttributesComponent = () => {
  const initGroupAttributes = async () => {
    const res = await TencentImSDKPlugin.v2TIMManager.getGroupManager().getGroupAttributes(
      'Ka',//直播群名称
    )
    setRes(res)
  }

  const [res, setRes] = useState<any>({})
  const CodeComponent = () => {
    return (
      res.code !== undefined ?
        (<SDKResponseView codeString={JSON.stringify(res)} />) : null
    );
  }
  return (
    <>
      <CommonButton handler={() => initGroupAttributes()} content={'初始化群属性'}></CommonButton>
      <CodeComponent></CodeComponent>
    </>
  )
}

export default GetGroupAttributesComponent
const styles = StyleSheet.create({
  container: {
    marginLeft: 10,
  },
  prioritySelectView: {
    flexDirection: 'row',
  },
  prioritySelectText: {
    marginTop: 5,
    fontSize: 14,
    marginLeft: 5
  },
  selectView: {
    flexDirection: 'row',
  },
  faceurlbuttonView: {
    backgroundColor: '#2F80ED',
    borderRadius: 3,
    width: 130,
    height: 35,
    marginTop: -5,
    marginRight: 10,
  },
  faceurlbuttonText: {
    color: '#FFFFFF',
    fontSize: 14,
    textAlign: 'center',
    textAlignVertical: 'center',
    lineHeight: 35,
  },
  faceUrl: {
    width: 45,
    height: 45,
    marginTop: -10,
  },
  selectContainer: {
    flexDirection: 'row',
    marginTop: 10,
    marginLeft:10
  },
  groupSelectView: {
    flexDirection: 'row',
  },
  groupSelectText: {
    marginTop: 5,
    fontSize: 14,
    marginLeft: 5
  },
  fieldItemContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignContent: 'center'
  },
  fieldItemText: {
    textAlignVertical: 'center',
    lineHeight: 30
  },
  containerGray: {
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: "#c0c0c0",
    paddingTop: 15,
  },
  deleteIcon: {
    width: 30,
    height: 30,
    marginRight: 10
  },
  addFieldsButtonContainer: {
    flexDirection: 'row',
  },
  userIcon: {
    width: 30,
    height: 30,
    marginRight: 15,
    marginLeft: 15
  },
  fieldContainer: {
    marginTop: 8,
    marginBottom: 8
  },
})