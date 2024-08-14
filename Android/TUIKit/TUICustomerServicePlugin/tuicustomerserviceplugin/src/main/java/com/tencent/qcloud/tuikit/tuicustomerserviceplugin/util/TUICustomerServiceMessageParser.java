package com.tencent.qcloud.tuikit.tuicustomerserviceplugin.util;

import android.text.TextUtils;
import com.tencent.imsdk.v2.V2TIMCustomElem;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.TUICustomerServiceConstants;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.bean.BotBranchBean;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.bean.BranchBean;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.bean.CardBean;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.bean.CollectionBean;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.bean.EvaluationBean;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class TUICustomerServiceMessageParser {
    private static final String TAG = "TUICustomerServiceMessageParser";

    public static BranchBean getBranchInfo(V2TIMMessage v2TIMMessage) {
        V2TIMCustomElem customElem = v2TIMMessage.getCustomElem();
        if (customElem == null || customElem.getData() == null || customElem.getData().length == 0) {
            TUICustomerServiceLog.e(TAG, "getBranchInfo fail, customElem or data is empty");
            return null;
        }

        BranchBean branchBean = new BranchBean();
        String data = new String(customElem.getData());
        try {
            JSONObject branchJson = new JSONObject(data);
            JSONObject contentJson = new JSONObject(branchJson.optString(TUICustomerServiceConstants.CUSTOMER_SERVICE_CONTENT));
            if (contentJson == null) {
                return null;
            }

            branchBean.setHead(contentJson.optString(TUICustomerServiceConstants.CUSTOMER_SERVICE_HEADER));
            branchBean.setTail(contentJson.optString(TUICustomerServiceConstants.CUSTOMER_SERVICE_TAIL));
            String selectItemString = contentJson.optString(TUICustomerServiceConstants.CUSTOMER_SERVICE_ITEM_SELECTED);
            if (!TextUtils.isEmpty(selectItemString)) {
                JSONObject selectedJson = new JSONObject(contentJson.optString(TUICustomerServiceConstants.CUSTOMER_SERVICE_ITEM_SELECTED));
                String itemContent = selectedJson.optString(TUICustomerServiceConstants.CUSTOMER_SERVICE_ITEM_CONTENT);
                if (!TextUtils.isEmpty(itemContent)) {
                    BranchBean.Item selectedItem = new BranchBean.Item();
                    selectedItem.setContent(itemContent);
                    selectedItem.setDescription(selectedJson.optString(TUICustomerServiceConstants.CUSTOMER_SERVICE_ITEM_DESCRIPTION));
                    branchBean.setSelectedItem(selectedItem);
                }
            }

            List<BranchBean.Item> itemList = new ArrayList<>();
            JSONArray itemJsonArray = contentJson.optJSONArray(TUICustomerServiceConstants.CUSTOMER_SERVICE_ITEMS);
            if (itemJsonArray != null) {
                for (int i = 0; i < itemJsonArray.length(); i++) {
                    JSONObject itemObject = itemJsonArray.optJSONObject(i);
                    if (itemObject != null) {
                        BranchBean.Item item = new BranchBean.Item();
                        item.setContent(itemObject.optString(TUICustomerServiceConstants.CUSTOMER_SERVICE_ITEM_CONTENT));
                        item.setDescription(itemObject.optString(TUICustomerServiceConstants.CUSTOMER_SERVICE_ITEM_DESCRIPTION));
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

    public static BotBranchBean getBotBranchInfo(V2TIMMessage v2TIMMessage) {
        V2TIMCustomElem customElem = v2TIMMessage.getCustomElem();
        if (customElem == null || customElem.getData() == null || customElem.getData().length == 0) {
            TUICustomerServiceLog.e(TAG, "getBranchInfo fail, customElem or data is empty");
            return null;
        }

        BotBranchBean botBranchBean = new BotBranchBean();
        String data = new String(customElem.getData());
        try {
            JSONObject branchJson = new JSONObject(data);
            botBranchBean.setSubType(branchJson.optString(TUICustomerServiceConstants.BOT_SUBTYPE));

            JSONObject contentJson = new JSONObject(branchJson.optString(TUICustomerServiceConstants.CUSTOMER_SERVICE_CONTENT));
            if (contentJson == null) {
                return null;
            }

            botBranchBean.setTitle(contentJson.optString(TUICustomerServiceConstants.BOT_TITLE));
            botBranchBean.setContent(contentJson.optString(TUICustomerServiceConstants.CUSTOMER_SERVICE_CONTENT));
            List<BotBranchBean.Item> itemList = new ArrayList<>();
            JSONArray itemJsonArray = contentJson.optJSONArray(TUICustomerServiceConstants.CUSTOMER_SERVICE_ITEMS);
            if (itemJsonArray != null) {
                for (int i = 0; i < itemJsonArray.length(); i++) {
                    JSONObject itemObject = itemJsonArray.optJSONObject(i);
                    if (itemObject != null) {
                        BotBranchBean.Item item = new BotBranchBean.Item();
                        item.setContent(itemObject.optString(TUICustomerServiceConstants.CUSTOMER_SERVICE_ITEM_CONTENT));
                        itemList.add(item);
                    }
                }
                botBranchBean.setItemList(itemList);
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }

        return botBranchBean;
    }

    public static CollectionBean getCollectionInfo(V2TIMMessage v2TIMMessage) {
        V2TIMCustomElem customElem = v2TIMMessage.getCustomElem();
        if (customElem == null || customElem.getData() == null || customElem.getData().length == 0) {
            TUICustomerServiceLog.e(TAG, "getCollectionInfo fail, customElem or data is empty");
            return null;
        }

        CollectionBean collectionBean = new CollectionBean();
        String data = new String(customElem.getData());
        try {
            JSONObject collectionJson = new JSONObject(data);
            JSONObject contentJson = new JSONObject(collectionJson.optString(TUICustomerServiceConstants.CUSTOMER_SERVICE_CONTENT));
            if (contentJson == null) {
                return null;
            }

            collectionBean.setHead(contentJson.optString(TUICustomerServiceConstants.CUSTOMER_SERVICE_HEADER));
            collectionBean.setType(contentJson.optInt(TUICustomerServiceConstants.CUSTOMER_SERVICE_TYPE));
            String selectItemString = contentJson.optString(TUICustomerServiceConstants.CUSTOMER_SERVICE_ITEM_SELECTED);
            if (!TextUtils.isEmpty(selectItemString)) {
                JSONObject selectedJson = new JSONObject(contentJson.optString(TUICustomerServiceConstants.CUSTOMER_SERVICE_ITEM_SELECTED));
                String itemContent = selectedJson.optString(TUICustomerServiceConstants.CUSTOMER_SERVICE_ITEM_CONTENT);
                if (!TextUtils.isEmpty(itemContent)) {
                    CollectionBean.FormItem selectedItem = new CollectionBean.FormItem();
                    selectedItem.setContent(itemContent);
                    selectedItem.setDescription(selectedJson.optString(TUICustomerServiceConstants.CUSTOMER_SERVICE_ITEM_DESCRIPTION));
                    collectionBean.setSelectedItem(selectedItem);
                }
            }

            List<CollectionBean.FormItem> itemList = new ArrayList<>();
            JSONArray itemJsonArray = contentJson.optJSONArray(TUICustomerServiceConstants.CUSTOMER_SERVICE_ITEMS);
            if (itemJsonArray != null) {
                for (int i = 0; i < itemJsonArray.length(); i++) {
                    JSONObject itemObject = itemJsonArray.optJSONObject(i);
                    if (itemObject != null) {
                        CollectionBean.FormItem item = new CollectionBean.FormItem();
                        item.setContent(itemObject.optString(TUICustomerServiceConstants.CUSTOMER_SERVICE_ITEM_CONTENT));
                        item.setDescription(itemObject.optString(TUICustomerServiceConstants.CUSTOMER_SERVICE_ITEM_DESCRIPTION));
                        itemList.add(item);
                    }
                }
                collectionBean.setItemList(itemList);
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }

        return collectionBean;
    }

    public static EvaluationBean getEvaluationInfo(V2TIMMessage v2TIMMessage) {
        V2TIMCustomElem customElem = v2TIMMessage.getCustomElem();
        if (customElem == null || customElem.getData() == null || customElem.getData().length == 0) {
            TUICustomerServiceLog.e(TAG, "getEvaluationInfo fail, customElem or data is empty");
            return null;
        }

        EvaluationBean evaluationBean = new EvaluationBean();
        String data = new String(customElem.getData());
        try {
            JSONObject collectionJson = new JSONObject(data);
            JSONObject contentJson = new JSONObject(collectionJson.optString(TUICustomerServiceConstants.CUSTOMER_SERVICE_MENU_CONTENT));
            if (contentJson == null) {
                return null;
            }

            evaluationBean.setHead(contentJson.optString(TUICustomerServiceConstants.CUSTOMER_SERVICE_MENU_CONTENT_HEAD));
            evaluationBean.setType(contentJson.optInt(TUICustomerServiceConstants.CUSTOMER_SERVICE_TYPE));
            evaluationBean.setSessionID(contentJson.optString(TUICustomerServiceConstants.CUSTOMER_SERVICE_SESSION_ID));
            evaluationBean.setTail(contentJson.optString(TUICustomerServiceConstants.CUSTOMER_SERVICE_TAIL));
            evaluationBean.setExpireTime(contentJson.optInt(TUICustomerServiceConstants.CUSTOMER_SERVICE_EXPIRED_TIME));
            String selectMenuString = contentJson.optString(TUICustomerServiceConstants.CUSTOMER_SERVICE_ITEM_SELECTED);
            if (!TextUtils.isEmpty(selectMenuString)) {
                EvaluationBean.Menu selectedMenu = new EvaluationBean.Menu();
                JSONObject selectedJson = new JSONObject(contentJson.optString(TUICustomerServiceConstants.CUSTOMER_SERVICE_ITEM_SELECTED));
                String menuContent = selectedJson.optString(TUICustomerServiceConstants.CUSTOMER_SERVICE_ITEM_CONTENT);
                if (!TextUtils.isEmpty(menuContent)) {
                    selectedMenu.setContent(menuContent);
                }

                String id = selectedJson.optString(TUICustomerServiceConstants.CUSTOMER_SERVICE_ITEM_ID);
                if (!TextUtils.isEmpty(id)) {
                    selectedMenu.setId(id);
                    evaluationBean.setSelectedMenu(selectedMenu);
                }
            }

            List<EvaluationBean.Menu> menuList = new ArrayList<>();
            JSONArray menuJsonArray = contentJson.optJSONArray(TUICustomerServiceConstants.CUSTOMER_SERVICE_MENU);
            if (menuJsonArray != null) {
                for (int i = 0; i < menuJsonArray.length(); i++) {
                    JSONObject itemObject = menuJsonArray.optJSONObject(i);
                    if (itemObject != null) {
                        EvaluationBean.Menu menu = new EvaluationBean.Menu();
                        menu.setContent(itemObject.optString(TUICustomerServiceConstants.CUSTOMER_SERVICE_ITEM_CONTENT));
                        menu.setId(itemObject.optString(TUICustomerServiceConstants.CUSTOMER_SERVICE_ITEM_ID));
                        menuList.add(menu);
                    }
                }
                Collections.sort(menuList, new Comparator<EvaluationBean.Menu>() {
                    @Override
                    public int compare(EvaluationBean.Menu menu, EvaluationBean.Menu t1) {
                        return Integer.valueOf(menu.getId()) - Integer.valueOf(t1.getId());
                    }
                });
                evaluationBean.setMenuList(menuList);
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }

        return evaluationBean;
    }

    public static CardBean getCardInfo(V2TIMMessage v2TIMMessage) {
        V2TIMCustomElem customElem = v2TIMMessage.getCustomElem();
        if (customElem == null || customElem.getData() == null || customElem.getData().length == 0) {
            TUICustomerServiceLog.e(TAG, "getEvaluationInfo fail, customElem or data is empty");
            return null;
        }

        CardBean cardBean = new CardBean();
        String data = new String(customElem.getData());
        try {
            JSONObject collectionJson = new JSONObject(data);
            JSONObject contentJson = new JSONObject(collectionJson.optString(TUICustomerServiceConstants.CUSTOMER_SERVICE_CONTENT));
            if (contentJson == null) {
                return null;
            }

            cardBean.setHeader(contentJson.optString(TUICustomerServiceConstants.CUSTOMER_SERVICE_HEADER));
            cardBean.setDesc(contentJson.optString(TUICustomerServiceConstants.CUSTOMER_SERVICE_ITEM_DESCRIPTION));
            cardBean.setPic(contentJson.optString(TUICustomerServiceConstants.CUSTOMER_SERVICE_CARD_PIC));
            cardBean.setUrl(contentJson.optString(TUICustomerServiceConstants.CUSTOMER_SERVICE_CARD_URL));
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return cardBean;
    }

    public static String getRichText(V2TIMMessage v2TIMMessage) {
        V2TIMCustomElem customElem = v2TIMMessage.getCustomElem();
        if (customElem == null || customElem.getData() == null || customElem.getData().length == 0) {
            TUICustomerServiceLog.e(TAG, "getRichText fail, customElem or data is empty");
            return "";
        }

        String richTextContent = "";
        String data = new String(customElem.getData());
        try {
            JSONObject richTextJson = new JSONObject(data);
            richTextContent = richTextJson.getString(TUICustomerServiceConstants.CUSTOMER_SERVICE_CONTENT);
        } catch (JSONException e) {
            e.printStackTrace();
        }

        return richTextContent;
    }

    public static String getStreamText(V2TIMMessage v2TIMMessage) {
        V2TIMCustomElem customElem = v2TIMMessage.getCustomElem();
        if (customElem == null || customElem.getData() == null || customElem.getData().length == 0) {
            TUICustomerServiceLog.e(TAG, "getStreamText fail, customElem or data is empty");
            return "";
        }

        String displayContent = "";
        String data = new String(customElem.getData());
        try {
            JSONObject streamTextJson = new JSONObject(data);
            JSONArray itemJsonArray = streamTextJson.optJSONArray(TUICustomerServiceConstants.BOT_CHUNKS);
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
}
