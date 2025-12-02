<?php
// ============================================
// Sistem Parkir API - Monitoring & Laporan
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
    default:
        sendError('Method not allowed', 405);
}

function handleGet($pdo) {
    $action = $_GET['action'] ?? 'status';
    
    try {
        if ($action === 'status') {
            // Get current system status
            $stmt = $pdo->query("SELECT * FROM sistem_parkir ORDER BY waktu_monitoring DESC LIMIT 1");
            $sistem = $stmt->fetch();
            
            if (!$sistem) {
                // Create default if not exists
                $idSistem = 'SYS001';
                $idAdmin = 'ADM001'; // Default admin
                $stmt = $pdo->prepare("INSERT INTO sistem_parkir (id_sistem, id_admin, status_sistem, waktu_monitoring) VALUES (?, ?, 'Aktif', NOW())");
                $stmt->execute([$idSistem, $idAdmin]);
                
                $stmt = $pdo->prepare("SELECT * FROM sistem_parkir WHERE id_sistem = ?");
                $stmt->execute([$idSistem]);
                $sistem = $stmt->fetch();
            }
            
            sendResponse(true, 'Status sistem berhasil dimuat', $sistem);
            
        } elseif ($action === 'monitoring') {
            // Get monitoring data (statistics)
            $stats = getMonitoringStats($pdo);
            sendResponse(true, 'Data monitoring berhasil dimuat', $stats);
            
        } elseif ($action === 'laporan') {
            // Generate report
            $laporan = generateLaporan($pdo);
            
            // Update sistem_parkir with generated report
            $stmt = $pdo->prepare("
                UPDATE sistem_parkir 
                SET generated_laporan = ?, waktu_monitoring = NOW()
                WHERE id_sistem = 'SYS001'
            ");
            $stmt->execute([json_encode($laporan)]);
            
            sendResponse(true, 'Laporan berhasil digenerate', $laporan);
        }
    } catch (Exception $e) {
        sendError('Terjadi kesalahan: ' . $e->getMessage(), 500);
    }
}

function handlePost($pdo) {
    $input = json_decode(file_get_contents('php://input'), true);
    $action = $input['action'] ?? null;
    
    if ($action === 'update_status') {
        $statusSistem = $input['status_sistem'] ?? null;
        $idAdmin = $input['id_admin'] ?? null;
        
        if (!$statusSistem) {
            sendError('Status sistem harus diisi');
        }
        
        try {
            if ($idAdmin) {
                // Update dengan admin yang melakukan perubahan
                $stmt = $pdo->prepare("
                    UPDATE sistem_parkir 
                    SET status_sistem = ?, id_admin = ?, waktu_monitoring = NOW()
                    WHERE id_sistem = 'SYS001'
                ");
                $stmt->execute([$statusSistem, $idAdmin]);
            } else {
                // Update tanpa mengubah admin
                $stmt = $pdo->prepare("
                    UPDATE sistem_parkir 
                    SET status_sistem = ?, waktu_monitoring = NOW()
                    WHERE id_sistem = 'SYS001'
                ");
                $stmt->execute([$statusSistem]);
            }
            
            sendResponse(true, 'Status sistem berhasil diupdate');
        } catch (Exception $e) {
            sendError('Terjadi kesalahan: ' . $e->getMessage(), 500);
        }
    }
}

function handlePut($pdo) {
    handlePost($pdo);
}

// Helper function: Get monitoring statistics
function getMonitoringStats($pdo) {
    // Total pengguna
    $stmt = $pdo->query("SELECT COUNT(*) as total FROM pengguna WHERE status = 'aktif'");
    $totalPengguna = $stmt->fetch()['total'];
    
    // Total kendaraan terdaftar
    $stmt = $pdo->query("SELECT COUNT(*) as total FROM kendaraan WHERE status_parkir = 'aktif'");
    $totalKendaraan = $stmt->fetch()['total'];
    
    // Kendaraan sedang parkir (waktu_keluar IS NULL)
    $stmt = $pdo->query("SELECT COUNT(*) as total FROM riwayat_parkir WHERE waktu_keluar IS NULL");
    $kendaraanParkir = $stmt->fetch()['total'];
    
    // Transaksi hari ini
    $stmt = $pdo->query("SELECT COUNT(*) as total FROM riwayat_parkir WHERE DATE(waktu_masuk) = CURDATE()");
    $transaksiHariIni = $stmt->fetch()['total'];
    
    // Total laporan kehilangan
    $stmt = $pdo->query("SELECT COUNT(*) as total FROM laporan_kehilangan");
    $totalLaporan = $stmt->fetch()['total'];
    
    // Laporan pending
    $stmt = $pdo->query("SELECT COUNT(*) as total FROM laporan_kehilangan WHERE status_laporan = 'Pending'");
    $laporanPending = $stmt->fetch()['total'];
    
    return [
        'total_pengguna' => (int)$totalPengguna,
        'total_kendaraan' => (int)$totalKendaraan,
        'kendaraan_parkir' => (int)$kendaraanParkir,
        'transaksi_hari_ini' => (int)$transaksiHariIni,
        'total_laporan' => (int)$totalLaporan,
        'laporan_pending' => (int)$laporanPending,
        'waktu_monitoring' => date('Y-m-d H:i:s')
    ];
}

// Helper function: Generate report
function generateLaporan($pdo) {
    $stats = getMonitoringStats($pdo);
    
    // Get recent riwayat
    $stmt = $pdo->query("
        SELECT r.*, k.plat_nomor, p.nama as nama_pemilik
        FROM riwayat_parkir r
        LEFT JOIN kendaraan k ON r.id_kendaraan = k.id_kendaraan
        LEFT JOIN pengguna p ON k.id_pengguna = p.id_pengguna
        WHERE DATE(r.waktu_masuk) = CURDATE()
        ORDER BY r.waktu_masuk DESC
        LIMIT 10
    ");
    $recentRiwayat = $stmt->fetchAll();
    
    // Get laporan kehilangan terbaru
    $stmt = $pdo->query("
        SELECT l.*, p.nama as pelapor, k.plat_nomor
        FROM laporan_kehilangan l
        LEFT JOIN pengguna p ON l.id_pengguna = p.id_pengguna
        LEFT JOIN kendaraan k ON l.id_kendaraan = k.id_kendaraan
        ORDER BY l.tanggal_laporan DESC
        LIMIT 5
    ");
    $recentLaporan = $stmt->fetchAll();
    
    return [
        'tanggal_generate' => date('Y-m-d H:i:s'),
        'statistik' => $stats,
        'riwayat_terbaru' => $recentRiwayat,
        'laporan_terbaru' => $recentLaporan
    ];
}
?>
