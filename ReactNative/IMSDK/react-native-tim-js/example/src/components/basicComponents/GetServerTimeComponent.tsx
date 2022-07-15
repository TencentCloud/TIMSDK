import * as React from 'react';

import { StyleSheet, Text } from 'react-native';
import { TencentImSDKPlugin } from 'react-native-tim-js';
import SDKResponseView from '../sdkResponseView';
const GetServerTimeComponent = () => {
    const getServerTime = async () => {
        const res = await TencentImSDKPlugin.v2TIMManager.getServerTime();
        setRes(res);
    }
    const [res, setRes] = React.useState<any>({})
    const CodeComponent = () => {
        return (
            res.code !== undefined?
                (<SDKResponseView codeString={JSON.stringify(res)} />) : null
        );
    }
    return (
        <>
            <Text style={styles.detailButton} onPress={() => getServerTime()}>获得服务端时间</Text>
            <CodeComponent></CodeComponent>
        </>
    )
}

export default GetServerTimeComponent

const styles = StyleSheet.create({
    detail: {
        backgroundColor: '#fff',
        borderRadius: 3,
        margin: 10,
    },
    detailButton: {
        backgroundColor: '#2F80ED',
        color: '#fff',
        margin: 10,
        fontSize: 14,
        lineHeight: 35,
        height: 35,
        textAlign: 'center'
    },
});