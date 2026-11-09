<?php
/**
 * FinWise API - Resend OTP with strict 60-second server-side throttling
 * POST /backend/api/resend_otp.php
 */

declare(strict_types=1);

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../includes/security.php';
require_once __DIR__ . '/../includes/validation.php';
require_once __DIR__ . '/../includes/otp_service.php';
require_once __DIR__ . '/../includes/email_service.php';
require_once __DIR__ . '/../includes/authentication.php';

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

$email   = strtolower(trim((string)($input['email'] ?? '')));
$purpose = trim((string)($input['purpose'] ?? 'registration'));

if (!Validation::validateEmail($email)) {
    Security::jsonResponse(false, 'Invalid email address.', [], 422);
}

$user = Authentication::findUserByEmail($email);
if (!$user) {
    Security::jsonResponse(false, 'User account not found.', [], 404);
}

$userId = (int)$user['id'];

// Attempt to create new OTP - OtpService checks server-side timestamp
$otpResult = OtpService::createOtp($userId, $purpose);

if (!$otpResult['success']) {
    Security::jsonResponse(false, $otpResult['message'], [
        'seconds_remaining' => $otpResult['seconds_remaining'] ?? 60
    ], 429);
}

// Send email
$emailResult = EmailService::sendVerificationOtp($email, $user['full_name'], $otpResult['otp_code']);
if (!$emailResult['success']) {
    Security::jsonResponse(false, 'Could not send the verification email. Please try again after the resend countdown.', [
        'email'             => $email,
        'seconds_remaining' => OtpService::getResendSecondsRemaining($userId, $purpose),
        'email_sent'        => false
    ], 502);
}

Security::jsonResponse(true, 'A new verification code has been dispatched to your email.', [
    'email'             => $email,
    'seconds_remaining' => OtpService::getResendSecondsRemaining($userId, $purpose),
    'expires_at'        => $otpResult['expires_at'],
    'email_sent'        => $emailResult['success']
], 200);
