<?php
// ============================================
// Database Configuration for XAMPP MySQL
// ============================================

// Prevent direct access
if (!defined('API_ACCESS')) {
    http_response_code(403);
    die('Direct access forbidden');
}

// Database credentials
define('DB_HOST', 'localhost');
define('DB_USER', 'root');
define('DB_PASS', '');
define('DB_NAME', 'siparkir');
define('DB_CHARSET', 'utf8mb4');

// Timezone
date_default_timezone_set('Asia/Jakarta');

// CORS Headers
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Content-Type: application/json; charset=utf-8');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Database Connection Function
function getDBConnection() {
    try {
        $dsn = "mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=" . DB_CHARSET;
        $options = [
            PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES   => false,
        ];
        
        $pdo = new PDO($dsn, DB_USER, DB_PASS, $options);
        return $pdo;
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Database connection failed: ' . $e->getMessage()
        ]);
        exit();
    }
}

// Response Helper Functions
function sendResponse($success, $message, $data = null) {
    echo json_encode([
        'success' => $success,
        'message' => $message,
        'data' => $data,
        'timestamp' => date('Y-m-d H:i:s')
    ]);
    exit();
}

function sendError($message, $code = 400) {
    http_response_code($code);
    sendResponse(false, $message);
}

// Generate ID Function
function generateId($prefix, $pdo, $table, $column) {
    $stmt = $pdo->prepare("SELECT $column FROM $table WHERE $column LIKE ? ORDER BY $column DESC LIMIT 1");
    $stmt->execute([$prefix . '%']);
    $last = $stmt->fetch();
    
    if ($last) {
        $num = intval(substr($last[$column], strlen($prefix))) + 1;
    } else {
        $num = 1;
    }
    
    return $prefix . str_pad($num, 3, '0', STR_PAD_LEFT);
}

// Audit Log Function
function addAuditLog($pdo, $idAdmin, $tabelTarget, $aksi, $idRecord = null, $dataLama = null, $dataBaru = null, $keterangan = null) {
    try {
        $idLog = generateId('AUD', $pdo, 'audit_log', 'id_log');
        
        $stmt = $pdo->prepare("
            INSERT INTO audit_log (id_log, id_admin, tabel_target, aksi, id_record, data_lama, data_baru, keterangan)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ");
        
        $stmt->execute([
            $idLog,
            $idAdmin,
            $tabelTarget,
            $aksi,
            $idRecord,
            $dataLama ? json_encode($dataLama) : null,
            $dataBaru ? json_encode($dataBaru) : null,
            $keterangan
        ]);
        
        return true;
    } catch (Exception $e) {
        error_log("Audit log failed: " . $e->getMessage());
        return false;
    }
}
