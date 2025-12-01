-- ============================================
-- SIPARKIR UNILA - Database Schema
-- Sistem Informasi Parkir Universitas Lampung
-- ============================================

-- Drop tables if exists (untuk clean install)
DROP TABLE IF EXISTS pencatatan_petugas;
DROP TABLE IF EXISTS verifikasi_kendaraan;
DROP TABLE IF EXISTS laporan_kehilangan;
DROP TABLE IF EXISTS transaksi_parkir;
DROP TABLE IF EXISTS kendaraan;
DROP TABLE IF EXISTS petugas_keamanan;
DROP TABLE IF EXISTS pengguna;
DROP TABLE IF EXISTS admin;

-- ============================================
-- Table: admin
-- Deskripsi: Menyimpan data administrator sistem
-- ============================================
CREATE TABLE admin (
    id_admin VARCHAR(20) PRIMARY KEY,
    nama VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) DEFAULT 'admin',
    status VARCHAR(20) DEFAULT 'aktif',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ============================================
-- Table: pengguna
-- Deskripsi: Menyimpan data pengguna (mahasiswa/dosen/civitas)
-- ============================================
CREATE TABLE pengguna (
    id_pengguna VARCHAR(20) PRIMARY KEY,
    nama VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    nim VARCHAR(20),
    peran VARCHAR(50) DEFAULT 'mahasiswa', -- mahasiswa, dosen, civitas
    role VARCHAR(20) DEFAULT 'pengguna',
    status VARCHAR(20) DEFAULT 'aktif',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ============================================
-- Table: petugas_keamanan
-- Deskripsi: Menyimpan data petugas keamanan
-- ============================================
CREATE TABLE petugas_keamanan (
    id_petugas VARCHAR(20) PRIMARY KEY,
    nama VARCHAR(100) NOT NULL,
    nip VARCHAR(30),
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    shift VARCHAR(50), -- Pagi, Siang, Malam
    role VARCHAR(20) DEFAULT 'petugas',
    status VARCHAR(20) DEFAULT 'aktif',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ============================================
-- Table: kendaraan
-- Deskripsi: Menyimpan data kendaraan yang terdaftar
-- ============================================
CREATE TABLE kendaraan (
    id_kendaraan VARCHAR(20) PRIMARY KEY,
    id_pengguna VARCHAR(20) NOT NULL,
    plat_nomor VARCHAR(20) UNIQUE NOT NULL,
    merk VARCHAR(50) NOT NULL,
    tipe VARCHAR(50) NOT NULL,
    warna VARCHAR(30) NOT NULL,
    tahun_pembuatan INT,
    foto_dokumen VARCHAR(255),
    status VARCHAR(20) DEFAULT 'pending', -- pending, aktif, nonaktif
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (id_pengguna) REFERENCES pengguna(id_pengguna) ON DELETE CASCADE,
    INDEX idx_pengguna (id_pengguna),
    INDEX idx_plat (plat_nomor),
    INDEX idx_status (status)
);

-- ============================================
-- Table: transaksi_parkir
-- Deskripsi: Menyimpan transaksi check-in dan check-out parkir
-- ============================================
CREATE TABLE transaksi_parkir (
    id_transaksi VARCHAR(20) PRIMARY KEY,
    id_kendaraan VARCHAR(20) NOT NULL,
    id_pengguna VARCHAR(20) NOT NULL,
    plat_nomor VARCHAR(20) NOT NULL,
    lokasi_parkir VARCHAR(100) NOT NULL,
    waktu_masuk DATETIME NOT NULL,
    waktu_keluar DATETIME,
    durasi_menit INT,
    biaya DECIMAL(10,2) DEFAULT 0,
    status VARCHAR(20) DEFAULT 'aktif', -- aktif, selesai
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (id_kendaraan) REFERENCES kendaraan(id_kendaraan) ON DELETE CASCADE,
    FOREIGN KEY (id_pengguna) REFERENCES pengguna(id_pengguna) ON DELETE CASCADE,
    INDEX idx_kendaraan (id_kendaraan),
    INDEX idx_pengguna (id_pengguna),
    INDEX idx_status (status),
    INDEX idx_waktu_masuk (waktu_masuk)
);

-- ============================================
-- Table: laporan_kehilangan
-- Deskripsi: Menyimpan laporan kehilangan kendaraan
-- ============================================
CREATE TABLE laporan_kehilangan (
    id_laporan VARCHAR(20) PRIMARY KEY,
    id_kendaraan VARCHAR(20) NOT NULL,
    id_pengguna VARCHAR(20) NOT NULL,
    id_petugas VARCHAR(20),
    plat_nomor VARCHAR(20) NOT NULL,
    pelapor_nama VARCHAR(100) NOT NULL,
    lokasi_kehilangan VARCHAR(100) NOT NULL,
    waktu_kejadian DATETIME NOT NULL,
    kronologi TEXT NOT NULL,
    bukti_pendukung VARCHAR(255),
    status VARCHAR(50) DEFAULT 'Investigasi', -- Investigasi, Dalam Patroli, Selesai
    tanggal_lapor TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    tanggal_selesai DATETIME,
    catatan_petugas TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (id_kendaraan) REFERENCES kendaraan(id_kendaraan) ON DELETE CASCADE,
    FOREIGN KEY (id_pengguna) REFERENCES pengguna(id_pengguna) ON DELETE CASCADE,
    FOREIGN KEY (id_petugas) REFERENCES petugas_keamanan(id_petugas) ON DELETE SET NULL,
    INDEX idx_kendaraan (id_kendaraan),
    INDEX idx_pengguna (id_pengguna),
    INDEX idx_petugas (id_petugas),
    INDEX idx_status (status)
);

-- ============================================
-- Table: pencatatan_petugas
-- Deskripsi: Menyimpan pencatatan kendaraan keluar/masuk oleh petugas
-- ============================================
CREATE TABLE pencatatan_petugas (
    id_pencatatan VARCHAR(20) PRIMARY KEY,
    id_petugas VARCHAR(20) NOT NULL,
    plat_nomor VARCHAR(20) NOT NULL,
    jenis_kendaraan VARCHAR(50) NOT NULL, -- Motor, Mobil, Truk
    lokasi_penjagaan VARCHAR(100) NOT NULL,
    status_transaksi VARCHAR(20) NOT NULL, -- Masuk, Keluar
    waktu_pencatatan DATETIME NOT NULL,
    catatan TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (id_petugas) REFERENCES petugas_keamanan(id_petugas) ON DELETE CASCADE,
    INDEX idx_petugas (id_petugas),
    INDEX idx_plat (plat_nomor),
    INDEX idx_waktu (waktu_pencatatan)
);

-- ============================================
-- Table: verifikasi_kendaraan
-- Deskripsi: Menyimpan riwayat verifikasi kendaraan oleh petugas/admin
-- ============================================
CREATE TABLE verifikasi_kendaraan (
    id_verifikasi VARCHAR(20) PRIMARY KEY,
    id_kendaraan VARCHAR(20) NOT NULL,
    id_petugas VARCHAR(20),
    plat_nomor VARCHAR(20) NOT NULL,
    status_verifikasi VARCHAR(50) NOT NULL, -- Valid, Tidak Valid, Mencurigakan
    catatan TEXT,
    waktu_verifikasi DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (id_kendaraan) REFERENCES kendaraan(id_kendaraan) ON DELETE CASCADE,
    FOREIGN KEY (id_petugas) REFERENCES petugas_keamanan(id_petugas) ON DELETE SET NULL,
    INDEX idx_kendaraan (id_kendaraan),
    INDEX idx_petugas (id_petugas)
);

-- ============================================
-- Insert Sample Data
-- ============================================

-- Insert Admin
INSERT INTO admin (id_admin, nama, email, password, role, status) VALUES
('ADM001', 'Administrator', 'admin@unila.ac.id', 'admin123', 'admin', 'aktif');

-- Insert Pengguna
INSERT INTO pengguna (id_pengguna, nama, email, password, nim, peran, role, status) VALUES
('USR001', 'Andi Pratama', 'pengguna@unila.ac.id', 'pengguna123', '2315061001', 'mahasiswa', 'pengguna', 'aktif'),
('USR002', 'Siti Nurhaliza', 'siti.nurhaliza@student.unila.ac.id', 'password123', '2315061002', 'mahasiswa', 'pengguna', 'aktif'),
('USR003', 'Dr. Bambang Susilo', 'bambang.susilo@unila.ac.id', 'password123', NULL, 'dosen', 'pengguna', 'aktif');

-- Insert Petugas
INSERT INTO petugas_keamanan (id_petugas, nama, nip, email, password, shift, role, status) VALUES
('PTG001', 'Budi Santoso', '198501012010011001', 'petugas@unila.ac.id', 'petugas123', 'Pagi (07:00 - 15:00)', 'petugas', 'aktif'),
('PTG002', 'Siti Nurjanah', '199003152015032002', 'siti.nurjanah@unila.ac.id', 'password123', 'Siang (15:00 - 23:00)', 'petugas', 'aktif'),
('PTG003', 'Ahmad Rifai', '198712202012011003', 'ahmad.rifai@unila.ac.id', 'password123', 'Malam (23:00 - 07:00)', 'petugas', 'aktif');

-- Insert Kendaraan
INSERT INTO kendaraan (id_kendaraan, id_pengguna, plat_nomor, merk, tipe, warna, tahun_pembuatan, status) VALUES
('KND001', 'USR001', 'B 1234 ABC', 'Honda', 'Beat', 'Hitam', 2022, 'aktif'),
('KND002', 'USR001', 'B 5678 XYZ', 'Yamaha', 'NMAX', 'Putih', 2021, 'aktif'),
('KND003', 'USR002', 'B 9876 DEF', 'Suzuki', 'Satria', 'Merah', 2023, 'pending'),
('KND004', 'USR003', 'B 1111 GHI', 'Toyota', 'Avanza', 'Silver', 2020, 'aktif');

-- Insert Transaksi Parkir
INSERT INTO transaksi_parkir (id_transaksi, id_kendaraan, id_pengguna, plat_nomor, lokasi_parkir, waktu_masuk, waktu_keluar, durasi_menit, status) VALUES
('TRX001', 'KND001', 'USR001', 'B 1234 ABC', 'Parkiran A - Gedung Rektorat', '2025-12-01 07:30:00', NULL, NULL, 'aktif'),
('TRX002', 'KND002', 'USR001', 'B 5678 XYZ', 'Parkiran B - Fakultas Teknik', '2025-11-30 08:00:00', '2025-11-30 16:30:00', 510, 'selesai'),
('TRX003', 'KND004', 'USR003', 'B 1111 GHI', 'Parkiran C - Fakultas Ekonomi', '2025-11-30 09:15:00', '2025-11-30 14:45:00', 330, 'selesai');

-- Insert Laporan Kehilangan
INSERT INTO laporan_kehilangan (id_laporan, id_kendaraan, id_pengguna, id_petugas, plat_nomor, pelapor_nama, lokasi_kehilangan, waktu_kejadian, kronologi, status) VALUES
('LAP001', 'KND002', 'USR001', 'PTG001', 'B 5678 XYZ', 'Andi Pratama', 'Parkiran B - Fakultas Teknik', '2025-12-01 10:30:00', 'Kendaraan hilang saat parkir di area fakultas teknik. Terakhir terlihat pukul 10:00 WIB.', 'Investigasi'),
('LAP002', 'KND001', 'USR001', NULL, 'B 1234 ABC', 'Andi Pratama', 'Parkiran A - Gedung Rektorat', '2025-11-29 14:00:00', 'Motor hilang di area parkir gedung rektorat.', 'Selesai');

-- Insert Pencatatan Petugas
INSERT INTO pencatatan_petugas (id_pencatatan, id_petugas, plat_nomor, jenis_kendaraan, lokasi_penjagaan, status_transaksi, waktu_pencatatan, catatan) VALUES
('PNC001', 'PTG001', 'B 1234 ABC', 'Motor', 'Gerbang Utama', 'Masuk', '2025-12-01 07:45:00', 'Kendaraan dalam kondisi baik'),
('PNC002', 'PTG001', 'B 5678 XYZ', 'Motor', 'Gerbang Utama', 'Masuk', '2025-12-01 08:15:00', NULL),
('PNC003', 'PTG002', 'B 1111 GHI', 'Mobil', 'Gerbang Teknik', 'Keluar', '2025-12-01 16:30:00', NULL);

-- Insert Verifikasi Kendaraan
INSERT INTO verifikasi_kendaraan (id_verifikasi, id_kendaraan, id_petugas, plat_nomor, status_verifikasi, catatan, waktu_verifikasi) VALUES
('VRF001', 'KND001', 'PTG001', 'B 1234 ABC', 'Valid', 'Dokumen lengkap dan sesuai', '2025-11-20 09:00:00'),
('VRF002', 'KND002', 'PTG001', 'B 5678 XYZ', 'Valid', 'Semua dokumen terverifikasi', '2025-11-20 09:30:00'),
('VRF003', 'KND004', 'PTG001', 'B 1111 GHI', 'Valid', 'Kendaraan dosen terverifikasi', '2025-11-21 10:00:00');

-- ============================================
-- Views untuk kemudahan query
-- ============================================

-- View: Data lengkap kendaraan dengan pemilik
CREATE VIEW view_kendaraan_lengkap AS
SELECT 
    k.id_kendaraan,
    k.plat_nomor,
    k.merk,
    k.tipe,
    k.warna,
    k.tahun_pembuatan,
    k.status AS status_kendaraan,
    p.id_pengguna,
    p.nama AS nama_pemilik,
    p.nim,
    p.peran,
    p.email
FROM kendaraan k
INNER JOIN pengguna p ON k.id_pengguna = p.id_pengguna;

-- View: Transaksi parkir aktif
CREATE VIEW view_parkir_aktif AS
SELECT 
    t.id_transaksi,
    t.plat_nomor,
    t.lokasi_parkir,
    t.waktu_masuk,
    TIMESTAMPDIFF(MINUTE, t.waktu_masuk, NOW()) AS durasi_menit_sekarang,
    k.merk,
    k.tipe,
    p.nama AS nama_pemilik,
    p.peran
FROM transaksi_parkir t
INNER JOIN kendaraan k ON t.id_kendaraan = k.id_kendaraan
INNER JOIN pengguna p ON t.id_pengguna = p.id_pengguna
WHERE t.status = 'aktif';

-- View: Laporan kehilangan yang masih aktif
CREATE VIEW view_laporan_aktif AS
SELECT 
    l.id_laporan,
    l.plat_nomor,
    l.pelapor_nama,
    l.lokasi_kehilangan,
    l.waktu_kejadian,
    l.status,
    l.tanggal_lapor,
    pt.nama AS nama_petugas,
    pt.shift
FROM laporan_kehilangan l
LEFT JOIN petugas_keamanan pt ON l.id_petugas = pt.id_petugas
WHERE l.status != 'Selesai';

-- View: Statistik parkir hari ini
CREATE VIEW view_statistik_hari_ini AS
SELECT 
    COUNT(*) AS total_transaksi,
    SUM(CASE WHEN status = 'aktif' THEN 1 ELSE 0 END) AS parkir_aktif,
    SUM(CASE WHEN status = 'selesai' THEN 1 ELSE 0 END) AS parkir_selesai,
    AVG(durasi_menit) AS rata_rata_durasi
FROM transaksi_parkir
WHERE DATE(waktu_masuk) = CURDATE();

-- ============================================
-- Stored Procedures
-- ============================================

-- Procedure: Check-in parkir
DELIMITER //
CREATE PROCEDURE sp_checkin_parkir(
    IN p_id_transaksi VARCHAR(20),
    IN p_id_kendaraan VARCHAR(20),
    IN p_id_pengguna VARCHAR(20),
    IN p_plat_nomor VARCHAR(20),
    IN p_lokasi_parkir VARCHAR(100)
)
BEGIN
    INSERT INTO transaksi_parkir (
        id_transaksi, 
        id_kendaraan, 
        id_pengguna, 
        plat_nomor, 
        lokasi_parkir, 
        waktu_masuk, 
        status
    ) VALUES (
        p_id_transaksi,
        p_id_kendaraan,
        p_id_pengguna,
        p_plat_nomor,
        p_lokasi_parkir,
        NOW(),
        'aktif'
    );
END //
DELIMITER ;

-- Procedure: Check-out parkir
DELIMITER //
CREATE PROCEDURE sp_checkout_parkir(
    IN p_id_transaksi VARCHAR(20)
)
BEGIN
    UPDATE transaksi_parkir
    SET 
        waktu_keluar = NOW(),
        durasi_menit = TIMESTAMPDIFF(MINUTE, waktu_masuk, NOW()),
        status = 'selesai'
    WHERE id_transaksi = p_id_transaksi;
END //
DELIMITER ;

-- Procedure: Verifikasi kendaraan
DELIMITER //
CREATE PROCEDURE sp_verifikasi_kendaraan(
    IN p_id_kendaraan VARCHAR(20),
    IN p_id_petugas VARCHAR(20),
    IN p_status_verifikasi VARCHAR(50)
)
BEGIN
    DECLARE v_plat_nomor VARCHAR(20);
    DECLARE v_id_verifikasi VARCHAR(20);
    
    -- Get plat nomor
    SELECT plat_nomor INTO v_plat_nomor 
    FROM kendaraan 
    WHERE id_kendaraan = p_id_kendaraan;
    
    -- Generate ID verifikasi
    SET v_id_verifikasi = CONCAT('VRF', LPAD(FLOOR(RAND() * 999999), 6, '0'));
    
    -- Update status kendaraan
    UPDATE kendaraan 
    SET status = 'aktif' 
    WHERE id_kendaraan = p_id_kendaraan;
    
    -- Insert verifikasi record
    INSERT INTO verifikasi_kendaraan (
        id_verifikasi,
        id_kendaraan,
        id_petugas,
        plat_nomor,
        status_verifikasi,
        waktu_verifikasi
    ) VALUES (
        v_id_verifikasi,
        p_id_kendaraan,
        p_id_petugas,
        v_plat_nomor,
        p_status_verifikasi,
        NOW()
    );
END //
DELIMITER ;

-- ============================================
-- Triggers
-- ============================================

-- Trigger: Auto update updated_at
DELIMITER //
CREATE TRIGGER trg_kendaraan_update 
BEFORE UPDATE ON kendaraan
FOR EACH ROW
BEGIN
    SET NEW.updated_at = NOW();
END //
DELIMITER ;

-- ============================================
-- Indexes untuk Performance
-- ============================================

-- Additional indexes untuk query optimization
CREATE INDEX idx_transaksi_tanggal ON transaksi_parkir(waktu_masuk);
CREATE INDEX idx_laporan_tanggal ON laporan_kehilangan(tanggal_lapor);
CREATE INDEX idx_kendaraan_status ON kendaraan(status);

-- ============================================
-- Comments
-- ============================================

-- Table comments
ALTER TABLE admin COMMENT = 'Tabel untuk menyimpan data administrator sistem';
ALTER TABLE pengguna COMMENT = 'Tabel untuk menyimpan data pengguna (mahasiswa/dosen/civitas)';
ALTER TABLE petugas_keamanan COMMENT = 'Tabel untuk menyimpan data petugas keamanan';
ALTER TABLE kendaraan COMMENT = 'Tabel untuk menyimpan data kendaraan yang terdaftar';
ALTER TABLE transaksi_parkir COMMENT = 'Tabel untuk menyimpan transaksi check-in dan check-out parkir';
ALTER TABLE laporan_kehilangan COMMENT = 'Tabel untuk menyimpan laporan kehilangan kendaraan';
ALTER TABLE pencatatan_petugas COMMENT = 'Tabel untuk menyimpan pencatatan kendaraan oleh petugas';
ALTER TABLE verifikasi_kendaraan COMMENT = 'Tabel untuk menyimpan riwayat verifikasi kendaraan';

-- ============================================
-- END OF SCRIPT
-- ============================================
