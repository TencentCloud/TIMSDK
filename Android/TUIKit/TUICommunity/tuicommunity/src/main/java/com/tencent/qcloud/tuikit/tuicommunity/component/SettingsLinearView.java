package com.tencent.qcloud.tuikit.tuicommunity.component;

import android.content.Context;
import android.content.res.TypedArray;
import android.os.Build;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;
import com.tencent.qcloud.tuikit.timcommon.component.RoundCornerImageView;
import com.tencent.qcloud.tuikit.tuicommunity.R;

public class SettingsLinearView extends LinearLayout {
    private String name;
    private String content;
    private boolean isShowBottomLine;
    private boolean isShowTopLine;
    private boolean isShowArrow;
    private boolean isShowCopy;
    private boolean isShowContentText;
    private boolean isShowContentImage;

    private TextView nameText;
    private TextView contentText;
    private ImageView arrowView;
    private View contentView;
    private RoundCornerImageView contentImage;
    private TextCopyView copyView;

    private int nameColor;
    private int nameColorResID;
    private int contentColor;
    private int contentColorResID;

    private int contentImageWidth;
    private int contentImageHeight;

    public SettingsLinearView(Context context) {
        super(context);
        init(context, null);
    }

    public SettingsLinearView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init(context, attrs);
    }

    public SettingsLinearView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context, attrs);
    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    public SettingsLinearView(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
        init(context, attrs);
    }

    private void init(Context context, AttributeSet attrs) {
        if (attrs == null) {
            setUpView();
            return;
        }
        LayoutInflater.from(context).inflate(R.layout.community_settings_linear_layout, this);
        TypedArray ta = context.obtainStyledAttributes(attrs, R.styleable.SettingsLinearView, 0, 0);
        try {
            name = ta.getString(R.styleable.SettingsLinearView_setting_name);
            content = ta.getString(R.styleable.SettingsLinearView_setting_content);
            int defaultNameColor = getResources().getColor(R.color.community_setting_linear_name_default_color);
            nameColor = ta.getColor(R.styleable.SettingsLinearView_setting_name_color, defaultNameColor);
            nameColorResID = ta.getResourceId(R.styleable.SettingsLinearView_setting_name_color, 0);
            int defaultContentColor = getResources().getColor(R.color.community_setting_linear_content_default_color);
            contentColor = ta.getColor(R.styleable.SettingsLinearView_setting_content_color, defaultContentColor);
            contentColorResID = ta.getResourceId(R.styleable.SettingsLinearView_setting_content_color, 0);

            isShowContentText = ta.getBoolean(R.styleable.SettingsLinearView_setting_is_show_content_text, true);
            isShowContentImage = ta.getBoolean(R.styleable.SettingsLinearView_setting_is_show_content_image, false);
            name = ta.getString(R.styleable.SettingsLinearView_setting_name);
            isShowBottomLine = ta.getBoolean(com.tencent.qcloud.tuikit.timcommon.R.styleable.LineControllerView_isBottom, false);
            isShowCopy = ta.getBoolean(R.styleable.SettingsLinearView_setting_is_show_copy, false);
            isShowArrow = ta.getBoolean(R.styleable.SettingsLinearView_setting_is_show_arrow, true);
            isShowTopLine = ta.getBoolean(R.styleable.SettingsLinearView_setting_is_show_top_line, false);
            isShowBottomLine = ta.getBoolean(R.styleable.SettingsLinearView_setting_is_show_bottom_line, false);

            contentImageWidth = ta.getDimensionPixelOffset(R.styleable.SettingsLinearView_setting_content_image_width, ViewGroup.LayoutParams.WRAP_CONTENT);
            contentImageHeight = ta.getDimensionPixelOffset(R.styleable.SettingsLinearView_setting_content_image_height, ViewGroup.LayoutParams.MATCH_PARENT);
        } finally {
            ta.recycle();
        }
        setUpView();
    }

    private void setUpView() {
        copyView = findViewById(R.id.copy_button);
        copyView.setVisibility(isShowCopy ? VISIBLE : GONE);

        contentView = findViewById(R.id.content);
        // name text and color
        nameText = findViewById(R.id.name);
        nameText.setText(name);
        int tempNameColor = nameColor;
        if (nameColorResID != 0) {
            tempNameColor = getResources().getColor(nameColorResID);
        }
        nameText.setTextColor(tempNameColor);

        // content text and color
        contentText = findViewById(R.id.content_text);
        setContent(content);
        int tempContentColor = contentColor;
        if (contentColorResID != 0) {
            tempContentColor = getResources().getColor(contentColorResID);
        }
        contentText.setTextColor(tempContentColor);
        contentText.setVisibility(isShowContentText ? VISIBLE : GONE);

        View bottomLine = findViewById(R.id.bottom_line);
        View topLine = findViewById(R.id.top_line);
        bottomLine.setVisibility(isShowBottomLine ? VISIBLE : GONE);
        topLine.setVisibility(isShowTopLine ? VISIBLE : GONE);

        setupArrow();

        contentImage = findViewById(R.id.content_image);
        contentImage.setVisibility(isShowContentImage ? VISIBLE : GONE);
        ViewGroup.LayoutParams layoutParams = contentImage.getLayoutParams();
        layoutParams.width = contentImageWidth;
        layoutParams.height = contentImageHeight;
        contentImage.setLayoutParams(layoutParams);
    }

    private void setupArrow() {
        arrowView = findViewById(R.id.right_arrow);
        arrowView.setVisibility(isShowArrow ? VISIBLE : GONE);
    }

    /**
     * 获取内容
     */
    public String getContent() {
        return contentText.getText().toString();
    }

    public void setName(String name) {
        this.name = name;
        nameText.setText(name);
    }

    public TextView getContentText() {
        return contentText;
    }

    /**
     * 设置文字内容
     *
     * @param content 内容
     */
    public void setContent(String content) {
        this.content = content;
        contentText.setText(content);
        if (TextUtils.isEmpty(content)) {
            copyView.setVisibility(GONE);
        } else {
            if (isShowCopy) {
                copyView.setVisibility(VISIBLE);
            }
        }
    }

    public void setShowArrow(boolean isShowArrow) {
        this.isShowArrow = isShowArrow;
        setupArrow();
    }

    public void setOnContentClickListener(View.OnClickListener clickListener) {
        contentView.setOnClickListener(clickListener);
    }

    public RoundCornerImageView getContentImage() {
        return contentImage;
    }
}
