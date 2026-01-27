CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'unique id for each user',
    name VARCHAR(150) NOT NULL COMMENT 'the name of the user',
    phone_number VARCHAR(15) UNIQUE NOT NULL COMMENT 'unique phone handle',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation time'

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

    FOREIGN KEY (category_id) REFERENCES transaction_categories(category_id)

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

ALTER TABLE transactions 
ADD COLUMN external_ref_id VARCHAR(50) UNIQUE NOT NULL COMMENT 'Unique MoMo Transaction ID' 
AFTER transaction_id;

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

-- Registering unique participants
insert into users (user_id, name, phone_number, entity_type) values 
(1, 'Main User', '36521838', 'SELF'),          
(2, 'Samuel Carter', '250791666666', 'INDIVIDUAL'),  		
(3, 'MTN Bank System', '250795963036', 'MERCHANT'),  		
(4, 'Alex Doe', '43810', 'MERCHANT'),             		
(5, 'Agent Sophia', '250790777777', 'AGENT'), 
(6, 'Linda Green', '*********806', 'INDIVIDUAL'),   
(7, 'Bundles and Packs', 'Bundles and Packs', 'MERCHANT');


-- Define the types of transactions 
insert into transaction_categories (category_id, category_name) values 
(1, 'P2P'),           -- Peer-to-Peer (Transfer/Receive)
(2, 'DEPOSIT'),       -- Bank deposit
(3, 'MERCHANT'),      -- Payment to a merchant code
(4, 'WITHDRAW'),      -- Agent withdrawal
(5, 'BILLS');         -- Service payments (Bundles,Electricity,...)


-- Records of 6 sample transactions (5 Completed, 1 Failed)
insert into transactions (transaction_id, transaction_date, amount, fees, category_id, status, raw_message) values
(1, '2024-05-11 20:34:47', 10000.00, 100.00, 1, 'COMPLETED', '*165*S*10000 RWF transferred to Samuel Carter (250791666666) from 36521838 at 2024-05-11 20:34:47 . Fee was: 100 RWF. New balance: 28300 RWF. Kugura ama inite cg interineti kuri MoMo, Kanda *182*2*1# .*EN#'),
(2, '2024-05-11 18:43:49', 40000.00, 0.00, 2, 'COMPLETED', '*113*R*A bank deposit of 40000 RWF has been added to your mobile money account at 2024-05-11 18:43:49. Your NEW BALANCE :40400 RWF. Cash Deposit::CASH::::0::250795963036.Thank you for using MTN MobileMoney.*EN#'),
(3, '2024-05-12 13:34:25', 3500.00, 0.00, 3, 'COMPLETED', 'TxId: 82113964658. Your payment of 3,500 RWF to Alex Doe 43810 has been completed at 2024-05-12 13:34:25. Your new balance: 10,880 RWF. Fee was 0 RWF.'),
(4, '2024-05-26 02:10:27', 20000.00, 350.00, 4, 'COMPLETED', 'You Abebe Chala CHEBUDIE (*********036) have via agent: Agent Sophia (250790777777), withdrawn 20000 RWF from your mobile money account: 36521838 at 2024-05-26 02:10:27 and you can now collect your money in cash. Your new balance: 6400 RWF. Fee paid: 350 RWF. Message from agent: 1. Financial Transaction Id: 14098463509.'),
(5, '2024-06-18 14:08:05', 5000.00, 0.00, 1, 'COMPLETED', 'You have received 5000 RWF from Linda Green (*********806) on your mobile money account at 2024-06-18 14:08:05. Message from sender: . Your new balance:14110 RWF. Financial Transaction Id: 43960900475.'),
(6, '2024-11-12 23:47:47', 5000.00, 0.00, 5, 'FAILED', '*143*TxId:16803066185*S*Your payment of 5000 RWF to Bundles and Packs with token has failed at 2024-11-12 23:47:47. Message: - -. *EN#');

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

INSERT INTO system_logs (transaction_id, log_level, status, message) VALUES
(1, 'INFO', 'COMPLETED', 'Transaction parsed successfully from SMS.'),
(2, 'INFO', 'COMPLETED', 'Fee calculation verified.'),
(3, 'INFO', 'COMPLETED', 'Balance update synchronized.'),
(4, 'WARNING', 'FLAGGED', 'High frequency transaction detected.'),
(5, 'INFO', 'COMPLETED', 'Cash withdrawal agent verified.');



