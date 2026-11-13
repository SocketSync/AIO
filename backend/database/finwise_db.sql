-- ==============================================================
-- FinWise Financial Management Database Schema
-- Modern Personal Finance & Intelligent Budgeting Platform
-- Database: finwise_db (MySQL / MariaDB)
-- ==============================================================

CREATE DATABASE IF NOT EXISTS `finwise_db` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `finwise_db`;

-- --------------------------------------------------------------
-- Table 1: users
-- Stores registered member account and profile information
-- --------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `users` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `full_name` VARCHAR(150) NOT NULL,
    `email` VARCHAR(191) NOT NULL UNIQUE,
    `phone` VARCHAR(30) DEFAULT NULL,
    `occupation` VARCHAR(100) DEFAULT NULL,
    `avatar_url` TEXT DEFAULT NULL,
    `currency` VARCHAR(10) NOT NULL DEFAULT 'RM',
    `monthly_budget` DECIMAL(12, 2) NOT NULL DEFAULT 2500.00,
    `password_hash` VARCHAR(255) NOT NULL,
    `email_verified` TINYINT(1) NOT NULL DEFAULT 1,
    `auth_token` VARCHAR(255) DEFAULT NULL,
    `token_expires_at` DATETIME DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_users_email` (`email`),
    INDEX `idx_users_token` (`auth_token`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------------
-- Table 2: categories
-- Standard FinWise transaction categories
-- --------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `categories` (
    `id` VARCHAR(50) PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL,
    `icon_name` VARCHAR(50) NOT NULL,
    `color_hex` VARCHAR(10) NOT NULL,
    `type` ENUM('income', 'expense') NOT NULL DEFAULT 'expense',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `categories` (`id`, `name`, `icon_name`, `color_hex`, `type`) VALUES
    ('food_dining', 'Food & Dining', 'restaurant', '#FF9800', 'expense'),
    ('transportation', 'Transportation', 'directions_car', '#2196F3', 'expense'),
    ('groceries', 'Groceries', 'shopping_cart', '#4CAF50', 'expense'),
    ('shopping', 'Shopping', 'shopping_bag', '#9C27B0', 'expense'),
    ('entertainment', 'Entertainment', 'sports_esports', '#E91E63', 'expense'),
    ('bills_utilities', 'Bills & Utilities', 'receipt_long', '#F44336', 'expense'),
    ('health_wellness', 'Health & Wellness', 'medical_services', '#009688', 'expense'),
    ('education', 'Education & Self-Care', 'school', '#3F51B5', 'expense'),
    ('salary', 'Salary / Employment', 'payments', '#006C49', 'income'),
    ('freelance', 'Freelance & Side Gig', 'laptop_mac', '#00BCD4', 'income'),
    ('investments', 'Investments & Returns', 'trending_up', '#673AB7', 'income'),
    ('other', 'General / Other', 'category', '#607D8B', 'expense')
ON DUPLICATE KEY UPDATE `name`=VALUES(`name`), `color_hex`=VALUES(`color_hex`);

-- --------------------------------------------------------------
-- Table 3: email_verifications
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
-- Table 4: transactions
-- Stores financial income and expense transactions
-- --------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `transactions` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT UNSIGNED NOT NULL,
    `transaction_name` VARCHAR(200) NOT NULL,
    `category` VARCHAR(100) NOT NULL,
    `category_id` VARCHAR(50) DEFAULT 'other',
    `amount` DECIMAL(12, 2) NOT NULL,
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
-- Table 5: budgets
-- Monthly spending budget targets per category
-- --------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `budgets` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT UNSIGNED NOT NULL,
    `category` VARCHAR(100) NOT NULL,
    `budget_limit` DECIMAL(12, 2) NOT NULL,
    `month_year` CHAR(7) NOT NULL, -- Format: YYYY-MM
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_budgets_user_id` FOREIGN KEY (`user_id`) 
        REFERENCES `users` (`id`) ON DELETE CASCADE,
    UNIQUE KEY `uk_user_cat_month` (`user_id`, `category`, `month_year`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------------
-- Table 6: savings_goals
-- Personal savings targets (Emergency fund, Investment, etc.)
-- --------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `savings_goals` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT UNSIGNED NOT NULL,
    `title` VARCHAR(150) NOT NULL,
    `target_amount` DECIMAL(12, 2) NOT NULL,
    `current_amount` DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    `target_date` DATE NOT NULL,
    `status` ENUM('active', 'achieved', 'cancelled') NOT NULL DEFAULT 'active',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_savings_user_id` FOREIGN KEY (`user_id`) 
        REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==============================================================
-- Seed Clean Demo Account for Public Use
-- Password: FinWise2026!
-- SHA-256: 989a2c9493e8051c86a809ae60c025b6fff7a79de475aa91ebac2e2b562fb322
-- ==============================================================
INSERT INTO `users` (`id`, `full_name`, `email`, `phone`, `occupation`, `currency`, `monthly_budget`, `password_hash`, `email_verified`)
VALUES 
(
    1,
    'Demo Finwise',
    'demo@finwise-app.xyz',
    '',
    '',
    'RM',
    2500.00,
    '$2y$10$tZ2c69vK0f0PzHq/uQ622e.lE5e76z2p1yWffo/O59z1F5E1k6sC.',
    1
)
ON DUPLICATE KEY UPDATE 
    `full_name`=VALUES(`full_name`),
    `phone`=VALUES(`phone`),
    `occupation`=VALUES(`occupation`),
    `monthly_budget`=VALUES(`monthly_budget`);

-- Seed Initial Transactions for Demo Finwise (user_id = 1)
INSERT INTO `transactions` (`user_id`, `transaction_name`, `category`, `category_id`, `amount`, `transaction_type`, `transaction_date`, `payment_method`, `note`)
VALUES
(1, 'Monthly Tech Salary', 'Salary / Employment', 'salary', 4800.00, 'income', DATE_SUB(NOW(), INTERVAL 10 DAY), 'Bank Transfer', 'Monthly direct deposit paycheck'),
(1, 'Village Grocer Weekly', 'Groceries', 'groceries', 142.50, 'expense', DATE_SUB(NOW(), INTERVAL 1 DAY), 'Debit Card', 'Fresh vegetables, milk, eggs, pantry staples'),
(1, 'Coffee & Breakfast Bistro', 'Food & Dining', 'food_dining', 28.00, 'expense', DATE_SUB(NOW(), INTERVAL 4 HOUR), 'Cash / QR', 'Americano & sourdough toast'),
(1, 'Electricity & Water Bill', 'Bills & Utilities', 'bills_utilities', 115.80, 'expense', DATE_SUB(NOW(), INTERVAL 3 DAY), 'Online Banking', 'Monthly utility auto-debit'),
(1, 'Freelance Mobile UI Design', 'Freelance & Side Gig', 'freelance', 750.00, 'income', DATE_SUB(NOW(), INTERVAL 5 DAY), 'Direct', 'Completed wireframe milestones'),
(1, 'Touch N Go / Transit Reload', 'Transportation', 'transportation', 50.00, 'expense', DATE_SUB(NOW(), INTERVAL 6 DAY), 'E-Wallet', 'MRT transit weekly commute reload');
