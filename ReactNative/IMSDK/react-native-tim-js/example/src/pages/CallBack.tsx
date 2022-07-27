import React,{useContext} from 'react';
    import {CallBackContext} from '../useContext';
import SDKResponseView from '../components/sdkResponseView';
import { FlatList,StyleSheet,View } from 'react-native';
import CommonButton from '../components/commonComponents/CommonButton';

const CallBackScreen = () => {
    const {contextData,clearCallbackData} = useContext(CallBackContext)
    const CodeComponent = ({item}) => {
        return (
            <View style={styles.container}>
                <SDKResponseView codeString={JSON.stringify(item.type, null, 4)}/> 
                <SDKResponseView codeString={JSON.stringify(item.data, null, 4)}/> 
            </View>
        );
    }
    return (
        <View style={styles.container}>
            <CommonButton content={'清空监听'} handler={clearCallbackData}/>
            <FlatList
                data={contextData}
                renderItem={CodeComponent}
                keyExtractor={(item,index)=>item.type+index}
            />
        </View>
    )
}

export default CallBackScreen

const styles = StyleSheet.create({
    container:{
        margin:10
    },
  })