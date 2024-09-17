CREATE DATABASE myapp;

USE myapp;

-- Create Users Table (for authentication only)
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    enabled BOOLEAN DEFAULT TRUE
);

-- Create Accounts Table (linked to users)
CREATE TABLE accounts (
    account_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    account_name VARCHAR(255),
    account_type VARCHAR(255),
    balance DECIMAL(10, 2) DEFAULT 0,
    currency VARCHAR(10),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Create Cards Table (linked to accounts)
CREATE TABLE cards (
    card_id INT AUTO_INCREMENT PRIMARY KEY,
    account_id INT,
    card_number VARCHAR(16),
    card_type VARCHAR(255),
    balance DECIMAL(10, 2) DEFAULT 0,
    enabled BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);

-- Create Categories Table (for categorizing transactions)
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    category_name VARCHAR(255),
    category_type VARCHAR(255), -- expense, income, etc.
    category_color VARCHAR(7),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Create Payments Table (linked to cards)
CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    card_id INT,
    amount DECIMAL(10, 2),
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    description TEXT,
    category_id INT,
    FOREIGN KEY (card_id) REFERENCES cards(card_id),
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- Create Transfers Table (linked to accounts)
CREATE TABLE transfers (
    transfer_id INT AUTO_INCREMENT PRIMARY KEY,
    account_id INT,
    amount DECIMAL(10, 2),
    transfer_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    description TEXT,
    category_id INT,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id),
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- Create Notifications Table (linked to users for alerts)
CREATE TABLE notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Create Statistics Table (linked to accounts)
CREATE TABLE statistics (
    statistic_id INT AUTO_INCREMENT PRIMARY KEY,
    account_id INT,
    statistic_type VARCHAR(255),
    value DECIMAL(10, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);

-- Insert Users
INSERT INTO users (email, username, password, enabled) VALUES
('john.doe@example.com', 'john_doe', 'password123', TRUE),
('jane.doe@example.com', 'jane_doe', 'password456', TRUE);

-- Insert Accounts for Users
INSERT INTO accounts (user_id, account_name, account_type, balance, currency, created_at, updated_at) VALUES
(1, 'John Checking', 'checking', 5000, 'USD', NOW(), NOW()),
(1, 'John Savings', 'savings', 15000, 'USD', NOW(), NOW()),
(2, 'Jane Checking', 'checking', 3000, 'USD', NOW(), NOW());

-- Insert Cards for Accounts
INSERT INTO cards (account_id, card_number, card_type, balance, enabled) VALUES
(1, '1234567812345678', 'visa', 2000, TRUE),
(1, '1234567898765432', 'mastercard', 500, TRUE),
(2, '9876543212345678', 'visa', 1000, TRUE);

-- Insert Categories for Users
INSERT INTO categories (user_id, category_name, category_type, category_color) VALUES
(1, 'Groceries', 'expense', '#FF0000'),
(1, 'Salary', 'income', '#00FF00'),
(2, 'Utilities', 'expense', '#0000FF');

-- Insert Payments (Card Transactions)
INSERT INTO payments (card_id, amount, payment_date, description, category_id) VALUES
(1, 50.75, NOW(), 'Grocery Store', 1),
(2, 120.00, NOW(), 'Restaurant', 1),
(3, 200.00, NOW(), 'Online Shopping', 1);

-- Insert Transfers (Bank Transfers)
INSERT INTO transfers (account_id, amount, transfer_date, description, category_id) VALUES
(1, 1000.00, NOW(), 'Rent Payment', 2),
(2, 500.00, NOW(), 'Savings Transfer', 2);

-- Insert Statistics for Accounts
INSERT INTO statistics (account_id, statistic_type, value, created_at) VALUES
(1, 'monthly_expense', 1500.00, NOW()),
(1, 'monthly_income', 3000.00, NOW()),
(2, 'monthly_savings', 5000.00, NOW());

-- Insert Notifications
INSERT INTO notifications (user_id, message, created_at) VALUES
(1, 'Your payment of $50.75 was successful', NOW()),
(2, 'Your transfer of $500 was successful', NOW());

