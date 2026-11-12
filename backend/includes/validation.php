<?php
/**
 * FinWise Input Validation Utilities
 * Pure PHP 8+ validation rules
 */

declare(strict_types=1);

namespace FinWise\Includes;

class Validation {
    /**
     * Validate user's full name (at least 2 characters)
     */
    public static function validateFullName(?string $name): bool {
        if ($name === null) return false;
        $trimmed = trim($name);
        return mb_strlen($trimmed) >= 2 && mb_strlen($trimmed) <= 150;
    }

    /**
     * Validate student or standard email address
     */
    public static function validateEmail(?string $email): bool {
        if ($email === null) return false;
        $trimmed = trim($email);
        return filter_var($trimmed, FILTER_VALIDATE_EMAIL) !== false;
    }

    /**
     * Check if email is a FinWise user address
     */
    public static function isUtmEmail(string $email): bool {
        return (bool)preg_match('/@(graduate\.utm\.my|utm\.my)$/i', trim($email));
    }

    /**
     * Require at least 8 characters, including uppercase, lowercase, and a number.
     */
    public static function validatePassword(?string $password): bool {
        if ($password === null) return false;
        return strlen($password) >= 8
            && strlen($password) <= 128
            && preg_match('/[A-Z]/', $password) === 1
            && preg_match('/[a-z]/', $password) === 1
            && preg_match('/[0-9]/', $password) === 1;
    }

    /**
     * Validate 6-digit OTP code format
     */
    public static function validateOtp(?string $otp): bool {
        if ($otp === null) return false;
        return (bool)preg_match('/^\d{6}$/', trim($otp));
    }
}
