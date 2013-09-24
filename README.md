AppLovinCoronaPlugin
====================

Download this repository and paste the contents over your Corona Enterprise project.  Then:

1. Download the android and iOS SDKs from here: https://applovin.com/integration
2. Paste the iOS .h and .a files into the ios/Plugin folder
3. Paste the android .jar file into android/libs
4. Add the following to your AndroidManifest file:
   <meta-data android:name="applovin.sdk.key" android:value="<SDK_KEY>" />
   <activity android:name="com.applovin.adview.AppLovinInterstitialActivity" />
5. Replace <SDK_KEY> above with the key from your applovin.com account
