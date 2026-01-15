package com.tencent.qcloud.tuikit.timcommon.util;

import android.graphics.Path;
import android.graphics.RectF;
import android.graphics.Region;
import android.text.Layout;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.SpannableStringBuilder;
import android.text.Spanned;
import android.text.TextPaint;
import android.text.method.LinkMovementMethod;
import android.text.style.ClickableSpan;
import android.text.style.URLSpan;
import android.text.util.Linkify;
import android.util.Log;
import android.util.Patterns;
import android.view.GestureDetector;
import android.view.MotionEvent;
import android.view.View;
import android.widget.TextView;
import androidx.annotation.NonNull;
import com.tencent.qcloud.tuicore.TUIThemeManager;

import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class TextUtil {
    public static final Pattern PHONE_NUMBER_PATTERN = Pattern.compile("(\\+?(\\d{1,4}[-\\s]?)?)?(\\(?\\d+\\)?[-\\s]?)?[\\d\\s-]{5,14}");

    public static final Pattern MARKDOWN_LINK_PATTERN = Pattern.compile("\\[([^\\]]+)\\]\\(([^\\)]+)\\)");

    public static void linkifyUrls(TextView textView) {
        CharSequence processedText = processMarkdownLinks(textView.getText());

        textView.setText(processedText);
        Linkify.addLinks(textView, Linkify.WEB_URLS | Linkify.EMAIL_ADDRESSES);
        Linkify.addLinks(textView, PHONE_NUMBER_PATTERN, "tel:");
        SpannableString spannableString = new SpannableString(textView.getText());

        URLSpan[] urlSpans = spannableString.getSpans(0, spannableString.length(), URLSpan.class);
        int urlColor = 0xFF6495ED;
        if (TUIThemeManager.getInstance().getCurrentTheme() != TUIThemeManager.THEME_LIGHT) {
            urlColor = 0xFF87CEFA;
        }
        if (urlSpans != null) {
            for (URLSpan span : urlSpans) {
                int start = spannableString.getSpanStart(span);
                int end = spannableString.getSpanEnd(span);
                spannableString.removeSpan(span);
                spannableString.setSpan(new TextLinkSpan(span.getURL(), urlColor), start, end, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
            }
        }
        GestureDetector gestureDetector = new GestureDetector(textView.getContext(), new GestureDetector.SimpleOnGestureListener() {
            @Override
            public boolean onSingleTapUp(MotionEvent e) {
                if (!textView.isActivated()) {
                    return false;
                }
                ClickableSpan[] spans = findSpansByLocation(textView, Math.round(e.getX()), Math.round(e.getY()));
                if (spans != null && spans.length > 0) {
                    ClickableSpan span = spans[0];

                    if (span instanceof URLSpan) {
                        Log.e("TextUtil", "onSingleTapUp urlSpan " + ((URLSpan) span).getURL());
                    }

                    span.onClick(textView);
                }
                return false;
            }
        });
        textView.setText(spannableString);
        textView.setMovementMethod(new LinkMovementMethod() {
            @Override
            public boolean onTouchEvent(TextView widget, Spannable buffer, MotionEvent event) {
                gestureDetector.onTouchEvent(event);
                return false;
            }
        });
    }

    public static CharSequence processMarkdownLinks(CharSequence text) {
        if (text == null || text.length() == 0) {
            return text;
        }

        Matcher matcher = MARKDOWN_LINK_PATTERN.matcher(text);
        if (!matcher.find()) {
            return text;
        }

        SpannableStringBuilder builder = new SpannableStringBuilder();
        int lastIndex = 0;
        do {
            builder.append(text.subSequence(lastIndex, matcher.start()));

            String displayText = matcher.group(1);
            String url = matcher.group(2);
            if (url != null && !url.startsWith("http://") && !url.startsWith("https://")) {
                url = "http://" + url;
            }
            int spanStart = builder.length();
            builder.append(displayText);
            int spanEnd = builder.length();
            builder.setSpan(new URLSpan(url), spanStart, spanEnd, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);

            lastIndex = matcher.end();
        } while (matcher.find());

        builder.append(text.subSequence(lastIndex, text.length()));
        return builder;
    }

    public static ClickableSpan[] findSpansByLocation(TextView textView, int x, int y) {
        if (textView == null || !(textView.getText() instanceof Spannable)) {
            return null;
        }
        Spannable spannable = (Spannable) textView.getText();
        Layout layout = textView.getLayout();
        int offset = getPreciseOffset(textView, x, y);
        ClickableSpan[] spans = spannable.getSpans(offset, offset, ClickableSpan.class);
        List<ClickableSpan> result = new ArrayList<>();
        for (ClickableSpan span : spans) {
            int spanStart = spannable.getSpanStart(span);
            int spanEnd = spannable.getSpanEnd(span);
            Path path = new Path();
            layout.getSelectionPath(spanStart, spanEnd, path);
            RectF rect = new RectF();
            path.computeBounds(rect, true);
            Region region = new Region();
            Region pathClipRegion = new Region((int) rect.left, (int) rect.top, (int) rect.right, (int) rect.bottom);
            region.setPath(path, pathClipRegion);
            if (region.contains(x, y)) {
                result.add(span);
            }
        }
        return result.toArray(new ClickableSpan[] {});
    }

    private static int getPreciseOffset(TextView textView, int x, int y) {
        Layout layout = textView.getLayout();
        if (layout != null) {
            int topVisibleLine = layout.getLineForVertical(y);
            int offset = layout.getOffsetForHorizontal(topVisibleLine, x);

            int offsetX = (int) layout.getPrimaryHorizontal(offset);

            if (offsetX > x) {
                return layout.getOffsetToLeftOf(offset);
            } else {
                return offset;
            }
        } else {
            return -1;
        }
    }

    public static class TextLinkSpan extends URLSpan {
        private final int color;

        public TextLinkSpan(String url, int color) {
            super(url);
            this.color = color;
        }

        @Override
        public void updateDrawState(@NonNull TextPaint ds) {
            ds.setColor(color);
        }
    }

    public static class ForegroundColorClickableSpan extends ClickableSpan {
        private final int color;
        private final View.OnClickListener listener;

        public ForegroundColorClickableSpan(int color, View.OnClickListener listener) {
            super();
            this.color = color;
            this.listener = listener;
        }

        @Override
        public void updateDrawState(@NonNull TextPaint ds) {
            ds.setColor(color);
        }

        @Override
        public void onClick(@NonNull View widget) {
            if (listener != null) {
                listener.onClick(widget);
            }
        }
    }
}
