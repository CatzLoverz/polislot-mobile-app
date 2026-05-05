# PoliSlot Mobile App

## Penjelasan Singkat Aplikasi
**PoliSlot Mobile App** adalah aplikasi *mobile dashboard* (berbasis Android & iOS) yang terhubung dengan ekosistem IoT cerdas PoliSlot. Aplikasi ini dirancang untuk memudahkan pengguna dalam melihat dan mengelola lokasi parkir secara langsung melalui perangkat seluler, melihat papan informasi, melakukan misi (gamifikasi) untuk mendapatkan *reward*, serta memeriksa riwayat aktivitas atau transaksi secara *real-time*. Seluruh komunikasi aplikasi dengan *backend* dilindungi menggunakan sistem enkripsi *Hybrid Encryption* (RSA/AES).

## Fitur Utama
- **Autentikasi Aman**: Login, Registrasi, Verifikasi OTP, dan Reset Password dengan enkripsi.
- **Pencarian Parkir (Google Maps)**: Integrasi peta interaktif untuk melihat dan mencari lokasi parkir (IoT-enabled) secara instan.
- **Sistem Misi & Reward**: Pengguna dapat menjalankan *mission* untuk meraih poin dan hadiah (*reward*).
- **Riwayat Aktivitas**: Rekaman lengkap terkait aktivitas parkir dan poin.
- **Pusat Informasi**: Memuat papan informasi (Info Board), FAQ, serta formulir pengaduan (Feedback) bagi pengguna.
- **Profil Pengguna**: Manajemen data profil, pengaturan akun, serta keamanan sandi.

## Tech Stack
Aplikasi ini dikembangkan dengan pendekatan modular (*feature-first*) menggunakan berbagai teknologi modern:
- **Framework**: [Flutter](https://flutter.dev/) (SDK `^3.10.0`)
- **State Management**: [Riverpod](https://riverpod.dev/) (`riverpod_annotation`, `flutter_riverpod`, `riverpod_generator`)
- **Networking & API**: [Dio](https://pub.dev/packages/dio)
- **Security / Encryption**: `encrypt`, `pointycastle`, RSA Public Key
- **Serialization**: `json_serializable`, `json_annotation`
- **Location & Maps**: `google_maps_flutter`, `geolocator`
- **Local Storage**: `shared_preferences`
- **Environment Management**: `flutter_dotenv`

## External Prerequisite Service
Agar aplikasi ini dapat berfungsi secara penuh, pastikan beberapa layanan eksternal berikut telah tersedia dan terkonfigurasi:
1. **Backend Server (PoliSlot Admin Dashboard)**: Server API dan website admin dibangun dengan Laravel yang menangani database pengguna, riwayat IoT, manajemen misi, dan memegang kunci enkripsi *private* (RSA).
2. **Google Maps API Key**: Diperlukan dari Google Cloud Console untuk merender peta pada halaman Parkir. Kunci ini disimpan secara lokal di `android/local.properties`.
3. **Kunci Enkripsi (Public Key)**: Sebuah *file* `public_key.pem` yang harus diletakkan dalam direktori *assets* aplikasi.

## Struktur Direktori
Struktur utama pada direktori `lib/` menerapkan arsitektur *feature-first layer*:

```text
lib/
├── core/                       # Kumpulan kode shared logic & utilities
│   ├── enums/                  # Enumeration global (contoh: tipe OTP)
│   ├── network/                # Interceptor Dio dan HTTP client
│   ├── providers/              # Global Riverpod provider
│   ├── routes/                 # Konfigurasi routing / navigasi (app_routes.dart)
│   ├── security/               # Manajer keamanan data dan enkripsi (KeyManager)
│   ├── theme/                  # Konfigurasi style dan tema (Colors, Typography)
│   ├── utils/                  # Fungsi *helper* tambahan
│   ├── widgets/                # Komponen UI (widget) yang dapat digunakan ulang
│   └── wrapper/                # Global wrapper seperti Connectivity Observer
│
├── features/                   # Modul/fitur utama aplikasi
│   ├── auth/                   # Fitur Login, Register, dan Verifikasi OTP
│   ├── faq/                    # Halaman FAQ
│   ├── feedback/               # Halaman penulisan Umpan Balik / Feedback
│   ├── history/                # Halaman riwayat parkir dan poin
│   ├── home/                   # Halaman Dashboard Utama
│   ├── info_board/             # Papan buletin atau informasi dari admin
│   ├── mission/                # Halaman Misi (Gamifikasi)
│   ├── park/                   # Halaman pencarian dan Peta Parkir
│   ├── profile/                # Pengaturan Profil dan Akun
│   ├── reward/                 # Penukaran / informasi Poin & Hadiah
│   └── splash/                 # Splash Screen saat aplikasi baru dibuka
│
└── main.dart                   # Entry point aplikasi
```

## Panduan Instalasi (Kompilasi)

### 1. Persiapan Awal
Pastikan Anda sudah menginstal:
- **Flutter SDK** (versi >= 3.10.0). Jalankan `flutter doctor` untuk memastikan semuanya telah *checklist* hijau.
- **Android Studio** (untuk build Android) dan/atau **Xcode** (untuk build iOS).
- **Git** (untuk kloning repository).

### 2. Kloning Repository
Clone repository lokal atau dari platform (GitHub/GitLab):
```bash
git clone <url-repository>
cd polislot_mobile_catz
```

### 3. Mengunduh Dependencies
Instal seluruh paket yang dideklarasikan pada `pubspec.yaml`:
```bash
flutter pub get
```

### 4. Konfigurasi Environment & Asset
- **File `.env`**: Buat *file* bernama `.env` di *root* proyek. Isi dengan variabel lingkungan seperti base URL *backend*:
  ```env
  API_URL=http://<ip-backend-anda>/api
  ```
- **Kunci Publik (RSA)**: Masukkan file `public_key.pem` ke dalam *folder* `assets/keys/` agar keamanan enkripsi data dapat berjalan lancar.
- **Google Maps API Key (Android)**: Salin *file* `android/local.properties.example` menjadi `android/local.properties`, lalu masukkan API Key Anda pada variabel `google.maps.api.key`.

### 5. Code Generation (Riverpod & JSON Serializable)
Aplikasi ini menggunakan *code generator*. Jalankan *build runner* untuk mengenerate seluruh *file* `.g.dart`:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 6. Jalankan Aplikasi
Jalankan aplikasi di emulator atau perangkat fisik (Android/iOS) yang sudah terhubung:
```bash
# Menjalankan untuk mode debug
flutter run

# Atau build APK untuk didistribusikan
flutter build apk --release
```
