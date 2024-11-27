package com.tencent.qcloud.tuikit.timcommon.component.face;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.text.Editable;
import android.text.Spannable;
import android.text.SpannableStringBuilder;
import android.text.TextUtils;
import android.text.style.ImageSpan;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.annotation.Nullable;
import com.bumptech.glide.Glide;
import com.bumptech.glide.load.DataSource;
import com.bumptech.glide.load.engine.GlideException;
import com.bumptech.glide.request.RequestListener;
import com.bumptech.glide.request.RequestOptions;
import com.bumptech.glide.request.target.Target;
import com.tencent.qcloud.tuikit.timcommon.R;
import com.tencent.qcloud.tuikit.timcommon.TIMCommonService;
import com.tencent.qcloud.tuikit.timcommon.bean.ChatFace;
import com.tencent.qcloud.tuikit.timcommon.bean.Emoji;
import com.tencent.qcloud.tuikit.timcommon.bean.FaceGroup;
import com.tencent.qcloud.tuikit.timcommon.util.TIMCommonLog;
import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ExecutionException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class FaceManager {
    private static final String TAG = "FaceManager";

    private static final class FaceManagerHolder {
        @SuppressLint("StaticFieldLeak") private static final FaceManager instance = new FaceManager();
    }

    public static final int EMOJI_GROUP_ID = 0;
    public static final int EMOJI_COLUMN_COUNT = 8;
    public static final int EMOJI_ROW_COUNT = 3;

    private final Map<String, Emoji> emojiMap = new LinkedHashMap<>();
    private final Context context;

    private final Map<Integer, FaceGroup<?>> faceGroupMap = new ConcurrentHashMap<>();

    private FaceManager() {
        context = TIMCommonService.getAppContext();
    }

    private static FaceManager getInstance() {
        return FaceManagerHolder.instance;
    }

    public static ArrayList<Emoji> getEmojiList() {
        return new ArrayList<>(getInstance().emojiMap.values());
    }

    public static Map<String, Emoji> getEmojiMap() {
        return Collections.unmodifiableMap(getInstance().emojiMap);
    }

    public static int getEmojiCount() {
        return getInstance().emojiMap.size();
    }

    /**
     * add a new faceGroup
     * @param groupID must >= 1
     * @param faceGroup the faceGroup be added
     */
    public static synchronized <T extends ChatFace> void addFaceGroup(int groupID, FaceGroup<T> faceGroup) {
        faceGroup.setGroupID(groupID);
        getInstance().faceGroupMap.put(groupID, faceGroup);
        if (faceGroup.isEmojiGroup()) {
            List<T> faces = faceGroup.getFaces();
            for (T face : faces) {
                getInstance().emojiMap.put(face.getFaceKey(), (Emoji) face);
            }
        }
    }

    public static List<FaceGroup> getFaceGroupList() {
        return new ArrayList<>(getInstance().faceGroupMap.values());
    }

    public static Emoji loadAssetEmoji(String emojiKey, String assetFilePath, int size) {
        String realPath = "file:///android_asset/" + assetFilePath;
        Bitmap bitmap = loadBitmap(realPath, size, size);
        if (bitmap == null) {
            TIMCommonLog.e(TAG, "load bitmap failed : " + realPath);
            return null;
        }
        Emoji emoji = new Emoji();
        emoji.setIcon(bitmap);
        emoji.setFaceKey(emojiKey);
        return emoji;
    }

    private static Bitmap loadBitmap(String resUrl, int width, int height) {
        Bitmap bitmap = null;
        try {
            bitmap = Glide.with(TIMCommonService.getAppContext())
                         .asBitmap()
                         .load(resUrl)
                         .apply(new RequestOptions().error(android.R.drawable.ic_menu_report_image))
                         .submit(width, height)
                         .get();
        } catch (InterruptedException | ExecutionException e) {
            TIMCommonLog.e(TAG, "load bitmap failed : " + e.getMessage());
        }
        return bitmap;
    }

    public static void loadFace(ChatFace chatFace, ImageView imageView) {
        getInstance().internalLoadFace(chatFace, imageView, true);
    }

    public static void loadFace(int faceGroupID, String faceKey, ImageView view) {
        getInstance().internalLoadFace(faceGroupID, faceKey, view);
    }

    private void internalLoadFace(int faceGroupID, String faceKey, ImageView imageView) {
        if (imageView == null) {
            return;
        }
        if (TextUtils.isEmpty(faceKey)) {
            Glide.with(TIMCommonService.getAppContext()).load(android.R.drawable.ic_menu_report_image).centerInside().into(imageView);
            return;
        }
        String faceUrl = "";
        FaceGroup faceGroup = faceGroupMap.get(faceGroupID);
        ChatFace face = null;
        if (faceGroup != null) {
            face = faceGroup.getFace(faceKey);
            if (face != null) {
                faceUrl = face.getFaceUrl();
            }
        }
        final ChatFace finalFace = face;
        Glide.with(TIMCommonService.getAppContext())
            .load(faceUrl)
            .centerInside()
            .apply(new RequestOptions().error(android.R.drawable.ic_menu_report_image))
            .addListener(new RequestListener<Drawable>() {
                @Override
                public boolean onLoadFailed(@Nullable GlideException e, Object model, Target<Drawable> target, boolean isFirstResource) {
                    return false;
                }

                @Override
                public boolean onResourceReady(Drawable resource, Object model, Target<Drawable> target, DataSource dataSource, boolean isFirstResource) {
                    if (finalFace != null && finalFace.isAutoMirrored()) {
                        resource.setAutoMirrored(true);
                    }
                    return false;
                }
            })
            .into(imageView);
    }

    private void internalLoadFace(ChatFace chatFace, ImageView imageView, boolean isBitMap) {
        if (imageView == null || chatFace == null) {
            return;
        }
        if (chatFace instanceof Emoji) {
            Glide.with(TIMCommonService.getAppContext())
                .load(((Emoji) chatFace).getIcon())
                .centerInside()
                .apply(new RequestOptions().error(android.R.drawable.ic_menu_report_image))
                .addListener(new RequestListener<Drawable>() {
                    @Override
                    public boolean onLoadFailed(@Nullable GlideException e, Object model, Target<Drawable> target, boolean isFirstResource) {
                        return false;
                    }

                    @Override
                    public boolean onResourceReady(Drawable resource, Object model, Target<Drawable> target, DataSource dataSource, boolean isFirstResource) {
                        if (chatFace.isAutoMirrored()) {
                            resource.setAutoMirrored(true);
                        }
                        return false;
                    }
                })
                .into(imageView);
            return;
        }
        String faceUrl = "";
        FaceGroup faceGroup = chatFace.getFaceGroup();
        ChatFace face = null;
        if (faceGroup != null) {
            face = faceGroup.getFace(chatFace.getFaceKey());
            if (face != null) {
                faceUrl = face.getFaceUrl();
            }
        }
        final ChatFace finalFace = face;
        if (isBitMap) {
            Glide.with(TIMCommonService.getAppContext())
                .asBitmap()
                .load(faceUrl)
                .centerInside()
                .apply(new RequestOptions().error(android.R.drawable.ic_menu_report_image))
                .addListener(new RequestListener<Bitmap>() {
                    @Override
                    public boolean onLoadFailed(@Nullable GlideException e, Object model, Target<Bitmap> target, boolean isFirstResource) {
                        return false;
                    }

                    @Override
                    public boolean onResourceReady(Bitmap resource, Object model, Target<Bitmap> target, DataSource dataSource, boolean isFirstResource) {
                        if (finalFace.isAutoMirrored()) {
                            imageView.setImageBitmap(resource);
                            imageView.getDrawable().setAutoMirrored(true);
                            return true;
                        } else {
                            return false;
                        }
                    }
                })
                .into(imageView);
        } else {
            Glide.with(TIMCommonService.getAppContext())
                .load(faceUrl)
                .centerInside()
                .apply(new RequestOptions().error(android.R.drawable.ic_menu_report_image))
                .addListener(new RequestListener<Drawable>() {
                    @Override
                    public boolean onLoadFailed(@Nullable GlideException e, Object model, Target<Drawable> target, boolean isFirstResource) {
                        return false;
                    }

                    @Override
                    public boolean onResourceReady(Drawable resource, Object model, Target<Drawable> target, DataSource dataSource, boolean isFirstResource) {
                        if (finalFace != null && finalFace.isAutoMirrored()) {
                            resource.setAutoMirrored(true);
                        }
                        return false;
                    }
                })
                .into(imageView);
        }
    }

    public static boolean isFaceChar(String faceChar) {
        return getEmojiMap().get(faceChar) != null;
    }

    public static boolean handlerEmojiText(TextView comment, CharSequence content, boolean typing) {
        if (comment == null) {
            return false;
        }
        if (content == null) {
            comment.setText(null);
            return false;
        }

        Spannable spannable;
        if (comment instanceof EditText && content instanceof Editable) {
            spannable = (Editable) content;
            ImageSpan[] imageSpans = ((Editable) content).getSpans(0, content.length(), ImageSpan.class);
            for (ImageSpan span : imageSpans) {
                ((Editable) content).removeSpan(span);
            }
        } else {
            spannable = new SpannableStringBuilder(content);
        }
        String regex = "\\[(\\S+?)\\]";
        Pattern p = Pattern.compile(regex);
        Matcher m = p.matcher(content);
        boolean imageFound = false;
        while (m.find()) {
            String emojiName = m.group();
            Emoji emoji = getEmojiMap().get(emojiName);
            if (emoji != null) {
                Bitmap bitmap = emoji.getIcon();
                if (bitmap != null) {
                    imageFound = true;

                    BitmapDrawable bitmapDrawable = new BitmapDrawable(getInstance().context.getResources(), bitmap);
                    int size = getInstance().context.getResources().getDimensionPixelSize(R.dimen.common_default_emoji_size);
                    bitmapDrawable.setBounds(0, 0, size, size);
                    ImageSpan imageSpan = new CenterImageSpan(bitmapDrawable);
                    spannable.setSpan(imageSpan, m.start(), m.end(), Spannable.SPAN_INCLUSIVE_EXCLUSIVE);
                }
            }
        }
        
        // If no emoticon picture is found, and it is currently in the input state, the input box will not be reset.
        if (!imageFound && typing) {
            return false;
        }
        int selection = comment.getSelectionStart();
        if (!(comment instanceof EditText)) {
            comment.setText(spannable);
        }
        if (comment instanceof EditText) {
            ((EditText) comment).setSelection(selection);
        }

        return true;
    }

    public static Bitmap getEmoji(String name) {
        Emoji emoji = getEmojiMap().get(name);
        if (emoji != null) {
            return emoji.getIcon();
        }
        return null;
    }

    public static String emojiJudge(String text) {
        if (TextUtils.isEmpty(text)) {
            return "";
        }

        if (getEmojiCount() == 0) {
            return text;
        }

        SpannableStringBuilder sb = new SpannableStringBuilder(text);
        String regex = "\\[(\\S+?)\\]";
        Pattern p = Pattern.compile(regex);
        Matcher m = p.matcher(text);
        ArrayList<EmojiData> emojiDataArrayList = new ArrayList<>();
        
        // Traverse to find matching characters and store
        int lastMentionIndex = -1;
        while (m.find()) {
            String emojiKey = m.group();
            int start;
            if (lastMentionIndex != -1) {
                start = text.indexOf(emojiKey, lastMentionIndex);
            } else {
                start = text.indexOf(emojiKey);
            }
            int end = start + emojiKey.length();
            lastMentionIndex = end;

            Emoji emoji = getEmojiMap().get(emojiKey);
            if (emoji == null) {
                continue;
            }
            EmojiData emojiData = new EmojiData();
            emojiData.setStart(start);
            emojiData.setEnd(end);
            emojiData.setEmojiText(emoji.getFaceName());

            emojiDataArrayList.add(emojiData);
        }

        
        // flashback replacement
        if (emojiDataArrayList.isEmpty()) {
            return text;
        }
        for (int i = emojiDataArrayList.size() - 1; i >= 0; i--) {
            EmojiData emojiData = emojiDataArrayList.get(i);
            String emojiName = emojiData.getEmojiText();
            int start = emojiData.getStart();
            int end = emojiData.getEnd();

            if (!TextUtils.isEmpty(emojiName) && start != -1 && end != -1) {
                sb.replace(start, end, emojiName);
            }
        }
        return sb.toString();
    }

    public static List<String> splitEmojiText(String text) {
        String regex = "\\[(\\S+?)\\]";
        Pattern p = Pattern.compile(regex);
        Matcher m = p.matcher(text);
        ArrayList<EmojiData> emojiDataList = new ArrayList<>();
        int lastMentionIndex = -1;
        while (m.find()) {
            String emojiKey = m.group();
            int start;
            if (lastMentionIndex != -1) {
                start = text.indexOf(emojiKey, lastMentionIndex);
            } else {
                start = text.indexOf(emojiKey);
            }
            int end = start + emojiKey.length();
            lastMentionIndex = end;

            Emoji emoji = getEmojiMap().get(emojiKey);
            if (emoji == null) {
                continue;
            }
            EmojiData emojiData = new EmojiData();
            emojiData.setStart(start);
            emojiData.setEnd(end);
            emojiDataList.add(emojiData);
        }
        List<String> stringList = new ArrayList<>();
        int offset = 0;
        for (EmojiData emojiData : emojiDataList) {
            int start = emojiData.getStart() - offset;
            int end = emojiData.getEnd() - offset;
            String startStr = text.substring(0, start);
            String middleStr = text.substring(start, end);
            text = text.substring(end);
            if (!TextUtils.isEmpty(startStr)) {
                stringList.add(startStr);
            }
            stringList.add(middleStr);
            offset += startStr.length() + middleStr.length();
        }
        if (!TextUtils.isEmpty(text)) {
            stringList.add(text);
        }
        return stringList;
    }

    public static List<String> findEmojiKeyListFromText(String text) {
        if (TextUtils.isEmpty(text)) {
            return null;
        }
        List<String> emojiKeyList = new ArrayList<>();
        // TUIKit custom emoji.
        String regexOfCustomEmoji = "\\[(\\S+?)\\]";
        Pattern patternOfCustomEmoji = Pattern.compile(regexOfCustomEmoji);
        Matcher matcherOfCustomEmoji = patternOfCustomEmoji.matcher(text);
        while (matcherOfCustomEmoji.find()) {
            String emojiName = matcherOfCustomEmoji.group();
            Emoji emoji = getEmojiMap().get(emojiName);
            if (emoji != null) {
                Bitmap bitmap = emoji.getIcon();
                if (bitmap != null) {
                    emojiKeyList.add(emojiName);
                }
            }
        }

        // Universal standard emoji.
        String regexOfUniversalEmoji = getRegexOfUniversalEmoji();
        Pattern patternOfUniversalEmoji = Pattern.compile(regexOfUniversalEmoji);
        Matcher matcherOfUniversalEmoji = patternOfUniversalEmoji.matcher(text);
        while (matcherOfUniversalEmoji.find()) {
            String emojiKey = matcherOfUniversalEmoji.group();
            if (!TextUtils.isEmpty(emojiKey)) {
                emojiKeyList.add(matcherOfUniversalEmoji.group());
            }
        }

        return emojiKeyList;
    }

    private static class EmojiData {
        private int start;
        private int end;
        private String emojiText;

        public int getEnd() {
            return end;
        }

        public void setEnd(int end) {
            this.end = end;
        }

        public int getStart() {
            return start;
        }

        public void setStart(int start) {
            this.start = start;
        }

        public String getEmojiText() {
            return emojiText;
        }

        public void setEmojiText(String emojiText) {
            this.emojiText = emojiText;
        }
    }

    // Regex of universal emoji, refer to https://unicode.org/reports/tr51/#EBNF_and_Regex
    private static String getRegexOfUniversalEmoji() {
        String ri = "[\\U0001F1E6-\\U0001F1FF]";
        // \u0023(#), \u002A(*), \u0030(keycap 0), \u0039(keycap 9), \u00A9(©), \u00AE(®) couldn't be added to NSString directly, need to transform a little
        // bit.
        String support = "\\U000000A9|\\U000000AE|\\u203C|\\u2049|\\u2122|\\u2139|[\\u2194-\\u2199]|[\\u21A9-\\u21AA]"
            + "|[\\u231A-\\u231B]|\\u2328|\\u23CF|[\\u23E9-\\u23EF]|[\\u23F0-\\u23F3]|[\\u23F8-\\u23FA]|\\u24C2"
            + "|[\\u25AA-\\u25AB]|\\u25B6|\\u25C0|[\\u25FB-\\u25FE]|[\\u2600-\\u2604]|\\u260E|\\u2611|[\\u2614-\\u2615]"
            + "|\\u2618|\\u261D|\\u2620|[\\u2622-\\u2623]|\\u2626|\\u262A|[\\u262E-\\u262F]|[\\u2638-\\u263A]|\\u2640"
            + "|\\u2642|[\\u2648-\\u264F]|[\\u2650-\\u2653]|\\u265F|\\u2660|\\u2663|[\\u2665-\\u2666]|\\u2668|\\u267B"
            + "|[\\u267E-\\u267F]|[\\u2692-\\u2697]|\\u2699|[\\u269B-\\u269C]|[\\u26A0-\\u26A1]|\\u26A7|[\\u26AA-\\u26AB]"
            + "|[\\u26B0-\\u26B1]|[\\u26BD-\\u26BE]|[\\u26C4-\\u26C5]|\\u26C8|[\\u26CE-\\u26CF]|\\u26D1|[\\u26D3-\\u26D4]"
            + "|[\\u26E9-\\u26EA]|[\\u26F0-\\u26F5]|[\\u26F7-\\u26FA]|\\u26FD|\\u2702|\\u2705|[\\u2708-\\u270D]|\\u270F|\\u2712"
            + "|\\u2714|\\u2716|\\u271D|\\u2721|\\u2728|[\\u2733-\\u2734]|\\u2744|\\u2747|\\u274C|\\u274E|[\\u2753-\\u2755]"
            + "|\\u2757|[\\u2763-\\u2764]|[\\u2795-\\u2797]|\\u27A1|\\u27B0|\\u27BF|[\\u2934-\\u2935]|[\\u2B05-\\u2B07]"
            + "|[\\u2B1B-\\u2B1C]|\\u2B50|\\u2B55|\\u3030|\\u303D|\\u3297|\\u3299|\\U0001F004|\\U0001F0CF|[\\U0001F170-\\U0001F171]"
            + "|[\\U0001F17E-\\U0001F17F]|\\U0001F18E|[\\U0001F191-\\U0001F19A]|[\\U0001F1E6-\\U0001F1FF]|[\\U0001F201-\\U0001F202]"
            + "|\\U0001F21A|\\U0001F22F|[\\U0001F232-\\U0001F23A]|[\\U0001F250-\\U0001F251]|[\\U0001F300-\\U0001F30F]"
            + "|[\\U0001F310-\\U0001F31F]|[\\U0001F320-\\U0001F321]|[\\U0001F324-\\U0001F32F]|[\\U0001F330-\\U0001F33F]"
            + "|[\\U0001F340-\\U0001F34F]|[\\U0001F350-\\U0001F35F]|[\\U0001F360-\\U0001F36F]|[\\U0001F370-\\U0001F37F]"
            + "|[\\U0001F380-\\U0001F38F]|[\\U0001F390-\\U0001F393]|[\\U0001F396-\\U0001F397]|[\\U0001F399-\\U0001F39B]"
            + "|[\\U0001F39E-\\U0001F39F]|[\\U0001F3A0-\\U0001F3AF]|[\\U0001F3B0-\\U0001F3BF]|[\\U0001F3C0-\\U0001F3CF]"
            + "|[\\U0001F3D0-\\U0001F3DF]|[\\U0001F3E0-\\U0001F3EF]|\\U0001F3F0|[\\U0001F3F3-\\U0001F3F5]|[\\U0001F3F7-\\U0001F3FF]"
            + "|[\\U0001F400-\\U0001F40F]|[\\U0001F410-\\U0001F41F]|[\\U0001F420-\\U0001F42F]|[\\U0001F430-\\U0001F43F]"
            + "|[\\U0001F440-\\U0001F44F]|[\\U0001F450-\\U0001F45F]|[\\U0001F460-\\U0001F46F]|[\\U0001F470-\\U0001F47F]"
            + "|[\\U0001F480-\\U0001F48F]|[\\U0001F490-\\U0001F49F]|[\\U0001F4A0-\\U0001F4AF]|[\\U0001F4B0-\\U0001F4BF]"
            + "|[\\U0001F4C0-\\U0001F4CF]|[\\U0001F4D0-\\U0001F4DF]|[\\U0001F4E0-\\U0001F4EF]|[\\U0001F4F0-\\U0001F4FF]"
            + "|[\\U0001F500-\\U0001F50F]|[\\U0001F510-\\U0001F51F]|[\\U0001F520-\\U0001F52F]|[\\U0001F530-\\U0001F53D]"
            + "|[\\U0001F549-\\U0001F54E]|[\\U0001F550-\\U0001F55F]|[\\U0001F560-\\U0001F567]|\\U0001F56F|\\U0001F570"
            + "|[\\U0001F573-\\U0001F57A]|\\U0001F587|[\\U0001F58A-\\U0001F58D]|\\U0001F590|[\\U0001F595-\\U0001F596]"
            + "|[\\U0001F5A4-\\U0001F5A5]|\\U0001F5A8|[\\U0001F5B1-\\U0001F5B2]|\\U0001F5BC|[\\U0001F5C2-\\U0001F5C4]"
            + "|[\\U0001F5D1-\\U0001F5D3]|[\\U0001F5DC-\\U0001F5DE]|\\U0001F5E1|\\U0001F5E3|\\U0001F5E8|\\U0001F5EF|\\U0001F5F3"
            + "|[\\U0001F5FA-\\U0001F5FF]|[\\U0001F600-\\U0001F60F]|[\\U0001F610-\\U0001F61F]|[\\U0001F620-\\U0001F62F]"
            + "|[\\U0001F630-\\U0001F63F]|[\\U0001F640-\\U0001F64F]|[\\U0001F650-\\U0001F65F]|[\\U0001F660-\\U0001F66F]"
            + "|[\\U0001F670-\\U0001F67F]|[\\U0001F680-\\U0001F68F]|[\\U0001F690-\\U0001F69F]|[\\U0001F6A0-\\U0001F6AF]"
            + "|[\\U0001F6B0-\\U0001F6BF]|[\\U0001F6C0-\\U0001F6C5]|[\\U0001F6CB-\\U0001F6CF]|[\\U0001F6D0-\\U0001F6D2]"
            + "|[\\U0001F6D5-\\U0001F6D7]|[\\U0001F6DD-\\U0001F6DF]|[\\U0001F6E0-\\U0001F6E5]|\\U0001F6E9|[\\U0001F6EB-\\U0001F6EC]"
            + "|\\U0001F6F0|[\\U0001F6F3-\\U0001F6FC]|[\\U0001F7E0-\\U0001F7EB]|\\U0001F7F0|[\\U0001F90C-\\U0001F90F]"
            + "|[\\U0001F910-\\U0001F91F]|[\\U0001F920-\\U0001F92F]|[\\U0001F930-\\U0001F93A]|[\\U0001F93C-\\U0001F93F]"
            + "|[\\U0001F940-\\U0001F945]|[\\U0001F947-\\U0001F94C]|[\\U0001F94D-\\U0001F94F]|[\\U0001F950-\\U0001F95F]"
            + "|[\\U0001F960-\\U0001F96F]|[\\U0001F970-\\U0001F97F]|[\\U0001F980-\\U0001F98F]|[\\U0001F990-\\U0001F99F]"
            + "|[\\U0001F9A0-\\U0001F9AF]|[\\U0001F9B0-\\U0001F9BF]|[\\U0001F9C0-\\U0001F9CF]|[\\U0001F9D0-\\U0001F9DF]"
            + "|[\\U0001F9E0-\\U0001F9EF]|[\\U0001F9F0-\\U0001F9FF]|[\\U0001FA70-\\U0001FA74]|[\\U0001FA78-\\U0001FA7C]"
            + "|[\\U0001FA80-\\U0001FA86]|[\\U0001FA90-\\U0001FA9F]|[\\U0001FAA0-\\U0001FAAC]|[\\U0001FAB0-\\U0001FABA]"
            + "|[\\U0001FAC0-\\U0001FAC5]|[\\U0001FAD0-\\U0001FAD9]|[\\U0001FAE0-\\U0001FAE7]|[\\U0001FAF0-\\U0001FAF6]";
        String unsupport = "\\u0023|\\u002A|[\\u0030-\\u0039]|";
        String emoji = unsupport + support;

        // Construct regex of emoji by the rules above.
        String eMod = "[\\U0001F3FB-\\U0001F3FF]";

        String variationSelector = "\\uFE0F";
        String keycap = "\\u20E3";
        String tags = "[\\U000E0020-\\U000E007E]";
        String termTag = "\\U000E007F";
        String zwj = "\\u200D";

        String risequence = "[" + ri + "]"
            + "[" + ri + "]";
        String element = "[" + emoji + "]"
            + "("
            + "[" + eMod + "]|" + variationSelector + keycap + "?|[" + tags + "]+" + termTag + "?)?";
        String regexEmoji = risequence + "|" + element + "(" + zwj + "(" + risequence + "|" + element + "))*";

        return regexEmoji;
    }
}
