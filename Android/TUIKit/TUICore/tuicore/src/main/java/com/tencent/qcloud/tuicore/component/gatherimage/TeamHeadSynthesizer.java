package com.tencent.qcloud.tuicore.component.gatherimage;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Rect;
import android.text.TextUtils;
import android.widget.ImageView;

import com.tencent.qcloud.tuicore.R;
import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuicore.component.imageEngine.impl.GlideEngine;
import com.tencent.qcloud.tuicore.util.BackgroundTasks;
import com.tencent.qcloud.tuicore.util.ImageUtil;
import com.tencent.qcloud.tuicore.util.ThreadHelper;

import java.io.File;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ExecutionException;


public class TeamHeadSynthesizer implements Synthesizer {

    /**
     * 多图片数据
     */
    MultiImageData multiImageData;
    Context mContext;

    ImageView imageView;

    // currentImageId 只在主线程中设置和获取，是安全的
    private String currentImageId = "";
    Callback callback = new Callback() {
        @Override
        public void onCall(Bitmap bitmap, String targetID) {
            // 异步加载结束之后可能当前 view 已经被复用，不能再设置上次请求的 bitmap
            if (!TextUtils.equals(getImageId(), targetID)) {
                return;
            }
            GlideEngine.loadUserIcon(imageView, bitmap);
        }
    };


    public TeamHeadSynthesizer(Context mContext, ImageView imageView) {
        this.mContext = mContext;
        this.imageView = imageView;
        init();
    }

    private void init() {
        multiImageData = new MultiImageData();
    }

    public void setMaxWidthHeight(int maxWidth, int maxHeight) {
        multiImageData.maxWidth = maxWidth;
        multiImageData.maxHeight = maxHeight;
    }

    public MultiImageData getMultiImageData() {
        return multiImageData;
    }

    public int getDefaultImage() {
        return multiImageData.getDefaultImageResId();
    }

    public void setDefaultImage(int defaultImageResId) {
        multiImageData.setDefaultImageResId(defaultImageResId);
    }

    public void setBgColor(int bgColor) {
        multiImageData.bgColor = bgColor;
    }

    public void setGap(int gap) {
        multiImageData.gap = gap;
    }

    /**
     * 设置宫格参数
     *
     * @param imagesSize 图片数量
     * @return 宫格参数 gridParam[0] 宫格行数 gridParam[1] 宫格列数
     */
    protected int[] calculateGridParam(int imagesSize) {
        int[] gridParam = new int[2];
        if (imagesSize < 3) {
            gridParam[0] = 1;
            gridParam[1] = imagesSize;
        } else if (imagesSize <= 4) {
            gridParam[0] = 2;
            gridParam[1] = 2;
        } else {
            gridParam[0] = imagesSize / 3 + (imagesSize % 3 == 0 ? 0 : 1);
            gridParam[1] = 3;
        }
        return gridParam;
    }

    @Override
    public Bitmap synthesizeImageList(MultiImageData imageData) {
        Bitmap mergeBitmap = Bitmap.createBitmap(imageData.maxWidth, imageData.maxHeight, Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(mergeBitmap);
        drawDrawable(canvas, imageData);
        canvas.save();
        canvas.restore();
        return mergeBitmap;
    }

    @Override
    public boolean asyncLoadImageList(MultiImageData imageData) {
        boolean loadSuccess = true;
        List<Object> imageUrls = imageData.getImageUrls();
        for (int i = 0; i < imageUrls.size(); i++) {
            Bitmap defaultIcon = BitmapFactory.decodeResource(mContext.getResources(), TUIThemeManager.getAttrResId(mContext, R.attr.core_default_user_icon));
            //下载图片
            try {
                Bitmap bitmap = asyncLoadImage(imageUrls.get(i), imageData.targetImageSize);
                imageData.putBitmap(bitmap, i);
            } catch (InterruptedException e) {
                e.printStackTrace();
                imageData.putBitmap(defaultIcon, i);
            } catch (ExecutionException e) {
                e.printStackTrace();
                imageData.putBitmap(defaultIcon, i);
            }
        }
        //下载完毕
        return loadSuccess;
    }

    @Override
    public void drawDrawable(Canvas canvas, MultiImageData imageData) {
        //画背景
        canvas.drawColor(imageData.bgColor);
        //画组合图片
        int size = imageData.size();
        int t_center = (imageData.maxHeight + imageData.gap) / 2;//中间位置以下的顶点（有宫格间距）
        int b_center = (imageData.maxHeight - imageData.gap) / 2;//中间位置以上的底部（有宫格间距）
        int l_center = (imageData.maxWidth + imageData.gap) / 2;//中间位置以右的左部（有宫格间距）
        int r_center = (imageData.maxWidth - imageData.gap) / 2;//中间位置以左的右部（有宫格间距）
        int center = (imageData.maxHeight - imageData.targetImageSize) / 2;//中间位置以上顶部（无宫格间距）
        for (int i = 0; i < size; i++) {
            int rowNum = i / imageData.columnCount;//当前行数
            int columnNum = i % imageData.columnCount;//当前列数

            int left = ((int) (imageData.targetImageSize * (imageData.columnCount == 1 ? columnNum + 0.5 : columnNum) + imageData.gap * (columnNum + 1)));
            int top = ((int) (imageData.targetImageSize * (imageData.columnCount == 1 ? rowNum + 0.5 : rowNum) + imageData.gap * (rowNum + 1)));
            int right = left + imageData.targetImageSize;
            int bottom = top + imageData.targetImageSize;

            Bitmap bitmap = imageData.getBitmap(i);
            if (size == 1) {
                drawBitmapAtPosition(canvas, left, top, right, bottom, bitmap);
            } else if (size == 2) {
                drawBitmapAtPosition(canvas, left, center, right, center + imageData.targetImageSize, bitmap);
            } else if (size == 3) {
                if (i == 0) {
                    drawBitmapAtPosition(canvas, center, top, center + imageData.targetImageSize, bottom, bitmap);
                } else {
                    drawBitmapAtPosition(canvas, imageData.gap * i + imageData.targetImageSize * (i - 1), t_center, imageData.gap * i + imageData.targetImageSize * i, t_center + imageData.targetImageSize, bitmap);
                }
            } else if (size == 4) {
                drawBitmapAtPosition(canvas, left, top, right, bottom, bitmap);
            } else if (size == 5) {
                if (i == 0) {
                    drawBitmapAtPosition(canvas, r_center - imageData.targetImageSize, r_center - imageData.targetImageSize, r_center, r_center, bitmap);
                } else if (i == 1) {
                    drawBitmapAtPosition(canvas, l_center, r_center - imageData.targetImageSize, l_center + imageData.targetImageSize, r_center, bitmap);
                } else {
                    drawBitmapAtPosition(canvas, imageData.gap * (i - 1) + imageData.targetImageSize * (i - 2), t_center, imageData.gap * (i - 1) + imageData.targetImageSize * (i - 1), t_center +
                            imageData.targetImageSize, bitmap);
                }
            } else if (size == 6) {
                if (i < 3) {
                    drawBitmapAtPosition(canvas, imageData.gap * (i + 1) + imageData.targetImageSize * i, b_center - imageData.targetImageSize, imageData.gap * (i + 1) + imageData.targetImageSize * (i + 1), b_center, bitmap);
                } else {
                    drawBitmapAtPosition(canvas, imageData.gap * (i - 2) + imageData.targetImageSize * (i - 3), t_center, imageData.gap * (i - 2) + imageData.targetImageSize * (i - 2), t_center +
                            imageData.targetImageSize, bitmap);
                }
            } else if (size == 7) {
                if (i == 0) {
                    drawBitmapAtPosition(canvas, center, imageData.gap, center + imageData.targetImageSize, imageData.gap + imageData.targetImageSize, bitmap);
                } else if (i > 0 && i < 4) {
                    drawBitmapAtPosition(canvas, imageData.gap * i + imageData.targetImageSize * (i - 1), center, imageData.gap * i + imageData.targetImageSize * i, center + imageData.targetImageSize, bitmap);
                } else {
                    drawBitmapAtPosition(canvas, imageData.gap * (i - 3) + imageData.targetImageSize * (i - 4), t_center + imageData.targetImageSize / 2, imageData.gap * (i - 3) + imageData.targetImageSize * (i - 3), t_center + imageData.targetImageSize / 2 + imageData.targetImageSize, bitmap);
                }
            } else if (size == 8) {
                if (i == 0) {
                    drawBitmapAtPosition(canvas, r_center - imageData.targetImageSize, imageData.gap, r_center, imageData.gap + imageData.targetImageSize, bitmap);
                } else if (i == 1) {
                    drawBitmapAtPosition(canvas, l_center, imageData.gap, l_center + imageData.targetImageSize, imageData.gap + imageData.targetImageSize, bitmap);
                } else if (i > 1 && i < 5) {
                    drawBitmapAtPosition(canvas, imageData.gap * (i - 1) + imageData.targetImageSize * (i - 2), center, imageData.gap * (i - 1) + imageData.targetImageSize * (i - 1), center + imageData.targetImageSize, bitmap);
                } else {
                    drawBitmapAtPosition(canvas, imageData.gap * (i - 4) + imageData.targetImageSize * (i - 5), t_center + imageData.targetImageSize / 2, imageData.gap * (i - 4) + imageData.targetImageSize * (i - 4), t_center + imageData.targetImageSize / 2 + imageData.targetImageSize, bitmap);
                }
            } else if (size == 9) {
                drawBitmapAtPosition(canvas, left, top, right, bottom, bitmap);
            }
        }
    }

    /**
     * 根据坐标画图
     *
     * @param canvas
     * @param left
     * @param top
     * @param right
     * @param bottom
     * @param bitmap
     */
    public void drawBitmapAtPosition(Canvas canvas, int left, int top, int right, int bottom, Bitmap bitmap) {
        if (null == bitmap) {
            //图片为空用默认图片
            if (multiImageData.getDefaultImageResId() > 0) {
                //设置过默认id
                bitmap = BitmapFactory.decodeResource(mContext.getResources(), multiImageData.getDefaultImageResId());
            }
        }
        if (null != bitmap) {
            Rect rect = new Rect(left, top, right, bottom);
            canvas.drawBitmap(bitmap, null, rect, null);
        }
    }

    /**
     * 同步加载图片
     *
     * @param imageUrl
     * @param targetImageSize
     * @return
     */
    private Bitmap asyncLoadImage(Object imageUrl, int targetImageSize) throws ExecutionException, InterruptedException {
        return GlideEngine.loadBitmap(imageUrl, targetImageSize);
    }

    public void setImageId(String id) {
        currentImageId = id;
    }

    public String getImageId() {
        return currentImageId;
    }

    /**
     * 加载图片
     * @param imageId 发起图片加载请求时的图片 ID
     */
    public void load(String imageId) {
        if (multiImageData.size() == 0) {
            // 发起请求时的图片 id 和当前图片 id 不一致，说明发生了复用，此时不应该再设置图像
            if (imageId != null && !TextUtils.equals(imageId, currentImageId)) {
                return;
            }
            GlideEngine.loadUserIcon(imageView, getDefaultImage());
            return;
        }

        if (multiImageData.size() == 1) {
            // 发起请求时的图片 id 和当前图片 id 不一致，说明发生了复用，此时不应该再设置图像
            if (imageId != null && !TextUtils.equals(imageId, currentImageId)) {
                return;
            }
            GlideEngine.loadUserIcon(imageView, multiImageData.getImageUrls().get(0));
            return;
        }

        // 异步加载图像前先清空内容，避免闪烁
        clearImage();

        // 初始化图片信息，由于是异步加载和合成头像，这里需要传给合成线程一个局部对象，只在异步加载线程中使用
        // 这样在图片被复用时外部线程再次设置 url 就不会覆盖此局部对象
        MultiImageData copyMultiImageData;
        try {
            copyMultiImageData = multiImageData.clone();
        } catch (CloneNotSupportedException e) {
            e.printStackTrace();
            List urlList = new ArrayList();
            if (multiImageData.imageUrls != null) {
                urlList.addAll(multiImageData.imageUrls);
            }
            copyMultiImageData = new MultiImageData(urlList, multiImageData.defaultImageResId);
        }
        int[] gridParam = calculateGridParam(multiImageData.size());
        copyMultiImageData.rowCount = gridParam[0];
        copyMultiImageData.columnCount = gridParam[1];
        copyMultiImageData.targetImageSize = (copyMultiImageData.maxWidth - (copyMultiImageData.columnCount + 1)
                * copyMultiImageData.gap) / (copyMultiImageData.columnCount == 1 ? 2 : copyMultiImageData.columnCount);//图片尺寸
        final String finalImageId = imageId;
        final MultiImageData finalCopyMultiImageData = copyMultiImageData;
        ThreadHelper.INST.execute(new Runnable() {
            @Override
            public void run() {
                //根据id获取存储的文件路径
                final File file = new File(TUIConfig.getImageBaseDir() + finalImageId);
                boolean cacheBitmapExists = false;
                Bitmap existsBitmap = null;
                if (file.exists() && file.isFile()) {
                    //文件存在，加载到内存
                    BitmapFactory.Options options = new BitmapFactory.Options();
                    existsBitmap = BitmapFactory.decodeFile(file.getPath(), options);
                    if (options.outWidth > 0 && options.outHeight > 0) {
                        //当前文件是图片
                        cacheBitmapExists = true;
                    }
                }
                if (!cacheBitmapExists) {
                    // 收集图片
                    asyncLoadImageList(finalCopyMultiImageData);
                    // 合成图片
                    final Bitmap bitmap = synthesizeImageList(finalCopyMultiImageData);
                    ImageUtil.storeBitmap(file, bitmap);
                    ImageUtil.setGroupConversationAvatar(finalImageId, file.getAbsolutePath());
                    BackgroundTasks.getInstance().runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            callback.onCall(bitmap, finalImageId);
                        }
                    });
                } else {
                    final Bitmap finalExistsBitmap = existsBitmap;
                    BackgroundTasks.getInstance().runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            callback.onCall(finalExistsBitmap, finalImageId);
                        }
                    });
                }
            }
        });
    }

    public void clearImage() {
        GlideEngine.clear(imageView);
    }

    interface Callback {
        void onCall(Bitmap bitmap, String targetID);
    }

}
