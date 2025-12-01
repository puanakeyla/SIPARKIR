<?php
// ============================================
// Authentication API - Login
// ============================================

define('API_ACCESS', true);
require_once 'config.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    
    $email = $input['email'] ?? '';
    $password = $input['password'] ?? '';
    
    if (empty($email) || empty($password)) {
        sendError('Email dan password harus diisi');
    }
    
    try {
        $pdo = getDBConnection();
        
        // Check admin table
        $stmt = $pdo->prepare("SELECT * FROM admin WHERE email = ? AND password = ? AND status = 'aktif'");
        $stmt->execute([$email, $password]);
        $admin = $stmt->fetch();
        
        if ($admin) {
            sendResponse(true, 'Login berhasil', [
                'user' => [
                    'id' => $admin['id_admin'],
                    'nama' => $admin['nama'],
                    'email' => $admin['email'],
                    'role' => $admin['role']
                ],
                'redirect' => 'admin.html'
            ]);
        }
        
        // Check pengguna table
        $stmt = $pdo->prepare("SELECT * FROM pengguna WHERE email = ? AND password = ? AND status = 'aktif'");
        $stmt->execute([$email, $password]);
        $pengguna = $stmt->fetch();
        
        if ($pengguna) {
            sendResponse(true, 'Login berhasil', [
                'user' => [
                    'id' => $pengguna['id_pengguna'],
                    'nama' => $pengguna['nama'],
                    'email' => $pengguna['email'],
                    'role' => $pengguna['role'],
                    'nim' => $pengguna['nim'],
                    'peran' => $pengguna['peran']
                ],
                'redirect' => 'pengguna.html'
            ]);
        }
        
        // Check petugas table
        $stmt = $pdo->prepare("SELECT * FROM petugas_keamanan WHERE email = ? AND password = ? AND status = 'aktif'");
        $stmt->execute([$email, $password]);
        $petugas = $stmt->fetch();
        
        if ($petugas) {
            sendResponse(true, 'Login berhasil', [
                'user' => [
                    'id' => $petugas['id_petugas'],
                    'nama' => $petugas['nama'],
                    'email' => $petugas['email'],
                    'role' => $petugas['role'],
                    'nip' => $petugas['nip'],
                    'shift' => $petugas['shift']
                ],
                'redirect' => 'petugas.html'
            ]);
        }
        
        // If no match found
        sendError('Email atau password salah', 401);
        
    } catch (Exception $e) {
        sendError('Terjadi kesalahan: ' . $e->getMessage(), 500);
    }
} else {
    sendError('Method not allowed', 405);
}
