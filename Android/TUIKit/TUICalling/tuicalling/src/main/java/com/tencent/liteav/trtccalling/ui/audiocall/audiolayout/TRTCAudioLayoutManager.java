package com.tencent.liteav.trtccalling.ui.audiocall.audiolayout;

import android.content.Context;
import android.util.AttributeSet;
import android.widget.RelativeLayout;

import com.tencent.liteav.trtccalling.model.impl.base.TRTCLogger;

import java.util.ArrayList;
import java.util.Iterator;

/**
 * 通话过程中，用来显示/管理所有用户头像的{@link TRTCAudioLayout}自定义布局
 */
public class TRTCAudioLayoutManager extends RelativeLayout {
    private static final String TAG = "TRTCAudioLayoutManager";

    public static final int MAX_USER = 9;

    private String  mSelfUserId;
    private Context mContext;
    private int     mCount     = 0;
    private boolean mInitParam = false;

    private ArrayList<LayoutParams>     mGrid1ParamList;
    private ArrayList<LayoutParams>     mGrid2ParamList;
    private ArrayList<LayoutParams>     mGrid3ParamList;
    private ArrayList<LayoutParams>     mGrid4ParamList;
    private ArrayList<LayoutParams>     mGrid9ParamList;
    private ArrayList<TRTCLayoutEntity> mLayoutEntityList;

    public TRTCAudioLayoutManager(Context context) {
        super(context);
        initView(context);
    }

    public TRTCAudioLayoutManager(Context context, AttributeSet attrs) {
        super(context, attrs);
        initView(context);
    }

    public TRTCAudioLayoutManager(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        initView(context);
    }

    private void initView(Context context) {
        TRTCLogger.i(TAG, "initView");
        mContext = context;
        // 做成正方形
        mLayoutEntityList = new ArrayList<TRTCLayoutEntity>();
        this.post(new Runnable() {
            @Override
            public void run() {
                makeGirdLayout(true);
            }
        });
    }

    public void setMySelfUserId(String userId) {
        mSelfUserId = userId;
    }

    /**
     * 根据 userId 找到已经分配的 View
     */
    public TRTCAudioLayout findAudioCallLayout(String userId) {
        if (userId == null) return null;
        for (TRTCLayoutEntity layoutEntity : mLayoutEntityList) {
            if (layoutEntity.userId.equals(userId)) {
                return layoutEntity.layout;
            }
        }
        return null;
    }

    /**
     * 根据 userId 分配对应的 view
     *
     * @param userId
     * @return
     */
    public TRTCAudioLayout allocAudioCallLayout(String userId) {
        if (userId == null) return null;
        if (mCount > MAX_USER) {
            return null;
        }
        TRTCLayoutEntity layoutEntity = new TRTCLayoutEntity();
        layoutEntity.userId = userId;
        layoutEntity.layout = new TRTCAudioLayout(mContext);
        layoutEntity.layout.setVisibility(VISIBLE);
        mLayoutEntityList.add(layoutEntity);
        addView(layoutEntity.layout);
        mCount++;
        post(new Runnable() {
            @Override
            public void run() {
                makeGirdLayout(true);
            }
        });
        return layoutEntity.layout;
    }

    /**
     * 根据 userId 回收对应的 view
     *
     * @param userId
     */
    public void recyclerAudioCallLayout(String userId) {
        if (userId == null) return;
        Iterator iterator = mLayoutEntityList.iterator();
        while (iterator.hasNext()) {
            TRTCLayoutEntity item = (TRTCLayoutEntity) iterator.next();
            if (item.userId.equals(userId)) {
                removeView(item.layout);
                iterator.remove();
                mCount--;
                break;
            }
        }
        post(new Runnable() {
            @Override
            public void run() {
                makeGirdLayout(true);
            }
        });
    }

    /**
     * 设置当前音量
     *
     * @param userId
     * @param audioVolume
     */
    public void updateAudioVolume(String userId, int audioVolume) {
        if (userId == null) return;
        for (TRTCLayoutEntity entity : mLayoutEntityList) {
            if (entity.layout.getVisibility() == VISIBLE) {
                if (userId.equals(entity.userId)) {
                    entity.layout.setAudioVolume(audioVolume);
                }
            }
        }
    }

    private TRTCLayoutEntity findEntity(TRTCAudioLayout layout) {
        for (TRTCLayoutEntity entity : mLayoutEntityList) {
            if (entity.layout == layout) return entity;
        }
        return null;
    }

    private TRTCLayoutEntity findEntity(String userId) {
        for (TRTCLayoutEntity entity : mLayoutEntityList) {
            if (entity.userId.equals(userId)) return entity;
        }
        return null;
    }

    /**
     * 切换到九宫格布局
     *
     * @param needUpdate 是否需要更新布局
     */
    private void makeGirdLayout(boolean needUpdate) {
        if (!mInitParam) {
            mGrid1ParamList = Utils.initGrid1Param(getContext(), getWidth(), getHeight());
            mGrid2ParamList = Utils.initGrid2Param(getContext(), getWidth(), getHeight());
            mGrid3ParamList = Utils.initGrid3Param(getContext(), getWidth(), getHeight());
            mGrid4ParamList = Utils.initGrid4Param(getContext(), getWidth(), getHeight());
            mGrid9ParamList = Utils.initGrid9Param(getContext(), getWidth(), getHeight());
            mInitParam = true;
        }
        if (needUpdate) {
            if (mLayoutEntityList.isEmpty()) {
                return;
            }
            ArrayList<LayoutParams> paramList;
            if (mCount <= 1) {
//                paramList = mGrid1ParamList;
//                TRTCLayoutEntity entity = mLayoutEntityList.get(0);
//                entity.layout.setLayoutParams(paramList.get(0));
                return;
            } else if (mCount == 2) {
                paramList = mGrid2ParamList;
            } else if (mCount == 3) {
                paramList = mGrid3ParamList;
            } else if (mCount == 4) {
                paramList = mGrid4ParamList;
            } else {
                paramList = mGrid9ParamList;
            }
            int layoutIndex = 1;
            for (int i = 0; i < mLayoutEntityList.size(); i++) {
                TRTCLayoutEntity entity = mLayoutEntityList.get(i);
                // 我自己要放在布局的左上角
                if (entity.userId.equals(mSelfUserId)) {
                    entity.layout.setLayoutParams(paramList.get(0));
                } else if (layoutIndex < paramList.size()) {
                    entity.layout.setLayoutParams(paramList.get(layoutIndex++));
                }
            }
        }
    }

    private static class TRTCLayoutEntity {
        public TRTCAudioLayout layout;
        public String          userId = "";
    }
}
