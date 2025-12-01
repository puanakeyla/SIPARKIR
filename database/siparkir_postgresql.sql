-- ============================================
-- SIPARKIR UNILA - PostgreSQL Database Schema
-- Sistem Informasi Parkir Universitas Lampung
-- ============================================

-- Drop tables if exists (untuk clean install)
DROP TABLE IF EXISTS pencatatan_petugas CASCADE;
DROP TABLE IF EXISTS verifikasi_kendaraan CASCADE;
DROP TABLE IF EXISTS laporan_kehilangan CASCADE;
DROP TABLE IF EXISTS transaksi_parkir CASCADE;
DROP TABLE IF EXISTS kendaraan CASCADE;
DROP TABLE IF EXISTS audit_log CASCADE;
DROP TABLE IF EXISTS petugas_keamanan CASCADE;
DROP TABLE IF EXISTS pengguna CASCADE;
DROP TABLE IF EXISTS admin CASCADE;

-- Drop views if exists
DROP VIEW IF EXISTS view_kendaraan_lengkap CASCADE;
DROP VIEW IF EXISTS view_parkir_aktif CASCADE;
DROP VIEW IF EXISTS view_laporan_aktif CASCADE;
DROP VIEW IF EXISTS view_statistik_hari_ini CASCADE;

-- Drop functions if exists
DROP FUNCTION IF EXISTS fn_checkin_parkir CASCADE;
DROP FUNCTION IF EXISTS fn_checkout_parkir CASCADE;
DROP FUNCTION IF EXISTS fn_verifikasi_kendaraan CASCADE;
DROP FUNCTION IF EXISTS fn_update_timestamp CASCADE;

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
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE admin IS 'Tabel untuk menyimpan data administrator sistem';
COMMENT ON COLUMN admin.id_admin IS 'ID unik administrator';
COMMENT ON COLUMN admin.role IS 'Role pengguna (admin)';
COMMENT ON COLUMN admin.status IS 'Status akun (aktif/nonaktif)';

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
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE pengguna IS 'Tabel untuk menyimpan data pengguna (mahasiswa/dosen/civitas)';
COMMENT ON COLUMN pengguna.nim IS 'Nomor Induk Mahasiswa (NULL untuk dosen/civitas)';
COMMENT ON COLUMN pengguna.peran IS 'Peran pengguna: mahasiswa, dosen, atau civitas';

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
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE petugas_keamanan IS 'Tabel untuk menyimpan data petugas keamanan';
COMMENT ON COLUMN petugas_keamanan.nip IS 'Nomor Induk Pegawai';
COMMENT ON COLUMN petugas_keamanan.shift IS 'Shift kerja (Pagi/Siang/Malam)';

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
    tahun_pembuatan INTEGER,
    foto_dokumen VARCHAR(255),
    status VARCHAR(20) DEFAULT 'pending', -- pending, aktif, nonaktif
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_kendaraan_pengguna 
        FOREIGN KEY (id_pengguna) 
        REFERENCES pengguna(id_pengguna) 
        ON DELETE CASCADE
);

CREATE INDEX idx_kendaraan_pengguna ON kendaraan(id_pengguna);
CREATE INDEX idx_kendaraan_plat ON kendaraan(plat_nomor);
CREATE INDEX idx_kendaraan_status ON kendaraan(status);

COMMENT ON TABLE kendaraan IS 'Tabel untuk menyimpan data kendaraan yang terdaftar';
COMMENT ON COLUMN kendaraan.status IS 'Status verifikasi: pending, aktif, nonaktif';

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
    waktu_masuk TIMESTAMP NOT NULL,
    waktu_keluar TIMESTAMP,
    durasi_menit INTEGER,
    biaya NUMERIC(10,2) DEFAULT 0,
    status VARCHAR(20) DEFAULT 'aktif', -- aktif, selesai
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_transaksi_kendaraan 
        FOREIGN KEY (id_kendaraan) 
        REFERENCES kendaraan(id_kendaraan) 
        ON DELETE CASCADE,
    CONSTRAINT fk_transaksi_pengguna 
        FOREIGN KEY (id_pengguna) 
        REFERENCES pengguna(id_pengguna) 
        ON DELETE CASCADE
);

CREATE INDEX idx_transaksi_kendaraan ON transaksi_parkir(id_kendaraan);
CREATE INDEX idx_transaksi_pengguna ON transaksi_parkir(id_pengguna);
CREATE INDEX idx_transaksi_status ON transaksi_parkir(status);
CREATE INDEX idx_transaksi_waktu_masuk ON transaksi_parkir(waktu_masuk);
CREATE INDEX idx_transaksi_tanggal ON transaksi_parkir(DATE(waktu_masuk));

COMMENT ON TABLE transaksi_parkir IS 'Tabel untuk menyimpan transaksi check-in dan check-out parkir';
COMMENT ON COLUMN transaksi_parkir.durasi_menit IS 'Durasi parkir dalam menit (dihitung saat check-out)';

-- ============================================
-- Table: laporan_kehilangan
-- Deskripsi: Menyimpan laporan kehilangan kendaraan
-- ============================================
CREATE TABLE laporan_kehilangan (
    id_laporan VARCHAR(20) PRIMARY KEY,
    id_kendaraan VARCHAR(20) NOT NULL,
    id_pengguna VARCHAR(20) NOT NULL,
    id_petugas VARCHAR(20),
    id_admin VARCHAR(20),
    plat_nomor VARCHAR(20) NOT NULL,
    pelapor_nama VARCHAR(100) NOT NULL,
    lokasi_kehilangan VARCHAR(100) NOT NULL,
    waktu_kejadian TIMESTAMP NOT NULL,
    kronologi TEXT NOT NULL,
    bukti_pendukung VARCHAR(255),
    status VARCHAR(50) DEFAULT 'Investigasi', -- Investigasi, Dalam Patroli, Selesai
    tanggal_lapor TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    tanggal_selesai TIMESTAMP,
    catatan_petugas TEXT,
    handler_role VARCHAR(20), -- 'petugas' atau 'admin' yang handle
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_laporan_kendaraan 
        FOREIGN KEY (id_kendaraan) 
        REFERENCES kendaraan(id_kendaraan) 
        ON DELETE CASCADE,
    CONSTRAINT fk_laporan_pengguna 
        FOREIGN KEY (id_pengguna) 
        REFERENCES pengguna(id_pengguna) 
        ON DELETE CASCADE,
    CONSTRAINT fk_laporan_petugas 
        FOREIGN KEY (id_petugas) 
        REFERENCES petugas_keamanan(id_petugas) 
        ON DELETE SET NULL,
    CONSTRAINT fk_laporan_admin 
        FOREIGN KEY (id_admin) 
        REFERENCES admin(id_admin) 
        ON DELETE SET NULL
);

CREATE INDEX idx_laporan_kendaraan ON laporan_kehilangan(id_kendaraan);
CREATE INDEX idx_laporan_pengguna ON laporan_kehilangan(id_pengguna);
CREATE INDEX idx_laporan_petugas ON laporan_kehilangan(id_petugas);
CREATE INDEX idx_laporan_admin ON laporan_kehilangan(id_admin);
CREATE INDEX idx_laporan_status ON laporan_kehilangan(status);
CREATE INDEX idx_laporan_tanggal ON laporan_kehilangan(tanggal_lapor);

COMMENT ON TABLE laporan_kehilangan IS 'Tabel untuk menyimpan laporan kehilangan kendaraan';
COMMENT ON COLUMN laporan_kehilangan.status IS 'Status laporan: Investigasi, Dalam Patroli, Selesai';
COMMENT ON COLUMN laporan_kehilangan.handler_role IS 'Role yang menangani: petugas atau admin';

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
    waktu_pencatatan TIMESTAMP NOT NULL,
    catatan TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_pencatatan_petugas 
        FOREIGN KEY (id_petugas) 
        REFERENCES petugas_keamanan(id_petugas) 
        ON DELETE CASCADE
);

CREATE INDEX idx_pencatatan_petugas ON pencatatan_petugas(id_petugas);
CREATE INDEX idx_pencatatan_plat ON pencatatan_petugas(plat_nomor);
CREATE INDEX idx_pencatatan_waktu ON pencatatan_petugas(waktu_pencatatan);

COMMENT ON TABLE pencatatan_petugas IS 'Tabel untuk menyimpan pencatatan kendaraan oleh petugas';
COMMENT ON COLUMN pencatatan_petugas.status_transaksi IS 'Status: Masuk atau Keluar';

-- ============================================
-- Table: audit_log
-- Deskripsi: Menyimpan log aktivitas admin untuk tracking
-- ============================================
CREATE TABLE audit_log (
    id_log VARCHAR(20) PRIMARY KEY,
    id_admin VARCHAR(20) NOT NULL,
    tabel_target VARCHAR(50) NOT NULL, -- Tabel yang di-edit
    aksi VARCHAR(20) NOT NULL, -- INSERT, UPDATE, DELETE
    id_record VARCHAR(20), -- ID record yang diubah
    data_lama TEXT, -- JSON data sebelum perubahan
    data_baru TEXT, -- JSON data setelah perubahan
    keterangan TEXT,
    waktu_aksi TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_audit_admin 
        FOREIGN KEY (id_admin) 
        REFERENCES admin(id_admin) 
        ON DELETE CASCADE
);

CREATE INDEX idx_audit_admin ON audit_log(id_admin);
CREATE INDEX idx_audit_tabel ON audit_log(tabel_target);
CREATE INDEX idx_audit_waktu ON audit_log(waktu_aksi);

COMMENT ON TABLE audit_log IS 'Tabel untuk menyimpan log aktivitas admin (audit trail)';
COMMENT ON COLUMN audit_log.tabel_target IS 'Nama tabel yang dimodifikasi (pengguna, kendaraan, dll)';
COMMENT ON COLUMN audit_log.aksi IS 'Jenis aksi: INSERT, UPDATE, DELETE';

-- ============================================
-- Table: verifikasi_kendaraan
-- Deskripsi: Menyimpan riwayat verifikasi kendaraan oleh petugas/admin
-- ============================================
CREATE TABLE verifikasi_kendaraan (
    id_verifikasi VARCHAR(20) PRIMARY KEY,
    id_kendaraan VARCHAR(20) NOT NULL,
    id_petugas VARCHAR(20),
    id_admin VARCHAR(20),
    plat_nomor VARCHAR(20) NOT NULL,
    status_verifikasi VARCHAR(50) NOT NULL, -- Valid, Tidak Valid, Mencurigakan
    catatan TEXT,
    waktu_verifikasi TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    verifikator_role VARCHAR(20) NOT NULL, -- 'petugas' atau 'admin'
    
    CONSTRAINT fk_verifikasi_kendaraan 
        FOREIGN KEY (id_kendaraan) 
        REFERENCES kendaraan(id_kendaraan) 
        ON DELETE CASCADE,
    CONSTRAINT fk_verifikasi_petugas 
        FOREIGN KEY (id_petugas) 
        REFERENCES petugas_keamanan(id_petugas) 
        ON DELETE SET NULL,
    CONSTRAINT fk_verifikasi_admin 
        FOREIGN KEY (id_admin) 
        REFERENCES admin(id_admin) 
        ON DELETE SET NULL,
    CONSTRAINT chk_verifikator 
        CHECK (
            (verifikator_role = 'petugas' AND id_petugas IS NOT NULL AND id_admin IS NULL) OR
            (verifikator_role = 'admin' AND id_admin IS NOT NULL AND id_petugas IS NULL)
        )
);

CREATE INDEX idx_verifikasi_kendaraan ON verifikasi_kendaraan(id_kendaraan);
CREATE INDEX idx_verifikasi_petugas ON verifikasi_kendaraan(id_petugas);
CREATE INDEX idx_verifikasi_admin ON verifikasi_kendaraan(id_admin);

COMMENT ON TABLE verifikasi_kendaraan IS 'Tabel untuk menyimpan riwayat verifikasi kendaraan';
COMMENT ON COLUMN verifikasi_kendaraan.status_verifikasi IS 'Status: Valid, Tidak Valid, Mencurigakan';
COMMENT ON COLUMN verifikasi_kendaraan.verifikator_role IS 'Role yang melakukan verifikasi: petugas atau admin';

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
INSERT INTO verifikasi_kendaraan (id_verifikasi, id_kendaraan, id_petugas, id_admin, plat_nomor, status_verifikasi, catatan, waktu_verifikasi, verifikator_role) VALUES
('VRF001', 'KND001', 'PTG001', NULL, 'B 1234 ABC', 'Valid', 'Dokumen lengkap dan sesuai', '2025-11-20 09:00:00', 'petugas'),
('VRF002', 'KND002', 'PTG001', NULL, 'B 5678 XYZ', 'Valid', 'Semua dokumen terverifikasi', '2025-11-20 09:30:00', 'petugas'),
('VRF003', 'KND004', NULL, 'ADM001', 'B 1111 GHI', 'Valid', 'Kendaraan dosen terverifikasi oleh admin', '2025-11-21 10:00:00', 'admin');

-- Insert Audit Log
INSERT INTO audit_log (id_log, id_admin, tabel_target, aksi, id_record, data_lama, data_baru, keterangan, waktu_aksi) VALUES
('AUD001', 'ADM001', 'kendaraan', 'UPDATE', 'KND004', '{"status":"pending"}', '{"status":"aktif"}', 'Admin memverifikasi kendaraan dosen', '2025-11-21 10:00:00'),
('AUD002', 'ADM001', 'pengguna', 'INSERT', 'USR003', NULL, '{"nama":"Dr. Bambang Susilo","email":"bambang.susilo@unila.ac.id"}', 'Admin menambahkan akun dosen', '2025-11-15 14:30:00');

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

COMMENT ON VIEW view_kendaraan_lengkap IS 'View untuk menampilkan data lengkap kendaraan dengan informasi pemilik';

-- View: Transaksi parkir aktif
CREATE VIEW view_parkir_aktif AS
SELECT 
    t.id_transaksi,
    t.plat_nomor,
    t.lokasi_parkir,
    t.waktu_masuk,
    EXTRACT(EPOCH FROM (NOW() - t.waktu_masuk))/60 AS durasi_menit_sekarang,
    k.merk,
    k.tipe,
    p.nama AS nama_pemilik,
    p.peran
FROM transaksi_parkir t
INNER JOIN kendaraan k ON t.id_kendaraan = k.id_kendaraan
INNER JOIN pengguna p ON t.id_pengguna = p.id_pengguna
WHERE t.status = 'aktif';

COMMENT ON VIEW view_parkir_aktif IS 'View untuk menampilkan transaksi parkir yang sedang aktif';

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

COMMENT ON VIEW view_laporan_aktif IS 'View untuk menampilkan laporan kehilangan yang belum selesai';

-- View: Statistik parkir hari ini
CREATE VIEW view_statistik_hari_ini AS
SELECT 
    COUNT(*) AS total_transaksi,
    SUM(CASE WHEN status = 'aktif' THEN 1 ELSE 0 END) AS parkir_aktif,
    SUM(CASE WHEN status = 'selesai' THEN 1 ELSE 0 END) AS parkir_selesai,
    AVG(durasi_menit) AS rata_rata_durasi
FROM transaksi_parkir
WHERE DATE(waktu_masuk) = CURRENT_DATE;

COMMENT ON VIEW view_statistik_hari_ini IS 'View untuk menampilkan statistik parkir hari ini';

-- ============================================
-- Functions (PostgreSQL equivalent of Stored Procedures)
-- ============================================

-- Function: Check-in parkir
CREATE OR REPLACE FUNCTION fn_checkin_parkir(
    p_id_transaksi VARCHAR(20),
    p_id_kendaraan VARCHAR(20),
    p_id_pengguna VARCHAR(20),
    p_plat_nomor VARCHAR(20),
    p_lokasi_parkir VARCHAR(100)
)
RETURNS VOID AS $$
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
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fn_checkin_parkir IS 'Function untuk melakukan check-in parkir';

-- Function: Check-out parkir
CREATE OR REPLACE FUNCTION fn_checkout_parkir(
    p_id_transaksi VARCHAR(20)
)
RETURNS VOID AS $$
BEGIN
    UPDATE transaksi_parkir
    SET 
        waktu_keluar = NOW(),
        durasi_menit = EXTRACT(EPOCH FROM (NOW() - waktu_masuk))/60,
        status = 'selesai',
        updated_at = NOW()
    WHERE id_transaksi = p_id_transaksi;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fn_checkout_parkir IS 'Function untuk melakukan check-out parkir';

-- Function: Verifikasi kendaraan
CREATE OR REPLACE FUNCTION fn_verifikasi_kendaraan(
    p_id_kendaraan VARCHAR(20),
    p_id_petugas VARCHAR(20),
    p_status_verifikasi VARCHAR(50)
)
RETURNS VOID AS $$
DECLARE
    v_plat_nomor VARCHAR(20);
    v_id_verifikasi VARCHAR(20);
BEGIN
    -- Get plat nomor
    SELECT plat_nomor INTO v_plat_nomor 
    FROM kendaraan 
    WHERE id_kendaraan = p_id_kendaraan;
    
    -- Generate ID verifikasi
    v_id_verifikasi := 'VRF' || LPAD(FLOOR(RANDOM() * 999999)::TEXT, 6, '0');
    
    -- Update status kendaraan
    UPDATE kendaraan 
    SET status = 'aktif',
        updated_at = NOW()
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
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fn_verifikasi_kendaraan IS 'Function untuk verifikasi kendaraan oleh petugas';

-- ============================================
-- Triggers
-- ============================================

-- Function untuk trigger auto update timestamp
CREATE OR REPLACE FUNCTION fn_update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger untuk admin
CREATE TRIGGER trg_admin_update
BEFORE UPDATE ON admin
FOR EACH ROW
EXECUTE FUNCTION fn_update_timestamp();

-- Trigger untuk pengguna
CREATE TRIGGER trg_pengguna_update
BEFORE UPDATE ON pengguna
FOR EACH ROW
EXECUTE FUNCTION fn_update_timestamp();

-- Trigger untuk petugas_keamanan
CREATE TRIGGER trg_petugas_update
BEFORE UPDATE ON petugas_keamanan
FOR EACH ROW
EXECUTE FUNCTION fn_update_timestamp();

-- Trigger untuk kendaraan
CREATE TRIGGER trg_kendaraan_update
BEFORE UPDATE ON kendaraan
FOR EACH ROW
EXECUTE FUNCTION fn_update_timestamp();

-- Trigger untuk transaksi_parkir
CREATE TRIGGER trg_transaksi_update
BEFORE UPDATE ON transaksi_parkir
FOR EACH ROW
EXECUTE FUNCTION fn_update_timestamp();

-- Trigger untuk laporan_kehilangan
CREATE TRIGGER trg_laporan_update
BEFORE UPDATE ON laporan_kehilangan
FOR EACH ROW
EXECUTE FUNCTION fn_update_timestamp();

-- ============================================
-- Contoh Query untuk Testing
-- ============================================

-- Query: Lihat semua kendaraan aktif dengan pemiliknya
-- SELECT * FROM view_kendaraan_lengkap WHERE status_kendaraan = 'aktif';

-- Query: Lihat parkir yang sedang berlangsung
-- SELECT * FROM view_parkir_aktif;

-- Query: Lihat laporan kehilangan yang masih ditangani
-- SELECT * FROM view_laporan_aktif;

-- Query: Statistik parkir hari ini
-- SELECT * FROM view_statistik_hari_ini;

-- Query: Check-in parkir (menggunakan function)
-- SELECT fn_checkin_parkir('TRX004', 'KND003', 'USR002', 'B 9876 DEF', 'Parkiran D - Perpustakaan');

-- Query: Check-out parkir (menggunakan function)
-- SELECT fn_checkout_parkir('TRX001');

-- Query: Verifikasi kendaraan (menggunakan function)
-- SELECT fn_verifikasi_kendaraan('KND003', 'PTG001', 'Valid');

-- ============================================
-- Analisis Database
-- ============================================

-- Query untuk melihat ukuran database
-- SELECT pg_size_pretty(pg_database_size(current_database())) AS database_size;

-- Query untuk melihat ukuran per tabel
-- SELECT 
--     schemaname,
--     tablename,
--     pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
-- FROM pg_tables
-- WHERE schemaname = 'public'
-- ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- Query untuk melihat semua foreign keys
-- SELECT
--     tc.table_name, 
--     kcu.column_name, 
--     ccu.table_name AS foreign_table_name,
--     ccu.column_name AS foreign_column_name 
-- FROM information_schema.table_constraints AS tc 
-- JOIN information_schema.key_column_usage AS kcu
--     ON tc.constraint_name = kcu.constraint_name
-- JOIN information_schema.constraint_column_usage AS ccu
--     ON ccu.constraint_name = tc.constraint_name
-- WHERE tc.constraint_type = 'FOREIGN KEY';

-- ============================================
-- END OF SCRIPT
-- ============================================
