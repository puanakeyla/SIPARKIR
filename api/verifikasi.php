<?php
// ============================================
// Verifikasi Kendaraan API
// ============================================

define('API_ACCESS', true);
require_once 'config.php';

$method = $_SERVER['REQUEST_METHOD'];
$pdo = getDBConnection();

switch ($method) {
    case 'GET':
        handleGet($pdo);
        break;
    case 'POST':
        handlePost($pdo);
        break;
    default:
        sendError('Method not allowed', 405);
}

function handleGet($pdo) {
    $idKendaraan = $_GET['id_kendaraan'] ?? null;
    
    try {
        if ($idKendaraan) {
            $stmt = $pdo->prepare("
                SELECT v.*, 
                       COALESCE(p.nama, a.nama) as nama_verifikator
                FROM verifikasi_kendaraan v
                LEFT JOIN petugas_keamanan p ON v.id_petugas = p.id_petugas
                LEFT JOIN admin a ON v.id_admin = a.id_admin
                WHERE v.id_kendaraan = ?
                ORDER BY v.waktu_verifikasi DESC
            ");
            $stmt->execute([$idKendaraan]);
            $verifikasi = $stmt->fetchAll();
        } else {
            $stmt = $pdo->query("
                SELECT v.*, 
                       k.merk, k.tipe,
                       COALESCE(p.nama, a.nama) as nama_verifikator
                FROM verifikasi_kendaraan v
                LEFT JOIN kendaraan k ON v.id_kendaraan = k.id_kendaraan
                LEFT JOIN petugas_keamanan p ON v.id_petugas = p.id_petugas
                LEFT JOIN admin a ON v.id_admin = a.id_admin
                ORDER BY v.waktu_verifikasi DESC
            ");
            $verifikasi = $stmt->fetchAll();
        }
        
        sendResponse(true, 'Data verifikasi berhasil dimuat', $verifikasi);
    } catch (Exception $e) {
        sendError('Terjadi kesalahan: ' . $e->getMessage(), 500);
    }
}

function handlePost($pdo) {
    $input = json_decode(file_get_contents('php://input'), true);
    
    $required = ['id_kendaraan', 'plat_nomor', 'status_verifikasi', 'verifikator_role'];
    foreach ($required as $field) {
        if (empty($input[$field])) {
            sendError("Field $field harus diisi");
        }
    }
    
    // Validate verifikator
    $role = $input['verifikator_role'];
    if ($role === 'petugas' && empty($input['id_petugas'])) {
        sendError('ID petugas harus diisi untuk role petugas');
    }
    if ($role === 'admin' && empty($input['id_admin'])) {
        sendError('ID admin harus diisi untuk role admin');
    }
    
    try {
        $idVerifikasi = generateId('VRF', $pdo, 'verifikasi_kendaraan', 'id_verifikasi');
        
        $stmt = $pdo->prepare("
            INSERT INTO verifikasi_kendaraan 
            (id_verifikasi, id_kendaraan, id_petugas, id_admin, plat_nomor, status_verifikasi, catatan, verifikator_role)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ");
        
        $stmt->execute([
            $idVerifikasi,
            $input['id_kendaraan'],
            $input['id_petugas'] ?? null,
            $input['id_admin'] ?? null,
            $input['plat_nomor'],
            $input['status_verifikasi'],
            $input['catatan'] ?? null,
            $role
        ]);
        
        // Update kendaraan status if verified
        if ($input['status_verifikasi'] === 'Valid') {
            $stmt = $pdo->prepare("UPDATE kendaraan SET status = 'aktif' WHERE id_kendaraan = ?");
            $stmt->execute([$input['id_kendaraan']]);
        }
        
        sendResponse(true, 'Verifikasi berhasil disimpan', ['id_verifikasi' => $idVerifikasi]);
    } catch (Exception $e) {
        sendError('Terjadi kesalahan: ' . $e->getMessage(), 500);
    }
}
