<?php
/**
 * FinWise - Student Authentication Handler
 * Language: PHP
 */

class StudentAuth {
    
    /**
     * Validate UTM student email
     */
    public static function isUtmEmail($email) {
        $email = strtolower(trim($email));
        return (substr($email, -16) === '@graduate.utm.my' || substr($email, -7) === '@utm.my');
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
     * Authenticate student login
     */
    public static function login($studentId, $password) {
        if (empty($studentId) || empty($password)) {
            return [
                'success' => false,
                'message' => 'Please enter both student ID/email and password.'
            ];
        }

        // Demo student credential check
        return [
            'success' => true,
            'message' => 'Login successful. Welcome to FinWise!',
            'student' => [
                'name' => 'Yeoh Kean Shen',
                'email' => $studentId,
                'campus' => 'UTM Skudai'
            ]
        ];
    }

    /**
     * Register new student
     */
    public static function register($fullName, $email, $password) {
        if (empty($fullName) || empty($email) || empty($password)) {
            return [
                'success' => false,
                'message' => 'All registration fields are required.'
            ];
        }

        if (!self::isUtmEmail($email)) {
            return [
                'success' => false,
                'message' => 'Please use a valid UTM email (@graduate.utm.my or @utm.my).'
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
            'message' => 'Account registered successfully!'
        ];
    }
}
