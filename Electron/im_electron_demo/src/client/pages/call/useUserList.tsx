import { useState, useEffect } from "react";
import { uniqBy } from 'lodash';
import { getUserInfoList } from '../../api';
import event from './event';

interface UserList extends State.userProfile {
    userId: string
    isEntering: boolean,
    isMicOpen: boolean,
    isSpeaking: boolean,
    order: number,
    isOpenCamera: boolean,
}

const splitUserListFunc = (array, count) => {
    const catchArray = [];
    for (let i = 0; i < array.length; i += count) {
        catchArray.push(array.slice(i, i + count));
    }
    return catchArray;
};

const generateTmp = (userId, isEntering = false) => ({
    userId,
    isEntering: isEntering,
    isMicOpen: true,
    isSpeaking: false,
    order: 1,
    isOpenCamera: true,
});

const useUserList = (originUserList) : [Array<Array<UserList>> , (userId: string) => void, (userId: string, userInfo?: State.userProfile) => void, (userId: string, available: boolean) => void, (userIds: Array<string>) => void, (userId: string, available: boolean) => void, (userId: string, available: boolean) => void] => {
    const [userList, setUserList] = useState([]);
    const [splitUserList, setSplitUserList] = useState([]);

    useEffect(() => {
        if(userList.length > 0) {
            setUserList(prev => prev.filter(item => originUserList.includes(item.userId)));
            return;
        }
    }, [originUserList.length]);

    useEffect(() => {
        const initialUserListWithUserInfo = async () => {
            const userInfo = await getUserInfoList(originUserList);
            const userListWithInfo = userInfo.map(item => ({
                ...item,
                ...generateTmp(item.user_profile_identifier)
            }));
            const uniqUserList = uniqBy(userListWithInfo, 'userId');
            setUserList(uniqUserList);
        };
        initialUserListWithUserInfo();
    }, []);

    useEffect(() => {
        const splitUserList = splitUserListFunc(userList, 9);
        setSplitUserList(splitUserList);
        event.emit('userListChange', userList);
    }, [userList])

    const deleteUser = userId => setUserList(prev => prev.filter(item => item.userId !== userId));

    const setUserEntering = (userId, userInfo) => {
        setUserList(prev => {
            if(!userInfo) {
                return prev.map(item => {
                    if(item.userId === userId) {
                        return {
                            ...item,
                            isEntering: true,
                        }
                    }
                    return item;
                });
            }

            return [...prev, {
                ...userInfo,
                ...generateTmp(userId, true)
            }]
            
        })
    }

    const setUserAudioAvailable = (userId, available) => setUserList(prev => prev.map(item => {
        if(item.userId === userId) {
            return {
                ...item,
                isMicOpen: available
            }
        }
        return item;
    }));

    const setUserSpeaking = userIds => setUserList(prev => prev.map(item => {
            return {
                ...item,
                isSpeaking: userIds.includes(item.userId)
            }
    }));

    const setUserOrder = (userId, available) => setUserList(prev => prev.map(item => {
        if(userId === item.userId) {
            return {
                ...item,
                order: available ? 0 :  1
            }
        }

        return item;
    }));

    const setUserCamera = (userId, available) => setUserList(prev => prev.map(item => {
        if(userId === item.userId) {
            return {
                ...item,
                isOpenCamera: available
            }
        }

        return item;
    }));

    return [
        splitUserList, 
        deleteUser, 
        setUserEntering, 
        setUserAudioAvailable, 
        setUserSpeaking, 
        setUserOrder, 
        setUserCamera
    ];
};

export default useUserList;