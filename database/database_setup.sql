-- Active: 1752652577294@@mysql-39736307-python-and-databases-1.f.aivencloud.com@15909@Wakuma
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
 -- 1. Categories (referenced by transactions)

-- 2. Users
CREATE TABLE IF NOT EXISTS users (
    user_id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'unique id for each user',
    name VARCHAR(150) NOT NULL COMMENT 'Full name of the user',
    phone_number VARCHAR(15) NOT NULL UNIQUE COMMENT 'Unique phone handle',
    entity_type ENUM('SELF','INDIVIDUAL','MERCHANT','AGENT') DEFAULT 'INDIVIDUAL'
        COMMENT 'Type of user: Self, Person, Business, or Agent',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation time'
);

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

    FOREIGN KEY (category_id) REFERENCES transaction_categories(category_id),
    INDEX idx_transaction_date (transaction_date)

    INDEX idx_category_id (category_id),
    FOREIGN KEY (category_id) REFERENCES transaction_categories(category_id)
);

-- Now run the new CREATE block above.

-- 4. User -> Transaction link (role per transaction)
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

-- 5. System logs (transaction_id is nullable so ON DELETE SET NULL works)
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













# from xml_sample

INSERT IGNORE INTO users (user_id, name, phone_number, entity_type) VALUES 
(1, 'My Device', '0788000000', 'SELF'),
(2, 'Jane Smith', '0788123013', 'INDIVIDUAL'),        
(3, 'Samuel Carter', '250791666666', 'INDIVIDUAL'),   
(4, 'Agent Sophia', '250790777777', 'AGENT'),         
(5, 'Airtime', 'MTN_AIRTIME', 'MERCHANT'),            
(6, 'Robert Brown', '0788999999', 'INDIVIDUAL');      


INSERT IGNORE INTO transactions (transaction_id, external_ref_id, transaction_date, amount, fees, category_id, raw_message) VALUES
(1, '76662021700', '2024-05-10 16:30:51', 2000.00, 0.00, 1, 'You have received 2000 RWF from Jane Smith (*********013) on your mobile money account at 2024-05-10 16:30:51.'),
(2, '51732411227', '2024-05-10 21:32:32', 600.00, 0.00, 2, 'TxId: 51732411227. Your payment of 600 RWF to Samuel Carter 95464 has been completed at 2024-05-10 21:32:32.'),
(3, '14098463509', '2024-05-26 02:10:27', 20000.00, 350.00, 4, 'You Abebe Chala CHEBUDIE have via agent: Agent Sophia (250790777777), withdrawn 20000 RWF from your mobile money account... Fee paid: 350 RWF.'),
(4, '13913173274', '2024-05-12 11:41:28', 2000.00, 0.00, 5, '*162*TxId:13913173274*S*Your payment of 2000 RWF to Airtime with token has been completed at 2024-05-12 11:41:28.'),
(5, '26614842768', '2024-05-12 17:58:15', 1000.00, 0.00, 2, 'TxId: 26614842768. Your payment of 1,000 RWF to Robert Brown 41193 has been completed at 2024-05-12 17:58:15.');

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

INSERT INTO system_logs (transaction_id, log_level, status, message) VALUES
(1, 'INFO', 'COMPLETED', 'Parsed incoming P2P from XML batch.'),
(2, 'INFO', 'COMPLETED', 'Verified outgoing payment to Samuel.'),
(3, 'INFO', 'COMPLETED', 'Agent withdrawal verified successfully.'),
(4, 'INFO', 'COMPLETED', 'Airtime token generated.'),
(5, 'INFO', 'COMPLETED', 'Payment to Robert confirmed.');




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