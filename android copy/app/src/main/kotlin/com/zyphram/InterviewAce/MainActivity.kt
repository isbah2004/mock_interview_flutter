package com.zyphram.InterviewAce

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.facebook.ads.*
import android.util.Log

class MainActivity : FlutterActivity() {
    private val CHANNEL = "facebook_interstitial_ads"
    private val TAG = "InterstitialAd"
    
    private var interstitialAd: InterstitialAd? = null
    private lateinit var methodChannel: MethodChannel

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "initialize" -> {
                    initializeFacebookAds()
                    result.success(null)
                }
                "loadAd" -> {
                    val placementId = call.argument<String>("placementId")
                    if (placementId != null) {
                        loadInterstitialAd(placementId)
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGUMENT", "Placement ID is required", null)
                    }
                }
                "showAd" -> {
                    val shown = showInterstitialAd()
                    result.success(shown)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun initializeFacebookAds() {
        try {
            // Initialize Facebook Audience Network
            AudienceNetworkAds.initialize(this)
            
            // Add test device for testing (your device hash from logs)
            AdSettings.addTestDevice("0bf49c20-eb2f-432b-939c-b79a730156f7")
            
            // Enable test mode for debugging
            AdSettings.setTestMode(true)
            
            Log.d(TAG, "Facebook Audience Network initialized successfully")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to initialize Facebook Audience Network: ${e.message}")
        }
    }

    private fun loadInterstitialAd(placementId: String) {
        try {
            interstitialAd = InterstitialAd(this, placementId)
            
            val interstitialAdListener = object : InterstitialAdListener {
                override fun onInterstitialDisplayed(ad: Ad) {
                    Log.d(TAG, "Interstitial ad displayed.")
                    methodChannel.invokeMethod("onAdImpression", null)
                }

                override fun onInterstitialDismissed(ad: Ad) {
                    Log.d(TAG, "Interstitial ad dismissed.")
                    methodChannel.invokeMethod("onAdClosed", null)
                }

                override fun onError(ad: Ad, adError: AdError) {
                    Log.e(TAG, "Interstitial ad failed to load: ${adError.errorMessage}")
                    Log.e(TAG, "Error code: ${adError.errorCode}")
                    
                    // Handle specific error codes
                    when (adError.errorCode) {
                        2 -> {
                            Log.w(TAG, "Service temporarily unavailable - this is common with test ads")
                            methodChannel.invokeMethod("onAdFailedToLoad", "Test ad service temporarily unavailable")
                        }
                        1001 -> {
                            Log.w(TAG, "No ad available - trying again later")
                            methodChannel.invokeMethod("onAdFailedToLoad", "No ad available")
                        }
                        else -> {
                            methodChannel.invokeMethod("onAdFailedToLoad", adError.errorMessage)
                        }
                    }
                }

                override fun onAdLoaded(ad: Ad) {
                    Log.d(TAG, "Interstitial ad is loaded and ready to be displayed!")
                    methodChannel.invokeMethod("onAdLoaded", null)
                }

                override fun onAdClicked(ad: Ad) {
                    Log.d(TAG, "Interstitial ad clicked!")
                    methodChannel.invokeMethod("onAdClicked", null)
                }

                override fun onLoggingImpression(ad: Ad) {
                    Log.d(TAG, "Interstitial ad impression logged!")
                }
            }
            
            interstitialAd?.loadAd(
                interstitialAd?.buildLoadAdConfig()
                    ?.withAdListener(interstitialAdListener)
                    ?.build()
            )
        } catch (e: Exception) {
            Log.e(TAG, "Error loading interstitial ad: ${e.message}")
            methodChannel.invokeMethod("onAdFailedToLoad", e.message)
        }
    }

    private fun showInterstitialAd(): Boolean {
        return try {
            if (interstitialAd?.isAdLoaded == true) {
                interstitialAd?.show()
                Log.d(TAG, "Interstitial ad shown")
                true
            } else {
                Log.d(TAG, "The interstitial ad wasn't ready yet.")
                false
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error showing interstitial ad: ${e.message}")
            false
        }
    }

    override fun onDestroy() {
        interstitialAd?.destroy()
        super.onDestroy()
    }
}
