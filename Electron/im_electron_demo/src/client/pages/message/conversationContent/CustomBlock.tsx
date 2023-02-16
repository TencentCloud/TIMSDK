import { ContentUtils } from "braft-utils";
import React from "react";
import "../scss/custom-block.scss";
import { getFileTypeName } from "../../../utils/message-input-util";

export const BlockFileComponent = (props: { blockProps: any; block: any }) => {
  const { block, blockProps } = props;

  // 注意：通过blockRendererFn定义的block，无法在编辑器中直接删除，需要在组件中增加删除按钮
  const removeBarBlock = () => {
    blockProps.editor.setValue(
      ContentUtils.removeBlock(blockProps.editorState, block)
    );
  };

  const fileName = getFileTypeName(blockProps.customData.name);

  return (
    <div className="block-file--file">
      <div className="block-file--file___ext">{fileName}</div>
      <div className="block-file--file___content">
        <div className="block-file--file___content____name">
          {blockProps.customData.name}
        </div>
      </div>
    </div>
  );
};

export const BlockVideoComponent = (props: { blockProps: any; block: any }) => {
  const { block, blockProps } = props;

  const fileName = getFileTypeName(blockProps.customData.name);

  return (
    <div className="block-file--file">
      <div className="block-file--file___ext">{fileName}</div>
      <div className="block-file--file___content">
        <div className="block-file--file___content____name">
          {blockProps.customData.name}
        </div>
      </div>
    </div>
  );
};

export const BlockImageComponent = (props: { blockProps: any; block: any }) => {
  const { block, blockProps } = props;

  const { base64URL } = blockProps.customData;

  return (
    <div className="block-image">
      <img src={base64URL} alt="" />
    </div>
  );
};

const BlockReplyMsgComponent =  (props: { blockProps: any; block: any }) => {
  const { block, blockProps } = props;
  const { replyMsg } = blockProps.customData;
  const { message_sender_profile : { user_profile_nick_name, user_profile_identifier}, message_elem_array } = replyMsg as State.message;
  const showName = user_profile_nick_name || user_profile_identifier;

  const getDisplayContent = () => {
    const message = message_elem_array[0];
    const displayTextMsg = message && message.text_elem_content;
    const displayFileMsg = message && message.file_elem_file_name;
    const displayContent = {
            '0': displayTextMsg,
            '1': '[图片]',
            '2': '[声音]',
            '3': '[自定义消息]',
            '4': `[${displayFileMsg}]`,
            '5': '[群组系统消息]',
            '6': '[表情]',
            '7': '[位置]',
            '8': '[群组系统通知]',
            '9': '[视频]',
            '10': '[关系]',
            '11': '[资料]',
            '12': '[合并消息]',
    }[message.elem_type];

    return displayContent;
  }

  return (
    <div className="block-reply-msg">
          <div className="block-reply-msg--name">{showName}:</div>
          <div className="block-reply-msg--message">{getDisplayContent()}</div>
    </div>
  );
}

// 声明blockRendererFn
export const blockRendererFn = (block, { editor, editorState }) => {
  const key = block.getEntityAt(0);
  if (block.getType() === "atomic" && key !== null) {
    const entity = editorState
      .getCurrentContent()
      .getEntity(key);

    const blockData = editorState
      .getCurrentContent()
      .getEntity(key)
      .getData();

    if (entity.getType() === "block-video") {
      return {
        component: BlockVideoComponent,
        editable: false, // 此处的editable并不代表组件内容实际可编辑，强烈建议设置为false
        props: { editor, editorState, customData: blockData }, // 此处传入的内容可以在组件中通过this.props.blockProps获取到
      };
    }

    if (entity.getType() === "block-file") {
      return {
        component: BlockFileComponent,
        editable: false,
        props: { editor, editorState, customData: blockData },
      };
    }

    if (entity.getType() === "block-image") {
      return {
        component: BlockImageComponent,
        editable: false,
        props: { editor, editorState, customData: blockData },
      };
    }

    if (entity.getType() === "block-reply-msg") {
      return {
        component: BlockReplyMsgComponent,
        editable: false, // 此处的editable并不代表组件内容实际可编辑，强烈建议设置为false
        props: { editor, editorState, customData: blockData }, // 此处传入的内容可以在组件中通过this.props.blockProps获取到
      };
    }
  }
};

// export const blockImportFn = (nodeName, node) => {
//   if (nodeName === "div" && node.classList.contains("my-block-video")) {
//     const dataA = node.dataset.a;

//     return {
//       type: "block-foo",
//       data: {
//         dataA: dataA,
//       },
//     };
//   }

//   if (nodeName === "div" && node.classList.contains("my-block-img")) {
//     debugger;
//     const text = node.querySelector("span").innerText;
//     const dataB = node.dataset.b;

//     return {
//       type: "block-bar",
//       data: {
//         text: text,
//         dataB: dataB,
//       },
//     };
//   }
// };

// 自定义block输出转换器，用于将不同的block转换成不同的html内容，通常与blockImportFn中定义的输入转换规则相对应
export const blockExportFn = (contentState, block) => {
  if (block.type === "atomic") {
    const entity = contentState.getEntity(
      contentState.getBlockForKey(block.key).getEntityAt(0)
    );

    const blockData = entity.getData();

    if (entity.getType() === "block-video") {
      return {
        start: `<div class="block-video" >${JSON.stringify(blockData)}`,
        end: "</div>",
      };
    }

    if (entity.getType() === "block-file") {
      return {
        start: `<div class="block-file" >${JSON.stringify(blockData)}`,
        end: "</div>",
      };
    }

    if (entity.getType() === "block-image") {
      const { nase64URL, ...others } = blockData;
      return {
        start: `<div class="block-image">${others}`,
        end: "</div>",
      };
    }

    if(entity.getType() === "block-reply-msg") {
      return {
        start: `<div class="block-reply-msg">${JSON.stringify(blockData)}`,
        end: "</div>",
      }
    }
  }
};
