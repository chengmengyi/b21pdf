-keepattributes Signature

# Apache POI references some desktop/JAXB classes that are not used on Android
# in this project, but R8 still sees those references during shrinking.
-dontwarn java.awt.**
-dontwarn javax.xml.bind.**

# ironSource requires extra keep rules when minify/shrink is enabled.
-keepclassmembers class com.ironsource.sdk.controller.IronSourceWebView$JSInterface {
    public *;
}
-keepclassmembers class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}
-keepattributes JavascriptInterface
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
-keep public class com.google.android.gms.ads.** {
   public *;
}
-keep class com.google.android.gms.appset.** { *; }
-keep class com.google.android.gms.tasks.** { *; }
-keep class com.ironsource.adapters.** { *; }
-keep class com.ironsource.** { *; }
-dontwarn com.ironsource.**
-dontwarn com.unity3d.ironsourceads.**
-keep class com.unity3d.ironsourceads.** { *; }
-dontwarn com.unity3d.mediation.**
-keep class com.unity3d.mediation.** { *; }
-dontwarn com.iab.omid.**
-keep class com.iab.omid.** { *; }
