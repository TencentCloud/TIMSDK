package com.tencent.qcloud.tuicore;

import android.content.ContentProvider;
import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.text.TextUtils;
import android.util.Log;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.tencent.qcloud.tuicore.annotations.TUIInitializerDependency;
import com.tencent.qcloud.tuicore.annotations.TUIInitializerID;
import com.tencent.qcloud.tuicore.annotations.TUIInitializerPriority;
import com.tencent.qcloud.tuicore.interfaces.TUIInitializer;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.PriorityQueue;
import java.util.Queue;
import java.util.ServiceLoader;
import java.util.Set;

/**
 * If each module needs to be initialized, it needs to implement the init method of this class
 * and register it in the form of ContentProvider in the Manifest file.
 */
public class ServiceInitializer extends ContentProvider {
    private static final String TAG = "ServiceInitializer";

    /**
     * @param context applicationContext
     */
    public void init(Context context) {}

    /**
     * LightTheme id
     */
    public int getLightThemeResId() {
        return R.style.TUIBaseLightTheme;
    }

    /**
     * LivelyTheme id
     */
    public int getLivelyThemeResId() {
        return R.style.TUIBaseLivelyTheme;
    }

    /**
     * SeriousTheme id
     */
    public int getSeriousThemeResId() {
        return R.style.TUIBaseSeriousTheme;
    }

    /////////////////////////////////////////////////////////////////////////////////
    //             The following methods do not need to be overridden              //
    /////////////////////////////////////////////////////////////////////////////////

    private static Context appContext;
    private static boolean hasInitComponents = false;

    public static Context getAppContext() {
        return appContext;
    }

    @Override
    public boolean onCreate() {
        if (appContext == null) {
            appContext = getContext().getApplicationContext();
        }

        TUILogin.init(appContext);
        TUIRouter.init(appContext);
        TUIConfig.init(appContext);
        TUIThemeManager.addLightTheme(getLightThemeResId());
        TUIThemeManager.addLivelyTheme(getLivelyThemeResId());
        TUIThemeManager.addSeriousTheme(getSeriousThemeResId());
        TUIThemeManager.setTheme(appContext);
        if (!hasInitComponents) {
            hasInitComponents = true;
            initComponents();
        }
        init(appContext);

        return false;
    }

    private void initComponents() {
        ServiceLoader<TUIInitializer> initializers = ServiceLoader.load(TUIInitializer.class);
        Map<String, TUIInitializer> initializerMap = new HashMap<>();
        for (TUIInitializer initializer : initializers) {
            String initializerID = getInitializerID(initializer);
            initializerMap.put(initializerID, initializer);
        }

        List<TUIInitializer> initializerList = getSortedInitializerList(initializerMap);
        StringBuilder sequence = new StringBuilder();
        for (TUIInitializer initializer : initializerList) {
            sequence.append(getInitializerID(initializer)).append(" ");
        }
        Log.i(TAG, "initialization sequence : " + sequence);
        for (TUIInitializer initializer : initializerList) {
            String initializerID = getInitializerID(initializer);
            Log.i(TAG, "start init " + initializerID);
            initializer.init(appContext);
            Log.i(TAG, "init " + initializerID + " finished");
        }
    }

    private List<TUIInitializer> getSortedInitializerList(Map<String, TUIInitializer> initializerMap) {
        Map<TUIInitializer, DependencyNode> dependencyNodeMap = new HashMap<>();
        // build dependency map
        for (TUIInitializer initializer : initializerMap.values()) {
            dependencyNodeMap.put(initializer, new DependencyNode(initializer));
        }
        for (Map.Entry<String, TUIInitializer> initializerEntry : initializerMap.entrySet()) {
            TUIInitializerDependency annotationDependency = initializerEntry.getValue().getClass().getAnnotation(TUIInitializerDependency.class);
            TUIInitializerPriority annotationPriority = initializerEntry.getValue().getClass().getAnnotation(TUIInitializerPriority.class);
            DependencyNode dependencyNode = dependencyNodeMap.get(initializerEntry.getValue());
            int priority = 0;
            if (annotationPriority != null) {
                priority = annotationPriority.value();
            }
            dependencyNode.priority = priority;
            if (annotationDependency == null) {
                continue;
            }
            String[] dependencies = annotationDependency.value();
            if (dependencies == null || dependencies.length == 0) {
                continue;
            }
            for (String dependencyID : dependencies) {
                if (TextUtils.isEmpty(dependencyID)) {
                    continue;
                }
                if (initializerMap.containsKey(dependencyID)) {
                    DependencyNode beDependencyNode = dependencyNodeMap.get(initializerMap.get(dependencyID));
                    dependencyNode.addDependency(beDependencyNode);
                    beDependencyNode.addBeDependency(dependencyNode);
                } else {
                    Log.w(TAG, initializerEntry.getKey() + " depends on " + dependencyID + ", but " + dependencyID + " is not found.");
                }
            }
        }
        // sort by dependency count and priority
        List<DependencyNode> dependencyNodeList = new ArrayList<>(dependencyNodeMap.values());
        Comparator<DependencyNode> comparator =  (o1, o2) -> {
            if (o1.dependencyCount() == o2.dependencyCount()) {
                return o2.priority - o1.priority;
            }
            return o1.dependencyCount() - o2.dependencyCount();
        };
        Collections.sort(dependencyNodeList, comparator);
        // get the initialization sequence and check
        ArrayList<TUIInitializer> sortedInitializerList = new ArrayList<>();
        while (true) {
            if (dependencyNodeList.isEmpty()) {
                break;
            }
            DependencyNode dependencyNode = dependencyNodeList.get(0);
            if (dependencyNode != null && dependencyNode.dependencyCount() == 0) {
                Set<DependencyNode> beDependencyNodes = dependencyNode.getBeDependencySet();
                for (DependencyNode beDependencyNode : beDependencyNodes) {
                    beDependencyNode.removeDependency(dependencyNode);
                }
                dependencyNode.removeBeDependencies(beDependencyNodes);
                sortedInitializerList.add(dependencyNode.initializer);
                dependencyNodeList.remove(0);
                Collections.sort(dependencyNodeList, comparator);
            } else {
                break;
            }
        }
        if (dependencyNodeList.size() != 0) {
            throw new IllegalStateException("FATAL! TUIInitializer has circular dependency:\n" + dumpCircularDependency(dependencyNodeList));
        }
        return sortedInitializerList;
    }

    private String getInitializerID(TUIInitializer initializer) {
        String initializerID;
        TUIInitializerID annotationID = initializer.getClass().getAnnotation(TUIInitializerID.class);
        if (annotationID == null || TextUtils.isEmpty(annotationID.value())) {
            initializerID = initializer.getClass().getSimpleName();
        } else {
            initializerID = annotationID.value();
        }
        return initializerID;
    }

    private String dumpCircularDependency(List<DependencyNode> dependencyNodes) {
        StringBuilder builder = new StringBuilder();
        builder.append("[");
        for (DependencyNode dependencyNode : dependencyNodes) {
            builder.append(dependencyNode.initializer.getClass().getSimpleName());
            builder.append(", ");
        }
        builder.append("]");
        return builder.toString();
    }

    private static class DependencyNode {
        TUIInitializer initializer;
        int priority;
        
        Set<DependencyNode> dependencySet = new HashSet<>();
        Set<DependencyNode> beDependencySet = new HashSet<>();

        DependencyNode(TUIInitializer initializer) {
            this.initializer = initializer;
        }

        void addDependency(DependencyNode dependencyNode) {
            dependencySet.add(dependencyNode);
        }

        void removeDependency(DependencyNode dependencyNode) {
            dependencySet.remove(dependencyNode);
        }

        void addBeDependency(DependencyNode dependencyNode) {
            beDependencySet.add(dependencyNode);
        }

        void removeBeDependency(DependencyNode dependencyNode) {
            beDependencySet.remove(dependencyNode);
        }

        void removeBeDependencies(Set<DependencyNode> dependencyNode) {
            beDependencySet.removeAll(dependencyNode);
        }

        public Set<DependencyNode> getBeDependencySet() {
            return beDependencySet;
        }

        public Set<DependencyNode> getDependencySet() {
            return dependencySet;
        }

        int dependencyCount() {
            if (dependencySet != null) {
                return dependencySet.size();
            }
            return 0;
        }

        int beDependencyCount() {
            if (beDependencySet != null) {
                return beDependencySet.size();
            }
            return 0;
        }
    }

    @Nullable
    @Override
    public Cursor query(
        @NonNull Uri uri, @Nullable String[] projection, @Nullable String selection, @Nullable String[] selectionArgs, @Nullable String sortOrder) {
        return null;
    }

    @Nullable
    @Override
    public String getType(@NonNull Uri uri) {
        return null;
    }

    @Nullable
    @Override
    public Uri insert(@NonNull Uri uri, @Nullable ContentValues values) {
        return null;
    }

    @Override
    public int delete(@NonNull Uri uri, @Nullable String selection, @Nullable String[] selectionArgs) {
        return 0;
    }

    @Override
    public int update(@NonNull Uri uri, @Nullable ContentValues values, @Nullable String selection, @Nullable String[] selectionArgs) {
        return 0;
    }
}
