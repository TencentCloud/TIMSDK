package com.tencent.qcloud.tuikit.tuichat.component.face;

import android.content.Context;
import android.graphics.Rect;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.util.AttributeSet;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.PopupWindow;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.RecyclerView;
import androidx.viewpager2.widget.ViewPager2;
import com.bumptech.glide.Glide;
import com.google.android.material.tabs.TabLayout;
import com.google.android.material.tabs.TabLayoutMediator;
import com.tencent.qcloud.tuikit.timcommon.bean.ChatFace;
import com.tencent.qcloud.tuikit.timcommon.bean.Emoji;
import com.tencent.qcloud.tuikit.timcommon.bean.FaceGroup;
import com.tencent.qcloud.tuikit.timcommon.component.face.FaceManager;
import com.tencent.qcloud.tuikit.timcommon.component.face.RecentEmojiManager;
import com.tencent.qcloud.tuikit.timcommon.interfaces.OnFaceInputListener;
import com.tencent.qcloud.tuikit.timcommon.util.LayoutUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import java.util.Iterator;
import java.util.List;

/**
 * In respect for the copyright of the emoji design, the Chat Demo/TUIKit project does not include the cutouts of large emoji elements. Please replace them
 * with your own designed or copyrighted emoji packs before the official launch for commercial use. The default small yellow face emoji pack is copyrighted by
 * Tencent Cloud and can be authorized for a fee. If you wish to obtain authorization, please submit a ticket to contact us.
 *
 * submit a ticket url：https://console.cloud.tencent.com/workorder/category?level1_id=29&level2_id=40&source=14&data_title=%E5%8D%B3%E6%97%B6%E9%80%9A%E4%BF%A1%20IM&step=1 (China mainland)
 * submit a ticket url：https://console.tencentcloud.com/workorder/category?level1_id=29&level2_id=40&source=14&data_title=Chat&step=1 (Other regions)
 */
public class FaceView extends FrameLayout {
    private static final String TAG = "FaceView";

    private TabLayout emojiTabs;
    private TabLayoutMediator emojiTabLayoutMediator;
    private ViewPager2 emojiPages;
    private FacePagerAdapter emojiPagesAdapter;
    private OnFaceInputListener onFaceInputListener;
    private boolean showCustomFace = true;

    public FaceView(@NonNull Context context) {
        super(context);
        init(context);
    }

    public FaceView(@NonNull Context context, boolean showCustomFace) {
        super(context);
        this.showCustomFace = showCustomFace;
        init(context);
    }

    private void init(Context context) {
        View view = LayoutInflater.from(context).inflate(R.layout.chat_face_view_layout, this);
        emojiTabs = view.findViewById(R.id.emoji_group_tabs);
        emojiPages = view.findViewById(R.id.emoji_group_pages);
        List<FaceGroup> faceGroupList = FaceManager.getFaceGroupList();

        filterCustomFace(faceGroupList);

        emojiPagesAdapter = new FacePagerAdapter();
        emojiPagesAdapter.setFaceGroupList(faceGroupList);
        emojiPagesAdapter.setOnEmojiClickListener(new OnItemClickListener() {
            @Override
            public void onFaceClicked(ChatFace face) {
                TUIChatLog.d(TAG, "Face " + face.getFaceKey() + " is clicked.");
                if (onFaceInputListener == null) {
                    return;
                }
                if (face instanceof Emoji) {
                    onFaceInputListener.onEmojiClicked(face.getFaceKey());
                    RecentEmojiManager.updateRecentUseEmoji(face.getFaceKey());
                } else {
                    onFaceInputListener.onFaceClicked(face);
                }
            }

            @Override
            public void onFaceLongClick(ChatFace face) {
                showFaceDetail(face);
            }

            @Override
            public void onDeleteClicked() {
                if (onFaceInputListener != null) {
                    onFaceInputListener.onDeleteClicked();
                }
            }

            @Override
            public void onSendClicked() {
                if (onFaceInputListener != null) {
                    onFaceInputListener.onSendClicked();
                }
            }
        });
        emojiPages.setAdapter(emojiPagesAdapter);

        emojiTabLayoutMediator = new TabLayoutMediator(emojiTabs, emojiPages, new TabLayoutMediator.TabConfigurationStrategy() {
            @Override
            public void onConfigureTab(@NonNull TabLayout.Tab tab, int position) {
                View tabView = LayoutInflater.from(context).inflate(R.layout.chat_face_tab_item_layout, null);
                ImageView tabIcon = tabView.findViewById(R.id.tab_item_icon);
                FaceGroup faceGroup = faceGroupList.get(position);
                Glide.with(tabView).asBitmap().load(faceGroup.getFaceGroupIconUrl()).into(tabIcon);
                tab.setCustomView(tabView);
            }
        });
        emojiTabLayoutMediator.attach();
    }

    private void filterCustomFace(List<FaceGroup> faceGroupList) {
        if (!showCustomFace) {
            Iterator<FaceGroup> iterator = faceGroupList.listIterator();
            while (iterator.hasNext()) {
                FaceGroup faceGroup = iterator.next();
                if (!faceGroup.isEmojiGroup()) {
                    iterator.remove();
                }
            }
        }
    }

    public void setOnFaceInputListener(OnFaceInputListener onFaceInputListener) {
        this.onFaceInputListener = onFaceInputListener;
    }

    private void showFaceDetail(ChatFace chatFace) {
        View contentView = LayoutInflater.from(getContext()).inflate(R.layout.chat_face_detail_layout, null);
        ImageView imageView = contentView.findViewById(R.id.image_view);
        int size = contentView.getResources().getDimensionPixelSize(R.dimen.chat_face_detail_layout_size);
        if (chatFace instanceof Emoji) {
            imageView.setImageBitmap(((Emoji) chatFace).getIcon());
            size /= 1.5f;
        } else {
            Glide.with(imageView).load(chatFace.getFaceUrl()).into(imageView);
        }
        PopupWindow popupWindow = new PopupWindow(contentView, size, size, true);
        popupWindow.setBackgroundDrawable(new ColorDrawable());
        popupWindow.setTouchable(true);
        popupWindow.setOutsideTouchable(false);
        int yoff = getResources().getDimensionPixelSize(R.dimen.chat_input_emoji_top_space) + emojiTabs.getHeight();
        int xoff = (this.getWidth() - size) / 2;
        popupWindow.showAsDropDown(this, xoff, yoff, Gravity.TOP);
    }

    /**
     * Add spacing and dividers
     */
    static class GridDecoration extends RecyclerView.ItemDecoration {
        private final int columnNum;
        private final int leftRightSpace;
        private final int topBottomSpace;

        public GridDecoration(int columnNum, int leftRightSpace, int topBottomSpace) {
            this.columnNum = columnNum;
            this.leftRightSpace = leftRightSpace;
            this.topBottomSpace = topBottomSpace;
        }

        @Override
        public void getItemOffsets(Rect outRect, View view, RecyclerView parent, RecyclerView.State state) {
            int position = parent.getChildAdapterPosition(view);
            int column = position % columnNum;

            int right = leftRightSpace * (columnNum - 1 - column) / columnNum;
            int left = column * leftRightSpace / columnNum;
            if (LayoutUtil.isRTL()) {
                outRect.right = left;
                outRect.left = right;
            } else {
                outRect.left = left;
                outRect.right = right;
            }

            // Add top spacing when multiple lines
            if (position >= columnNum) {
                outRect.top = topBottomSpace;
            }
        }
    }

    public void setTabIndicator(Drawable drawable) {
        emojiTabs.setSelectedTabIndicator(drawable);
    }

    public void setTabIndicatorColor(int color) {
        emojiTabs.setSelectedTabIndicatorColor(color);
    }

    @Override
    protected void onVisibilityChanged(@NonNull View changedView, int visibility) {
        super.onVisibilityChanged(changedView, visibility);
        emojiPagesAdapter.notifyDataSetChanged();
    }

    public interface OnItemClickListener {
        void onFaceClicked(ChatFace face);

        void onFaceLongClick(ChatFace face);

        default void onDeleteClicked() {}

        default void onSendClicked() {}
    }
}
