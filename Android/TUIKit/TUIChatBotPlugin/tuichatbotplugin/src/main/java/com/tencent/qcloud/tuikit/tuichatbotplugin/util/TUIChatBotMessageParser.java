package com.tencent.qcloud.tuikit.tuichatbotplugin.util;

import com.tencent.imsdk.v2.V2TIMCustomElem;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuikit.tuichatbotplugin.TUIChatBotConstants;
import com.tencent.qcloud.tuikit.tuichatbotplugin.bean.BranchBean;

import java.util.ArrayList;
import java.util.List;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class TUIChatBotMessageParser {
    private static final String TAG = "TUIChatBotMessageParser";

    public static BranchBean getBranchInfo(V2TIMMessage v2TIMMessage) {
        V2TIMCustomElem customElem = v2TIMMessage.getCustomElem();
        if (customElem == null || customElem.getData() == null || customElem.getData().length == 0) {
            TUIChatBotLog.e(TAG, "getBranchInfo fail, customElem or data is empty");
            return null;
        }

        BranchBean branchBean = new BranchBean();
        String data = new String(customElem.getData());
        try {
            JSONObject branchJson = new JSONObject(data);
            branchBean.setSubType(branchJson.optString(TUIChatBotConstants.CHAT_BOT_SUBTYPE));

            JSONObject contentJson = new JSONObject(branchJson.optString(TUIChatBotConstants.CHAT_BOT_CONTENT));
            if (contentJson == null) {
                return null;
            }

            branchBean.setTitle(contentJson.optString(TUIChatBotConstants.CHAT_BOT_TITLE));
            branchBean.setContent(contentJson.optString(TUIChatBotConstants.CHAT_BOT_CONTENT));
            List<BranchBean.Item> itemList = new ArrayList<>();
            JSONArray itemJsonArray = contentJson.optJSONArray(TUIChatBotConstants.CHAT_BOT_ITEMS);
            if (itemJsonArray != null) {
                for (int i = 0; i < itemJsonArray.length(); i++) {
                    JSONObject itemObject = itemJsonArray.optJSONObject(i);
                    if (itemObject != null) {
                        BranchBean.Item item = new BranchBean.Item();
                        item.setContent(itemObject.optString(TUIChatBotConstants.CHAT_BOT_CONTENT));
                        itemList.add(item);
                    }
                }
                branchBean.setItemList(itemList);
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }

        return branchBean;
    }

    public static String getStreamText(V2TIMMessage v2TIMMessage) {
        V2TIMCustomElem customElem = v2TIMMessage.getCustomElem();
        if (customElem == null || customElem.getData() == null || customElem.getData().length == 0) {
            TUIChatBotLog.e(TAG, "getStreamText fail, customElem or data is empty");
            return "";
        }

        String displayContent = "";
        String data = new String(customElem.getData());
        try {
            JSONObject streamTextJson = new JSONObject(data);
            JSONArray itemJsonArray = streamTextJson.optJSONArray(TUIChatBotConstants.CHAT_BOT_CHUNKS);
            if (itemJsonArray != null) {
                for (int i = 0; i < itemJsonArray.length(); i++) {
                    String contentChunk = itemJsonArray.getString(i);
                    displayContent = displayContent + contentChunk;
                }
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }

        return displayContent;
    }

    public static String getRichText(V2TIMMessage v2TIMMessage) {
        V2TIMCustomElem customElem = v2TIMMessage.getCustomElem();
        if (customElem == null || customElem.getData() == null || customElem.getData().length == 0) {
            TUIChatBotLog.e(TAG, "getRichText fail, customElem or data is empty");
            return "";
        }

        String richTextContent = "";
        String data = new String(customElem.getData());
        try {
            JSONObject richTextJson = new JSONObject(data);
            richTextContent = richTextJson.getString(TUIChatBotConstants.CHAT_BOT_CONTENT);
        } catch (JSONException e) {
            e.printStackTrace();
        }

        return richTextContent;
    }

}
