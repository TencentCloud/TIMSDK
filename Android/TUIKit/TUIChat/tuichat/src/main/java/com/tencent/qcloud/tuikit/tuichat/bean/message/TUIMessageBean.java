package com.tencent.qcloud.tuikit.tuichat.bean.message;

import android.text.TextUtils;

import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.TUIReplyQuoteBean;

import java.io.Serializable;

public abstract class TUIMessageBean implements Serializable {
     /**
      * 消息正常状态
      */
     public static final int MSG_STATUS_NORMAL = 0;
     /**
      * 消息发送中状态
      */
     public static final int MSG_STATUS_SENDING = 1;
     /**
      * 消息发送成功状态
      */
     public static final int MSG_STATUS_SEND_SUCCESS = 2;
     /**
      * 消息发送失败状态
      */
     public static final int MSG_STATUS_SEND_FAIL = 3;

     /**
      * 消息未读状态
      */
     public static final int MSG_STATUS_READ = 0x111;
     /**
      * 消息删除状态
      */
     public static final int MSG_STATUS_DELETE = 0x112;
     /**
      * 消息撤回状态
      */
     public static final int MSG_STATUS_REVOKE = 0x113;

     /**
      * 消息内容下载中状态
      */
     public static final int MSG_STATUS_DOWNLOADING = 4;
     /**
      * 消息内容未下载状态
      */
     public static final int MSG_STATUS_UN_DOWNLOAD = 5;
     /**
      * 消息内容已下载状态
      */
     public static final int MSG_STATUS_DOWNLOADED = 6;

     private V2TIMMessage v2TIMMessage;
     private long msgTime;
     private String extra;
     private String id;
     private boolean isGroup;
     private int status;
     private int downloadStatus;

     private long readCount = 0;
     private long unreadCount = 1;

     public void setReadCount(long readCount) {
          this.readCount = readCount;
     }

     public void setUnreadCount(long unreadCount) {
          this.unreadCount = unreadCount;
     }

     public long getReadCount() {
          return readCount;
     }

     public long getUnreadCount() {
          return unreadCount;
     }

     public void setCommonAttribute(V2TIMMessage v2TIMMessage) {
          msgTime = System.currentTimeMillis() / 1000;
          this.v2TIMMessage = v2TIMMessage;

          if (v2TIMMessage == null) {
               return;
          }

          id = v2TIMMessage.getMsgID();
          isGroup = !TextUtils.isEmpty(v2TIMMessage.getGroupID());
          if (!isGroup && v2TIMMessage.isPeerRead()) {
               unreadCount = 0;
               readCount = 1;
          }
          if (v2TIMMessage.getStatus() == V2TIMMessage.V2TIM_MSG_STATUS_LOCAL_REVOKED) {
               status = MSG_STATUS_REVOKE;
               if (isSelf()) {
                    extra = TUIChatService.getAppContext().getString(R.string.revoke_tips_you);
               } else if (isGroup) {
                    String message = TUIChatConstants.covert2HTMLString(getSender());
                    extra = message + TUIChatService.getAppContext().getString(R.string.revoke_tips);
               } else {
                    extra = TUIChatService.getAppContext().getString(R.string.revoke_tips_other);
               }
          } else {
               if (isSelf()) {
                    if (v2TIMMessage.getStatus() == V2TIMMessage.V2TIM_MSG_STATUS_SEND_FAIL) {
                         status = MSG_STATUS_SEND_FAIL;
                    } else if (v2TIMMessage.getStatus() == V2TIMMessage.V2TIM_MSG_STATUS_SEND_SUCC) {
                         status = MSG_STATUS_SEND_SUCCESS;
                    } else if (v2TIMMessage.getStatus() == V2TIMMessage.V2TIM_MSG_STATUS_SENDING) {
                         status = MSG_STATUS_SENDING;
                    }
               }
          }
     }

     public boolean isPeerRead() {
          return unreadCount == 0 && readCount == 1;
     }

     public void setPeerRead(boolean isPeerRead) {
          if (isPeerRead) {
               unreadCount = 0;
               readCount = 1;
          } else {
               unreadCount = 1;
               readCount = 0;
          }
     }

     public boolean isAllRead() {
          return unreadCount == 0 && readCount > 0;
     }

     public boolean isUnread() {
          return readCount == 0;
     }

     /**
      * 获取要显示在会话列表的消息摘要
      * @return 消息摘要
      */
     public abstract String onGetDisplayString();

     /**
      * V2TIMMessage 解析为 TUIMessageBean
      * @param v2TIMMessage IMSDK 消息类
      */
     public abstract void onProcessMessage(V2TIMMessage v2TIMMessage);

     public final long getMessageTime() {
          if (v2TIMMessage != null) {
               long timestamp = v2TIMMessage.getTimestamp();
               // 老版本 IMSDK 创建消息时间为0，返回客户端时间
               if (timestamp != 0) {
                    return timestamp;
               }
          }
          return msgTime;
     }

     public long getMsgSeq() {
          if (v2TIMMessage != null) {
               return v2TIMMessage.getSeq();
          }
          return 0;
     }

     public void setId(String id) {
          this.id = id;
     }

     public String getId() {
          return id;
     }


     public String getUserId() {
          if (v2TIMMessage != null) {
               return v2TIMMessage.getUserID();
          }
          return "";
     }

     public boolean isSelf() {
          if (v2TIMMessage != null) {
               return v2TIMMessage.isSelf();
          }
          return true;
     }

     public String getSender() {
          String sender = null;
          if (v2TIMMessage != null) {
               sender = v2TIMMessage.getSender();
          }
          if (TextUtils.isEmpty(sender)) {
               sender = V2TIMManager.getInstance().getLoginUser();
          }
          return sender;
     }

     public V2TIMMessage getV2TIMMessage() {
          return v2TIMMessage;
     }

     public boolean isGroup() {
          return isGroup;
     }

     public void setGroup(boolean group) {
          isGroup = group;
     }

     public String getGroupId() {
          if (v2TIMMessage != null) {
               return v2TIMMessage.getGroupID();
          }
          return "";
     }

     public String getNameCard() {
          if (v2TIMMessage != null) {
               return v2TIMMessage.getNameCard();
          }
          return "";
     }

     public String getNickName() {
          if (v2TIMMessage != null) {
               return v2TIMMessage.getNickName();
          }
          return "";
     }

     public String getFriendRemark() {
          if (v2TIMMessage != null) {
               return v2TIMMessage.getFriendRemark();
          }
          return "";
     }

     public String getUserDisplayName() {
          // 群名片->好友备注->昵称->ID
          String displayName;
          if (!TextUtils.isEmpty(getNameCard())) {
               displayName = getNameCard();
          } else if (!TextUtils.isEmpty(getFriendRemark())) {
               displayName = getFriendRemark();
          } else if (!TextUtils.isEmpty(getNickName())) {
               displayName = getNickName();
          } else {
               displayName = getSender();
          }
          return displayName;
     }

     public String getFaceUrl() {
          if (v2TIMMessage != null) {
               return v2TIMMessage.getFaceUrl();
          }
          return "";
     }

     public void setStatus(int status) {
          this.status = status;
     }

     public int getStatus() {
          return status;
     }

     public void setExtra(String extra) {
          this.extra = extra;
     }

     public String getExtra() {
          return extra;
     }

     public void setDownloadStatus(int downloadStatus) {
          this.downloadStatus = downloadStatus;
     }

     public int getDownloadStatus() {
          return downloadStatus;
     }

     public int getMsgType() {
          if (v2TIMMessage != null) {
               return v2TIMMessage.getElemType();
          } else {
               return V2TIMMessage.V2TIM_ELEM_TYPE_NONE;
          }
     }

     public boolean isNeedReadReceipt() {
          if (v2TIMMessage != null) {
               return v2TIMMessage.isNeedReadReceipt();
          }
          return false;
     }

     public void setNeedReadReceipt(boolean isNeedReceipt) {
          if (v2TIMMessage != null) {
               v2TIMMessage.setNeedReadReceipt(isNeedReceipt);
          }
     }

     public void setV2TIMMessage(V2TIMMessage v2TIMMessage) {
          this.v2TIMMessage = v2TIMMessage;
          setCommonAttribute(v2TIMMessage);
          onProcessMessage(v2TIMMessage);
     }

     public Class<? extends TUIReplyQuoteBean> getReplyQuoteBeanClass() {
          return null;
     }
}
