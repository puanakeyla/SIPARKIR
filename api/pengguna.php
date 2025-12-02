<?php
// ============================================
// Pengguna API - CRUD Operations
// ============================================

define('API_ACCESS', true);
require_once 'config.php';

$method = $_SERVER['REQUEST_METHOD'];

// GET - Retrieve pengguna data
if ($method === 'GET') {
    try {
        $pdo = getDBConnection();
        
        $id = $_GET['id'] ?? null;
        
        if ($id) {
            // Get single pengguna
            $stmt = $pdo->prepare("SELECT * FROM pengguna WHERE id_pengguna = ?");
            $stmt->execute([$id]);
            $pengguna = $stmt->fetch();
            
            if ($pengguna) {
                sendResponse(true, 'Data pengguna ditemukan', ['pengguna' => $pengguna]);
            } else {
                sendError('Pengguna tidak ditemukan', 404);
            }
        } else {
            // Get all pengguna
            $status = $_GET['status'] ?? null;
            
            if ($status) {
                $stmt = $pdo->prepare("SELECT * FROM pengguna WHERE status = ? ORDER BY created_at DESC");
                $stmt->execute([$status]);
            } else {
                $stmt = $pdo->query("SELECT * FROM pengguna ORDER BY created_at DESC");
            }
            
            $pengguna = $stmt->fetchAll();
            sendResponse(true, 'Data pengguna berhasil diambil', ['pengguna' => $pengguna]);
        }
        
    } catch (Exception $e) {
        sendError('Terjadi kesalahan: ' . $e->getMessage(), 500);
    }
}

// POST - Create new pengguna
elseif ($method === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    
    $nama = $input['nama'] ?? '';
    $email = $input['email'] ?? '';
    $password = $input['password'] ?? '';
    $nim = $input['nim'] ?? '';
    
    if (empty($nama) || empty($email) || empty($password)) {
        sendError('Nama, email, dan password harus diisi');
    }
    
    try {
        $pdo = getDBConnection();
        
        // Check if email already exists
        $stmt = $pdo->prepare("SELECT id_pengguna FROM pengguna WHERE email = ?");
        $stmt->execute([$email]);
        if ($stmt->fetch()) {
            sendError('Email sudah terdaftar', 400);
        }
        
        // Generate ID
        $stmt = $pdo->query("SELECT id_pengguna FROM pengguna ORDER BY id_pengguna DESC LIMIT 1");
        $lastId = $stmt->fetch();
        
        if ($lastId) {
            $num = intval(substr($lastId['id_pengguna'], 3)) + 1;
            $newId = 'USR' . str_pad($num, 3, '0', STR_PAD_LEFT);
        } else {
            $newId = 'USR001';
        }
        
        // Insert new pengguna
        $stmt = $pdo->prepare("
            INSERT INTO pengguna (id_pengguna, nama, email, password, nim, role, status)
            VALUES (?, ?, ?, ?, ?, 'pengguna', 'aktif')
        ");
        
        $stmt->execute([$newId, $nama, $email, $password, $nim]);
        
        sendResponse(true, 'Pengguna berhasil ditambahkan', ['id' => $newId]);
        
    } catch (Exception $e) {
        sendError('Terjadi kesalahan: ' . $e->getMessage(), 500);
    }
}

// PUT - Update pengguna
elseif ($method === 'PUT') {
    $input = json_decode(file_get_contents('php://input'), true);
    
    $id = $input['id'] ?? '';
    
    if (empty($id)) {
        sendError('ID pengguna harus diisi');
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
        if (isset($input['nim'])) {
            $updates[] = "nim = ?";
            $params[] = $input['nim'];
        }
        if (isset($input['status'])) {
            $updates[] = "status = ?";
            $params[] = $input['status'];
        }
        
        if (empty($updates)) {
            sendError('Tidak ada data yang diupdate');
        }
        
        $params[] = $id;
        $sql = "UPDATE pengguna SET " . implode(", ", $updates) . " WHERE id_pengguna = ?";
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);
        
        sendResponse(true, 'Data pengguna berhasil diupdate');
        
    } catch (Exception $e) {
        sendError('Terjadi kesalahan: ' . $e->getMessage(), 500);
    }
}

// DELETE - Delete pengguna
elseif ($method === 'DELETE') {
    $input = json_decode(file_get_contents('php://input'), true);
    
    $id = $input['id'] ?? '';
    
    if (empty($id)) {
        sendError('ID pengguna harus diisi');
    }
    
    try {
        $pdo = getDBConnection();
        
        // Soft delete - change status to 'nonaktif'
        $stmt = $pdo->prepare("UPDATE pengguna SET status = 'nonaktif' WHERE id_pengguna = ?");
        $stmt->execute([$id]);
        
        if ($stmt->rowCount() > 0) {
            sendResponse(true, 'Pengguna berhasil dihapus');
        } else {
            sendError('Pengguna tidak ditemukan', 404);
        }
        
    } catch (Exception $e) {
        sendError('Terjadi kesalahan: ' . $e->getMessage(), 500);
    }
}

else {
    sendError('Method not allowed', 405);
}
