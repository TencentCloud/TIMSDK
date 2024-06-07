package com.tencent.qcloud.tuikit.tuichat.component.pinned;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.animation.ValueAnimator;
import android.app.Activity;
import android.app.Dialog;
import android.content.Context;
import android.graphics.Rect;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.ShapeDrawable;
import android.os.Bundle;
import android.util.AttributeSet;
import android.util.DisplayMetrics;
import android.view.Display;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewParent;
import android.view.Window;
import android.view.WindowManager;
import android.widget.FrameLayout;
import android.widget.PopupWindow;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.fragment.app.DialogFragment;
import androidx.fragment.app.FragmentManager;
import androidx.recyclerview.widget.DividerItemDecoration;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.google.android.material.bottomsheet.BottomSheetDialog;
import com.tencent.qcloud.tuicore.interfaces.TUICallback;
import com.tencent.qcloud.tuicore.interfaces.TUIValueCallback;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.component.face.FaceManager;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.interfaces.IGroupPinnedView;
import com.tencent.qcloud.tuikit.tuichat.presenter.GroupChatPresenter;
import java.util.List;

public class GroupPinnedView extends FrameLayout implements IGroupPinnedView {
    private static final String TAG = "GroupPinnedView";

    private TextView messageSenderName;
    private TextView messageAbstractTv;
    private View clearButton;
    private View moreItems;
    private PinnedMessageListPopWindow popWindow;
    private List<TUIMessageBean> messageBeanList;
    private GroupChatPresenter groupChatPresenter;

    public GroupPinnedView(@NonNull Context context) {
        super(context);
        init(context);
    }

    public GroupPinnedView(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }

    public GroupPinnedView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }

    public GroupPinnedView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
        init(context);
    }

    private void init(Context context) {
        View view = LayoutInflater.from(context).inflate(R.layout.chat_group_pinned_view_layout, this);
        messageSenderName = view.findViewById(R.id.message_sender_name);
        messageAbstractTv = view.findViewById(R.id.message_abstract);
        clearButton = view.findViewById(R.id.clear_button);
        moreItems = view.findViewById(R.id.more_items_button);
    }

    public void setGroupChatPresenter(GroupChatPresenter groupChatPresenter) {
        this.groupChatPresenter = groupChatPresenter;
    }

    @Override
    public void onPinnedListChanged(List<TUIMessageBean> pinnedMessages) {
        messageBeanList = pinnedMessages;
        this.setOnClickListener(null);
        if (!messageBeanList.isEmpty()) {
            TUIMessageBean firstMessage = messageBeanList.get(0);
            this.setVisibility(VISIBLE);
            String messageAbstract = firstMessage.onGetDisplayString();
            String senderName = firstMessage.getUserDisplayName();
            FaceManager.handlerEmojiText(messageAbstractTv, messageAbstract, false);
            messageSenderName.setText(senderName);
            if (messageBeanList.size() > 1) {
                moreItems.setVisibility(VISIBLE);
                clearButton.setVisibility(GONE);
                this.setOnClickListener(new OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        showPinnedMessageList();
                    }
                });
            } else {
                moreItems.setVisibility(GONE);
                if (groupChatPresenter.canPinnedMessage()) {
                    clearButton.setVisibility(VISIBLE);
                } else {
                    clearButton.setVisibility(GONE);
                }
                this.setOnClickListener(new OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        groupChatPresenter.locateMessage(firstMessage.getId(), new IUIKitCallback<Void>() {
                            @Override
                            public void onSuccess(Void data) {
                                // do nothing
                            }

                            @Override
                            public void onError(String module, int errCode, String errMsg) {
                                ToastUtil.toastShortMessage(getContext().getString(R.string.locate_origin_msg_failed_tip));
                            }
                        });
                    }
                });
                clearButton.setOnClickListener(new OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        groupChatPresenter.unpinnedMessage(firstMessage, new TUICallback() {
                            @Override
                            public void onSuccess() {
                                //do nothing
                            }

                            @Override
                            public void onError(int errorCode, String errorMessage) {
                                ToastUtil.toastShortMessage(errorMessage);
                            }
                        });
                    }
                });
            }
        } else {
            this.setVisibility(GONE);
            if (popWindow != null && popWindow.isShowing()) {
                popWindow.dismiss();
            }
        }
        if (popWindow != null && popWindow.isShowing()) {
            popWindow.setMessageBeanList(messageBeanList);
            popWindow.refresh(this);
        }
    }

    private void showPinnedMessageList() {
        popWindow = new PinnedMessageListPopWindow(getContext());
        popWindow.setGroupChatPresenter(groupChatPresenter);
        popWindow.setMessageBeanList(messageBeanList);
        popWindow.show(this);
    }

    public static class PinnedMessageListPopWindow {
        private PopupWindow popupWindow;
        private View contentView;
        private List<TUIMessageBean> messageBeanList;
        private RecyclerView pinnedListView;
        private View dialogContainer;
        private PinnedMessageListAdapter pinnedMessageListAdapter;

        private GroupChatPresenter groupChatPresenter;

        private int dialogHeight = 0;
        private int anchorHeight = 0;
        private boolean inDismissing = false;

        public void setGroupChatPresenter(GroupChatPresenter groupChatPresenter) {
            this.groupChatPresenter = groupChatPresenter;
        }

        public void setMessageBeanList(List<TUIMessageBean> messageBeanList) {
            this.messageBeanList = messageBeanList;
            if (pinnedMessageListAdapter != null) {
                pinnedMessageListAdapter.notifyDataSetChanged();
            }
        }

        public boolean isShowing() {
            return popupWindow.isShowing();
        }

        public PinnedMessageListPopWindow(Context context) {
            contentView = LayoutInflater.from(context).inflate(R.layout.chat_group_pinned_view_dialog_layout, null);
            dialogContainer = contentView.findViewById(R.id.dialog_content);
            popupWindow = new PopupWindow(contentView, WindowManager.LayoutParams.MATCH_PARENT, WindowManager.LayoutParams.WRAP_CONTENT, false);
            popupWindow.setTouchable(true);
            popupWindow.setOutsideTouchable(true);
            contentView.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    dismiss();
                }
            });
            pinnedListView = contentView.findViewById(R.id.pinned_list);
            pinnedMessageListAdapter = new PinnedMessageListAdapter();
            DividerItemDecoration decoration = new DividerItemDecoration(pinnedListView.getContext(), DividerItemDecoration.VERTICAL);
            decoration.setDrawable(contentView.getResources().getDrawable(R.drawable.chat_pinned_list_divider));
            pinnedListView.addItemDecoration(decoration);
            pinnedListView.setAdapter(pinnedMessageListAdapter);
            LinearLayoutManager linearLayoutManager = new LinearLayoutManager(context);
            pinnedListView.setLayoutManager(linearLayoutManager);
        }

        public void show(View anchor) {
            setDialogContentHeight(anchor);
            anchorHeight = anchor.getHeight();
            changeHeightWithAnim(anchorHeight, dialogHeight, null);

            Rect rect = new Rect();
            anchor.getGlobalVisibleRect(rect);
            int height = getChatViewHeight(anchor.getParent()) - anchor.getTop();
            popupWindow.setHeight(height);
            popupWindow.setBackgroundDrawable(new ColorDrawable());
            popupWindow.showAtLocation(anchor, 0, rect.left, rect.top);
        }

        private void changeHeightWithAnim(int anchorHeight, int dialogHeight, Runnable onFinished) {
            ValueAnimator animator = ValueAnimator.ofInt(anchorHeight, dialogHeight);
            animator.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
                @Override
                public void onAnimationUpdate(ValueAnimator animation) {
                    ViewGroup.LayoutParams layoutParams = dialogContainer.getLayoutParams();
                    layoutParams.height = (int) animation.getAnimatedValue();
                    dialogContainer.setLayoutParams(layoutParams);
                }
            });
            animator.addListener(new AnimatorListenerAdapter() {
                @Override
                public void onAnimationCancel(Animator animation) {
                    if (onFinished != null) {
                        onFinished.run();
                    }
                }

                @Override
                public void onAnimationEnd(Animator animation) {
                    if (onFinished != null) {
                        onFinished.run();
                    }
                }
            });
            animator.start();
        }

        private void setDialogContentHeight(View anchor) {
            int maxHeight = anchor.getContext().getResources().getDimensionPixelSize(R.dimen.chat_pinned_list_max_height);
            if (pinnedMessageListAdapter.getItemCount() == 0) {
                dialogHeight = anchor.getHeight();
            } else {
                dialogContainer.measure(MeasureSpec.UNSPECIFIED, MeasureSpec.UNSPECIFIED);
                dialogHeight = dialogContainer.getMeasuredHeight();
            }
            if (dialogHeight > maxHeight) {
                ViewGroup.LayoutParams lp = dialogContainer.getLayoutParams();
                lp.height = maxHeight;
                dialogContainer.setLayoutParams(lp);
                dialogHeight = maxHeight;
            }
        }

        private void refresh(View anchor) {
            int currentHeight = dialogHeight;
            setDialogContentHeight(anchor);
            int nextHeight = dialogHeight;
            changeHeightWithAnim(currentHeight, nextHeight, null);
        }

        private void dismiss() {
            if (popupWindow == null || !popupWindow.isShowing() || inDismissing) {
                return;
            }
            inDismissing = true;
            changeHeightWithAnim(dialogHeight, anchorHeight, () -> popupWindow.dismiss());
        }

        private int getChatViewHeight(ViewParent parent) {
            if (parent instanceof View) {
                return ((View) parent).getHeight();
            }
            return 0;
        }

        class PinnedMessageListAdapter extends RecyclerView.Adapter<PinnedMessageViewHolder> {
            @NonNull
            @Override
            public PinnedMessageViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
                View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.chat_group_pinned_item_view_layout, parent, false);
                return new PinnedMessageViewHolder(view);
            }

            @Override
            public void onBindViewHolder(@NonNull PinnedMessageViewHolder holder, int position) {
                TUIMessageBean messageBean = messageBeanList.get(position);
                String messageAbstract = messageBean.onGetDisplayString();
                FaceManager.handlerEmojiText(holder.messageAbstractTv, messageAbstract, false);
                holder.messageSenderName.setText(messageBean.getUserDisplayName());
                holder.itemView.setOnClickListener(new OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        dismiss();
                        groupChatPresenter.locateMessage(messageBean.getId(), new IUIKitCallback<Void>() {
                            @Override
                            public void onSuccess(Void data) {
                                // do nothing
                            }

                            @Override
                            public void onError(String module, int errCode, String errMsg) {
                                ToastUtil.toastShortMessage(holder.itemView.getContext().getString(R.string.locate_origin_msg_failed_tip));
                            }
                        });
                    }
                });
                if (groupChatPresenter.canPinnedMessage()) {
                    holder.clearButton.setVisibility(VISIBLE);
                } else {
                    holder.clearButton.setVisibility(GONE);
                }
                holder.clearButton.setOnClickListener(new OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        groupChatPresenter.unpinnedMessage(messageBean, new TUICallback() {
                            @Override
                            public void onSuccess() {
                                //do nothing
                            }

                            @Override
                            public void onError(int errorCode, String errorMessage) {
                                ToastUtil.toastShortMessage(errorMessage);
                            }
                        });
                    }
                });
            }

            @Override
            public int getItemCount() {
                if (messageBeanList == null) {
                    return 0;
                }
                return messageBeanList.size();
            }
        }

        static class PinnedMessageViewHolder extends RecyclerView.ViewHolder {
            private TextView messageSenderName;
            private final TextView messageAbstractTv;
            private View clearButton;

            public PinnedMessageViewHolder(@NonNull View itemView) {
                super(itemView);
                messageSenderName = itemView.findViewById(R.id.message_sender_name);
                messageAbstractTv = itemView.findViewById(R.id.message_abstract);
                clearButton = itemView.findViewById(R.id.clear_button);
            }
        }
    }
}
