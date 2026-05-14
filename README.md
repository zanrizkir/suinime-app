# Suinime 🎬

**Suinime** adalah aplikasi mobile berbasis **Flutter** untuk menelusuri katalog anime, melihat detail metadata, menyimpan favorit dan riwayat tontonan, serta melakukan streaming episode anime langsung dari dalam aplikasi.

Aplikasi ini menggunakan arsitektur **Hybrid Bridging**, yaitu menggabungkan metadata anime dari **Jikan API / MyAnimeList** dengan link streaming dari **Otakudesu Scraper Backend**. Pendekatan ini memungkinkan aplikasi menampilkan informasi anime yang kaya sekaligus tetap menyediakan akses streaming yang praktis.

---

## Ringkasan Project

| Informasi | Detail |
|---|---|
| Nama Aplikasi | Suinime |
| Platform | Mobile App |
| Framework | Flutter |
| Bahasa | Dart |
| State Management | Provider |
| Local Database | Hive |
| Metadata API | Jikan API / MyAnimeList |
| Streaming Source | Otakudesu Scraper Backend |
| Arsitektur | Hybrid Bridging |

---

## Fitur Utama

| Fitur | Deskripsi | Teknologi |
|---|---|---|
| Katalog Jikan | Menampilkan katalog anime, detail anime, genre, skor, sinopsis, poster, status, dan informasi lain dari MyAnimeList melalui Jikan API. | Jikan API |
| Smart Video Bridging | Menghubungkan metadata anime dari Jikan dengan data episode dan link streaming dari backend Otakudesu. | Flutter Service Layer, Otakudesu Backend |
| Hive Local DB | Menyimpan data favorit dan history secara lokal di perangkat pengguna. | Hive |
| In-App Streaming | Memutar episode anime langsung di dalam aplikasi tanpa perlu membuka browser eksternal. | Flutter Video Player / Streaming Service |
| Favorite Anime | Menyimpan anime favorit agar mudah diakses kembali. | Hive, Provider |
| History Tontonan | Menyimpan riwayat anime atau episode yang pernah ditonton pengguna. | Hive, Provider |
| State Management | Mengelola perubahan state aplikasi secara reaktif dan terstruktur. | Provider |

---

## Arsitektur Utama

Suinime menggunakan pendekatan **Hybrid Bridging Architecture**.

```text
+----------------------+
|      Flutter App     |
+----------+-----------+
           |
           | Fetch Metadata
           v
+----------------------+
|      Jikan API       |
|   MyAnimeList Data   |
+----------------------+
           |
           | Match / Bridge Anime Title
           v
+------------------------------+
| Otakudesu Scraper Backend    |
| Episode & Streaming Links    |
+------------------------------+
           |
           | Save Local Data
           v
+----------------------+
|      Hive DB         |
| Favorite & History   |
+----------------------+
```

### Alur Data

| Tahap | Proses |
|---|---|
| 1 | Aplikasi mengambil metadata anime dari Jikan API. |
| 2 | Pengguna memilih anime dari katalog atau halaman pencarian. |
| 3 | Service aplikasi mencocokkan judul anime dengan data dari Otakudesu Backend. |
| 4 | Backend mengembalikan daftar episode dan link streaming. |
| 5 | Aplikasi menampilkan player streaming di dalam aplikasi. |
| 6 | Data favorit dan history disimpan secara lokal menggunakan Hive. |

---

## Tech Stack

| Kategori | Teknologi |
|---|---|
| Mobile Framework | Flutter |
| Programming Language | Dart |
| State Management | Provider |
| Local Database | Hive |
| Metadata API | Jikan API |
| Streaming Backend | Otakudesu Scraper Backend |
| Backend Tunnel | ngrok |
| Code Generator | build_runner |
| Local Storage Adapter | hive_generator |

---

## Persyaratan Sistem

Sebelum menjalankan project, pastikan perangkat pengembangan sudah memiliki komponen berikut:

| Kebutuhan | Versi / Keterangan |
|---|---|
| Flutter SDK | Versi stabil terbaru direkomendasikan |
| Dart SDK | Mengikuti versi Flutter SDK |
| Android Studio / VS Code | Untuk development Flutter |
| Android SDK | Untuk menjalankan emulator atau build Android |
| Node.js | Dibutuhkan untuk menjalankan backend scraper |
| npm / pnpm / yarn | Package manager backend |
| ngrok | Untuk membuat public tunnel ke backend lokal |
| Git | Untuk clone repository |

Cek instalasi Flutter:

```bash
flutter doctor
```

Cek instalasi Node.js:

```bash
node --version
```

Cek instalasi ngrok:

```bash
ngrok version
```

---

## Instalasi dan Konfigurasi

### 1. Clone Repository

```bash
git clone https://github.com/username/suinime-app.git
cd suinime-app
```

> Ganti URL repository dengan URL repository Suinime yang digunakan.

### 2. Install Dependency Flutter

```bash
flutter pub get
```

### 3. Generate Hive Adapter

> **Wajib dilakukan.**
>
> Project ini menggunakan Hive sebagai local database. Jika adapter Hive belum di-generate, aplikasi dapat mengalami error saat membaca atau menyimpan data lokal.

Jalankan perintah berikut:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Perintah ini akan membuat file adapter yang dibutuhkan Hive, misalnya:

```text
*.g.dart
```

Contoh file hasil generate:

```text
lib/models/anime_model.g.dart
lib/models/favorite_model.g.dart
lib/models/history_model.g.dart
```

Jika terjadi error setelah berpindah device, clone ulang project, atau membersihkan build cache, jalankan kembali perintah generate Hive adapter tersebut.

---

## Konfigurasi Backend Otakudesu

Suinime membutuhkan backend scraper Otakudesu untuk mendapatkan daftar episode dan link streaming.

### 1. Jalankan Backend Lokal

Masuk ke folder backend Otakudesu, lalu jalankan server:

```bash
npm install
npm run dev
```

Atau sesuai konfigurasi backend:

```bash
node index.js
```

Pastikan backend berjalan di localhost, misalnya:

```text
http://localhost:3000
```

### 2. Jalankan ngrok

Karena aplikasi mobile atau emulator tidak selalu dapat mengakses `localhost` komputer secara langsung, gunakan ngrok untuk membuat public URL.

```bash
ngrok http 3000
```

Contoh output ngrok:

```text
Forwarding  https://abc123.ngrok-free.app -> http://localhost:3000
```

Gunakan URL HTTPS dari ngrok sebagai base URL backend.

### 3. Atur Base URL di `otakudesu_service.dart`

Buka file berikut:

```text
lib/services/otakudesu_service.dart
```

Cari konfigurasi base URL backend, lalu ubah menjadi URL ngrok aktif.

Contoh:

```dart
class OtakudesuService {
  static const String baseUrl = 'https://abc123.ngrok-free.app';

  // Endpoint service lainnya
}
```

Pastikan URL memenuhi ketentuan berikut:

| Syarat | Keterangan |
|---|---|
| Menggunakan HTTPS | Direkomendasikan untuk akses dari mobile app |
| Tidak diakhiri slash ganda | Hindari format seperti `https://example.ngrok-free.app//api` |
| Masih aktif | URL ngrok gratis berubah setiap kali tunnel dijalankan ulang |
| Sesuai port backend | Pastikan port ngrok sama dengan port backend lokal |

---

## Menjalankan Aplikasi

### Android Emulator / Device

```bash
flutter run
```

### Menjalankan dengan Device Tertentu

Lihat daftar device:

```bash
flutter devices
```

Jalankan ke device tertentu:

```bash
flutter run -d <device_id>
```

Contoh:

```bash
flutter run -d emulator-5554
```

---

## Struktur Folder Project

```text
lib/
+-- main.dart
+-- models/
|   +-- anime_model.dart
|   +-- favorite_model.dart
|   +-- history_model.dart
|   +-- *.g.dart
+-- providers/
|   +-- anime_provider.dart
|   +-- favorite_provider.dart
|   +-- history_provider.dart
+-- screens/
|   +-- home_screen.dart
|   +-- detail_screen.dart
|   +-- favorite_screen.dart
|   +-- history_screen.dart
|   +-- player_screen.dart
+-- services/
|   +-- consumet_service.dart
|   +-- jikan_service.dart
|   +-- otakudesu_service.dart
+-- widgets/
|   +-- anime_card.dart
|   +-- episode_tile.dart
|   +-- loading_widget.dart
+-- utils/
    +-- constants.dart
    +-- helpers.dart
```

### Penjelasan Folder

| Folder / File | Fungsi |
|---|---|
| `lib/main.dart` | Entry point aplikasi Flutter. |
| `lib/models` | Berisi model data aplikasi, termasuk model Hive. |
| `lib/providers` | Berisi state management menggunakan Provider. |
| `lib/screens` | Berisi halaman utama aplikasi. |
| `lib/services` | Berisi logic komunikasi API dan backend. |
| `lib/widgets` | Berisi komponen UI reusable. |
| `lib/utils` | Berisi helper, konstanta, dan utilitas umum. |
| `*.g.dart` | File hasil generate Hive adapter dari build_runner. |

---

## Service Layer

### Jikan / Consumet Service

Service ini bertugas mengambil metadata anime seperti:

| Data | Keterangan |
|---|---|
| Judul Anime | Nama anime dari MyAnimeList |
| Sinopsis | Deskripsi cerita anime |
| Skor | Rating anime |
| Poster | Gambar cover anime |
| Genre | Daftar genre anime |
| Status | Status penayangan |
| Episode | Jumlah episode dari metadata |

Contoh konsep penggunaan:

```dart
final animeList = await jikanService.getTopAnime();
```

### Otakudesu Service

Service ini bertugas mengambil data streaming dari backend scraper.

| Data | Keterangan |
|---|---|
| Daftar Episode | Episode anime dari Otakudesu |
| Detail Episode | Informasi episode tertentu |
| Streaming URL | Link video untuk diputar di aplikasi |
| Mirror | Alternatif server streaming jika tersedia |

Contoh konsep penggunaan:

```dart
final episodes = await otakudesuService.getEpisodes(animeTitle);
```

---

## Local Database dengan Hive

Suinime menggunakan Hive untuk menyimpan data lokal seperti:

| Data | Fungsi |
|---|---|
| Favorite | Menyimpan anime favorit pengguna |
| History | Menyimpan riwayat tontonan |
| Cache Ringan | Menyimpan data tertentu agar lebih cepat diakses |

### Contoh Model Hive

```dart
import 'package:hive/hive.dart';

part 'favorite_model.g.dart';

@HiveType(typeId: 1)
class FavoriteModel extends HiveObject {
  @HiveField(0)
  final int malId;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String imageUrl;

  FavoriteModel({
    required this.malId,
    required this.title,
    required this.imageUrl,
  });
}
```

Setelah membuat atau mengubah model Hive, jalankan kembali:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Konfigurasi Penting

| Konfigurasi | Lokasi | Keterangan |
|---|---|---|
| Base URL Otakudesu Backend | `lib/services/otakudesu_service.dart` | URL backend scraper yang aktif. |
| Hive Adapter | `lib/models/*.g.dart` | Harus di-generate dengan build_runner. |
| Provider Setup | `lib/main.dart` | Registrasi provider aplikasi. |
| Permission Internet | `android/app/src/main/AndroidManifest.xml` | Dibutuhkan agar aplikasi dapat mengakses API. |

Pastikan Android memiliki permission internet:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

---

## Troubleshooting

### 1. Jikan API Error 429 Rate Limit

**Masalah:**

```text
HTTP 429 Too Many Requests
```

**Penyebab:**

Jikan API memiliki batas request. Error ini muncul ketika aplikasi mengirim terlalu banyak request dalam waktu singkat.

**Solusi:**

| Solusi | Keterangan |
|---|---|
| Tambahkan delay request | Hindari memanggil API berkali-kali dalam waktu singkat. |
| Gunakan caching | Simpan data sementara agar tidak selalu request ulang. |
| Batasi refresh otomatis | Hindari auto-refresh yang terlalu agresif. |
| Tampilkan retry state | Beri opsi pengguna untuk mencoba ulang. |

Contoh pendekatan retry sederhana:

```dart
Future<void> fetchAnimeWithDelay() async {
  await Future.delayed(const Duration(seconds: 2));
  await animeService.fetchAnime();
}
```

### 2. Error Hive Adapter Tidak Ditemukan

**Masalah:**

```text
HiveError: Cannot read, unknown typeId
```

Atau:

```text
Error: TypeAdapter not found
```

**Penyebab:**

File adapter Hive belum dibuat atau belum terdaftar dengan benar.

**Solusi:**

Jalankan:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Lalu pastikan adapter sudah diregistrasikan di `main.dart`.

Contoh:

```dart
Hive.registerAdapter(FavoriteModelAdapter());
Hive.registerAdapter(HistoryModelAdapter());
```

### 3. Error Setelah Pindah Device atau Clone Ulang

**Masalah:**

Aplikasi berjalan normal di satu device, tetapi error setelah pindah device atau setelah project di-clone ulang.

**Penyebab umum:**

| Penyebab | Solusi |
|---|---|
| File `*.g.dart` belum tersedia | Jalankan build_runner. |
| Hive box belum terinisialisasi | Periksa inisialisasi Hive di `main.dart`. |
| Adapter belum diregistrasikan | Pastikan semua adapter dipanggil sebelum membuka box. |
| Data lama tidak kompatibel | Clear app data atau uninstall aplikasi dari device. |

Perintah yang disarankan:

```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

### 4. Backend Tidak Dapat Diakses dari Aplikasi

**Masalah:**

```text
SocketException
Connection refused
Failed host lookup
```

**Penyebab:**

Aplikasi tidak dapat mengakses backend lokal atau URL ngrok tidak aktif.

**Solusi:**

| Langkah | Keterangan |
|---|---|
| Pastikan backend berjalan | Jalankan backend lokal terlebih dahulu. |
| Pastikan ngrok aktif | Jalankan `ngrok http <port>`. |
| Update base URL | Ubah URL di `otakudesu_service.dart`. |
| Gunakan HTTPS | Gunakan URL HTTPS dari ngrok. |
| Cek koneksi device | Pastikan emulator/device memiliki internet. |

---

## Perintah Penting

| Kebutuhan | Perintah |
|---|---|
| Install dependency Flutter | `flutter pub get` |
| Generate Hive adapter | `flutter pub run build_runner build --delete-conflicting-outputs` |
| Membersihkan build | `flutter clean` |
| Menjalankan aplikasi | `flutter run` |
| Melihat device | `flutter devices` |
| Mengecek environment | `flutter doctor` |
| Menjalankan ngrok | `ngrok http 3000` |

---

## Workflow Development

```text
1. Jalankan backend Otakudesu
2. Jalankan ngrok
3. Salin URL HTTPS ngrok
4. Update baseUrl di otakudesu_service.dart
5. Jalankan flutter pub get
6. Generate Hive adapter
7. Jalankan aplikasi dengan flutter run
```

Contoh lengkap:

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

---

## Catatan Pengembangan

- URL ngrok gratis akan berubah setiap kali tunnel dijalankan ulang.
- Jangan lupa memperbarui `baseUrl` di `otakudesu_service.dart` setelah URL ngrok berubah.
- Setiap perubahan pada model Hive membutuhkan generate ulang adapter.
- Hindari request berlebihan ke Jikan API untuk mencegah error rate limit.
- Gunakan cache lokal jika data tidak perlu selalu diperbarui secara real-time.
- Pastikan backend scraper berjalan sebelum membuka fitur streaming.

---

## Status Project

| Komponen | Status |
|---|---|
| Flutter App | Aktif dikembangkan |
| Jikan Metadata Integration | Tersedia |
| Otakudesu Backend Bridging | Tersedia |
| Hive Favorite Storage | Tersedia |
| Hive History Storage | Tersedia |
| In-App Streaming | Tersedia |

---

## Lisensi

Project ini dibuat untuk kebutuhan pembelajaran dan pengembangan aplikasi mobile berbasis Flutter.

Pastikan penggunaan data, metadata, dan sumber streaming mengikuti kebijakan dari masing-masing penyedia layanan.
