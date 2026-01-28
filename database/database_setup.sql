

CREATE DATABASE momo_db;

USE momo_db;

-- 1. Users
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'unique id for each user',
    name VARCHAR(150) NOT NULL COMMENT 'the name of the user',
    phone_number VARCHAR(15) UNIQUE NOT NULL COMMENT 'unique phone handle',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation time',
    entity_type ENUM('SELF','INDIVIDUAL','MERCHANT','AGENT') DEFAULT 'INDIVIDUAL'
        COMMENT 'Type of user: Self, Person, Business, or Agent',
    INDEX idx_phone_number (phone_number)
); 

-- 2. Categories (referenced by transactions)
CREATE TABLE IF NOT EXISTS transaction_categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) UNIQUE NOT NULL COMMENT 'e.g., P2P, MERCHANT, BILLS'
);


-- 3. Transactions
CREATE TABLE IF NOT EXISTS transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Unique transaction id',
    external_ref_id VARCHAR(50) UNIQUE NOT NULL COMMENT 'Unique MoMo Transaction ID',
    transaction_date DATETIME NOT NULL COMMENT 'Date extracted from SMS',
    amount DECIMAL(15,2) NOT NULL COMMENT 'Transaction amount in RWF',
    fees DECIMAL(10,2) DEFAULT 0.00 COMMENT 'Service fees charged',
    category_id INT NULL COMMENT 'transaction category',
    status VARCHAR(50) NOT NULL DEFAULT 'SUCCESS',
    raw_message TEXT COMMENT 'original sms message',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'creation time',
    INDEX idx_category_id (category_id),
    FOREIGN KEY (category_id) REFERENCES transaction_categories(category_id)
);


-- 4. User to Transaction link (role per transaction)
CREATE TABLE IF NOT EXISTS user_transactions (
    user_transaction_id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Primary key for the user_transactions table',
    transaction_id INT NOT NULL COMMENT 'linked transaction',
    user_id INT NOT NULL COMMENT 'linked user',
    role ENUM('SENDER','RECEIVER') NOT NULL COMMENT 'Role: SENDER or RECEIVER',
    balance_after DECIMAL(15,2) COMMENT 'Balance snapshot after event',
    INDEX idx_ut_transaction (transaction_id),
    INDEX idx_ut_user (user_id),
    FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- 5. System logs for tracking processing steps
CREATE TABLE IF NOT EXISTS system_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    transaction_id INT NULL COMMENT 'Links log to a specific transaction event',
    log_level ENUM('INFO','WARNING','ERROR') DEFAULT 'INFO' COMMENT 'Severity of the log entry',
    status VARCHAR(50) DEFAULT 'PROCESSING' COMMENT 'Current state of the transaction',
    message TEXT COMMENT 'Detailed system message or error trace',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id) ON DELETE SET NULL,
    INDEX idx_log_level (log_level),
    INDEX idx_log_time (created_at)
);


-- 4. Adding sample categories
INSERT INTO transaction_categories (category_id, category_name) VALUES 
(1, 'P2P_RECEIVE'), (2, 'P2P_SEND'), (3, 'MERCHANT_PAY'), (4, 'WITHDRAWAL'), (5, 'BILL_PAY');

-- 5. Adding sample users
INSERT INTO users (user_id, name, phone_number, entity_type) VALUES 
(1, 'My Device', '0788000000', 'SELF'),
(2, 'Jane Smith', '0788123013', 'INDIVIDUAL'),
(3, 'Samuel Carter', '250791666666', 'INDIVIDUAL'),
(4, 'Agent Sophia', '250790777777', 'AGENT'),
(5, 'Airtime', 'MTN_AIRTIME', 'MERCHANT'),
(6, 'Robert Brown', '0788999999', 'INDIVIDUAL');

-- 6. Adding sample user_transactions
INSERT INTO transactions (transaction_id, external_ref_id, transaction_date, amount, fees, category_id, raw_message) VALUES
(1, '76662021700', '2024-05-10 16:30:51', 2000.00, 0.00, 1, 'Imported from XML: Received 2000'),
(2, '51732411227', '2024-05-10 21:32:32', 600.00, 0.00, 2, 'Imported from XML: Payment to Samuel'),
(3, '14098463509', '2024-05-26 02:10:27', 20000.00, 350.00, 4, 'Imported from XML: Agent Withdrawal'),
(4, '13913173274', '2024-05-12 11:41:28', 2000.00, 0.00, 5, 'Imported from XML: Airtime'),
(5, '26614842768', '2024-05-12 17:58:15', 1000.00, 0.00, 2, 'Imported from XML: Payment to Robert');

-- 7. Adding sample user roles in transactions
INSERT IGNORE INTO user_transactions (transaction_id, user_id, role, balance_after) VALUES
(1, 2, 'SENDER', NULL),
(1, 1, 'RECEIVER', 2000.00),
(2, 1, 'SENDER', 400.00),
(2, 3, 'RECEIVER', NULL),
(3, 1, 'SENDER', 6400.00),
(3, 4, 'RECEIVER', NULL),
(4, 1, 'SENDER', 25280.00),
(4, 5, 'RECEIVER', NULL),
(5, 1, 'SENDER', 9880.00),
(5, 6, 'RECEIVER', NULL);

-- 8. Adding sample system logs
INSERT INTO system_logs (transaction_id, log_level, status, message) VALUES
(1, 'INFO', 'COMPLETED', 'Parsed incoming P2P from XML batch.'),
(2, 'INFO', 'COMPLETED', 'Verified outgoing payment to Samuel.'),
(3, 'INFO', 'COMPLETED', 'Agent withdrawal verified successfully.'),
(4, 'INFO', 'COMPLETED', 'Airtime token generated.'),
(5, 'INFO', 'COMPLETED', 'Payment to Robert confirmed.');


#CRUD operations

-- Create operations
-- 1: Add two new users (one sender, one receiver)
INSERT INTO users (name, phone_number, entity_type) VALUES 
('David Miller', '0788111222', 'INDIVIDUAL'), -- ID 7
('Sarah Jones', '0788333444', 'INDIVIDUAL');  -- ID 8

-- Step 2: Create the main Transaction record
INSERT INTO transactions (external_ref_id, transaction_date, amount, fees, category_id, raw_message) 
VALUES ('TRX999888777', '2025-01-20 09:00:00', 15000.00, 150.00, 2, 'Manual P2P Test David to Sarah');

-- Step 3: Link users to the transaction in the user_transactions table
-- Assuming the transaction_id generated is 6
INSERT INTO user_transactions (transaction_id, user_id, role, balance_after) VALUES 
(6, 7, 'SENDER', 5000.00),  -- David sent money
(6, 8, 'RECEIVER', 15000.00); -- Sarah received money

-- Read operation
-- Query to retrieve all transactions with sender and receiver names
SELECT 
    t.transaction_id,
    sender.name AS Sent_By,
    receiver.name AS Received_By,
    t.amount,
    t.transaction_date
FROM transactions t
JOIN user_transactions ut1 ON t.transaction_id = ut1.transaction_id AND ut1.role = 'SENDER'
JOIN users sender ON ut1.user_id = sender.user_id
JOIN user_transactions ut2 ON t.transaction_id = ut2.transaction_id AND ut2.role = 'RECEIVER'
JOIN users receiver ON ut2.user_id = receiver.user_id;

-- Update operation
-- Promoting Jane Smith to an Agent status
UPDATE users SET entity_type = 'AGENT' WHERE name = 'Jane Smith';

-- Delete operations
-- 1. Remove the link between the test users and the transaction
DELETE FROM user_transactions WHERE transaction_id = 6;

-- 2. Remove the transaction itself
DELETE FROM transactions WHERE transaction_id = 6;

-- 3. Remove the test users
DELETE FROM users WHERE user_id IN (7, 8);