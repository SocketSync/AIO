<?php
/**
 * FinWise SMTP Configuration
 * FinWise Financial Platform - Course: Application Development
 *
 * Configurable via environment variables or default local parameters.
 * Never commit production credentials directly to public repositories.
 */

declare(strict_types=1);

namespace FinWise\Config;

class SmtpConfig {
    public static function getConfig(): array {
        $username = getenv('SMTP_USER') ?: '';

        return [
            'host'       => getenv('SMTP_HOST') ?: 'smtp.gmail.com',
            'port'       => (int)(getenv('SMTP_PORT') ?: 587),
            'encryption' => getenv('SMTP_ENCRYPTION') ?: 'tls',
            'username'   => $username,
            'password'   => getenv('SMTP_PASS') ?: '',
            'from_email' => getenv('SMTP_FROM_EMAIL') ?: $username,
            'from_name'  => getenv('SMTP_FROM_NAME') ?: 'FinWise Campus Banking',
            'simulate'   => filter_var(getenv('SMTP_SIMULATE') ?: false, FILTER_VALIDATE_BOOLEAN)
        ];
    }
}
