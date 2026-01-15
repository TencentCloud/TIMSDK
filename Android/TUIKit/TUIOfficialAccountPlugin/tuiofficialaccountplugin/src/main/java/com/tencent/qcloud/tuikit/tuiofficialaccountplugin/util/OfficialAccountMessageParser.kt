package com.tencent.qcloud.tuikit.tuiofficialaccountplugin.util

import android.text.TextUtils
import com.tencent.imsdk.v2.V2TIMMessage
import com.tencent.qcloud.tuikit.tuiofficialaccountplugin.TUIOfficialAccountConstants
import com.tencent.qcloud.tuikit.tuiofficialaccountplugin.bean.OfficialAccountMessage
import org.json.JSONException
import org.json.JSONObject

object OfficialAccountMessageParser {
    
    private const val TAG = "OfficialAccountMessageParser"
    
    fun parseOfficialAccountMessage(v2TIMMessage: V2TIMMessage): OfficialAccountMessage? {
        val customElem = v2TIMMessage.customElem
        if (customElem?.data == null || customElem.data.isEmpty()) {
            TUIOfficialAccountLog.e(TAG, "parseOfficialAccountMessage fail, customElem or data is empty")
            return null
        }
        
        return try {
            val data = String(customElem.data)
            val messageJson = JSONObject(data)
            
            val businessId = messageJson.optString("businessID")
            if (!TextUtils.equals(businessId, TUIOfficialAccountConstants.BUSINESS_ID_OFFICIAL_ACCOUNT)) {
                TUIOfficialAccountLog.e(TAG, "parseOfficialAccountMessage fail, business id not match")
                return null
            }
            
            val imageInfo = if (messageJson.has("imageInfo")) {
                val imageInfoJson = messageJson.getJSONObject("imageInfo")
                com.tencent.qcloud.tuikit.tuiofficialaccountplugin.bean.ImageInfo(
                    url = imageInfoJson.optString("url"),
                    width = imageInfoJson.optInt("width"),
                    height = imageInfoJson.optInt("height")
                )
            } else {
                null
            }
            
            OfficialAccountMessage(
                businessID = businessId,
                title = messageJson.optString("title"),
                content = messageJson.optString("content"),
                link = messageJson.optString("link"),
                imageInfo = imageInfo,
                version = messageJson.optInt("version", 1)
            )
        } catch (e: JSONException) {
            TUIOfficialAccountLog.e(TAG, "parseOfficialAccountMessage fail: ${e.message}")
            null
        }
    }

}
