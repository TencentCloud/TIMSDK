-keep class com.baidu.** {*;}
-keep class vi.com.** {*;}
-keep class com.baidu.vi.** {*;}
#-keep class com.tencent.flutter.tuikit.** {*;}
-dontwarn com.baidu.**
#-ignorewarnings
#-keepattributes *Annotation*
#-keepattributes Exceptions
#-keepattributes InnerClasses
#-keepattributes Signature
#-keepattributes SourceFile,LineNumberTable
#-keep class com.hianalytics.android.**{*;}
#-keep class com.huawei.updatesdk.**{*;}
#-keep class com.huawei.hms.**{*;}
#-keep class com.xiaomi.**{*;}
#-dontwarn com.meizu.cloud.pushsdk.**
#-keep class com.meizu.cloud.pushsdk.**{*;}
#-dontwarn com.vivo.push.**
#-keep class com.vivo.push.**{*; }
#-keep class com.vivo.vms.**{*; }
#-keep public class * extends android.app.Service
#-keep class com.heytap.mcssdk.** {*;}
#-keep class com.heytap.msp.push.** { *;}