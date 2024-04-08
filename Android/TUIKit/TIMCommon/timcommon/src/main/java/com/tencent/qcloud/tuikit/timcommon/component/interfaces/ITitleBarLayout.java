package com.tencent.qcloud.tuikit.timcommon.component.interfaces;

import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

/**
 * Conversation list window {@link ConversationLayout}、chat window {@link ChatLayout} have title bar，
 * The title bar is designed as a three-part title on the left, middle and right. The left can be
 * picture + text, the middle is text, and the right can also be picture + text. These areas return the
 * standard Android View，These Views can be interactively processed according to business needs。
 */
public interface ITitleBarLayout {
    /**
     *
     * Set the click event of the left header
     *
     * @param listener
     */
    void setOnLeftClickListener(View.OnClickListener listener);

    /**
     *
     * Set the click event of the right title
     *
     * @param listener
     */
    void setOnRightClickListener(View.OnClickListener listener);

    /**
     * 
     * set Title
     *
     */
    void setTitle(String title, Position position);

    /**
     *
     * Return to the left header area
     *
     * @return
     */
    LinearLayout getLeftGroup();

    /**
     *
     * Return to the right header area
     *
     * @return
     */
    LinearLayout getRightGroup();

    /**
     *
     * Returns the image for the left header
     *
     * @return
     */
    ImageView getLeftIcon();

    /**
     *
     * Set the image for the left header
     *
     * @param resId
     */
    void setLeftIcon(int resId);

    /**
     *
     * Returns the image with the right header
     *
     * @return
     */
    ImageView getRightIcon();

    /**
     *
     * Set the image for the title on the right
     *
     * @param resId
     */
    void setRightIcon(int resId);

    /**
     *
     * Returns the text of the left header
     *
     * @return
     */
    TextView getLeftTitle();

    /**
     *
     * Returns the text of the middle title
     *
     * @return
     */
    TextView getMiddleTitle();

    /**
     *
     * Returns the text of the title on the right
     *
     * @return
     */
    TextView getRightTitle();

    /**
     *
     * enumeration value of the header area
     */
    enum Position {
        /**
         *
         * left title
         */
        LEFT,
        /**
         *
         * middle title
         */
        MIDDLE,
        /**
         *
         * right title
         */
        RIGHT
    }
}
