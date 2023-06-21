package com.tencent.qcloud.tuikit.tuicontact.minimalistui.pages;

import android.content.Context;
import android.content.Intent;
import android.graphics.Rect;
import android.net.Uri;
import android.os.Bundle;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.TextPaint;
import android.text.TextUtils;
import android.text.method.LinkMovementMethod;
import android.text.style.ClickableSpan;
import android.text.style.ForegroundColorSpan;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;
import androidx.activity.result.ActivityResultCallback;
import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContract;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.recyclerview.widget.SimpleItemAnimator;
import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.timcommon.component.MinimalistLineControllerView;
import com.tencent.qcloud.tuikit.timcommon.component.activities.ImageSelectMinimalistActivity;
import com.tencent.qcloud.tuikit.timcommon.component.dialog.TUIKitDialog;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.timcommon.util.ImageUtil;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuicontact.R;
import com.tencent.qcloud.tuikit.tuicontact.TUIContactConstants;
import com.tencent.qcloud.tuikit.tuicontact.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuicontact.bean.GroupInfo;
import com.tencent.qcloud.tuikit.tuicontact.bean.GroupMemberInfo;
import com.tencent.qcloud.tuikit.tuicontact.minimalistui.util.ContactStartChatUtils;
import com.tencent.qcloud.tuikit.tuicontact.presenter.ContactPresenter;
import com.tencent.qcloud.tuikit.tuicontact.util.TUIContactLog;
import java.util.ArrayList;
import java.util.List;

public class CreateGroupMinimalistActivity extends AppCompatActivity implements View.OnClickListener {
    private static final String TAG = CreateGroupMinimalistActivity.class.getSimpleName();

    private EditText groupNameEdit;
    private EditText groupIdEdit;
    private MinimalistLineControllerView groupTypeLv;
    private TextView createButton;
    private TextView cancelButton;
    private TextView groupTypeContentView;
    private RecyclerView groupAvatarList;
    private RecyclerView groupMemberList;
    private StartGroupChatMinimalistActivity.GroupMemberSelectedAdapter groupMemberSelectedAdapter;
    private ImageSelectMinimalistActivity.ImageGridAdapter groupAvatarSelectAdapter;

    private String groupName;
    private String groupType = TUIContactConstants.GroupType.TYPE_WORK;
    private String groupAvatarUrl;
    private ArrayList<Object> groupAvatarUrlList = new ArrayList<>();
    private int joinTypeIndex;
    private String groupAvatarImageId = "";

    private ArrayList<GroupMemberInfo> mGroupMembers = new ArrayList<>();
    private boolean mCreating;

    private ActivityResultLauncher<String> groupTypeLauncher;

    private ContactPresenter presenter;

    public static class GroupTypeResultContract extends ActivityResultContract<String, String> {
        @NonNull
        @Override
        public Intent createIntent(@NonNull Context context, String type) {
            Intent intent = new Intent(context, GroupTypeSelectMinimalistActivity.class);
            intent.putExtra(TUIContactConstants.Selection.GROUP_TYPE, type);
            return intent;
        }

        @Override
        public String parseResult(int i, @Nullable Intent data) {
            if (data != null) {
                String type = data.getStringExtra(TUIContactConstants.Selection.TYPE);
                if (TextUtils.isEmpty(type)) {
                    TUIContactLog.e(TAG, "onActivityResult type is null");
                    return null;
                } else {
                    return type;
                }
            }
            return null;
        }
    }

    private ActivityResultCallback<String> groupTypeSelectedCallback = new ActivityResultCallback<String>() {
        @Override
        public void onActivityResult(String type) {
            if (!TextUtils.isEmpty(type)) {
                groupType = type;
                groupTypeLv.setContent(type);
                initGroupTypeContentView();
                if (TextUtils.equals(groupType, TUIContactConstants.GroupType.TYPE_COMMUNITY)) {
                    groupIdEdit.setText("");
                    groupIdEdit.setEnabled(false);
                } else {
                    groupIdEdit.setEnabled(true);
                }
            }
        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        groupTypeLauncher = registerForActivityResult(new GroupTypeResultContract(), groupTypeSelectedCallback);

        setContentView(R.layout.contact_minimalist_create_group_layout);

        groupNameEdit = findViewById(R.id.group_name_edit);
        groupIdEdit = findViewById(R.id.group_id_edit);
        groupTypeLv = findViewById(R.id.group_type_layout);
        createButton = findViewById(R.id.create_button);
        cancelButton = findViewById(R.id.cancel_button);
        groupTypeContentView = findViewById(R.id.group_type_text);
        groupAvatarList = findViewById(R.id.group_avatar_list);
        groupMemberList = findViewById(R.id.selected_list);

        initData();
        setupViews();
    }

    private void initData() {
        Intent intent = getIntent();
        if (intent == null) {
            TUIContactLog.e(TAG, "intent is null");
            return;
        }
        Bundle bundle = intent.getExtras();
        if (bundle == null) {
            TUIContactLog.e(TAG, "bundle is null");
            return;
        }

        mGroupMembers = (ArrayList<GroupMemberInfo>) bundle.getSerializable(TUIConstants.TUIGroup.GROUP_MEMBER_ID_LIST);

        if (mGroupMembers == null || mGroupMembers.size() <= 1) {
            TUIContactLog.e(TAG, "mGroupMemberIcons <= 1");
        }
        generateImageID();

        groupName = bundle.getString(TUIConstants.TUIGroup.GROUP_NAME);
        groupNameEdit.setText(groupName);

        groupTypeLv.setContent(groupType);

        if (TUIConfig.isEnableGroupGridAvatar()) {
            groupAvatarUrlList.clear();
            groupAvatarUrlList.addAll(fillGroupGridAvatar());
            groupAvatarUrl = null;
        }

        joinTypeIndex = bundle.getInt(TUIConstants.TUIGroup.JOIN_TYPE_INDEX, 2);
    }

    private void generateImageID() {
        groupAvatarImageId = System.currentTimeMillis() + "";
    }

    private void setupViews() {
        groupTypeLv.setOnClickListener(this);
        cancelButton.setOnClickListener(this);
        createButton.setOnClickListener(this);
        presenter = new ContactPresenter();
        initGroupTypeContentView();
        initAvatarList();
        initSelectedMemberList();
    }

    private void initGroupTypeContentView() {
        switch (groupType) {
            case TUIContactConstants.GroupType.TYPE_WORK:
                groupTypeContentView.setText(getString(R.string.group_work_content));
                break;
            case TUIContactConstants.GroupType.TYPE_PUBLIC:
                groupTypeContentView.setText(getString(R.string.group_public_des));
                break;
            case TUIContactConstants.GroupType.TYPE_MEETING:
                groupTypeContentView.setText(getString(R.string.group_meeting_des));
                break;
            case TUIContactConstants.GroupType.TYPE_COMMUNITY:
                groupTypeContentView.setText(getString(R.string.group_commnity_des));
                break;
            default:
                break;
        }

        String groupTypeContent = getResources().getString(R.string.group_type_content_title);
        String urlContent = getResources().getString(R.string.group_type_content_url);
        int urlContentIndex = groupTypeContent.lastIndexOf(urlContent);

        final int foregroundColor;
        int currentTheme = TUIThemeManager.getInstance().getCurrentTheme();
        if (currentTheme == TUIThemeManager.THEME_LIVELY) {
            foregroundColor = getResources().getColor(com.tencent.qcloud.tuicore.R.color.core_primary_color_lively);
        } else if (currentTheme == TUIThemeManager.THEME_SERIOUS) {
            foregroundColor = getResources().getColor(com.tencent.qcloud.tuicore.R.color.core_primary_color_serious);
        } else {
            foregroundColor = getResources().getColor(com.tencent.qcloud.tuicore.R.color.core_primary_color_light);
        }

        SpannableString spannedString = new SpannableString(groupTypeContent);
        ForegroundColorSpan colorSpan = new ForegroundColorSpan(foregroundColor);
        spannedString.setSpan(colorSpan, urlContentIndex, urlContentIndex + urlContent.length(), Spannable.SPAN_EXCLUSIVE_INCLUSIVE);

        ClickableSpan clickableSpan = new ClickableSpan() {
            @Override
            public void onClick(View view) {
                if (TextUtils.equals(TUIThemeManager.getInstance().getCurrentLanguage(), "zh")) {
                    openWebUrl(TUIContactConstants.IM_PRODUCT_DOC_URL);
                } else {
                    openWebUrl(TUIContactConstants.IM_PRODUCT_DOC_URL_EN);
                }
            }

            @Override
            public void updateDrawState(TextPaint ds) {
                ds.setUnderlineText(false);
            }
        };
        spannedString.setSpan(clickableSpan, urlContentIndex, urlContentIndex + urlContent.length(), Spannable.SPAN_EXCLUSIVE_INCLUSIVE);
        groupTypeContentView.append(spannedString);
        groupTypeContentView.setMovementMethod(LinkMovementMethod.getInstance());
    }

    private void initAvatarList() {
        int columnCount = 2;
        groupAvatarList.setLayoutManager(new GridLayoutManager(this, columnCount, RecyclerView.HORIZONTAL, false));
        int leftRightSpace = ScreenUtil.dip2px(23);
        groupAvatarList.addItemDecoration(new GridDecoration(leftRightSpace, ScreenUtil.dip2px(20)));
        groupAvatarList.setItemAnimator(null);
        SimpleItemAnimator animator = (SimpleItemAnimator) groupAvatarList.getItemAnimator();
        if (animator != null) {
            animator.setSupportsChangeAnimations(false);
        }
        groupAvatarSelectAdapter = new ImageSelectMinimalistActivity.ImageGridAdapter();
        ArrayList<ImageSelectMinimalistActivity.ImageBean> faceList = new ArrayList<>();
        if (TUIConfig.isEnableGroupGridAvatar()) {
            ImageSelectMinimalistActivity.ImageBean imageBean = new ImageSelectMinimalistActivity.ImageBean();
            imageBean.setGroupGridAvatar(fillGroupGridAvatar());
            imageBean.setImageId(groupAvatarImageId);
            faceList.add(imageBean);
        }
        for (int i = 0; i < TUIConstants.TUIContact.GROUP_FACE_COUNT; i++) {
            ImageSelectMinimalistActivity.ImageBean imageBean = new ImageSelectMinimalistActivity.ImageBean();
            imageBean.setThumbnailUri(String.format(TUIConstants.TUIContact.GROUP_FACE_URL, (i + 1) + ""));
            faceList.add(imageBean);
        }
        groupAvatarSelectAdapter.setItemHeight(ScreenUtil.dip2px(50));
        groupAvatarSelectAdapter.setItemWidth(ScreenUtil.dip2px(50));
        groupAvatarSelectAdapter.setSelected(faceList.get(0));
        groupAvatarSelectAdapter.setData(faceList);
        groupAvatarSelectAdapter.setOnItemClickListener(new ImageSelectMinimalistActivity.OnItemClickListener() {
            @Override
            public void onClick(ImageSelectMinimalistActivity.ImageBean imageBean) {
                List<Object> faceUrlList = imageBean.getGroupGridAvatar();
                if (faceUrlList != null && !faceUrlList.isEmpty()) {
                    groupAvatarUrlList.clear();
                    groupAvatarUrlList.addAll(faceUrlList);
                    groupAvatarUrl = null;
                } else {
                    groupAvatarUrl = imageBean.getThumbnailUri();
                }
                groupAvatarSelectAdapter.setSelected(imageBean);
            }
        });
        groupAvatarList.setAdapter(groupAvatarSelectAdapter);
    }

    private void initSelectedMemberList() {
        groupMemberList.setLayoutManager(new LinearLayoutManager(this, RecyclerView.HORIZONTAL, false));
        groupMemberList.setItemAnimator(null);
        SimpleItemAnimator animator = (SimpleItemAnimator) groupMemberList.getItemAnimator();
        if (animator != null) {
            animator.setSupportsChangeAnimations(false);
        }
        groupMemberSelectedAdapter = new StartGroupChatMinimalistActivity.GroupMemberSelectedAdapter();
        groupMemberSelectedAdapter.setMembers(mGroupMembers);
        groupMemberSelectedAdapter.setSelectedMemberClickedListener(new StartGroupChatMinimalistActivity.OnSelectedMemberClickedListener() {
            @Override
            public void onRemove(GroupMemberInfo groupMemberInfo) {
                groupMemberSelectedAdapter.notifyItemRemoved(mGroupMembers.indexOf(groupMemberInfo));
                mGroupMembers.remove(groupMemberInfo);
                ImageSelectMinimalistActivity.ImageBean imageBean = groupAvatarSelectAdapter.getDataByPosition(0);
                if (imageBean != null) {
                    generateImageID();
                    List<Object> avatarList = fillGroupGridAvatar();
                    imageBean.setImageId(groupAvatarImageId);
                    imageBean.setGroupGridAvatar(avatarList);
                    groupAvatarSelectAdapter.notifyItemChanged(0);
                    groupAvatarUrlList.clear();
                    groupAvatarUrlList.addAll(avatarList);
                }
            }
        });
        groupMemberList.addItemDecoration(new RecyclerView.ItemDecoration() {
            @Override
            public void getItemOffsets(@NonNull Rect outRect, @NonNull View view, @NonNull RecyclerView parent, @NonNull RecyclerView.State state) {
                outRect.bottom = ScreenUtil.dip2px(10);
            }
        });
        groupMemberList.setAdapter(groupMemberSelectedAdapter);
    }

    @Override
    public void onClick(View v) {
        if (v == groupTypeLv) {
            groupTypeLauncher.launch(groupType);
        } else if (v == cancelButton) {
            finish();
        } else if (v == createButton) {
            createGroupChat();
        }
    }

    private List<Object> fillGroupGridAvatar() {
        final List<Object> urlList = new ArrayList<>();
        String savedIcon = ImageUtil.getGroupConversationAvatar(groupAvatarImageId);
        if (TextUtils.isEmpty(savedIcon)) {
            int faceSize = Math.min(mGroupMembers.size(), 9);
            urlList.add(TUIConfig.getSelfFaceUrl());
            for (int i = 0; i < faceSize; i++) {
                String iconUrl = mGroupMembers.get(i).getIconUrl();
                urlList.add(TextUtils.isEmpty(iconUrl) ? TUIConfig.getDefaultAvatarImage() : iconUrl);
            }
        } else {
            urlList.add(savedIcon);
        }

        return urlList;
    }

    private void createGroupChat() {
        if (mCreating) {
            return;
        }
        groupName = groupNameEdit.getText().toString();
        final GroupInfo groupInfo = new GroupInfo();
        groupInfo.setChatName(groupName);
        groupInfo.setGroupName(groupName);
        groupInfo.setMemberDetails(mGroupMembers);
        groupInfo.setGroupType(groupType);
        groupInfo.setJoinType(joinTypeIndex);
        groupInfo.setCommunitySupportTopic(false);
        groupInfo.setFaceUrl(groupAvatarUrl);
        groupInfo.setIconUrlList(groupAvatarUrlList);

        String groupId = groupIdEdit.getText().toString();
        if (!TextUtils.isEmpty(groupId)) {
            groupInfo.setId(groupId);
        } else {
            groupInfo.setId("");
        }

        mCreating = true;

        presenter.createGroupChat(groupInfo, new IUIKitCallback<String>() {
            @Override
            public void onSuccess(String data) {
                ContactStartChatUtils.startChatActivity(data, ChatInfo.TYPE_GROUP, groupInfo.getGroupName(), groupAvatarUrl, groupAvatarUrlList);
                finish();
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                mCreating = false;
                if (errCode == TUIConstants.BuyingFeature.ERR_SDK_INTERFACE_NOT_SUPPORT || errCode == 11000) {
                    showNotSupportDialog();
                }
                ToastUtil.toastLongMessage("createGroupChat fail:" + errCode + "=" + errMsg);
            }
        });
    }

    private void showNotSupportDialog() {
        String string = getResources().getString(R.string.contact_im_flagship_edition_update_tip, getString(R.string.contact_community));
        String buyingGuidelines = getResources().getString(R.string.contact_buying_guidelines);
        int buyingGuidelinesIndex = string.lastIndexOf(buyingGuidelines);
        final int foregroundColor = getResources().getColor(TUIThemeManager.getAttrResId(this, com.tencent.qcloud.tuicore.R.attr.core_primary_color));
        SpannableString spannedString = new SpannableString(string);
        ForegroundColorSpan colorSpan2 = new ForegroundColorSpan(foregroundColor);
        spannedString.setSpan(colorSpan2, buyingGuidelinesIndex, buyingGuidelinesIndex + buyingGuidelines.length(), Spannable.SPAN_EXCLUSIVE_INCLUSIVE);

        ClickableSpan clickableSpan2 = new ClickableSpan() {
            @Override
            public void onClick(View view) {
                if (TextUtils.equals(TUIThemeManager.getInstance().getCurrentLanguage(), "zh")) {
                    openWebUrl(TUIConstants.BuyingFeature.BUYING_PRICE_DESC);
                } else {
                    openWebUrl(TUIConstants.BuyingFeature.BUYING_PRICE_DESC_EN);
                }
            }

            @Override
            public void updateDrawState(TextPaint ds) {
                ds.setUnderlineText(false);
            }
        };
        spannedString.setSpan(clickableSpan2, buyingGuidelinesIndex, buyingGuidelinesIndex + buyingGuidelines.length(), Spannable.SPAN_EXCLUSIVE_INCLUSIVE);

        TUIKitDialog.TUIIMUpdateDialog.getInstance()
            .createDialog(this)
            .setMovementMethod(LinkMovementMethod.getInstance())
            .setShowOnlyDebug(true)
            .setCancelable(true)
            .setCancelOutside(true)
            .setTitle(spannedString)
            .setDialogWidth(0.75f)
            .setDialogFeatureName(TUIConstants.BuyingFeature.BUYING_FEATURE_COMMUNITY)
            .setPositiveButton(getString(R.string.contact_no_more_reminders),
                new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        TUIKitDialog.TUIIMUpdateDialog.getInstance().dismiss();
                        TUIKitDialog.TUIIMUpdateDialog.getInstance().setNeverShow(true);
                    }
                })
            .setNegativeButton(getString(R.string.contact_i_know),
                new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        TUIKitDialog.TUIIMUpdateDialog.getInstance().dismiss();
                    }
                })
            .show();
    }

    private void openWebUrl(String url) {
        Intent intent = new Intent();
        intent.setAction(Intent.ACTION_VIEW);
        Uri contentUrl = Uri.parse(url);
        intent.setData(contentUrl);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        startActivity(intent);
    }

    /**
     * add spacing
     */
    public static class GridDecoration extends RecyclerView.ItemDecoration {
        private final int leftRightSpace; // vertical spacing
        private final int topBottomSpace; // horizontal spacing

        public GridDecoration(int leftRightSpace, int topBottomSpace) {
            this.leftRightSpace = leftRightSpace;
            this.topBottomSpace = topBottomSpace;
        }

        @Override
        public void getItemOffsets(Rect outRect, View view, RecyclerView parent, RecyclerView.State state) {
            outRect.right = leftRightSpace;
            outRect.bottom = topBottomSpace;
        }
    }
}