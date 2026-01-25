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
    balance_after INT

    FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);


