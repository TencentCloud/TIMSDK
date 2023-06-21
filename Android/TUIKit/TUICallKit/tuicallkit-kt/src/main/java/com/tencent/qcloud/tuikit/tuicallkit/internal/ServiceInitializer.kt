package com.tencent.qcloud.tuikit.tuicallkit.internal

import android.content.ContentProvider
import android.content.ContentValues
import android.content.Context
import android.database.Cursor
import android.net.Uri
import android.util.Log

/**
 * `TUICallKit` uses `ContentProvider` to be registered with `TUICore`.
 * (`TUICore` is the connection and communication class of each component)
 */
class ServiceInitializer : ContentProvider() {

    fun init(context: Context) {
        TUICallKitService.sharedInstance(context)
    }

    override fun onCreate(): Boolean {
        Log.d("ServiceInitializer", "ServiceInitializer onCreate")
        val appContext = context.applicationContext
        if (appContext == null) {
            Log.d("ServiceInitializer", "ServiceInitializer appContext == null")
        } else {
            Log.d("ServiceInitializer", "ServiceInitializer appContext != null")
        }
        init(appContext)
        return false
    }

    override fun query(
        uri: Uri, projection: Array<String>?, selection: String?,
        selectionArgs: Array<String>?, sortOrder: String?
    ): Cursor? {
        return null
    }

    override fun getType(uri: Uri): String? {
        return null
    }

    override fun insert(uri: Uri, values: ContentValues?): Uri? {
        return null
    }

    override fun delete(uri: Uri, selection: String?, selectionArgs: Array<String>?): Int {
        return 0
    }

    override fun update(
        uri: Uri, values: ContentValues?, selection: String?,
        selectionArgs: Array<String>?
    ): Int {
        return 0
    }
}