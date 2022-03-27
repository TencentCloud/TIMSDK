import BraftEditor from "braft-editor";
import { emojiMap } from "./emoji-map";
import fs from 'fs';
import path from 'path';
import os from 'os'

export const getFileTypeName = (fileName: string) => {
  const match = fileName.match(/\.(\w+)$/);
  return match ? match[1] : "unknow";
};

export const getNameByLink = (link: string) => {
  const arr = link.split("/");
  const name = arr[arr.length - 1] || "";
  return decodeURIComponent(name);
};

export const generateTemplateElement = async (convId, convType, userProfile, messageId, element, groupMemberProfile?, replyMsg?) => {
  let formatedElement;
  if(element.elem_type === 1) {
    const base64Url = await localFileToBase64(element.image_elem_orig_path);
     formatedElement = {
      ...element,
      image_elem_orig_path: base64Url
    }
  } else {
    formatedElement = element;
  }
  return {
    message_client_time:Math.round(new Date().getTime() /  1000),
    message_is_peer_read: false,
    message_status: 1,
    message_cloud_custom_str: replyMsg ?? "",
    message_conv_type: convType,
    message_conv_id: convId,
    message_is_from_self: true,
    message_elem_array: [formatedElement],
    message_msg_id: messageId,
    message_sender_profile: userProfile,
    message_sender_group_member_info: groupMemberProfile || {}
  }
}

const getMessageElemItem = (
  type: string,
  data: { text?: string; path?: string; name?: string; size?: number },
  videoInfoList?: any[]
) => {
  switch (type) {
    case "text": {
      return {
        elem_type: 0,
        text_elem_content: data.text,
      };
    }
    case "block-video": {
      const item = videoInfoList.find((item) => item.videoPath === data.path);
      const {
        videoType,
        videoSize,
        videoDuration,
        videoPath,
        screenshotType,
        screenshotSize,
        screenshotWidth,
        screenshotHeight,
        screenshotPath,
      } = item;
      return {
        elem_type: 9,
        video_elem_video_type: videoType,
        video_elem_video_size: videoSize,
        video_elem_video_duration: videoDuration,
        video_elem_video_path: videoPath,
        video_elem_image_type: screenshotType,
        video_elem_image_size: screenshotSize,
        video_elem_image_width: screenshotWidth,
        video_elem_image_height: screenshotHeight,
        video_elem_image_path: screenshotPath,
      };
    }
    case "block-file": {
      return {
        elem_type: 4,
        file_elem_file_path: data.path,
        file_elem_file_name: data.name,
        file_elem_file_size: data.size,
      };
    }
    case "block-image": {
      return {
        elem_type: 1,
        image_elem_orig_path: data.path,
        image_elem_level: 0,
      };
    }
    case "block-reply-msg": {
      return {
        elem_type: 999
      }
    }
  }
};


// 得到最终发送的messageElemArray
export const getMessageElemArray = (rawData: any, videoInfoList: any[]) => {
  try {
    const data = JSON.parse(rawData);
    const { blocks, entityMap } = data; 

    const messageElementArray = [];

    blocks?.forEach((item) => {
      const { type, text, entityRanges } = item;
      switch (type) {
        case "unstyled": {
          const trimText = text.trim();
          if (trimText?.length) {
            messageElementArray.push(
              getMessageElemItem("text", { text: text.trim() })
            );
          }
          break;
        }
        case "atomic": {
          entityRanges.forEach((v) => {
            const { key } = v;
            const entity = entityMap[key];
            const { type: customBlockType, data } = entity;
            messageElementArray.push(
              getMessageElemItem(customBlockType, data, videoInfoList)
            );
          });
        }
      }
    });
    return messageElementArray;
  } catch (e) {
    console.log(e);
  }
  return [];
};

// 计算出emoji
const getReverseEmojiMap = (map: object) => {
  const data = {};
  Object.entries(map).forEach(([key, value]) => {
    data[value] = key;
  });
  return data;
};

// 根据根据HTML字符串得到最终展示文案
export const getPasteText = (htmlString: string) => {
  const ReverseEmojiMap = getReverseEmojiMap(emojiMap);
  const srcReg = /src=[\'\"]?([^\'\"]*)[\'\"]?/i;
  const contentString = htmlString.replace(
    /<img(?:.|\s)*?>/gi,
    function (item) {
      const src = item.match(srcReg)?.[1];
      const emojiValue = getNameByLink(src);
      const emojiName = ReverseEmojiMap[emojiValue];
      return emojiName;
    }
  );
  return BraftEditor.createEditorState(contentString).toText();
};

// 得到图片的base64
export const fileImgToBase64Url = async (file: File) => {
  return new Promise((res) => {
    const reader = new FileReader();
    reader.onload = function (e) {
      const base64Value = e.target.result;
      // target.result 该属性表示目标对象的DataURL
      res(base64Value);
    };
    reader.readAsDataURL(file);
  });
};

export const bufferToBase64Url = (data: string, type: string) => {
  const buffer = new Buffer(data, 'binary');
  return `data:image/${type};base64,` + buffer.toString('base64');
}

const getFilePath = () => {
  return path.resolve(os.homedir(), 'Download/', `${new Date().getTime()}-screent-shot.png`)
}

export const fileReaderAsBuffer = async (file: File) => {
  const filePath = getFilePath();
  return new Promise((res) => {
    const reader = new FileReader();
    reader.onload = function (e) {
      const arrayBuffer = e.target.result as ArrayBuffer;
      const unit8Array = new Uint8Array(arrayBuffer);
      const buffer = new Buffer(arrayBuffer);
      fs.writeFileSync(filePath, buffer);
      const imageObj = {
        lastModified: file.lastModified,
        //@ts-ignore 
        lastModifiedDate: file.lastModifiedDate,
        name: file.name,
        path: filePath,
        size: file.size,
        type: file.type,
        //@ts-ignore 
        webkitRelativePath: file.webkitRelativePath,
        fileContent: unit8Array,
      };
      res(imageObj);
    };
    reader.readAsArrayBuffer(file);
  })
}

const getImageType = str => {
  const reg = /\.(png|jpg|gif|jpeg|webp)$/;
  return str.match(reg)[1];
}

export const localFileToBase64 = (url) => {
  return new Promise((resolve, reject) => {
    fs.readFile(url, 'binary', (err, data) => {
      if(err) {
        reject(err);
      } else {
        const base64Url = bufferToBase64Url(data, getImageType(url));
        resolve(base64Url);
      }
    })
  });
}

export const getFileByPath = async (filePath) => {
  const size = fs.statSync(filePath).size;
  const name = path.parse(filePath).base;
  const type = name.split('.')[1];
  const fileContent = await fs.readFileSync(filePath);
  return {
    path: filePath,
    size,
    name,
    type,
    fileContent
  }
}