# SIPARKIR UNILA - Sistem Parkir Kampus

Sistem Informasi Parkir Universitas Lampung yang terintegrasi dengan database MySQL real-time menggunakan XAMPP.

## 🚀 Fitur Utama

### **👤 PENGGUNA (Mahasiswa/Dosen/Civitas)**
1. ✅ Login ke Sistem
2. ✅ Registrasi Kendaraan Baru
3. ✅ Melakukan Parkir (Check-In)
4. ✅ Melakukan Keluar Parkir (Check-Out)
5. ✅ Lapor Kehilangan Kendaraan

### **👮 PETUGAS KEAMANAN**
1. ✅ Login ke Sistem
2. ✅ Mencatat Kendaraan Keluar/Masuk
3. ✅ Verifikasi Identitas Kendaraan
4. ✅ Menangani Laporan Kehilangan

### **👨‍💼 ADMINISTRATOR**
1. ✅ Login ke Sistem
2. ✅ Monitoring Sistem Parkir (Dashboard KPI)
3. ✅ Generate Laporan Statistik
4. ✅ Kelola Database Kendaraan
5. ✅ Kelola Data Pengguna
6. ✅ Kelola Data Petugas

---

## 📦 Struktur File

```
SIPARKIR/
├── api/
│   ├── config.php           # Konfigurasi database MySQL
│   ├── login.php            # API endpoint login
│   ├── kendaraan.php        # API endpoint kendaraan
│   ├── transaksi.php        # API endpoint transaksi parkir
│   ├── verifikasi.php       # API endpoint verifikasi
│   └── audit.php            # API endpoint audit log
├── database/
│   ├── siparkir.sql         # Database schema MySQL
│   ├── siparkir_postgresql.sql  # Database schema PostgreSQL
│   └── MAPPING_SQL_vs_CLASS_vs_APP.md
├── js/
│   ├── database.js          # Database helper (localStorage fallback)
│   └── database-api.js      # API client helper
├── login.html               # Halaman login universal (3 role)
├── pengguna.html            # Dashboard pengguna
├── petugas.html             # Dashboard petugas keamanan
├── admin.html               # Dashboard administrator
├── test-database.html       # Testing database connection
├── README.md                # Dokumentasi ini
└── SETUP_XAMPP.md           # Panduan setup XAMPP
```

---

## 🔐 Kredensial Login

### **Pengguna (Mahasiswa/Dosen/Civitas)**
- **Email:** `pengguna@unila.ac.id`
- **Password:** `pengguna123`
- **Redirect:** pengguna.html

### **Petugas Keamanan**
- **Email:** `petugas@unila.ac.id`
- **Password:** `petugas123`
- **Redirect:** petugas.html

### **Administrator**
- **Email:** `admin@unila.ac.id`
- **Password:** `admin123`
- **Redirect:** admin.html

---

## 💾 Database Structure (MySQL)

Database: `siparkir`

### **Tabel Utama:**

### **1. admin**
```sql
CREATE TABLE admin (
    id_admin VARCHAR(10) PRIMARY KEY,
    nama VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) DEFAULT 'admin',
    status VARCHAR(20) DEFAULT 'aktif',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### **2. pengguna**
```sql
CREATE TABLE pengguna (
    id_pengguna VARCHAR(10) PRIMARY KEY,
    nama VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    nim VARCHAR(20) UNIQUE,
    no_telepon VARCHAR(20),
    alamat TEXT,
    role VARCHAR(20) DEFAULT 'pengguna',
    status VARCHAR(20) DEFAULT 'aktif',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### **3. petugas_keamanan**
```sql
CREATE TABLE petugas_keamanan (
    id_petugas VARCHAR(10) PRIMARY KEY,
    nama VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    nip VARCHAR(30) UNIQUE,
    no_telepon VARCHAR(20),
    shift VARCHAR(50),
    role VARCHAR(20) DEFAULT 'petugas',
    status VARCHAR(20) DEFAULT 'aktif',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### **4. kendaraan**
```sql
CREATE TABLE kendaraan (
    id_kendaraan VARCHAR(10) PRIMARY KEY,
    id_pengguna VARCHAR(10),
    plat_nomor VARCHAR(20) UNIQUE NOT NULL,
    jenis VARCHAR(20),
    merk VARCHAR(50),
    warna VARCHAR(30),
    tahun_produksi YEAR,
    status VARCHAR(20) DEFAULT 'pending',
    tanggal_registrasi TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_pengguna) REFERENCES pengguna(id_pengguna)
);
```

### **5. transaksi_parkir**
```sql
CREATE TABLE transaksi_parkir (
    id_transaksi VARCHAR(10) PRIMARY KEY,
    id_kendaraan VARCHAR(10),
    lokasi_parkir VARCHAR(100),
    waktu_masuk TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    waktu_keluar TIMESTAMP NULL,
    durasi_parkir INT,
    status VARCHAR(20) DEFAULT 'aktif',
    FOREIGN KEY (id_kendaraan) REFERENCES kendaraan(id_kendaraan)
);
```

### **6. laporan_kehilangan**
```sql
CREATE TABLE laporan_kehilangan (
    id_laporan VARCHAR(10) PRIMARY KEY,
    id_kendaraan VARCHAR(10),
    id_pengguna VARCHAR(10),
    lokasi_kehilangan VARCHAR(100),
    waktu_kejadian TIMESTAMP,
    kronologi TEXT,
    status VARCHAR(20) DEFAULT 'Investigasi',
    id_petugas VARCHAR(10),
    tanggal_lapor TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_kendaraan) REFERENCES kendaraan(id_kendaraan),
    FOREIGN KEY (id_pengguna) REFERENCES pengguna(id_pengguna),
    FOREIGN KEY (id_petugas) REFERENCES petugas_keamanan(id_petugas)
);
```

### **7. pencatatan_petugas**
```sql
CREATE TABLE pencatatan_petugas (
    id_pencatatan VARCHAR(10) PRIMARY KEY,
    id_petugas VARCHAR(10),
    plat_nomor VARCHAR(20),
    jenis_kendaraan VARCHAR(20),
    lokasi_penjagaan VARCHAR(100),
### **1. Login**
1. User masuk ke `login.html`
2. Input email & password
3. Sistem kirim request ke `api/login.php`
4. API query MySQL database untuk validasi kredensial
5. Jika valid, return user data dan set session
6. Redirect ke dashboard sesuai role (admin/pengguna/petugas)
```

### **8. verifikasi_kendaraan**
```sql
CREATE TABLE verifikasi_kendaraan (
    id_verifikasi VARCHAR(10) PRIMARY KEY,
    id_kendaraan VARCHAR(10),
    id_verifikator VARCHAR(10),
    tanggal_verifikasi TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status_verifikasi VARCHAR(20),
    catatan TEXT,
    FOREIGN KEY (id_kendaraan) REFERENCES kendaraan(id_kendaraan)
);
```

### **9. audit_log**
```sql
CREATE TABLE audit_log (
    id_log VARCHAR(10) PRIMARY KEY,
    id_user VARCHAR(10),
    role VARCHAR(20),
    aksi VARCHAR(100),
    detail TEXT,
    waktu TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### **Views untuk Reporting:**
- `view_transaksi_lengkap` - Join transaksi dengan data kendaraan & pengguna
- `view_laporan_lengkap` - Join laporan dengan data kendaraan & petugas
- `view_kendaraan_lengkap` - Join kendaraan dengan data pemilik
- `view_statistik_parkir` - Agregasi data parkir untuk dashboard

---

## 🔄 Alur Kerja Sistem

### **1. Login**
1. User masuk ke `login.html`
2. Input email & password
3. Sistem cek kredensial di `database.js`
4. Jika valid, set session dan redirect ke dashboard sesuai role

### **2. Registrasi Kendaraan (Pengguna)**
1. Pengguna input data kendaraan
2. Data disimpan dengan status 'pending'
3. Admin/Petugas verifikasi → status jadi 'aktif'
4. Kendaraan bisa digunakan untuk parkir

### **3. Check-In Parkir (Pengguna)**
1. Pengguna pilih kendaraan yang sudah terverifikasi
2. Pilih lokasi parkir
3. Sistem catat waktu masuk
4. Transaksi dibuat dengan status 'aktif'

### **4. Check-Out Parkir (Pengguna)**
1. Pengguna pilih kendaraan yang sedang parkir
2. Sistem hitung durasi parkir
3. Update transaksi: waktu keluar, durasi, status 'selesai'

### **5. Lapor Kehilangan (Pengguna → Petugas)**
1. Pengguna buat laporan
2. Petugas lihat di dashboard
3. Petugas update status atau selesaikan laporan

### **6. Verifikasi Kendaraan (Petugas/Admin)**
1. Lihat kendaraan dengan status 'pending'
2. Klik verifikasi
3. Status berubah jadi 'aktif'
4. Pemilik bisa gunakan untuk parkir

---

## 📊 Dashboard Statistik (Admin)

- **Total Pengguna:** Jumlah semua pengguna terdaftar
- **Kendaraan Terdaftar:** Jumlah semua kendaraan (aktif + pending)
- **Transaksi Hari Ini:** Jumlah check-in hari ini
- **Laporan Aktif:** Jumlah laporan yang belum selesai

Data auto-refresh setiap 30 detik.

## 🔧 Cara Menggunakan

### **Persiapan (Setup XAMPP):**

1. **Install XAMPP** (jika belum ada)
2. **Start Apache & MySQL** di XAMPP Control Panel
3. **Import Database:**
   ```powershell
   # Masuk ke direktori MySQL
   cd C:\xampp\mysql\bin
   
   # Buat database
   .\mysql.exe -u root -e "CREATE DATABASE IF NOT EXISTS siparkir CHARACTER SET utf8mb4"
   
   # Import SQL file
   .\mysql.exe -u root siparkir -e "source C:/xampp/htdocs/SIPARKIR/database/siparkir.sql"
   
   # Verifikasi
   .\mysql.exe -u root siparkir -e "SHOW TABLES"
   ```
4. **Pastikan file ada di:** `C:\xampp\htdocs\SIPARKIR\`

### **Menggunakan Aplikasi:**

1. **Buka browser** dan akses `http://localhost/SIPARKIR/login.html`
2. **Login** dengan salah satu kredensial di atas
3. **Mulai gunakan fitur** sesuai role Anda

> **Catatan:** Pastikan XAMPP Apache & MySQL sedang running!
2. **Login** dengan salah satu kredensial di atas
3. **Mulai gunakan fitur** sesuai role Anda

### **Contoh Skenario:**

#### **A. Sebagai Pengguna:**
1. Login → `pengguna@unila.ac.id` / `pengguna123`
2. Registrasi kendaraan baru (status: pending)
3. Tunggu verifikasi dari petugas/admin
4. Setelah terverifikasi, lakukan check-in parkir
5. Setelah selesai parkir, lakukan check-out

## 🛠️ Teknologi yang Digunakan

- **Frontend:** HTML5, CSS3, JavaScript (Vanilla ES6+)
- **Backend:** PHP 8.x with PDO
- **Database:** MySQL 5.7+ (via XAMPP)
- **Server:** Apache 2.4 (XAMPP)
- **API:** RESTful API with JSON responses
- **Icons:** Font Awesome 6.4.0
- **Charts:** Chart.js (untuk admin dashboard)
- **Fonts:** Google Fonts (Poppins)
## 📝 Catatan Penting

1. **Data disimpan di MySQL database** - Data persisten dan aman
2. **Memerlukan XAMPP** - Apache dan MySQL harus running
3. **Database Config** - `api/config.php` (host: localhost, user: root, no password)
4. **API Endpoints** - Semua API ada di folder `api/`
5. **Fallback localStorage** - Jika API gagal, sistem fallback ke localStorage
6. **Password plain-text** - Untuk demo purposes only (production harus di-hash)
7. **Auto-refresh 30 detik** - Bisa disesuaikan di script masing-masing halaman
## 🔮 Future Development

- [x] Database MySQL dengan XAMPP
- [x] RESTful API dengan PHP
- [ ] Password hashing (bcrypt/Argon2)
- [ ] Session management dengan PHP sessions
- [ ] Real-time notification (WebSocket)
- [ ] Export laporan ke PDF/Excel
- [ ] Upload foto kendaraan
- [ ] QR Code untuk tiket parkir
- [ ] Mobile App (React Native)
- [ ] Email notification (PHPMailer)
- [ ] Payment gateway (jika berbayar)
- [ ] JWT authentication
- [ ] Rate limiting & security headers
- [ ] Backup & restore database punya akses berbeda  
✅ **Data Validation** - Form validation & error handling  
✅ **Responsive Design** - Compatible dengan berbagai device  

---

## 🛠️ Teknologi yang Digunakan

- **Frontend:** HTML5, CSS3, JavaScript (Vanilla)
- **Database:** localStorage (Browser Storage)
- **Icons:** Font Awesome 6.4.0
- **Charts:** Chart.js (untuk admin dashboard)
- **Fonts:** Google Fonts (Poppins)

---

## 📝 Catatan Penting

1. **Data disimpan di localStorage browser** - Data akan hilang jika clear browser data
2. **Tidak ada backend server** - Sistem berjalan full client-side
3. **Password tidak di-hash** - Untuk demo purposes only
4. **Auto-refresh 30 detik** - Bisa disesuaikan di script masing-masing halaman

---

## 🔮 Future Development

- [ ] Backend dengan Node.js + Express
- [ ] Database MySQL/PostgreSQL
- [ ] Real-time notification (WebSocket)
- [ ] Export laporan ke PDF/Excel
- [ ] Upload foto kendaraan
- [ ] QR Code untuk tiket parkir
- [ ] Mobile App (React Native)
- [ ] Email notification
- [ ] Payment gateway (jika berbayar)

---

## 👨‍💻 Developer

**Sistem Parkir UNILA**  
Universitas Lampung  
© 2025

---

## 📞 Support

Jika ada pertanyaan atau issue, silakan hubungi:
- Email: support@siparkir.unila.ac.id
- WhatsApp: +62 xxx xxxx xxxx

---

**Selamat menggunakan SIPARKIR UNILA! 🚗🏫**
