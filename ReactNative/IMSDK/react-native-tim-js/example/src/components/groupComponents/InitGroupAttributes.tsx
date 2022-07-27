import React, { useState } from 'react';

import { Text, View, StyleSheet, Image, TouchableOpacity, FlatList } from 'react-native';
import { TencentImSDKPlugin } from 'react-native-tim-js';
import CommonButton from '../commonComponents/CommonButton';
import mystylesheet from '../../stylesheets';
import SDKResponseView from '../sdkResponseView';
import AddFieldModalComponent from '../commonComponents/AddFieldModalComponent';
import UserInputComponent from '../commonComponents/UserInputComponent';

const map = new Map()
const setmap = new Map()
const InitGroupAttributesComponent = () => {
  const [groupID, setGroupID] = useState<string>('')
  const [groupName, setGroupName] = useState<string>('')
  const [visible, setVisible] = useState(false)
  const [data, setData] = useState<any>([])
  const [fieldvisible, setFieldVisible] = useState(false)
  const [setfielddata, setFieldData] = useState<any>([])
  const createGroup = async()=>{
    const res = await TencentImSDKPlugin.v2TIMManager.createGroup(
      groupName,
      'AVChatRoom',
      groupID,
    );
    setRes(res)
  }

  const initGroupAttributes = async () => {
    const customInfo = [...map.entries()].reduce((customInfo, [key, value]) => (customInfo[key] = value, customInfo), {})

    const res = await TencentImSDKPlugin.v2TIMManager.getGroupManager().initGroupAttributes(
      groupID,//直播群名称
      customInfo
    )
    setRes(res)
  }

  const getGroupAttributes = async () => {
    const res = await TencentImSDKPlugin.v2TIMManager.getGroupManager().getGroupAttributes(
      groupID,//直播群名称
    )
    setRes(res)
  }

  const deleteGroupAttributes = async(key) =>{
    const res = await TencentImSDKPlugin.v2TIMManager.getGroupManager().deleteGroupAttributes(
      groupID,//直播群名称
      key
    )
    setRes(res)
  }

  const setGroupAttributes = async() =>{
    updateData()
    setFieldData([])
    const customInfo = [...setmap.entries()].reduce((customInfo, [key, value]) => (customInfo[key] = value, customInfo), {})
    const res = await TencentImSDKPlugin.v2TIMManager.getGroupManager().setGroupAttributes(
      groupID,//直播群名称
      customInfo
    )
    setRes(res)
    setmap.clear()
  }

  const deleteAllGroupAttributes = async ()=>{
    const res = await TencentImSDKPlugin.v2TIMManager.getGroupManager().deleteGroupAttributes(
      groupID,//直播群名称
      []
    )
    setRes(res)
    setFieldData([])
    setmap.clear()
    setData([])
    map.clear()
  }
  const updateData = ()=>{
    setmap.forEach((v,k)=>{
      if(!map.has(k)){
        map.set(k,v)
        setData([...data,{key:k,val:v}])
      }else{
        const dataArr: Object[] = []
        map.set(k, v)
        map.forEach((v, k) => {
          dataArr.push({
            key: k,
            val: v
          })
        })
        setData(dataArr)
      }
    })
  }
  const [res, setRes] = useState<any>({})
  const CodeComponent = () => {
    return (
      res.code !== undefined ?
        (<SDKResponseView codeString={JSON.stringify(res)} />) : null
    );
  }
  const AddFieldsComponent = () => {
    const getKeyValueHandler = (field) => {
      if (!map.has(field.key)) {
        map.set(field.key, field.val)
        setData([...data, { key: field.key, val: field.val }])
      } else {
        const dataArr: Object[] = []
        map.set(field.key, field.val)
        map.forEach((v, k) => {
          dataArr.push({
            key: k,
            val: v
          })
        })
        setData(dataArr)
      }
    }
    const deleteHandler = (key) => {
      deleteGroupAttributes([key])
      map.delete(key)
      const dataArr: Object[] = []
      map.forEach((v, k) => {
        dataArr.push({
          key: k,
          val: v
        })
      })
      setData(dataArr)
      
    }
    const renderItem = ({ item }) => {
      return (
        <View style={styles.fieldItemContainer}>
          <Text style={styles.fieldItemText}>{`${item.key}:${item.val}`}</Text>
          <TouchableOpacity onPress={() => { deleteHandler(item.key) }}>
            <Image style={styles.deleteIcon} source={require('../../icon/delete.png')} />
          </TouchableOpacity>
        </View>
      )
    }
    return (
      <>
        <View style={mystylesheet.userInputcontainer}>
          <View style={styles.containerGray}>
            <View style={styles.addFieldsButtonContainer}>
              <Image style={styles.userIcon} source={require('../../icon/persongray.png')} />
              <View style={styles.selectView}>
                <TouchableOpacity onPress={() => { setVisible(true) }}>
                  <View style={mystylesheet.buttonView}>
                    <Text style={mystylesheet.buttonText}>新建属性</Text>
                  </View>
                </TouchableOpacity>
              </View>
            </View>
            <View style={styles.fieldContainer}>
              <Text>已设置字段</Text>
              <FlatList
                data={data}
                renderItem={renderItem}
                extraData={(item, index) => item.key + index}
              />
            </View>
          </View>
        </View>
        <AddFieldModalComponent visible={visible} getVisible={setVisible} getKeyValue={getKeyValueHandler} type={'attribute'}/>
      </>
    )
  }

  const SetFieldsComponent = () => {
    const getKeyValueHandler = (field) => {
      if (!setmap.has(field.key)) {
        setmap.set(field.key, field.val)
        setFieldData([...setfielddata, { key: field.key, val: field.val }])
      } else {
        const dataArr: Object[] = []
        setmap.set(field.key, field.val)
        setmap.forEach((v, k) => {
          dataArr.push({
            key: k,
            val: v
          })
        })
        setFieldData(dataArr)
      }
    }
    const renderItem = ({ item }) => {
      return (
        <View style={styles.fieldItemContainer}>
          <Text style={styles.fieldItemText}>{`${item.key}:${item.val}`}</Text>
        </View>
      )
    }
    return (
      <>
        <View style={mystylesheet.userInputcontainer}>
          <View style={styles.containerGray}>
            <View style={styles.addFieldsButtonContainer}>
              <Image style={styles.userIcon} source={require('../../icon/persongray.png')} />
              <View style={styles.selectView}>
                <TouchableOpacity onPress={() => { setFieldVisible(true) }}>
                  <View style={mystylesheet.buttonView}>
                    <Text style={mystylesheet.buttonText}>添加属性</Text>
                  </View>
                </TouchableOpacity>
              </View>
            </View>
            <View style={styles.fieldContainer}>
              <Text>已设置字段</Text>
              <FlatList
                data={setfielddata}
                renderItem={renderItem}
                extraData={(item, index) => item.key + index}
              />
            </View>
          </View>
        </View>
        <AddFieldModalComponent visible={fieldvisible} getVisible={setFieldVisible} getKeyValue={getKeyValueHandler} type={'attribute'}/>
      </>
    )
  }
  return (
    <>
      <View style={mystylesheet.userInputcontainer}>
        <UserInputComponent content='群ID' placeholdercontent={'选填（如填，则自定义群ID）'} getContent={setGroupID} />
      </View>
      <View style={mystylesheet.userInputcontainer}>
        <UserInputComponent content='群名称' placeholdercontent={'群名称'} getContent={setGroupName} />
      </View>
      <CommonButton handler={() => createGroup()} content={'创建群'}></CommonButton>
      <AddFieldsComponent />
      <CommonButton handler={() => initGroupAttributes()} content={'初始化群属性'}></CommonButton>
      <CommonButton handler={() => getGroupAttributes()} content={'获得群属性'}></CommonButton> 
      <CommonButton handler={() => deleteAllGroupAttributes()} content={'清除所有群属性'}></CommonButton>       
      <SetFieldsComponent/>
      <CommonButton handler={() => setGroupAttributes()} content={'设置群属性'}></CommonButton>    
      <CodeComponent></CodeComponent>
    </>
  )
}

export default InitGroupAttributesComponent
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
    marginLeft: 10
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