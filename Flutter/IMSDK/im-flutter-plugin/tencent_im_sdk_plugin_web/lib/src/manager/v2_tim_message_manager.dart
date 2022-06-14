// ignore_for_file: unused_import, library_prefixes, prefer_typing_uninitialized_variables, duplicate_ignore

import 'dart:collection';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:path/path.dart' as Path;

import 'package:js/js.dart';
import 'package:js/js_util.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/enum/V2TimAdvancedMsgListener.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_message_receipt.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_message_search_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_receive_message_opt_info.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin_web/src/enum/event_enum.dart';
import 'package:tencent_im_sdk_plugin_web/src/enum/group_receive_message_opt.dart';
import 'package:tencent_im_sdk_plugin_web/src/models/v2_tim_create_message.dart';
import 'package:tencent_im_sdk_plugin_web/src/models/v2_tim_get_message_list.dart';
import 'package:tencent_im_sdk_plugin_web/src/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin_web/src/utils/utils.dart';
import 'im_sdk_plugin_js.dart';
import 'package:mime_type/mime_type.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_msg_create_info_result.dart';

class V2TIMMessageManager {
  static late TIM? timeweb;
  static V2TimAdvancedMsgListener? messageListener;

  static int currentTimeMillis() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  Map<String, dynamic> messageIDMap = {}; // 和native那边略有区别，web在发送信息时才会创建消息

  V2TIMMessageManager() {
    timeweb = V2TIMManagerWeb.timWeb;
  }
  // 设置uuid，保证发送时可以直接拿到底层返回过来的messahe
  handleSetMessageMap(messageInfo) {
    String id = (currentTimeMillis()).toString();

    Map<String, dynamic> resultMap = {"messageInfo": messageInfo, "id": id};
    messageIDMap[id] = resultMap;

    return resultMap;
  }

  /*
      V2TIM_ELEM_TYPE_NONE                      = 0,  ///< 未知消息
    V2TIM_ELEM_TYPE_TEXT                      = 1,  ///< 文本消息
    V2TIM_ELEM_TYPE_CUSTOM                    = 2,  ///< 自定义消息
    V2TIM_ELEM_TYPE_IMAGE                     = 3,  ///< 图片消息
    V2TIM_ELEM_TYPE_SOUND                     = 4,  ///< 语音消息
    V2TIM_ELEM_TYPE_VIDEO                     = 5,  ///< 视频消息
    V2TIM_ELEM_TYPE_FILE                      = 6,  ///< 文件消息
    V2TIM_ELEM_TYPE_LOCATION                  = 7,  ///< 地理位置消息
    V2TIM_ELEM_TYPE_FACE                      = 8,  ///< 表情消息
    V2TIM_ELEM_TYPE_GROUP_TIPS                = 9,  ///< 群 Tips 消息
    V2TIM_ELEM_TYPE_MERGER                    = 10, ///< 合并消息
  */
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createMessage<T, F>(
      {required String type, required Map<String, dynamic> params}) async {
    var messageSimpleElem = {};
    switch (type) {
      case "text":
        {
          var text = params['text'] ?? '';
          messageSimpleElem = CreateMessage.createSimpleTextMessage(text);
          break;
        }
      case "custom":
        {
          String data = params['data'] ?? '';
          String desc = params['desc'] ?? "";
          String extension = params['extension'];
          messageSimpleElem =
              CreateMessage.createSimpleCustomMessage(data, desc, extension);
          break;
        }
      case "face":
        {
          int index = params['index'] ?? '';
          String data = params['data'] ?? '';
          messageSimpleElem =
              CreateMessage.createSimpleFaceMessage(index: index, data: data);
          break;
        }
      case "image":
        {
          String imagePath = params['imagePath'] ?? '';
          Uint8List fileContent = params['fileContent'];
          String fileName = params['fileName'];
          dynamic file = params['file'];
          messageSimpleElem = CreateMessage.createSimpleImageMessage(
              imagePath, fileContent, fileName, file);
          break;
        }
      case "textAt":
        {
          String text = params['text'] ?? '';
          List<String> atUserList = params['atUserList'] ?? [];
          messageSimpleElem = CreateMessage.createSimpleAtText(
              atUserList: atUserList, text: text);
          break;
        }
      case "location":
        {
          String desc = params['description'] ?? '';
          double longitude = params['longitude'] ?? 0;
          double latitude = params['latitude'] ?? 0;
          messageSimpleElem = CreateMessage.createSimpleLoaction(
              description: desc, longitude: longitude, latitude: latitude);
          break;
        }
      case "mergeMessage":
        {
          List<String> msgIDList = params['msgIDList'] ?? [];
          String title = params['title'] ?? "";
          String abstractList = params['abstractList'][0] ?? '';
          String compatibleText = params['compatibleText'];
          messageSimpleElem = CreateMessage.createSimpleMergeMessage(
              msgIDList: msgIDList,
              title: title,
              abstractList: abstractList,
              compatibleText: compatibleText);
          break;
        }
      case "forwardMessage":
        {
          break;
        }
      case "video":
        {
          String videoFilePath = params['videoFilePath'] ?? '';
          Uint8List fileContent = params['fileContent'];
          String fileName = params['fileName'];
          dynamic file = params['file'];
          messageSimpleElem = CreateMessage.createSimpleVideoMessage(
              videoFilePath, fileContent, file, fileName);
          break;
        }
      case "file":
        {
          messageSimpleElem = CreateMessage.createSimpleFileMessage(
              fileContent: params['fileContent'],
              filePath: params['filePath'] ?? '',
              fileName: params['fileName'] ?? "",
              file: params['file']);
          break;
        }
    }
    var result = handleSetMessageMap(messageSimpleElem);
    return CommonUtils.returnSuccess<V2TimMsgCreateInfoResult>(result);
  }

  // 3.6.0后启用此函数
  Future<dynamic> sendMessageForNew<T, F>(
      {required Map<String, dynamic> params}) async {
    String? id = params['id'];
    try {
      final groupID = params['groupID'] ?? '';
      final recveiver = params['receiver'] ?? '';
      final haveTwoValues = groupID != '' && recveiver != '';

      final messageMap = messageIDMap[id];
      final messageInfo = messageMap["messageInfo"];
      final type = messageMap["messageInfo"]["type"];
      if (haveTwoValues) {
        return CommonUtils.returnErrorForValueCb<F>({
          'code': 6017,
          'desc': "receiver and groupID cannot set at the same time",
          'data': V2TimMessage(elemType: 1).toJson()
        });
      }
      if (id == null || messageMap == null) {
        return CommonUtils.returnErrorForValueCb<F>({
          'code': 6017,
          'desc': "id cannot be empty or message cannot find",
          'data': V2TimMessage(elemType: 1).toJson()
        });
      }
      final convType = groupID != '' ? 'GROUP' : 'C2C';
      final sendToUserID = convType == 'GROUP' ? groupID : recveiver;
      var messageElem;
      switch (type) {
        case "text":
          {
            String text = messageInfo["textElem"]["text"];
            final createElemParams = CreateMessage.createTextMessage(
                userID: sendToUserID,
                text: text,
                convType: convType,
                priority: params['priority']);
            messageElem = timeweb!.createTextMessage(createElemParams);
            break;
          }
        case "custom":
          {
            final customMessage = CreateMessage.createCustomMessage(
                userID: sendToUserID,
                customData: messageInfo["customElem"]["data"],
                convType: convType,
                extension: messageInfo['customElem']['extension'],
                description: messageInfo['customElem']['desc'],
                priority: params['priority']);
            messageElem = timeweb!.createCustomMessage(customMessage);
            break;
          }
        case "face":
          {
            final faceMessage = CreateMessage.createFaceMessage(
                userID: sendToUserID,
                data: messageInfo["faceElem"]["data"],
                index: messageInfo["faceElem"]["index"],
                convType: convType,
                priority: params['priority']);
            messageElem = timeweb!.createFaceMessage(faceMessage);
            break;
          }
        case "image":
          {
            final progressCallback = allowInterop((progress) async {
              final messageInstance =
                  await V2TIMMessage.convertMessageFromWebToDart(messageElem);
              if (messageListener != null) {
                messageInstance['id'] = id;
                messageListener!.onSendMessageProgress(
                    V2TimMessage.fromJson(messageInstance), progress as int);
              }
            });
            final createElemParams = CreateMessage.createImageMessage(
                userID: sendToUserID,
                file: messageInfo["imageElem"]["file"],
                convType: convType,
                progressCallback: progressCallback,
                priority: params['priority']);
            log(createElemParams);
            messageElem = timeweb!.createImageMessage(createElemParams);
            break;
          }
        case "textAt":
          {
            final createElemParams = CreateMessage.createTextAtMessage(
                groupID: sendToUserID,
                text: messageInfo["textAtElem"]['text'],
                priority: params['priority'],
                atList: messageInfo["textAtElem"]['atUserList']);
            messageElem = timeweb!.createTextAtMessage(createElemParams);
            break;
          }
        case "location":
          {
            final createElemParams = CreateMessage.createLocationMessage(
                description: messageInfo["locationElem"]['description'],
                longitude: messageInfo["locationElem"]['longitude'],
                latitude: messageInfo["locationElem"]['latitude'],
                priority: params['priority'],
                userID: sendToUserID);
            messageElem = timeweb!.createLocationMessage(createElemParams);
            break;
          }
        case "mergeMessage":
          {
            List<String> messageList =
                messageInfo["mergerElem"]['webMessageInstanceList'];
            String titile = messageInfo["mergerElem"]['title'];
            String abstractList = messageInfo["mergerElem"]['abstractList'];
            String compatibleText = messageInfo["mergerElem"]['compatibleText'];
            final createElemParams = CreateMessage.createMereMessage(
                userID: sendToUserID,
                messageList: messageList,
                title: titile,
                priority: params['priority'],
                abstractList: abstractList,
                compatibleText: compatibleText);
            messageElem = timeweb!.createMergerMessage(createElemParams);
            break;
          }
        case "forwardMessage":
          {
            final createElemParams = CreateMessage.createForwardMessage(
              message: parse(params['webMessageInstance']),
              userID: sendToUserID,
              priority: params['priority'],
            );

            messageElem = timeweb!.createForwardMessage(createElemParams);
            break;
          }
        case "video":
          {
            final progressCallback = allowInterop((progress) async {
              final messageInstance =
                  await V2TIMMessage.convertMessageFromWebToDart(messageElem);
              if (messageListener != null) {
                messageInstance['id'] = id;
                messageListener!.onSendMessageProgress(
                    V2TimMessage.fromJson(messageInstance), progress as int);
              }
            });
            final createElemParams = CreateMessage.createVideoMessage(
                userID: sendToUserID,
                file: messageInfo['videoElem']['file'],
                convType: convType,
                progressCallback: progressCallback,
                priority: params['priority']);
            messageElem = timeweb!.createVideoMessage(createElemParams);
            break;
          }
        case "file":
          {
            final progressCallback = allowInterop((progress) async {
              final messageInstance =
                  await V2TIMMessage.convertMessageFromWebToDart(messageElem);
              if (messageListener != null) {
                messageInstance['id'] = id;
                messageListener!.onSendMessageProgress(
                    V2TimMessage.fromJson(messageInstance), progress as int);
              }
            });
            final createElemParams = CreateMessage.createFileMessage(
                userID: sendToUserID,
                file: messageInfo['fileElem']['file'],
                convType: convType,
                progressCallback: progressCallback,
                priority: params['priority']);
            messageElem = timeweb!.createFileMessage(createElemParams);
            break;
          }
      }
      final res = await wrappedPromiseToFuture(timeweb!.sendMessage(messageElem,
          mapToJSObj({"onlineUserOnly": params['onlineUserOnly']})));
      final code = res.code;
      if (code == 0) {
        final message = jsToMap(res.data)['message'];
        final formatedMessage =
            await V2TIMMessage.convertMessageFromWebToDart(message);
        messageIDMap.remove(id);
        return CommonUtils.returnSuccess<F>(formatedMessage);
      } else {
        return CommonUtils.returnErrorForValueCb<F>('发送消息失败');
      }
    } catch (error) {
      messageIDMap.remove(id);
      return CommonUtils.returnErrorForValueCb<F>(error);
    }
  }

  Future<dynamic> sendMessage<T, F>(
      {required String type, required Map<String, dynamic> params}) async {
    try {
      final groupID = params['groupID'] ?? '';
      final recveiver = params['receiver'] ?? '';
      final haveTwoValues = groupID != '' && recveiver != '';
      if (haveTwoValues) {
        return CommonUtils.returnErrorForValueCb<F>({
          'code': 6017,
          'desc': "receiver and groupID cannot set at the same time",
          'data': V2TimMessage(elemType: 1).toJson()
        });
      }
      final convType = groupID != '' ? 'GROUP' : 'C2C';
      final sendToUserID = convType == 'GROUP' ? groupID : recveiver;
      // ignore: prefer_typing_uninitialized_variables
      var messageElem;
      switch (type) {
        case "text":
          {
            final createElemParams = CreateMessage.createTextMessage(
                userID: sendToUserID,
                text: params["text"],
                convType: convType,
                priority: params['priority']);
            messageElem = timeweb!.createTextMessage(createElemParams);
            break;
          }
        case "custom":
          {
            final customMessage = CreateMessage.createCustomMessage(
                userID: sendToUserID,
                customData: params["data"],
                convType: convType,
                extension: params['extension'],
                description: params['desc'],
                priority: params['priority']);
            messageElem = timeweb!.createCustomMessage(customMessage);
            break;
          }
        case "face":
          {
            final faceMessage = CreateMessage.createFaceMessage(
                userID: sendToUserID,
                data: params["data"],
                index: params["index"],
                convType: convType,
                priority: params['priority']);
            messageElem = timeweb!.createFaceMessage(faceMessage);
            break;
          }
        case "image":
          {
            final progressCallback = allowInterop((progress) async {
              final messageInstance =
                  await V2TIMMessage.convertMessageFromWebToDart(messageElem);
              if (messageListener != null) {
                messageListener!.onSendMessageProgress(
                    V2TimMessage.fromJson(messageInstance), progress as int);
              }
            });
            final createElemParams = CreateMessage.createImageMessage(
                userID: sendToUserID,
                file: params['file'],
                convType: convType,
                progressCallback: progressCallback,
                priority: params['priority']);
            messageElem = timeweb!.createImageMessage(createElemParams);
            break;
          }
        case "textAt":
          {
            final createElemParams = CreateMessage.createTextAtMessage(
                groupID: sendToUserID,
                text: params['text'],
                priority: params['priority'],
                atList: params['atUserList']);
            messageElem = timeweb!.createTextAtMessage(createElemParams);
            break;
          }
        case "location":
          {
            final createElemParams = CreateMessage.createLocationMessage(
                description: params['desc'],
                longitude: params['longitude'],
                latitude: params['latitude'],
                priority: params['priority'],
                userID: sendToUserID);
            messageElem = timeweb!.createLocationMessage(createElemParams);
            break;
          }
        case "mergeMessage":
          {
            final createElemParams = CreateMessage.createMereMessage(
                userID: sendToUserID,
                messageList: params['webMessageInstanceList'],
                title: params['title'],
                priority: params['priority'],
                abstractList: params['abstractList'],
                compatibleText: params['compatibleText']);
            messageElem = timeweb!.createMergerMessage(createElemParams);
            break;
          }
        case "forwardMessage":
          {
            final createElemParams = CreateMessage.createForwardMessage(
              message: parse(params['webMessageInstance']),
              userID: sendToUserID,
              priority: params['priority'],
            );
            messageElem = timeweb!.createForwardMessage(createElemParams);
            break;
          }
        case "video":
          {
            final progressCallback = allowInterop((progress) async {
              final messageInstance =
                  await V2TIMMessage.convertMessageFromWebToDart(messageElem);
              if (messageListener != null) {
                messageListener!.onSendMessageProgress(
                    V2TimMessage.fromJson(messageInstance), progress as int);
              }
            });
            final createElemParams = CreateMessage.createVideoMessage(
                userID: sendToUserID,
                file: params['file'],
                convType: convType,
                progressCallback: progressCallback,
                priority: params['priority']);
            messageElem = timeweb!.createVideoMessage(createElemParams);
            break;
          }
        case "file":
          {
            final progressCallback = allowInterop((progress) async {
              final messageInstance =
                  await V2TIMMessage.convertMessageFromWebToDart(messageElem);
              if (messageListener != null) {
                messageListener!.onSendMessageProgress(
                    V2TimMessage.fromJson(messageInstance), progress as int);
              }
            });
            final createElemParams = CreateMessage.createFileMessage(
                userID: sendToUserID,
                file: params['file'],
                convType: convType,
                progressCallback: progressCallback,
                priority: params['priority']);
            messageElem = timeweb!.createFileMessage(createElemParams);
            break;
          }
      }
      final res = await wrappedPromiseToFuture(timeweb!.sendMessage(messageElem,
          mapToJSObj({"onlineUserOnly": params['onlineUserOnly']})));
      final code = res.code;
      if (code == 0) {
        final message = jsToMap(res.data)['message'];
        final formatedMessage =
            await V2TIMMessage.convertMessageFromWebToDart(message);
        return CommonUtils.returnSuccess<F>(formatedMessage);
      } else {
        return CommonUtils.returnErrorForValueCb<F>('发送消息失败');
      }
    } catch (error) {
      log(error);
      return CommonUtils.returnErrorForValueCb<F>(error);
    }
  }

  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createTextMessage(
      {required String text}) async {
    return createMessage(type: "text", params: {"text": text});
  }

  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createCustomMessage(
      {required String data, String? desc, String? extension}) async {
    return createMessage(
        type: "custom",
        params: {"data": data, "desc": desc, "extension": extension});
  }

  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createImageMessage(
      Map<String, dynamic> params) async {
    try {
      String? mimeType = mime(Path.basename(params['fileName']));
      final fileContent = generateDartListObject(params['fileContent']);

      params['file'] = html.File(
          fileContent, params['fileName'] as String, {'type': mimeType});
      return createMessage(type: "image", params: params);
    } catch (error) {
      throw const FormatException('fileName and fileContent cannot be empty.');
    }
  }

  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createVideoMessage(
      Map<String, dynamic> params) async {
    String? mimeType = mime(Path.basename(params['fileName']));
    final fileContent = generateDartListObject(params['fileContent']);

    params['file'] = html.File(
        fileContent, params['fileName'] as String, {'type': mimeType});

    return createMessage(type: "video", params: params);
  }

  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createFaceMessage({
    required int index,
    required String data,
  }) async {
    return createMessage(type: "face", params: {
      "index": index,
      "data": data,
    });
  }

  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createFileMessage(
      Map<String, dynamic> params) async {
    String? mimeType = mime(Path.basename(params['fileName']));
    final fileContent = generateDartListObject(params['fileContent']);

    params['file'] = html.File(
        fileContent, params['fileName'] as String, {'type': mimeType});
    return createMessage(type: "file", params: params);
  }

  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createTextAtMessage({
    required String text,
    required List<String> atUserList,
  }) async {
    return createMessage(type: "textAt", params: {
      "text": text,
      "atUserList": atUserList,
    });
  }

  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createLocationMessage({
    required String desc,
    required double longitude,
    required double latitude,
  }) async {
    return createMessage(
        type: "location",
        params: {"desc": desc, "longitude": longitude, "latitude": latitude});
  }

  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createMergerMessage(
      {required List<String> msgIDList,
      required String title,
      required List<String> abstractList,
      required String compatibleText,
      List<String>? webMessageInstanceList}) async {
    return createMessage(type: "mergeMessage", params: {
      "msgIDList": msgIDList,
      "title": title,
      "abstractList": abstractList,
      "compatibleText": compatibleText,
      "webMessageInstanceList": webMessageInstanceList
    });
  }

  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createForwardMessage(
      {required String msgID, String? webMessageInstance}) async {
    return createMessage(
        type: "mergeMessage",
        params: {"msgID": msgID, "webMessageInstance": webMessageInstance});
  }

  Future<T> sendTextMessage<T, F>(Map<String, dynamic> params) async {
    return await sendMessage<T, F>(type: 'text', params: params);
  }

  Future<T> sendCustomMessage<T, F>(Map<String, dynamic> params) async {
    return await sendMessage<T, F>(type: 'custom', params: params);
  }

  static List<Object> generateDartListObject(List<dynamic> params) =>
      List.from(params);

  Future<T> sendImageMessage<T, F>(Map<String, dynamic> params) async {
    String? mimeType = mime(Path.basename(params['fileName']));
    final fileContent = generateDartListObject(params['fileContent']);
    params['file'] = html.File(
        fileContent, params['fileName'] as String, {'type': mimeType});
    return await sendMessage<T, F>(type: 'image', params: params);
  }

  Future<T> sendVideoMessage<T, F>(Map<String, dynamic> params) async {
    String? mimeType = mime(Path.basename(params['fileName']));
    final fileContent = generateDartListObject(params['fileContent']);
    params['file'] = html.File(
        fileContent, params['fileName'] as String, {'type': mimeType});
    return await sendMessage<T, F>(type: 'video', params: params);
  }

  Future<T> sendFileMessage<T, F>(Map<String, dynamic> params) async {
    String? mimeType = mime(Path.basename(params['fileName']));
    final fileContent = generateDartListObject(params['fileContent']);
    params['file'] = html.File(
        fileContent, params['fileName'] as String, {'type': mimeType});
    return await sendMessage<T, F>(type: 'file', params: params);
  }

  // web不支持
  Future<V2TimValueCallback<V2TimMessage>> sendSoundMessage() async {
    return CommonUtils.returnErrorForValueCb<V2TimMessage>(
        "getTotalUnreadMessageCount feature does not exist on the web");
  }

  Future<T> sendTextAtMessage<T, F>(Map<String, dynamic> params) async {
    return await sendMessage<T, F>(type: 'textAt', params: params);
  }

  Future<T> sendFaceMessage<T, F>(Map<String, dynamic> params) async {
    return await sendMessage<T, F>(type: 'face', params: params);
  }

  Future<T> sendLocationMessage<T, F>(Map<String, dynamic> params) async {
    return await sendMessage<T, F>(type: 'location', params: params);
  }

  Future<T> sendMergerMessage<T, F>(Map<String, dynamic> params) async {
    return await sendMessage<T, F>(type: 'mergeMessage', params: params);
  }

  Future<T> sendForwardMessage<T, F>(Map<String, dynamic> params) async {
    return await sendMessage<T, F>(type: 'forwardMessage', params: params);
  }

  Future<dynamic> reSendMessage(Map<String, dynamic> params) async {
    try {
      final res = await wrappedPromiseToFuture(
          timeweb!.reSendMessage(parse(params['webMessageInstance'])));
      final code = res.code;
      if (code == 0) {
        final message = jsToMap(res.data)['message'];
        final formatedMessage =
            await V2TIMMessage.convertMessageFromWebToDart(message);
        return CommonUtils.returnSuccess<V2TimMessage>(formatedMessage);
      } else {
        return CommonUtils.returnErrorForValueCb<V2TimMessage>('重发失败!');
      }
    } catch (error) {
      return CommonUtils.returnErrorForValueCb<V2TimMessage>(error);
    }
  }

  Future<V2TimCallback> setLocalCustomData() async {
    return CommonUtils.returnError(
        "setLocalCustomData feature does not exist on the web");
  }

  Future<V2TimCallback> setLocalCustomInt() async {
    return CommonUtils.returnError(
        "setLocalCustomInt feature does not exist on the web");
  }

  Future<V2TimCallback> setCloudCustomData() async {
    return CommonUtils.returnError(
        "setCloudCustomData feature does not exist on the web");
  }

  Future<dynamic> getMessageList(dynamic getMsgListParams) async {
    // try {
    final res =
        await wrappedPromiseToFuture(timeweb!.getMessageList(getMsgListParams));
    final code = res.code;
    if (code == 0) {
      final List messageList = jsToMap(res.data)['messageList'];
      final historyMessageListPromises = messageList.map((element) async {
        final responses =
            await V2TIMMessage.convertMessageFromWebToDart(element);
        return responses;
      }).toList();
      final historyMessageList = await Future.wait(historyMessageListPromises);
      return CommonUtils.returnSuccess<List<V2TimMessage>>(historyMessageList);
    } else {
      return CommonUtils.returnError("获取历史消息失败");
    }
    // } catch (error) {
    //   return CommonUtils.returnError(error);
    // }
  }

  Future<dynamic> getC2CHistoryMessageList(params) async {
    final getMessageListParams = GetMessageList.formateParams(params);
    return await getMessageList(getMessageListParams);
  }

  Future<dynamic> getGroupHistoryMessageList(params) async {
    final getMessageListParams = GetMessageList.formateParams(params);
    return await getMessageList(getMessageListParams);
  }

  Future<Map<String, dynamic>> getHistoryMessageList(params) async {
    final getMessageListParams = GetMessageList.formateParams(params);
    if (getMessageListParams == null) {
      return {
        'desc': "receiver and groupID cannot set at the same time",
        'data': []
      };
    }
    return await getMessageList(getMessageListParams);
  }

  Future<dynamic> getHistoryMessageListWithoutFormat() async {
    return {
      "code": 0,
      "desc":
          "getHistoryMessageListWithoutFormat feature does not exist on the web"
    };
    // return CommonUtils.returnErrorForValueCb<LinkedHashMap<dynamic, dynamic>>(
    //     "getHistoryMessageListWithoutFormat feature does not exist on the web");
  }

  Future<dynamic> revokeMessage(params) async {
    try {
      final res = await wrappedPromiseToFuture(
          timeweb!.revokeMessage(params['webMessageInstatnce']));
      final code = res.code;
      if (code == 0) {
        return CommonUtils.returnSuccessForCb(jsToMap(res.data));
      } else {
        return CommonUtils.returnError("撤回消息失败");
      }
    } catch (error) {
      return CommonUtils.returnError(error);
    }
  }

  Future<dynamic> markMsgReaded(markMsgReadedParams) async {
    try {
      final res = await wrappedPromiseToFuture(
          timeweb!.setMessageRead(markMsgReadedParams));
      if (res.code == 0) {
        return CommonUtils.returnSuccessForCb(jsToMap(res.data));
      } else {
        return CommonUtils.returnError('设置已读失败');
      }
    } catch (error) {
      return CommonUtils.returnError(error);
    }
  }

  Future<V2TimCallback> markC2CMessageAsRead(params) async {
    final markMsgReadedParams =
        mapToJSObj({"conversationID": 'C2C' + params['userID']});
    return await markMsgReaded(markMsgReadedParams);
  }

  Future<dynamic> markGroupMessageAsRead(params) async {
    final markMsgReadedParams =
        mapToJSObj({"conversationID": 'GROUP' + params['groupID']});
    return await markMsgReaded(markMsgReadedParams);
  }

  Future<V2TimCallback> deleteMessageFromLocalStorage() async {
    return CommonUtils.returnError(
        "deleteMessageFromLocalStorage feature does not exist on the web");
  }

  Future<dynamic> insertGroupMessageToLocalStorage() async {
    return CommonUtils.returnErrorForValueCb<V2TimMessage>(
        "insertGroupMessageToLocalStorage feature does not exist on the web");
  }

  Future<dynamic> insertC2CMessageToLocalStorage() async {
    return CommonUtils.returnErrorForValueCb<V2TimMessage>(
        "insertGroupMessageToLocalStorage feature does not exist on the web");
  }

  Future<V2TimCallback> clearC2CHistoryMessage() async {
    return CommonUtils.returnError(
        "clearC2CHistoryMessage feature does not exist on the web");
  }

  Future<V2TimCallback> clearGroupHistoryMessage() async {
    return CommonUtils.returnError(
        "clearGroupHistoryMessage feature does not exist on the web");
  }

  Future<dynamic> getC2CReceiveMessageOpt() async {
    return CommonUtils.returnErrorForValueCb<List<V2TimReceiveMessageOptInfo>>(
        "getC2CReceiveMessageOpt feature does not exist on the web");
  }

  Future<dynamic> searchLocalMessages() async {
    return CommonUtils.returnErrorForValueCb<V2TimMessageSearchResult>(
        "searchLocalMessages feature does not exist on the web");
  }

  Future<dynamic> findMessages() async {
    return CommonUtils.returnErrorForValueCb<List<V2TimMessage>>(
        "findMessages feature does not exist on the web");
  }

  Future<V2TimCallback> setC2CReceiveMessageOpt() async {
    return CommonUtils.returnError(
        "setC2CReceiveMessageOpt feature does not exist on the web");
  }

  // webMessageInstanceList 这个参数web独有其中元素是web端的message实例
  Future<dynamic> deleteMessages(params) async {
    try {
      final res = await wrappedPromiseToFuture(
          timeweb!.deleteMessages(params['webMessageInstanceList']));
      if (res.code == 0) {
        return CommonUtils.returnSuccess(jsToMap(res.data));
      } else {
        return CommonUtils.returnError('delete msg failed');
      }
    } catch (error) {
      log(error);
      return CommonUtils.returnError(error);
    }
  }

  Future<dynamic> setGroupReceiveMessageOpt(params) async {
    try {
      final remindTypeOpt = {
        'groupID': params['groupID'],
        'messageRemindType':
            GroupRecvMsgOpt.convertMsgRecvOptToWeb(params['opt'])
      };
      final res = await wrappedPromiseToFuture(
          timeweb!.setMessageRemindType(mapToJSObj(remindTypeOpt)));
      if (res.code == 0) {
        return CommonUtils.returnSuccessForCb(jsToMap(res.data));
      } else {
        return CommonUtils.returnError('set group recv msg opt failed');
      }
    } catch (error) {
      return CommonUtils.returnError(error);
    }
  }

  static final _messageReadReceiptHandler = allowInterop((dynamic responses) {
    final List messageData = jsToMap(responses)['data'];
    final readedList = messageData.map((item) {
      final formatedItem = jsToMap(item);
      return V2TimMessageReceipt(
          userID: formatedItem['from'], timestamp: formatedItem['time']);
    }).toList();
    messageListener!.onRecvC2CReadReceipt(readedList);
  });

  static final _messageRevokedHandler = allowInterop((dynamic responses) {
    final List messageData = jsToMap(responses)['data'];
    for (var element in messageData) {
      final msgID = jsToMap(element)['ID'];
      messageListener!.onRecvMessageRevoked(msgID);
    }
  });

  static final _reciveNewMesageHandler = allowInterop((dynamic responses) {
    final List messageList = jsToMap(responses)['data'];
    for (var messageItem in messageList) {
      loop() async {
        final formatedMessage =
            await V2TIMMessage.convertMessageFromWebToDart(messageItem);
        messageListener!
            .onRecvNewMessage(V2TimMessage.fromJson(formatedMessage));
      }

      loop();
    }
  });

  void addAdvancedMsgListener(V2TimAdvancedMsgListener listener) {
    messageListener = listener;
    submitMessageReadReceipt();
    submitMessageRevoked();
    submitRecvNewMessage();
  }

  void removeAdvancedMsgListener() {
    timeweb!.off(EventType.MESSAGE_READ_BY_PEER, _messageReadReceiptHandler);
    timeweb!.off(EventType.MESSAGE_REVOKED, _messageRevokedHandler);
    timeweb!.off(EventType.MESSAGE_RECEIVED, _reciveNewMesageHandler);
  }

  static void submitMessageReadReceipt() {
    timeweb!.on(EventType.MESSAGE_READ_BY_PEER, _messageReadReceiptHandler);
  }

  static void submitMessageRevoked() {
    timeweb!.on(EventType.MESSAGE_REVOKED, _messageRevokedHandler);
  }

  static void submitRecvNewMessage() {
    timeweb!.on(EventType.MESSAGE_RECEIVED, _reciveNewMesageHandler);
  }
}
