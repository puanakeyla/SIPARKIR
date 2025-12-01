<?php
// ============================================
// Laporan Kehilangan API - CRUD Operations
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
    $idPengguna = $_GET['id_pengguna'] ?? null;
    $idPetugas = $_GET['id_petugas'] ?? null;
    $status = $_GET['status_laporan'] ?? null;
    
    try {
        if ($id) {
            // Get single laporan
            $stmt = $pdo->prepare("
                SELECT l.*, 
                       p.nama as nama_pelapor, p.username as username_pelapor,
                       k.plat_nomor, k.merk, k.tipe,
                       pt.nama as nama_petugas
                FROM laporan_kehilangan l
                LEFT JOIN pengguna p ON l.id_pengguna = p.id_pengguna
                LEFT JOIN kendaraan k ON l.id_kendaraan = k.id_kendaraan
                LEFT JOIN petugas_keamanan pt ON l.id_petugas = pt.id_petugas
                WHERE l.id_laporan = ?
            ");
            $stmt->execute([$id]);
            $laporan = $stmt->fetch();
            
            if ($laporan) {
                sendResponse(true, 'Data laporan ditemukan', $laporan);
            } else {
                sendError('Laporan tidak ditemukan', 404);
            }
        } else {
            // Build query with filters
            $sql = "
                SELECT l.*, 
                       p.nama as nama_pelapor, p.username as username_pelapor,
                       k.plat_nomor, k.merk, k.tipe,
                       pt.nama as nama_petugas
                FROM laporan_kehilangan l
                LEFT JOIN pengguna p ON l.id_pengguna = p.id_pengguna
                LEFT JOIN kendaraan k ON l.id_kendaraan = k.id_kendaraan
                LEFT JOIN petugas_keamanan pt ON l.id_petugas = pt.id_petugas
                WHERE 1=1
            ";
            $params = [];
            
            if ($idPengguna) {
                $sql .= " AND l.id_pengguna = ?";
                $params[] = $idPengguna;
            }
            
            if ($idPetugas) {
                $sql .= " AND l.id_petugas = ?";
                $params[] = $idPetugas;
            }
            
            if ($status) {
                $sql .= " AND l.status_laporan = ?";
                $params[] = $status;
            }
            
            $sql .= " ORDER BY l.tanggal_laporan DESC";
            
            $stmt = $pdo->prepare($sql);
            $stmt->execute($params);
            $laporan = $stmt->fetchAll();
            sendResponse(true, 'Data laporan berhasil dimuat', $laporan);
        }
    } catch (Exception $e) {
        sendError('Terjadi kesalahan: ' . $e->getMessage(), 500);
    }
}

function handlePost($pdo) {
    $input = json_decode(file_get_contents('php://input'), true);
    
    $required = ['id_pengguna', 'id_kendaraan', 'waktu_kejadian', 'lokasi_kehilangan', 'deskripsi'];
    foreach ($required as $field) {
        if (empty($input[$field])) {
            sendError("Field $field harus diisi");
        }
    }
    
    try {
        $idLaporan = generateId('LAP', $pdo, 'laporan_kehilangan', 'id_laporan');
        
        $stmt = $pdo->prepare("
            INSERT INTO laporan_kehilangan (
                id_laporan, id_pengguna, id_kendaraan, 
                tanggal_laporan, waktu_kejadian, lokasi_kehilangan, 
                deskripsi, status_laporan
            )
            VALUES (?, ?, ?, NOW(), ?, ?, ?, 'Pending')
        ");
        
        $stmt->execute([
            $idLaporan,
            $input['id_pengguna'],
            $input['id_kendaraan'],
            $input['waktu_kejadian'],
            $input['lokasi_kehilangan'],
            $input['deskripsi']
        ]);
        
        sendResponse(true, 'Laporan kehilangan berhasil dibuat', ['id_laporan' => $idLaporan]);
    } catch (Exception $e) {
        sendError('Terjadi kesalahan: ' . $e->getMessage(), 500);
    }
}

function handlePut($pdo) {
    $input = json_decode(file_get_contents('php://input'), true);
    $id = $input['id_laporan'] ?? null;
    
    if (!$id) {
        sendError('ID laporan harus diisi');
    }
    
    try {
        // Check if laporan exists
        $stmt = $pdo->prepare("SELECT * FROM laporan_kehilangan WHERE id_laporan = ?");
        $stmt->execute([$id]);
        $oldData = $stmt->fetch();
        
        if (!$oldData) {
            sendError('Laporan tidak ditemukan', 404);
        }
        
        // Build update query
        $fields = [];
        $values = [];
        
        $allowedFields = [
            'id_petugas', 'waktu_kejadian', 'lokasi_kehilangan', 
            'deskripsi', 'status_laporan'
        ];
        
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
        $sql = "UPDATE laporan_kehilangan SET " . implode(', ', $fields) . " WHERE id_laporan = ?";
        $stmt = $pdo->prepare($sql);
        $stmt->execute($values);
        
        sendResponse(true, 'Laporan berhasil diupdate');
    } catch (Exception $e) {
        sendError('Terjadi kesalahan: ' . $e->getMessage(), 500);
    }
}

function handleDelete($pdo) {
    $input = json_decode(file_get_contents('php://input'), true);
    $id = $input['id_laporan'] ?? $_GET['id'] ?? null;
    
    if (!$id) {
        sendError('ID laporan harus diisi');
    }
    
    try {
        $stmt = $pdo->prepare("DELETE FROM laporan_kehilangan WHERE id_laporan = ?");
        $stmt->execute([$id]);
        
        if ($stmt->rowCount() > 0) {
            sendResponse(true, 'Laporan berhasil dihapus');
        } else {
            sendError('Laporan tidak ditemukan', 404);
        }
    } catch (Exception $e) {
        sendError('Terjadi kesalahan: ' . $e->getMessage(), 500);
    }
}
?>
