import React, { useState} from 'react';
import { StyleSheet, View, Modal, TouchableOpacity } from 'react-native';
import { Text } from 'react-native-paper';
import BasicInputComponent from './BasicInputComponent';

const AddFieldModalComponent = (props) => {
    const { visible, getVisible,getKeyValue } = props
    const [fieldKey,setFieldKey] = useState<string>('')
    const [fieldValue,setFieldValue]= useState<string>('')
    const closeHandler = (val: boolean) => {
        getVisible(val)
    }

    const confirmHandler = (val: boolean) => {
        const key = fieldKey
        const value = fieldValue
        getKeyValue({key:key,val:value})
        getVisible(val)
    }

    return (
        <Modal
            visible={visible}
            transparent={true}
        >
            <View style={styles.container}>
                <View style={styles.showContainer}>
                    <View style={styles.inputContainer}>
                        <BasicInputComponent content={'字段名'} placeholdercontent={'请在控制台查看'} getContent={setFieldKey}/>
                        <BasicInputComponent content={'字段值'} placeholdercontent={'字段值'} getContent={setFieldValue}/>
                    </View>
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
export default AddFieldModalComponent

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
        borderRadius: 5
    },
    inputContainer: {
        margin: 20
    },
    title: {
        fontSize: 20,
        marginTop: 20,
        marginLeft: 18,
        marginBottom: 10,
    },
    listContainer: {
        marginLeft: 15,
        maxHeight: 500,
        overflow: 'scroll'
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