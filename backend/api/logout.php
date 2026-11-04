<?php
/**
 * FinWise API - User Logout
 * POST /backend/api/logout.php
 */

declare(strict_types=1);

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../includes/security.php';
require_once __DIR__ . '/../includes/authentication.php';

use FinWise\Includes\Security;
use FinWise\Includes\Authentication;

Security::sendHeaders();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    Security::jsonResponse(false, 'Method not allowed. Use POST.', [], 405);
}

$user = Authentication::authenticateRequest();
Authentication::revokeSession((int)$user['id']);

Security::jsonResponse(true, 'Logged out successfully.', [], 200);

