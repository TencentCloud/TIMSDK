package com.tencent.qcloud.uikit.business.chat.group.model;

import com.tencent.imsdk.TIMMessage;
import com.tencent.imsdk.ext.message.TIMMessageExt;
import com.tencent.imsdk.ext.message.TIMMessageLocator;
import com.tencent.qcloud.uikit.api.chat.IChatAdapter;
import com.tencent.qcloud.uikit.api.chat.IChatProvider;
import com.tencent.qcloud.uikit.business.chat.model.MessageInfo;
import com.tencent.qcloud.uikit.business.chat.view.ChatListView;

import java.util.ArrayList;
import java.util.List;


public class GroupChatProvider implements IChatProvider {

    private ArrayList<MessageInfo> dataSource = new ArrayList();

    private IChatAdapter adapter;

    @Override
    public List<MessageInfo> getDataSource() {
        return dataSource;
    }

    @Override
    public boolean addMessageInfos(List<MessageInfo> msgs, boolean front) {
        List<MessageInfo> messageInfos = removeExistElement(msgs);
        boolean flag;
        if (front) {
            flag = dataSource.addAll(0, messageInfos);
            updateAdapter(ChatListView.DATA_CHANGE_TYPE_ADD_FRONT, messageInfos.size());
        } else {
            flag = dataSource.addAll(messageInfos);
            updateAdapter(ChatListView.DATA_CHANGE_TYPE_ADD_BACK, messageInfos.size());
        }
        return flag;
    }

    private List<MessageInfo> removeExistElement(List<MessageInfo> msgs) {
        if (msgs.size() > 0) {
            for (int i = 0; i < msgs.size(); i++) {
                String msgId = msgs.get(i).getMsgId();
                if (msgId != null) {
                    for (int j = dataSource.size() - 1; j >= 0; j--) {
                        TIMMessage timMessage = dataSource.get(j).getTIMMessage();
                        if (timMessage.getMsgId().equals(msgId)) {
                            msgs.remove(msgs.get(i));
                        }
                    }
                }
            }
        }
        return msgs;
    }

    private boolean checkExist(MessageInfo msg) {
        if (msg != null) {
            String msgId = msg.getMsgId();
            for (int i = dataSource.size() - 1; i >= 0; i--) {
                if (dataSource.get(i).getTIMMessage().getMsgId().equals(msgId))
                    return true;
            }
        }
        return false;

    }

    @Override
    public boolean deleteMessageInfos(List<MessageInfo> messages) {
        for (int i = 0; i < dataSource.size(); i++) {
            for (int j = 0; j < messages.size(); j++) {
                if (dataSource.get(i).getMsgId().equals(messages.get(j).getMsgId())) {
                    dataSource.remove(i);
                    updateAdapter(ChatListView.DATA_CHANGE_TYPE_DELETE, i);
                    break;
                }
            }
        }
        return false;
    }

    @Override
    public boolean updateMessageInfos(List<MessageInfo> messages) {
        return false;
    }


    public boolean addMessageInfo(MessageInfo msg) {
        if (msg == null) {
            updateAdapter(ChatListView.DATA_CHANGE_TYPE_LOAD, 0);
            return true;
        }
        if (checkExist(msg))
            return true;
        boolean flag = dataSource.add(msg);
        updateAdapter(ChatListView.DATA_CHANGE_TYPE_ADD_BACK, 1);
        return flag;

    }

    public boolean deleteMessageInfo(MessageInfo msg) {
        for (int i = 0; i < dataSource.size(); i++) {
            if (dataSource.get(i).getMsgId().equals(msg.getMsgId())) {
                dataSource.remove(i);
                updateAdapter(ChatListView.DATA_CHANGE_TYPE_DELETE, -1);
                return true;
            }
        }
        return false;
    }

    public boolean updateMessageInfo(MessageInfo message) {
        for (int i = 0; i < dataSource.size(); i++) {
            if (dataSource.get(i).getMsgId().equals(message.getMsgId())) {
                dataSource.remove(i);
                dataSource.add(i, message);
                updateAdapter(ChatListView.DATA_CHANGE_TYPE_UPDATE, i);
                return true;
            }
        }
        return false;
    }

    public boolean updateMessageRevoked(TIMMessageLocator locator) {
        for (int i = 0; i < dataSource.size(); i++) {
            MessageInfo messageInfo = dataSource.get(i);
            TIMMessage msg = messageInfo.getTIMMessage();
            TIMMessageExt ext = new TIMMessageExt(msg);
            if (ext.checkEquals(locator)) {
                messageInfo.setMsgType(MessageInfo.MSG_STATUS_REVOKE);
                messageInfo.setStatus(MessageInfo.MSG_STATUS_REVOKE);
                updateAdapter(ChatListView.DATA_CHANGE_TYPE_UPDATE, i);
                return true;
            }
        }
        return false;
    }


    public boolean updateMessageRevoked(String msgId) {
        for (int i = 0; i < dataSource.size(); i++) {
            MessageInfo messageInfo = dataSource.get(i);
            if (messageInfo.getMsgId().equals(msgId)) {
                messageInfo.setMsgType(MessageInfo.MSG_STATUS_REVOKE);
                messageInfo.setStatus(MessageInfo.MSG_STATUS_REVOKE);
                updateAdapter(ChatListView.DATA_CHANGE_TYPE_UPDATE, i);
                return true;
            }
        }
        return false;
    }


    public void remove(int index) {
        dataSource.remove(index);
        updateAdapter(ChatListView.DATA_CHANGE_TYPE_DELETE, index);
    }

    public void clear() {
        dataSource.clear();
        updateAdapter(ChatListView.DATA_CHANGE_TYPE_LOAD, 0);
    }


    private void updateAdapter(int type, int data) {
        if (adapter != null)
            adapter.notifyDataSetChanged(type, data);
    }


    public IChatAdapter getAdapter() {
        return adapter;
    }

    public void attachAdapter(IChatAdapter adapter) {
        this.adapter = adapter;
    }

}
