package com.tencent.qcloud.tuicore.push;

import java.io.Serializable;

/**
 * ## The transparent transmission field of offline push messages can be set through the V2TIMOfflinePushInfo.setExt(ext)
 *    method.When users receive push notifications and click on them, they can retrieve the transparent transmission field
 *    within the startup interface.
 *    OfflinePushExtInfo is the JavaBean corresponding to the ext parameter of the transparent transmission.
 *
 *
 * @note usage：
 *     OfflinePushExtInfo offlinePushExtInfo = new OfflinePushExtInfo();
 *
 *    - Set:
 *      V2TIMOfflinePushInfo v2TIMOfflinePushInfo = new V2TIMOfflinePushInfo();
 *      v2TIMOfflinePushInfo.setExt(new Gson().toJson(offlinePushExtInfo).getBytes());
 *
 *    - Get:
 *      String ext = intent.getStringExtra("ext");
 *      try {
 *          offlinePushExtInfo = new Gson().fromJson(ext, OfflinePushExtInfo.class);
 *      } catch (Exception e) {
 *
 *      }
 *
 *
 * @note OfflinePushExtInfo JSON format：
 *    {
 *     "entity":"xxxxxx",
 *     "timPushFeatures":"xxxxxxx"
 *    }
 *
 */

public class OfflinePushExtInfo implements Serializable {
    public static final int REDIRECT_ACTION_CHAT = 1;
    public static final int REDIRECT_ACTION_CALL = 2;

    private OfflinePushExtBusinessInfo entity = new OfflinePushExtBusinessInfo();
    private OfflinePushExtConfigInfo timPushFeatures = new OfflinePushExtConfigInfo();

    /**
     * ## Universal feature function entry
     *
     * @return Universal feature function class instance
     */
    public OfflinePushExtBusinessInfo getBusinessInfo() {
        return this.entity;
    }

    /**
     *  Set universal feature function class instance
     *
     */
    public void setBusinessInfo(OfflinePushExtBusinessInfo entity) {
        if (null == entity) {
            entity = new OfflinePushExtBusinessInfo();
        }

        this.entity = entity;
    }

    /**
     * ## Feature function entry supported by TIMPush
     *
     * @return  Class instance of feature function supported by TIMPush
     */
    public OfflinePushExtConfigInfo getConfigInfo() {
        return this.timPushFeatures;
    }
}
