-- ==============================================================
-- FinWise Financial Management Database Schema
-- Universiti Teknologi Malaysia (UTM) - Course: Application Development
-- Database: finwise_db
-- ==============================================================

CREATE DATABASE IF NOT EXISTS `finwise_db` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `finwise_db`;

-- --------------------------------------------------------------
-- Table 1: users
-- Stores registered student and user account information
-- --------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `users` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `full_name` VARCHAR(150) NOT NULL,
    `email` VARCHAR(191) NOT NULL UNIQUE,
    `matric_id` VARCHAR(50) DEFAULT NULL,
    `password_hash` VARCHAR(255) NOT NULL,
    `email_verified` TINYINT(1) NOT NULL DEFAULT 0,
    `auth_token` VARCHAR(255) DEFAULT NULL,
    `token_expires_at` DATETIME DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_users_email` (`email`),
    INDEX `idx_users_token` (`auth_token`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------------
-- Table 2: email_verifications
-- Stores secure OTP codes for email verification & password reset
-- --------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `email_verifications` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT UNSIGNED NOT NULL,
    `otp_hash` VARCHAR(255) NOT NULL,
    `purpose` ENUM('registration', 'password_reset') NOT NULL DEFAULT 'registration',
    `attempts` TINYINT UNSIGNED NOT NULL DEFAULT 0,
    `last_sent_at` DATETIME NOT NULL,
    `expires_at` DATETIME NOT NULL,
    `verified_at` DATETIME DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_verifications_user_id` FOREIGN KEY (`user_id`) 
        REFERENCES `users` (`id`) ON DELETE CASCADE,
    INDEX `idx_verif_user_purpose` (`user_id`, `purpose`),
    INDEX `idx_verif_expires` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------------
-- Table 3: transactions
-- Stores financial income and expense transactions
-- --------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `transactions` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT UNSIGNED NOT NULL,
    `transaction_name` VARCHAR(200) NOT NULL,
    `category` VARCHAR(100) NOT NULL,
    `amount` DECIMAL(10, 2) NOT NULL,
    `transaction_type` ENUM('income', 'expense') NOT NULL,
    `transaction_date` DATETIME NOT NULL,
    `payment_method` VARCHAR(50) DEFAULT 'Direct',
    `note` VARCHAR(255) DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_transactions_user_id` FOREIGN KEY (`user_id`) 
        REFERENCES `users` (`id`) ON DELETE CASCADE,
    INDEX `idx_trans_user_date` (`user_id`, `transaction_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------------
-- Table 4: budgets
-- Monthly spending budget targets per category
-- --------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `budgets` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT UNSIGNED NOT NULL,
    `category` VARCHAR(100) NOT NULL,
    `budget_limit` DECIMAL(10, 2) NOT NULL,
    `month_year` CHAR(7) NOT NULL, -- Format: YYYY-MM
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_budgets_user_id` FOREIGN KEY (`user_id`) 
        REFERENCES `users` (`id`) ON DELETE CASCADE,
    UNIQUE KEY `uk_user_cat_month` (`user_id`, `category`, `month_year`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------------
-- Table 5: savings_goals
-- University savings targets (Emergency fund, Semester fees, etc.)
-- --------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `savings_goals` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT UNSIGNED NOT NULL,
    `title` VARCHAR(150) NOT NULL,
    `target_amount` DECIMAL(10, 2) NOT NULL,
    `current_amount` DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    `target_date` DATE NOT NULL,
    `status` ENUM('active', 'achieved', 'cancelled') NOT NULL DEFAULT 'active',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_savings_user_id` FOREIGN KEY (`user_id`) 
        REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==============================================================
-- Seed Demo Data for Development & Testing
-- User: Yeoh Keng Wei (yeoh.k@graduate.utm.my)
-- Default Password: SecretStudentPass99 (pre-hashed with PASSWORD_BCRYPT)
-- ==============================================================
INSERT INTO `users` (`id`, `full_name`, `email`, `matric_id`, `password_hash`, `email_verified`)
VALUES (
    1,
    'Yeoh Keng Wei',
    'yeoh.k@graduate.utm.my',
    'A23CS0123',
    '$2y$10$tZ2c69vK0f0PzHq/uQ622e.lE5e76z2p1yWffo/O59z1F5E1k6sC.', -- SecretStudentPass99
    1
) ON DUPLICATE KEY UPDATE `id`=`id`;


