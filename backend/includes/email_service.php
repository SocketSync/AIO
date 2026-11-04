<?php
/**
 * FinWise Email Service
 * Pure PHP SMTP Client implementation without third-party dependencies.
 * Sends multipart/HTML emails securely over SSL/TLS sockets.
 */

declare(strict_types=1);

namespace FinWise\Includes;

require_once __DIR__ . '/../config/smtp.php';

use FinWise\Config\SmtpConfig;
use Exception;

class EmailService {

    /**
     * Send email verification code using HTML template
     */
    public static function sendVerificationOtp(string $toEmail, string $userName, string $otpCode): array {
        return self::sendOtpEmail(
            $toEmail,
            $userName,
            $otpCode,
            'FinWise – Email Verification Code'
        );
    }

    public static function sendPasswordResetOtp(string $toEmail, string $userName, string $otpCode): array {
        return self::sendOtpEmail(
            $toEmail,
            $userName,
            $otpCode,
            'FinWise – Password Reset Code'
        );
    }

    private static function sendOtpEmail(string $toEmail, string $userName, string $otpCode, string $subject): array {
        $templatePath = __DIR__ . '/../templates/verification_email.html';
        if (!file_exists($templatePath)) {
            return [
                'success' => false,
                'message' => 'Email template file not found on server.'
            ];
        }

        $html = file_get_contents($templatePath);
        $html = str_replace(['{{USER_NAME}}', '{{OTP_CODE}}'], [htmlspecialchars($userName), htmlspecialchars($otpCode)], $html);

        return self::sendMail($toEmail, $userName, $subject, $html);
    }

    /**
     * Core SMTP Mailer via PHP stream sockets
     */
    public static function sendMail(string $toEmail, string $toName, string $subject, string $htmlBody): array {
        $config = SmtpConfig::getConfig();

        if (!empty($config['simulate'])) {
            return [
                'success' => false,
                'message' => 'Email simulation is enabled; no email was sent.'
            ];
        }

        if (
            empty($config['host'])
            || empty($config['username'])
            || empty($config['password'])
            || empty($config['from_email'])
        ) {
            return [
                'success' => false,
                'message' => 'SMTP is not configured. Set SMTP_USER, SMTP_PASS, and SMTP_FROM_EMAIL.'
            ];
        }

        $socket = null;
        try {
            $socket = self::connectSmtp($config);
            self::expectResponse($socket, ['220'], 'SMTP greeting');

            $smtpClientName = gethostname() ?: 'localhost';
            self::sendCommand($socket, "EHLO " . $smtpClientName);
            self::expectResponse($socket, ['250'], 'EHLO');

            if ($config['port'] !== 465 && $config['encryption'] === 'tls') {
                self::sendCommand($socket, "STARTTLS");
                self::expectResponse($socket, ['220'], 'STARTTLS');
                if (!stream_socket_enable_crypto($socket, true, STREAM_CRYPTO_METHOD_TLS_CLIENT)) {
                    throw new Exception("Failed to establish TLS encryption with SMTP server.");
                }
                self::sendCommand($socket, "EHLO " . $smtpClientName);
                self::expectResponse($socket, ['250'], 'EHLO after STARTTLS');
            }

            self::sendCommand($socket, "AUTH LOGIN");
            self::expectResponse($socket, ['334'], 'SMTP authentication');
            self::sendCommand($socket, base64_encode($config['username']));
            self::expectResponse($socket, ['334'], 'SMTP username');
            self::sendCommand($socket, base64_encode($config['password']));
            self::expectResponse($socket, ['235'], 'SMTP password');

            self::sendCommand($socket, "MAIL FROM:<" . $config['from_email'] . ">");
            self::expectResponse($socket, ['250'], 'MAIL FROM');

            self::sendCommand($socket, "RCPT TO:<" . $toEmail . ">");
            self::expectResponse($socket, ['250', '251'], 'RCPT TO');

            self::sendCommand($socket, "DATA");
            self::expectResponse($socket, ['354'], 'DATA');

            $safeFromName = str_replace(["\r", "\n"], '', $config['from_name']);
            $safeToName = str_replace(["\r", "\n"], '', $toName);
            $headers  = "From: " . $safeFromName . " <" . $config['from_email'] . ">\r\n";
            $headers .= "To: " . $safeToName . " <" . $toEmail . ">\r\n";
            $headers .= "Subject: =?UTF-8?B?" . base64_encode($subject) . "?=\r\n";
            $headers .= "MIME-Version: 1.0\r\n";
            $headers .= "Content-Type: text/html; charset=UTF-8\r\n";
            $headers .= "Content-Transfer-Encoding: base64\r\n";
            $headers .= "\r\n";

            $content = $headers . chunk_split(base64_encode($htmlBody)) . "\r\n.\r\n";
            fwrite($socket, $content);
            self::expectResponse($socket, ['250'], 'message delivery');

            self::sendCommand($socket, "QUIT");
            fclose($socket);

            return [
                'success' => true,
                'message' => 'Email dispatched successfully via SMTP.'
            ];
        } catch (Exception $e) {
            if (is_resource($socket)) {
                fclose($socket);
            }
            error_log('FinWise SMTP delivery failed: ' . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Email delivery failed. Check the SMTP server configuration and application logs.'
            ];
        }
    }

    private static function expectResponse($socket, array $expectedCodes, string $stage): void {
        $response = self::readMultiResponse($socket);
        $code = substr($response, 0, 3);
        if (!in_array($code, $expectedCodes, true)) {
            throw new Exception($stage . ' failed: ' . $response);
        }
    }

    private static function connectSmtp(array $config) {
        $host = $config['host'];
        if ($config['port'] === 465 || $config['encryption'] === 'ssl') {
            $host = 'ssl://' . $host;
        }

        $timeout = 15;
        $context = stream_context_create([
            'ssl' => [
                'verify_peer' => true,
                'verify_peer_name' => true
            ]
        ]);

        $socket = @stream_socket_client(
            $host . ':' . $config['port'],
            $errno,
            $errstr,
            $timeout,
            STREAM_CLIENT_CONNECT,
            $context
        );

        if (!$socket) {
            throw new Exception("Could not connect to SMTP server {$host}: {$errstr} ({$errno})");
        }

        stream_set_timeout($socket, $timeout);
        return $socket;
    }

    private static function sendCommand($socket, string $command): void {
        fwrite($socket, $command . "\r\n");
    }

    private static function readMultiResponse($socket): string {
        $response = '';
        while ($line = fgets($socket, 512)) {
            $response .= $line;
            if (preg_match('/^\d{3}\s/', $line)) {
                break;
            }
        }
        return trim($response);
    }
}
