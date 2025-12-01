<?php
// ============================================
// Audit Log API
// ============================================

define('API_ACCESS', true);
require_once 'config.php';

$method = $_SERVER['REQUEST_METHOD'];
$pdo = getDBConnection();

if ($method === 'GET') {
    $idAdmin = $_GET['id_admin'] ?? null;
    $tabel = $_GET['tabel'] ?? null;
    $limit = $_GET['limit'] ?? 100;
    
    try {
        $sql = "SELECT a.*, ad.nama as nama_admin 
                FROM audit_log a 
                LEFT JOIN admin ad ON a.id_admin = ad.id_admin 
                WHERE 1=1";
        $params = [];
        
        if ($idAdmin) {
            $sql .= " AND a.id_admin = ?";
            $params[] = $idAdmin;
        }
        
        if ($tabel) {
            $sql .= " AND a.tabel_target = ?";
            $params[] = $tabel;
        }
        
        $sql .= " ORDER BY a.waktu_aksi DESC LIMIT ?";
        $params[] = (int)$limit;
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);
        $logs = $stmt->fetchAll();
        
        sendResponse(true, 'Data audit log berhasil dimuat', $logs);
    } catch (Exception $e) {
        sendError('Terjadi kesalahan: ' . $e->getMessage(), 500);
    }
} else {
    sendError('Method not allowed', 405);
}
