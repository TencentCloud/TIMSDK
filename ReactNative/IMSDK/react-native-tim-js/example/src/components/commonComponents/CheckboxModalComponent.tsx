import React, { useState,useEffect } from 'react';
import { StyleSheet, View, Modal, TouchableOpacity,ScrollView } from 'react-native';
import { Text } from 'react-native-paper';
import CheckboxComponent from './CheckboxComponent';


const CheckBoxModalComponent = (props) => {
    const { visible, getVisible, getUsername,type,groupID} = props
    const [selected, setSelected] = useState('')
    const [content, setContent] = useState('')
    useEffect(() => {
        switch (type) {
            case 'friend':
                setContent('好友选择')
                break;
            case 'group':
                setContent('群组选择')
                break;
            case 'friendapplication':
                setContent('好友申请选择')
                break;
            case 'groupselect':
                setContent('分组选择')
                break;
            case 'member':
                setContent('选择群成员')
                break;
            default:
                break;
        }

    }, [])
    const closeHandler = (val: boolean) => {
        getVisible(val)
    }

    const confirmHandler = (val: boolean) => {
        console.log(selected)
        getUsername(selected.split(' ')[1])
        getVisible(val)
    }

    return (
        <Modal
            visible={visible}
            transparent={true}
        >
            <View style={styles.container}>
                <View style={styles.showContainer}>
                    <Text style={styles.title}>{content}（单选）</Text>
                    <ScrollView style={styles.listContainer}>
                        <CheckboxComponent getSelect={setSelected} type={type} groupID={groupID}/>
                    </ScrollView>
                    <View style={styles.buttonContainer}>
                        <TouchableOpacity onPress={() => confirmHandler(false)}>
                            <View style={styles.buttonView}>
                                <Text style={styles.buttonText}>确认</Text>
                            </View>
                        </TouchableOpacity>
                        <TouchableOpacity onPress={() => { closeHandler(false) }}>
                            <View style={styles.buttonView}>
                                <Text style={styles.buttonText}>取消</Text>
                            </View>
                        </TouchableOpacity>
                    </View>
                </View>
            </View>
        </Modal>
    )
}
export default CheckBoxModalComponent

const styles = StyleSheet.create({
    container: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        backgroundColor: 'rgba(0,0,0,0.3)',
    },
    showContainer: {
        width: '80%',
        backgroundColor: 'white',
        borderRadius: 5,
    },
    title: {
        fontSize: 20,
        marginTop: 20,
        marginLeft: 18,
        marginBottom: 10,
    },
    listContainer: {
        marginLeft: 15,
        overflow: 'scroll',
        maxHeight: 500     
    },
    buttonContainer: {
        flexDirection: 'row',
        justifyContent: 'flex-end',
    },
    buttonView: {
        backgroundColor: '#2F80ED',
        borderRadius: 3,
        height: 35,
        width: 65,
        marginRight: 8,
        marginBottom: 10
    },
    buttonText: {
        color: '#FFFFFF',
        fontSize: 15,
        textAlign: 'center',
        textAlignVertical: 'center',
        lineHeight: 35
    }
})