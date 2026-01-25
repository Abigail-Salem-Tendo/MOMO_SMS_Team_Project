CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    phone_number VARCHAR(15) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    transaction_date DATETIME NOT NULL,
    amount INT NOT NULL,
    fees INT,
    category_id INT,
    status VARCHAR(50) NOT NULL,
    raw_message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);

CREATE TABLE user_transactions (
    user_transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    transaction_id INT,
    user_id INT,
    role text NOT NULL,
    balance_after INT,

    FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);



ALTER TABLE users 
    MODIFY name VARCHAR(150) NOT NULL COMMENT 'Full name of the user',
    MODIFY phone_number VARCHAR(15) NOT NULL COMMENT 'Unique phone handle';


ALTER TABLE transactions 
    MODIFY transaction_date DATETIME NOT NULL COMMENT 'Date extracted from SMS',
    MODIFY amount DECIMAL(15, 2) NOT NULL COMMENT 'Transaction amount in RWF',
    MODIFY fees DECIMAL(10, 2) DEFAULT 0.00 COMMENT 'Service fees charged',
    ADD CONSTRAINT chk_amount_positive CHECK (amount > 0),
    ADD INDEX idx_tx_date (transaction_date);


ALTER TABLE user_transactions 
    MODIFY role ENUM('SENDER', 'RECEIVER') NOT NULL COMMENT 'Role: SENDER or RECEIVER',
    MODIFY balance_after DECIMAL(15, 2) COMMENT 'Balance snapshot after event';

CREATE TABLE IF NOT EXISTS transaction_categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) UNIQUE NOT NULL COMMENT 'e.g., P2P, MERCHANT, BILLS'
);

-- linking to transactions
ALTER TABLE transactions 
    ADD FOREIGN KEY (category_id) REFERENCES transaction_categories(category_id);

CREATE TABLE IF NOT EXISTS system_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    transaction_id INT COMMENT 'Links log to a specific transaction event',
    log_level ENUM('INFO', 'WARNING', 'ERROR') DEFAULT 'INFO' COMMENT 'Severity of the log entry',
    status VARCHAR(50) DEFAULT 'PROCESSING' COMMENT 'Current state of the transaction',
    message TEXT COMMENT 'Detailed system message or error trace',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Referential Integrity

    FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id) ON DELETE SET NULL,

    -- Appropriate Indexes
    -- 
    INDEX idx_log_level (log_level),
    -- Indexing created_at helps find "logs from the last hour"
    INDEX idx_log_time (created_at)
);