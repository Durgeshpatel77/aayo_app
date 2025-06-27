#########################
# Razorpay SDK ProGuard #
#########################

# Keep all Razorpay classes
-keep class com.razorpay.** { *; }

# Keep all annotations Razorpay might use
-keepattributes *Annotation*
-keep class proguard.annotation.Keep
-keep class proguard.annotation.KeepClassMembers

# Keep Google Pay classes (referenced by Razorpay)
-keep class com.google.android.apps.nbu.paisa.inapp.client.api.** { *; }
-dontwarn com.google.android.apps.nbu.paisa.inapp.client.api.**

# Don't warn about missing classes (optional safety)
-dontwarn com.razorpay.**

# Optional (you can uncomment for testing)
# -dontnote
# -dontwarn
