<?php
// ============================================
// Petugas Keamanan API - CRUD Operations
// ============================================

define('API_ACCESS', true);
require_once 'config.php';

$method = $_SERVER['REQUEST_METHOD'];

// GET - Retrieve petugas data
if ($method === 'GET') {
    try {
        $pdo = getDBConnection();
        
        $id = $_GET['id'] ?? null;
        
        if ($id) {
            // Get single petugas
            $stmt = $pdo->prepare("SELECT * FROM petugas_keamanan WHERE id_petugas = ?");
            $stmt->execute([$id]);
            $petugas = $stmt->fetch();
            
            if ($petugas) {
                sendResponse(true, 'Data petugas ditemukan', ['petugas' => $petugas]);
            } else {
                sendError('Petugas tidak ditemukan', 404);
            }
        } else {
            // Get all petugas
            $status = $_GET['status'] ?? null;
            
            if ($status) {
                $stmt = $pdo->prepare("SELECT * FROM petugas_keamanan WHERE status = ? ORDER BY created_at DESC");
                $stmt->execute([$status]);
            } else {
                $stmt = $pdo->query("SELECT * FROM petugas_keamanan ORDER BY created_at DESC");
            }
            
            $petugas = $stmt->fetchAll();
            sendResponse(true, 'Data petugas berhasil diambil', ['petugas' => $petugas]);
        }
        
    } catch (Exception $e) {
        sendError('Terjadi kesalahan: ' . $e->getMessage(), 500);
    }
}

// POST - Create new petugas
elseif ($method === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    
    $nama = $input['nama'] ?? '';
    $email = $input['email'] ?? '';
    $password = $input['password'] ?? '';
    $nip = $input['nip'] ?? '';
    $shift = $input['shift'] ?? '';
    
    if (empty($nama) || empty($email) || empty($password)) {
        sendError('Nama, email, dan password harus diisi');
    }
    
    try {
        $pdo = getDBConnection();
        
        // Check if email already exists
        $stmt = $pdo->prepare("SELECT id_petugas FROM petugas_keamanan WHERE email = ?");
        $stmt->execute([$email]);
        if ($stmt->fetch()) {
            sendError('Email sudah terdaftar', 400);
        }
        
        // Generate ID
        $stmt = $pdo->query("SELECT id_petugas FROM petugas_keamanan ORDER BY id_petugas DESC LIMIT 1");
        $lastId = $stmt->fetch();
        
        if ($lastId) {
            $num = intval(substr($lastId['id_petugas'], 3)) + 1;
            $newId = 'PTG' . str_pad($num, 3, '0', STR_PAD_LEFT);
        } else {
            $newId = 'PTG001';
        }
        
        // Insert new petugas
        $stmt = $pdo->prepare("
            INSERT INTO petugas_keamanan (id_petugas, nama, email, password, nip, shift, role, status)
            VALUES (?, ?, ?, ?, ?, ?, 'petugas', 'aktif')
        ");
        
        $stmt->execute([$newId, $nama, $email, $password, $nip, $shift]);
        
        sendResponse(true, 'Petugas berhasil ditambahkan', ['id' => $newId]);
        
    } catch (Exception $e) {
        sendError('Terjadi kesalahan: ' . $e->getMessage(), 500);
    }
}

// PUT - Update petugas
elseif ($method === 'PUT') {
    $input = json_decode(file_get_contents('php://input'), true);
    
    $id = $input['id'] ?? '';
    
    if (empty($id)) {
        sendError('ID petugas harus diisi');
    }
    
    try {
        $pdo = getDBConnection();
        
        // Build update query dynamically
        $updates = [];
        $params = [];
        
        if (isset($input['nama'])) {
            $updates[] = "nama = ?";
            $params[] = $input['nama'];
        }
        if (isset($input['email'])) {
            $updates[] = "email = ?";
            $params[] = $input['email'];
        }
        if (isset($input['password'])) {
            $updates[] = "password = ?";
            $params[] = $input['password'];
        }
        if (isset($input['nip'])) {
            $updates[] = "nip = ?";
            $params[] = $input['nip'];
        }
        if (isset($input['shift'])) {
            $updates[] = "shift = ?";
            $params[] = $input['shift'];
        }
        if (isset($input['status'])) {
            $updates[] = "status = ?";
            $params[] = $input['status'];
        }
        
        if (empty($updates)) {
            sendError('Tidak ada data yang diupdate');
        }
        
        $params[] = $id;
        $sql = "UPDATE petugas_keamanan SET " . implode(", ", $updates) . " WHERE id_petugas = ?";
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);
        
        sendResponse(true, 'Data petugas berhasil diupdate');
        
    } catch (Exception $e) {
        sendError('Terjadi kesalahan: ' . $e->getMessage(), 500);
    }
}

// DELETE - Delete petugas
elseif ($method === 'DELETE') {
    $input = json_decode(file_get_contents('php://input'), true);
    
    $id = $input['id'] ?? '';
    
    if (empty($id)) {
        sendError('ID petugas harus diisi');
    }
    
    try {
        $pdo = getDBConnection();
        
        // Soft delete - change status to 'nonaktif'
        $stmt = $pdo->prepare("UPDATE petugas_keamanan SET status = 'nonaktif' WHERE id_petugas = ?");
        $stmt->execute([$id]);
        
        if ($stmt->rowCount() > 0) {
            sendResponse(true, 'Petugas berhasil dihapus');
        } else {
            sendError('Petugas tidak ditemukan', 404);
        }
        
    } catch (Exception $e) {
        sendError('Terjadi kesalahan: ' . $e->getMessage(), 500);
    }
}

else {
    sendError('Method not allowed', 405);
}
