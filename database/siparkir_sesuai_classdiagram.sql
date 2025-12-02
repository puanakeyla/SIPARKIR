-- ============================================
-- SIPARKIR UNILA - Database MySQL
-- 100% SESUAI CLASS DIAGRAM
-- ============================================

DROP DATABASE IF EXISTS siparkir;
CREATE DATABASE siparkir;
USE siparkir;

-- ============================================
-- TABEL 1: Admin
-- Sesuai Class Diagram
-- ============================================
CREATE TABLE admin (
    id_admin VARCHAR(20) PRIMARY KEY,
    nama VARCHAR(100) NOT NULL,
    username VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ============================================
-- TABEL 2: Pengguna
-- Sesuai Class Diagram (+ field tambahan untuk kebutuhan sistem)
-- ============================================
CREATE TABLE pengguna (
    id_pengguna VARCHAR(20) PRIMARY KEY,
    nama VARCHAR(100) NOT NULL,
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    peran VARCHAR(50) DEFAULT 'mahasiswa', -- mahasiswa, dosen, civitas
    status VARCHAR(20) DEFAULT 'aktif',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ============================================
-- TABEL 3: Petugas Keamanan
-- Sesuai Class Diagram
-- ============================================
CREATE TABLE petugas_keamanan (
    id_petugas VARCHAR(20) PRIMARY KEY,
    nama VARCHAR(100) NOT NULL,
    username VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    shift VARCHAR(50),
    status VARCHAR(20) DEFAULT 'aktif',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ============================================
-- TABEL 4: Kendaraan
-- Sesuai Class Diagram
-- ============================================
CREATE TABLE kendaraan (
    id_kendaraan VARCHAR(20) PRIMARY KEY,
    id_pengguna VARCHAR(20) NOT NULL,
    plat_nomor VARCHAR(20) UNIQUE NOT NULL,
    merk VARCHAR(50) NOT NULL,
    tipe VARCHAR(50) NOT NULL,
    warna VARCHAR(30) NOT NULL,
    tahun_pembuatan INT,
    foto_kendaraan VARCHAR(255),
    status_parkir VARCHAR(20) DEFAULT 'aktif',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (id_pengguna) REFERENCES pengguna(id_pengguna) ON DELETE CASCADE,
    INDEX idx_pengguna (id_pengguna),
    INDEX idx_plat (plat_nomor)
);

-- ============================================
-- TABEL 5: Riwayat Parkir
-- Sesuai Class Diagram (relasi dengan Kendaraan)
-- ============================================
CREATE TABLE riwayat_parkir (
    id_riwayat VARCHAR(20) PRIMARY KEY,
    id_kendaraan VARCHAR(20) NOT NULL,
    waktu_masuk DATETIME NOT NULL,
    waktu_keluar DATETIME,
    lokasi_parkir VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (id_kendaraan) REFERENCES kendaraan(id_kendaraan) ON DELETE CASCADE,
    INDEX idx_kendaraan (id_kendaraan)
);

-- ============================================
-- TABEL 6: Laporan Kehilangan
-- Sesuai Class Diagram (relasi dengan Pengguna, Petugas, Kendaraan)
-- ============================================
CREATE TABLE laporan_kehilangan (
    id_laporan VARCHAR(20) PRIMARY KEY,
    id_pengguna VARCHAR(20) NOT NULL,
    id_petugas VARCHAR(20),
    id_kendaraan VARCHAR(20) NOT NULL,
    tanggal_laporan DATETIME NOT NULL,
    waktu_kejadian DATETIME NOT NULL,
    lokasi_kehilangan VARCHAR(100) NOT NULL,
    deskripsi TEXT NOT NULL,
    status_laporan VARCHAR(50) DEFAULT 'Pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (id_pengguna) REFERENCES pengguna(id_pengguna) ON DELETE CASCADE,
    FOREIGN KEY (id_petugas) REFERENCES petugas_keamanan(id_petugas) ON DELETE SET NULL,
    FOREIGN KEY (id_kendaraan) REFERENCES kendaraan(id_kendaraan) ON DELETE CASCADE,
    INDEX idx_pengguna (id_pengguna),
    INDEX idx_petugas (id_petugas),
    INDEX idx_status (status_laporan)
);

-- ============================================
-- TABEL 7: Sistem Parkir
-- Sesuai Class Diagram (untuk monitoring sistem)
-- ============================================
-- TABEL 7: Sistem Parkir
-- Sesuai Class Diagram (untuk monitoring sistem)
-- Relasi: Admin (1) ---< mengelola >--- (*) Sistem Parkir
-- ============================================
CREATE TABLE sistem_parkir (
    id_sistem VARCHAR(20) PRIMARY KEY,
    id_admin VARCHAR(20) NOT NULL,
    status_sistem VARCHAR(50) DEFAULT 'Aktif',
    waktu_monitoring DATETIME DEFAULT CURRENT_TIMESTAMP,
    generated_laporan TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (id_admin) REFERENCES admin(id_admin) ON DELETE CASCADE,
    INDEX idx_admin (id_admin)
);

-- ============================================
-- DATA SAMPLE
-- ============================================

-- Admin
INSERT INTO admin (id_admin, nama, username, password) VALUES
('ADM001', 'Administrator', 'admin@unila.ac.id', 'admin123');

-- Pengguna
INSERT INTO pengguna (id_pengguna, nama, username, email, password, peran, status) VALUES
('USR001', 'Andi Pratama', 'pengguna@unila.ac.id', 'pengguna@unila.ac.id', 'pengguna123', 'mahasiswa', 'aktif'),
('USR002', 'Siti Nurhaliza', 'siti.nurhaliza', 'siti.nurhaliza@student.unila.ac.id', 'password123', 'mahasiswa', 'aktif'),
('USR003', 'Dr. Budi Susanto', 'budi.susanto', 'budi.susanto@staff.unila.ac.id', 'password123', 'dosen', 'aktif');

-- Petugas Keamanan
INSERT INTO petugas_keamanan (id_petugas, nama, username, password, shift, status) VALUES
('PTG001', 'Budi Santoso', 'petugas@unila.ac.id', 'petugas123', 'Pagi (07:00 - 15:00)', 'aktif'),
('PTG002', 'Siti Nurjanah', 'siti.nurjanah', 'password123', 'Siang (15:00 - 23:00)', 'aktif'),
('PTG003', 'Ahmad Yani', 'ahmad.yani', 'password123', 'Malam (23:00 - 07:00)', 'aktif');

-- Kendaraan
INSERT INTO kendaraan (id_kendaraan, id_pengguna, plat_nomor, merk, tipe, warna, tahun_pembuatan, status_parkir) VALUES
('KND001', 'USR001', 'B 1234 ABC', 'Honda', 'Beat', 'Hitam', 2022, 'aktif'),
('KND002', 'USR001', 'B 5678 XYZ', 'Yamaha', 'NMAX', 'Putih', 2021, 'aktif'),
('KND003', 'USR002', 'B 9876 DEF', 'Honda', 'Vario 160', 'Merah', 2023, 'aktif'),
('KND004', 'USR003', 'B 1111 GHI', 'Toyota', 'Avanza', 'Silver', 2020, 'aktif');

-- Riwayat Parkir
INSERT INTO riwayat_parkir (id_riwayat, id_kendaraan, waktu_masuk, waktu_keluar, lokasi_parkir) VALUES
('RWY001', 'KND001', '2025-12-01 08:00:00', '2025-12-01 17:00:00', 'Parkiran A - Fakultas Teknik'),
('RWY002', 'KND002', '2025-12-01 07:30:00', NULL, 'Parkiran B - Fakultas Ekonomi'),
('RWY003', 'KND003', '2025-12-01 09:00:00', '2025-12-01 15:00:00', 'Parkiran C - Rektorat'),
('RWY004', 'KND004', '2025-12-01 08:30:00', NULL, 'Parkiran D - Gedung Kuliah Bersama');

-- Laporan Kehilangan
INSERT INTO laporan_kehilangan (id_laporan, id_pengguna, id_petugas, id_kendaraan, tanggal_laporan, waktu_kejadian, lokasi_kehilangan, deskripsi, status_laporan) VALUES
('LAP001', 'USR001', 'PTG001', 'KND001', '2025-11-30 15:00:00', '2025-11-30 14:30:00', 'Parkiran A - Fakultas Teknik', 'Motor hilang saat kuliah, terakhir diparkir jam 08:00', 'Dalam Investigasi'),
('LAP002', 'USR002', NULL, 'KND003', '2025-11-29 10:00:00', '2025-11-29 09:00:00', 'Parkiran C - Rektorat', 'Helm hilang dari jok motor', 'Pending');

-- Sistem Parkir (dikelola oleh Admin)
INSERT INTO sistem_parkir (id_sistem, id_admin, status_sistem, waktu_monitoring, generated_laporan) VALUES
('SYS001', 'ADM001', 'Aktif', NOW(), NULL);

-- ============================================
-- END OF SQL
-- ============================================
