package com.tencent.qcloud.tim.uikit.modules.chat.interfaces;

import android.view.View;

import com.tencent.qcloud.tim.uikit.modules.chat.base.BaseInputFragment;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.inputmore.InputMoreActionUnit;

public interface IInputLayout {

    /**
     * disable语音输入后，会隐藏按钮
     *
     * @param disable
     */
    void disableAudioInput(boolean disable);

    /**
     * disable表情输入后，会隐藏按钮
     *
     * @param disable
     */
    void disableEmojiInput(boolean disable);

    /**
     * disable更多功能后，会隐藏按钮
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
     * disable发送图片后，会隐藏更多面板上的按钮
     *
     * @param disable
     */
    void disableSendPhotoAction(boolean disable);

    /**
     * disable拍照后，会隐藏更多面板上的按钮
     *
     * @param disable
     */
    void disableCaptureAction(boolean disable);

    /**
     * disable录像后，会隐藏更多面板上的按钮
     *
     * @param disable
     */
    void disableVideoRecordAction(boolean disable);

    /**
     * disable发送文件后，会隐藏更多面板上的按钮
     *
     * @param disable
     */
    void disableSendFileAction(boolean disable);

    /**
     * 增加更多面板上的事件单元
     *
     * @param action 事件单元{@link InputMoreActionUnit}，可以自定义显示的图片、标题以及点击事件
     */
    void addAction(InputMoreActionUnit action);
}
