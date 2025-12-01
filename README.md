# SIPARKIR UNILA - Sistem Parkir Kampus

Sistem Informasi Parkir Universitas Lampung yang terintegrasi dengan database real-time menggunakan localStorage.

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
APPL/
├── js/
│   └── database.js          # Database manager (localStorage)
├── login.html               # Halaman login universal (3 role)
├── pengguna.html            # Dashboard pengguna
├── petugas.html             # Dashboard petugas
├── admin.html               # Dashboard admin
└── README.md                # Dokumentasi ini
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

## 💾 Database Structure (localStorage)

### **1. siparkir_pengguna**
```javascript
{
    id: 'USR001',
    nama: 'Andi Pratama',
    email: 'pengguna@unila.ac.id',
    password: 'pengguna123',
    nim: '2315061001',
    role: 'pengguna',
    status: 'aktif'
}
```

### **2. siparkir_petugas**
```javascript
{
    id: 'PTG001',
    nama: 'Budi Santoso',
    email: 'petugas@unila.ac.id',
    password: 'petugas123',
    nip: '198501012010011001',
    shift: 'Pagi (07:00 - 15:00)',
    role: 'petugas',
    status: 'aktif'
}
```

### **3. siparkir_admin**
```javascript
{
    id: 'ADM001',
    nama: 'Administrator',
    email: 'admin@unila.ac.id',
    password: 'admin123',
    role: 'admin',
    status: 'aktif'
}
```

### **4. siparkir_kendaraan**
```javascript
{
    id: 'KND001',
    pemilikId: 'USR001',
    platNomor: 'B 1234 ABC',
    merk: 'Honda',
    tipe: 'Beat',
    warna: 'Hitam',
    tahun: 2022,
    status: 'aktif' // atau 'pending'
}
```

### **5. siparkir_transaksi_parkir**
```javascript
{
    id: 'TRX001',
    kendaraanId: 'KND001',
    platNomor: 'B 1234 ABC',
    penggunaId: 'USR001',
    lokasiParkir: 'Parkiran A',
    waktuMasuk: '2025-12-01T07:30:00',
    waktuKeluar: null,
    durasi: null,
    status: 'aktif' // atau 'selesai'
}
```

### **6. siparkir_laporan_kehilangan**
```javascript
{
    id: 'LAP001',
    kendaraanId: 'KND002',
    platNomor: 'B 5678 XYZ',
    penggunaId: 'USR001',
    pelaporNama: 'Andi Pratama',
    lokasiKehilangan: 'Parkiran B',
    waktuKejadian: '2025-12-01T10:30:00',
    kronologi: 'Kendaraan hilang saat parkir...',
    buktiPendukung: '',
    status: 'Investigasi', // atau 'Selesai'
    petugasId: null,
    tanggalLapor: '2025-12-01T10:35:00'
}
```

### **7. siparkir_pencatatan_petugas**
```javascript
{
    id: 'PNC001',
    platNomor: 'B 1234 ABC',
    jenisKendaraan: 'Motor',
    lokasiPenjagaan: 'Gerbang Utama',
    statusTransaksi: 'Masuk', // atau 'Keluar'
    catatan: '',
    petugasId: 'PTG001',
    petugasNama: 'Budi Santoso',
    waktu: '2025-12-01T07:45:00'
}
```

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

---

## 🔧 Cara Menggunakan

1. **Buka file `login.html`** di browser
2. **Login** dengan salah satu kredensial di atas
3. **Mulai gunakan fitur** sesuai role Anda

### **Contoh Skenario:**

#### **A. Sebagai Pengguna:**
1. Login → `pengguna@unila.ac.id` / `pengguna123`
2. Registrasi kendaraan baru (status: pending)
3. Tunggu verifikasi dari petugas/admin
4. Setelah terverifikasi, lakukan check-in parkir
5. Setelah selesai parkir, lakukan check-out

#### **B. Sebagai Petugas:**
1. Login → `petugas@unila.ac.id` / `petugas123`
2. Verifikasi kendaraan yang pending
3. Catat kendaraan keluar/masuk di pos jaga
4. Tangani laporan kehilangan dari pengguna

#### **C. Sebagai Admin:**
1. Login → `admin@unila.ac.id` / `admin123`
2. Monitoring dashboard (lihat statistik real-time)
3. Kelola database kendaraan & pengguna
4. Tambah petugas baru
5. Verifikasi kendaraan jika diperlukan

---

## 🌟 Fitur Unggulan

✅ **Real-Time Sync** - Semua data tersinkron antar halaman  
✅ **Session Management** - Login persisten sampai logout  
✅ **Auto Refresh** - Data update otomatis setiap 30 detik  
✅ **Role-Based Access** - Setiap role punya akses berbeda  
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
