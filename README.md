# Suinime 🎬

**Suinime** adalah aplikasi mobile Flutter untuk menjelajahi katalog anime, melihat detail metadata, menyimpan library/history secara lokal, dan menonton episode melalui integrasi streaming backend.

Project ini menggunakan pendekatan **Hybrid Bridging**: metadata anime diambil dari **Jikan API / MyAnimeList**, sedangkan data episode dan link streaming diambil dari **Otakudesu Scraper Backend**.

---

## Ringkasan

| Item | Detail |
|---|---|
| Platform | Mobile App |
| Framework | Flutter |
| Bahasa | Dart |
| State Management | Provider |
| Local Database | Hive |
| Metadata API | Jikan API / MyAnimeList |
| Streaming Backend | Otakudesu Scraper Backend |
| Arsitektur | Hybrid Bridging |

---

## Fitur Utama

| Fitur | Deskripsi |
|---|---|
| Katalog Jikan | Menampilkan data anime seperti judul, poster, genre, skor, sinopsis, status, dan detail lain dari Jikan API. |
| Smart Video Bridging | Mencocokkan metadata anime dengan data episode dan link streaming dari backend Otakudesu. |
| Hive Local DB | Menyimpan library, kategori, search history, watch history, continue watching, dan cache detail anime secara lokal. |
| In-App Streaming | Memutar episode anime langsung di dalam aplikasi. |
| Data Storage | Menyediakan pengelolaan data lokal, termasuk backup/restore dan pengaturan penyimpanan. |

---

## Alur Arsitektur

```text
Flutter App
   |
   +-- Metadata Anime --> Jikan API / MyAnimeList
   |
   +-- Episode & Stream --> Otakudesu Scraper Backend
   |
   +-- Local Data --> Hive Database
```

---

## Persyaratan Sistem

| Kebutuhan | Keterangan |
|---|---|
| Flutter SDK | Versi stabil terbaru direkomendasikan |
| Dart SDK | Mengikuti versi Flutter SDK |
| Android Studio / VS Code | Untuk development Flutter |
| Android SDK | Untuk emulator atau build Android |
| Node.js | Untuk menjalankan backend scraper |
| ngrok | Untuk membuat tunnel backend lokal |
| Git | Untuk clone repository |

Cek environment:

```bash
flutter doctor
node --version
ngrok version
```

---

## Instalasi

### 1. Clone Repository

```bash
git clone https://github.com/username/suinime-app.git
cd suinime-app
```

### 2. Install Dependency Flutter

```bash
flutter pub get
```

### 3. Generate Hive Adapter

> **Wajib dijalankan**, terutama setelah clone ulang, pindah device, atau mengubah model Hive.

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Perintah ini akan menghasilkan file adapter seperti:

```text
lib/models/hive/*.g.dart
```

### 4. Jalankan Aplikasi

```bash
flutter run
```

Untuk memilih device tertentu:

```bash
flutter devices
flutter run -d <device_id>
```

---

## Konfigurasi Backend Otakudesu

Suinime membutuhkan backend scraper Otakudesu untuk mengambil data episode dan link streaming.

### 1. Jalankan Backend Lokal

Masuk ke folder backend, lalu jalankan server sesuai konfigurasi backend:

```bash
npm install
npm run dev
```

Contoh backend lokal:

```text
http://localhost:3000
```

### 2. Buat Tunnel dengan ngrok

```bash
ngrok http 3000
```

Contoh URL ngrok:

```text
https://abc123.ngrok-free.app
```

### 3. Update Base URL

Buka file:

```text
lib/services/otakudesu_service.dart
```

Ubah base URL menjadi URL ngrok aktif:

```dart
class OtakudesuService {
  static const String baseUrl = 'https://abc123.ngrok-free.app';
}
```

Catatan:

| Hal | Keterangan |
|---|---|
| Gunakan HTTPS | Lebih aman dan cocok untuk akses mobile. |
| URL ngrok berubah | Update `baseUrl` setiap kali tunnel baru dibuat. |
| Pastikan backend aktif | Aplikasi tidak dapat streaming jika backend lokal mati. |

---

## Struktur Folder Project

```text
lib/
+-- main.dart
+-- test_api.dart
+-- config/
|   +-- theme/
|       +-- app_theme.dart
+-- models/
|   +-- anime_model.dart
|   +-- library_model.dart
|   +-- hive/
|       +-- cached_anime_detail_hive.dart
|       +-- continue_watching_hive.dart
|       +-- library_category_hive.dart
|       +-- library_item_hive.dart
|       +-- search_history_hive.dart
|       +-- watch_history_hive.dart
|       +-- *.g.dart
+-- screens/
|   +-- category_management_screen.dart
|   +-- completed_anime_screen.dart
|   +-- dashboard_anime_list_screen.dart
|   +-- data_storage_screen.dart
|   +-- detail_screen.dart
|   +-- genre_list_screen.dart
|   +-- player_screen.dart
|   +-- search_screen.dart
|   +-- video_player_screen.dart
|   +-- home/
|       +-- home_screen.dart
|       +-- tabs/
|       |   +-- dashboard_tab.dart
|       |   +-- history_tab.dart
|       |   +-- library_tab.dart
|       |   +-- more_tab.dart
|       |   +-- schedule_tab.dart
|       +-- widgets/
|           +-- anime_grid_card.dart
|           +-- home_views.dart
|           +-- pagination_controls.dart
|           +-- section_header.dart
+-- services/
|   +-- api_service.dart
|   +-- backup_restore_service.dart
|   +-- consumet_service.dart
|   +-- hive_service.dart
|   +-- library_service.dart
|   +-- otakudesu_service.dart
|   +-- search_history_notifier.dart
|   +-- storage_settings_service.dart
|   +-- video_tracking_service.dart
+-- widgets/
|   +-- custom_button.dart
|   +-- custom_text_field.dart
+-- utils/
    +-- responsive.dart
```

| Folder / File | Fungsi |
|---|---|
| `lib/main.dart` | Entry point aplikasi. |
| `lib/config/theme` | Konfigurasi tema aplikasi. |
| `lib/models` | Model data utama aplikasi. |
| `lib/models/hive` | Model Hive dan adapter hasil generate. |
| `lib/screens` | Halaman aplikasi. |
| `lib/screens/home` | Home screen, tab utama, dan widget khusus home. |
| `lib/services` | Logic API, backend, Hive, library, backup/restore, storage, dan tracking video. |
| `lib/widgets` | Komponen UI reusable. |
| `lib/utils` | Helper umum seperti responsive layout. |

---

## Konfigurasi Penting

| Konfigurasi | Lokasi | Catatan |
|---|---|---|
| Base URL Backend | `lib/services/otakudesu_service.dart` | Gunakan URL HTTPS dari ngrok. |
| Hive Adapter | `lib/models/hive/*.g.dart` | Generate dengan `build_runner`. |
| Hive Service | `lib/services/hive_service.dart` | Mengatur inisialisasi dan akses database lokal. |
| Permission Internet | `android/app/src/main/AndroidManifest.xml` | Diperlukan untuk akses API dan streaming. |

Pastikan permission internet tersedia:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

---

## Troubleshooting

| Masalah | Penyebab Umum | Solusi |
|---|---|---|
| `HTTP 429 Too Many Requests` | Request ke Jikan API terlalu sering. | Kurangi frekuensi request, gunakan cache, atau tambahkan delay/retry. |
| `TypeAdapter not found` | Adapter Hive belum di-generate atau belum terdaftar. | Jalankan `flutter pub run build_runner build --delete-conflicting-outputs`. |
| `HiveError: Cannot read, unknown typeId` | Data lokal tidak cocok dengan adapter/model terbaru. | Generate adapter ulang, lalu clear app data jika masih bermasalah. |
| `SocketException` / `Connection refused` | Backend tidak aktif atau URL ngrok salah. | Jalankan backend, aktifkan ngrok, lalu update `baseUrl`. |
| Error setelah clone atau pindah device | File `*.g.dart` belum dibuat di environment baru. | Jalankan `flutter pub get` lalu generate Hive adapter. |

Perintah reset development yang sering dipakai:

```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

---

## Perintah Penting

| Kebutuhan | Perintah |
|---|---|
| Install dependency | `flutter pub get` |
| Generate Hive adapter | `flutter pub run build_runner build --delete-conflicting-outputs` |
| Jalankan aplikasi | `flutter run` |
| Cek device | `flutter devices` |
| Cek environment | `flutter doctor` |
| Jalankan ngrok | `ngrok http 3000` |

---

## Catatan

- URL ngrok gratis akan berubah setiap kali tunnel dijalankan ulang.
- Setiap perubahan pada model Hive membutuhkan generate ulang adapter.
- Hindari request berlebihan ke Jikan API agar tidak terkena rate limit.
- Pastikan backend scraper aktif sebelum membuka fitur streaming.

---

## Lisensi

Project ini dibuat untuk kebutuhan pembelajaran dan pengembangan aplikasi mobile berbasis Flutter.

Pastikan penggunaan data, metadata, dan sumber streaming mengikuti kebijakan dari masing-masing penyedia layanan.
