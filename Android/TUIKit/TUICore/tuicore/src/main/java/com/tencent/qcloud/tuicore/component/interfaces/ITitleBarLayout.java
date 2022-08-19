package com.tencent.qcloud.tuicore.component.interfaces;

import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

/**
 * 会话列表窗口 {@link ConversationLayout}、聊天窗口 {@link ChatLayout} 等都自带标题栏，<br>
 * 标题栏设计为左中右三部分标题，左边可为图片+文字，中间为文字，右边也可为图片+文字，这些区域返回的都是标准的<br>
 * Android View，可以根据业务需要对这些 View 进行交互响应处理。
 * 
 * Conversation list window {@link ConversationLayout}、chat window {@link ChatLayout} have title bar，
 * The title bar is designed as a three-part title on the left, middle and right. The left can be 
 * picture + text, the middle is text, and the right can also be picture + text. These areas return the 
 * standard Android View，These Views can be interactively processed according to business needs。
 */
public interface ITitleBarLayout {

    /**
     * 设置左边标题的点击事件
     * 
     * Set the click event of the left header
     *
     * @param listener
     */
    void setOnLeftClickListener(View.OnClickListener listener);

    /**
     * 设置右边标题的点击事件
     * 
     * Set the click event of the right title
     *
     * @param listener
     */
    void setOnRightClickListener(View.OnClickListener listener);

    /**
     * 设置标题
     * 
     * set Title
     *
     */
    void setTitle(String title, Position position);

    /**
     * 返回左边标题区域
     * 
     * Return to the left header area
     *
     * @return
     */
    LinearLayout getLeftGroup();

    /**
     * 返回右边标题区域
     * 
     * Return to the right header area
     *
     * @return
     */
    LinearLayout getRightGroup();

    /**
     * 返回左边标题的图片
     * 
     * Returns the image for the left header
     *
     * @return
     */
    ImageView getLeftIcon();

    /**
     * 设置左边标题的图片
     * 
     * Set the image for the left header
     *
     * @param resId
     */
    void setLeftIcon(int resId);

    /**
     * 返回右边标题的图片
     * 
     * Returns the image with the right header
     *
     * @return
     */
    ImageView getRightIcon();

    /**
     * 设置右边标题的图片
     * 
     * Set the image for the title on the right
     *
     * @param resId
     */
    void setRightIcon(int resId);

    /**
     * 返回左边标题的文字
     * 
     * Returns the text of the left header
     *
     * @return
     */
    TextView getLeftTitle();

    /**
     * 返回中间标题的文字
     * 
     * Returns the text of the middle title
     *
     * @return
     */
    TextView getMiddleTitle();

    /**
     * 返回右边标题的文字
     * 
     * Returns the text of the title on the right
     *
     * @return
     */
    TextView getRightTitle();

    /**
     * 标题区域的枚举值
     * 
     * enumeration value of the header area
     */
    enum Position {
        /**
         * 左边标题
         * 
         * left title
         */
        LEFT,
        /**
         * 中间标题
         * 
         * middle title
         */
        MIDDLE,
        /**
         * 右边标题
         * 
         * right title
         */
        RIGHT
    }

}
