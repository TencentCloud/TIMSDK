package com.tencent.qcloud.uikit.common.widget;

import android.annotation.SuppressLint;
import android.content.Context;
import android.support.annotation.Nullable;
import android.util.AttributeSet;
import android.view.View;
import android.widget.TextView;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.Iterator;


/**
 * Created by valexhuang on 2018/10/11.
 */
@SuppressLint("AppCompatCustomView")
public class UIKitTextView extends TextView implements InfoCacheView {
    private HashMap<Method, Object[]> infoCache = new HashMap<>();
    private TextView mRealView;

    public UIKitTextView(Context context) {
        super(context);
    }

    public UIKitTextView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
    }

    public UIKitTextView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    @Override
    public void saveInfo(Method key, Object value[]) {
        infoCache.put(key, value);
    }

    @Override
    public View getRealView() {
        return mRealView;
    }

    @Override
    public void setBackgroundColor(int color) {
    }

    public void attachTextView(TextView textView) {
        mRealView = textView;
        if (infoCache.size() > 0) {
            Iterator<Method> it = infoCache.keySet().iterator();
            while (it.hasNext()) {
                Method method = it.next();
                try {
                    method.invoke(textView, infoCache.get(method));
                } catch (IllegalAccessException e) {
                    e.printStackTrace();
                } catch (InvocationTargetException e) {
                    e.printStackTrace();
                }
            }
        }

    }
}
