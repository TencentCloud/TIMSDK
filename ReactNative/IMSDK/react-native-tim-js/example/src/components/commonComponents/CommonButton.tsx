import * as React from 'react';

import { Text, View, StyleSheet } from 'react-native';
import { TouchableOpacity } from 'react-native-gesture-handler';


const CommonButton = ({content,handler}) => {
    return (
        <TouchableOpacity onPress={handler}>
            <View style={styles.commonButtonView}>
                <Text style={styles.commonButtonText}>{content}</Text>
            </View>
        </TouchableOpacity>
    )
}

export default CommonButton

const styles = StyleSheet.create({
    container: {
        margin: 10
    },
    buttonView:{
       backgroundColor: '#2F80ED' ,
       borderRadius:3,
       width:100,
       height:35,
       marginLeft:10
    },
    buttonText:{
        color: '#FFFFFF',
        fontSize:16,
        textAlign:'center',
        textAlignVertical:'center',
        lineHeight:35
    },
    commonButtonView:{
        backgroundColor: '#2F80ED' ,
        borderRadius:3,
        height:35,
        margin:10
    },
    commonButtonText:{
        color: '#FFFFFF',
        fontSize:14,
        textAlign:'center',
        textAlignVertical:'center',
        lineHeight:35
    }
})
