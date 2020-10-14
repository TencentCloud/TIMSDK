package com.tencent.qcloud.tim.tuikit.live.component.danmaku;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.NinePatchDrawable;
import android.os.Handler;
import android.os.HandlerThread;
import android.text.Spannable;
import android.text.SpannableStringBuilder;
import android.text.Spanned;
import android.text.TextPaint;
import android.text.TextUtils;
import android.text.style.ForegroundColorSpan;

import com.bumptech.glide.Glide;
import com.tencent.qcloud.tim.tuikit.live.R;
import com.tencent.qcloud.tim.tuikit.live.utils.UIUtil;

import java.util.HashMap;
import java.util.concurrent.ExecutionException;

import master.flame.danmaku.controller.DrawHandler;
import master.flame.danmaku.controller.IDanmakuView;
import master.flame.danmaku.danmaku.model.BaseDanmaku;
import master.flame.danmaku.danmaku.model.DanmakuTimer;
import master.flame.danmaku.danmaku.model.IDisplayer;
import master.flame.danmaku.danmaku.model.android.BaseCacheStuffer;
import master.flame.danmaku.danmaku.model.android.DanmakuContext;
import master.flame.danmaku.danmaku.model.android.Danmakus;
import master.flame.danmaku.danmaku.model.android.SpannedCacheStuffer;
import master.flame.danmaku.danmaku.parser.BaseDanmakuParser;

/**
 * Module:   DanmakuManager
 * <p>
 * Function: 弹幕管理类
 * <p>
 * 弹幕管理类，代码源自
 * https://github.com/wangpeiyuan/DanmuDemo
 * https://github.com/Bilibili/DanmakuFlameMaster
 * <p>
 * 接口调用：
 * setDanmakuView 设置弹幕view IDanmakuView，可以在xml配置到
 * addDanmu 添加一条弹幕消息
 * <p>
 * UI定制
 * BackgroundCacheStuffer 用于定制弹幕消息背景
 */
public class DanmakuManager {

    private static final String TAG = "DanmakuManager";

    private static final long ADD_DANMU_TIME = 500;      //弹幕显示的时间(如果是list的话，会 * i)，记得加上mDanmakuView.getCurrentTime()
    private static final int  PINK_COLOR = 0xffff5a93;   //粉红 楼主
    private static final int  ORANGE_COLOR = 0xffff815a; //橙色 我
    private static final int  BLACK_COLOR = 0xb2000000;  //黑色 普通

    private Context        mContext;
    private Handler        mDanmuHandler;
    private IDanmakuView   mDanmakuView;
    private DanmakuContext mDanmakuContext;
    private HandlerThread  mDanmuThread;

    private int   mBitmapWidth       = 23;    //头像的宽度
    private int   mBitmapHeight      = 23;    //头像的高度
    private int   mDanmuPadding      = 8;     //这两个用来控制两行弹幕之间的间距
    private int   mDanmuPaddingInner = 7;
    private int   mDanmuRadius       = 11;    //圆角半径
    private float mDanmuTextSize     = 12f;   //弹幕字体的大小
    private int   mMsgColor          = 0;

    public DanmakuManager(Context context) {
        this.mContext = context;
        setSize(context);
        initDanmuConfig();
        mDanmuThread = new HandlerThread("DamuThread");
        mDanmuThread.start();
        mDanmuHandler = new Handler(mDanmuThread.getLooper());

        mMsgColor = mContext.getResources().getColor(R.color.live_color_accent);
    }

    /**
     * 设置弹幕view
     *
     * @param danmakuView 弹幕view
     */
    public void setDanmakuView(IDanmakuView danmakuView) {
        this.mDanmakuView = danmakuView;
        initDanmuView();
    }

    /**
     * 弹幕渲染暂停
     */
    public void pause() {
        if (mDanmakuView != null && mDanmakuView.isPrepared()) {
            mDanmakuView.pause();
        }
    }

    /**
     * 弹幕隐藏
     */
    public void hide() {
        if (mDanmakuView != null) {
            mDanmakuView.hide();
        }
    }

    /**
     * 弹幕显示
     */
    public void show() {
        if (mDanmakuView != null) {
            mDanmakuView.show();
        }
    }

    /**
     * 弹幕渲染恢复
     */
    public void resume() {
        if (mDanmakuView != null && mDanmakuView.isPrepared() && mDanmakuView.isPaused()) {
            mDanmakuView.resume();
        }
    }

    /**
     * 弹幕资源释放
     */
    public void destroy() {
        if (mDanmuThread != null) {
            mDanmuThread.quit();
            mDanmuThread = null;
        }
        if (mDanmakuView != null) {
            mDanmakuView.release();
            mDanmakuView = null;
        }
        mContext = null;

    }

    /**
     * 添加一条弹幕消息
     *
     * @param head     弹幕消息发送者头像
     * @param nickname 弹幕消息发送者昵称
     * @param text     弹幕消息内容
     */
    public void addDanmu(final String head, final String nickname, final String text) {
        if (mDanmuHandler != null) {
            mDanmuHandler.post(new Runnable() {
                @Override
                public void run() {
                    addDanmuInternal(head, nickname, text);
                }
            });
        }
    }

    /**
     * 对数值进行转换，适配手机，必须在初始化之前，否则有些数据不会起作用
     */
    private void setSize(Context context) {
        mBitmapWidth = UIUtil.dp2px(context, mBitmapHeight);
        mBitmapHeight = UIUtil.dp2px(context, mBitmapHeight);
        mDanmuPadding = UIUtil.dp2px(context, mDanmuPadding);
        mDanmuPaddingInner = UIUtil.dp2px(context, mDanmuPaddingInner);
        mDanmuRadius = UIUtil.dp2px(context, mDanmuRadius);
        mDanmuTextSize = UIUtil.sp2px(context, mDanmuTextSize);
    }

    /**
     * 初始化配置
     */
    private void initDanmuConfig() {
        // 设置最大显示行数
        HashMap<Integer, Integer> maxLinesPair = new HashMap<>();
        maxLinesPair.put(BaseDanmaku.TYPE_SCROLL_RL, 2); // 滚动弹幕最大显示2行
        // 设置是否禁止重叠
        HashMap<Integer, Boolean> overlappingEnablePair = new HashMap<>();
        overlappingEnablePair.put(BaseDanmaku.TYPE_SCROLL_RL, true);
        overlappingEnablePair.put(BaseDanmaku.TYPE_FIX_TOP, true);

        mDanmakuContext = DanmakuContext.create();
        mDanmakuContext
                .setDanmakuStyle(IDisplayer.DANMAKU_STYLE_NONE)
                .setDuplicateMergingEnabled(false)
                .setScrollSpeedFactor(1.5f)//越大速度越慢
                .setScaleTextSize(1.2f)
                .setCacheStuffer(new BackgroundCacheStuffer(), mCacheStufferAdapter)
                .setMaximumLines(maxLinesPair)
                .preventOverlapping(overlappingEnablePair);
    }

    /**
     * 绘制背景(自定义弹幕样式)
     */
    private class BackgroundCacheStuffer extends SpannedCacheStuffer {
        // 通过扩展SimpleTextCacheStuffer或SpannedCacheStuffer个性化你的弹幕样式
        final Paint paint = new Paint();

        @Override
        public void measure(BaseDanmaku danmaku, TextPaint paint, boolean fromWorkerThread) {
            //            danmaku.padding = 10;  // 在背景绘制模式下增加padding
            super.measure(danmaku, paint, fromWorkerThread);
        }

        @Override
        public void drawBackground(BaseDanmaku danmaku, Canvas canvas, float left, float top) {
            paint.setAntiAlias(true);
            //            if (!danmaku.isGuest && danmaku.userId == mGoodUserId && mGoodUserId != 0) {
            //                paint.setColor(PINK_COLOR);//粉红 楼主
            //            } else if (!danmaku.isGuest && danmaku.userId == mMyUserId
            //                    && danmaku.userId != 0) {
            //                paint.setColor(ORANGE_COLOR);//橙色 我
            //            } else {
            //                paint.setColor(BLACK_COLOR);//黑色 普通
            //            }
            //            if (danmaku.isGuest) {//如果是赞 就不要设置背景
            //                paint.setColor(Color.TRANSPARENT);
            //            }
            //            canvas.drawRoundRect(new RectF(left + DANMU_PADDING_INNER, top + DANMU_PADDING_INNER
            //                            , left + danmaku.paintWidth - DANMU_PADDING_INNER + 6,
            //                            top + danmaku.paintHeight - DANMU_PADDING_INNER + 6),//+6 主要是底部被截得太厉害了，+6是增加padding的效果
            //                    DANMU_RADIUS, DANMU_RADIUS, paint);

            NinePatchDrawable bg = (NinePatchDrawable) mContext.getResources().getDrawable(R.drawable.live_barrage);
            if (bg != null) {
                bg.setBounds((int) left + 7, (int) top + 5, (int) danmaku.paintWidth, (int) danmaku.paintHeight);
                bg.draw(canvas);
            }
        }

        @Override
        public void drawStroke(BaseDanmaku danmaku, String lineText, Canvas canvas, float left, float top, Paint paint) {
            // 禁用描边绘制
        }
    }

    private BaseCacheStuffer.Proxy mCacheStufferAdapter = new BaseCacheStuffer.Proxy() {

        @Override
        public void prepareDrawing(final BaseDanmaku danmaku, boolean fromWorkerThread) {
            //            if (danmaku.text instanceof Spanned) { // 根据你的条件检查是否需要需要更新弹幕
            //            }
        }

        @Override
        public void releaseResource(BaseDanmaku danmaku) {
            // TODO 重要:清理含有ImageSpan的text中的一些占用内存的资源 例如drawable
            if (danmaku.text instanceof Spanned) {
                danmaku.text = "";
            }
        }
    };

    private void initDanmuView() {
        if (mDanmakuView != null) {
            mDanmakuView.setCallback(new DrawHandler.Callback() {
                @Override
                public void prepared() {
                    mDanmakuView.start();
                }

                @Override
                public void updateTimer(DanmakuTimer timer) {

                }

                @Override
                public void danmakuShown(BaseDanmaku danmaku) {

                }

                @Override
                public void drawingFinished() {

                }
            });
            mDanmakuView.prepare(new BaseDanmakuParser() {

                @Override
                protected Danmakus parse() {
                    return new Danmakus();
                }
            }, mDanmakuContext);
            mDanmakuView.enableDanmakuDrawingCache(true);
        }
    }

    private void addDanmuInternal(String headUrl, String sender, String text) {
        if (mDanmakuView == null) {
            return;
        }
        BaseDanmaku danmaku = mDanmakuContext.mDanmakuFactory.createDanmaku(BaseDanmaku.TYPE_SCROLL_RL);
        if (danmaku == null) {
            return;
        }
        danmaku.userId = 0;
        danmaku.isGuest = false;    //isGuest此处用来判断是赞还是评论

        SpannableStringBuilder spannable;
        Bitmap headBitmap = null;
        if (!TextUtils.isEmpty(headUrl)) {
            try {
                headBitmap =  Glide.with(mContext)
                        .asBitmap()
                        .load(headUrl)
                        .centerCrop()
                        .into(mBitmapWidth, mBitmapHeight)
                        .get();
            } catch (InterruptedException e) {
                e.printStackTrace();
            } catch (ExecutionException e) {
                e.printStackTrace();
            }
        }
        if (headBitmap == null) {
            headBitmap = getDefaultBitmap(R.drawable.live_bg_cover);
        }
        DanmakuCircleDrawable circleDrawable = new DanmakuCircleDrawable(mContext, headBitmap, danmaku.isGuest);
        circleDrawable.setBounds(0, 0, mBitmapWidth, mBitmapHeight);
        spannable = createSpannable(circleDrawable, sender, text);
        danmaku.text = spannable;

        danmaku.padding = mDanmuPadding;
        danmaku.priority = 0;  // 1:一定会显示, 一般用于本机发送的弹幕,但会导致行数的限制失效
        danmaku.isLive = false;
        danmaku.setTime(mDanmakuView.getCurrentTime() + ADD_DANMU_TIME);
        //        danmaku.textSize = DANMU_TEXT_SIZE * (mDanmakuContext.getDisplayer().getDensity() - 0.6f);
        danmaku.textSize = mDanmuTextSize;
        danmaku.textColor = Color.WHITE;
        danmaku.textShadowColor = 0; // 重要：如果有图文混排，最好不要设置描边(设textShadowColor=0)，否则会进行两次复杂的绘制导致运行效率降低
        mDanmakuView.addDanmaku(danmaku);
    }

    private Bitmap getDefaultBitmap(int drawableId) {
        Bitmap mDefauleBitmap = null;
        Bitmap bitmap = BitmapFactory.decodeResource(mContext.getResources(), drawableId);
        if (bitmap != null) {
            int width = bitmap.getWidth();
            int height = bitmap.getHeight();
            Matrix matrix = new Matrix();
            matrix.postScale(((float) mBitmapWidth) / width, ((float) mBitmapHeight) / height);
            mDefauleBitmap = Bitmap.createBitmap(bitmap, 0, 0, width, height, matrix, true);
        }
        return mDefauleBitmap;
    }

    private SpannableStringBuilder createSpannable(Drawable drawable, String sender, String content) {
        String text = "bitmap";
        int spanLen = 0;
        SpannableStringBuilder spannableStringBuilder = new SpannableStringBuilder(text);

        //head pic
        DanmakuCenterImageSpan span = new DanmakuCenterImageSpan(drawable);
        spannableStringBuilder.setSpan(span, 0, text.length(), Spannable.SPAN_INCLUSIVE_EXCLUSIVE);
        spanLen += text.length();

        //msg sender
        if (!TextUtils.isEmpty(sender)) {
            spannableStringBuilder.append(" ");
            spannableStringBuilder.append(sender.trim());
            spanLen += sender.trim().length() + 1;
        }

        //msg content
        if (!TextUtils.isEmpty(content)) {
            spannableStringBuilder.append(" ");
            spannableStringBuilder.append(content.trim());
            spanLen += 1;
            spannableStringBuilder.setSpan(new ForegroundColorSpan(mMsgColor), spanLen, spanLen + content.trim().length(),
                    Spannable.SPAN_INCLUSIVE_EXCLUSIVE);
        }
        return spannableStringBuilder;
    }
}
