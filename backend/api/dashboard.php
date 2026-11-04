<?php
/**
 * FinWise API - Home Dashboard Data & Operations
 * GET  /backend/api/dashboard.php - Fetch balance, 7-day trends, recent transactions, AI alert
 * POST /backend/api/dashboard.php - Quick action (e.g. transfer RM50 to emergency fund or log sample transaction)
 */

declare(strict_types=1);

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../includes/security.php';
require_once __DIR__ . '/../includes/authentication.php';

use FinWise\Config\Database;
use FinWise\Includes\Security;
use FinWise\Includes\Authentication;

Security::sendHeaders();

// Verify user authentication
$user = Authentication::authenticateRequest();
$userId = (int)$user['id'];
$pdo = Database::getConnection();

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $input = Security::getJsonInput();
    $action = trim((string)($input['action'] ?? ''));

    if ($action === 'quick_transfer_savings') {
        $amount = (float)($input['amount'] ?? 50.00);
        // Record demo transfer transaction
        $stmt = $pdo->prepare("
            INSERT INTO transactions (user_id, transaction_name, category, amount, transaction_type, transaction_date, payment_method, note)
            VALUES (:user_id, 'Emergency Fund Allocation', 'Savings', :amount, 'expense', NOW(), 'Internal Transfer', 'Auto AI Spend Rule')
        ");
        $stmt->execute([
            'user_id' => $userId,
            'amount'  => $amount
        ]);

        Security::jsonResponse(true, "Transferred RM " . number_format($amount, 2) . " to Emergency Fund!", [
            'transferred_amount' => $amount
        ]);
    }

    if ($action === 'add_transaction') {
        $name     = trim((string)($input['name'] ?? 'Quick Campus Expense'));
        $category = trim((string)($input['category'] ?? 'Food & Dining'));
        $amount   = (float)($input['amount'] ?? 0.0);
        $type     = in_array($input['type'] ?? '', ['income', 'expense']) ? $input['type'] : 'expense';
        $method   = trim((string)($input['method'] ?? 'Debit Card'));

        if ($amount <= 0) {
            Security::jsonResponse(false, 'Amount must be greater than zero.', [], 422);
        }

        $stmt = $pdo->prepare("
            INSERT INTO transactions (user_id, transaction_name, category, amount, transaction_type, transaction_date, payment_method, note)
            VALUES (:user_id, :name, :category, :amount, :type, NOW(), :method, 'Logged from Android app')
        ");
        $stmt->execute([
            'user_id'  => $userId,
            'name'     => $name,
            'category' => $category,
            'amount'   => $amount,
            'type'     => $type,
            'method'   => $method
        ]);

        Security::jsonResponse(true, 'Transaction added successfully.', [], 201);
    }
}

// GET: Return Dashboard Data
// 1. Fetch recent transactions
$stmt = $pdo->prepare("
    SELECT id, transaction_name, category, amount, transaction_type, transaction_date, payment_method, note
    FROM transactions
    WHERE user_id = :user_id
    ORDER BY transaction_date DESC
    LIMIT 4
");
$stmt->execute(['user_id' => $userId]);
$recentTransactions = $stmt->fetchAll();

// If user has no transactions yet, provide standard reference transactions
if (empty($recentTransactions)) {
    $recentTransactions = [
        [
            'id' => 1,
            'transaction_name' => 'UTM Arked Cengal - Lunch',
            'category' => 'Food & Dining',
            'amount' => 8.50,
            'transaction_type' => 'expense',
            'transaction_date' => date('Y-m-d H:i:s'),
            'payment_method' => 'Debit Card',
            'note' => 'Savings target met'
        ],
        [
            'id' => 2,
            'transaction_name' => 'Monthly Allowance',
            'category' => 'Family Transfer',
            'amount' => 800.00,
            'transaction_type' => 'income',
            'transaction_date' => date('Y-m-d H:i:s', strtotime('-1 day')),
            'payment_method' => 'Bank Direct',
            'note' => 'Family Transfer'
        ],
        [
            'id' => 3,
            'transaction_name' => 'Campus Bookstore - Stationery',
            'category' => 'Education',
            'amount' => 34.00,
            'transaction_type' => 'expense',
            'transaction_date' => date('Y-m-d H:i:s', strtotime('-3 days')),
            'payment_method' => 'Debit Card',
            'note' => 'Debit Card'
        ],
        [
            'id' => 4,
            'transaction_name' => 'Grab Ride to Senai',
            'category' => 'Transport',
            'amount' => 22.00,
            'transaction_type' => 'expense',
            'transaction_date' => date('Y-m-d H:i:s', strtotime('-5 days')),
            'payment_method' => 'GrabPay',
            'note' => 'GrabPay'
        ]
    ];
}

// 2. 7-Day Outflow Trend (Mon - Sun)
$trendDays = [
    ['day' => 'M', 'full_day' => 'Mon', 'amount' => 35.00, 'is_today' => false, 'is_peak' => false],
    ['day' => 'T', 'full_day' => 'Tue', 'amount' => 52.00, 'is_today' => false, 'is_peak' => false],
    ['day' => 'W', 'full_day' => 'Wed', 'amount' => 24.50, 'is_today' => false, 'is_peak' => false],
    ['day' => 'T', 'full_day' => 'Thu', 'amount' => 62.00, 'is_today' => false, 'is_peak' => false],
    ['day' => 'F', 'full_day' => 'Fri', 'amount' => 41.00, 'is_today' => false, 'is_peak' => false],
    ['day' => 'S', 'full_day' => 'Sat', 'amount' => 78.50, 'is_today' => false, 'is_peak' => true],
    ['day' => 'S', 'full_day' => 'Sun', 'amount' => 30.50, 'is_today' => true,  'is_peak' => false],
];

// Response payload strictly aligned with FinWise Dashboard UI reference
Security::jsonResponse(true, 'Dashboard data loaded.', [
    'user' => [
        'id'        => $user['id'],
        'full_name' => $user['full_name'],
        'email'     => $user['email'],
        'matric_id' => $user['matric_id'] ?? 'A23CS0123'
    ],
    'campus_info' => [
        'campus'   => 'UTM Skudai Campus',
        'subtitle' => 'Financial Snapshot',
        'period'   => 'Nov 2024'
    ],
    'balance' => [
        'currency'          => 'RM',
        'total_available'   => 3420.50,
        'formatted_total'   => '3,420.50',
        'total_income'      => 2800.00,
        'formatted_income'  => '+RM 2,800.00',
        'total_expense'     => 1485.20,
        'formatted_expense' => '-RM 1,485.20',
        'status'            => 'Active'
    ],
    'ai_insight' => [
        'tag'               => 'SMART SPEND ALERT',
        'time_label'        => 'Just now',
        'message'           => "You've spent 20% less on food this week at UTM Arked. Great job! Move RM50 to your Emergency Fund?",
        'action_label'      => 'Transfer RM50',
        'action_amount'     => 50.00,
        'is_dismissible'    => true
    ],
    'outflow_trend' => [
        'title'             => '7-Day Outflow Trend',
        'daily_average'     => 'RM 45/day',
        'days'              => $trendDays
    ],
    'recent_transactions' => $recentTransactions
]);

