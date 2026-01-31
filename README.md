# GtsAlpha Wallet

แอปพลิเคชัน Wallet สำหรับสแกน QR Code และ NFC แบบ Premium Minimalist

[![Release](https://img.shields.io/badge/release-v1.0.0--alpha.1-blue)](https://github.com/gittisak-go/GtsAlpha-Wallet/releases)
[![Flutter](https://img.shields.io/badge/Flutter-3.3.0+-blue)](https://flutter.dev)
[![Supabase](https://img.shields.io/badge/Supabase-2.5+-green)](https://supabase.com)

## ✨ Features

### Core
- **QR Code Scanner** - สแกน QR Code ด้วยกล้อง
- **NFC Scanner** - แตะการ์ดหรือแหวน NFC เพื่ออ่านข้อมูล
- **Premium UI** - ดีไซน์หรูหรา ทันสมัย แบบ Minimalist
- **Dark Theme** - โทนมืดสไตล์ Apple Wallet

### Backend (Supabase)
- **User Authentication** - Email/Password, Social login
- **Scan Logs** - บันทึกประวัติการสแกน QR/NFC
- **Digital Cards** - จัดการนามบัตรดิจิทัล
- **GPS/Maps** - Location tracking

### Security & Compliance
- **Row Level Security (RLS)** - ผู้ใช้เห็นเฉพาะข้อมูลตัวเอง
- **Compliance Cases** - Super_Admin สร้าง case ตรวจสอบได้
- **Audit Logs** - บันทึกการเข้าถึงข้อมูลทั้งหมด
- **GDPR/PDPA Ready** - พร้อมสำหรับกฎหมายคุ้มครองข้อมูล

### Realtime
- **Chat Messages** - แชทเรียลไทม์
- **Location Updates** - อัปเดตตำแหน่งแบบเรียลไทม์
- **Status Updates** - สถานะ compliance cases

## 🎨 Design

- **Color Scheme**: Dark background (#000000) with iOS Blue accent (#0A84FF)
- **Typography**: Modern sans-serif with optimized letter spacing
- **UI Style**: Minimalist, clean, luxurious

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.3.0)
- Dart SDK
- Supabase account

### Installation

```bash
# Clone repository
git clone https://github.com/gittisak-go/GtsAlpha-Wallet.git
cd GtsAlpha-Wallet

# Install dependencies
flutter pub get

# Setup environment
cp .env.example .env
# Edit .env with your Supabase credentials

# Run app
flutter run
```

### Environment Variables

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

### Database Setup

Run migrations in Supabase SQL Editor:
```bash
supabase/migrations/001_initial_schema.sql
supabase/migrations/002_scan_logs_rls_super_admin.sql
supabase/migrations/003_compliance_cases_realtime_rls.sql
```

## 📱 Supported Platforms

- ✅ iOS
- ✅ Android
- ✅ Web
- ✅ macOS
- ✅ Windows
- ✅ Linux

## 🛠️ Tech Stack

- **Flutter** - Cross-platform framework
- **Supabase** - Backend as a Service (Auth, Database, Realtime)
- **mobile_scanner** - QR Code scanning
- **nfc_manager** - NFC reading
- **modal_bottom_sheet** - Bottom sheet UI

## 🗺️ Roadmap

### v1.0.0-alpha.1 (Current) ✅
- [x] Supabase integration
- [x] QR/NFC scanning
- [x] RLS & Compliance cases
- [x] Realtime features

### v1.0.0-alpha.2 (Next)
- [ ] Admin Dashboard (ผู้ควบคุมระบบ)
- [ ] User management UI
- [ ] Compliance case management UI

### v1.0.0-beta.1
- [ ] 1NEC IoT SIM Card Industrial integration
- [ ] Enhanced GPS tracking
- [ ] Push notifications

### v1.0.0 (Stable)
- [ ] Production ready
- [ ] Full documentation
- [ ] Performance optimization

## 🚢 Deployment

### Web (Vercel/Netlify)

```bash
# Build for web
flutter build web --release

# Deploy to Vercel
vercel deploy build/web

# Or Netlify
netlify deploy --prod --dir=build/web
```

### Mobile

```bash
# Android APK
flutter build apk --release

# iOS
flutter build ios --release
```

## 👥 Super_Admin Team

| Role | Email |
|------|-------|
| System Administrator | patty_patteera19@hotmail.com |
| Developer | gittisakwannakeeree@gmail.com |
| Developer | phongwut.w@gmail.com |
| Director | director@gtsalphamcp.com |
| DPO (Data Protection) | info@gtsalphamcp.com |

## 📄 License

This project is private and proprietary.

## 👤 Author

GtsAlpha Team - [GtsAlpha MCP](https://gtsalphamcp.com)

---

**GtsAlpha Wallet** - Secure, Modern, Minimalist

🔐 Powered by Supabase | 🚀 Built with Flutter
