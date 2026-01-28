# Create database, Use database, remove the alters.
CREATE DATABASE momo_db;

USE momo_db;
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'unique id for each user',
    name VARCHAR(150) NOT NULL COMMENT 'the name of the user',
    phone_number VARCHAR(15) UNIQUE NOT NULL COMMENT 'unique phone handle',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation time',
    INDEX idx_phone_number (phone_number)
); 

CREATE TABLE IF NOT EXISTS transaction_categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) UNIQUE NOT NULL COMMENT 'e.g., P2P, MERCHANT, BILLS'
);

CREATE TABLE transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Unique transaction id',
    transaction_date DATETIME NOT NULL COMMENT 'Date extracted from SMS',
    amount DECIMAL(15,2) NOT NULL COMMENT 'Transaction amount in Rwandan francs',
    fees DECIMAL(10,2) DEFAULT 0.00 COMMENT 'Fees charged',
    category_id INT COMMENT 'transaction category',
    status VARCHAR(50) NOT NULL COMMENT 'transaction status',
    raw_message TEXT COMMENT 'original sms message',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'creation time',

    FOREIGN KEY (category_id) REFERENCES transaction_categories(category_id),
    INDEX idx_transaction_date (transaction_date)

);

CREATE TABLE user_transactions (
    user_transaction_id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Primary key for the user_transactions table',
    transaction_id INT NOT NULL COMMENT 'linked transaction',
    user_id INT NOT NULL COMMENT 'linked user',
    role ENUM('SENDER', 'RECEIVER') NOT NULL COMMENT 'role of the user in transaction',
    balance_after DECIMAL(15,2) COMMENt 'balance of the user after transaction',

    FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);


CREATE TABLE IF NOT EXISTS system_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    transaction_id INT COMMENT 'Links log to a specific transaction event',
    log_level ENUM('INFO', 'WARNING', 'ERROR') DEFAULT 'INFO' COMMENT 'Severity of the log entry',
    status VARCHAR(50) DEFAULT 'PROCESSING' COMMENT 'Current state of the transaction',
    message TEXT COMMENT 'Detailed system message or error trace',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id) ON DELETE SET NULL,
    INDEX idx_log_level (log_level),
    INDEX idx_log_time (created_at)
);


-- User roles in transactions and balances after each transaction
insert into user_transactions (transaction_id, user_id, role, balance_after) values
-- Transaction 1: Main User sends to Samuel Carter
(1, 1, 'SENDER', 28300.00), (1, 2, 'RECEIVER', NULL),
-- Transaction 2: Bank sends deposit to Main User
(2, 3, 'SENDER', NULL), (2, 1, 'RECEIVER', 40400.00),
-- Transaction 3: Main User pays Alex Doe
(3, 1, 'SENDER', 10880.00), (3, 4, 'RECEIVER', NULL),
-- Transaction 4: Main User withdraws via Agent Sophia
(4, 1, 'SENDER', 6400.00), (4, 5, 'RECEIVER', NULL),
-- Transaction 5: Linda Green sends to Main User
(5, 6, 'SENDER', NULL), (5, 1, 'RECEIVER', 14110.00),
-- Transaction 6: Failed payment (Balances are NULL as money did not move)
(6, 1, 'SENDER', NULL), (6, 7, 'RECEIVER', NULL);


-- Sample system logs for transactions
insert into system_logs (transaction_id, log_level, status, message) values
(1, 'INFO', 'COMPLETED', 'Transfer of 10000 RWF to Samuel Carter.'),
(2, 'INFO', 'COMPLETED', 'Bank deposit of 40000 RWF added.'),
(3, 'INFO', 'COMPLETED', 'Payment of 3500 RWF to Alex Doe.'),
(4, 'INFO', 'COMPLETED', 'Withdrawal of 20000 RWF via Agent Sophia.'),
(5, 'INFO', 'COMPLETED', 'Received 5000 RWF from Linda Green.'),
(6, 'ERROR', 'FAILED', 'Payment of 5000 RWF to Bundles and Packs failed.');

-- Validation queries
SELECT phone_number, COUNT(*) FROM users GROUP BY phone_number HAVING COUNT(*) > 1;
SELECT * FROM transactions WHERE category_id IS NULL;
SELECT * FROM user_transactions ut
LEFT JOIN transactions t ON ut.transaction_id=t.transaction_id
LEFT JOIN users u ON ut.user_id=u.user_id
WHERE t.transaction_id IS NULL OR u.user_id IS NULL;
