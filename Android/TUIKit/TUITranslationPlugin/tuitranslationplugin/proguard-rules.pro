# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

# 保护代码中的Annotation不被混淆
# 这在JSON实体映射时非常重要，比如fastJson
-keepattributes *Annotation*

# 避免混淆泛型
# 这在JSON实体映射时非常重要，比如fastJson
-keepattributes Signature

# 抛出异常时保留代码行号
-keepattributes SourceFile,LineNumberTable
-ignorewarnings

# 保留方法参数名字
-keepparameternames

# 避免资源混淆
-keep class **.R$* {*;}

# 不混淆指定的包名称，防止不同的库混淆后的类名冲突，比如都是 a.a.a.a
-keeppackagenames com.tencent.qcloud.tuikit.*

# 以下类不混淆
-keep public class com.tencent.qcloud.tuikit.tuipoll.bean.PollBean{*;}


