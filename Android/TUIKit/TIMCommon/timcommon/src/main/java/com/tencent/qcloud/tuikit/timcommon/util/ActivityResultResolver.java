package com.tencent.qcloud.tuikit.timcommon.util;

import android.app.Activity;
import android.content.ClipData;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;
import android.text.TextUtils;
import android.util.Pair;
import androidx.activity.result.ActivityResult;
import androidx.activity.result.ActivityResultCallback;
import androidx.activity.result.ActivityResultCaller;
import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContract;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.FragmentActivity;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.interfaces.TUIValueCallback;
import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashSet;
import java.util.List;

public class ActivityResultResolver {
    public static final String CONTENT_TYPE_ALL = "*/*";
    public static final String CONTENT_TYPE_IMAGE = "image/*";
    public static final String CONTENT_TYPE_VIDEO = "video/*";

    private static final String CONTENT_KEY_TYPE = "ContentType";
    private static final String URI = "Uri";
    private static final String METHOD = "Method";
    private static final String KEY_DATA = "Data";

    private static final String METHOD_GET_SINGLE_CONTENT = "MethodGetSingleContent";
    private static final String METHOD_GET_MULTIPLE_CONTENT = "MethodGetMultipleContent";
    private static final String METHOD_TAKE_PICTURE = "MethodTakePicture";
    private static final String METHOD_TAKE_VIDEO = "MethodTakeVideo";

    private ActivityResultResolver() {}

    public static void getSingleContent(ActivityResultCaller activityResultCaller, @NonNull String type, TUIValueCallback<Uri> callback) {
        getContent(activityResultCaller, new String[] {type}, false, new TUIValueCallback<List<Uri>>() {
            @Override
            public void onSuccess(List<Uri> list) {
                if (list != null && !list.isEmpty()) {
                    TUIValueCallback.onSuccess(callback, list.get(0));
                } else {
                    TUIValueCallback.onError(callback, -1, "getSingleContent result list is empty");
                }
            }

            @Override
            public void onError(int errorCode, String errorMessage) {
                TUIValueCallback.onError(callback, errorCode, errorMessage);
            }
        });
    }

    public static void getSingleContent(ActivityResultCaller activityResultCaller, @NonNull String[] type, TUIValueCallback<Uri> callback) {
        getContent(activityResultCaller, type, false, new TUIValueCallback<List<Uri>>() {
            @Override
            public void onSuccess(List<Uri> list) {
                if (list != null && !list.isEmpty()) {
                    TUIValueCallback.onSuccess(callback, list.get(0));
                } else {
                    TUIValueCallback.onError(callback, -1, "getSingleContent result list is empty");
                }
            }

            @Override
            public void onError(int errorCode, String errorMessage) {
                TUIValueCallback.onError(callback, errorCode, errorMessage);
            }
        });
    }

    public static void getMultipleContent(ActivityResultCaller activityResultCaller, @NonNull String type, TUIValueCallback<List<Uri>> callback) {
        getContent(activityResultCaller, new String[] {type}, true, callback);
    }

    public static void getMultipleContent(ActivityResultCaller activityResultCaller, @NonNull String[] type, TUIValueCallback<List<Uri>> callback) {
        getContent(activityResultCaller, type, true, callback);
    }

    private static void getContent(
        ActivityResultCaller activityResultCaller, @NonNull String[] types, boolean isMultiContent, TUIValueCallback<List<Uri>> callback) {
        Bundle bundle = new Bundle();
        bundle.putStringArray(CONTENT_KEY_TYPE, types);
        bundle.putString(METHOD, isMultiContent ? METHOD_GET_MULTIPLE_CONTENT : METHOD_GET_SINGLE_CONTENT);
        TUICore.startActivityForResult(activityResultCaller, ActivityResultProxyActivity.class, bundle, new ActivityResultCallback<ActivityResult>() {
            @Override
            public void onActivityResult(ActivityResult result) {
                if (result.getData() != null) {
                    TUIValueCallback.onSuccess(callback, (List<Uri>) result.getData().getSerializableExtra(KEY_DATA));
                }
            }
        });
    }

    public static void takePicture(ActivityResultCaller activityResultCaller, @NonNull Uri uri, TUIValueCallback<Boolean> callback) {
        takePictureVideo(activityResultCaller, uri, true, callback);
    }

    public static void takeVideo(ActivityResultCaller activityResultCaller, @NonNull Uri uri, TUIValueCallback<Boolean> callback) {
        takePictureVideo(activityResultCaller, uri, false, callback);
    }

    private static void takePictureVideo(ActivityResultCaller activityResultCaller, @NonNull Uri uri, boolean isPicture, TUIValueCallback<Boolean> callback) {
        Bundle bundle = new Bundle();
        if (isPicture) {
            bundle.putString(METHOD, METHOD_TAKE_PICTURE);
        } else {
            bundle.putString(METHOD, METHOD_TAKE_VIDEO);
        }
        bundle.putParcelable(URI, uri);
        TUICore.startActivityForResult(activityResultCaller, ActivityResultProxyActivity.class, bundle, new ActivityResultCallback<ActivityResult>() {
            @Override
            public void onActivityResult(ActivityResult result) {
                if (result.getData() != null) {
                    TUIValueCallback.onSuccess(callback, result.getData().getBooleanExtra(KEY_DATA, false));
                }
            }
        });
    }

    private static class GetContentsContract extends ActivityResultContract<Pair<String[], Boolean>, List<Uri>> {
        @NonNull
        @Override
        public Intent createIntent(@NonNull Context context, @NonNull Pair<String[], Boolean> input) {
            Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
            intent.addCategory(Intent.CATEGORY_OPENABLE);
            String[] type = input.first;
            boolean allowMultiple = input.second;
            if (type.length == 1) {
                intent.setType(type[0]);
            } else if (type.length > 1) {
                intent.setType(type[0]);
                intent.putExtra(Intent.EXTRA_MIME_TYPES, type);
            }
            intent.putExtra(Intent.EXTRA_ALLOW_MULTIPLE, allowMultiple);
            return intent;
        }

        @NonNull
        @Override
        public final List<Uri> parseResult(int resultCode, @Nullable Intent intent) {
            if (intent == null || resultCode != Activity.RESULT_OK) {
                return Collections.emptyList();
            } else {
                return getClipDataUris(intent);
            }
        }

        @NonNull
        static List<Uri> getClipDataUris(@NonNull Intent intent) {
            // Use a LinkedHashSet to maintain any ordering that may be
            // present in the ClipData
            LinkedHashSet<Uri> resultSet = new LinkedHashSet<>();
            if (intent.getData() != null) {
                resultSet.add(intent.getData());
            }
            ClipData clipData = intent.getClipData();
            if (clipData == null && resultSet.isEmpty()) {
                return Collections.emptyList();
            } else if (clipData != null) {
                for (int i = 0; i < clipData.getItemCount(); i++) {
                    Uri uri = clipData.getItemAt(i).getUri();
                    if (uri != null) {
                        resultSet.add(uri);
                    }
                }
            }
            return new ArrayList<>(resultSet);
        }
    }

    private static class TakePictureVideoContract extends ActivityResultContract<Pair<Uri, Boolean>, Boolean> {
        private boolean isTakePicture;

        @NonNull
        @Override
        public Intent createIntent(@NonNull Context context, @NonNull Pair<Uri, Boolean> input) {
            isTakePicture = input.second;
            if (isTakePicture) {
                return new Intent(MediaStore.ACTION_IMAGE_CAPTURE)
                    .putExtra(MediaStore.EXTRA_OUTPUT, input.first)
                    .addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
                    .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            } else {
                return new Intent(MediaStore.ACTION_VIDEO_CAPTURE)
                    .putExtra(MediaStore.EXTRA_OUTPUT, input.first)
                    .addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
                    .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            }
        }

        @NonNull
        @Override
        public final Boolean parseResult(int resultCode, @Nullable Intent intent) {
            if (isTakePicture) {
                return resultCode == Activity.RESULT_OK;
            } else {
                return intent != null && resultCode == Activity.RESULT_OK;
            }
        }
    }

    public static class ActivityResultProxyActivity extends FragmentActivity {
        @Override
        protected void onCreate(@Nullable Bundle savedInstanceState) {
            super.onCreate(savedInstanceState);
            Intent intent = getIntent();
            String method = intent.getStringExtra(METHOD);
            if (TextUtils.equals(method, METHOD_GET_SINGLE_CONTENT)) {
                getSingleContent(intent);
            } else if (TextUtils.equals(method, METHOD_GET_MULTIPLE_CONTENT)) {
                getMultipleContent(intent);
            } else if (TextUtils.equals(method, METHOD_TAKE_PICTURE)) {
                takePicture(intent);
            } else if (TextUtils.equals(method, METHOD_TAKE_VIDEO)) {
                takeVideo(intent);
            }
        }

        private void getSingleContent(Intent intent) {
            String[] types = intent.getStringArrayExtra(CONTENT_KEY_TYPE);
            getContent(types, false);
        }

        private void getMultipleContent(Intent intent) {
            String[] types = intent.getStringArrayExtra(CONTENT_KEY_TYPE);
            getContent(types, true);
        }

        private void getContent(String[] types, boolean isMultiple) {
            ActivityResultLauncher<Pair<String[], Boolean>> launcher =
                this.registerForActivityResult(new GetContentsContract(), new ActivityResultCallback<List<Uri>>() {
                    @Override
                    public void onActivityResult(List<Uri> result) {
                        Intent dataIntent = new Intent();
                        dataIntent.putExtra(KEY_DATA, new ArrayList<>(result));
                        setResult(Activity.RESULT_OK, dataIntent);
                        finish();
                    }
                });
            try {
                launcher.launch(Pair.create(types, isMultiple));
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        private void takePicture(Intent intent) {
            takePictureVideo(intent, true);
        }

        private void takeVideo(Intent intent) {
            takePictureVideo(intent, false);
        }

        private void takePictureVideo(Intent intent, boolean isPicture) {
            Uri uri = intent.getParcelableExtra(URI);
            ActivityResultLauncher<Pair<Uri, Boolean>> launcher =
                this.registerForActivityResult(new TakePictureVideoContract(), new ActivityResultCallback<Boolean>() {
                    @Override
                    public void onActivityResult(Boolean result) {
                        Intent dataIntent = new Intent();
                        dataIntent.putExtra(KEY_DATA, result);
                        setResult(Activity.RESULT_OK, dataIntent);
                        finish();
                    }
                });
            try {
                launcher.launch(Pair.create(uri, isPicture));
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}
