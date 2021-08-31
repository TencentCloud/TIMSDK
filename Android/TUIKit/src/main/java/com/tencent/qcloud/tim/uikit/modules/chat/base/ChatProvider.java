package com.tencent.qcloud.tim.uikit.modules.chat.base;

import com.tencent.imsdk.v2.V2TIMMessageReceipt;
import com.tencent.qcloud.tim.uikit.modules.chat.interfaces.IChatProvider;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.MessageLayout;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.MessageListAdapter;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfo;

import java.util.ArrayList;
import java.util.List;


public class ChatProvider implements IChatProvider {

    private ArrayList<MessageInfo> mDataSource = new ArrayList();

    private MessageListAdapter mAdapter;
    private TypingListener mTypingListener;

    @Override
    public List<MessageInfo> getDataSource() {
        return mDataSource;
    }

    @Override
    public boolean addMessageList(List<MessageInfo> msgs, boolean front) {
        List<MessageInfo> list = new ArrayList<>();
        for (MessageInfo info : msgs) {
            if (checkExistPosition(info) >= 0) {
                continue;
            }
            list.add(info);
        }
        boolean flag;
        if (front) {
            flag = mDataSource.addAll(0, list);
            updateAdapter(MessageLayout.DATA_CHANGE_TYPE_ADD_FRONT, list.size());
        } else {
            flag = mDataSource.addAll(list);
            updateAdapter(MessageLayout.DATA_CHANGE_TYPE_ADD_BACK, list.size());
        }
        return flag;
    }

    private int checkExistPosition(MessageInfo msg) {
        if (msg != null) {
            String msgId = msg.getId();
            for (int i = mDataSource.size() - 1; i >= 0; i--) {
                if (mDataSource.get(i).getId().equals(msgId)) {
                    return i;
                }
            }
        }
        return -1;
    }

    @Override
    public boolean deleteMessageList(List<MessageInfo> messages) {
        for (int i = mDataSource.size() -1; i >= 0 ; i--) {
            for (int j = messages.size() -1; j >= 0; j--) {
                if (mDataSource.get(i).getId().equals(messages.get(j).getId())) {
                    mDataSource.remove(i);
                    updateAdapter(MessageLayout.DATA_CHANGE_TYPE_DELETE, i);
                    break;
                }
            }
        }
        return false;
    }

    @Override
    public boolean updateMessageList(List<MessageInfo> messages) {
        return false;
    }

    public boolean addMessageInfo(MessageInfo msg, boolean isModifiedByServer) {
        if (msg == null) {
            updateAdapter(MessageLayout.DATA_CHANGE_TYPE_LOAD, 0);
            return true;
        }

        int existPosition = checkExistPosition(msg);
        if (existPosition >= 0 && isModifiedByServer) {
            // 被服务器修改了消息内容，消息会通过 onRecvMessageModified 回调出来，因此需要替换原有消息
            mDataSource.set(existPosition, msg);
            updateAdapter(MessageLayout.DATA_CHANGE_TYPE_REFRESH, 1);
        } else {
            mDataSource.add(msg);
            updateAdapter(MessageLayout.DATA_CHANGE_TYPE_NEW_MESSAGE, 1);
        }
        return true;
    }

    public boolean deleteMessageInfo(MessageInfo msg) {
        for (int i = 0; i < mDataSource.size(); i++) {
            if (mDataSource.get(i).getId().equals(msg.getId())) {
                mDataSource.remove(i);
                updateAdapter(MessageLayout.DATA_CHANGE_TYPE_DELETE, -1);
                return true;
            }
        }
        return false;
    }

    public boolean resendMessageInfo(MessageInfo message) {
        boolean found = false;
        for (int i = 0; i < mDataSource.size(); i++) {
            if (mDataSource.get(i).getId().equals(message.getId())) {
                mDataSource.remove(i);
                found = true;
                break;
            }
        }
        if (!found) {
            return false;
        }
        return addMessageInfo(message, false);
    }

    public boolean updateMessageInfo(MessageInfo message) {
        for (int i = 0; i < mDataSource.size(); i++) {
            if (mDataSource.get(i).getId().equals(message.getId())) {
                mDataSource.remove(i);
                mDataSource.add(i, message);
                updateAdapter(MessageLayout.DATA_CHANGE_TYPE_UPDATE, i);
                return true;
            }
        }
        return false;
    }

    public boolean updateTIMMessageStatus(MessageInfo message) {
        for (int i = 0; i < mDataSource.size(); i++) {
            if (mDataSource.get(i).getId().equals(message.getId())
                    && mDataSource.get(i).getStatus() != message.getStatus()) {
                mDataSource.get(i).setStatus(message.getStatus());
                updateAdapter(MessageLayout.DATA_CHANGE_TYPE_UPDATE, i);
                return true;
            }
        }
        return false;
    }

    public boolean updateMessageRevoked(String msgId) {
        for (int i = 0; i < mDataSource.size(); i++) {
            MessageInfo messageInfo = mDataSource.get(i);
            // 一条包含多条元素的消息，撤回时，会把所有元素都撤回，所以下面的判断即使满足条件也不能return
            if (messageInfo.getId().equals(msgId)) {
                messageInfo.setMsgType(MessageInfo.MSG_STATUS_REVOKE);
                messageInfo.setStatus(MessageInfo.MSG_STATUS_REVOKE);
                updateAdapter(MessageLayout.DATA_CHANGE_TYPE_UPDATE, i);
            }
        }
        return false;
    }

    public void updateReadMessage(V2TIMMessageReceipt max) {
        for (int i = 0; i < mDataSource.size(); i++) {
            MessageInfo messageInfo = mDataSource.get(i);
            if (messageInfo.getMsgTime() > max.getTimestamp()) {
                messageInfo.setPeerRead(false);
            } else if (messageInfo.isPeerRead()) {
                // do nothing
            } else {
                messageInfo.setPeerRead(true);
                updateAdapter(MessageLayout.DATA_CHANGE_TYPE_UPDATE, i);
            }
        }
    }

    public void notifyTyping() {
        if (mTypingListener != null) {
            mTypingListener.onTyping();
        }
    }

    public void setTypingListener(TypingListener l) {
        mTypingListener = l;
    }

    public void remove(int index) {
        mDataSource.remove(index);
        updateAdapter(MessageLayout.DATA_CHANGE_TYPE_DELETE, index);
    }

    public void clear() {
        mDataSource.clear();
        updateAdapter(MessageLayout.DATA_CHANGE_TYPE_LOAD, 0);
    }

    private void updateAdapter(int type, int data) {
        if (mAdapter != null) {
            mAdapter.notifyDataSourceChanged(type, data);
        }
    }

    public void setAdapter(MessageListAdapter adapter) {
        this.mAdapter = adapter;
    }

    public interface TypingListener {
        void onTyping();
    }
}
