<?php
// ============================================
// Pencatatan Petugas API - CRUD Operations
// ============================================

define('API_ACCESS', true);
require_once 'config.php';

$method = $_SERVER['REQUEST_METHOD'];

// GET - Retrieve pencatatan data
if ($method === 'GET') {
    try {
        $pdo = getDBConnection();
        
        $id = $_GET['id'] ?? null;
        $idPetugas = $_GET['id_petugas'] ?? null;
        
        if ($id) {
            // Get single pencatatan
            $stmt = $pdo->prepare("SELECT * FROM pencatatan_petugas WHERE id_pencatatan = ?");
            $stmt->execute([$id]);
            $pencatatan = $stmt->fetch();
            
            if ($pencatatan) {
                sendResponse(true, 'Data pencatatan ditemukan', ['pencatatan' => $pencatatan]);
            } else {
                sendError('Pencatatan tidak ditemukan', 404);
            }
        } elseif ($idPetugas) {
            // Get pencatatan by petugas
            $stmt = $pdo->prepare("SELECT * FROM pencatatan_petugas WHERE id_petugas = ? ORDER BY waktu_pencatatan DESC");
            $stmt->execute([$idPetugas]);
            $pencatatan = $stmt->fetchAll();
            sendResponse(true, 'Data pencatatan berhasil diambil', ['pencatatan' => $pencatatan]);
        } else {
            // Get all pencatatan
            $stmt = $pdo->query("SELECT p.*, pt.nama as nama_petugas FROM pencatatan_petugas p LEFT JOIN petugas_keamanan pt ON p.id_petugas = pt.id_petugas ORDER BY p.waktu_pencatatan DESC");
            $pencatatan = $stmt->fetchAll();
            sendResponse(true, 'Data pencatatan berhasil diambil', ['pencatatan' => $pencatatan]);
        }
        
    } catch (Exception $e) {
        sendError('Terjadi kesalahan: ' . $e->getMessage(), 500);
    }
}

// POST - Create new pencatatan
elseif ($method === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    
    $id_petugas = $input['id_petugas'] ?? '';
    $plat_nomor = $input['plat_nomor'] ?? '';
    $jenis_kendaraan = $input['jenis_kendaraan'] ?? '';
    $lokasi_penjagaan = $input['lokasi_penjagaan'] ?? '';
    $status_transaksi = $input['status_transaksi'] ?? '';
    $catatan = $input['catatan'] ?? '';
    
    if (empty($id_petugas) || empty($plat_nomor) || empty($jenis_kendaraan)) {
        sendError('ID petugas, plat nomor, dan jenis kendaraan harus diisi');
    }
    
    try {
        $pdo = getDBConnection();
        
        // Generate ID
        $stmt = $pdo->query("SELECT id_pencatatan FROM pencatatan_petugas ORDER BY id_pencatatan DESC LIMIT 1");
        $lastId = $stmt->fetch();
        
        if ($lastId) {
            $num = intval(substr($lastId['id_pencatatan'], 3)) + 1;
            $newId = 'PNC' . str_pad($num, 3, '0', STR_PAD_LEFT);
        } else {
            $newId = 'PNC001';
        }
        
        // Insert new pencatatan
        $stmt = $pdo->prepare("
            INSERT INTO pencatatan_petugas (id_pencatatan, id_petugas, plat_nomor, jenis_kendaraan, lokasi_penjagaan, status_transaksi, waktu_pencatatan, catatan)
            VALUES (?, ?, ?, ?, ?, ?, NOW(), ?)
        ");
        
        $stmt->execute([$newId, $id_petugas, $plat_nomor, $jenis_kendaraan, $lokasi_penjagaan, $status_transaksi, $catatan]);
        
        sendResponse(true, 'Pencatatan berhasil ditambahkan', ['id' => $newId]);
        
    } catch (Exception $e) {
        sendError('Terjadi kesalahan: ' . $e->getMessage(), 500);
    }
}

// PUT - Update pencatatan
elseif ($method === 'PUT') {
    $input = json_decode(file_get_contents('php://input'), true);
    
    $id = $input['id'] ?? '';
    
    if (empty($id)) {
        sendError('ID pencatatan harus diisi');
    }
    
    try {
        $pdo = getDBConnection();
        
        // Build update query dynamically
        $updates = [];
        $params = [];
        
        if (isset($input['plat_nomor'])) {
            $updates[] = "plat_nomor = ?";
            $params[] = $input['plat_nomor'];
        }
        if (isset($input['jenis_kendaraan'])) {
            $updates[] = "jenis_kendaraan = ?";
            $params[] = $input['jenis_kendaraan'];
        }
        if (isset($input['lokasi_penjagaan'])) {
            $updates[] = "lokasi_penjagaan = ?";
            $params[] = $input['lokasi_penjagaan'];
        }
        if (isset($input['status_transaksi'])) {
            $updates[] = "status_transaksi = ?";
            $params[] = $input['status_transaksi'];
        }
        if (isset($input['catatan'])) {
            $updates[] = "catatan = ?";
            $params[] = $input['catatan'];
        }
        
        if (empty($updates)) {
            sendError('Tidak ada data yang diupdate');
        }
        
        $params[] = $id;
        $sql = "UPDATE pencatatan_petugas SET " . implode(", ", $updates) . " WHERE id_pencatatan = ?";
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);
        
        sendResponse(true, 'Data pencatatan berhasil diupdate');
        
    } catch (Exception $e) {
        sendError('Terjadi kesalahan: ' . $e->getMessage(), 500);
    }
}

// DELETE - Delete pencatatan
elseif ($method === 'DELETE') {
    $input = json_decode(file_get_contents('php://input'), true);
    
    $id = $input['id'] ?? '';
    
    if (empty($id)) {
        sendError('ID pencatatan harus diisi');
    }
    
    try {
        $pdo = getDBConnection();
        
        $stmt = $pdo->prepare("DELETE FROM pencatatan_petugas WHERE id_pencatatan = ?");
        $stmt->execute([$id]);
        
        if ($stmt->rowCount() > 0) {
            sendResponse(true, 'Pencatatan berhasil dihapus');
        } else {
            sendError('Pencatatan tidak ditemukan', 404);
        }
        
    } catch (Exception $e) {
        sendError('Terjadi kesalahan: ' . $e->getMessage(), 500);
    }
}

else {
    sendError('Method not allowed', 405);
}
