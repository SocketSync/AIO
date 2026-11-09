<?php
/**
 * FinWise API - Email OTP Verification
 * POST /backend/api/verify_email.php
 */

declare(strict_types=1);

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../includes/security.php';
require_once __DIR__ . '/../includes/validation.php';
require_once __DIR__ . '/../includes/otp_service.php';
require_once __DIR__ . '/../includes/authentication.php';

use FinWise\Includes\Security;
use FinWise\Includes\Validation;
use FinWise\Includes\OtpService;
use FinWise\Includes\Authentication;

Security::sendHeaders();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    Security::jsonResponse(false, 'Method not allowed. Use POST.', [], 405);
}

$input = Security::getJsonInput();

$email   = strtolower(trim((string)($input['email'] ?? '')));
$otpCode = trim((string)($input['otp'] ?? $input['code'] ?? ''));
$purpose = trim((string)($input['purpose'] ?? 'registration'));

if ($purpose !== 'registration') {
    Security::jsonResponse(false, 'Invalid verification request.', [], 422);
}

if (!Validation::validateEmail($email)) {
    Security::jsonResponse(false, 'Invalid email address.', [], 422);
}

if (!Validation::validateOtp($otpCode)) {
    Security::jsonResponse(false, 'Invalid verification code. Please try again.', [], 422);
}

$user = Authentication::findUserByEmail($email);
if (!$user) {
    Security::jsonResponse(false, 'User account not found.', [], 404);
}

$userId = (int)$user['id'];

// Verify OTP
$result = OtpService::verifyOtp($userId, $otpCode, $purpose);

if (!$result['success']) {
    Security::jsonResponse(false, $result['message'], [], 400);
}

// Issue session token for immediate seamless access
$session = Authentication::createSession($userId);

Security::jsonResponse(true, 'Email verification successful.', [
    'user' => [
        'id'             => $userId,
        'full_name'      => $user['full_name'],
        'email'          => $user['email'],
        'matric_id'      => $user['matric_id'],
        'email_verified' => true
    ],
    'token'      => $session['token'],
    'expires_at' => $session['expires_at']
], 200);
