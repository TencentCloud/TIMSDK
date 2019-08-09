package com.tencent.qcloud.tim.uikit.modules.chat.interfaces;

import android.view.View;

import com.tencent.qcloud.tim.uikit.modules.chat.base.BaseInputFragment;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.input.InputLayout;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.inputmore.InputMoreActionUnit;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.MessageLayout;

/**
 * 输入区域 {@link InputLayout} 实现了一般消息的输入，包括文本、表情、图片、音频、视频、文件等，<br>
 * 并且配合 {@link MessageLayout#setOnCustomMessageDrawListener} 可以完成自定义消息的发送与展示。
 * <br>另外也可以根据需要对上面的功能进行删除或替换。
 */
public interface IInputLayout {

    /**
     * disable 语音输入后，会隐藏按钮
     *
     * @param disable
     */
    void disableAudioInput(boolean disable);

    /**
     * disable 表情输入后，会隐藏按钮
     *
     * @param disable
     */
    void disableEmojiInput(boolean disable);

    /**
     * disable 更多功能后，会隐藏按钮
     *
     * @param disable
     */
    void disableMoreInput(boolean disable);

    /**
     * 替换点击“+”弹出的面板
     *
     * @param fragment
     */
    void replaceMoreInput(BaseInputFragment fragment);

    /**
     * 替换点击“+”响应的事件
     *
     * @param listener
     */
    void replaceMoreInput(View.OnClickListener listener);

    /**
     * disable 发送图片后，会隐藏更多面板上的按钮
     *
     * @param disable
     */
    void disableSendPhotoAction(boolean disable);

    /**
     * disable 拍照后，会隐藏更多面板上的按钮
     *
     * @param disable
     */
    void disableCaptureAction(boolean disable);

    /**
     * disable 录像后，会隐藏更多面板上的按钮
     *
     * @param disable
     */
    void disableVideoRecordAction(boolean disable);

    /**
     * disable 发送文件后，会隐藏更多面板上的按钮
     *
     * @param disable
     */
    void disableSendFileAction(boolean disable);

    /**
     * 增加更多面板上的事件单元
     *
     * @param action 事件单元 {@link InputMoreActionUnit}，可以自定义显示的图片、标题以及点击事件
     */
    void addAction(InputMoreActionUnit action);
}
