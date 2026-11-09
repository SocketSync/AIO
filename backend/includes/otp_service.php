<?php
/**
 * FinWise OTP Service
 * Manages 6-digit OTP generation, bcrypt/sha256 hashing, 60-second throttling, and verification.
 */

declare(strict_types=1);

namespace FinWise\Includes;

require_once __DIR__ . '/../config/database.php';

use FinWise\Config\Database;
use PDO;

class OtpService {
    public const OTP_EXPIRY_MINUTES = 10;
    public const RESEND_RESTRICTION_SECONDS = 60;
    public const MAX_VERIFICATION_ATTEMPTS = 5;

    public static function getResendSecondsRemaining(int $userId, string $purpose = 'registration'): int {
        $pdo = Database::getConnection();
        $stmt = $pdo->prepare("
            SELECT last_sent_at
            FROM email_verifications
            WHERE user_id = :user_id AND purpose = :purpose AND verified_at IS NULL
            ORDER BY id DESC LIMIT 1
        ");
        $stmt->execute(['user_id' => $userId, 'purpose' => $purpose]);
        $record = $stmt->fetch();

        if (!$record) {
            return 0;
        }

        $elapsed = max(0, time() - strtotime($record['last_sent_at']));
        return max(0, self::RESEND_RESTRICTION_SECONDS - $elapsed);
    }

    /**
     * Generate and record a new OTP for a given user
     * Enforces the 60-second resend restriction on the backend.
     */
    public static function createOtp(int $userId, string $purpose = 'registration'): array {
        $pdo = Database::getConnection();

        // 1. Check existing active OTP for 60-second restriction
        $stmt = $pdo->prepare("
            SELECT id, last_sent_at, expires_at 
            FROM email_verifications 
            WHERE user_id = :user_id AND purpose = :purpose AND verified_at IS NULL 
            ORDER BY id DESC LIMIT 1
        ");
        $stmt->execute(['user_id' => $userId, 'purpose' => $purpose]);
        $existing = $stmt->fetch();

        if ($existing) {
            $lastSentTime = strtotime($existing['last_sent_at']);
            $elapsed = time() - $lastSentTime;
            if ($elapsed < self::RESEND_RESTRICTION_SECONDS) {
                $wait = self::RESEND_RESTRICTION_SECONDS - $elapsed;
                return [
                    'success' => false,
                    'error_type' => 'THROTTLED',
                    'message' => "Please wait {$wait} seconds before requesting a new code.",
                    'seconds_remaining' => $wait
                ];
            }
        }

        // 2. Generate random 6-digit code
        $otpCode = (string)random_int(100000, 999999);
        $otpHash = password_hash($otpCode, PASSWORD_BCRYPT);

        $now = date('Y-m-d H:i:s');
        $expiresAt = date('Y-m-d H:i:s', time() + (self::OTP_EXPIRY_MINUTES * 60));

        // Invalidate older unverified OTPs for this purpose
        $invalidateStmt = $pdo->prepare("
            DELETE FROM email_verifications 
            WHERE user_id = :user_id AND purpose = :purpose AND verified_at IS NULL
        ");
        $invalidateStmt->execute(['user_id' => $userId, 'purpose' => $purpose]);

        // Insert new record
        $insertStmt = $pdo->prepare("
            INSERT INTO email_verifications (user_id, otp_hash, purpose, attempts, last_sent_at, expires_at)
            VALUES (:user_id, :otp_hash, :purpose, 0, :last_sent_at, :expires_at)
        ");
        $insertStmt->execute([
            'user_id'      => $userId,
            'otp_hash'     => $otpHash,
            'purpose'      => $purpose,
            'last_sent_at' => $now,
            'expires_at'   => $expiresAt
        ]);

        return [
            'success'            => true,
            'otp_code'           => $otpCode, // Plaintext code to be sent via email
            'expires_at'         => $expiresAt,
            'seconds_remaining'  => self::RESEND_RESTRICTION_SECONDS
        ];
    }

    /**
     * Validate the submitted 6-digit OTP code
     */
    public static function verifyOtp(int $userId, string $submittedOtp, string $purpose = 'registration'): array {
        $pdo = Database::getConnection();

        $stmt = $pdo->prepare("
            SELECT id, otp_hash, attempts, expires_at 
            FROM email_verifications 
            WHERE user_id = :user_id AND purpose = :purpose AND verified_at IS NULL 
            ORDER BY id DESC LIMIT 1
        ");
        $stmt->execute(['user_id' => $userId, 'purpose' => $purpose]);
        $record = $stmt->fetch();

        if (!$record) {
            return [
                'success' => false,
                'message' => 'Please request a new verification code.'
            ];
        }

        // Check if attempts exceeded
        if ((int)$record['attempts'] >= self::MAX_VERIFICATION_ATTEMPTS) {
            return [
                'success' => false,
                'message' => 'Too many failed attempts. Please request a new verification code.'
            ];
        }

        // Check expiration
        if (strtotime($record['expires_at']) < time()) {
            return [
                'success' => false,
                'message' => 'Verification code has expired.'
            ];
        }

        // Increment attempt counter
        $incStmt = $pdo->prepare("UPDATE email_verifications SET attempts = attempts + 1 WHERE id = :id");
        $incStmt->execute(['id' => $record['id']]);

        // Verify hash
        if (!password_verify($submittedOtp, $record['otp_hash'])) {
            return [
                'success' => false,
                'message' => 'Invalid verification code. Please try again.'
            ];
        }

        // Mark as verified
        $now = date('Y-m-d H:i:s');
        $updateStmt = $pdo->prepare("UPDATE email_verifications SET verified_at = :now WHERE id = :id");
        $updateStmt->execute(['now' => $now, 'id' => $record['id']]);

        // Update user status
        if ($purpose === 'registration') {
            $userStmt = $pdo->prepare("UPDATE users SET email_verified = 1 WHERE id = :user_id");
            $userStmt->execute(['user_id' => $userId]);
        }

        return [
            'success' => true,
            'message' => 'Email verification successful.'
        ];
    }
}
