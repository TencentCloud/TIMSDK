import {
  V2TIMAdvancedMsgListener,
  V2TIMMessage,
  V2TIMElem,
  V2TIMElemType,
  V2TIMMessageExtension,
  V2TIMMessageReactionChangeInfo,
  V2TIMUserFullInfo,
  V2TIMOfflinePushInfo,
  V2TIMMessagePriority,
  V2TIMUploadCallback,
  V2TIMReceiveMessageOpt,
  V2TIMMessageExtensionResult,
  V2TIMReceiveMessageOptInfo,
  V2TIMMessageReactionUserResult,
  V2TIMMessageReactionResult,
  V2TIMMessageReceipt,
  V2TIMGroupMessageReadMemberList,
  V2TIMGroupMessageReadMembersFilter,
  V2TIMVideoElem,
  V2TIMSoundElem,
  V2TIMMergerElem,
  V2TIMLocationElem,
  V2TIMImageElem,
  V2TIMImage,
  V2TIMGroupTipsElem,
  V2TIMFileElem,
  V2TIMFaceElem,
  V2TIMDownloadCallback,
  V2TIMGroupMemberInfo,
  V2TIMMessageManager,
}
from '@tencentcloud/imsdk';
import { V2TIMManager } from '@tencentcloud/imsdk/src/main/ets/V2TIMManager'
import buffer from '@ohos.buffer';
import Prompt from '@system.prompt';
import TestResult, { info } from '../pages/MessageManagerTestPage';
import { onCallback, writeResult } from '../pages/MessageManagerTestPage';

import picker from '@ohos.file.picker';
import fs from '@ohos.file.fs';
import { BusinessError } from '@ohos.base';

// 文件下载目录
const cacheDir = getContext().cacheDir;
let msgList: V2TIMMessage[] = [];

interface SendMessageOptions {
  receiver?: string;
  groupID?: string;
  priority?: V2TIMMessagePriority;
  callback?: V2TIMUploadCallback;
  onlineUserOnly?: boolean;
  offlinePushInfo?: V2TIMOfflinePushInfo;
}

export class MessageTestInterfaces {
  static clearMessageList() {
    msgList = [];
  }

  static addAdvancedMsgListener() {
    V2TIMManager.getMessageManager().addAdvancedMsgListener(advancedMsgListener);
    Prompt.showToast({ message: "addAdvancedMsgListener" });
  }

  static removeAdvancedMsgListener() {
    V2TIMManager.getMessageManager().removeAdvancedMsgListener(advancedMsgListener);
    Prompt.showToast({ message: "removeAdvancedMsgListener" });
  }


  private static getSendMessageOptions(): SendMessageOptions {
    const options: SendMessageOptions = {
      receiver: info.receiver.length !== 0 ? info.receiver : undefined,
      groupID: info.receiver.length === 0 ? (info.groupID.length !== 0 ? info.groupID : undefined) : undefined,
      priority: info.priority,
      callback: MessageTestInterfaces.onUpload,
      onlineUserOnly: info.onlineUserOnly,
      offlinePushInfo: info.offlinePushInfo !== null ? info.offlinePushInfo : undefined,
    };
    return options;
  }

  private static onUpload(currentSize: number, totalSize: number) {
    TestResult.progress = currentSize / totalSize;
  }

  private static onSendMessageSuccess(message: V2TIMMessage) {
    TestResult.result = `send message success ${message}`
    msgList.push(message);
  }

  private static onSendMessageFailed(error: object | number | string | null) {
    TestResult.result = `send message failed ${error}`
  }

  private static sendMessage(message: V2TIMMessage) {
    message.isExcludedFromContentModeration = info.excludeSecurityCheck;
    message.isExcludedFromUnreadCount = info.excludeUnreadCount;
    message.isExcludedFromLastMessage = info.excludeLastMessage;
    let options = MessageTestInterfaces.getSendMessageOptions();
    let result = V2TIMManager.getMessageManager().sendMessage(message, options);
    let promise = result.promise;
    let msgID = result.msgID;
    TestResult.messageID = msgID;
    promise.then(MessageTestInterfaces.onSendMessageSuccess).catch(MessageTestInterfaces.onSendMessageFailed);
  }


  static createTextMessageAndSend() {
    let message = V2TIMManager.getMessageManager().createTextMessage(info.text);
    MessageTestInterfaces.sendMessage(message);
  }

  static createTextAtMessageAndSend() {
    let message = V2TIMManager.getMessageManager().createTextAtMessage(info.text, info.atUsers);
    MessageTestInterfaces.sendMessage(message);
  }

  static createCustomMessageAndSend() {
    let message = V2TIMManager.getMessageManager()
      .createCustomMessage(info.customData, { description: info.customDesc, extension: info.customExt });
    MessageTestInterfaces.sendMessage(message);
  }

  static createImageMessageAndSend() {
    const imagePath = getContext().cacheDir + '/uploads/image.png';
    let message = V2TIMManager.getMessageManager()
      .createImageMessage(imagePath);
    MessageTestInterfaces.sendMessage(message);
  }


  static createSoundMessageAndSend() {
    const soundPath = getContext().cacheDir + '/uploads/sound.mp3';
    const duration = 3;
    let message = V2TIMManager.getMessageManager()
      .createSoundMessage(soundPath, duration);
    MessageTestInterfaces.sendMessage(message);
  }

  static createVideoMessageAndSend() {
    const videoFilePath = getContext().cacheDir + '/uploads/videoFile.m4a';
    const type = "m4a";
    const duration = 3;
    const snapshotPath = getContext().cacheDir + '/uploads/snapshot.jpg';
    let message = V2TIMManager.getMessageManager()
      .createVideoMessage(videoFilePath, type, duration, snapshotPath);
    MessageTestInterfaces.sendMessage(message);
  }

  static createFileMessageAndSend() {
    const filePath = getContext().cacheDir + '/uploads/file.zip';
    const fileName = "fileName";
    let message = V2TIMManager.getMessageManager()
      .createFileMessage(filePath, fileName);
    MessageTestInterfaces.sendMessage(message);
  }

  static createLocationMessageAndSend() {
    const desc = "desc";
    const longitude = 12.34;
    const latitude = 56.78;
    let message = V2TIMManager.getMessageManager().createLocationMessage(desc, longitude, latitude);
    MessageTestInterfaces.sendMessage(message);
  }

  static createFaceMessageAndSend() {
    const index = 1024;
    const data = buffer.from("data").buffer;
    let message = V2TIMManager.getMessageManager().createFaceMessage(index, data);
    MessageTestInterfaces.sendMessage(message);
  }

  static createMergeMessageAndSend() {
    const title = "title";
    const abstractList = ["abstractList"];
    const compatibleText = "compatibleText";
    if (msgList.length > 0) {
      let message = V2TIMManager.getMessageManager()
        .createMergerMessage(msgList, title, abstractList, compatibleText);
      if (message) {
        MessageTestInterfaces.sendMessage(message);
      }
    } else {
      Prompt.showToast({ message: "请先发送一条消息" })
    }
  }

  static createForwardMessageAndSend() {
    if (msgList.length > 0) {
      let message = V2TIMManager.getMessageManager().createForwardMessage(msgList[0]);
      if (message) {
        MessageTestInterfaces.sendMessage(message);
      }
    } else {
      Prompt.showToast({ message: "请先发送一条消息" })
    }
  }

  static createTargetedGroupMessageAndSend() {
    let originMessage = V2TIMManager.getMessageManager().createTextMessage(info.text);
    let message = V2TIMManager.getMessageManager().createTargetedGroupMessage(originMessage, info.groupTargetReceivers);
    if (message) {
      MessageTestInterfaces.sendMessage(message);
    }
  }

  static createAtSignedGroupMessageAndSend() {
    let originMessage = V2TIMManager.getMessageManager().createTextMessage(info.text);
    let message = V2TIMManager.getMessageManager().createAtSignedGroupMessage(originMessage, info.atUsers);
    if (message) {
      MessageTestInterfaces.sendMessage(message);
    }
  }

  static setC2CReceiveMessageOpt() {
    V2TIMManager.getMessageManager().setC2CReceiveMessageOpt([info.userID1, info.userID2], info.recvOpt)
      .then(() => {
        Prompt.showToast({ message: "setC2CReceiveMessageOpt success" });
      })
      .catch(() => {
        Prompt.showToast({ message: "setC2CReceiveMessageOpt failed" });
      })
  }

  static setGroupReceiveMessageOpt() {
    V2TIMManager.getMessageManager().setGroupReceiveMessageOpt(info.groupID2, info.recvOpt)
      .then(() => {
        Prompt.showToast({ message: "setGroupReceiveMessageOpt success" });
      })
      .catch(() => {
        Prompt.showToast({ message: "setGroupReceiveMessageOpt failed" });
      })
  }

  static getC2CReceiveMessageOpt() {
    V2TIMManager.getMessageManager()
      .getC2CReceiveMessageOpt([info.userID1, info.userID2])
      .then((result: V2TIMReceiveMessageOptInfo[]) => {
        writeResult('getC2CReceiveMessageOpt succeeded', result);
      })
      .catch((error: Error) => {
        writeResult('getC2CReceiveMessageOpt failed', error);
      });
  }

  static setAllReceiveMessageOpt() {
    V2TIMManager.getMessageManager()
      .setAllReceiveMessageOpt(info.recvOpt, info.startHour, info.startMinute, info.startSecond, info.duration)
      .then(() => {
        writeResult('setAllReceiveMessageOpt succeeded');
      })
      .catch((error: Error) => {
        writeResult('setAllReceiveMessageOpt failed', error);
      });
  }

  static setAllReceiveMessageOpt2() {
    V2TIMManager.getMessageManager()
      .setAllReceiveMessageOpt2(info.recvOpt, info.startTimeStamp, info.duration)
      .then(() => {
        writeResult('setAllReceiveMessageOpt2 succeeded');
      })
      .catch((error: Error) => {
        writeResult('setAllReceiveMessageOpt2 failed', error);
      });
  }

  static getAllReceiveMessageOpt() {
    V2TIMManager.getMessageManager()
      .getAllReceiveMessageOpt()
      .then((result: V2TIMReceiveMessageOptInfo) => {
        writeResult('getAllReceiveMessageOpt succeeded', result);
      })
      .catch((error: Error) => {
        writeResult('getAllReceiveMessageOpt failed', error);
      });
  }

  static revokeMessage() {
    if (msgList.length <= 0) {
      Prompt.showToast({ message: "请先发一条消息" })
      return;
    }
    V2TIMManager.getMessageManager().revokeMessage(msgList[0])
      .then(() => {
        writeResult('revokeMessage succeeded');
      })
      .catch((error: Error) => {
        writeResult('revokeMessage failed', error);
      });
  }

  static modifyMessage() {
    if (msgList.length <= 0) {
      Prompt.showToast({ message: "请先发一条消息" })
      return;
    }
    let lastMsg = msgList[0];
    // let elemList = lastMsg.elemList;
    // if (elemList.length === 0) {
    //   return;
    // }
    // let elem = elemList[0];
    let rand = Math.random();
    let elemType = lastMsg.elemType;
    // 修改文本内容
    if (elemType === V2TIMElemType.V2TIM_ELEM_TYPE_TEXT) {
      if (lastMsg && lastMsg.textElem) {
        lastMsg.textElem.text = "m_text_" + rand;
      }
    }
    // 修改 cloudCustomData
    lastMsg.cloudCustomData = buffer.from("m_cloud_data_" + rand).buffer;
    V2TIMManager.getMessageManager().modifyMessage(lastMsg)
      .then(() => {
        writeResult('modifyMessage succeeded');
      })
      .catch((error: Error) => {
        writeResult('modifyMessage failed', error);
      });
  }

  static deleteMessage() {
    if (msgList.length <= 0) {
      Prompt.showToast({ message: "请先发一条消息或者拉取消息" })
      return;
    }
    V2TIMManager.getMessageManager().deleteMessages(msgList)
      .then(() => {
        writeResult('deleteMessage succeeded');
      })
      .catch((error: Error) => {
        writeResult('deleteMessage failed', error);
      });
  }

  static clearC2CHistoryMessage() {
    if (msgList.length <= 0) {
      Prompt.showToast({ message: "请先发一条消息或者拉取消息" })
      return;
    }
    V2TIMManager.getMessageManager().clearC2CHistoryMessage(info.userID4)
      .then(() => {
        writeResult('clearC2CHistoryMessage succeeded');
      })
      .catch((error: Error) => {
        writeResult('clearC2CHistoryMessage failed', error);
      });
  }

  static clearGroupHistoryMessage() {
    if (msgList.length <= 0) {
      Prompt.showToast({ message: "请先发一条消息或者拉取消息" })
      return;
    }
    V2TIMManager.getMessageManager().clearGroupHistoryMessage(info.groupID4)
      .then(() => {
        writeResult('clearGroupHistoryMessage succeeded');
      })
      .catch((error: Error) => {
        writeResult('clearGroupHistoryMessage failed', error);
      });
  }

  static insertGroupMessageToLocalStorage() {
    let message = V2TIMManager.getMessageManager().createTextMessage("insertGroupMessage")
    V2TIMManager.getMessageManager()
      .insertGroupMessageToLocalStorage(message, info.groupID5, info.sender)
      .promise
      .then((result: V2TIMMessage) => {
        writeResult('insertGroupMessageToLocalStorage succeeded', result);
      })
      .catch((error: Error) => {
        writeResult('insertGroupMessageToLocalStorage failed', error);
      });
  }

  static insertC2CMessageToLocalStorage() {
    let message = V2TIMManager.getMessageManager().createTextMessage("insertGroupMessage")
    let result = V2TIMManager.getMessageManager()
      .insertC2CMessageToLocalStorage(message, info.userID5, info.sender);
    let msgID = result.msgID;
    let promise = result.promise;
    promise.then((result: V2TIMMessage) => {
      writeResult('insertC2CMessageToLocalStorage succeeded', result);
    })
      .catch((error: Error) => {
        writeResult('insertC2CMessageToLocalStorage failed', error);
      });
    Prompt.showToast({ message: msgID });
  }

  // static markAllMessageAsRead() {
  //   V2TIMManager.getMessageManager().markAllMessageAsRead()
  //     .then(() => {
  //       TestResult.result = 'markAllMessageAsRead succeeded';
  //     })
  //     .catch((error: Error) => {
  //       TestResult.result = `markAllMessageAsRead failed  ${error}`;
  //     });
  // }
  //
  // static markC2CMessageAsRead() {
  //   V2TIMManager.getMessageManager().markC2CMessageAsRead(info.userID4)
  //     .then(() => {
  //       TestResult.result = 'markC2CMessageAsRead succeeded';
  //     })
  //     .catch((error: Error) => {
  //       TestResult.result = `markC2CMessageAsRead failed  ${error}`;
  //     });
  // }
  //
  // static markGroupMessageAsRead() {
  //   V2TIMManager.getMessageManager().markGroupMessageAsRead(info.groupID4)
  //     .then(() => {
  //       TestResult.result = 'markGroupMessageAsRead succeeded';
  //     })
  //     .catch((error: Error) => {
  //       TestResult.result = `markGroupMessageAsRead failed  ${error}`;
  //     });
  // }

  static translateText() {
    V2TIMManager.getMessageManager()
      .translateText([info.sourceText1, info.sourceText2], info.sourceLanguage, info.targetLanguage)
      .then(() => {
        writeResult('translateText succeeded');
      })
      .catch((error: Error) => {
        writeResult('translateText failed', error);
      });
  }

  static getMessageExtensions() {
    if (msgList.length === 0) {
      Prompt.showToast({ message: "请先发一条消息" })
      return
    }
    V2TIMManager.getMessageManager().getMessageExtensions(msgList[0])
      .then((resultList: V2TIMMessageExtension[]) => {
        writeResult('getMessageExtensions succeeded', resultList);
      })
      .catch((error: Error) => {
        writeResult('getMessageExtensions failed', error);
      });
  }

  static setMessageExtensions() {
    if (msgList.length === 0) {
      Prompt.showToast({ message: "请先发一条消息" })
      return
    }
    const extension1: V2TIMMessageExtension = {
      extensionKey: "extension1",
      extensionValue: "extension1111",
    }
    const extension2: V2TIMMessageExtension = {
      extensionKey: "extension2",
      extensionValue: "extension2222",
    }
    V2TIMManager.getMessageManager().setMessageExtensions(msgList[0], [extension1, extension2])
      .then((resultList: V2TIMMessageExtensionResult[]) => {
        writeResult('setMessageExtensions succeeded', resultList);
      })
      .catch((error: Error) => {
        writeResult('setMessageExtensions failed', error);
      });
  }

  static deleteMessageExtensions() {
    if (msgList.length === 0) {
      Prompt.showToast({ message: "请先发一条消息" })
      return
    }

    V2TIMManager.getMessageManager().deleteMessageExtensions(msgList[0], ["extension1", "extension2"])
      .then((resultList: V2TIMMessageExtensionResult[]) => {
        writeResult('deleteMessageExtensions succeeded', resultList);
      })
      .catch((error: Error) => {
        writeResult('deleteMessageExtensions failed', error);
      });
  }


  static addMessageReaction() {
    if (msgList.length === 0) {
      Prompt.showToast({ message: "请先发一条消息" })
      return
    }

    V2TIMManager.getMessageManager().addMessageReaction(msgList[0], "reactionID111")
      .then(() => {
        writeResult('addMessageReaction succeeded');
      })
      .catch((error: Error) => {
        writeResult('addMessageReaction failed', error);
      });
  }

  static getMessageReactions() {
    if (msgList.length === 0) {
      Prompt.showToast({ message: "请先发一条消息" })
      return
    }

    V2TIMManager.getMessageManager().getMessageReactions(msgList, 10)
      .then((result: V2TIMMessageReactionResult) => {
        writeResult('getMessageReactions succeeded', result);
      })
      .catch((error: Error) => {
        writeResult('getMessageReactions failed', error);
      });
  }

  static getMessageReactionUserList() {
    if (msgList.length === 0) {
      Prompt.showToast({ message: "请先发一条消息" })
      return
    }

    V2TIMManager.getMessageManager().getMessageReactionUserList(msgList[0], "reactionID111", 0, 10)
      .then((result: V2TIMMessageReactionUserResult) => {
        writeResult('getMessageReactionUserList succeeded', result);
      })
      .catch((error: Error) => {
        writeResult('getMessageReactionUserList failed', error);
      });
  }

  static removeMessageReaction() {
    if (msgList.length === 0) {
      Prompt.showToast({ message: "请先发一条消息" })
      return
    }

    V2TIMManager.getMessageManager().removeMessageReaction(msgList[0], "reactionID111")
      .then(() => {
        writeResult('removeMessageReaction succeeded');
      })
      .catch((error: Error) => {
        writeResult('removeMessageReaction failed', error);
      });
  }

  static findMessages() {
    V2TIMManager.getMessageManager().findMessages([info.messageID1, info.messageID2])
      .then((result: V2TIMMessage[]) => {
        writeResult('findMessages succeeded', result);
      })
      .catch((error: Error) => {
        writeResult('findMessages failed', error);
      });
  }

  static sendMessageReadReceipts() {
    V2TIMManager.getMessageManager().sendMessageReadReceipts(msgList)
      .then(() => {
        writeResult('sendMessageReadReceipts succeeded');
      })
      .catch((error: Error) => {
        writeResult('sendMessageReadReceipts failed', error);
      });
  }

  static getMessageReadReceipts() {
    V2TIMManager.getMessageManager().getMessageReadReceipts(msgList)
      .then((result: V2TIMMessageReceipt[]) => {
        writeResult('getMessageReadReceipts succeeded', result);
      })
      .catch((error: Error) => {
        writeResult('getMessageReadReceipts failed', error);
      });
  }

  static getGroupMessageReadMemberList() {
    if (msgList.length === 0) {
      Prompt.showToast({ message: "请先发一条群消息" })
      return
    }

    let filter = info.isUnread ?
    V2TIMGroupMessageReadMembersFilter.V2TIM_GROUP_MESSAGE_READ_MEMBERS_FILTER_UNREAD
                               : V2TIMGroupMessageReadMembersFilter.V2TIM_GROUP_MESSAGE_READ_MEMBERS_FILTER_READ
    V2TIMManager.getMessageManager()
      .getGroupMessageReadMemberList(msgList[0], filter, 0, 100)
      .then((result: V2TIMGroupMessageReadMemberList) => {
        writeResult('getGroupMessageReadMemberList succeeded', result);
      })
      .catch((error: Error) => {
        writeResult('getGroupMessageReadMemberList failed', error);
      });
  }

  static getLocalCustomData() {
    writeResult(buffer.from(msgList[0].getLocalCustomData()).toString());
  }

  static async setLocalCustomData() {
    try {
      await msgList[0].setLocalCustomData(buffer.from("data").buffer);
      const message = await V2TIMManager.getMessageManager().findMessages([ msgList[0].msgID ]);
      writeResult("success", buffer.from(msgList[0].getLocalCustomData()).toString(),
        buffer.from(message[0].getLocalCustomData()).toString());
    } catch (error) {
      writeResult("fail", error);
    }
  }

  static getLocalCustomInt() {
    writeResult(msgList[0].getLocalCustomInt());
  }

  static async setLocalCustomInt() {
    try {
      await msgList[0].setLocalCustomInt(1024);
      const message = await V2TIMManager.getMessageManager().findMessages([ msgList[0].msgID ]);
      writeResult("success", msgList[0].getLocalCustomInt(), message[0].getLocalCustomInt());
    } catch (error) {
      writeResult("fail", error);
    }
  }

  static async pick_and_upload() {
    try {
      // const photoSelectOptions = new picker.PhotoSelectOptions();
      // photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
      // photoSelectOptions.maxSelectNumber = 5;
      // const photoViewPicker = new picker.PhotoViewPicker();
      // const photoSelectResult = await photoViewPicker.select(photoSelectOptions);
      // const uri = photoSelectResult.photoUris[0];

      const uri = getContext().cacheDir + '/image.png';
      let file = fs.openSync(uri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      let writeLen = fs.writeSync(file.fd, "Try to write str.");
      fs.closeSync(file);

      {
        const uri = getContext().filesDir + '/image.png';
        let file = fs.openSync(uri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
        let writeLen = fs.writeSync(file.fd, "Try to write str.");
        fs.closeSync(file);
      }

      let message = V2TIMManager.getMessageManager().createImageMessage(uri);
      MessageTestInterfaces.sendMessage(message);

    } catch (error) {
      // TODO
    }
  }
}

const advancedMsgListener: V2TIMAdvancedMsgListener = {
  onRecvNewMessage: (message: V2TIMMessage) => {
    onCallback(`onRecvNewMessage ${message.msgID}`);
    msgList.push(message);
    switch (message.elemType) {
      case V2TIMElemType.V2TIM_ELEM_TYPE_TEXT: {
        onCallback(message?.textElem?.text)
        break;
      }
      case V2TIMElemType.V2TIM_ELEM_TYPE_CUSTOM: {
        let custom_elem = message.customElem;
        if (custom_elem && custom_elem.data) {
          onCallback(buffer.from(custom_elem.data).toString());
        }
        break;
      }
      case V2TIMElemType.V2TIM_ELEM_TYPE_IMAGE: {
        let image_elem = message.imageElem;
        onCallback(image_elem?.path, image_elem?.imageList);
        if (image_elem && image_elem.imageList) {
          let i = 0;
          image_elem.imageList.forEach((image: V2TIMImage) => {
            i += 1;
            const callback: V2TIMDownloadCallback = (currentSize: number, totalSize: number) => {
              TestResult.progress = currentSize / totalSize * 100;
            };
            image.downloadImage(cacheDir + '/' + image.uuid + i, callback)
              .then(() => {
                onCallback('downloadImage succeed');
              })
              .catch((error: Error) => {
                onCallback('downloadImage failed', error);
              });
          });
        }
        break;
      }

      case V2TIMElemType.V2TIM_ELEM_TYPE_SOUND: {
        let sound_elem = message.soundElem;
        onCallback(sound_elem?.path, sound_elem?.uuid, sound_elem?.dataSize, sound_elem?.duration);

        const callback: V2TIMDownloadCallback = (currentSize: number, totalSize: number) => {
          TestResult.progress = currentSize / totalSize * 100;
        };
        if (sound_elem && sound_elem.uuid) {
          sound_elem.downloadSound(cacheDir + '/' + sound_elem.uuid, callback)
            .then(() => {
              onCallback('downloadSound succeed');
            })
            .catch((error: Error) => {
              onCallback('downloadSound failed', error);
            });
        }
      }
        break;
      case V2TIMElemType.V2TIM_ELEM_TYPE_VIDEO: {
        let video_elem = message.videoElem;
        onCallback(video_elem?.videoPath, video_elem?.snapshotPath, video_elem?.videoUUID,
          video_elem?.videoSize, video_elem?.videoType, video_elem?.duration);

        const videoCallback: V2TIMDownloadCallback = (currentSize: number, totalSize: number) => {
          TestResult.progress = currentSize / totalSize * 100;
        };
        if (video_elem && video_elem.videoUUID) {
          video_elem.downloadVideo(cacheDir + '/' + video_elem.videoUUID, videoCallback)
            .then(() => {
              onCallback('downloadVideo succeed');
            })
            .catch((error: Error) => {
              onCallback('downloadVideo failed', error);
            });
        }

        const snapshotCallback: V2TIMDownloadCallback = (currentSize: number, totalSize: number) => {
          TestResult.progress2 = currentSize / totalSize * 100;
        };
        if (video_elem && video_elem.snapshotUUID) {
          video_elem.downloadSnapshot(cacheDir + '/' + video_elem.snapshotUUID, snapshotCallback)
            .then(() => {
              onCallback('downloadSnapshot succeed');
            })
            .catch((error: Error) => {
              onCallback('downloadSnapshot failed', error);
            });
        }
      }
        break;
      case V2TIMElemType.V2TIM_ELEM_TYPE_FILE: {
        let file_elem = message.fileElem;
        onCallback(file_elem?.path, file_elem?.uuid, file_elem?.filename, file_elem?.fileSize);

        const callback: V2TIMDownloadCallback = (currentSize: number, totalSize: number) => {
          TestResult.progress = currentSize / totalSize * 100;
        };
        if (file_elem && file_elem.uuid) {
          file_elem.downloadFile(cacheDir + '/' + file_elem.uuid, callback)
            .then(() => {
              onCallback('downloadFile succeed');
            })
            .catch((error: Error) => {
              onCallback('downloadFile failed', error);
            });
        }
      }
        break;
      case V2TIMElemType.V2TIM_ELEM_TYPE_LOCATION: {
        let location_elem = message.LocationElem;
        onCallback(location_elem?.desc, location_elem?.longitude, location_elem?.latitude);
      }
        break;
      case V2TIMElemType.V2TIM_ELEM_TYPE_FACE: {
        let face_elem = message.faceElem;
        onCallback(face_elem?.index, buffer.from(face_elem?.data).toString());
      }
        break;
      case V2TIMElemType.V2TIM_ELEM_TYPE_GROUP_TIPS: {
        let group_tips_elem = message.groupTipsElem;
        onCallback(group_tips_elem?.opMember);
      }
        break;
      case V2TIMElemType.V2TIM_ELEM_TYPE_MERGER: {
        let merger_elem = message.mergerElem;
        // merger_elem 和 message 相互引用，直接打印会死循环
        // onCallback(merger_elem);
        if (merger_elem) {
          merger_elem.downloadMergerMessage()
            .then((messageList: V2TIMMessage[]) => {
              let messageIDList = new Array<string>();
              messageList.forEach((message: V2TIMMessage) => {
                messageIDList.push(message.msgID);
              });
              onCallback('downloadMergerMessage succeed', messageIDList);
            })
            .catch((error: Error) => {
              onCallback('downloadMergerMessage failed', error);
            });
        }
      }
        break;
      default: {
        onCallback('unsupported element');
      }
        break;
    }
  },
  onRecvMessageRevoked: (msgID: string, operateUser: V2TIMUserFullInfo, reason: string) => {
    onCallback('onRecvMessageRevoked', msgID, operateUser, reason);
  },
  onRecvMessageModified: (message: V2TIMMessage) => {
    onCallback('onRecvMessageModified', message.msgID);
  },
  onRecvC2CReadReceipt: (receiptList) => {
    onCallback('onRecvC2CReadReceipt', receiptList);
  },
  onRecvMessageReadReceipts: (receiptList) => {
    onCallback('onRecvMessageReadReceipts', receiptList);
  },
  onRecvMessageExtensionsChanged: (msgID: string, extensions: V2TIMMessageExtension[]) => {
    onCallback('onRecvMessageExtensionsChanged', msgID, extensions);
  },
  onRecvMessageExtensionsDeleted: (msgID: string, extensionKeys: string[]) => {
    onCallback('onRecvMessageExtensionsDeleted', msgID, extensionKeys);
  },
  onRecvMessageReactionsChanged: (changeInfos: V2TIMMessageReactionChangeInfo[]) => {
    onCallback('onRecvMessageReactionsChanged', changeInfos);
  },
  onGroupMessagePinned: (groupID: string, message: V2TIMMessage, isPinned: Boolean, opUser: V2TIMGroupMemberInfo) => {
    onCallback('onGroupMessagePinned', groupID, message.seq, isPinned);
  }
};
