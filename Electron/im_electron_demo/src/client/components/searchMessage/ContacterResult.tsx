import React from 'react';
import { EmptyResult } from '../emptyResult';
import { useMessageDirect } from '../../utils/react-use/useDirectMsgPage';
import { ResultItem } from './ResultItem';

import './style/contacter-result.scss';

export const ContacterResult = (props) => {
    const { result, onClose } = props;
    const directToMsgPage = useMessageDirect();

    const handleDirect = (profile) => {
        directToMsgPage({
            profile,
            convType: 1,
            beforeDirect: onClose
        })
    };

    return (
        <div className="contacter-result ">
            <EmptyResult isEmpty={result.length === 0} contentText="没有找到相关结果, 请重新输入">
                <div className="customize-scroll-style" style={{height: '100%'}}>
                    {
                        result.map((item, index) => {
                            const { user_profile_face_url, user_profile_nick_name, user_profile_identifier } = item?.friendship_friend_info_get_result_field_info.friend_profile_user_profile;
                            return (
                                <ResultItem
                                    key={index}
                                    faceUrl={user_profile_face_url}
                                    nickName={user_profile_nick_name || user_profile_identifier}
                                    onClick={() => handleDirect(item?.friendship_friend_info_get_result_field_info.friend_profile_user_profile)}
                                />
                            )
                        }
                        )
                    }
                </div>
            </EmptyResult>
        </div>
    )
}