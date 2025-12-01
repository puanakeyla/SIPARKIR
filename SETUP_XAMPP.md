# Panduan Setup SIPARKIR dengan XAMPP MySQL

## Langkah 1: Install & Start XAMPP
1. Pastikan XAMPP sudah terinstall
2. Start **Apache** dan **MySQL** dari XAMPP Control Panel

## Langkah 2: Import Database
1. Buka phpMyAdmin: `http://localhost/phpmyadmin`
2. Klik tab **"New"** atau **"Databases"**
3. Buat database baru dengan nama: `siparkir`
4. Pilih database `siparkir` yang baru dibuat
5. Klik tab **"Import"**
6. Pilih file: `database/siparkir.sql`
7. Klik **"Go"** untuk import

## Langkah 3: Setup File PHP
1. Copy folder project `APPL` ke folder `htdocs` XAMPP
   - Default path: `C:\xampp\htdocs\APPL`
2. Pastikan struktur folder seperti ini:
   ```
   C:\xampp\htdocs\APPL\
   ├── api/
   │   ├── config.php
   │   ├── login.php
   │   ├── kendaraan.php
   │   ├── transaksi.php
   │   ├── verifikasi.php
   │   └── audit.php
   ├── js/
   │   ├── database.js (localStorage - backup)
   │   └── database-api.js (MySQL API - gunakan ini)
   ├── login.html
   ├── admin.html
   ├── pengguna.html
   └── petugas.html
   ```

## Langkah 4: Update HTML Files
Ganti reference dari `database.js` ke `database-api.js` di semua file HTML:

**Sebelum:**
```html
<script src="js/database.js"></script>
```

**Sesudah:**
```html
<script src="js/database-api.js"></script>
```

File yang perlu diupdate:
- ✅ login.html
- ✅ admin.html
- ✅ pengguna.html
- ✅ petugas.html

## Langkah 5: Konfigurasi API URL
1. Buka file `js/database-api.js`
2. Edit baris ke-7, sesuaikan dengan path project Anda:
   ```javascript
   const API_URL = 'http://localhost/APPL/api';
   ```
   - Jika folder project di `htdocs/siparkir`, ubah jadi: `http://localhost/siparkir/api`
   - Jika di root `htdocs`, ubah jadi: `http://localhost/api`

## Langkah 6: Test Koneksi
1. Buka browser, akses: `http://localhost/APPL/login.html`
2. Login dengan akun default:
   
   **Admin:**
   - Email: `admin@unila.ac.id`
   - Password: `admin123`
   
   **Pengguna:**
   - Email: `pengguna@unila.ac.id`
   - Password: `pengguna123`
   
   **Petugas:**
   - Email: `petugas@unila.ac.id`
   - Password: `petugas123`

## Langkah 7: Troubleshooting

### Error: CORS Policy
Jika muncul error CORS, pastikan:
1. Apache sudah running di XAMPP
2. Akses via `http://localhost`, bukan `file://`

### Error: Database Connection Failed
1. Cek MySQL di XAMPP sudah running
2. Cek kredensial di `api/config.php`:
   ```php
   define('DB_HOST', 'localhost');
   define('DB_USER', 'root');
   define('DB_PASS', ''); // Default XAMPP kosong
   define('DB_NAME', 'siparkir');
   ```

### Error: 404 Not Found
1. Pastikan path API URL benar
2. Pastikan folder `api/` ada di `htdocs/APPL/`

### Data Tidak Muncul
1. Cek browser console (F12) untuk error
2. Pastikan database sudah diimport dengan benar
3. Test API langsung: `http://localhost/APPL/api/kendaraan.php`

## Fitur yang Tersedia
✅ Login untuk Admin, Pengguna, Petugas
✅ CRUD Kendaraan dengan foto dokumen
✅ Transaksi Parkir (Check-in/Check-out)
✅ Verifikasi Kendaraan (Admin & Petugas)
✅ Audit Trail untuk tracking Admin
✅ Real-time data dari MySQL database

## Perbedaan dengan localStorage
| Fitur | localStorage | MySQL (API) |
|-------|-------------|-------------|
| Data Storage | Browser | Server Database |
| Persistensi | Per browser | Semua device |
| Keamanan | Low | High |
| Multi-user | ❌ | ✅ |
| Backup | Manual | Otomatis |

## Backup & Restore
**Backup Database:**
1. Buka phpMyAdmin
2. Pilih database `siparkir`
3. Tab "Export" → "Go"
4. Download file `.sql`

**Restore Database:**
1. Pilih database `siparkir`
2. Tab "Import"
3. Pilih file backup `.sql`
4. Click "Go"

## Support
Jika ada masalah, cek:
1. XAMPP Control Panel (Apache & MySQL harus hijau/running)
2. Browser Console (F12) untuk error JavaScript
3. PHP Error Log di `xampp/apache/logs/error.log`
