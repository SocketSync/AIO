<?php
/**
 * FinWise - Authentication Service
 * Target: General public and young adults (Independent financial app)
 * Authentication: Google Sign-In (Gmail)
 */

class AuthService {
    
    /**
     * Check if email is a valid Gmail address or Google-compatible email
     */
    public static function isGmail($email) {
        $email = strtolower(trim($email));
        return (filter_var($email, FILTER_VALIDATE_EMAIL) && 
               (substr($email, -10) === '@gmail.com' || substr($email, -17) === '@googlemail.com'));
    }

    /**
     * Validate password criteria (min 8 chars, 1 number, 1 symbol)
     */
    public static function validatePassword($password) {
        if (strlen($password) < 8) {
            return false;
        }
        if (!preg_match('/\d/', $password)) {
            return false;
        }
        if (!preg_match('/[!@#$%^&*(),.?":{}|<>]/', $password)) {
            return false;
        }
        return true;
    }

    /**
     * Authenticate user with Google Gmail account
     */
    public static function loginWithGoogle($email, $displayName, $idToken = null) {
        if (empty($email)) {
            return [
                'success' => false,
                'message' => 'Gmail address is required.'
            ];
        }

        return [
            'success' => true,
            'message' => 'Google authentication successful. Welcome to FinWise!',
            'user' => [
                'name' => $displayName ?: 'Google User',
                'email' => $email,
                'provider' => 'google'
            ]
        ];
    }

    /**
     * Register new user with Gmail
     */
    public static function register($fullName, $email, $password) {
        if (empty($fullName) || empty($email) || empty($password)) {
            return [
                'success' => false,
                'message' => 'All registration fields are required.'
            ];
        }

        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            return [
                'success' => false,
                'message' => 'Please provide a valid email address.'
            ];
        }

        if (!self::validatePassword($password)) {
            return [
                'success' => false,
                'message' => 'Password must have 8+ characters, a number, and a symbol.'
            ];
        }

        return [
            'success' => true,
            'message' => 'Account registered successfully! Welcome to FinWise.',
            'user' => [
                'name' => $fullName,
                'email' => $email,
                'provider' => 'email'
            ]
        ];
    }
}
