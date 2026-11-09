<?php
/** FinWise user-scoped dashboard and transaction API. */
declare(strict_types=1);

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../includes/security.php';
require_once __DIR__ . '/../includes/authentication.php';

use FinWise\Config\Database;
use FinWise\Includes\Security;
use FinWise\Includes\Authentication;

Security::sendHeaders();
$user = Authentication::authenticateRequest();
$userId = (int)$user['id'];
$pdo = Database::getConnection();

function requestString(array $input, string $key): string {
    return trim((string)($input[$key] ?? ''));
}

function validDate(string $date): bool {
    $parsed = DateTime::createFromFormat('Y-m-d', $date);
    return $parsed !== false && $parsed->format('Y-m-d') === $date;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $input = Security::getJsonInput();
    $action = requestString($input, 'action');

    if ($action === 'add_transaction' || $action === 'update_transaction') {
        $name = requestString($input, 'description') ?: requestString($input, 'name');
        $category = requestString($input, 'category');
        $type = requestString($input, 'type');
        $date = requestString($input, 'date') ?: date('Y-m-d');
        $amount = (float)($input['amount'] ?? 0);

        if ($name === '' || strlen($name) > 200) {
            Security::jsonResponse(false, 'Please enter a transaction description.', [], 422);
        }
        if ($category === '' || strlen($category) > 100) {
            Security::jsonResponse(false, 'Please select a category.', [], 422);
        }
        if (!in_array($type, ['income', 'expense'], true)) {
            Security::jsonResponse(false, 'Transaction type must be income or expense.', [], 422);
        }
        if ($amount <= 0 || $amount > 99999999) {
            Security::jsonResponse(false, 'Amount must be greater than zero.', [], 422);
        }
        if (!validDate($date)) {
            Security::jsonResponse(false, 'Please enter a valid date.', [], 422);
        }

        if ($action === 'add_transaction') {
            $stmt = $pdo->prepare("INSERT INTO transactions
                (user_id, transaction_name, category, amount, transaction_type, transaction_date, payment_method, note)
                VALUES (:user_id, :name, :category, :amount, :type, :date, 'Direct', NULL)");
            $stmt->execute(['user_id' => $userId, 'name' => $name, 'category' => $category,
                'amount' => number_format($amount, 2, '.', ''), 'type' => $type, 'date' => $date . ' 00:00:00']);
            Security::jsonResponse(true, 'Transaction saved.', ['id' => (int)$pdo->lastInsertId()], 201);
        }

        $id = (int)($input['id'] ?? 0);
        if ($id <= 0) {
            Security::jsonResponse(false, 'Transaction not found.', [], 404);
        }
        $stmt = $pdo->prepare("UPDATE transactions SET transaction_name = :name, category = :category,
            amount = :amount, transaction_type = :type, transaction_date = :date
            WHERE id = :id AND user_id = :user_id");
        $stmt->execute(['name' => $name, 'category' => $category, 'amount' => number_format($amount, 2, '.', ''),
            'type' => $type, 'date' => $date . ' 00:00:00', 'id' => $id, 'user_id' => $userId]);
        $check = $pdo->prepare('SELECT id FROM transactions WHERE id = :id AND user_id = :user_id');
        $check->execute(['id' => $id, 'user_id' => $userId]);
        if (!$check->fetch()) {
            Security::jsonResponse(false, 'Transaction not found.', [], 404);
        }
        Security::jsonResponse(true, 'Transaction updated.');
    }

    if ($action === 'delete_transaction') {
        $id = (int)($input['id'] ?? 0);
        $stmt = $pdo->prepare('DELETE FROM transactions WHERE id = :id AND user_id = :user_id');
        $stmt->execute(['id' => $id, 'user_id' => $userId]);
        if ($stmt->rowCount() === 0) {
            Security::jsonResponse(false, 'Transaction not found.', [], 404);
        }
        Security::jsonResponse(true, 'Transaction deleted.');
    }
}

$month = requestString($_GET, 'month');
if (!preg_match('/^\d{4}-\d{2}$/', $month)) {
    $month = date('Y-m');
}
$monthStart = $month . '-01';
$nextMonth = date('Y-m-d', strtotime($monthStart . ' +1 month'));

$totals = $pdo->prepare("SELECT
    COALESCE(SUM(CASE WHEN transaction_type = 'income' THEN amount ELSE 0 END), 0) AS total_income,
    COALESCE(SUM(CASE WHEN transaction_type = 'expense' THEN amount ELSE 0 END), 0) AS total_expense
    FROM transactions WHERE user_id = :user_id");
$totals->execute(['user_id' => $userId]);
$totalRow = $totals->fetch() ?: ['total_income' => 0, 'total_expense' => 0];

$monthlyTotals = $pdo->prepare("SELECT
    COALESCE(SUM(CASE WHEN transaction_type = 'income' THEN amount ELSE 0 END), 0) AS total_income,
    COALESCE(SUM(CASE WHEN transaction_type = 'expense' THEN amount ELSE 0 END), 0) AS total_expense
    FROM transactions WHERE user_id = :user_id AND transaction_date >= :start_date AND transaction_date < :next_date");
$monthlyTotals->execute(['user_id' => $userId, 'start_date' => $monthStart, 'next_date' => $nextMonth]);
$monthlyRow = $monthlyTotals->fetch() ?: ['total_income' => 0, 'total_expense' => 0];

$breakdown = $pdo->prepare("SELECT category, COALESCE(SUM(amount), 0) AS amount
    FROM transactions WHERE user_id = :user_id AND transaction_type = 'expense'
    AND transaction_date >= :start_date AND transaction_date < :next_date
    GROUP BY category ORDER BY amount DESC");
$breakdown->execute(['user_id' => $userId, 'start_date' => $monthStart, 'next_date' => $nextMonth]);

$recent = $pdo->prepare("SELECT id, transaction_name, category, amount, transaction_type,
    DATE_FORMAT(transaction_date, '%Y-%m-%d') AS transaction_date, payment_method, note
    FROM transactions WHERE user_id = :user_id ORDER BY transaction_date DESC, id DESC LIMIT 50");
$recent->execute(['user_id' => $userId]);

$toNumber = static fn($value): float => (float)$value;
$income = $toNumber($totalRow['total_income']);
$expense = $toNumber($totalRow['total_expense']);
$monthlyIncome = $toNumber($monthlyRow['total_income']);
$monthlyExpense = $toNumber($monthlyRow['total_expense']);

Security::jsonResponse(true, 'Dashboard data loaded.', [
    'user' => ['id' => $user['id'], 'full_name' => $user['full_name'], 'email' => $user['email']],
    'balance' => [
        'total_available' => $income - $expense,
        'total_income' => $income,
        'total_expense' => $expense,
        'status' => 'Active'
    ],
    'recent_transactions' => $recent->fetchAll(),
    'monthly_summary' => [
        'month' => $month,
        'total_income' => $monthlyIncome,
        'total_expense' => $monthlyExpense,
        'balance' => $monthlyIncome - $monthlyExpense,
        'expense_breakdown' => $breakdown->fetchAll()
    ]
]);
