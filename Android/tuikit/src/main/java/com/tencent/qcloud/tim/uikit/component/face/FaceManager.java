package com.tencent.qcloud.tim.uikit.component.face;

import android.content.Context;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Rect;
import android.text.Spannable;
import android.text.SpannableStringBuilder;
import android.text.style.ImageSpan;
import android.util.DisplayMetrics;
import android.util.LruCache;
import android.widget.EditText;
import android.widget.TextView;

import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.TUIKit;
import com.tencent.qcloud.tim.uikit.config.CustomFaceConfig;
import com.tencent.qcloud.tim.uikit.utils.ScreenUtil;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;


public class FaceManager {

    private static ArrayList<Emoji> emojiList = new ArrayList<>();
    private static LruCache<String, Bitmap> drawableCache = new LruCache(1024);
    private static Context context = TUIKit.getAppContext();
    private static String[] emojiFilters = context.getResources().getStringArray(R.array.emoji_filter);
    private static final int drawableWidth = ScreenUtil.getPxByDp(32);
    private static ArrayList<FaceGroup> customFace = new ArrayList<>();

    public static ArrayList<Emoji> getEmojiList() {
        return emojiList;
    }

    public static ArrayList<FaceGroup> getCustomFaceList() {
        return customFace;
    }


    public static Bitmap getCustomBitmap(int groupId, String name) {
        for (int i = 0; i < customFace.size(); i++) {
            FaceGroup group = customFace.get(i);
            if (group.getGroupId() == groupId) {
                ArrayList<Emoji> faces = group.getFaces();
                for (int j = 0; j < faces.size(); j++) {
                    Emoji face = faces.get(j);
                    if (face.getFilter().equals(name)) {
                        return face.getIcon();
                    }
                }

            }
        }
        return null;
    }

    public static void loadFaceFiles() {
        new Thread() {
            @Override
            public void run() {
                for (int i = 0; i < emojiFilters.length; i++) {
                    loadAssetBitmap(emojiFilters[i], "emoji/" + emojiFilters[i] + "@2x.png", true);
                }
                CustomFaceConfig config = TUIKit.getConfigs().getCustomFaceConfig();
                if (config == null) {
                    return;
                }
                List<CustomFaceGroup> groups = config.getFaceGroups();
                if (groups == null) {
                    return;
                }
                for (int i = 0; i < groups.size(); i++) {
                    CustomFaceGroup groupConfigs = groups.get(i);
                    FaceGroup groupInfo = new FaceGroup();
                    groupInfo.setGroupId(groupConfigs.getFaceGroupId());
                    groupInfo.setDesc(groupConfigs.getFaceIconName());
                    groupInfo.setPageColumnCount(groupConfigs.getPageColumnCount());
                    groupInfo.setPageRowCount(groupConfigs.getPageRowCount());
                    groupInfo.setGroupIcon(loadAssetBitmap(groupConfigs.getFaceIconName(), groupConfigs.getFaceIconPath(), false).getIcon());

                    ArrayList<CustomFace> customFaceArray = groupConfigs.getCustomFaceList();
                    ArrayList<Emoji> faceList = new ArrayList<>();
                    for (int j = 0; j < customFaceArray.size(); j++) {
                        CustomFace face = customFaceArray.get(j);
                        Emoji emoji = loadAssetBitmap(face.getFaceName(), face.getAssetPath(), false);
                        emoji.setWidth(face.getFaceWidth());
                        emoji.setHeight(face.getFaceHeight());
                        faceList.add(emoji);

                    }
                    groupInfo.setFaces(faceList);
                    customFace.add(groupInfo);
                }
            }
        }.start();


    }


    private static Emoji loadAssetBitmap(String filter, String assetPath, boolean isEmoji) {
        InputStream is = null;
        try {
            Emoji emoji = new Emoji();
            Resources resources = context.getResources();
            BitmapFactory.Options options = new BitmapFactory.Options();
            options.inDensity = DisplayMetrics.DENSITY_XXHIGH;
            options.inScreenDensity = resources.getDisplayMetrics().densityDpi;
            options.inTargetDensity = resources.getDisplayMetrics().densityDpi;
            context.getAssets().list("");
            is = context.getAssets().open(assetPath);
            Bitmap bitmap = BitmapFactory.decodeStream(is, new Rect(0, 0, drawableWidth, drawableWidth), options);
            if (bitmap != null) {
                drawableCache.put(filter, bitmap);

                emoji.setIcon(bitmap);
                emoji.setFilter(filter);
                if (isEmoji) {
                    emojiList.add(emoji);
                }

            }
            return emoji;
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (is != null) {
                try {
                    is.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
        return null;
    }


    public static int calculateInSampleSize(BitmapFactory.Options options,
                                            int reqWidth, int reqHeight) {
        // 源图片的高度和宽度
        final int height = options.outHeight;
        final int width = options.outWidth;
        int inSampleSize = 1;
        if (height > reqHeight || width > reqWidth) {
            // 计算出实际宽高和目标宽高的比率
            final int heightRatio = Math.round((float) height / (float) reqHeight);
            final int widthRatio = Math.round((float) width / (float) reqWidth);
            // 选择宽和高中最小的比率作为inSampleSize的值，这样可以保证最终图片的宽和高
            // 一定都会大于等于目标的宽和高。
            inSampleSize = heightRatio < widthRatio ? heightRatio : widthRatio;
        }
        return inSampleSize;
    }

    public static Bitmap decodeSampledBitmapFromResource(Resources res, int resId,
                                                         int reqWidth, int reqHeight) {
        // 第一次解析将inJustDecodeBounds设置为true，来获取图片大小
        final BitmapFactory.Options options = new BitmapFactory.Options();
        options.inJustDecodeBounds = true;
        BitmapFactory.decodeResource(res, resId, options);
        // 调用上面定义的方法计算inSampleSize值
        options.inSampleSize = calculateInSampleSize(options, reqWidth, reqHeight);
        // 使用获取到的inSampleSize值再次解析图片
        options.inJustDecodeBounds = false;
        return BitmapFactory.decodeResource(res, resId, options);
    }


    public static int dip2px(Context context, float dipValue) {
        final float scale = context.getResources().getDisplayMetrics().density;
        return (int) (dipValue * scale + 0.5f);
    }

    public static boolean isFaceChar(String faceChar) {
        return drawableCache.get(faceChar) != null;
    }


    public static void handlerEmojiText(TextView comment, String content) {
        SpannableStringBuilder sb = new SpannableStringBuilder(content);
        String regex = "\\[(\\S+?)\\]";
        Pattern p = Pattern.compile(regex);
        Matcher m = p.matcher(content);
        while (m.find()) {
            String emojiName = m.group();
            Bitmap bitmap = drawableCache.get(emojiName);
            if (bitmap != null) {
                sb.setSpan(new ImageSpan(context, bitmap),
                        m.start(), m.end(), Spannable.SPAN_INCLUSIVE_EXCLUSIVE);
            }
        }
        int selection = comment.getSelectionStart();
        comment.setText(sb);
        if (comment instanceof EditText) {
            ((EditText) comment).setSelection(selection);
        }
    }

    public static Bitmap getEmoji(String name) {
        return drawableCache.get(name);
    }
}
