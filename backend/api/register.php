<?php
/**
 * FinWise API - User Registration
 * POST /backend/api/register.php
 */

declare(strict_types=1);

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../includes/security.php';
require_once __DIR__ . '/../includes/validation.php';
require_once __DIR__ . '/../includes/otp_service.php';
require_once __DIR__ . '/../includes/email_service.php';

use FinWise\Config\Database;
use FinWise\Includes\Security;
use FinWise\Includes\Validation;
use FinWise\Includes\OtpService;
use FinWise\Includes\EmailService;

Security::sendHeaders();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    Security::jsonResponse(false, 'Method not allowed. Use POST.', [], 405);
}

$input = Security::getJsonInput();

$fullName        = trim((string)($input['full_name'] ?? ''));
$email           = strtolower(trim((string)($input['email'] ?? '')));
$matricId        = trim((string)($input['matric_id'] ?? ''));
$password        = (string)($input['password'] ?? '');
$confirmPassword = (string)($input['confirm_password'] ?? '');

// 1. Validation checks
if (!Validation::validateFullName($fullName)) {
    Security::jsonResponse(false, 'Please enter your full name.', [], 422);
}

if (!Validation::validateEmail($email)) {
    Security::jsonResponse(false, 'Invalid email address.', [], 422);
}

if ($password !== $confirmPassword) {
    Security::jsonResponse(false, 'Passwords do not match.', [], 422);
}

if (!Validation::validatePassword($password)) {
    Security::jsonResponse(false, 'Password must be at least 8 characters and include uppercase, lowercase, and a number.', [], 422);
}

// 2. Duplicate email check
$pdo = Database::getConnection();
$checkStmt = $pdo->prepare("SELECT id, email_verified FROM users WHERE email = :email LIMIT 1");
$checkStmt->execute(['email' => $email]);
$existingUser = $checkStmt->fetch();

if ($existingUser) {
    if ((int)$existingUser['email_verified'] === 1) {
        Security::jsonResponse(false, 'Email already registered.', [], 409);
    } else {
        // If registered before but unverified, update name & password and resend OTP
        $passwordHash = Security::hashPassword($password);
        $updateStmt = $pdo->prepare("
            UPDATE users 
            SET full_name = :full_name, matric_id = :matric_id, password_hash = :hash 
            WHERE id = :id
        ");
        $updateStmt->execute([
            'full_name' => $fullName,
            'matric_id' => !empty($matricId) ? $matricId : null,
            'hash'      => $passwordHash,
            'id'        => $existingUser['id']
        ]);
        $userId = (int)$existingUser['id'];
    }
} else {
    // 3. Insert new user with email_verified = 0
    try {
        $passwordHash = Security::hashPassword($password);
        $insertStmt = $pdo->prepare("
            INSERT INTO users (full_name, email, matric_id, password_hash, email_verified) 
            VALUES (:full_name, :email, :matric_id, :password_hash, 0)
        ");
        $insertStmt->execute([
            'full_name'     => $fullName,
            'email'         => $email,
            'matric_id'     => !empty($matricId) ? $matricId : null,
            'password_hash' => $passwordHash
        ]);
        $userId = (int)$pdo->lastInsertId();
    } catch (\PDOException $e) {
        Security::jsonResponse(false, 'Registration failed. Please try again.', [], 500);
    }
}

// 4. Generate 6-digit OTP
$otpResult = OtpService::createOtp($userId, 'registration');
if (!$otpResult['success']) {
    Security::jsonResponse(false, $otpResult['message'], [
        'user_id'           => $userId,
        'email'             => $email,
        'seconds_remaining' => $otpResult['seconds_remaining'] ?? 60
    ], 429);
}

// 5. Send OTP Email
$emailResult = EmailService::sendVerificationOtp($email, $fullName, $otpResult['otp_code']);
if (!$emailResult['success']) {
    Security::jsonResponse(false, 'Could not send the verification email. Please try again after the resend countdown.', [
        'user_id'           => $userId,
        'email'             => $email,
        'seconds_remaining' => OtpService::getResendSecondsRemaining($userId, 'registration'),
        'verification_pending' => true
    ], 502);
}

Security::jsonResponse(true, 'Registration successful. A 6-digit verification code has been sent to your email.', [
    'user_id'           => $userId,
    'email'             => $email,
    'full_name'         => $fullName,
    'seconds_remaining' => OtpService::getResendSecondsRemaining($userId, 'registration'),
    'email_sent'        => $emailResult['success']
], 201);
