# iOS Distribution via TestFlight

This is the one-time setup that turns on `.github/workflows/release-testflight.yml`
so pushing a `v*.*.*` tag (the same tag that builds the Android APK) also builds
a signed iOS `.ipa` and uploads it to TestFlight.

## Why this isn't "just build an iOS APK"

Android lets you build an unsigned `.apk`, host it anywhere, and let anyone
install it directly ("unknown sources"). iOS has no equivalent: every app
that runs on a real iPhone must be signed by a certificate tied to a paid
**Apple Developer Program** account, and the installing device has to be
authorized one of these ways:

| Method | Who can install | Cost / review |
|---|---|---|
| **TestFlight** (what this workflow does) | Anyone with an invite, or anyone with the link once you turn on the *Public Link* | $99/yr account; internal testers install instantly, external testers need a quick Apple "Beta App Review" (usually well under 48h) |
| Ad-hoc `.ipa` | Only iPhones whose UDID was registered in the provisioning profile beforehand (100/yr cap) | $99/yr account, no review, but not usable by the general public |
| App Store | Anyone | $99/yr account, full App Review (days, can be rejected) |

TestFlight is the closest thing to "download and install like Android," so
that's what `release-testflight.yml` targets. Builds expire after 90 days —
you'll want to cut a new release at least that often to keep testers on a
working build (a normal Takwa release tag already does this).

## One-time setup

### 1. Enroll in the Apple Developer Program
https://developer.apple.com/programs/ — $99/year, needs an Apple ID.
Note your **Team ID** (Membership page, or top-right of developer.apple.com
once enrolled) — that's `APPLE_TEAM_ID` below.

### 2. Register the App ID
In [Certificates, Identifiers & Profiles → Identifiers](https://developer.apple.com/account/resources/identifiers/list),
create an App ID with bundle identifier **`com.takwa`** (must match
`PRODUCT_BUNDLE_IDENTIFIER` in `apps/mobile/ios/Runner.xcodeproj`).

### 3. Create an Apple Distribution certificate

You need a `.p12` file (private key + signed certificate bundled together).
Apple's site only ever hands you the signed *certificate* half — you always
generate the *key* + CSR yourself and combine them locally. Pick whichever
of these two paths matches what you have available; both produce the same
`.p12`.

**No Mac needed — OpenSSL (works on Linux/Windows/macOS):**
```bash
# 1. Generate a private key
openssl genrsa -out ios_distribution.key 2048

# 2. Generate a CSR from it (email/name can be anything identifying)
openssl req -new -key ios_distribution.key -out ios_distribution.csr \
  -subj "/emailAddress=you@example.com/CN=Your Name/C=US"
```
Upload `ios_distribution.csr` at
[Certificates, Identifiers & Profiles → Certificates → +](https://developer.apple.com/account/resources/certificates/list),
choosing type **Apple Distribution**. Download the issued certificate
(`distribution.cer`, DER format), then:
```bash
# 3. Convert Apple's .cer to PEM
openssl x509 -in distribution.cer -inform DER -out ios_distribution.pem -outform PEM

# 4. Bundle your key + Apple's certificate into a .p12, setting an export password
openssl pkcs12 -export \
  -inkey ios_distribution.key -in ios_distribution.pem \
  -out ios_distribution.p12 -password pass:'CHOOSE_A_PASSWORD'
```
That password is `APPLE_DIST_CERTIFICATE_PASSWORD`.

**On a Mac instead:** Keychain Access → Certificate Assistant → Request a
Certificate from a Certificate Authority (produces the CSR), upload it in
the same Certificates page above, then double-click the downloaded
certificate to install it into Keychain Access, find it under
**My Certificates**, right-click → **Export...** as `.p12`, setting a
password there.

Either way, base64-encode the final `.p12` for GitHub Secrets:
```bash
base64 -w0 ios_distribution.p12       # Linux
base64 -i ios_distribution.p12 | pbcopy   # macOS
```
That output is `APPLE_DIST_CERTIFICATE_BASE64`.

### 4. Create an App Store provisioning profile
In [Certificates, Identifiers & Profiles → Profiles](https://developer.apple.com/account/resources/profiles/list),
create a profile of type **App Store Connect** (formerly "App Store"),
selecting the `com.takwa` App ID and the distribution certificate from
step 3. Download it, then:

```bash
base64 -i Takwa_AppStore.mobileprovision | pbcopy   # macOS
base64 -w0 Takwa_AppStore.mobileprovision           # Linux
```

That's `APPLE_PROVISIONING_PROFILE_BASE64`. Also note the profile's exact
**Name** as you typed it when creating it — that's `APPLE_PROVISIONING_PROFILE_NAME`
(the workflow's `ExportOptions.plist` looks up the profile by this name, not
its filename).

### 5. Create an App Store Connect API key
In [App Store Connect → Users and Access → Integrations → App Store Connect API](https://appstoreconnect.apple.com/access/integrations/api),
create a key with **App Manager** access. Apple lets you download the
`.p8` private key file **exactly once**, so save it somewhere safe. Note:

- `APP_STORE_CONNECT_API_KEY_ID` — the Key ID shown in the list
- `APP_STORE_CONNECT_API_ISSUER_ID` — the Issuer ID shown above the key list
- `APP_STORE_CONNECT_API_KEY_P8` — the **raw contents** of the downloaded
  `AuthKey_<key_id>.p8` file, pasted as-is (not base64-encoded):
  ```bash
  cat AuthKey_XXXXXXXXXX.p8 | pbcopy   # macOS
  cat AuthKey_XXXXXXXXXX.p8            # Linux — copy the output
  ```

### 6. Create the app record in App Store Connect
In [App Store Connect → My Apps → +](https://appstoreconnect.apple.com/apps),
create a new app with bundle ID `com.takwa`. The workflow can only upload a
build once this app record exists.

### 7. Add the GitHub repo secrets
In the repo's **Settings → Secrets and variables → Actions**, add:

| Secret | Value |
|---|---|
| `APPLE_TEAM_ID` | from step 1 |
| `APPLE_DIST_CERTIFICATE_BASE64` | from step 3 |
| `APPLE_DIST_CERTIFICATE_PASSWORD` | the `.p12` export password from step 3 |
| `APPLE_PROVISIONING_PROFILE_BASE64` | from step 4 |
| `APPLE_PROVISIONING_PROFILE_NAME` | the profile's Name from step 4 |
| `APP_STORE_CONNECT_API_KEY_ID` | from step 5 |
| `APP_STORE_CONNECT_API_ISSUER_ID` | from step 5 |
| `APP_STORE_CONNECT_API_KEY_P8` | from step 5 |

`SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_WEB_CLIENT_ID`, and
`SUPABASE_IOS_CLIENT_ID` are reused from the existing Android release setup
— nothing new needed there.

Until all eight Apple secrets above are present, `release-testflight.yml`
detects that in its `check-secrets` job and **skips the build with a
warning** instead of failing your release — pushing a normal `v*.*.*` tag
stays safe to do at any point during this setup.

## Running it

- **Automatic**: push a tag like `v1.0.26` — the same tag `release-apk.yml`
  already reacts to.
- **Manual**: Actions tab → *Release iOS to TestFlight* → *Run workflow*.

A successful run uploads the build to App Store Connect; it then takes
Apple roughly 10–30 minutes to finish processing before it's selectable
under the app's **TestFlight** tab.

## Getting it to your users

1. **Internal testers** (up to 100 people on your App Store Connect team):
   add them under TestFlight → Internal Testing — they get access
   immediately, no Apple review.
2. **External testers / public link**: create an External Testing group,
   add the build, and submit for **Beta App Review** (a lighter check than
   full App Review, typically resolved within a day). Once approved, turn
   on **Public Link** — anyone with that link can install via the
   TestFlight app, no invite needed. This is the direct equivalent of the
   Android APK link on the website.

### Wiring the Public Link into takwa-app.vercel.app

Once you have that Public Link (or, later, an App Store link), set it as
the `NEXT_PUBLIC_IOS_APP_URL` environment variable on the web app's Vercel
project (same place `NEXT_PUBLIC_APK_*` already lives) and redeploy. The
Download section on the site (`apps/web/src/components/landing/DownloadSection.tsx`)
picks it up automatically:

- An **iOS tab** appears next to Android with its own QR code and a
  "Join the iOS Beta" button pointing at that link.
- The **Platform Availability** sidebar flips iOS from "In Active
  Development" to "Available Now (TestFlight Beta)".
- The hero section shows a small "Also available on iPhone via TestFlight"
  note linking down to it.

Until that env var is set, the site keeps showing iOS as "coming soon" —
nothing breaks or shows a dead link in the meantime.

## Renewals to plan for

- The Distribution certificate expires after 1 year, the provisioning
  profile can expire sooner — regenerate and update the two `APPLE_*_BASE64`
  secrets when the workflow starts failing signing with an expiry error.
- Each TestFlight build itself expires 90 days after upload — cutting a
  release at least that often keeps existing testers on a working build.
