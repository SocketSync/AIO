<?php
/**
 * FinWise API - Forgot / Reset Password
 * POST /backend/api/forgot_password.php
 */

declare(strict_types=1);

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../includes/security.php';
require_once __DIR__ . '/../includes/validation.php';
require_once __DIR__ . '/../includes/otp_service.php';
require_once __DIR__ . '/../includes/email_service.php';
require_once __DIR__ . '/../includes/authentication.php';

use FinWise\Config\Database;
use FinWise\Includes\Security;
use FinWise\Includes\Validation;
use FinWise\Includes\OtpService;
use FinWise\Includes\EmailService;
use FinWise\Includes\Authentication;

Security::sendHeaders();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    Security::jsonResponse(false, 'Method not allowed. Use POST.', [], 405);
}

$input = Security::getJsonInput();
$action = trim((string)($input['action'] ?? 'request_code'));
$email  = strtolower(trim((string)($input['email'] ?? '')));

if (!Validation::validateEmail($email)) {
    Security::jsonResponse(false, 'Invalid email address.', [], 422);
}

$user = Authentication::findUserByEmail($email);
if (!$user) {
    // For security against user enumeration, we can return success-like message or note
    Security::jsonResponse(false, 'No student account found with this email.', [], 404);
}

$userId = (int)$user['id'];

if ($action === 'request_code' || $action === 'resend_code') {
    $otpResult = OtpService::createOtp($userId, 'password_reset');
    if (!$otpResult['success']) {
        Security::jsonResponse(false, $otpResult['message'], [
            'seconds_remaining' => $otpResult['seconds_remaining'] ?? 60
        ], 429);
    }

    $emailResult = EmailService::sendPasswordResetOtp($email, $user['full_name'], $otpResult['otp_code']);
    if (!$emailResult['success']) {
        Security::jsonResponse(false, $emailResult['message'], [
            'email'             => $email,
            'seconds_remaining' => OtpService::getResendSecondsRemaining($userId, 'password_reset')
        ], 502);
    }

    Security::jsonResponse(true, 'Password reset code sent to your email. Enter it with your new password to reset your account.', [
        'email'             => $email,
        'seconds_remaining' => OtpService::getResendSecondsRemaining($userId, 'password_reset')
    ], 200);
}

if ($action === 'reset_password') {
    $otpCode         = trim((string)($input['otp'] ?? ''));
    $newPassword     = (string)($input['new_password'] ?? '');
    $confirmPassword = (string)($input['confirm_password'] ?? '');

    if (!Validation::validateOtp($otpCode)) {
        Security::jsonResponse(false, 'Invalid verification code. Please try again.', [], 422);
    }

    if ($newPassword !== $confirmPassword) {
        Security::jsonResponse(false, 'Passwords do not match.', [], 422);
    }

    if (!Validation::validatePassword($newPassword)) {
        Security::jsonResponse(false, 'Password must be at least 8 characters and include uppercase, lowercase, and a number.', [], 422);
    }

    $verifyResult = OtpService::verifyOtp($userId, $otpCode, 'password_reset');
    if (!$verifyResult['success']) {
        Security::jsonResponse(false, $verifyResult['message'], [], 400);
    }

    // Update password
    $pdo = Database::getConnection();
    $newHash = Security::hashPassword($newPassword);
    $stmt = $pdo->prepare("UPDATE users SET password_hash = :hash WHERE id = :id");
    $stmt->execute(['hash' => $newHash, 'id' => $userId]);

    // Revoke any existing tokens
    Authentication::revokeSession($userId);

    Security::jsonResponse(true, 'Password updated successfully. You can now log in with your new password.', [], 200);
}

Security::jsonResponse(false, 'Invalid action specified.', [], 400);
