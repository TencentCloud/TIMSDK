import React from 'react';
import { Modal,Button } from 'tea-component';

export const EndMeetingConfirmModal = ({isShow, endMeetingCallback, exitMeetingCallback, close}) => {
    return (
        <Modal
            disableCloseIcon
            visible={isShow}
            disableEscape
            caption="结束会议"
        >
            <Modal.Body>
                如果您不想结束会议, 可选择离开会议，我们会随机指定新的主持人.
            </Modal.Body>
            <Modal.Footer>
                <Button type="weak" onClick={close}>
                    取消
                </Button>
                <Button type="primary" onClick={endMeetingCallback}>
                    结束会议
                </Button>
                <Button type="primary" onClick={exitMeetingCallback}>
                    离开会议
                </Button>
            </Modal.Footer>
        </Modal>
    )
}