<?php
// ============================================
// Transaksi Parkir API - CRUD Operations
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
    default:
        sendError('Method not allowed', 405);
}

function handleGet($pdo) {
    $id = $_GET['id'] ?? null;
    $idPengguna = $_GET['id_pengguna'] ?? null;
    $status = $_GET['status'] ?? null;
    
    try {
        if ($id) {
            $stmt = $pdo->prepare("SELECT * FROM transaksi_parkir WHERE id_transaksi = ?");
            $stmt->execute([$id]);
            $transaksi = $stmt->fetch();
            sendResponse(true, 'Data transaksi ditemukan', $transaksi);
        } else {
            $sql = "SELECT t.*, p.nama as nama_pengguna, k.merk, k.tipe 
                    FROM transaksi_parkir t 
                    LEFT JOIN pengguna p ON t.id_pengguna = p.id_pengguna 
                    LEFT JOIN kendaraan k ON t.id_kendaraan = k.id_kendaraan 
                    WHERE 1=1";
            $params = [];
            
            if ($idPengguna) {
                $sql .= " AND t.id_pengguna = ?";
                $params[] = $idPengguna;
            }
            
            if ($status) {
                $sql .= " AND t.status = ?";
                $params[] = $status;
            }
            
            $sql .= " ORDER BY t.waktu_masuk DESC";
            
            $stmt = $pdo->prepare($sql);
            $stmt->execute($params);
            $transaksi = $stmt->fetchAll();
            sendResponse(true, 'Data transaksi berhasil dimuat', $transaksi);
        }
    } catch (Exception $e) {
        sendError('Terjadi kesalahan: ' . $e->getMessage(), 500);
    }
}

function handlePost($pdo) {
    $input = json_decode(file_get_contents('php://input'), true);
    $action = $input['action'] ?? 'checkin';
    
    try {
        if ($action === 'checkin') {
            // Check in (masuk parkir)
            $required = ['id_kendaraan', 'id_pengguna', 'plat_nomor', 'lokasi_parkir'];
            foreach ($required as $field) {
                if (empty($input[$field])) {
                    sendError("Field $field harus diisi");
                }
            }
            
            $idTransaksi = generateId('TRX', $pdo, 'transaksi_parkir', 'id_transaksi');
            
            $stmt = $pdo->prepare("
                INSERT INTO transaksi_parkir (id_transaksi, id_kendaraan, id_pengguna, plat_nomor, lokasi_parkir, waktu_masuk, status)
                VALUES (?, ?, ?, ?, ?, NOW(), 'aktif')
            ");
            
            $stmt->execute([
                $idTransaksi,
                $input['id_kendaraan'],
                $input['id_pengguna'],
                $input['plat_nomor'],
                $input['lokasi_parkir']
            ]);
            
            sendResponse(true, 'Check-in berhasil', ['id_transaksi' => $idTransaksi]);
            
        } elseif ($action === 'checkout') {
            // Check out (keluar parkir)
            $idTransaksi = $input['id_transaksi'] ?? null;
            
            if (!$idTransaksi) {
                sendError('ID transaksi harus diisi');
            }
            
            $stmt = $pdo->prepare("
                UPDATE transaksi_parkir 
                SET waktu_keluar = NOW(),
                    durasi_menit = TIMESTAMPDIFF(MINUTE, waktu_masuk, NOW()),
                    biaya = TIMESTAMPDIFF(MINUTE, waktu_masuk, NOW()) * 100,
                    status = 'selesai'
                WHERE id_transaksi = ? AND status = 'aktif'
            ");
            
            $stmt->execute([$idTransaksi]);
            
            if ($stmt->rowCount() > 0) {
                // Get updated data
                $stmt = $pdo->prepare("SELECT * FROM transaksi_parkir WHERE id_transaksi = ?");
                $stmt->execute([$idTransaksi]);
                $transaksi = $stmt->fetch();
                
                sendResponse(true, 'Check-out berhasil', $transaksi);
            } else {
                sendError('Transaksi tidak ditemukan atau sudah selesai', 404);
            }
        } else {
            sendError('Action tidak valid');
        }
    } catch (Exception $e) {
        sendError('Terjadi kesalahan: ' . $e->getMessage(), 500);
    }
}

function handlePut($pdo) {
    $input = json_decode(file_get_contents('php://input'), true);
    $id = $input['id_transaksi'] ?? null;
    
    if (!$id) {
        sendError('ID transaksi harus diisi');
    }
    
    try {
        $fields = [];
        $values = [];
        
        $allowedFields = ['lokasi_parkir', 'status', 'biaya'];
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
        $sql = "UPDATE transaksi_parkir SET " . implode(', ', $fields) . " WHERE id_transaksi = ?";
        $stmt = $pdo->prepare($sql);
        $stmt->execute($values);
        
        sendResponse(true, 'Transaksi berhasil diupdate');
    } catch (Exception $e) {
        sendError('Terjadi kesalahan: ' . $e->getMessage(), 500);
    }
}
