AdMob Production Readiness Guide

Purpose

This document explains the steps required to make the app's AdMob integration ready for production: account/config setup, code changes, privacy & policy requirements, testing, release checklist, and monitoring.

Quick checklist

- [ ] AdMob account created and app registered in AdMob
- [ ] Production ad unit IDs created and saved in config (not hard-coded)
- [ ] App-ads.txt published on the app website / domain
- [ ] AdMob App ID set in AndroidManifest.xml and iOS Info.plist
- [ ] GDPR/CCPA/COPPA consent flow implemented and tested
- [ ] Test devices removed & test ad units used only in staging/dev
- [ ] Logging + analytics events implemented (ad_loaded, ad_failed, ad_shown, ad_dismissed)
- [ ] Graceful handling of no-fill and error codes (exponential backoff / retry limits)
- [ ] Frequency caps and UX rules validated (no disruptive ads)
- [ ] ProGuard/R8 rules added for Android release
- [ ] Crashlytics + remote config for ad toggles enabled
- [ ] Privacy policy and AdMob policy compliance confirmed

High-level steps

1. AdMob account & app registration

   - Create or use an existing AdMob account.
   - Add your app (package name for Android, bundle id for iOS) in the AdMob console.
   - Create Interstitial ad units (and any other units you plan to use: banner, rewarded).
   - Copy production ad unit IDs into your app configuration (do NOT check them into public repos). Use environment-specific config or CI secrets.

2. Reserve test ad units & device IDs for development

   - Use Google's official test ad unit ids (e.g. ca-app-pub-3940256099942544/1033173712 for interstitial) for local/dev testing.
   - Register test device IDs during development only. Remove test device registration from production builds.

3. App manifest configuration

   - Android (AndroidManifest.xml): add the AdMob App ID meta-data entry under application tag.
     Example:
     <meta-data android:name="com.google.android.gms.ads.APPLICATION_ID" android:value="ca-app-pub-xxxxxxxx~yyyyyyyy"/>
   - iOS (Info.plist): add GADApplicationIdentifier key with the App ID.

4. Code-level best practices (how it maps to this repo)

   - Initialization: call MobileAds.instance.initialize() once at app startup (splash/main). Log initialization status.
   - Use a single source of truth for ad unit ids and AppSecrets. In this repo, update `lib/core/constants/app_secrets.dart` or wire in a secure env-driven config for production.
   - Keep test ad unit ids for dev only. Example in this repo:
     - `lib/features/ads/data/datasources/admob_datasource.dart` currently defaults to Google's interstitial test id when an empty id is passed. In production change to read from secure config.
   - Use a service layer to gate when ads are shown: `lib/features/ads/presentation/services/ad_integration_service.dart` is the right place to keep UX rules (only show post-interview, frequency caps, session counters).
   - Add production-level logging and analytics around ad lifecycle in `AdMobDataSource`, `AdIntegrationService`, and `AdService`.
   - Use remote config or feature flags to toggle ads remotely if you need to disable them quickly.

5. Consent & privacy

   - Implement consent collection for GDPR and mechanisms for CCPA.
   - If the app serves kids, comply with COPPA and set appropriate flags in ad requests.
   - Provide a clear privacy policy that explains ad serving and user data usage and link it in the app store listing and inside the app.

6. Error handling and retry strategy

   - On load failures, log the LoadAdError code & message.
   - Implement backoff and caps: e.g., try up to N times with exponential backoff, and stop attempting for M minutes after repeated failures.
   - Gracefully degrade when ads are not available (do not crash; proceed without blocking UX).

7. UX rules and frequency

   - Enforce frequency caps (e.g., at most 1 interstitial every 3 minutes or 1 per interview completion). Keep these rules configurable.
   - Avoid showing ads during critical flows. The current repo logic aims to show only post-interview; confirm placement across screens.

8. Testing matrix

   - Test flows on both physical devices and emulators for Android and iOS.
   - Test with various network conditions (offline, slow networks, captive portals).
   - Test with Google Play Services out-of-date (physical devices) to observe fallback behavior.
   - Validate removal of test device registration and replacement of test ad unit with production units in a staging channel prior to production release.

9. Build & release steps

   - Ensure the AdMob App ID and production ad unit ids are present in release manifests and replaced from secure config.
   - Remove all test-device registrations and Google's test ad unit usage from release builds.
   - Add ProGuard/R8 rules recommended by the google_mobile_ads docs if you use code shrinking.
   - Build an internal/staging release and verify ad deliverability before full rollout.

10. Monitoring & observability

    - Send analytics events for ad_loaded, ad_failed (include error code), ad_shown, ad_dismissed, and ad_clicked.
    - Surface a small set of telemetry to Crashlytics (non-sensitive) for ad failures that correlate with crashes.
    - Keep logs (AppLogger) and capture sample logcat outputs for Android to inspect LoadAdError codes.

11. Compliance & policy
    - Review AdMob program policies and ensure ad placements and content comply.
    - Ensure the app's privacy policy and data handling disclosures are linked in app stores and inside the app.
    - Implement opt-out mechanisms if legally required.

Repo-specific action items (what to change in this repo before production)

- Replace test ad unit id usage with production ids in a secure config
  - Files to update or verify:
    - `lib/core/constants/app_secrets.dart` — add production `adUnitIds` keys or better: wire environment-based config.
    - `lib/features/ads/data/datasources/admob_datasource.dart` — ensure it reads production adUnitId from config for production, and only uses Google test ID in dev when AppSecrets.isProduction == false.
    - `lib/features/ads/presentation/services/ad_integration_service.dart` — validate that the ad unit passed is the production id (or comes from config) and that the UX gating is correct.
- Initialization
  - Ensure `MobileAds.instance.initialize()` is called once at app start and confirm initialization success is logged. Move initialization to a central startup flow if needed.
- Test devices
  - Remove or conditionally register test device ids only when not in production.
- Feature flag / remote toggle
  - Add a remote config flag to disable ads instantly if something goes wrong.
- Logging & analytics
  - Add analytics events and hook AdMob lifecycle logs into your analytics (e.g., Firebase Analytics / custom backend).
- Privacy & Consent
  - Add a consent collection UI and store consent state. Ensure RequestConfiguration and ad requests respect consent.
- QA
  - Create an internal build (staging) that uses production ad unit ids but with a limited audience or a special debug build that still routes to test ad units controlled by remote config.

Sample logs you should see in a working staging run

- MobileAds initialization
  - "AdMobDataSource: MobileAds initialized: InitializationStatus(...)
  - "AdMobDataSource: request configuration updated"
- Load attempt
  - "AdMobDataSource: loading interstitial for adUnitId: <id>"
  - "AdMobDataSource: interstitial loaded for <id>" OR
  - "AdMobDataSource: interstitial failed to load for <id> - code: <code>, message: <message>"
- Show
  - "AdIntegrationService: ad loaded, showing for post*interview*<type>"
  - "AdIntegrationService: ad shown for post*interview*<type>"

Common LoadAdError codes to expect and next steps

- 0 (internal error): often transient; check Play Services & SDK versions, and capture full logcat. Use backoff and retries.
- 1 (invalid request): usually wrong ad unit id or manifest/App ID issues. Verify App ID in Manifest/Info.plist and ad unit id correctness.
- 2 (network error): retry with backoff; inform analytics.
- 3 (no fill): normal when demand is low; handle gracefully and do not retry aggressively.
- 4-... other errors: consult google_mobile_ads docs and log full messages.

Staging → Production rollout checklist (short)

1. Finalize ad unit IDs in secure config (not in source control). Ensure `AppSecrets.isProduction = true` or environment switch.
2. Remove test device IDs and test ad unit usage.
3. Confirm AdMob App ID present in AndroidManifest.xml and Info.plist.
4. Perform internal/staging release and verify ads appear and logs show successful loads.
5. Monitor ad load rates and errors via logs/analytics for a few days after rollout.
6. If problems appear, disable ads via remote flag and debug using logs and the AdMob console.

Appendix — Useful commands & quick checks

- Run flutter analyze locally:

```bash
flutter analyze
```

- Run app on device with verbose logging (Android):

```bash
flutter run -d <device-id> -v
# or uses adb logcat for longer sessions
adb logcat -s FlutterActivity *:S | grep -i "AdMobDataSource\|AdIntegrationService\|Load failed"
```

- If you see repeated LoadAdError code 0 on physical devices, capture full logcat and verify Google Play services are up-to-date on device.

Notes & final advice

- Never ship test ad unit ids or test-device registrations in production builds.
- Use remote flags so you can instantly disable ads if policy or technical issues appear.
- Instrument ad lifecycle events; these are invaluable for diagnosing no-fill and backend policy-related issues.
- Follow AdMob policies closely. Non-compliance can lead to account suspension.

If you want, I can:

- Add a staging-only debug screen that shows ad lifecycle state (loaded/failed/show) and last LoadAdError details.
- Add remote-config wiring for toggling ads.
- Add a small internal test harness to flip between test and production ad unit ids at runtime for QA.
