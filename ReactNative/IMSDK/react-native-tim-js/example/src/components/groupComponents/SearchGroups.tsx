import React, { useState } from 'react';
import { View, StyleSheet, Text, Switch } from 'react-native';
import { TencentImSDKPlugin } from 'react-native-tim-js';
import CommonButton from '../commonComponents/CommonButton';
import SDKResponseView from '../sdkResponseView';
import UserInputComponent from '../commonComponents/UserInputComponent';
const SearchGroupsComponent = () => {
    const searchGroups = async () => {
        // const keywordList = keywords.split(' ');
        const res = await TencentImSDKPlugin.v2TIMManager.getGroupManager().searchGroups({
            keywordList:['Test'],
            isSearchGroupID:isSearchGroupID,
            isSearchGroupName:isSearchGroupname
        })
        console.log(res)
        setRes(res)
    }

    const [res, setRes] = useState<any>({})
    // const [keywords, setKeywords] = useState<string>('')
    const [isSearchGroupname, setIssearchGroupname] = useState(false);
    const [isSearchGroupID, setIsSearchGroupID] = useState(false);
    const searchGroupIDtoggle = () => setIsSearchGroupID(previousState => !previousState);
    const searchGroupnametoggle = () => setIssearchGroupname(previousState => !previousState);
    const CodeComponent = () => {
        return (
            res.code !== undefined ?
                (<SDKResponseView codeString={JSON.stringify(res)} />) : null
        );
    }
    return (
        <>
            <View style={styles.userInputcontainer}>
                <UserInputComponent content='搜索关键词列表，最多支持5个' placeholdercontent='关键词(example只有设置了一个关键词)' getContent={() => {}} />
            </View>
            <View style={styles.switchcontainer}>
                <Text style={styles.switchtext}>设置是否搜索群ID</Text>
                <Switch
                    trackColor={{ false: "#c0c0c0", true: "#81b0ff" }}
                    thumbColor={isSearchGroupID ? "#2F80ED" : "#f4f3f4"}
                    ios_backgroundColor="#3e3e3e"
                    onValueChange={searchGroupIDtoggle}
                    value={isSearchGroupID}
                />
            </View>
            <View style={styles.switchcontainer}>
                <Text style={styles.switchtext}>设置是否搜索群名称</Text>
                <Switch
                    trackColor={{ false: "#c0c0c0", true: "#81b0ff" }}
                    thumbColor={isSearchGroupname ? "#2F80ED" : "#f4f3f4"}
                    ios_backgroundColor="#3e3e3e"
                    onValueChange={searchGroupnametoggle}
                    value={isSearchGroupname}
                />
            </View>
            <CommonButton handler={() => searchGroups()} content={'搜索Group'}></CommonButton>
            <CodeComponent></CodeComponent>
        </>
    )
}

export default SearchGroupsComponent

const styles = StyleSheet.create({
    userInputcontainer: {
        margin: 10,
        marginBottom: 0,
        marginTop: 1,
        justifyContent: 'center'
    },
    switchcontainer: {
        flexDirection: 'row',
        margin: 10
    },
    switchtext: {
        lineHeight: 35,
        marginRight: 8
    }
})