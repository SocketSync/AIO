<?php
/**
 * FinWise API - User Login
 * POST /backend/api/login.php
 */

declare(strict_types=1);

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../includes/security.php';
require_once __DIR__ . '/../includes/validation.php';
require_once __DIR__ . '/../includes/otp_service.php';
require_once __DIR__ . '/../includes/authentication.php';

use FinWise\Config\Database;
use FinWise\Includes\Security;
use FinWise\Includes\Validation;
use FinWise\Includes\Authentication;

Security::sendHeaders();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    Security::jsonResponse(false, 'Method not allowed. Use POST.', [], 405);
}

$input = Security::getJsonInput();

$identifier = trim((string)($input['email'] ?? ''));
$password   = (string)($input['password'] ?? '');

if (empty($identifier)) {
    Security::jsonResponse(false, 'Invalid email address.', [], 422);
}

if (!Validation::validateEmail($identifier)) {
    Security::jsonResponse(false, 'Invalid email address.', [], 422);
}

if (empty($password)) {
    Security::jsonResponse(false, 'Incorrect email or password.', [], 401);
}

$pdo = Database::getConnection();

// Support login via either email or matric_id
$stmt = $pdo->prepare("
    SELECT id, full_name, email, matric_id, password_hash, email_verified 
    FROM users 
    WHERE email = :email
    LIMIT 1
");
$stmt->execute(['email' => strtolower($identifier)]);
$user = $stmt->fetch();

if (!$user) {
    Security::jsonResponse(false, 'Incorrect email or password.', [], 401);
}

// Check password
if (!Security::verifyPassword($password, $user['password_hash'])) {
    Security::jsonResponse(false, 'Incorrect email or password.', [], 401);
}

// Check if email is verified
if ((int)$user['email_verified'] !== 1) {
    Security::jsonResponse(false, 'Please verify your email before logging in.', [
        'user_id'        => (int)$user['id'],
        'email'          => $user['email'],
        'full_name'      => $user['full_name'],
        'email_verified' => false,
        'seconds_remaining' => \FinWise\Includes\OtpService::getResendSecondsRemaining((int)$user['id'], 'registration')
    ], 403);
}

// Issue session token
$session = Authentication::createSession((int)$user['id']);

Security::jsonResponse(true, 'Login successful. Welcome back!', [
    'user' => [
        'id'             => (int)$user['id'],
        'full_name'      => $user['full_name'],
        'email'          => $user['email'],
        'matric_id'      => $user['matric_id'],
        'email_verified' => true
    ],
    'token'      => $session['token'],
    'expires_at' => $session['expires_at']
], 200);
