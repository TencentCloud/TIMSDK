import React, { useState } from 'react';
import { View, Text, Switch } from 'react-native';
import { TencentImSDKPlugin } from 'react-native-tim-js';
import CommonButton from '../commonComponents/CommonButton';
import SDKResponseView from '../sdkResponseView';
import UserInputComponent from '../commonComponents/UserInputComponent';
import mystylesheet from '../../stylesheets';
const SearchFriendsComponent = () => {
    const searchFriends = async () => {
        const keywordList = keywords.split(' ');
        const res = await TencentImSDKPlugin.v2TIMManager.getFriendshipManager().searchFriends({
            keywordList:keywordList,
            isSearchNickName:isSearchNickname,
            isSearchRemark:isSearchRemark,
            isSearchUserID:isSearchUserID
        })
        setRes(res)
    }

    const [res, setRes] = useState<any>({})
    const [keywords, setKeywords] = useState<string>('')
    const [isSearchNickname, setIssearchNickname] = useState(false);
    const [isSearchRemark, setIsSearchRemark] = useState(false);
    const [isSearchUserID, setIsSearchUserID] = useState(false);
    const searchUserIDtoggle = () => setIsSearchUserID(previousState => !previousState);
    const searchNicknametoggle = () => setIssearchNickname(previousState => !previousState);
    const searchRemarktoggle = () => setIsSearchRemark(previousState => !previousState);
    const CodeComponent = () => {
        return (
            res.code !== undefined ?
                (<SDKResponseView codeString={JSON.stringify(res, null, 2)} />) : null
        );
    }
    return (
        <View style={{height: '100%'}}>
            <View style={mystylesheet.userInputcontainer}>
                <UserInputComponent content='搜索关键词列表，最多支持5个' placeholdercontent='关键词(example只有设置了一个关键词)' getContent={setKeywords} />
            </View>
            <View style={mystylesheet.switchcontainer}>
                <Text style={mystylesheet.switchtext}>设置是否搜索userID</Text>
                <Switch
                    trackColor={{ false: "#c0c0c0", true: "#81b0ff" }}
                    thumbColor={isSearchUserID ? "#2F80ED" : "#f4f3f4"}
                    ios_backgroundColor="#3e3e3e"
                    onValueChange={searchUserIDtoggle}
                    value={isSearchUserID}
                />
            </View>
            <View style={mystylesheet.switchcontainer}>
                <Text style={mystylesheet.switchtext}>设置是否搜索昵称</Text>
                <Switch
                    trackColor={{ false: "#c0c0c0", true: "#81b0ff" }}
                    thumbColor={isSearchNickname ? "#2F80ED" : "#f4f3f4"}
                    ios_backgroundColor="#3e3e3e"
                    onValueChange={searchNicknametoggle}
                    value={isSearchNickname}
                />
            </View>
            <View style={mystylesheet.switchcontainer}>
                <Text style={mystylesheet.switchtext}>设置是否搜索备注</Text>
                <Switch
                    trackColor={{ false: "#c0c0c0", true: "#81b0ff" }}
                    thumbColor={isSearchRemark ? "#2F80ED" : "#f4f3f4"}
                    ios_backgroundColor="#3e3e3e"
                    onValueChange={searchRemarktoggle}
                    value={isSearchRemark}
                />
            </View>
            <CommonButton handler={() => searchFriends()} content={'搜索好友'}></CommonButton>
            <CodeComponent></CodeComponent>
        </View>
    )
}

export default SearchFriendsComponent
