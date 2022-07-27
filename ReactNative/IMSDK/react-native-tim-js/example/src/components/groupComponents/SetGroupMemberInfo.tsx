import React,{useState} from 'react';
import { Text, View, StyleSheet, TouchableOpacity, Image,FlatList} from 'react-native';
import { TencentImSDKPlugin } from 'react-native-tim-js';
import CommonButton from '../commonComponents/CommonButton';
import SDKResponseView from '../sdkResponseView';
import CheckBoxModalComponent from '../commonComponents/CheckboxModalComponent';
import UserInputComponent from '../commonComponents/UserInputComponent';
import AddFieldModalComponent from '../commonComponents/AddFieldModalComponent';
import mystylesheet from '../../stylesheets';
const map = new Map()
const SetGroupMemberInfoComponent = () => {
    const [groupID, setGroupID] = useState<string>('未选择')
    const [res, setRes] = useState<any>({});
    const [memberName,setMemberName] = useState('');
    const [nameCard,setNameCard] =useState('')
    const setGroupMemberInfo = async()=>{
        const customInfo = [...map.entries()].reduce((customInfo, [key, value]) => (customInfo[key] = value, customInfo), {})
        const res = await TencentImSDKPlugin.v2TIMManager.getGroupManager().setGroupMemberInfo(groupID,memberName,nameCard,customInfo)
        setRes(res)
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
    const MembersSelectComponent = ()=>{
        const [visible, setVisible] = useState<boolean>(false)
        return (
            <View style={styles.container}>
                <View style={styles.selectContainer}>
                    <TouchableOpacity onPress={() => { setVisible(true) }}>
                        <View style={mystylesheet.buttonView}>
                            <Text style={mystylesheet.buttonText}>选择群成员</Text>
                        </View>
                    </TouchableOpacity>
                    <Text style={mystylesheet.selectedText}>{memberName}</Text>
                </View>
                <CheckBoxModalComponent visible={visible} getVisible={setVisible} getUsername={setMemberName} type={'member'} groupID={groupID} />
            </View>
        )
    };
    const AddFieldsComponent = () => {
        const [visible, setVisible] = useState(false)
        const [data, setData] = useState<any>([])
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
                                        <Text style={mystylesheet.buttonText}>添加字段</Text>
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
                <AddFieldModalComponent visible={visible} getVisible={setVisible} getKeyValue={getKeyValueHandler} type={'field'}/>
            </>
        )
    }
    return (
        <View style={{height: '100%'}}>
            <GroupSelectComponent/>
            <MembersSelectComponent/>
            <View style={mystylesheet.userInputcontainer}>
                <UserInputComponent content='nameCard' placeholdercontent='nameCard' getContent={setNameCard} />
            </View>
            <AddFieldsComponent/>
            <CommonButton
                handler={() => setGroupMemberInfo()}
                content={'设置群成员信息'}
            ></CommonButton>
            <CodeComponent></CodeComponent>
        </View>
    );
};

export default SetGroupMemberInfoComponent;

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
    addFieldsButtonContainer: {
        flexDirection: 'row',
    },
    fieldContainer: {
        marginTop: 8,
        marginBottom: 8
    },
    deleteIcon: {
        width: 30,
        height: 30,
        marginRight: 10
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
    userIcon: {
        width: 30,
        height: 30,
        marginRight: 15,
        marginLeft: 15
    },
})