package com.reactnativetimjs.manager;

import com.reactnativetimjs.util.CommonUtils;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReadableMap;

import com.tencent.imsdk.v2.V2TIMAdvancedMsgListener;
import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMCompleteCallback;
import com.tencent.imsdk.v2.V2TIMElem;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMergerElem;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMMessageListGetOption;
import com.tencent.imsdk.v2.V2TIMMessageManager;
import com.tencent.imsdk.v2.V2TIMMessageReceipt;
import com.tencent.imsdk.v2.V2TIMMessageSearchParam;
import com.tencent.imsdk.v2.V2TIMMessageSearchResult;
import com.tencent.imsdk.v2.V2TIMOfflinePushInfo;
import com.tencent.imsdk.v2.V2TIMReceiveMessageOptInfo;
import com.tencent.imsdk.v2.V2TIMSendCallback;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.imsdk.v2.V2TIMGroupMessageReadMemberList;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

public class MessageManager {
    private static V2TIMAdvancedMsgListener advacedMessageListener;// There can only be one listener for the time being
    private static HashMap<String, V2TIMMessage> messageIDMap = new HashMap(); // Used to temporarily store the created
                                                                               // message
    private static LinkedList<String> listenerUuidList = new LinkedList<String>();

    public V2TIMElem getElem(V2TIMMessage message) {
        int type = message.getElemType();
        V2TIMElem elem;
        if (type == V2TIMMessage.V2TIM_ELEM_TYPE_TEXT) {
            elem = message.getTextElem();
        } else if (type == V2TIMMessage.V2TIM_ELEM_TYPE_CUSTOM) {
            elem = message.getCustomElem();
        } else if (type == V2TIMMessage.V2TIM_ELEM_TYPE_IMAGE) {
            elem = message.getImageElem();
        } else if (type == V2TIMMessage.V2TIM_ELEM_TYPE_SOUND) {
            elem = message.getSoundElem();
        } else if (type == V2TIMMessage.V2TIM_ELEM_TYPE_VIDEO) {
            elem = message.getVideoElem();
        } else if (type == V2TIMMessage.V2TIM_ELEM_TYPE_FILE) {
            elem = message.getFileElem();
        } else if (type == V2TIMMessage.V2TIM_ELEM_TYPE_LOCATION) {
            elem = message.getLocationElem();
        } else if (type == V2TIMMessage.V2TIM_ELEM_TYPE_FACE) {
            elem = message.getFaceElem();
        } else if (type == V2TIMMessage.V2TIM_ELEM_TYPE_GROUP_TIPS) {
            elem = message.getGroupTipsElem();
        } else if (type == V2TIMMessage.V2TIM_ELEM_TYPE_MERGER) {
            elem = message.getMergerElem();
        } else {
            elem = new V2TIMElem();
        }
        return elem;
    }

    public void setAppendMessage(V2TIMMessage appendMess, V2TIMMessage baseMessage) {
        V2TIMElem aElem = getElem(appendMess);
        V2TIMElem bElem = getElem(baseMessage);
        bElem.appendElem(aElem);
    }

    public void appendMessage(Promise promise, ReadableMap arguments) {
        final String createMessageBaseId = arguments.getString("createMessageBaseId");
        final String createMessageAppendId = arguments.getString("createMessageAppendId");
        if (messageIDMap.containsKey(createMessageAppendId) && messageIDMap.containsKey(createMessageAppendId)) {
            V2TIMMessage baseMessage = messageIDMap.get(createMessageBaseId);
            V2TIMMessage appendMess = messageIDMap.get(createMessageAppendId);
            setAppendMessage(appendMess, baseMessage);
            CommonUtils.returnSuccess(promise, CommonUtils.convertV2TIMMessageToMap(baseMessage));
        } else {
            CommonUtils.returnError(promise, -1, "message not found");
        }
    }

    public void addAdvancedMsgListener(Promise promise, ReadableMap arguments) {
        advacedMessageListener = new V2TIMAdvancedMsgListener() {
            @Override
            public void onRecvNewMessage(V2TIMMessage msg) {
                makeAddAdvancedMsgListenerEventData("onRecvNewMessage", CommonUtils.convertV2TIMMessageToMap(msg));
            }

            @Override
            public void onRecvC2CReadReceipt(List<V2TIMMessageReceipt> receiptList) {
                List<Object> list = new LinkedList<Object>();
                for (int i = 0; i < receiptList.size(); i++) {
                    list.add(CommonUtils.convertV2TIMMessageReceiptToMap(receiptList.get(i)));
                }
                makeAddAdvancedMsgListenerEventData("onRecvC2CReadReceipt", list);
            }

            @Override
            public void onRecvMessageReadReceipts(List<V2TIMMessageReceipt> receiptList) {
                List<Object> list = new LinkedList<Object>();
                for (int i = 0; i < receiptList.size(); i++) {
                    list.add(CommonUtils.convertV2TIMMessageReceiptToMap(receiptList.get(i)));
                }
                makeAddAdvancedMsgListenerEventData("onRecvMessageReadReceipts", list);
            }

            @Override
            public void onRecvMessageRevoked(String msgID) {
                makeAddAdvancedMsgListenerEventData("onRecvMessageRevoked", msgID);
            }

            @Override
            public void onRecvMessageModified(V2TIMMessage msg) {
                makeAddAdvancedMsgListenerEventData("onRecvMessageModified", CommonUtils.convertV2TIMMessageToMap(msg));
            }

        };
        V2TIMManager.getMessageManager().addAdvancedMsgListener(advacedMessageListener);
        CommonUtils.returnSuccess(promise, "add advance msg listener success");
    }

    public void removeAdvancedMsgListener(Promise promise, ReadableMap arguments) {
        V2TIMManager.getMessageManager().removeAdvancedMsgListener(advacedMessageListener);
        CommonUtils.returnSuccess(promise, "removeAdvancedMsgListener is done");
    }

    private <T> void makeAddAdvancedMsgListenerEventData(String eventType, T data) {
        CommonUtils.emmitEvent("messageListener", eventType, data);
    }

    private <T> T getMapValue(HashMap<String, T> map, String key) {
        T value = map.get(key);
        return value;
    }

    private V2TIMOfflinePushInfo handleOfflinePushInfo(Promise promise, ReadableMap arguments) {
        HashMap<String, Object> offlinePushInfoParams = CommonUtils
                .convertReadableMapToHashMap(arguments.getMap("offlinePushInfo"));
        V2TIMOfflinePushInfo offlinePushInfo = new V2TIMOfflinePushInfo();
        if (offlinePushInfoParams != null) {
            String title = (String) offlinePushInfoParams.get("title");
            String offlineDesc = (String) offlinePushInfoParams.get("desc");
            Boolean disablePush = (Boolean) offlinePushInfoParams.get("disablePush");
            String ext = (String) offlinePushInfoParams.get("ext");
            String iOSSound = (String) offlinePushInfoParams.get("iOSSound");
            Boolean ignoreIOSBadge = (Boolean) offlinePushInfoParams.get("ignoreIOSBadge");
            String androidOPPOChannelID = (String) offlinePushInfoParams.get("androidOPPOChannelID");
            if (title != null) {
                offlinePushInfo.setTitle(title);
            }
            if (offlineDesc != null) {
                offlinePushInfo.setDesc(offlineDesc);
            }
            if (offlinePushInfoParams.get("disablePush") != null) {
                offlinePushInfo.disablePush(disablePush);
            }
            if (ext != null) {
                offlinePushInfo.setExt(ext.getBytes());
            }
            if (iOSSound != null) {
                offlinePushInfo.setIOSSound(iOSSound);
            }
            if (offlinePushInfoParams.get("ignoreIOSBadge") != null) {
                offlinePushInfo.setIgnoreIOSBadge(ignoreIOSBadge);
            }
            if (androidOPPOChannelID != null) {
                offlinePushInfo.setAndroidOPPOChannelID(androidOPPOChannelID);
            }
        }
        return offlinePushInfo;
    }

    // encapsulate send message
    private void handleSendMessage(
            final V2TIMMessage msg,
            String receiver,
            String groupID,
            int priority,
            boolean onlineUserOnly,
            V2TIMOfflinePushInfo offlinePushInfo,
            Promise promise, final String id) {
        V2TIMMessageManager mannager = V2TIMManager.getMessageManager();
        mannager.sendMessage(msg, receiver, groupID, priority, onlineUserOnly, offlinePushInfo,
                new V2TIMSendCallback<V2TIMMessage>() {
                    @Override
                    public void onProgress(int i) {
                        HashMap<String, Object> data = new HashMap<String, Object>();
                        data.put("message", CommonUtils.convertV2TIMMessageToMap(msg, i, id));
                        data.put("progress", i);
                        makeAddAdvancedMsgListenerEventData("onSendMessageProgress", data);
                    }

                    @Override
                    public void onError(int i, String s) {
                        // HashMap<String, Object> msgMap = CommonUtils.convertV2TIMMessageToMap(msg);
                        // msgMap.put("id", id);
                        messageIDMap.remove(id);
                        CommonUtils.returnError(promise, i, s);
                    }

                    @Override
                    public void onSuccess(V2TIMMessage v2TIMMessage) {
                        HashMap<String, Object> data = CommonUtils.convertV2TIMMessageToMap(v2TIMMessage);
                        data.put("id", id);
                        messageIDMap.remove(id);
                        CommonUtils.returnSuccess(promise, data);
                    }
                });
    }

    // Encapsulate the process of setting local id
    private void handleSetMessageMap(V2TIMMessage message, Promise promise) {
        final String id = String.valueOf(System.nanoTime());
        messageIDMap.put(id, message);

        HashMap<String, Object> resultMap = new HashMap<String, Object>();
        HashMap<String, Object> messageMap = CommonUtils.convertV2TIMMessageToMap(message);

        messageMap.put("id", id);
        resultMap.put("messageInfo", messageMap);
        resultMap.put("id", id);

        CommonUtils.returnSuccess(promise, resultMap);
    }

    public void createTextMessage(Promise promise, ReadableMap arguments) {
        String text = arguments.getString("text");
        final V2TIMMessage msg = V2TIMManager.getMessageManager().createTextMessage(text);
        handleSetMessageMap(msg, promise);
    }

    public void modifyMessage(Promise promise, ReadableMap arguments) {
        final Map<String, Object> message = CommonUtils.convertReadableMapToHashMap(arguments.getMap("message"));

        if (message.get("msgID") == null) {
            CommonUtils.returnError(promise, -1, "message not found");
            return;
        }
        String messageID = (String) message.get("msgID");
        LinkedList<String> list = new LinkedList<>();
        list.add(messageID);
        V2TIMManager.getMessageManager().findMessages(list, new V2TIMValueCallback<List<V2TIMMessage>>() {
            @Override
            public void onSuccess(List<V2TIMMessage> v2TIMMessages) {
                if (v2TIMMessages.size() == 1) {
                    V2TIMMessage currentMessage = v2TIMMessages.get(0);
                    if (message.get("cloudCustomData") != null) {
                        currentMessage.setLocalCustomData((String) message.get("cloudCustomData"));
                    }
                    if (message.get("localCustomInt") != null) {
                        currentMessage.setLocalCustomInt((int) message.get("localCustomInt"));
                    }
                    if (message.get("localCustomData") != null) {
                        currentMessage.setCloudCustomData((String) message.get("localCustomData"));
                    }
                    if (currentMessage.getElemType() == V2TIMMessage.V2TIM_ELEM_TYPE_TEXT) {
                        Map<String, Object> text = (Map<String, Object>) message.get("textElem");
                        if (text.get("text") != null) {
                            currentMessage.getTextElem().setText((String) text.get("text"));
                        }
                    }
                    if (currentMessage.getElemType() == V2TIMMessage.V2TIM_ELEM_TYPE_CUSTOM) {
                        Map<String, Object> custom = (Map<String, Object>) message.get("customElem");
                        if (custom.get("data") != null) {
                            currentMessage.getCustomElem().setData(((String) custom.get("data")).getBytes());
                        }
                        if (custom.get("desc") != null) {
                            currentMessage.getCustomElem().setDescription(((String) custom.get("desc")));
                        }
                        if (custom.get("extension") != null) {
                            currentMessage.getCustomElem().setExtension(((String) custom.get("extension")).getBytes());
                        }
                    }
                    V2TIMManager.getMessageManager().modifyMessage(currentMessage,
                            new V2TIMCompleteCallback<V2TIMMessage>() {
                                @Override
                                public void onComplete(int i, String s, V2TIMMessage v2TIMMessage) {
                                    HashMap<String, Object> res = new HashMap<String, Object>();
                                    res.put("code", i);
                                    res.put("desc", s);
                                    res.put("message", CommonUtils.convertV2TIMMessageToMap(v2TIMMessage));
                                    CommonUtils.returnSuccess(promise, res);
                                }
                            });
                } else {
                    CommonUtils.returnError(promise, -1, "message not found");
                }
            }

            @Override
            public void onError(int i, String s) {
                CommonUtils.returnError(promise, i, s);
            }
        });
    }

    public void createTargetedGroupMessage(Promise promise, ReadableMap arguments) {
        String id = arguments.getString("id");
        List<String> receiverList = CommonUtils.convertReadableArrayToListString(arguments.getArray("receiverList"));
        V2TIMMessage msg = messageIDMap.get(id);
        final V2TIMMessage newMsg = V2TIMManager.getMessageManager().createTargetedGroupMessage(msg, receiverList);
        handleSetMessageMap(newMsg, promise);
    }

    public void createCustomMessage(Promise promise, ReadableMap arguments) {
        String data = arguments.getString("data");
        String desc = arguments.getString("desc");
        String extension = arguments.getString("extension");
        final V2TIMMessage msg = V2TIMManager.getMessageManager().createCustomMessage(data.getBytes(), desc,
                extension.getBytes());
        handleSetMessageMap(msg, promise);
    }

    public void createImageMessage(Promise promise, ReadableMap arguments) {
        String imagePath = arguments.getString("imagePath");
        final V2TIMMessage msg = V2TIMManager.getMessageManager().createImageMessage(imagePath);
        handleSetMessageMap(msg, promise);
    }

    public void createSoundMessage(Promise promise, ReadableMap arguments) {
        String soundPath = arguments.getString("soundPath");
        int duration = arguments.getInt("duration");
        final V2TIMMessage msg = V2TIMManager.getMessageManager().createSoundMessage(soundPath, duration);
        handleSetMessageMap(msg, promise);
    }

    public void createVideoMessage(Promise promise, ReadableMap arguments) {
        String videoFilePath = arguments.getString("videoFilePath");
        String type = arguments.getString("type");
        String snapshotPath = arguments.getString("snapshotPath");
        int duration = arguments.getInt("duration");

        final V2TIMMessage msg = V2TIMManager.getMessageManager().createVideoMessage(videoFilePath, type, duration,
                snapshotPath);
        handleSetMessageMap(msg, promise);
    }

    public void createFileMessage(Promise promise, ReadableMap arguments) {
        String filePath = arguments.getString("filePath");
        String fileName = arguments.getString("fileName");
        final V2TIMMessage msg = V2TIMManager.getMessageManager().createFileMessage(filePath, fileName);
        handleSetMessageMap(msg, promise);
    }

    public void createLocationMessage(Promise promise, ReadableMap arguments) {
        String desc = arguments.getString("desc");
        double longitude = arguments.getDouble("longitude");
        double latitude = arguments.getDouble("latitude");
        final V2TIMMessage msg = V2TIMManager.getMessageManager().createLocationMessage(desc, longitude, latitude);
        handleSetMessageMap(msg, promise);
    }

    public void createFaceMessage(Promise promise, ReadableMap arguments) {
        int index = arguments.getInt("index");
        String data = arguments.getString("data");
        final V2TIMMessage msg = V2TIMManager.getMessageManager().createFaceMessage(index, data.getBytes());
        handleSetMessageMap(msg, promise);
    }

    public void createTextAtMessage(Promise promise, ReadableMap arguments) {
        String text = arguments.getString("text");
        List<String> atUserList = CommonUtils.convertReadableArrayToListString(arguments.getArray("atUserList"));
        final V2TIMMessage msg = V2TIMManager.getMessageManager().createTextAtMessage(text, atUserList);
        handleSetMessageMap(msg, promise);
    }

    public void createMergerMessage(Promise promise, ReadableMap arguments) {
        final String title = arguments.getString("title");
        final String compatibleText = arguments.getString("compatibleText");
        List<String> msgIDList = CommonUtils.convertReadableArrayToListString(arguments.getArray("msgIDList"));
        final List<String> abstractList = CommonUtils
                .convertReadableArrayToListString(arguments.getArray("abstractList"));
        final V2TIMMessageManager mannager = V2TIMManager.getMessageManager();

        V2TIMManager.getMessageManager().findMessages(msgIDList, new V2TIMValueCallback<List<V2TIMMessage>>() {
            @Override
            public void onSuccess(List<V2TIMMessage> v2TIMMessages) {
                if (v2TIMMessages.size() == 0) {
                    CommonUtils.returnError(promise, -1, "message not found");
                    return;
                }
                final V2TIMMessage msg = mannager.createMergerMessage(v2TIMMessages, title, abstractList,
                        compatibleText);
                handleSetMessageMap(msg, promise);
            }

            @Override
            public void onError(int i, String s) {
                CommonUtils.returnError(promise, i, s);
            }
        });
    }

    public void createForwardMessage(Promise promise, ReadableMap arguments) {
        final String msgID = arguments.getString("msgID");
        final V2TIMMessageManager mannager = V2TIMManager.getMessageManager();
        LinkedList<String> msgIDList = new LinkedList<String>();
        msgIDList.add(msgID);
        V2TIMManager.getMessageManager().findMessages(msgIDList, new V2TIMValueCallback<List<V2TIMMessage>>() {
            @Override
            public void onSuccess(List<V2TIMMessage> messageList) {
                if (messageList.size() != 1) {
                    CommonUtils.returnError(promise, -1, "message not found");
                    return;
                }
                final V2TIMMessage msg = mannager.createForwardMessage(messageList.get(0));
                handleSetMessageMap(msg, promise);
            }

            @Override
            public void onError(int i, String s) {
                CommonUtils.returnError(promise, i, s);
            }
        });
    }

    public void sendMessage(Promise promise, ReadableMap arguments) {
        String id = arguments.getString("id");
        String receiver = arguments.getString("receiver");
        String groupID = arguments.getString("groupID");
        final String cloudCustomData = arguments.getString("cloudCustomData");
        final String localCustomData = arguments.getString("localCustomData");
        final Boolean needReadReceipt = arguments.getBoolean("needReadReceipt");

        boolean isExcludedFromUnreadCount = arguments.getBoolean("isExcludedFromUnreadCount");
        boolean isExcludedFromLastMessage = arguments.getBoolean("isExcludedFromLastMessage");
        int priority = arguments.getInt("priority");

        V2TIMMessage msg = messageIDMap.get(id);

        if (id == null) {
            CommonUtils.returnError(promise, -1, "id not exist please try create again");
        }
        boolean onlineUserOnly = arguments.getBoolean("onlineUserOnly");

        if (cloudCustomData != null) {
            msg.setCloudCustomData(cloudCustomData);
        }
        if (localCustomData != null) {
            msg.setLocalCustomData(localCustomData);
        }

        if (needReadReceipt != null) {
            msg.setNeedReadReceipt(needReadReceipt);
        }

        V2TIMOfflinePushInfo offlinePushInfo = handleOfflinePushInfo(promise, arguments);
        msg.setExcludedFromUnreadCount(isExcludedFromUnreadCount);
        msg.setExcludedFromLastMessage(isExcludedFromLastMessage);
        handleSendMessage(msg, receiver, groupID, priority, onlineUserOnly, offlinePushInfo, promise, id);
    }

    public void downloadMergerMessage(Promise promise, ReadableMap arguments) {
        final String msgID = arguments.getString("msgID");
        List<String> msgIds = new LinkedList<String>();
        msgIds.add(msgID);
        V2TIMManager.getInstance().getMessageManager().findMessages(msgIds,
                new V2TIMValueCallback<List<V2TIMMessage>>() {
                    @Override
                    public void onSuccess(List<V2TIMMessage> v2TIMMessages) {
                        if (v2TIMMessages.size() == 1) {
                            V2TIMMergerElem message = v2TIMMessages.get(0).getMergerElem();
                            if (message != null) {
                                message.downloadMergerMessage(new V2TIMValueCallback<List<V2TIMMessage>>() {
                                    @Override
                                    public void onSuccess(List<V2TIMMessage> downMessages) {
                                        List<HashMap<String, Object>> downloadMessageMap = new LinkedList<>();
                                        for (int i = 0; i < downMessages.size(); i++) {
                                            HashMap<String, Object> obj = CommonUtils
                                                    .convertV2TIMMessageToMap(downMessages.get(i));
                                            downloadMessageMap.add(obj);
                                        }
                                        CommonUtils.returnSuccess(promise, downloadMessageMap);
                                    }

                                    @Override
                                    public void onError(int i, String s) {
                                        CommonUtils.returnError(promise, i, s);
                                    }
                                });
                            } else {
                                CommonUtils.returnError(promise, -1, "this message is not mergeElem");
                            }
                        } else {
                            CommonUtils.returnError(promise, -1, "message not found");
                        }
                    }

                    @Override
                    public void onError(int i, String s) {
                        CommonUtils.returnError(promise, i, s);
                    }
                });
    }

    public void reSendMessage(Promise promise, ReadableMap arguments) {
        String msgID = arguments.getString("msgID");
        final boolean onlineUserOnly = arguments.getBoolean("onlineUserOnly");
        List<String> msgList = new LinkedList<String>();
        msgList.add(msgID);
        final V2TIMMessageManager manager = V2TIMManager.getMessageManager();
        manager.findMessages(msgList, new V2TIMValueCallback<List<V2TIMMessage>>() {
            @Override
            public void onSuccess(List<V2TIMMessage> v2TIMMessages) {
                if (v2TIMMessages.size() == 1) {
                    final V2TIMMessage message = v2TIMMessages.get(0);
                    V2TIMOfflinePushInfo offlinePushInfo = message.getOfflinePushInfo();
                    String groupId = message.getGroupID();
                    String reciever = message.getUserID();
                    int priority = message.getPriority();
                    manager.sendMessage(message, reciever, groupId, priority, onlineUserOnly, offlinePushInfo,
                            new V2TIMSendCallback<V2TIMMessage>() {
                                @Override
                                public void onProgress(int i) {
                                    HashMap<String, Object> data = new HashMap<String, Object>();
                                    data.put("message", CommonUtils.convertV2TIMMessageToMap(message, i));
                                    data.put("progress", i);
                                    makeAddAdvancedMsgListenerEventData("onSendMessageProgress", data);
                                }

                                @Override
                                public void onSuccess(V2TIMMessage v2TIMMessage) {
                                    CommonUtils.returnSuccess(promise,
                                            CommonUtils.convertV2TIMMessageToMap(v2TIMMessage));
                                }

                                @Override
                                public void onError(int i, String s) {
                                    CommonUtils.returnError(promise, i, s);
                                    // CommonUtils.returnError(promise, i, s,
                                    // CommonUtils.convertV2TIMMessageToMap(message));
                                }
                            });
                } else {
                    CommonUtils.returnError(promise, -1, "message not found");
                }
            }

            @Override
            public void onError(int i, String s) {
                CommonUtils.returnError(promise, i, s);
            }
        });
    }

    public void setC2CReceiveMessageOpt(Promise promise, ReadableMap arguments) {
        List<String> userIDList = CommonUtils.convertReadableArrayToListString(arguments.getArray("userIDList"));
        int opt = arguments.getInt("opt");
        V2TIMManager.getMessageManager().setC2CReceiveMessageOpt(userIDList, opt, new V2TIMCallback() {
            @Override
            public void onSuccess() {
                CommonUtils.returnSuccess(promise, null);
            }

            @Override
            public void onError(int i, String s) {
                CommonUtils.returnError(promise, i, s);
            }
        });
    }

    public void getC2CReceiveMessageOpt(Promise promise, ReadableMap arguments) {
        List<String> userIDList = CommonUtils.convertReadableArrayToListString(arguments.getArray("userIDList"));
        V2TIMManager.getMessageManager().getC2CReceiveMessageOpt(userIDList,
                new V2TIMValueCallback<List<V2TIMReceiveMessageOptInfo>>() {
                    @Override
                    public void onSuccess(List<V2TIMReceiveMessageOptInfo> v2TIMReceiveMessageOptInfos) {
                        LinkedList<HashMap<String, Object>> list = new LinkedList<HashMap<String, Object>>();
                        for (int i = 0; i < v2TIMReceiveMessageOptInfos.size(); i++) {
                            list.add(CommonUtils
                                    .convertV2TIMReceiveMessageOptInfoToMap(v2TIMReceiveMessageOptInfos.get(i)));
                        }
                        CommonUtils.returnSuccess(promise, list);
                    }

                    @Override
                    public void onError(int i, String s) {
                        CommonUtils.returnError(promise, i, s);
                    }
                });
    }

    public void setGroupReceiveMessageOpt(Promise promise, ReadableMap arguments) {
        String groupID = arguments.getString("groupID");
        int opt = arguments.getInt("opt");
        V2TIMManager.getMessageManager().setGroupReceiveMessageOpt(groupID, opt, new V2TIMCallback() {
            @Override
            public void onSuccess() {
                CommonUtils.returnSuccess(promise, null);
            }

            @Override
            public void onError(int i, String s) {
                CommonUtils.returnError(promise, i, s);
            }
        });
    }

    public void setLocalCustomData(Promise promise, ReadableMap arguments) {
        String msgID = arguments.getString("msgID");
        final String localCustomData = arguments.getString("localCustomData");
        List<String> msgList = new LinkedList<String>();
        msgList.add(msgID);
        V2TIMManager.getMessageManager().findMessages(msgList, new V2TIMValueCallback<List<V2TIMMessage>>() {
            @Override
            public void onSuccess(List<V2TIMMessage> v2TIMMessages) {
                if (v2TIMMessages.size() == 1) {
                    v2TIMMessages.get(0).setLocalCustomData(localCustomData);
                    CommonUtils.returnSuccess(promise, null);
                } else {
                    CommonUtils.returnError(promise, -1, "message not found");
                }
            }

            @Override
            public void onError(int code, String desc) {
                CommonUtils.returnError(promise, code, desc);
            }
        });
    }

    public void setLocalCustomInt(Promise promise, ReadableMap arguments) {
        String msgID = arguments.getString("msgID");
        final int localCustomInt = arguments.getInt("localCustomInt");
        List<String> msgList = new LinkedList<String>();
        msgList.add(msgID);
        V2TIMManager.getMessageManager().findMessages(msgList, new V2TIMValueCallback<List<V2TIMMessage>>() {
            @Override
            public void onSuccess(List<V2TIMMessage> v2TIMMessages) {
                if (v2TIMMessages.size() == 1) {
                    v2TIMMessages.get(0).setLocalCustomInt(localCustomInt);
                    CommonUtils.returnSuccess(promise, null);
                } else {
                    CommonUtils.returnError(promise, -1, "message not found");
                }
            }

            @Override
            public void onError(int code, String desc) {
                CommonUtils.returnError(promise, code, desc);
            }
        });
    }

    public void setCloudCustomData(Promise promise, ReadableMap arguments) {
        String msgID = arguments.getString("msgID");
        final String data = arguments.getString("data");
        List<String> msgList = new LinkedList<String>();
        msgList.add(msgID);
        V2TIMManager.getMessageManager().findMessages(msgList, new V2TIMValueCallback<List<V2TIMMessage>>() {
            @Override
            public void onSuccess(List<V2TIMMessage> v2TIMMessages) {
                if (v2TIMMessages.size() == 1) {
                    v2TIMMessages.get(0).setCloudCustomData(data);
                    CommonUtils.returnSuccess(promise, null);
                } else {
                    CommonUtils.returnError(promise, -1, "message not found");
                }
            }

            @Override
            public void onError(int code, String desc) {
                CommonUtils.returnError(promise, code, desc);
            }
        });
    }

    public void getC2CHistoryMessageList(Promise promise, ReadableMap arguments) {

        final int count = arguments.getInt("count");
        final String userID = arguments.getString("userID");
        final String lastMsgID = arguments.getString("lastMsgID");
        final List<String> list = new LinkedList<String>();
        if (lastMsgID != null) {
            list.add(lastMsgID);
        }
        if (list.size() > 0) {
            V2TIMManager.getMessageManager().findMessages(list, new V2TIMValueCallback<List<V2TIMMessage>>() {
                @Override
                public void onError(int i, String s) {
                    CommonUtils.returnError(promise, i, s);
                }

                @Override
                public void onSuccess(List<V2TIMMessage> v2TIMMessages) {
                    if (v2TIMMessages.size() > 0) {
                        V2TIMMessage msg = v2TIMMessages.get(0);
                        V2TIMManager.getMessageManager().getC2CHistoryMessageList(userID, count, msg,
                                new V2TIMValueCallback<List<V2TIMMessage>>() {
                                    @Override
                                    public void onError(int i, String s) {
                                        CommonUtils.returnError(promise, i, s);
                                    }

                                    @Override
                                    public void onSuccess(List<V2TIMMessage> v2TIMMessages) {
                                        LinkedList<HashMap<String, Object>> list = new LinkedList<HashMap<String, Object>>();
                                        for (int i = 0; i < v2TIMMessages.size(); i++) {
                                            list.add(CommonUtils.convertV2TIMMessageToMap(v2TIMMessages.get(i)));
                                        }
                                        CommonUtils.returnSuccess(promise, list);
                                    }
                                });
                    } else {
                        CommonUtils.returnError(promise, -1, "message not found");
                    }
                }
            });
        } else {
            V2TIMManager.getMessageManager().getC2CHistoryMessageList(userID, count, null,
                    new V2TIMValueCallback<List<V2TIMMessage>>() {
                        @Override
                        public void onError(int i, String s) {
                            CommonUtils.returnError(promise, i, s);
                        }

                        @Override
                        public void onSuccess(List<V2TIMMessage> v2TIMMessages) {
                            LinkedList<HashMap<String, Object>> list = new LinkedList<HashMap<String, Object>>();
                            for (int i = 0; i < v2TIMMessages.size(); i++) {
                                list.add(CommonUtils.convertV2TIMMessageToMap(v2TIMMessages.get(i)));
                            }
                            CommonUtils.returnSuccess(promise, list);
                        }
                    });
        }

    }

    public void getGroupHistoryMessageList(Promise promise, ReadableMap arguments) {
        final int count = arguments.getInt("count");
        final String groupID = arguments.getString("groupID");
        final String lastMsgID = arguments.getString("lastMsgID");
        final List<String> list = new LinkedList<String>();
        if (lastMsgID != null) {
            list.add(lastMsgID);
        }
        if (list.size() > 0) {
            V2TIMManager.getMessageManager().findMessages(list, new V2TIMValueCallback<List<V2TIMMessage>>() {
                @Override
                public void onError(int i, String s) {
                    CommonUtils.returnError(promise, i, s);
                }

                @Override
                public void onSuccess(List<V2TIMMessage> v2TIMMessages) {
                    if (v2TIMMessages.size() > 0) {
                        V2TIMManager.getMessageManager().getGroupHistoryMessageList(groupID, count,
                                v2TIMMessages.get(0), new V2TIMValueCallback<List<V2TIMMessage>>() {
                                    @Override
                                    public void onError(int i, String s) {
                                        CommonUtils.returnError(promise, i, s);
                                    }

                                    @Override
                                    public void onSuccess(List<V2TIMMessage> v2TIMMessages) {
                                        LinkedList<HashMap<String, Object>> list = new LinkedList<HashMap<String, Object>>();

                                        for (int i = 0; i < v2TIMMessages.size(); i++) {
                                            list.add(CommonUtils.convertV2TIMMessageToMap(v2TIMMessages.get(i)));
                                        }
                                        CommonUtils.returnSuccess(promise, list);
                                    }
                                });
                    } else {
                        CommonUtils.returnError(promise, -1, "message not found");
                    }
                }
            });
        } else {
            V2TIMManager.getMessageManager().getGroupHistoryMessageList(groupID, count, null,
                    new V2TIMValueCallback<List<V2TIMMessage>>() {
                        @Override
                        public void onError(int i, String s) {
                            CommonUtils.returnError(promise, i, s);
                        }

                        @Override
                        public void onSuccess(List<V2TIMMessage> v2TIMMessages) {
                            LinkedList<HashMap<String, Object>> list = new LinkedList<HashMap<String, Object>>();
                            for (int i = 0; i < v2TIMMessages.size(); i++) {
                                list.add(CommonUtils.convertV2TIMMessageToMap(v2TIMMessages.get(i)));
                            }
                            CommonUtils.returnSuccess(promise, list);
                        }
                    });
        }
    }

    public void getHistoryMessageList(Promise promise, ReadableMap arguments) {
        int getType = arguments.getInt("getType");
        String userID = arguments.getString("userID");
        String groupID = arguments.getString("groupID");
        final String lastMsgID = arguments.getString("lastMsgID");
        int lastMsgSeq = arguments.getInt("lastMsgSeq");
        int count = arguments.getInt("count");

        final V2TIMMessageListGetOption option = new V2TIMMessageListGetOption();
        option.setCount(count);
        option.setGetType(getType);
        if (groupID != null) {
            option.setGroupID(groupID);
        }
        if (userID != null) {
            option.setUserID(userID);
        }
        if (lastMsgSeq != -1) {
            option.setLastMsgSeq(lastMsgSeq);
        }
        if (arguments.getArray("messageTypeList") != null) {
            List<Integer> messageTypeList = CommonUtils
                    .convertReadableArrayToListInt(arguments.getArray("messageTypeList"));
            option.setMessageTypeList(messageTypeList);
        }
        List<String> msglist = new LinkedList<String>();
        if (lastMsgID != null) {
            msglist.add(lastMsgID);
            V2TIMManager.getMessageManager().findMessages(msglist, new V2TIMValueCallback<List<V2TIMMessage>>() {
                @Override
                public void onSuccess(List<V2TIMMessage> v2TIMMessages) {
                    if (v2TIMMessages.size() == 1) {
                        // found message
                        option.setLastMsg(v2TIMMessages.get(0));
                        V2TIMManager.getMessageManager().getHistoryMessageList(option,
                                new V2TIMValueCallback<List<V2TIMMessage>>() {
                                    @Override
                                    public void onSuccess(List<V2TIMMessage> v2TIMMessages) {
                                        LinkedList<HashMap<String, Object>> msgs = new LinkedList<HashMap<String, Object>>();
                                        for (int i = 0; i < v2TIMMessages.size(); i++) {
                                            HashMap<String, Object> msg = CommonUtils
                                                    .convertV2TIMMessageToMap(v2TIMMessages.get(i));
                                            msgs.add(msg);
                                        }
                                        CommonUtils.returnSuccess(promise, msgs);
                                    }

                                    @Override
                                    public void onError(int code, String desc) {
                                        CommonUtils.returnError(promise, code, desc);
                                    }
                                });
                    } else {
                        CommonUtils.returnError(promise, -1, "message not found");
                    }
                }

                @Override
                public void onError(int code, String desc) {
                    CommonUtils.returnError(promise, code, desc);
                }
            });
        } else {
            V2TIMManager.getMessageManager().getHistoryMessageList(option,
                    new V2TIMValueCallback<List<V2TIMMessage>>() {
                        @Override
                        public void onSuccess(List<V2TIMMessage> v2TIMMessages) {
                            List<HashMap<String, Object>> msgs = new LinkedList<HashMap<String, Object>>();
                            for (int i = 0; i < v2TIMMessages.size(); i++) {
                                msgs.add(CommonUtils.convertV2TIMMessageToMap(v2TIMMessages.get(i)));
                            }
                            CommonUtils.returnSuccess(promise, msgs);
                        }

                        @Override
                        public void onError(int code, String desc) {
                            CommonUtils.returnError(promise, code, desc);
                        }
                    });
        }
    }

    public void revokeMessage(Promise promise, ReadableMap arguments) {
        final String msgID = arguments.getString("msgID");
        LinkedList<String> list = new LinkedList<>();
        list.add(msgID);
        V2TIMManager.getMessageManager().findMessages(list, new V2TIMValueCallback<List<V2TIMMessage>>() {
            @Override
            public void onError(int i, String s) {
                CommonUtils.returnError(promise, i, s);
            }

            @Override
            public void onSuccess(List<V2TIMMessage> v2TIMMessages) {
                if (v2TIMMessages.size() > 0) {
                    V2TIMManager.getMessageManager().revokeMessage(v2TIMMessages.get(0), new V2TIMCallback() {
                        @Override
                        public void onError(int i, String s) {
                            CommonUtils.returnError(promise, i, s);
                        }

                        @Override
                        public void onSuccess() {
                            CommonUtils.returnSuccess(promise, null);
                        }
                    });
                } else {
                    CommonUtils.returnError(promise, -1, "messages not found");
                }
            }
        });

    }

    public void markC2CMessageAsRead(Promise promise, ReadableMap arguments) {
        String userID = arguments.getString("userID");
        V2TIMManager.getMessageManager().markC2CMessageAsRead(userID, new V2TIMCallback() {
            @Override
            public void onError(int i, String s) {
                CommonUtils.returnError(promise, i, s);
            }

            @Override
            public void onSuccess() {
                CommonUtils.returnSuccess(promise, null);
            }
        });
    }

    public void markGroupMessageAsRead(Promise promise, ReadableMap arguments) {
        String groupID = arguments.getString("groupID");
        V2TIMManager.getMessageManager().markGroupMessageAsRead(groupID, new V2TIMCallback() {
            @Override
            public void onError(int i, String s) {
                CommonUtils.returnError(promise, i, s);
            }

            @Override
            public void onSuccess() {
                CommonUtils.returnSuccess(promise, null);
            }
        });
    }

    public void markAllMessageAsRead(Promise promise, ReadableMap arguments) {
        V2TIMManager.getMessageManager().markAllMessageAsRead(new V2TIMCallback() {
            @Override
            public void onError(int i, String s) {
                CommonUtils.returnError(promise, i, s);
            }

            @Override
            public void onSuccess() {
                CommonUtils.returnSuccess(promise, null);
            }
        });
    }

    public void deleteMessageFromLocalStorage(Promise promise, ReadableMap arguments) {
        final String msgID = arguments.getString("msgID");
        LinkedList<String> list = new LinkedList<>();
        list.add(msgID);
        V2TIMManager.getMessageManager().findMessages(list, new V2TIMValueCallback<List<V2TIMMessage>>() {
            @Override
            public void onError(int i, String s) {
                CommonUtils.returnError(promise, i, s);
            }

            @Override
            public void onSuccess(List<V2TIMMessage> v2TIMMessages) {
                if (v2TIMMessages.size() > 0) {
                    V2TIMManager.getMessageManager().deleteMessageFromLocalStorage(v2TIMMessages.get(0),
                            new V2TIMCallback() {
                                @Override
                                public void onError(int i, String s) {
                                    CommonUtils.returnError(promise, i, s);
                                }

                                @Override
                                public void onSuccess() {
                                    CommonUtils.returnSuccess(promise, null);
                                }
                            });
                } else {
                    CommonUtils.returnError(promise, -1, "messages not found");
                }
            }
        });
    }

    public void deleteMessages(Promise promise, ReadableMap arguments) {
        final List<String> msgIDs = CommonUtils.convertReadableArrayToListString(arguments.getArray("msgIDs"));
        V2TIMManager.getMessageManager().findMessages(msgIDs, new V2TIMValueCallback<List<V2TIMMessage>>() {
            @Override
            public void onError(int i, String s) {
                CommonUtils.returnError(promise, i, s);
            }

            @Override
            public void onSuccess(List<V2TIMMessage> v2TIMMessages) {
                System.out.println("find arrived message" + v2TIMMessages.size());
                if (v2TIMMessages.size() > 0) {
                    V2TIMManager.getMessageManager().deleteMessages(v2TIMMessages, new V2TIMCallback() {
                        @Override
                        public void onError(int i, String s) {
                            CommonUtils.returnError(promise, i, s);
                        }

                        @Override
                        public void onSuccess() {
                            CommonUtils.returnSuccess(promise, null);
                        }
                    });
                } else {
                    CommonUtils.returnError(promise, -1, "messages not found");
                }
            }
        });
    }

    public void sendMessageReadReceipts(Promise promise, ReadableMap arguments) {
        final List<String> messageIDList = CommonUtils
                .convertReadableArrayToListString(arguments.getArray("messageIDList"));
        V2TIMManager.getMessageManager().findMessages(messageIDList, new V2TIMValueCallback<List<V2TIMMessage>>() {
            @Override
            public void onError(int i, String s) {
                CommonUtils.returnError(promise, i, s);
            }

            @Override
            public void onSuccess(List<V2TIMMessage> v2TIMMessages) {
                if (v2TIMMessages.size() == messageIDList.size()) {
                    V2TIMManager.getMessageManager().sendMessageReadReceipts(v2TIMMessages, new V2TIMCallback() {
                        @Override
                        public void onError(int i, String s) {
                            CommonUtils.returnError(promise, i, s);
                        }

                        @Override
                        public void onSuccess() {
                            CommonUtils.returnSuccess(promise, null);
                        }
                    });
                } else {
                    CommonUtils.returnError(promise, -1, "messages not found");
                }
            }
        });
    }

    public void getMessageReadReceipts(Promise promise, ReadableMap arguments) {
        final List<String> messageIDList = CommonUtils
                .convertReadableArrayToListString(arguments.getArray("messageIDList"));
        V2TIMManager.getMessageManager().findMessages(messageIDList, new V2TIMValueCallback<List<V2TIMMessage>>() {
            @Override
            public void onError(int i, String s) {
                CommonUtils.returnError(promise, i, s);
            }

            @Override
            public void onSuccess(List<V2TIMMessage> v2TIMMessages) {
                if (v2TIMMessages.size() == messageIDList.size()) {
                    V2TIMManager.getMessageManager().getMessageReadReceipts(v2TIMMessages,
                            new V2TIMValueCallback<List<V2TIMMessageReceipt>>() {
                                @Override
                                public void onError(int i, String s) {
                                    CommonUtils.returnError(promise, i, s);
                                }

                                @Override
                                public void onSuccess(List<V2TIMMessageReceipt> receiptList) {
                                    List<Object> list = new LinkedList<Object>();
                                    for (int i = 0; i < receiptList.size(); i++) {
                                        list.add(CommonUtils.convertV2TIMMessageReceiptToMap(receiptList.get(i)));
                                    }
                                    CommonUtils.returnSuccess(promise, list);
                                }
                            });
                } else {
                    CommonUtils.returnError(promise, -1, "messages not found");
                }
            }
        });
    }

    public void getGroupMessageReadMemberList(Promise promise, ReadableMap arguments) {
        final String messageID = arguments.getString("messageID");
        final int filter = arguments.getInt("filter");
        final int nextSeqParams = arguments.getInt("nextSeq");
        final int count = arguments.getInt("count");
        final long nextSeq = new Long(nextSeqParams);

        LinkedList<String> msgList = new LinkedList<>();

        msgList.add(messageID);

        V2TIMManager.getMessageManager().findMessages(msgList, new V2TIMValueCallback<List<V2TIMMessage>>() {
            @Override
            public void onError(int i, String s) {
                CommonUtils.returnError(promise, i, s);
            }

            @Override
            public void onSuccess(List<V2TIMMessage> v2TIMMessages) {
                if (v2TIMMessages.size() == 1) {
                    V2TIMManager.getMessageManager().getGroupMessageReadMemberList(v2TIMMessages.get(0), filter,
                            nextSeq, count, new V2TIMValueCallback<V2TIMGroupMessageReadMemberList>() {
                                @Override
                                public void onError(int i, String s) {

                                    CommonUtils.returnError(promise, i, s);
                                }

                                @Override
                                public void onSuccess(V2TIMGroupMessageReadMemberList memberlist) {
                                    CommonUtils.returnSuccess(promise,
                                            CommonUtils.converV2TIMGroupMessageReadMemberListToMap(memberlist));
                                }
                            });
                } else {
                    CommonUtils.returnError(promise, -1, "messages not found");
                }
            }
        });
    }

    public void insertGroupMessageToLocalStorage(final Promise promise, ReadableMap arguments) {
        final String data = arguments.getString("data");
        final String groupID = arguments.getString("groupID");
        final String sender = arguments.getString("sender");

        V2TIMMessageManager msgManager = V2TIMManager.getInstance().getMessageManager();
        final V2TIMMessage msg = msgManager.createCustomMessage(data.getBytes());

        V2TIMManager.getMessageManager().insertGroupMessageToLocalStorage(msg, groupID, sender,
                new V2TIMValueCallback<V2TIMMessage>() {
                    @Override
                    public void onError(int i, String s) {
                        CommonUtils.returnError(promise, i, s);
                    }

                    @Override
                    public void onSuccess(V2TIMMessage v2TIMMessage) {
                        CommonUtils.returnSuccess(promise, CommonUtils.convertV2TIMMessageToMap(v2TIMMessage));
                    }
                });
    }

    public void insertC2CMessageToLocalStorage(final Promise promise, ReadableMap arguments) {
        final String data = arguments.getString("data");
        final String userID = arguments.getString("userID");
        final String sender = arguments.getString("sender");
        V2TIMMessageManager msgManager = V2TIMManager.getInstance().getMessageManager();
        V2TIMMessage msg = msgManager.createCustomMessage(data.getBytes());
        msgManager.insertC2CMessageToLocalStorage(msg, userID, sender, new V2TIMValueCallback<V2TIMMessage>() {
            @Override
            public void onSuccess(V2TIMMessage v2TIMMessage) {
                CommonUtils.returnSuccess(promise, CommonUtils.convertV2TIMMessageToMap(v2TIMMessage));
            }

            @Override
            public void onError(int code, String desc) {
                CommonUtils.returnError(promise, code, desc);
            }
        });

    }

    public void clearC2CHistoryMessage(final Promise promise, ReadableMap arguments) {
        String userID = arguments.getString("userID");
        V2TIMManager.getMessageManager().clearC2CHistoryMessage(userID, new V2TIMCallback() {
            @Override
            public void onSuccess() {
                CommonUtils.returnSuccess(promise, null);
            }

            @Override
            public void onError(int code, String desc) {
                CommonUtils.returnError(promise, code, desc);
            }
        });
    }

    public void clearGroupHistoryMessage(final Promise promise, ReadableMap arguments) {
        String groupID = arguments.getString("groupID");
        V2TIMManager.getMessageManager().clearGroupHistoryMessage(groupID, new V2TIMCallback() {
            @Override
            public void onSuccess() {
                CommonUtils.returnSuccess(promise, null);
            }

            @Override
            public void onError(int code, String desc) {
                CommonUtils.returnError(promise, code, desc);
            }
        });
    }

    public void searchLocalMessages(final Promise promise, ReadableMap arguments) {
        HashMap<String, Object> searchParam = CommonUtils.convertReadableMapToHashMap(arguments.getMap("searchParam"));
        V2TIMMessageSearchParam param = new V2TIMMessageSearchParam();
        if (searchParam.get("conversationID") != null) {
            param.setConversationID((String) searchParam.get("conversationID"));
        }
        if (searchParam.get("keywordList") != null) {
            param.setKeywordList((List<String>) searchParam.get("keywordList"));
        }
        if (searchParam.get("type") != null) {
            param.setKeywordListMatchType((Integer) searchParam.get("type"));
        }
        if (searchParam.get("userIDList") != null) {
            param.setSenderUserIDList((List<String>) searchParam.get("userIDList"));
        }
        if (searchParam.get("messageTypeList") != null) {
            param.setMessageTypeList((List<Integer>) searchParam.get("messageTypeList"));
        }
        if (searchParam.get("searchTimePosition") != null) {
            param.setSearchTimePosition((Integer) searchParam.get("searchTimePosition"));
        }
        if (searchParam.get("searchTimePeriod") != null) {
            param.setSearchTimePeriod((Integer) searchParam.get("searchTimePeriod"));
        }
        if (searchParam.get("pageSize") != null) {
            param.setPageSize((Integer) searchParam.get("pageSize"));
        }
        if (searchParam.get("pageIndex") != null) {
            param.setPageIndex((Integer) searchParam.get("pageIndex"));
        }
        V2TIMManager.getMessageManager().searchLocalMessages(param, new V2TIMValueCallback<V2TIMMessageSearchResult>() {
            @Override
            public void onSuccess(V2TIMMessageSearchResult v2TIMMessageSearchResult) {
                CommonUtils.returnSuccess(promise,
                        CommonUtils.convertV2TIMMessageSearchResultToMap(v2TIMMessageSearchResult));
            }

            @Override
            public void onError(int code, String desc) {
                CommonUtils.returnError(promise, code, desc);
            }
        });
    }

    public void findMessages(final Promise promise, ReadableMap arguments) {
        List<String> messageIDList = CommonUtils.convertReadableArrayToListString(arguments.getArray("messageIDList"));
        V2TIMManager.getMessageManager().findMessages(messageIDList, new V2TIMValueCallback<List<V2TIMMessage>>() {
            @Override
            public void onSuccess(List<V2TIMMessage> v2TIMMessages) {
                LinkedList<HashMap<String, Object>> messageList = new LinkedList<>();
                for (int i = 0; i < v2TIMMessages.size(); i++) {
                    messageList.add(CommonUtils.convertV2TIMMessageToMap(v2TIMMessages.get(i)));
                }
                CommonUtils.returnSuccess(promise, messageList);
            }

            @Override
            public void onError(int code, String desc) {
                CommonUtils.returnError(promise, code, desc);
            }
        });
    }
}
