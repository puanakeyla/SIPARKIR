<?php
// ============================================
// Riwayat Parkir API - CRUD Operations
// 100% Sesuai Class Diagram
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
    case 'PUT':
        handlePut($pdo);
        break;
    case 'DELETE':
        handleDelete($pdo);
        break;
    default:
        sendError('Method not allowed', 405);
}

function handleGet($pdo) {
    $id = $_GET['id'] ?? null;
    $idKendaraan = $_GET['id_kendaraan'] ?? null;
    $status = $_GET['status'] ?? null;
    
    try {
        if ($id) {
            // Get single riwayat
            $stmt = $pdo->prepare("
                SELECT r.*, k.plat_nomor, k.merk, k.tipe, p.nama as nama_pemilik, p.id_pengguna
                FROM riwayat_parkir r
                LEFT JOIN kendaraan k ON r.id_kendaraan = k.id_kendaraan
                LEFT JOIN pengguna p ON k.id_pengguna = p.id_pengguna
                WHERE r.id_riwayat = ?
            ");
            $stmt->execute([$id]);
            $riwayat = $stmt->fetch();
            
            if ($riwayat) {
                sendResponse(true, 'Data riwayat ditemukan', $riwayat);
            } else {
                sendError('Riwayat tidak ditemukan', 404);
            }
        } elseif ($idKendaraan) {
            // Get riwayat by kendaraan
            $stmt = $pdo->prepare("
                SELECT r.*, k.plat_nomor, k.merk, k.tipe
                FROM riwayat_parkir r
                LEFT JOIN kendaraan k ON r.id_kendaraan = k.id_kendaraan
                WHERE r.id_kendaraan = ?
                ORDER BY r.waktu_masuk DESC
            ");
            $stmt->execute([$idKendaraan]);
            $riwayat = $stmt->fetchAll();
            sendResponse(true, 'Data riwayat berhasil dimuat', $riwayat);
        } elseif ($status === 'aktif') {
            // Get riwayat yang sedang parkir (belum keluar)
            $stmt = $pdo->query("
                SELECT r.*, k.plat_nomor, k.merk, k.tipe, p.nama as nama_pemilik, p.id_pengguna
                FROM riwayat_parkir r
                LEFT JOIN kendaraan k ON r.id_kendaraan = k.id_kendaraan
                LEFT JOIN pengguna p ON k.id_pengguna = p.id_pengguna
                WHERE r.waktu_keluar IS NULL
                ORDER BY r.waktu_masuk DESC
            ");
            $riwayat = $stmt->fetchAll();
            sendResponse(true, 'Data riwayat aktif berhasil dimuat', $riwayat);
        } else {
            // Get all riwayat
            $stmt = $pdo->query("
                SELECT r.*, k.plat_nomor, k.merk, k.tipe, p.nama as nama_pemilik, p.id_pengguna
                FROM riwayat_parkir r
                LEFT JOIN kendaraan k ON r.id_kendaraan = k.id_kendaraan
                LEFT JOIN pengguna p ON k.id_pengguna = p.id_pengguna
                ORDER BY r.waktu_masuk DESC
                LIMIT 100
            ");
            $riwayat = $stmt->fetchAll();
            sendResponse(true, 'Data riwayat berhasil dimuat', $riwayat);
        }
    } catch (Exception $e) {
        sendError('Terjadi kesalahan: ' . $e->getMessage(), 500);
    }
}

function handlePost($pdo) {
    $input = json_decode(file_get_contents('php://input'), true);
    
    $action = $input['action'] ?? 'masuk';
    
    if ($action === 'masuk') {
        // Catat masuk parkir
        $required = ['id_kendaraan', 'lokasi_parkir'];
        foreach ($required as $field) {
            if (empty($input[$field])) {
                sendError("Field $field harus diisi");
            }
        }
        
        try {
            $idRiwayat = generateId('RWY', $pdo, 'riwayat_parkir', 'id_riwayat');
            
            $stmt = $pdo->prepare("
                INSERT INTO riwayat_parkir (id_riwayat, id_kendaraan, waktu_masuk, lokasi_parkir)
                VALUES (?, ?, NOW(), ?)
            ");
            
            $stmt->execute([
                $idRiwayat,
                $input['id_kendaraan'],
                $input['lokasi_parkir']
            ]);
            
            sendResponse(true, 'Parkir masuk berhasil dicatat', ['id_riwayat' => $idRiwayat]);
        } catch (Exception $e) {
            sendError('Terjadi kesalahan: ' . $e->getMessage(), 500);
        }
    } elseif ($action === 'keluar') {
        // Catat keluar parkir
        $idRiwayat = $input['id_riwayat'] ?? null;
        
        if (!$idRiwayat) {
            sendError('ID riwayat harus diisi');
        }
        
        try {
            $stmt = $pdo->prepare("
                UPDATE riwayat_parkir 
                SET waktu_keluar = NOW()
                WHERE id_riwayat = ? AND waktu_keluar IS NULL
            ");
            
            $stmt->execute([$idRiwayat]);
            
            if ($stmt->rowCount() > 0) {
                sendResponse(true, 'Parkir keluar berhasil dicatat');
            } else {
                sendError('Riwayat tidak ditemukan atau sudah keluar', 404);
            }
        } catch (Exception $e) {
            sendError('Terjadi kesalahan: ' . $e->getMessage(), 500);
        }
    }
}

function handlePut($pdo) {
    $input = json_decode(file_get_contents('php://input'), true);
    $id = $input['id_riwayat'] ?? null;
    
    if (!$id) {
        sendError('ID riwayat harus diisi');
    }
    
    try {
        // Build update query
        $fields = [];
        $values = [];
        
        $allowedFields = ['waktu_masuk', 'waktu_keluar', 'lokasi_parkir'];
        foreach ($allowedFields as $field) {
            if (isset($input[$field])) {
                $fields[] = "$field = ?";
                $values[] = $input[$field];
            }
        }
        
        if (empty($fields)) {
            sendError('Tidak ada data yang diupdate');
        }
        
        $values[] = $id;
        $sql = "UPDATE riwayat_parkir SET " . implode(', ', $fields) . " WHERE id_riwayat = ?";
        $stmt = $pdo->prepare($sql);
        $stmt->execute($values);
        
        sendResponse(true, 'Riwayat berhasil diupdate');
    } catch (Exception $e) {
        sendError('Terjadi kesalahan: ' . $e->getMessage(), 500);
    }
}

function handleDelete($pdo) {
    $input = json_decode(file_get_contents('php://input'), true);
    $id = $input['id_riwayat'] ?? $_GET['id'] ?? null;
    
    if (!$id) {
        sendError('ID riwayat harus diisi');
    }
    
    try {
        $stmt = $pdo->prepare("DELETE FROM riwayat_parkir WHERE id_riwayat = ?");
        $stmt->execute([$id]);
        
        if ($stmt->rowCount() > 0) {
            sendResponse(true, 'Riwayat berhasil dihapus');
        } else {
            sendError('Riwayat tidak ditemukan', 404);
        }
    } catch (Exception $e) {
        sendError('Terjadi kesalahan: ' . $e->getMessage(), 500);
    }
}
?>
