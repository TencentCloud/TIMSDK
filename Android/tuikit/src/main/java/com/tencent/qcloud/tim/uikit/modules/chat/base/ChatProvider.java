package com.tencent.qcloud.tim.uikit.modules.chat.base;

import android.text.TextUtils;

import com.tencent.imsdk.TIMMessage;
import com.tencent.imsdk.ext.message.TIMMessageLocator;
import com.tencent.qcloud.tim.uikit.modules.chat.interfaces.IChatProvider;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.MessageLayout;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.MessageListAdapter;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfo;

import java.util.ArrayList;
import java.util.List;


public class ChatProvider implements IChatProvider {

    private ArrayList<MessageInfo> mDataSource = new ArrayList();

    private MessageListAdapter mAdapter;

    @Override
    public List<MessageInfo> getDataSource() {
        return mDataSource;
    }

    @Override
    public boolean addMessageList(List<MessageInfo> msgs, boolean front) {
        List<MessageInfo> messageList = removeExistElement(msgs);
        boolean flag;
        if (front) {
            flag = mDataSource.addAll(0, messageList);
            updateAdapter(MessageLayout.DATA_CHANGE_TYPE_ADD_FRONT, messageList.size());
        } else {
            flag = mDataSource.addAll(messageList);
            updateAdapter(MessageLayout.DATA_CHANGE_TYPE_ADD_BACK, messageList.size());
        }
        return flag;
    }

    private List<MessageInfo> removeExistElement(List<MessageInfo> messages) {
        for (int i = messages.size() - 1; i >= 0; i--) {
            String msgId = messages.get(i).getId();
            for (int j = 0; j < mDataSource.size(); j++) {
                TIMMessage timMessage = mDataSource.get(j).getTIMMessage();
                if (TextUtils.equals(timMessage.getMsgId(), msgId)) {
                    messages.remove(messages.get(i));
                }
            }
        }
        return messages;
    }

    private boolean checkExist(MessageInfo msg) {
        if (msg != null) {
            String msgId = msg.getId();
            for (int i = mDataSource.size() - 1; i >= 0; i--) {
                if (mDataSource.get(i).getTIMMessage().getMsgId().equals(msgId))
                    return true;
            }
        }
        return false;
    }

    @Override
    public boolean deleteMessageList(List<MessageInfo> messages) {
        for (int i = 0; i < mDataSource.size(); i++) {
            for (int j = 0; j < messages.size(); j++) {
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


    public boolean addMessageInfo(MessageInfo msg) {
        if (msg == null) {
            updateAdapter(MessageLayout.DATA_CHANGE_TYPE_LOAD, 0);
            return true;
        }
        if (checkExist(msg))
            return true;
        boolean flag = mDataSource.add(msg);
        updateAdapter(MessageLayout.DATA_CHANGE_TYPE_ADD_BACK, 1);
        return flag;

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

    public boolean updateMessageRevoked(TIMMessageLocator locator) {
        for (int i = 0; i < mDataSource.size(); i++) {
            MessageInfo messageInfo = mDataSource.get(i);
            TIMMessage msg = messageInfo.getTIMMessage();
            if (msg.checkEquals(locator)) {
                messageInfo.setMsgType(MessageInfo.MSG_STATUS_REVOKE);
                messageInfo.setStatus(MessageInfo.MSG_STATUS_REVOKE);
                updateAdapter(MessageLayout.DATA_CHANGE_TYPE_UPDATE, i);
                return true;
            }
        }
        return false;
    }


    public boolean updateMessageRevoked(String msgId) {
        for (int i = 0; i < mDataSource.size(); i++) {
            MessageInfo messageInfo = mDataSource.get(i);
            if (messageInfo.getId().equals(msgId)) {
                messageInfo.setMsgType(MessageInfo.MSG_STATUS_REVOKE);
                messageInfo.setStatus(MessageInfo.MSG_STATUS_REVOKE);
                updateAdapter(MessageLayout.DATA_CHANGE_TYPE_UPDATE, i);
                return true;
            }
        }
        return false;
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

}
