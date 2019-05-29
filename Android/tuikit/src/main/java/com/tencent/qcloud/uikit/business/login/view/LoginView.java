package com.tencent.qcloud.uikit.business.login.view;

import android.content.Context;
import android.graphics.Canvas;
import android.support.annotation.Nullable;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.tencent.qcloud.uikit.R;
import com.tencent.qcloud.uikit.api.login.ILoginPanel;


public class LoginView extends LinearLayout implements ILoginPanel, TextWatcher {

    private EditText mUserAccount;
    private EditText mPassword;
    private Button mLoginButton;
    private TextView mRegisterButton;
    private ImageView mLogo;
    private ILoginEvent mLoginEvent;
    private boolean mLoginModel = true;

    public LoginView(Context context) {
        super(context);
        init();
    }

    public LoginView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    private void init() {
        LayoutInflater inflater = LayoutInflater.from(getContext());
        inflater.inflate(R.layout.login_panel, this);
        mLogo = findViewById(R.id.logo);
        mUserAccount = findViewById(R.id.login_user);
        mUserAccount.addTextChangedListener(this);
        mPassword = findViewById(R.id.login_password);
        mPassword.addTextChangedListener(this);
        mLoginButton = findViewById(R.id.login_btn);
        mRegisterButton = findViewById(R.id.register_btn);
        mLoginButton.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mLoginModel) {
                    if (mLoginEvent != null)
                        mLoginEvent.onLoginClick(v, mUserAccount.getText().toString(), mPassword.getText().toString());
                } else {
                    if (mLoginEvent != null)
                        mLoginEvent.onRegisterClick(v, mUserAccount.getText().toString(), mPassword.getText().toString());
                }


            }
        });
        mRegisterButton.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mLoginModel) {
                    if (mLoginEvent != null)
                        mLoginEvent.onRegisterClick(v, mUserAccount.getText().toString(), mPassword.getText().toString());
                } else {
                    if (mLoginEvent != null)
                        mLoginEvent.onLoginClick(v, mUserAccount.getText().toString(), mPassword.getText().toString());
                }
            }
        });
    }

    public void setLoginEvent(ILoginEvent event) {
        this.mLoginEvent = event;
    }

    public EditText getAccountEditor() {
        return mUserAccount;
    }


    public EditText getPasswordEditor() {
        return mPassword;
    }


    @Override
    public void beforeTextChanged(CharSequence s, int start, int count, int after) {

    }

    @Override
    public void onTextChanged(CharSequence s, int start, int before, int count) {

    }

    @Override
    public void afterTextChanged(Editable s) {
        checkButton();
    }


    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
    }

    @Override
    protected void onDetachedFromWindow() {
        mUserAccount.removeTextChangedListener(this);
        mPassword.removeTextChangedListener(this);
        super.onDetachedFromWindow();
    }

    @Override
    protected void onFinishInflate() {
        super.onFinishInflate();
    }


    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
    }

    @Override
    public void draw(Canvas canvas) {
        super.draw(canvas);
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
    }

    @Override
    protected void onLayout(boolean changed, int l, int t, int r, int b) {
        super.onLayout(changed, l, t, r, b);
    }

    public void setModel(boolean isLoginModel) {
        if (mLoginModel == isLoginModel)
            return;
        mLoginModel = isLoginModel;
        if (isLoginModel) {
            mLoginButton.setText("登录");
            mRegisterButton.setText("注册");
        } else {
            mLoginButton.setText("注册 & 登录");
            mRegisterButton.setText("直接登录");
        }
        checkButton();
    }

    public boolean getModel() {
        return mLoginModel;
    }

    private void checkButton() {
        if (TextUtils.isEmpty(mUserAccount.getText()) || TextUtils.isEmpty(mPassword.getText())) {
            mLoginButton.setBackgroundResource(R.drawable.gray_btn_bg);
            mLoginButton.setEnabled(false);
        } else {
            mLoginButton.setBackgroundResource(R.drawable.green_btn_bg);
            mLoginButton.setEnabled(true);
        }
    }

}
