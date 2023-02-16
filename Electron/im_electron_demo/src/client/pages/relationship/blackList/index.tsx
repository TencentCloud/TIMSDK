import React, { useEffect, useState } from 'react';
import { Button } from "tea-component";

import { DelayLoading } from "../../../components/delayLoading";
import { EmptyResult } from "../../../components/emptyResult";
import { RelationShipItemLoader } from "../../../components/skeleton";

import { getBlackList, removeFriendsFromBlackList } from '../../../api';
import './index.scss';
import { Avatar } from "../../../components/avatar/avatar";

export const BlackList = () => {
    const [blackList, setBlackList ] = useState([]);
    const [isLoading, setLoading ] = useState(true);

    const getBlackListData = async () => {
        setLoading(true);
        const result = await getBlackList();
        console.log(result);
        setBlackList(result);
        setLoading(false);
    };

    useEffect(() => {
        getBlackListData();
    }, []);

    const removeFromBlackList = async (userId) => {
        const result = await removeFriendsFromBlackList([userId]);
        console.log(result);
        setBlackList(prev => prev.filter(item => item.friend_profile_identifier !== userId));
    }

    return (
        <div className="black-list">
            <div className="black-list__title">
                <span className="black-list__title--icon" />
                <span className="black-list__title--text">黑名单</span>
            </div>
            <div className="black-list__content">
                <DelayLoading delay={100} minDuration={400} isLoading={isLoading} fallback={<RelationShipItemLoader />}>
                    <EmptyResult isEmpty={blackList.length === 0} contentText="暂无黑名单">
                            {
                                blackList.map(item => {
                                    const { friend_profile_user_profile: { user_profile_face_url, user_profile_identifier, user_profile_nick_name } } = item;

                                    return (
                                        <div className="black-list__content-item" key={user_profile_identifier}>
                                            <div className="black-list__content-item--left">
                                                <div className="black-list__content-item--avatar">
                                                    <Avatar url={user_profile_face_url} userID={user_profile_identifier} nickName={user_profile_nick_name} />
                                                </div>
                                                <div className="black-list__content-item--name">
                                                    { user_profile_nick_name || user_profile_identifier}
                                                </div>
                                            </div>
                                            <div className="black-list__content-item--right">
                                                <Button
                                                    onClick={() => removeFromBlackList(user_profile_identifier)} 
                                                    type="link" 
                                                    className="black-list__content-item--remove"
                                                >
                                                    移除
                                                </Button>
                                            </div>
                                        </div>
                                    )
                                })
                            }
                    </EmptyResult>
                </DelayLoading>
            </div>
        </div>
    )
};