import React, { useEffect, useState } from 'react';

import { Modal } from 'tea-component';
import { ShareScreenList } from './ShareScreenList';


export const ShareScreenSelectModal = ({ isShow, onClose, startShare }) => {
    return <Modal
            visible={isShow}
            onClose={onClose}
            disableEscape={false}
            size="auto"
            caption="请选择共享的屏幕"
        >
            <Modal.Body>
                <ShareScreenList startShare={startShare} />
            </Modal.Body>
        </Modal>
};