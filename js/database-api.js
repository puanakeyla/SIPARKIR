// ============================================
// Database Manager - MySQL via PHP API
// Pengganti localStorage dengan koneksi real database
// ============================================

const API_URL = 'http://localhost/APPL/api'; // Sesuaikan dengan path XAMPP Anda

class DatabaseAPI {
    constructor() {
        this.apiUrl = API_URL;
    }

    // Helper untuk fetch dengan error handling
    async request(endpoint, options = {}) {
        try {
            const response = await fetch(`${this.apiUrl}/${endpoint}`, {
                ...options,
                headers: {
                    'Content-Type': 'application/json',
                    ...options.headers
                }
            });

            const data = await response.json();

            if (!data.success) {
                throw new Error(data.message || 'Request failed');
            }

            return data;
        } catch (error) {
            console.error('API Error:', error);
            throw error;
        }
    }

    // ==================== AUTH ====================
    async login(email, password) {
        const result = await this.request('login.php', {
            method: 'POST',
            body: JSON.stringify({ email, password })
        });
        
        if (result.success) {
            // Simpan session ke localStorage
            localStorage.setItem('currentUser', JSON.stringify(result.data.user));
        }
        
        return result;
    }

    getCurrentUser() {
        const user = localStorage.getItem('currentUser');
        return user ? JSON.parse(user) : null;
    }

    logout() {
        localStorage.removeItem('currentUser');
        window.location.href = 'login.html';
    }

    // ==================== KENDARAAN ====================
    async getAllKendaraan() {
        const result = await this.request('kendaraan.php');
        return result.data;
    }

    async getKendaraanByPengguna(idPengguna) {
        const result = await this.request(`kendaraan.php?id_pengguna=${idPengguna}`);
        return result.data;
    }

    async getKendaraanById(id) {
        const result = await this.request(`kendaraan.php?id=${id}`);
        return result.data;
    }

    async addKendaraan(kendaraan) {
        const result = await this.request('kendaraan.php', {
            method: 'POST',
            body: JSON.stringify(kendaraan)
        });
        return result;
    }

    async updateKendaraan(id, updates) {
        const result = await this.request('kendaraan.php', {
            method: 'PUT',
            body: JSON.stringify({ id_kendaraan: id, ...updates })
        });
        return result;
    }

    async deleteKendaraan(id, adminId = null) {
        const result = await this.request('kendaraan.php', {
            method: 'DELETE',
            body: JSON.stringify({ id_kendaraan: id, admin_id: adminId })
        });
        return result;
    }

    // ==================== TRANSAKSI PARKIR ====================
    async getAllTransaksi() {
        const result = await this.request('transaksi.php');
        return result.data;
    }

    async getTransaksiByPengguna(idPengguna) {
        const result = await this.request(`transaksi.php?id_pengguna=${idPengguna}`);
        return result.data;
    }

    async getTransaksiAktif() {
        const result = await this.request('transaksi.php?status=aktif');
        return result.data;
    }

    async checkinParkir(data) {
        const result = await this.request('transaksi.php', {
            method: 'POST',
            body: JSON.stringify({ action: 'checkin', ...data })
        });
        return result;
    }

    async checkoutParkir(idTransaksi) {
        const result = await this.request('transaksi.php', {
            method: 'POST',
            body: JSON.stringify({ action: 'checkout', id_transaksi: idTransaksi })
        });
        return result;
    }

    // ==================== VERIFIKASI ====================
    async getAllVerifikasi() {
        const result = await this.request('verifikasi.php');
        return result.data;
    }

    async getVerifikasiByKendaraan(idKendaraan) {
        const result = await this.request(`verifikasi.php?id_kendaraan=${idKendaraan}`);
        return result.data;
    }

    async verifikasiKendaraan(idKendaraan, verifikatorId, verifikatorRole, status, catatan, platNomor) {
        const data = {
            id_kendaraan: idKendaraan,
            plat_nomor: platNomor,
            status_verifikasi: status,
            catatan: catatan,
            verifikator_role: verifikatorRole
        };

        if (verifikatorRole === 'admin') {
            data.id_admin = verifikatorId;
        } else {
            data.id_petugas = verifikatorId;
        }

        const result = await this.request('verifikasi.php', {
            method: 'POST',
            body: JSON.stringify(data)
        });
        return result;
    }

    // ==================== AUDIT LOG ====================
    async getAllAuditLogs(limit = 100) {
        const result = await this.request(`audit.php?limit=${limit}`);
        return result.data;
    }

    async getAuditLogsByAdmin(idAdmin) {
        const result = await this.request(`audit.php?id_admin=${idAdmin}`);
        return result.data;
    }

    async getAuditLogsByTable(tabel) {
        const result = await this.request(`audit.php?tabel=${tabel}`);
        return result.data;
    }
}

// Export instance
const dbAPI = new DatabaseAPI();

// Tambahkan fungsi helper untuk kompatibilitas dengan kode lama
const db = {
    // Auth
    login: (email, password) => dbAPI.login(email, password),
    getCurrentUser: () => dbAPI.getCurrentUser(),
    logout: () => dbAPI.logout(),

    // Kendaraan
    getAllKendaraan: () => dbAPI.getAllKendaraan(),
    getKendaraanByPengguna: (id) => dbAPI.getKendaraanByPengguna(id),
    addKendaraan: (data) => dbAPI.addKendaraan(data),
    updateKendaraan: (id, updates) => dbAPI.updateKendaraan(id, updates),
    deleteKendaraan: (id, adminId) => dbAPI.deleteKendaraan(id, adminId),

    // Transaksi
    getAllTransaksi: () => dbAPI.getAllTransaksi(),
    getTransaksiByPengguna: (id) => dbAPI.getTransaksiByPengguna(id),
    getTransaksiAktif: () => dbAPI.getTransaksiAktif(),
    checkinParkir: (data) => dbAPI.checkinParkir(data),
    checkoutParkir: (id) => dbAPI.checkoutParkir(id),

    // Verifikasi
    verifikasiKendaraan: (idKendaraan, verifikatorId, verifikatorRole, status, catatan, platNomor) => 
        dbAPI.verifikasiKendaraan(idKendaraan, verifikatorId, verifikatorRole, status, catatan, platNomor),
    getAllVerifikasi: () => dbAPI.getAllVerifikasi(),

    // Audit
    getAllAuditLogs: () => dbAPI.getAllAuditLogs(),
    getAuditLogsByAdmin: (id) => dbAPI.getAuditLogsByAdmin(id),
};
