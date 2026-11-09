# Proguard rules for FinWise Android Application
-keep class com.finwise.app.models.** { *; }
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

