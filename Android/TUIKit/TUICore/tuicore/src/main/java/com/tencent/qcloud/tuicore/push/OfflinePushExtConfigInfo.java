package com.tencent.qcloud.tuicore.push;

import androidx.annotation.NonNull;

import java.io.Serializable;

public class OfflinePushExtConfigInfo implements Serializable {
   public static final int FCM_PUSH_TYPE_DATA = 0;
   public static final int FCM_PUSH_TYPE_NOTIFICATION = 1;

   public static final int FCM_NOTIFICATION_TYPE_TIMPUSH = 0;
   public static final int FCM_NOTIFICATION_TYPE_PASS_THROUGH = 1;

   private int fcmPushType = -1;
   private int fcmNotificationType = -1;

   /**
    * Console configures the certificate for data mode, and the message field can be set to switch to this mode with higher priority.
    *
    * @param fcmPushType  0, data; 1, notification
    */
   public void setFCMPushType(int fcmPushType) {
      this.fcmPushType = fcmPushType;
   }

   /**
    * In FCM channel's data mode, whether to display the notification message through the plugin or handle it in the
    * business implementation after transparent transmission.
    *
    * @param fcmNotificationType  0, TIMPush implementation； 1, business implementation after transparent transmission
    */
   public void setFCMNotificationType(int fcmNotificationType) {
      this.fcmNotificationType = fcmNotificationType;
   }

   /**
    * In FCM channel's data mode, whether to retrieve the notification message through the plugin or handle it in the
    * business implementation after transparent transmission.
    *
    * @return   0, TIMPush implementation； 1, business implementation after transparent transmission
    */
   public int getFCMNotificationType() {
      return this.fcmNotificationType;
   }

   @NonNull
   @Override
   public String toString() {
      return "OfflinePushExtConfigInfo{"
              + "fcmPushType=" + fcmPushType + ", fcmNotificationType='" + fcmNotificationType + '}';
   }
}
