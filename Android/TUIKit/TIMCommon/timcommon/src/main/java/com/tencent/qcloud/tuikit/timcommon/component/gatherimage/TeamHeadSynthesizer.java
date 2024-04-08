package com.tencent.qcloud.tuikit.timcommon.component.gatherimage;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Rect;
import android.text.TextUtils;
import android.widget.ImageView;
import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuikit.timcommon.TIMCommonConfig;
import com.tencent.qcloud.tuikit.timcommon.component.impl.GlideEngine;
import com.tencent.qcloud.tuikit.timcommon.util.ImageUtil;
import com.tencent.qcloud.tuikit.timcommon.util.ThreadUtils;
import java.io.File;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ExecutionException;

public class TeamHeadSynthesizer implements Synthesizer {
    MultiImageData multiImageData;
    Context mContext;

    ImageView imageView;

    // It is safe to set and get only in the main thread
    private String currentImageId = "";
    Callback callback = new Callback() {
        @Override
        public void onCall(Bitmap bitmap, String targetID) {
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
     * Set Grid params
     *
     * @param imagesSize   Number of pictures
     * @return gridParam[0] Rows gridParam[1] columns
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
            Bitmap defaultIcon = BitmapFactory.decodeResource(mContext.getResources(), TIMCommonConfig.getDefaultAvatarImage());
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
        return loadSuccess;
    }

    @Override
    public void drawDrawable(Canvas canvas, MultiImageData imageData) {
        canvas.drawColor(imageData.bgColor);
        int size = imageData.size();
        int tCenter = (imageData.maxHeight + imageData.gap) / 2;
        int bCenter = (imageData.maxHeight - imageData.gap) / 2;
        int lCenter = (imageData.maxWidth + imageData.gap) / 2;
        int rCenter = (imageData.maxWidth - imageData.gap) / 2;
        int center = (imageData.maxHeight - imageData.targetImageSize) / 2;
        for (int i = 0; i < size; i++) {
            int rowNum = i / imageData.columnCount;
            int columnNum = i % imageData.columnCount;

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
                    drawBitmapAtPosition(canvas, imageData.gap * i + imageData.targetImageSize * (i - 1), tCenter,
                        imageData.gap * i + imageData.targetImageSize * i, tCenter + imageData.targetImageSize, bitmap);
                }
            } else if (size == 4) {
                drawBitmapAtPosition(canvas, left, top, right, bottom, bitmap);
            } else if (size == 5) {
                if (i == 0) {
                    drawBitmapAtPosition(canvas, rCenter - imageData.targetImageSize, rCenter - imageData.targetImageSize, rCenter, rCenter, bitmap);
                } else if (i == 1) {
                    drawBitmapAtPosition(canvas, lCenter, rCenter - imageData.targetImageSize, lCenter + imageData.targetImageSize, rCenter, bitmap);
                } else {
                    drawBitmapAtPosition(canvas, imageData.gap * (i - 1) + imageData.targetImageSize * (i - 2), tCenter,
                        imageData.gap * (i - 1) + imageData.targetImageSize * (i - 1), tCenter + imageData.targetImageSize, bitmap);
                }
            } else if (size == 6) {
                if (i < 3) {
                    drawBitmapAtPosition(canvas, imageData.gap * (i + 1) + imageData.targetImageSize * i, bCenter - imageData.targetImageSize,
                        imageData.gap * (i + 1) + imageData.targetImageSize * (i + 1), bCenter, bitmap);
                } else {
                    drawBitmapAtPosition(canvas, imageData.gap * (i - 2) + imageData.targetImageSize * (i - 3), tCenter,
                        imageData.gap * (i - 2) + imageData.targetImageSize * (i - 2), tCenter + imageData.targetImageSize, bitmap);
                }
            } else if (size == 7) {
                if (i == 0) {
                    drawBitmapAtPosition(canvas, center, imageData.gap, center + imageData.targetImageSize, imageData.gap + imageData.targetImageSize, bitmap);
                } else if (i > 0 && i < 4) {
                    drawBitmapAtPosition(canvas, imageData.gap * i + imageData.targetImageSize * (i - 1), center,
                        imageData.gap * i + imageData.targetImageSize * i, center + imageData.targetImageSize, bitmap);
                } else {
                    drawBitmapAtPosition(canvas, imageData.gap * (i - 3) + imageData.targetImageSize * (i - 4), tCenter + imageData.targetImageSize / 2,
                        imageData.gap * (i - 3) + imageData.targetImageSize * (i - 3), tCenter + imageData.targetImageSize / 2 + imageData.targetImageSize,
                        bitmap);
                }
            } else if (size == 8) {
                if (i == 0) {
                    drawBitmapAtPosition(
                        canvas, rCenter - imageData.targetImageSize, imageData.gap, rCenter, imageData.gap + imageData.targetImageSize, bitmap);
                } else if (i == 1) {
                    drawBitmapAtPosition(
                        canvas, lCenter, imageData.gap, lCenter + imageData.targetImageSize, imageData.gap + imageData.targetImageSize, bitmap);
                } else if (i > 1 && i < 5) {
                    drawBitmapAtPosition(canvas, imageData.gap * (i - 1) + imageData.targetImageSize * (i - 2), center,
                        imageData.gap * (i - 1) + imageData.targetImageSize * (i - 1), center + imageData.targetImageSize, bitmap);
                } else {
                    drawBitmapAtPosition(canvas, imageData.gap * (i - 4) + imageData.targetImageSize * (i - 5), tCenter + imageData.targetImageSize / 2,
                        imageData.gap * (i - 4) + imageData.targetImageSize * (i - 4), tCenter + imageData.targetImageSize / 2 + imageData.targetImageSize,
                        bitmap);
                }
            } else if (size == 9) {
                drawBitmapAtPosition(canvas, left, top, right, bottom, bitmap);
            }
        }
    }

    /**
     * DrawBitmap
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
            if (multiImageData.getDefaultImageResId() > 0) {
                bitmap = BitmapFactory.decodeResource(mContext.getResources(), multiImageData.getDefaultImageResId());
            }
        }
        if (null != bitmap) {
            Rect rect = new Rect(left, top, right, bottom);
            canvas.drawBitmap(bitmap, null, rect, null);
        }
    }

    private Bitmap asyncLoadImage(Object imageUrl, int targetImageSize) throws ExecutionException, InterruptedException {
        return GlideEngine.loadBitmap(imageUrl, targetImageSize);
    }

    public void setImageId(String id) {
        currentImageId = id;
    }

    public String getImageId() {
        return currentImageId;
    }

    public void load(String imageId) {
        if (multiImageData.size() == 0) {
            
            // The image id when the request is initiated is inconsistent with the current image id,
            // indicating that multiplexing has occurred, and the image should not be set at this time.
            if (imageId != null && !TextUtils.equals(imageId, currentImageId)) {
                return;
            }
            GlideEngine.loadUserIcon(imageView, getDefaultImage());
            return;
        }

        if (multiImageData.size() == 1) {
            
            // The image id when the request is initiated is inconsistent with the current image id,
            // indicating that multiplexing has occurred, and the image should not be set at this time.
            if (imageId != null && !TextUtils.equals(imageId, currentImageId)) {
                return;
            }
            GlideEngine.loadUserIcon(imageView, multiImageData.getImageUrls().get(0));
            return;
        }

        
        // Clear the content before loading images asynchronously to avoid flickering
        clearImage();

        
        
        // Initialize the image information. Since it is asynchronous loading and synthesizing the avatar,
        // a local object needs to be passed to the synthesis thread, which is only used in the asynchronous
        // loading thread, so that when the image is reused, the external thread will not overwrite the local
        // object by setting the url again.
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
        copyMultiImageData.targetImageSize = (copyMultiImageData.maxWidth - (copyMultiImageData.columnCount + 1) * copyMultiImageData.gap)
            / (copyMultiImageData.columnCount == 1 ? 2 : copyMultiImageData.columnCount);
        final String finalImageId = imageId;
        final MultiImageData finalCopyMultiImageData = copyMultiImageData;
        ThreadUtils.execute(new Runnable() {
            @Override
            public void run() {
                final File file = new File(TUIConfig.getImageBaseDir() + finalImageId);
                boolean cacheBitmapExists = false;
                Bitmap existsBitmap = null;
                if (file.exists() && file.isFile()) {
                    BitmapFactory.Options options = new BitmapFactory.Options();
                    existsBitmap = BitmapFactory.decodeFile(file.getPath(), options);
                    if (options.outWidth > 0 && options.outHeight > 0) {
                        cacheBitmapExists = true;
                    }
                }
                if (!cacheBitmapExists) {
                    asyncLoadImageList(finalCopyMultiImageData);
                    final Bitmap bitmap = synthesizeImageList(finalCopyMultiImageData);
                    ImageUtil.storeBitmap(file, bitmap);
                    ImageUtil.setGroupConversationAvatar(finalImageId, file.getAbsolutePath());
                    ThreadUtils.postOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            callback.onCall(bitmap, finalImageId);
                        }
                    });
                } else {
                    final Bitmap finalExistsBitmap = existsBitmap;
                    ThreadUtils.postOnUiThread(new Runnable() {
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
