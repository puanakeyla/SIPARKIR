<?php
// ============================================
// Kendaraan API - CRUD Operations
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
    $idPengguna = $_GET['id_pengguna'] ?? null;
    
    try {
        if ($id) {
            // Get single kendaraan
            $stmt = $pdo->prepare("SELECT * FROM kendaraan WHERE id_kendaraan = ?");
            $stmt->execute([$id]);
            $kendaraan = $stmt->fetch();
            
            if ($kendaraan) {
                sendResponse(true, 'Data kendaraan ditemukan', $kendaraan);
            } else {
                sendError('Kendaraan tidak ditemukan', 404);
            }
        } elseif ($idPengguna) {
            // Get kendaraan by pengguna
            $stmt = $pdo->prepare("SELECT * FROM kendaraan WHERE id_pengguna = ? ORDER BY created_at DESC");
            $stmt->execute([$idPengguna]);
            $kendaraan = $stmt->fetchAll();
            sendResponse(true, 'Data kendaraan berhasil dimuat', $kendaraan);
        } else {
            // Get all kendaraan
            $stmt = $pdo->query("SELECT k.*, p.nama as nama_pemilik, p.peran FROM kendaraan k LEFT JOIN pengguna p ON k.id_pengguna = p.id_pengguna ORDER BY k.created_at DESC");
            $kendaraan = $stmt->fetchAll();
            sendResponse(true, 'Data kendaraan berhasil dimuat', $kendaraan);
        }
    } catch (Exception $e) {
        sendError('Terjadi kesalahan: ' . $e->getMessage(), 500);
    }
}

function handlePost($pdo) {
    $input = json_decode(file_get_contents('php://input'), true);
    
    $required = ['id_pengguna', 'plat_nomor', 'merk', 'tipe', 'warna', 'tahun_pembuatan'];
    foreach ($required as $field) {
        if (empty($input[$field])) {
            sendError("Field $field harus diisi");
        }
    }
    
    try {
        $idKendaraan = generateId('KND', $pdo, 'kendaraan', 'id_kendaraan');
        
        $stmt = $pdo->prepare("
            INSERT INTO kendaraan (id_kendaraan, id_pengguna, plat_nomor, merk, tipe, warna, tahun_pembuatan)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        ");
        
        $stmt->execute([
            $idKendaraan,
            $input['id_pengguna'],
            $input['plat_nomor'],
            $input['merk'],
            $input['tipe'],
            $input['warna'],
            $input['tahun_pembuatan']
        ]);
        
        sendResponse(true, 'Kendaraan berhasil didaftarkan', ['id_kendaraan' => $idKendaraan]);
    } catch (Exception $e) {
        sendError('Terjadi kesalahan: ' . $e->getMessage(), 500);
    }
}

function handlePut($pdo) {
    $input = json_decode(file_get_contents('php://input'), true);
    $id = $input['id_kendaraan'] ?? null;
    
    if (!$id) {
        sendError('ID kendaraan harus diisi');
    }
    
    try {
        // Get old data for audit
        $stmt = $pdo->prepare("SELECT * FROM kendaraan WHERE id_kendaraan = ?");
        $stmt->execute([$id]);
        $oldData = $stmt->fetch();
        
        if (!$oldData) {
            sendError('Kendaraan tidak ditemukan', 404);
        }
        
        // Build update query dynamically
        $fields = [];
        $values = [];
        
        $allowedFields = ['plat_nomor', 'merk', 'tipe', 'warna', 'tahun_pembuatan'];
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
        $sql = "UPDATE kendaraan SET " . implode(', ', $fields) . " WHERE id_kendaraan = ?";
        $stmt = $pdo->prepare($sql);
        $stmt->execute($values);
        
        // Add audit log if admin made changes
        if (!empty($input['admin_id'])) {
            addAuditLog($pdo, $input['admin_id'], 'kendaraan', 'UPDATE', $id, $oldData, $input, 'Update data kendaraan');
        }
        
        sendResponse(true, 'Kendaraan berhasil diupdate');
    } catch (Exception $e) {
        sendError('Terjadi kesalahan: ' . $e->getMessage(), 500);
    }
}

function handleDelete($pdo) {
    $input = json_decode(file_get_contents('php://input'), true);
    $id = $input['id_kendaraan'] ?? $_GET['id'] ?? null;
    
    if (!$id) {
        sendError('ID kendaraan harus diisi');
    }
    
    try {
        // Get data for audit
        $stmt = $pdo->prepare("SELECT * FROM kendaraan WHERE id_kendaraan = ?");
        $stmt->execute([$id]);
        $oldData = $stmt->fetch();
        
        if (!$oldData) {
            sendError('Kendaraan tidak ditemukan', 404);
        }
        
        $stmt = $pdo->prepare("DELETE FROM kendaraan WHERE id_kendaraan = ?");
        $stmt->execute([$id]);
        
        // Add audit log if admin made changes
        if (!empty($input['admin_id'])) {
            addAuditLog($pdo, $input['admin_id'], 'kendaraan', 'DELETE', $id, $oldData, null, 'Hapus data kendaraan');
        }
        
        sendResponse(true, 'Kendaraan berhasil dihapus');
    } catch (Exception $e) {
        sendError('Terjadi kesalahan: ' . $e->getMessage(), 500);
    }
}
