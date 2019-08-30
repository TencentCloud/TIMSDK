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
        boolean flag;
        if (front) {
            flag = mDataSource.addAll(0, msgs);
            updateAdapter(MessageLayout.DATA_CHANGE_TYPE_ADD_FRONT, msgs.size());
        } else {
            flag = mDataSource.addAll(msgs);
            updateAdapter(MessageLayout.DATA_CHANGE_TYPE_ADD_BACK, msgs.size());
        }
        return flag;
    }

    private boolean checkExist(MessageInfo msg) {
        if (msg != null) {
            String msgId = msg.getId();
            for (int i = mDataSource.size() - 1; i >= 0; i--) {
                if (mDataSource.get(i).getTIMMessage().getMsgId().equals(msgId)
                        && mDataSource.get(i).getTIMMessage().getMsgUniqueId() == msg.getTIMMessage().getMsgUniqueId()
                        && TextUtils.equals(mDataSource.get(i).getExtra().toString(), msg.getExtra().toString())) {
                    return true;
                }
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

    public boolean addMessageInfoList(List<MessageInfo> msg) {
        if (msg == null || msg.size() == 0) {
            updateAdapter(MessageLayout.DATA_CHANGE_TYPE_LOAD, 0);
            return true;
        }
        List<MessageInfo> list = new ArrayList<>();
        for (MessageInfo info : msg) {
            if (checkExist(info)) {
                continue;
            }
            list.add(info);
        }
        boolean flag = mDataSource.addAll(list);
        updateAdapter(MessageLayout.DATA_CHANGE_TYPE_ADD_BACK, list.size());
        return flag;

    }

    public boolean addMessageInfo(MessageInfo msg) {
        if (msg == null) {
            updateAdapter(MessageLayout.DATA_CHANGE_TYPE_LOAD, 0);
            return true;
        }
        if (checkExist(msg)) {
            return true;
        }
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
            // 一条包含多条元素的消息，撤回时，会把所有元素都撤回，所以下面的判断即使满足条件也不能return
            if (msg.checkEquals(locator)) {
                messageInfo.setMsgType(MessageInfo.MSG_STATUS_REVOKE);
                messageInfo.setStatus(MessageInfo.MSG_STATUS_REVOKE);
                updateAdapter(MessageLayout.DATA_CHANGE_TYPE_UPDATE, i);
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
