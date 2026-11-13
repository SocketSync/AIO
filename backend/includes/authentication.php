<?php
/**
 * FinWise Authentication Service
 */

declare(strict_types=1);

namespace FinWise\Includes;

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/security.php';

use FinWise\Config\Database;
use PDO;

class Authentication {
    /**
     * Find user by email
     */
    public static function findUserByEmail(string $email): ?array {
        $pdo = Database::getConnection();
        $stmt = $pdo->prepare("SELECT * FROM users WHERE email = :email LIMIT 1");
        $stmt->execute(['email' => strtolower(trim($email))]);
        $user = $stmt->fetch();
        return $user ?: null;
    }

    /**
     * Find user by ID
     */
    public static function findUserById(int $id): ?array {
        $pdo = Database::getConnection();
        $stmt = $pdo->prepare("SELECT id, full_name, email, phone, occupation, avatar_url, currency, monthly_budget, email_verified, created_at FROM users WHERE id = :id LIMIT 1");
        $stmt->execute(['id' => $id]);
        $user = $stmt->fetch();
        return $user ?: null;
    }

    /**
     * Authenticate token from request header
     */
    public static function authenticateRequest(): array {
        $token = Security::getBearerToken();
        if (!$token) {
            Security::jsonResponse(false, 'Unauthorized. Authentication token is missing.', [], 401);
        }

        $pdo = Database::getConnection();
        $stmt = $pdo->prepare("
            SELECT id, full_name, email, phone, occupation, avatar_url, currency, monthly_budget, email_verified, token_expires_at 
            FROM users 
            WHERE auth_token = :token LIMIT 1
        ");
        $stmt->execute(['token' => $token]);
        $user = $stmt->fetch();

        if (!$user) {
            Security::jsonResponse(false, 'Invalid session token. Please log in again.', [], 401);
        }

        if ($user['token_expires_at'] && strtotime($user['token_expires_at']) < time()) {
            Security::jsonResponse(false, 'Session expired. Please log in again.', [], 401);
        }

        return $user;
    }

    /**
     * Issue new session token
     */
    public static function createSession(int $userId): array {
        $token = Security::generateAuthToken();
        $expiresAt = date('Y-m-d H:i:s', time() + (30 * 86400)); // 30 days session

        $pdo = Database::getConnection();
        $stmt = $pdo->prepare("
            UPDATE users 
            SET auth_token = :token, token_expires_at = :expires_at 
            WHERE id = :id
        ");
        $stmt->execute([
            'token'      => $token,
            'expires_at' => $expiresAt,
            'id'         => $userId
        ]);

        return [
            'token'      => $token,
            'expires_at' => $expiresAt
        ];
    }

    /**
     * Invalidate session token
     */
    public static function revokeSession(int $userId): void {
        $pdo = Database::getConnection();
        $stmt = $pdo->prepare("UPDATE users SET auth_token = NULL, token_expires_at = NULL WHERE id = :id");
        $stmt->execute(['id' => $userId]);
    }
}

