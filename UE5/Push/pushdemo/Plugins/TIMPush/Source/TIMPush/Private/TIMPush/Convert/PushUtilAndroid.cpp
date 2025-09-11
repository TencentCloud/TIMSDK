// Copyright (c) 2025 Tencent. All rights reserved.
#if PLATFORM_ANDROID
#include "PushUtil.h"

#include "PushListener.h"
#include "PushMessage.h"
#include "PushCallback.h"
#include <string>


namespace Push {
namespace Convert {
namespace Util {
    std::string FStringToStdString(const FString& fstr) {
        // TCHAR_TO_UTF8 宏返回 const char*，是 UTF-8 编码
        return std::string(TCHAR_TO_UTF8(*fstr));
    }
    
    FString StdStringToFString(const std::string& str) {
        // UTF8_TO_TCHAR 宏将 UTF-8 字节流转为 TCHAR*
        return FString(UTF8_TO_TCHAR(str.c_str()));
    }
    
    FString JStringToFString(JNIEnv* jenv, jstring jstr) {
        if (!jstr) return FString();
    
        // 获取 UTF-16 字符指针
        const jchar* Raw = jenv->GetStringChars(jstr, nullptr);
        jsize Len = jenv->GetStringLength(jstr);
    
        // FString 构造支持 TCHAR*，Android 下 TCHAR=char16_t，jchar=char16_t，直接兼容
        FString Result;
        Result.AppendChars((const TCHAR*)Raw, Len);
    
        jenv->ReleaseStringChars(jstr, Raw);
        return Result;
    }
    
    jstring FStringToJString(JNIEnv* jenv, const FString& fstr) {
        // FString::Len() 返回字符数
        // Android 下 TCHAR=char16_t，jchar=char16_t，直接兼容
        return jenv->NewString((const jchar*)*fstr, fstr.Len());
    }

    jstring FStringVoidPtrToJString(JNIEnv* Env, void* Param) {
        if (!Param)
            return nullptr;
    
        // void* 指向的假设是 TCHAR*，即Unicode字符
        // 把它转换为 FString 方便使用UE转换工具
        const TCHAR* TCHARStr = static_cast<const TCHAR*>(Param);
        const FString UEString = FString(TCHARStr);
    
        // 使用FTCHARToUTF8转换（TCHAR->UTF8）
        FTCHARToUTF8 UTF8String(*UEString);
    
        // UTF8String.Get() 返回 char*，是经UTF8编码的字符串
        return Env->NewStringUTF(UTF8String.Get());
   }

    jobject GetJavaCallback(JNIEnv* jenv, jlong ptr) {
        jclass callbackClass = FAndroidApplication::FindJavaClassGlobalRef("com/tencent/qcloud/tim/push/ue/UEPushCallback");
        if (!callbackClass) {
            UE_LOG(LogInit, Error, TEXT("Push failed to find PushCallback class"));
            return nullptr;
        }

        jmethodID ctor = jenv->GetMethodID(callbackClass, "<init>", "(J)V");
        if (!ctor) {
            UE_LOG(LogInit, Error, TEXT("Push failed to get PushCallback constructor"));
            return nullptr;
        }

        jobject callbackObj = jenv->NewObject(callbackClass, ctor, ptr);
        if (!callbackObj) {
            UE_LOG(LogInit, Error, TEXT("Push failed to create PushCallback instance"));
            return nullptr;
        }

        return callbackObj;
    }

    jobject GetJavaListener(JNIEnv* jenv, jlong ptr) {
        jclass listenerClass = FAndroidApplication::FindJavaClassGlobalRef("com/tencent/qcloud/tim/push/ue/UEPushListener");
        if (!listenerClass) {
            UE_LOG(LogInit, Error, TEXT("Push failed to find PushListener class"));
            return nullptr;
        }

        jmethodID ctor = jenv->GetMethodID(listenerClass, "<init>", "(J)V");
        if (!ctor) {
            UE_LOG(LogInit, Error, TEXT("Push failed to get PushListener constructor"));
            return nullptr;
        }

        jobject listenerObj = jenv->NewObject(listenerClass, ctor, ptr);
        if (!listenerObj) {
            UE_LOG(LogInit, Error, TEXT("Push failed to create PushListener instance"));
            return nullptr;
        }

        return listenerObj;
    }
    
    JNI_METHOD void Java_com_tencent_qcloud_tim_push_ue_UEPushCallback_nativeOnSuccess(JNIEnv* jenv, jobject thiz, jlong nativePtr, jobject object) {
        if (!jenv || !nativePtr) {
            UE_LOG(LogTemp, Error, TEXT("Push invalid JNIEnv or nativePtr in nativeOnSuccess"));
            return;
        }
    
        PushBaseCallback* callback = reinterpret_cast<PushBaseCallback*>(nativePtr);
        if (callback) {
            if (callback->IsValueCallback()) {
                PushValueCallback<FString>* valueCallback = reinterpret_cast<PushValueCallback<FString>*>(callback);
                FString objectStr = "";
                if (object) {
                    jstring jobject = static_cast<jstring>(object);
                    objectStr = JStringToFString(jenv, jobject);
                }
                valueCallback->OnSuccess(objectStr);
            } else {
                PushCallback* pushcallback = reinterpret_cast<PushCallback*>(callback);
                pushcallback->OnSuccess();
            }
        } else {
            UE_LOG(LogTemp, Error, TEXT("Push invalid callback type in nativeOnSuccess"));
        }
    }
    
    JNI_METHOD void Java_com_tencent_qcloud_tim_push_ue_UEPushCallback_nativeOnError(JNIEnv* jenv, jobject thiz, jlong nativePtr, jint code, jstring desc, jobject object) {
        if (!jenv || !nativePtr) {
            UE_LOG(LogTemp, Error, TEXT("Push invalid JNIEnv or nativePtr in nativeOnError"));
            return;
        }
    
        PushBaseCallback* callback = reinterpret_cast<PushBaseCallback*>(nativePtr);
        if (callback) {
            FString ErrorMsg = JStringToFString(jenv, desc);
            if (callback->IsValueCallback()) {
                PushValueCallback<FString>* valueCallback = reinterpret_cast<PushValueCallback<FString>*>(callback);
                valueCallback->OnError(code, ErrorMsg);
            } else {
                PushCallback* pushcallback = reinterpret_cast<PushCallback*>(callback);
                pushcallback->OnError(code, ErrorMsg);
            }
        } else {
            UE_LOG(LogTemp, Error, TEXT("Push invalid callback type in nativeOnError"));
        }
    }
    
    JNI_METHOD void Java_com_tencent_qcloud_tim_push_ue_UEPushListener_nativeOnRecvPushMessage(JNIEnv* jenv, jobject thiz, jlong nativePtr, jobject object) {
        if (!jenv || !nativePtr) {
            UE_LOG(LogTemp, Error, TEXT("Push invalid JNIEnv or nativePtr in nativeOnRecvPushMessage"));
            return;
        }
    
        PushListener* listener = reinterpret_cast<PushListener*>(nativePtr);
        if (!listener) {
            UE_LOG(LogTemp, Error, TEXT("Push invalid listener in nativeOnRecvPushMessage"));
            return;
        }
    
        jclass cls = jenv->GetObjectClass(object);
        if (!cls) {
            UE_LOG(LogTemp, Error, TEXT("Push failed to get object class in nativeOnRecvPushMessage"));
            return;
        }

        jstring jTitle = jenv->NewStringUTF("");
        jfieldID fidTitle = jenv->GetFieldID(cls, "title", "Ljava/lang/String;");
        if(fidTitle) {
            jTitle = (jstring)jenv->GetObjectField(object, fidTitle);
        }

        jstring jDesc = jenv->NewStringUTF("");
        jfieldID fidDesc = jenv->GetFieldID(cls, "desc", "Ljava/lang/String;");
        if(fidDesc) {
            jDesc = (jstring)jenv->GetObjectField(object, fidDesc);
        }

        jstring jExt = jenv->NewStringUTF("");
        jfieldID fidExt = jenv->GetFieldID(cls, "ext", "Ljava/lang/String;");
        if(fidExt) {
            jExt = (jstring)jenv->GetObjectField(object, fidExt);
        }

        jstring jMessageID = jenv->NewStringUTF("");
        jfieldID fidMessageID = jenv->GetFieldID(cls, "messageID", "Ljava/lang/String;");
        if(fidMessageID) {
            jMessageID = (jstring)jenv->GetObjectField(object, fidMessageID);
        }
        
        FString title = JStringToFString(jenv, jTitle);
        FString desc = JStringToFString(jenv, jDesc);
        FString ext = JStringToFString(jenv, jExt);
        FString messageID = JStringToFString(jenv, jMessageID);
    
        PushMessage message(title, desc, ext, messageID);
        UE_LOG(LogTemp, Error, TEXT("Push message: %s, %s, %s, %s"), *title, *desc, *ext, *messageID);
        
        listener->OnRecvPushMessage(message);
    
        jenv->DeleteLocalRef(jTitle);
        jenv->DeleteLocalRef(jDesc);
        jenv->DeleteLocalRef(jExt);
        jenv->DeleteLocalRef(jMessageID);
        jenv->DeleteLocalRef(cls);
    }
    
    JNI_METHOD void Java_com_tencent_qcloud_tim_push_ue_UEPushListener_nativeOnRevokePushMessage(JNIEnv* jenv, jobject thiz, jlong nativePtr, jobject object) {
        if (!jenv || !nativePtr) {
            UE_LOG(LogTemp, Error, TEXT("Push invalid JNIEnv or nativePtr in nativeOnRevokePushMessage"));
            return;
        }
    
        PushListener* listener = reinterpret_cast<PushListener*>(nativePtr);
        if (!listener) {
            UE_LOG(LogTemp, Error, TEXT("Push invalid listener in nativeOnRevokePushMessage"));
            return;
        }
    
        FString messageID;
        if (object) {
            // 从object中提取字符串值
            jstring jobject = static_cast<jstring>(object);
            messageID = JStringToFString(jenv, jobject);
        }
    
        if (listener) {
           listener->OnRevokePushMessage(messageID);
        }
    }
    
    JNI_METHOD void Java_com_tencent_qcloud_tim_push_ue_UEPushListener_nativeOnNotificationClicked(JNIEnv* jenv, jobject thiz, jlong nativePtr, jobject object) {
        if (!jenv || !nativePtr) {
            UE_LOG(LogTemp, Error, TEXT("Push invalid JNIEnv or nativePtr in nativeOnNotificationClicked"));
            return;
        }
    
        PushListener* listener = reinterpret_cast<PushListener*>(nativePtr);
        if (!listener) {
            UE_LOG(LogTemp, Error, TEXT("Push invalid listener in nativeOnNotificationClicked"));
            return;
        }
    
        FString ext;
        if (object) {
            // 从object中提取字符串值
            jstring jobject = static_cast<jstring>(object);
            ext = JStringToFString(jenv, jobject);
        }
    
        if (listener) {
            listener->OnNotificationClicked(ext);
        }
    }
    
}  // namespace Util
}  // namespace Convert
}  // namespace Push
#endif  // PLATFORM_ANDROID