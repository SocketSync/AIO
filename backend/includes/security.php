<?php
/**
 * FinWise Security and Response Utilities
 */

declare(strict_types=1);

namespace FinWise\Includes;

class Security {
    /**
     * Send standard API headers (CORS, JSON, Security)
     */
    public static function sendHeaders(): void {
        header('Content-Type: application/json; charset=UTF-8');
        header('Access-Control-Allow-Origin: *');
        header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
        header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
        header('X-Content-Type-Options: nosniff');
        header('X-Frame-Options: DENY');
        header('X-XSS-Protection: 1; mode=block');

        if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
            http_response_code(204);
            exit;
        }
    }

    /**
     * Parse incoming JSON request body or POST array
     */
    public static function getJsonInput(): array {
        $raw = file_get_contents('php://input');
        if (!empty($raw)) {
            $decoded = json_decode($raw, true);
            if (is_array($decoded)) {
                return $decoded;
            }
        }
        return is_array($_POST) ? $_POST : [];
    }

    /**
     * Send structured JSON response and terminate execution
     */
    public static function jsonResponse(bool $success, string $message, array $data = [], int $httpCode = 200): void {
        http_response_code($httpCode);
        echo json_encode([
            'success'   => $success,
            'message'   => $message,
            'data'      => $data,
            'timestamp' => date('c')
        ], JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);
        exit;
    }

    /**
     * Hash user password securely
     */
    public static function hashPassword(string $password): string {
        return password_hash($password, PASSWORD_BCRYPT, ['cost' => 12]);
    }

    /**
     * Verify user password against stored bcrypt hash
     */
    public static function verifyPassword(string $password, string $hash): bool {
        return password_verify($password, $hash);
    }

    /**
     * Generate cryptographically secure random token (64 hex chars)
     */
    public static function generateAuthToken(): string {
        return bin2hex(random_bytes(32));
    }

    /**
     * Extract Bearer token from Authorization header
     */
    public static function getBearerToken(): ?string {
        $headers = function_exists('getallheaders') ? getallheaders() : [];
        $authHeader = $headers['Authorization'] ?? $headers['authorization'] ?? $_SERVER['HTTP_AUTHORIZATION'] ?? null;
        if ($authHeader && preg_match('/Bearer\s+(\S+)/i', $authHeader, $matches)) {
            return $matches[1];
        }
        return null;
    }
}

