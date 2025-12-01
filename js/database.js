// Database Manager - SIPARKIR UNILA
// Menggunakan localStorage sebagai database sementara

class Database {
    constructor() {
        this.init();
    }

    init() {
        // Inisialisasi database jika belum ada
        if (!localStorage.getItem('siparkir_pengguna')) {
            localStorage.setItem('siparkir_pengguna', JSON.stringify([
                {
                    id: 'USR001',
                    nama: 'Andi Pratama',
                    email: 'pengguna@unila.ac.id',
                    password: 'pengguna123',
                    nim: '2315061001',
                    peran: 'mahasiswa', // mahasiswa, dosen, civitas
                    role: 'pengguna',
                    status: 'aktif',
                    createdAt: new Date().toISOString(),
                    updatedAt: new Date().toISOString()
                }
            ]));
        }

        if (!localStorage.getItem('siparkir_petugas')) {
            localStorage.setItem('siparkir_petugas', JSON.stringify([
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
            ]));
        }

        if (!localStorage.getItem('siparkir_admin')) {
            localStorage.setItem('siparkir_admin', JSON.stringify([
                {
                    id: 'ADM001',
                    nama: 'Administrator',
                    email: 'admin@unila.ac.id',
                    password: 'admin123',
                    role: 'admin',
                    status: 'aktif'
                }
            ]));
        }

        if (!localStorage.getItem('siparkir_kendaraan')) {
            localStorage.setItem('siparkir_kendaraan', JSON.stringify([
                {
                    id: 'KND001',
                    pemilikId: 'USR001',
                    platNomor: 'B 1234 ABC',
                    merk: 'Honda',
                    tipe: 'Beat',
                    warna: 'Hitam',
                    tahunPembuatan: 2022,
                    fotoDokumen: null,
                    status: 'aktif',
                    createdAt: new Date().toISOString(),
                    updatedAt: new Date().toISOString()
                },
                {
                    id: 'KND002',
                    pemilikId: 'USR001',
                    platNomor: 'B 5678 XYZ',
                    merk: 'Yamaha',
                    tipe: 'NMAX',
                    warna: 'Putih',
                    tahunPembuatan: 2021,
                    fotoDokumen: null,
                    status: 'aktif',
                    createdAt: new Date().toISOString(),
                    updatedAt: new Date().toISOString()
                }
            ]));
        }

        if (!localStorage.getItem('siparkir_transaksi_parkir')) {
            localStorage.setItem('siparkir_transaksi_parkir', JSON.stringify([
                {
                    id: 'TRX001',
                    kendaraanId: 'KND001',
                    platNomor: 'B 1234 ABC',
                    penggunaId: 'USR001',
                    lokasiParkir: 'Parkiran A',
                    waktuMasuk: new Date().toISOString(),
                    waktuKeluar: null,
                    durasiMenit: null,
                    biaya: 0,
                    status: 'aktif',
                    createdAt: new Date().toISOString(),
                    updatedAt: new Date().toISOString()
                }
            ]));
        }

        if (!localStorage.getItem('siparkir_laporan_kehilangan')) {
            localStorage.setItem('siparkir_laporan_kehilangan', JSON.stringify([
                {
                    id: 'LAP001',
                    kendaraanId: 'KND002',
                    platNomor: 'B 5678 XYZ',
                    penggunaId: 'USR001',
                    pelaporNama: 'Andi Pratama',
                    lokasiKehilangan: 'Parkiran B',
                    waktuKejadian: '2025-12-01T10:30:00',
                    kronologi: 'Kendaraan hilang saat parkir di area fakultas',
                    buktiPendukung: null,
                    status: 'Investigasi',
                    petugasId: null,
                    adminId: null,
                    handlerRole: null,
                    catatanPetugas: null,
                    tanggalLapor: new Date().toISOString(),
                    tanggalSelesai: null,
                    createdAt: new Date().toISOString(),
                    updatedAt: new Date().toISOString()
                }
            ]));
        }

        if (!localStorage.getItem('siparkir_pencatatan_petugas')) {
            localStorage.setItem('siparkir_pencatatan_petugas', JSON.stringify([]));
        }

        if (!localStorage.getItem('siparkir_verifikasi')) {
            localStorage.setItem('siparkir_verifikasi', JSON.stringify([]));
        }

        if (!localStorage.getItem('siparkir_audit_log')) {
            localStorage.setItem('siparkir_audit_log', JSON.stringify([]));
        }

        // Set current user session
        if (!sessionStorage.getItem('currentUser')) {
            sessionStorage.setItem('currentUser', JSON.stringify(null));
        }
    }

    // User Management
    getAllUsers(role = null) {
        if (role) {
            const data = JSON.parse(localStorage.getItem(`siparkir_${role}`)) || [];
            return data;
        }
        const pengguna = JSON.parse(localStorage.getItem('siparkir_pengguna')) || [];
        const petugas = JSON.parse(localStorage.getItem('siparkir_petugas')) || [];
        const admin = JSON.parse(localStorage.getItem('siparkir_admin')) || [];
        return [...pengguna, ...petugas, ...admin];
    }

    addUser(userData, role) {
        const users = JSON.parse(localStorage.getItem(`siparkir_${role}`)) || [];
        const newId = this.generateId(role.toUpperCase().substring(0, 3));
        const newUser = { 
            id: newId, 
            ...userData, 
            role, 
            status: 'aktif',
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString()
        };
        users.push(newUser);
        localStorage.setItem(`siparkir_${role}`, JSON.stringify(users));
        
        // Log audit jika ada admin yang login
        const currentUser = this.getCurrentUser();
        if (currentUser && currentUser.role === 'admin') {
            this.addAuditLog({
                adminId: currentUser.id,
                tabelTarget: role,
                aksi: 'INSERT',
                idRecord: newId,
                dataLama: null,
                dataBaru: JSON.stringify(newUser),
                keterangan: `Admin menambahkan ${role} baru: ${userData.nama}`
            });
        }
        
        return newUser;
    }

    // Kendaraan Management
    getAllKendaraan() {
        return JSON.parse(localStorage.getItem('siparkir_kendaraan')) || [];
    }

    getKendaraanByPemilik(pemilikId) {
        const kendaraan = this.getAllKendaraan();
        return kendaraan.filter(k => k.pemilikId === pemilikId);
    }

    addKendaraan(kendaraanData) {
        const kendaraan = this.getAllKendaraan();
        const newId = this.generateId('KND');
        const newKendaraan = { 
            id: newId, 
            ...kendaraanData, 
            status: 'pending',
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString()
        };
        kendaraan.push(newKendaraan);
        localStorage.setItem('siparkir_kendaraan', JSON.stringify(kendaraan));
        return newKendaraan;
    }

    updateKendaraan(id, updates) {
        const kendaraan = this.getAllKendaraan();
        const index = kendaraan.findIndex(k => k.id === id);
        if (index !== -1) {
            const dataLama = {...kendaraan[index]};
            kendaraan[index] = { 
                ...kendaraan[index], 
                ...updates,
                updatedAt: new Date().toISOString()
            };
            localStorage.setItem('siparkir_kendaraan', JSON.stringify(kendaraan));
            
            // Log audit jika ada admin yang update
            const currentUser = this.getCurrentUser();
            if (currentUser && currentUser.role === 'admin') {
                this.addAuditLog({
                    adminId: currentUser.id,
                    tabelTarget: 'kendaraan',
                    aksi: 'UPDATE',
                    idRecord: id,
                    dataLama: JSON.stringify(dataLama),
                    dataBaru: JSON.stringify(kendaraan[index]),
                    keterangan: `Admin mengupdate kendaraan ${kendaraan[index].platNomor}`
                });
            }
            
            return kendaraan[index];
        }
        return null;
    }

    deleteKendaraan(id) {
        let kendaraan = this.getAllKendaraan();
        const deleted = kendaraan.find(k => k.id === id);
        kendaraan = kendaraan.filter(k => k.id !== id);
        localStorage.setItem('siparkir_kendaraan', JSON.stringify(kendaraan));
        
        // Log audit
        const currentUser = this.getCurrentUser();
        if (currentUser && currentUser.role === 'admin' && deleted) {
            this.addAuditLog({
                adminId: currentUser.id,
                tabelTarget: 'kendaraan',
                aksi: 'DELETE',
                idRecord: id,
                dataLama: JSON.stringify(deleted),
                dataBaru: null,
                keterangan: `Admin menghapus kendaraan ${deleted.platNomor}`
            });
        }
        
        return true;
    }

    // Transaksi Parkir Management
    getAllTransaksi() {
        return JSON.parse(localStorage.getItem('siparkir_transaksi_parkir')) || [];
    }

    getTransaksiAktif() {
        const transaksi = this.getAllTransaksi();
        return transaksi.filter(t => t.status === 'aktif');
    }

    checkIn(data) {
        const transaksi = this.getAllTransaksi();
        const newId = this.generateId('TRX');
        const newTransaksi = {
            id: newId,
            ...data,
            waktuMasuk: new Date().toISOString(),
            waktuKeluar: null,
            durasiMenit: null,
            biaya: 0,
            status: 'aktif',
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString()
        };
        transaksi.push(newTransaksi);
        localStorage.setItem('siparkir_transaksi_parkir', JSON.stringify(transaksi));
        return newTransaksi;
    }

    checkOut(transaksiId) {
        const transaksi = this.getAllTransaksi();
        const index = transaksi.findIndex(t => t.id === transaksiId);
        if (index !== -1) {
            const waktuKeluar = new Date();
            const waktuMasuk = new Date(transaksi[index].waktuMasuk);
            const durasiMenit = Math.floor((waktuKeluar - waktuMasuk) / (1000 * 60));
            
            transaksi[index].waktuKeluar = waktuKeluar.toISOString();
            transaksi[index].durasiMenit = durasiMenit;
            transaksi[index].biaya = 0; // Bisa dihitung berdasarkan durasi
            transaksi[index].status = 'selesai';
            transaksi[index].updatedAt = new Date().toISOString();
            
            localStorage.setItem('siparkir_transaksi_parkir', JSON.stringify(transaksi));
            return transaksi[index];
        }
        return null;
    }

    // Laporan Kehilangan Management
    getAllLaporan() {
        return JSON.parse(localStorage.getItem('siparkir_laporan_kehilangan')) || [];
    }

    addLaporan(laporanData) {
        const laporan = this.getAllLaporan();
        const newId = this.generateId('LAP');
        const newLaporan = {
            id: newId,
            ...laporanData,
            status: 'Investigasi',
            tanggalLapor: new Date().toISOString(),
            tanggalSelesai: null,
            catatanPetugas: null,
            handlerRole: null,
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString()
        };
        laporan.push(newLaporan);
        localStorage.setItem('siparkir_laporan_kehilangan', JSON.stringify(laporan));
        return newLaporan;
    }

    updateLaporan(id, updates) {
        const laporan = this.getAllLaporan();
        const index = laporan.findIndex(l => l.id === id);
        if (index !== -1) {
            laporan[index] = { 
                ...laporan[index], 
                ...updates,
                updatedAt: new Date().toISOString()
            };
            if (updates.status === 'Selesai' && !laporan[index].tanggalSelesai) {
                laporan[index].tanggalSelesai = new Date().toISOString();
            }
            localStorage.setItem('siparkir_laporan_kehilangan', JSON.stringify(laporan));
            return laporan[index];
        }
        return null;
    }

    // Pencatatan Petugas
    addPencatatan(data) {
        const pencatatan = JSON.parse(localStorage.getItem('siparkir_pencatatan_petugas')) || [];
        const newId = this.generateId('PNC');
        const newPencatatan = {
            id: newId,
            ...data,
            waktuPencatatan: new Date().toISOString(),
            createdAt: new Date().toISOString()
        };
        pencatatan.push(newPencatatan);
        localStorage.setItem('siparkir_pencatatan_petugas', JSON.stringify(pencatatan));
        return newPencatatan;
    }

    getAllPencatatan() {
        return JSON.parse(localStorage.getItem('siparkir_pencatatan_petugas')) || [];
    }

    // Verifikasi Kendaraan (support admin & petugas)
    verifikasiKendaraan(kendaraanId, verifikatorId, verifikatorRole, statusVerifikasi, catatan = null) {
        const kendaraan = this.getAllKendaraan();
        const kendaraanIndex = kendaraan.findIndex(k => k.id === kendaraanId);
        
        if (kendaraanIndex === -1) return null;
        
        const verifikasi = JSON.parse(localStorage.getItem('siparkir_verifikasi')) || [];
        const newId = this.generateId('VRF');
        
        const newVerifikasi = {
            id: newId,
            kendaraanId,
            petugasId: verifikatorRole === 'petugas' ? verifikatorId : null,
            adminId: verifikatorRole === 'admin' ? verifikatorId : null,
            platNomor: kendaraan[kendaraanIndex].platNomor,
            statusVerifikasi,
            catatan,
            verifikatorRole,
            waktuVerifikasi: new Date().toISOString()
        };
        
        verifikasi.push(newVerifikasi);
        localStorage.setItem('siparkir_verifikasi', JSON.stringify(verifikasi));
        
        // Update status kendaraan menjadi aktif jika valid
        if (statusVerifikasi === 'Valid') {
            this.updateKendaraan(kendaraanId, { status: 'aktif' });
        }
        
        return newVerifikasi;
    }

    getAllVerifikasi() {
        return JSON.parse(localStorage.getItem('siparkir_verifikasi')) || [];
    }

    // Audit Log Management
    addAuditLog(auditData) {
        const logs = JSON.parse(localStorage.getItem('siparkir_audit_log')) || [];
        const newId = this.generateId('AUD');
        const newLog = {
            id: newId,
            ...auditData,
            waktuAksi: new Date().toISOString()
        };
        logs.push(newLog);
        localStorage.setItem('siparkir_audit_log', JSON.stringify(logs));
        return newLog;
    }

    getAllAuditLogs() {
        return JSON.parse(localStorage.getItem('siparkir_audit_log')) || [];
    }

    getAuditLogsByAdmin(adminId) {
        const logs = this.getAllAuditLogs();
        return logs.filter(log => log.adminId === adminId);
    }

    // Session Management
    login(email, password) {
        const allUsers = this.getAllUsers();
        const user = allUsers.find(u => u.email === email && u.password === password);
        if (user) {
            sessionStorage.setItem('currentUser', JSON.stringify(user));
            return user;
        }
        return null;
    }

    logout() {
        // Clear both session and persistent storage to fully sign out
        sessionStorage.removeItem('currentUser');
        localStorage.removeItem('currentUser');
        // Redirect to login page after cleanup
        window.location.href = 'login.html';
    }

    getCurrentUser() {
        const user = sessionStorage.getItem('currentUser');
        return user ? JSON.parse(user) : null;
    }

    // Utility
    generateId(prefix) {
        const timestamp = Date.now().toString().slice(-6);
        const random = Math.floor(Math.random() * 1000).toString().padStart(3, '0');
        return `${prefix}${timestamp}${random}`;
    }

    // Statistics
    getStatistics() {
        const pengguna = this.getAllUsers('pengguna');
        const kendaraan = this.getAllKendaraan();
        const transaksi = this.getAllTransaksi();
        const laporan = this.getAllLaporan();
        
        const today = new Date().toDateString();
        const transaksiHariIni = transaksi.filter(t => 
            new Date(t.waktuMasuk).toDateString() === today
        );

        return {
            totalPengguna: pengguna.length,
            totalKendaraan: kendaraan.length,
            transaksiHariIni: transaksiHariIni.length,
            laporanAktif: laporan.filter(l => l.status !== 'Selesai').length,
            parkirAktif: this.getTransaksiAktif().length
        };
    }
}

// Export singleton instance
const db = new Database();
