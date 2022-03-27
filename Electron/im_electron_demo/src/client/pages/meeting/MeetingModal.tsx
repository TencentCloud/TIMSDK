import React, { useCallback } from 'react';
import { useSelector, useDispatch } from 'react-redux';
import { Modal } from 'tea-component';
import Store from 'electron-store';

import { useDialog } from "../../utils/react-use/useDialog";
import { openCallWindow } from "../../utils/callWindowTools";

import { MettingModalBody } from "./MettingModalBody";
import { updateCallingStatus } from '../.../../../store/actions/ui';
import { generateGroupId, generateStoreKey } from './meeting-util';
import { getGroupInfoList } from '../../api';

const store = new Store();

export const MeetingModal = (props) => {
    const { dialogRef } = props;
    const dispatch = useDispatch();
    const onClose = () => setShowState(false);
    const [visible, setShowState, defaultValue] = useDialog(dialogRef, {});
    const { type } = defaultValue;
    const { userId, userSig, sdkappId } = useSelector((state: State.RootState) => state.settingConfig);

    const storeMeetingData = async (groupId) => {
        const groupInfo = await getGroupInfoList([groupId]);
        const { group_base_info_group_name } = groupInfo[0];
        const storeKey = generateStoreKey(userId, sdkappId);
        const meetingHistoryList = store.get(storeKey) as {
            list: []
        };
        const storeValue = {
            meetingName: group_base_info_group_name,
            meetingTime: new Date().getTime()
        }
        const storeHistoryList = meetingHistoryList ?
            [storeValue, ...meetingHistoryList.list].slice(0, 4) :
            [storeValue]
        store.set(storeKey, {
            list: storeHistoryList
        });
    }

    const handleSuccess = useCallback((params) => {
        const { meetingId, isVoiceOpen, isVideoOpen } = params;
        const groupId = generateGroupId(meetingId);
        onClose();
        openCallWindow({
            windowType: 'meetingWindow',
            roomId: meetingId,
            isVoiceOpen,
            isVideoOpen,
            userID: userId,
            userSig
        });
        dispatch(updateCallingStatus({
            callingId: meetingId,
            callingType: 0,
            inviteeList: [],
            callType: 0
        }));
        storeMeetingData(groupId);
    }, [type]);

    return <Modal
            disableEscape
            visible={visible} 
            onClose={onClose}
        >
            <Modal.Body>
                <MettingModalBody type={type} onSuccess={handleSuccess} />
            </Modal.Body>
    </Modal>
};