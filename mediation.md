# AdMob Mediation Plan for Feelong

## Recommended Networks (start with 3)

1. **Meta Audience Network** -- strong eCPMs for wellness apps
2. **Unity Ads** -- great for rewarded video
3. **AppLovin** -- solid across all formats

## Implementation Phases

### Phase 1: AdMob Console (no code)

- Enable mediation for all 6 existing ad units
- Create mediation groups per format/platform
- Register with Meta, Unity, AppLovin and link accounts
- Use waterfall initially, switch to Open Bidding later

### Phase 2: iOS Native (`ios/Podfile`)

- Add adapter pods: `GoogleMobileAdsMediationFacebook`, `GoogleMobileAdsMediationUnity`, `GoogleMobileAdsMediationAppLovin`
- Add partner SKAdNetwork IDs to `Info.plist` (Google publishes a consolidated list)
- Add `FacebookAppID` to `Info.plist`

### Phase 3: Android Native (`android/app/build.gradle.kts`)

- Add Gradle dependencies: `com.google.ads.mediation:facebook`, `unity`, `applovin`
- Add ProGuard keep rules for all 3 SDKs (critical -- release builds use minification)
- Add AppLovin SDK key to `AndroidManifest.xml`

### Phase 4: Dart Changes (minimal)

- No changes to ad IDs or ad loading logic -- mediation is transparent
- Add `onPaidEvent` callback for revenue-per-network logging
- Add debug Ad Inspector trigger (`MobileAds.instance.openAdInspector()`)

### Phase 5: Testing

- Use AdMob Ad Inspector to verify adapter initialization
- Test consent flow includes all networks
- Monitor fill rates and eCPMs in AdMob Mediation Report post-launch

### Key Points

- **No new Flutter packages needed** -- adapters are native-only (CocoaPods + Gradle)
- **Existing Dart code mostly unchanged** -- mediation is handled at SDK level
- **App size will increase ~10-15 MB** from the 3 adapter SDKs
- **ProGuard rules are critical** to avoid Android release crashes

---

## Adding a Mediation Network in AdMob Console

### Step 1: Create a Mediation Group

1. Go to **admob.google.com** -> **Mediation** (left sidebar)
2. Click **Create Mediation Group**
3. Choose **ad format** (Banner, Interstitial, or Rewarded)
4. Select **platform** (iOS or Android)
5. Name the group and click **Add Ad Units** -> select your Feelong ad unit

### Step 2: Add Ad Sources (Networks)

1. In the mediation group, you'll see the **Waterfall** section
2. Click **Add Ad Source**
3. Two options:
   - **Bidding** -- networks compete in real-time auction (higher revenue, recommended)
   - **Waterfall** -- you set manual eCPM floors and priority order
4. Select a network (e.g., Meta Audience Network, Unity Ads, AppLovin)
5. You'll be prompted to:
   - **Sign in / link** your account with that network (OAuth or API key)
   - Enter the **Placement ID** you created in that network's dashboard

### Step 3: Configure Each Network

For each network you add, you need to have already:

1. **Created an account** on the network's own platform (e.g., business.facebook.com for Meta)
2. **Created an app** in their dashboard
3. **Created placement IDs** for each ad format

Then enter those IDs in the AdMob mediation group mapping.

### Step 4: Enable Optimization (Optional)

- Toggle **Ad source optimization** to let AdMob automatically adjust eCPM floors based on historical data
- This requires linking the network account via API key

### Order of Operations

1. Register on each network's site -> create app -> create placements
2. Come back to AdMob -> create mediation groups -> add those networks as ad sources
3. Add native SDKs to your app (the CocoaPods/Gradle steps from the plan)
4. Test with Ad Inspector

---

## Network Setup Guides

### 1. Meta Audience Network

#### Create Account & Placements

1. Go to **business.facebook.com** -> Monetization Manager
2. Click **Create Property** -> enter "Feelong" as the app name
3. Link your app store listings (iOS + Android)
4. Create **3 placements** per platform:
   - Banner -> note the Placement ID
   - Interstitial -> note the Placement ID
   - Rewarded Video -> note the Placement ID

#### Link in AdMob

1. AdMob -> **Mediation** -> your mediation group
2. **Add Ad Source** -> select **Meta Audience Network**
3. First time: click **Sign in** to link your Meta business account
4. Enter the **Placement ID** for the matching format
5. Set an **eCPM floor** (start with $1-2 for banner, $5-10 for rewarded) or enable optimization
6. Repeat for each mediation group (per format/platform)

#### Get API Key for Optimization

1. In Meta Business Settings -> System Users -> create a system user
2. Generate a token with `read_audience_network_insights` permission
3. Paste the token in AdMob's Meta ad source settings to enable **automatic eCPM optimization**

---

### 2. Unity Ads

#### Create Account & Placements

1. Go to **dashboard.unity.com** -> Monetization -> **Ads**
2. Click **Add Project** -> name it "Feelong"
3. Add **two platforms** (iOS + Android) -> note the **Game ID** for each
4. Go to **Ad Units** -> create 3 per platform:
   - Banner -> note the Ad Unit ID
   - Interstitial -> note the Ad Unit ID
   - Rewarded -> note the Ad Unit ID

#### Link in AdMob

1. AdMob -> **Mediation** -> your mediation group
2. **Add Ad Source** -> select **Unity Ads**
3. Enter:
   - **Game ID** (different for iOS and Android)
   - **Ad Unit ID** for the matching format
4. Set eCPM floor or enable optimization
5. Repeat for each group

#### Get API Key for Optimization

1. Unity Dashboard -> **API Management** -> create an API key
2. Note the **Organization Core ID** (Settings -> Organization)
3. Enter both in AdMob's Unity ad source settings

---

### 3. AppLovin

#### Create Account & Placements

1. Go to **dash.applovin.com** -> sign up
2. Note your **SDK Key** (Account -> Keys -> SDK Key) -- you'll need this in your app code
3. Go to **Manage** -> **Ad Units** -> create ad units:
   - Banner -> note the **Zone ID**
   - Interstitial -> note the **Zone ID**
   - Rewarded -> note the **Zone ID**
4. Add your app (iOS + Android) with store URLs

#### Link in AdMob

1. AdMob -> **Mediation** -> your mediation group
2. **Add Ad Source** -> select **AppLovin**
3. Enter:
   - **SDK Key**
   - **Zone ID** for the matching format
4. Set eCPM floor or enable optimization
5. Repeat for each group

#### Get API Key for Optimization

1. AppLovin Dashboard -> **Account** -> **Keys**
2. Copy the **Report Key**
3. Enter it in AdMob's AppLovin ad source settings

---

## Summary Checklist

| Network | You Need | Where to Get It |
|---------|----------|----------------|
| Meta | Placement IDs, API Token | Monetization Manager, Business Settings |
| Unity | Game IDs, Ad Unit IDs, API Key | Unity Dashboard |
| AppLovin | SDK Key, Zone IDs, Report Key | AppLovin Dashboard |
