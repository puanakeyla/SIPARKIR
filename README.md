# 🚗 SIPARKIR - Sistem Informasi Parkir Kampus

> **Sistem Parkir Digital Terintegrasi untuk Universitas Lampung**  
> Solusi modern untuk mengelola parkir kampus dengan monitoring real-time, laporan kehilangan, dan verifikasi kendaraan.

[![Status](https://img.shields.io/badge/status-active-success.svg)]()
[![License](https://img.shields.io/badge/license-MIT-blue.svg)]()
[![Version](https://img.shields.io/badge/version-1.0.0-green.svg)]()

---

## 📋 Daftar Isi

- [Tentang Project](#-tentang-project)
- [Fitur Utama](#-fitur-utama)
- [Teknologi](#-teknologi)
- [Instalasi](#-instalasi)
- [Penggunaan](#-penggunaan)
- [Struktur Database](#-struktur-database)
- [API Documentation](#-api-documentation)
- [User Roles](#-user-roles)
- [Screenshot](#-screenshot)
- [Kontributor](#-kontributor)

---

## 🎯 Tentang Project

**SIPARKIR** adalah sistem informasi parkir berbasis web yang dirancang khusus untuk lingkungan kampus. Sistem ini memungkinkan pengelolaan parkir yang efisien dengan fitur monitoring real-time, pencatatan transaksi, dan penanganan laporan kehilangan kendaraan.

### 🎓 Dikembangkan untuk:
- **Universitas Lampung (UNILA)**
- Mengelola 3 area parkir utama (A, B, C)
- Mendukung 3 role pengguna berbeda
- Integrasi dengan sistem keamanan kampus

---

## ✨ Fitur Utama

### 👤 **Portal Pengguna (Mahasiswa/Dosen)**
- ✅ Registrasi kendaraan pribadi
- ✅ Check-in/Check-out parkir mandiri
- ✅ Monitoring kendaraan parkir aktif
- ✅ Laporan kehilangan kendaraan
- ✅ Riwayat transaksi parkir
- ✅ Real-time durasi parkir

### 👮 **Portal Petugas Keamanan**
- ✅ Pencatatan kendaraan masuk/keluar
- ✅ Verifikasi identitas kendaraan
- ✅ Monitoring parkir aktif real-time
- ✅ Penanganan laporan kehilangan
- ✅ Update status laporan
- ✅ Riwayat pencatatan shift

### 🔐 **Portal Admin**
- ✅ Manajemen pengguna (CRUD)
- ✅ Manajemen petugas (CRUD)
- ✅ Manajemen kendaraan (CRUD)
- ✅ Verifikasi kendaraan baru
- ✅ Laporan dan statistik
- ✅ Audit log sistem

---

## 🛠 Teknologi

### Frontend
- **HTML5** - Struktur halaman
- **CSS3** - Styling dengan animated gradient
- **JavaScript ES6+** - Interaktivitas dan API calls
- **Font Awesome** - Icons
- **Google Fonts (Poppins)** - Typography

### Backend
- **PHP 8.x** - Server-side logic
- **PDO** - Database access layer
- **RESTful API** - Architecture pattern

### Database
- **MySQL 5.7+** - Relational database
- **9 Tables** - Normalized structure
- **4 Views** - Query optimization

### Server
- **XAMPP** - Local development environment
- **Apache 2.4** - Web server
- **phpMyAdmin** - Database management

---

## 📦 Instalasi

### Prasyarat
```bash
✅ XAMPP (Apache + MySQL + PHP 8.0+)
✅ Web Browser Modern (Chrome/Firefox/Edge)
✅ Git (optional)
```

### Langkah Instalasi

1. **Clone Repository**
```bash
cd C:\xampp\htdocs
git clone https://github.com/puanakeyla/SIPARKIR.git
```

2. **Import Database**
```bash
# Buka phpMyAdmin (http://localhost/phpmyadmin)
# Buat database baru bernama: siparkir
# Import file: database/siparkir.sql
```

3. **Konfigurasi Database**
```php
// File: api/config.php (sudah dikonfigurasi)
$host = 'localhost';
$dbname = 'siparkir';
$username = 'root';
$password = ''; // default XAMPP
```

4. **Start XAMPP**
```
- Jalankan Apache
- Jalankan MySQL
```

5. **Akses Aplikasi**
```
http://localhost/SIPARKIR/login.html
```

---

## 🚀 Penggunaan

### Default Credentials

| Role | Email | Password |
|------|-------|----------|
| **Admin** | admin@unila.ac.id | admin123 |
| **Pengguna** | pengguna@unila.ac.id | pengguna123 |
| **Petugas** | petugas@unila.ac.id | petugas123 |

### Flow Penggunaan

#### 1️⃣ **Sebagai Pengguna**
```
Login → Registrasi Kendaraan → Check-in Parkir → Check-out Parkir
```

#### 2️⃣ **Sebagai Petugas**
```
Login → Catat Kendaraan Masuk/Keluar → Verifikasi Identitas → Handle Laporan
```

#### 3️⃣ **Sebagai Admin**
```
Login → Kelola User → Kelola Kendaraan → Monitor Aktivitas → Generate Report
```

---

## 💾 Struktur Database

### Tabel Utama (9 Tables)

| Tabel | Deskripsi | Primary Key |
|-------|-----------|-------------|
| `admin` | Data administrator sistem | id_admin |
| `pengguna` | Data mahasiswa/dosen | id_pengguna |
| `petugas_keamanan` | Data petugas keamanan | id_petugas |
| `kendaraan` | Data kendaraan terdaftar | id_kendaraan |
| `transaksi_parkir` | Transaksi check-in/out | id_transaksi |
| `laporan_kehilangan` | Laporan kehilangan | id_laporan |
| `pencatatan_petugas` | Log pencatatan petugas | id_pencatatan |
| `verifikasi_kendaraan` | Riwayat verifikasi | id_verifikasi |
| `audit_log` | Log aktivitas sistem | id_audit |

### Views (4 Views)
- `view_kendaraan_aktif` - Kendaraan dengan status aktif
- `view_parkir_aktif` - Transaksi parkir yang sedang berlangsung
- `view_laporan_pending` - Laporan yang belum selesai
- `view_statistik_harian` - Statistik parkir harian

---

## 🔌 API Documentation

### Base URL
```
http://localhost/SIPARKIR/api/
```

### Endpoints

#### Authentication
```http
POST /api/login.php
Body: { "email": "user@email.com", "password": "password" }
Response: { "success": true, "data": {...}, "redirect": "page.html" }
```

#### Kendaraan
```http
GET    /api/kendaraan.php              # Get all
GET    /api/kendaraan.php?id={id}      # Get by ID
GET    /api/kendaraan.php?id_pengguna={id}  # Get by user
POST   /api/kendaraan.php              # Create new
PUT    /api/kendaraan.php              # Update
DELETE /api/kendaraan.php              # Delete
```

#### Transaksi Parkir
```http
GET  /api/transaksi.php?status=aktif   # Get active
POST /api/transaksi.php
Body: { "action": "checkin", "id_kendaraan": "KND001", ... }

POST /api/transaksi.php
Body: { "action": "checkout", "id_transaksi": "TRX001" }
```

#### Laporan Kehilangan
```http
GET  /api/laporan.php?id_pengguna={id}  # Get by user
POST /api/laporan.php                    # Create report
PUT  /api/laporan.php                    # Update status
```

#### Pencatatan Petugas
```http
GET  /api/pencatatan.php                # Get all
POST /api/pencatatan.php                # Create log
```

### Response Format
```json
{
  "success": true,
  "message": "Success message",
  "data": { ... }
}
```

---

## 👥 User Roles

### 🔵 Admin
- Full access ke semua fitur
- CRUD semua data
- Verifikasi kendaraan
- Generate reports
- Audit log management

### 🟢 Pengguna (Mahasiswa/Dosen)
- Registrasi kendaraan
- Check-in/out parkir
- Lapor kehilangan
- View riwayat pribadi

### 🟡 Petugas Keamanan
- Catat kendaraan masuk/keluar
- Verifikasi identitas
- Handle laporan kehilangan
- Monitor parkir aktif
- Update status laporan

---

## 📸 Screenshot

### Login Page
![Login](https://via.placeholder.com/800x400?text=Login+Page)

### Dashboard Pengguna
![Pengguna](https://via.placeholder.com/800x400?text=Dashboard+Pengguna)

### Dashboard Petugas
![Petugas](https://via.placeholder.com/800x400?text=Dashboard+Petugas)

### Dashboard Admin
![Admin](https://via.placeholder.com/800x400?text=Dashboard+Admin)

---

## 📁 Struktur Folder

```
SIPARKIR/
├── 📄 login.html              # Halaman login universal
├── 📄 admin.html              # Dashboard admin
├── 📄 pengguna.html           # Dashboard pengguna
├── 📄 petugas.html            # Dashboard petugas
│
├── 📁 api/                    # REST API Endpoints
│   ├── config.php             # Database configuration
│   ├── login.php              # Authentication
│   ├── kendaraan.php          # Kendaraan CRUD
│   ├── transaksi.php          # Transaksi parkir
│   ├── laporan.php            # Laporan kehilangan
│   ├── pencatatan.php         # Pencatatan petugas
│   ├── pengguna.php           # Pengguna CRUD
│   ├── petugas.php            # Petugas CRUD
│   └── verifikasi.php         # Verifikasi kendaraan
│
├── 📁 database/               # Database Files
│   ├── siparkir.sql           # Full database schema
│   └── SEQUENCE_DIAGRAMS_GENERAL.md
│
└── 📁 js/                     # JavaScript (legacy)
    ├── database.js
    └── database-api.js
```

---

## 🔒 Security Features

- ✅ **PDO Prepared Statements** - SQL Injection protection
- ✅ **Password Hashing** - Secure password storage
- ✅ **Session Management** - LocalStorage with role validation
- ✅ **Input Validation** - Client & server-side validation
- ✅ **CORS Protection** - API access control
- ✅ **Audit Logging** - Track all system activities

---

## 🚧 Known Issues & TODO

### Current Issues
- [ ] Upload foto kendaraan (feature disabled)
- [ ] Export PDF laporan
- [ ] Email notification

### Future Enhancements
- [ ] Mobile responsive optimization
- [ ] Push notifications
- [ ] QR Code untuk check-in
- [ ] Payment integration
- [ ] Analytics dashboard
- [ ] Multi-language support

---

## 🤝 Kontributor

### Development Team

| Nama | Role | GitHub |
|------|------|--------|
| **Akeyla** | Full Stack Developer | [@puanakeyla](https://github.com/puanakeyla) |

---

## 📝 License

Project ini menggunakan [MIT License](LICENSE).

```
Copyright (c) 2025 SIPARKIR Team

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software...
```

---

## 📞 Support

Jika mengalami kendala atau ada pertanyaan:

- 📧 Email: support@siparkir.unila.ac.id
- 🐛 Issues: [GitHub Issues](https://github.com/puanakeyla/SIPARKIR/issues)
- 📖 Docs: [Wiki](https://github.com/puanakeyla/SIPARKIR/wiki)

---

## 🙏 Acknowledgments

- **Universitas Lampung** - Untuk dukungan dan feedback
- **Font Awesome** - Icon library
- **Google Fonts** - Typography (Poppins)
- **XAMPP Team** - Development environment

---

## 📊 Statistics

![GitHub repo size](https://img.shields.io/github/repo-size/puanakeyla/SIPARKIR)
![GitHub language count](https://img.shields.io/github/languages/count/puanakeyla/SIPARKIR)
![GitHub top language](https://img.shields.io/github/languages/top/puanakeyla/SIPARKIR)
![GitHub last commit](https://img.shields.io/github/last-commit/puanakeyla/SIPARKIR)

---

<div align="center">

**Made with ❤️ by SIPARKIR Team**

⭐ Star this repo if you find it helpful!

</div>
