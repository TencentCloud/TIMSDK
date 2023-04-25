package com.tencent.qcloud.tuikit.tuicallkit.view.common.gridimage;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Rect;
import android.text.TextUtils;
import android.widget.ImageView;

import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuikit.tuicallkit.R;
import com.tencent.qcloud.tuikit.tuicallkit.utils.ImageLoader;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ExecutionException;

public class GridImageSynthesizer {
    private GridImageData mGridImageData;
    private Context       mContext;
    private ImageView     mImageView;
    private String        mCurrentImageId = "";

    public GridImageSynthesizer(Context mContext, ImageView imageView) {
        this.mContext = mContext;
        this.mImageView = imageView;
        init();
    }

    private void init() {
        mGridImageData = new GridImageData();
    }

    public void setImageUrls(List<Object> list) {
        mGridImageData.setImageUrlList(list);
    }

    public void setMaxSize(int maxWidth, int maxHeight) {
        mGridImageData.maxWidth = maxWidth;
        mGridImageData.maxHeight = maxHeight;
    }

    public int getDefaultImage() {
        return mGridImageData.getDefaultImageResId();
    }

    public void setDefaultImage(int defaultImageResId) {
        mGridImageData.setDefaultImageResId(defaultImageResId);
    }

    public void setBgColor(int bgColor) {
        mGridImageData.bgColor = bgColor;
    }

    public void setGap(int gap) {
        mGridImageData.gap = gap;
    }

    public void setImageId(String id) {
        mCurrentImageId = id;
    }

    public String getImageId() {
        return mCurrentImageId;
    }

    private int[] calculateGridParam(int imagesSize) {
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

    private boolean asyncLoadImageList(GridImageData imageData) {
        boolean loadSuccess = true;
        List<Object> imageUrlList = imageData.getImageUrlList();
        for (int i = 0; i < imageUrlList.size(); i++) {
            Bitmap defaultIcon = BitmapFactory.decodeResource(mContext.getResources(), R.drawable.tuicalling_ic_avatar);
            try {
                Bitmap bitmap = asyncLoadImage(imageUrlList.get(i), imageData.targetImageSize);
                imageData.putBitmap(bitmap, i);
            } catch (InterruptedException | ExecutionException e) {
                e.printStackTrace();
                imageData.putBitmap(defaultIcon, i);
            }
        }
        return loadSuccess;
    }

    private Bitmap synthesizeImageList(GridImageData imageData) {
        Bitmap mergeBitmap = Bitmap.createBitmap(imageData.maxWidth, imageData.maxHeight, Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(mergeBitmap);
        drawDrawable(canvas, imageData);
        canvas.save();
        canvas.restore();
        return mergeBitmap;
    }

    private void drawDrawable(Canvas canvas, GridImageData imageData) {
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

            int left = ((int) (imageData.targetImageSize * (imageData.columnCount == 1 ? columnNum + 0.5 : columnNum)
                    + imageData.gap * (columnNum + 1)));
            int top = ((int) (imageData.targetImageSize * (imageData.columnCount == 1 ? rowNum + 0.5 : rowNum)
                    + imageData.gap * (rowNum + 1)));
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
                            imageData.gap * i + imageData.targetImageSize * i, tCenter + imageData.targetImageSize,
                            bitmap);
                }
            } else if (size == 4) {
                drawBitmapAtPosition(canvas, left, top, right, bottom, bitmap);
            } else if (size == 5) {
                if (i == 0) {
                    drawBitmapAtPosition(canvas, rCenter - imageData.targetImageSize,
                            rCenter - imageData.targetImageSize, rCenter, rCenter, bitmap);
                } else if (i == 1) {
                    drawBitmapAtPosition(canvas, lCenter, rCenter - imageData.targetImageSize,
                            lCenter + imageData.targetImageSize, rCenter, bitmap);
                } else {
                    drawBitmapAtPosition(canvas, imageData.gap * (i - 1) + imageData.targetImageSize * (i - 2),
                            tCenter, imageData.gap * (i - 1) + imageData.targetImageSize * (i - 1), tCenter
                                    + imageData.targetImageSize, bitmap);
                }
            } else if (size == 6) {
                if (i < 3) {
                    drawBitmapAtPosition(canvas, imageData.gap * (i + 1) + imageData.targetImageSize * i,
                            bCenter - imageData.targetImageSize,
                            imageData.gap * (i + 1) + imageData.targetImageSize * (i + 1), bCenter, bitmap);
                } else {
                    drawBitmapAtPosition(canvas, imageData.gap * (i - 2) + imageData.targetImageSize * (i - 3),
                            tCenter, imageData.gap * (i - 2) + imageData.targetImageSize * (i - 2), tCenter
                                    + imageData.targetImageSize, bitmap);
                }
            } else if (size == 7) {
                if (i == 0) {
                    drawBitmapAtPosition(canvas, center, imageData.gap, center + imageData.targetImageSize,
                            imageData.gap + imageData.targetImageSize, bitmap);
                } else if (i > 0 && i < 4) {
                    drawBitmapAtPosition(canvas, imageData.gap * i + imageData.targetImageSize * (i - 1), center,
                            imageData.gap * i + imageData.targetImageSize * i, center + imageData.targetImageSize,
                            bitmap);
                } else {
                    drawBitmapAtPosition(canvas, imageData.gap * (i - 3) + imageData.targetImageSize * (i - 4),
                            tCenter + imageData.targetImageSize / 2,
                            imageData.gap * (i - 3) + imageData.targetImageSize * (i - 3),
                            tCenter + imageData.targetImageSize / 2 + imageData.targetImageSize, bitmap);
                }
            } else if (size == 8) {
                if (i == 0) {
                    drawBitmapAtPosition(canvas, rCenter - imageData.targetImageSize, imageData.gap, rCenter,
                            imageData.gap + imageData.targetImageSize, bitmap);
                } else if (i == 1) {
                    drawBitmapAtPosition(canvas, lCenter, imageData.gap, lCenter + imageData.targetImageSize,
                            imageData.gap + imageData.targetImageSize, bitmap);
                } else if (i > 1 && i < 5) {
                    drawBitmapAtPosition(canvas, imageData.gap * (i - 1) + imageData.targetImageSize * (i - 2),
                            center, imageData.gap * (i - 1) + imageData.targetImageSize * (i - 1),
                            center + imageData.targetImageSize, bitmap);
                } else {
                    drawBitmapAtPosition(canvas, imageData.gap * (i - 4) + imageData.targetImageSize * (i - 5),
                            tCenter + imageData.targetImageSize / 2,
                            imageData.gap * (i - 4) + imageData.targetImageSize * (i - 4),
                            tCenter + imageData.targetImageSize / 2 + imageData.targetImageSize, bitmap);
                }
            } else if (size == 9) {
                drawBitmapAtPosition(canvas, left, top, right, bottom, bitmap);
            }
        }
    }

    private void drawBitmapAtPosition(Canvas canvas, int left, int top, int right, int bottom, Bitmap bitmap) {
        if (null == bitmap) {
            if (mGridImageData.getDefaultImageResId() > 0) {
                bitmap = BitmapFactory.decodeResource(mContext.getResources(), mGridImageData.getDefaultImageResId());
            }
        }
        if (null != bitmap) {
            Rect rect = new Rect(left, top, right, bottom);
            canvas.drawBitmap(bitmap, null, rect, null);
        }
    }

    private Bitmap asyncLoadImage(Object imgUrl, int targetImageSize) throws ExecutionException, InterruptedException {
        return ImageLoader.loadBitmap(mContext, imgUrl, targetImageSize);
    }

    public void load(String imageId) {
        if (mGridImageData.size() == 0) {
            if (imageId != null && !TextUtils.equals(imageId, mCurrentImageId)) {
                return;
            }
            ImageLoader.loadImage(mContext, mImageView, getDefaultImage());
            return;
        }

        if (mGridImageData.size() == 1) {
            if (imageId != null && !TextUtils.equals(imageId, mCurrentImageId)) {
                return;
            }
            ImageLoader.loadImage(mContext, mImageView, mGridImageData.getImageUrlList().get(0));
            return;
        }

        clearImage();

        GridImageData copyGridImageData;
        try {
            copyGridImageData = mGridImageData.clone();
        } catch (CloneNotSupportedException e) {
            e.printStackTrace();
            List<Object> urlList = new ArrayList();
            if (mGridImageData.imageUrlList != null) {
                urlList.addAll(mGridImageData.imageUrlList);
            }
            copyGridImageData = new GridImageData(urlList, mGridImageData.defaultImageResId);
        }
        int[] gridParam = calculateGridParam(mGridImageData.size());
        copyGridImageData.rowCount = gridParam[0];
        copyGridImageData.columnCount = gridParam[1];
        copyGridImageData.targetImageSize = (copyGridImageData.maxWidth - (copyGridImageData.columnCount + 1)
                * copyGridImageData.gap) / (copyGridImageData.columnCount == 1 ? 2 : copyGridImageData.columnCount);

        final String finalImageId = imageId;
        final GridImageData finalCopyGridImageData = copyGridImageData;
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
                    asyncLoadImageList(finalCopyGridImageData);
                    existsBitmap = synthesizeImageList(finalCopyGridImageData);
                    storeBitmap(file, existsBitmap);
                }
                loadImage(existsBitmap, finalImageId);
            }
        });
    }

    private void loadImage(Bitmap bitmap, String targetId) {
        ThreadUtils.runOnUIThread(() -> {
            if (TextUtils.equals(getImageId(), targetId)) {
                ImageLoader.loadImage(mContext, mImageView, bitmap);
            }
        });
    }

    public void clearImage() {
        ImageLoader.clear(mContext, mImageView);
    }

    private void storeBitmap(File outFile, Bitmap bitmap) {
        if (!outFile.exists() || outFile.isDirectory()) {
            outFile.getParentFile().mkdirs();
        }
        FileOutputStream fOut = null;
        try {
            outFile.deleteOnExit();
            outFile.createNewFile();
            fOut = new FileOutputStream(outFile);
            bitmap.compress(Bitmap.CompressFormat.JPEG, 100, fOut);
            fOut.flush();
        } catch (IOException e) {
            outFile.deleteOnExit();
        } finally {
            if (null != fOut) {
                try {
                    fOut.close();
                } catch (IOException e) {
                    e.printStackTrace();
                    outFile.deleteOnExit();
                }
            }
        }
    }
}
