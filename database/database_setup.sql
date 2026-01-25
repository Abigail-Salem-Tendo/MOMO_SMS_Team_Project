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

ALTER TABLE users 
ADD COLUMN entity_type ENUM('SELF', 'INDIVIDUAL', 'MERCHANT', 'AGENT') 
DEFAULT 'INDIVIDUAL' 
COMMENT 'Type of user: Self, Person, Business, or Agent'
AFTER phone_number;

ALTER TABLE transactions 
    MODIFY transaction_date DATETIME NOT NULL COMMENT 'Date extracted from SMS',
    MODIFY amount DECIMAL(15, 2) NOT NULL COMMENT 'Transaction amount in RWF',
    MODIFY fees DECIMAL(10, 2) DEFAULT 0.00 COMMENT 'Service fees charged';


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
    FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id) ON DELETE SET NULL,
    INDEX idx_log_level (log_level),
    INDEX idx_log_time (created_at)
);

INSERT IGNORE INTO users (user_id, name, phone_number, entity_type) VALUES 
(1, 'My Device', '0788000000', 'SELF'),
(2, 'KAREKEZI JEAN', '0788123456', 'INDIVIDUAL'),
(3, 'MUGISHA ALINE', '0788654321', 'INDIVIDUAL'),
(4, 'RWARUTABURA', '0788987654', 'MERCHANT'),
(5, 'CANAL+ RWANDA', '0788555555', 'MERCHANT'),
(6, 'MUVUNYI AGENT', '0788111222', 'AGENT');



-- Sample Data to test our database. Most of this data is from the .xml file given to us to help us design the DB.
INSERT IGNORE INTO transaction_categories (category_id, category_name) VALUES 
(1, 'P2P_RECEIVE'), 
(2, 'P2P_SEND'), 
(3, 'MERCHANT_PAY'), 
(4, 'WITHDRAWAL'), 
(5, 'BILL_PAY');
INSERT IGNORE INTO users (user_id, name, phone_number, entity_type) VALUES 
(1, 'My Device', '0788000000', 'SELF'),
(2, 'KAREKEZI JEAN', '0788123456', 'INDIVIDUAL'),
(3, 'MUGISHA ALINE', '0788654321', 'INDIVIDUAL'),
(4, 'RWARUTABURA', '0788987654', 'MERCHANT'),
(5, 'CANAL+ RWANDA', '0788555555', 'MERCHANT'),
(6, 'MUVUNYI AGENT', '0788111222', 'AGENT');

INSERT IGNORE INTO user_transactions (transaction_id, user_id, role, balance_after) VALUES
-- Tx 1: Karekezi sent to You
(1, 2, 'SENDER', NULL),
(1, 1, 'RECEIVER', 45000.00),
-- Tx 2: You paid Rwarutabura
(2, 1, 'SENDER', 42950.00),
(2, 4, 'RECEIVER', NULL),
-- Tx 3: Mugisha sent to You
(3, 3, 'SENDER', NULL),
(3, 1, 'RECEIVER', 57950.00),
-- Tx 4: You paid Canal+
(4, 1, 'SENDER', 47750.00),
(4, 5, 'RECEIVER', NULL),
-- Tx 5: You withdrew cash (Sender) from Agent (Receiver)
(5, 1, 'SENDER', 0.00),
(5, 6, 'RECEIVER', NULL);



