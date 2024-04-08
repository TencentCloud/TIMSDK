package com.tencent.qcloud.tuicore.push;

import android.util.Log;

import androidx.annotation.NonNull;

import com.tencent.imsdk.v2.V2TIMConversation;

import java.io.Serializable;
import java.io.UnsupportedEncodingException;

public class OfflinePushExtBusinessInfo implements Serializable {
   // The following are example fields that can be used based on the explanation; they are already used in TUIKitDemo.

   public int version = 1;
   public int chatType = V2TIMConversation.V2TIM_C2C;
   public int action = OfflinePushExtInfo.REDIRECT_ACTION_CHAT;
   public String sender = "";
   public String nickname = "";
   public String faceUrl = "";
   public String content = "";
   public long sendTime = 0;

   // custom data
   public byte[] customData;


   /**
    * Set the identifier for the chat type of the sent offline message.
    *
    * @param chatType  1，one-on-one chat；2，group chat
    */
   public void setChatType(int chatType) {
      this.chatType = chatType;
   }

   /**
    * Get the chat type of the offline message from the sender.
    *
    * @return   1，one-on-one chat；2，group chat
    */
   public int getChatType() {
      return this.chatType;
   }

   /**
    * Set the identifier for the type of the sent offline message
    *
    * @param action  REDIRECT_ACTION_CHAT = 1，chat; REDIRECT_ACTION_CALL = 2, call
    */
   public void setChatAction(int action) {
      this.action = action;
   }

   /**
    * Get the type of the offline message from the sender
    *
    * @return   REDIRECT_ACTION_CHAT = 1，chat; REDIRECT_ACTION_CALL = 2, call
    */
   public int getChatAction() {
      return this.action;
   }

   /**
    * Set the identifier for the sender ID of the offline message
    *
    * @param senderId  userID/groupID
    */
   public void setSenderId(String senderId) {
      this.sender = senderId;
   }

   /**
    * Get the sender ID of the offline message
    *
    * @return   userID/groupID
    */
   public String getSenderId() {
      return this.sender;
   }

   /**
    * Set the identifier for the sender nickname of the offline message.
    *
    * @param nickName  sender nickname
    */
   public void setSenderNickName(String nickName) {
      this.nickname = nickName;
   }

   /**
    * Get the sender nickname of the offline message.
    *
    * @return  sender nickname
    */
   public String getSenderNickName() {
      return this.nickname;
   }

   /**
    * Set the display fields of the offline message
    *
    * @param desc  description
    */
   public void setDesc(String desc) {
      this.content = desc;
   }

   /**
    * Get the display fields of the offline message
    *
    * @return  description
    */
   public String getDesc() {
      return this.content;
   }

   /**
    * Set the version number of the offline message
    *
    * @param version  version number
    */
   public void setVersion(int version) {
      this.version = version;
   }

   /**
    * Get the version number of the offline message
    *
    * @return  version number
    */
   public int getVersion() {
      return this.version;
   }

   /**
    * Set the face Url of the offline message
    *
    * @param faceUrl  face Url
    */
   public void setFaceUrl(String faceUrl) {
      this.faceUrl = faceUrl;
   }

   /**
    * Get the face Url of the offline message
    *
    * @return  face Url
    */
   public String getFaceUrl() {
      return this.faceUrl;
   }

   /**
    * Set the sending time of the offline message
    *
    * @param sendTime  sending time
    */
   public void setSendTime(long sendTime) {
      this.sendTime = sendTime;
   }

   /**
    * Get the sending time of the offline message
    *
    * @return  sending time
    */
   public long getSendTime() {
      return this.sendTime;
   }

   /**
    * Set custom data (will be fully transmitted to the receiving end).
    *
    * @param customData custom data
    */
   public void setCustomData(byte[] customData) {
      this.customData = customData;
   }

   /**
    * Get custom data
    *
    * @return  custom data
    */
   public byte[] getCustomData() {
      return this.customData;
   }

   String getCustomDataString() {
      String customString = "";
      if (customData != null && customData.length > 0) {
         try {
            customString = new String(customData, "UTF-8");
         } catch (UnsupportedEncodingException e) {
            Log.e("entity", "getCustomData e = " + e);
         }
      }
      return customString;
   }

   @NonNull
   @Override
   public String toString() {
      return "OfflinePushExtBusinessInfo{"
              + "version=" + version + ", chatType='" + chatType + '\'' + ", action=" + action + ", sender=" + sender + ", nickname=" + nickname
              + ", faceUrl=" + faceUrl + ", content=" + content + ", sendTime=" + sendTime + ", customData=" + getCustomDataString() + '}';
   }
}
