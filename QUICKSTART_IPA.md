# 🚀 Quick Start: Build IPA for Sideloadly

## Two Options Available

### ✅ Option 1: Local Build (Recommended - No GitHub Needed)

If you have Flutter installed locally:

```bash
cd /home/shadiq/dc/spotit
./build-ios.sh
```

This creates `spotit.ipa` ready for Sideloadly installation.

### ✅ Option 2: GitHub Actions (If you don't have Flutter)

Requires GitHub account to use free macOS build servers.

**Steps:**
1. Create GitHub account (free)
2. Push code to GitHub
3. GitHub builds IPA automatically
4. Download from Actions → Artifacts

---

## 📋 What You Need for Sideloadly

- ✅ `spotit.ipa` file (from either option above)
- ✅ Sideloadly installed
- ✅ iPhone connected via USB
- ✅ Apple ID (free account works)

---

## 🎯 Installation Steps

1. **Get the IPA** (use Option 1 or 2 above)
2. **Open Sideloadly**
3. **Connect iPhone** via USB
4. **Drag `spotit.ipa`** into Sideloadly
5. **Enter Apple ID** and click Start
6. **Trust certificate** on iPhone (Settings → General → VPN & Device Management)

---

## 📝 Important Notes

- **Free Apple ID**: Apps expire after 7 days (need to reinstall)
- **Paid Developer Account ($99/year)**: Apps valid for 1 year
- **Backend**: Update `lib/services/api_service.dart` with your computer's IP address
- **Network**: iPhone and computer must be on same WiFi

See `SIDELOADLY_GUIDE.md` for detailed instructions.
