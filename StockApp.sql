USE master;
-- CREATE DATABASE StockApp;
IF NOT EXISTS (SELECT name
FROM sys.databases
WHERE name = N'StockApp')
    CREATE DATABASE StockApp;
GO
USE StockApp;
CREATE TABLE users
(
    user_id INT PRIMARY KEY IDENTITY(1,1) ,
    username NVARCHAR(100) UNIQUE NOT NULL,
    hashed_password NVARCHAR(100) NOT NULL,
    email NVARCHAR(255) UNIQUE NOT NULL,
    phone NVARCHAR(20) NOT NULL,
    fullname NVARCHAR(255),
    date_of_birth DATE,
    country NVARCHAR(200),
);

-- a user can login with multi devices
CREATE TABLE user_devices
(
    id INT PRIMARY KEY IDENTITY,
    user_id INT NOT NULL,
    device_id NVARCHAR(255) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE stocks
(
    stock_id INT PRIMARY KEY IDENTITY(1,1),
    symbol NVARCHAR(10) UNIQUE NOT NULL,
    company_name NVARCHAR(255) NOT NULL,
    market_cap DECIMAL(18,2),
    sector NVARCHAR(200),
    industry NVARCHAR(200),
    sector_en NVARCHAR(200),
    industry_en NVARCHAR(200),
    stock_type NVARCHAR(50),
    -- common stock, preferred stock, etf
    rank INT DEFAULT 0,
    rank_source NVARCHAR(200),
    reason NVARCHAR(255)
);

-- data realtime
CREATE TABLE quotes
(
    quote_id INT PRIMARY KEY IDENTITY(1,1),
    stock_id INT FOREIGN KEY REFERENCES stocks(stock_id),
    price DECIMAL(18,2) NOT NULL,
    change DECIMAL(18,2) NOT NULL,
    percent_change DECIMAL(18,2) NOT NULL,
    volume INT NOT NULL,
    time_stamp DATETIME NOT NULL,
);
GO

-- index => indices
CREATE TABLE market_indices
(
    index_id INT PRIMARY KEY IDENTITY,
    name NVARCHAR(255) NOT NULL,
    symbol NVARCHAR(59) UNIQUE NOT NULL
);

-- market_indices - stocks => n - n
-- index_constituents: list of companies that have been selected 
-- for index calculation of a certain stock market index
-- association table
CREATE TABLE index_constituents
(
    index_id INT FOREIGN KEY REFERENCES market_indices(index_id),
    stock_id INT FOREIGN KEY REFERENCES stocks(stock_id)
);

CREATE TABLE derivatives
(
    drivaive_id INT PRIMARY KEY IDENTITY,
    name NVARCHAR(255) NOT NULL,
    underlying_asset_id INT FOREIGN KEY REFERENCES stocks(stock_id),
    contract_size INT,
    expiration_date DATE,
    -- Date contract
    strike_price DECIMAL(18,4),
    last_price DECIMAL(18,2) NOT NULL,
    change DECIMAL(18,2) NOT NULL,
    percent_change DECIMAL(18,2) NOT NULL,
    open_price DECIMAL(18,2) NOT NULL,
    high_price DECIMAL(18,2) NOT NULL,
    low_price DECIMAL (18,2) NOT NULL,
    volume INT NOT NULL,
    open_interest INT NOT NULL,
    time_stamp DATETIME NOT NULL,
);

-- covered warrants ensure by third party (ex: banks, company)
CREATE TABLE covered_warrants
(
    wrrant_id INT PRIMARY KEY IDENTITY,
    name NVARCHAR(255) NOT NULL,
    underlying_asset_id INT FOREIGN KEY REFERENCES stocks(stock_id),
    -- ID of stakeholder's base asset 
    issue_date DATE,
    expiration_date DATE,
    strike_price DECIMAL(18,4),
    warrant_type NVARCHAR(50),
);

CREATE TABLE etfs
(
    eft_id INT PRIMARY KEY IDENTITY,
    name NVARCHAR(255) NOT NULL,
    symbol NVARCHAR(50) UNIQUE NOT NULL,
    management_company NVARCHAR(255),
    inception_date DATE,
);

-- relationship between etf and etf_quotes is 1 - n 
-- an investment fund can have multiple quotes on the same day
CREATE TABLE etf_quotes
(
    quote_id INT PRIMARY KEY IDENTITY(1,1),
    etf_id INT FOREIGN KEY REFERENCES etfs(eft_id),
    price DECIMAL(18,2) NOT NULL,
    change DECIMAL(18,2) NOT NULL,
    -- price movement of ETFs compared to the previous day
    percent_change DECIMAL(18,2) NOT NULL,
    -- the price movement of the ETF compared to the previous day
    total_volume INT NOT NULL,
    time_stamp DATETIME NOT NULL,
);

CREATE TABLE etf_holdings
(
    eft_id INT FOREIGN KEY REFERENCES etfs(eft_id),
    stock_id INT FOREIGN KEY REFERENCES stocks(stock_id),
    shares_held DECIMAL(18,4),
    weight DECIMAL(18,4)
);
-- relationship between user and stocks: n - n
CREATE TABLE watch_lists
(
    user_id INT FOREIGN KEY REFERENCES users(user_id),
    stock_id INT FOREIGN KEY REFERENCES stocks(stock_id)
);

-- Orders table (place an order)
/*
    Market order:
    Limit order:
    Stop order:
*/

CREATE TABLE orders
(
    order_id INT PRIMARY KEY IDENTITY(1,1),
    user_id INT FOREIGN KEY REFERENCES users(user_id),
    stock_id INT FOREIGN KEY REFERENCES stocks(stock_id),
    order_type NVARCHAR(20),
    -- market, limit, stop
    direction NVARCHAR(20),
    -- buy, sell
    quantity INT,
    price DECIMAL(18,4),
    status NVARCHAR(20),
    -- pending, executed, cancelled
    order_date DATETIME,
);

CREATE TABLE porfolios
(
    user_id INT FOREIGN KEY REFERENCES users(user_id),
    stock_id INT FOREIGN KEY REFERENCES stocks(stock_id),
    quantity INT,
    purchase_price DECIMAL(18,4),
    purchase_date DATETIME
);

/*
    order_executed:
    price_alert:
    news_event:
*/

CREATE TABLE notifications
(
    notification_id INT PRIMARY KEY IDENTITY(1,1),
    user_id INT FOREIGN KEY REFERENCES users(user_id),
    notification_type NVARCHAR(50),
    -- order_executed, price_alert, news_event
    content TEXT NOT NULL,
    is_read BIT DEFAULT 0,
    created_at DATETIME,
);

CREATE TABLE educational_resources
(
    resource_id INT PRIMARY KEY IDENTITY(1,1),
    title NVARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    category NVARCHAR(100),
    date_published DATETIME
);

-- linkded bank accounts table
-- routing number: indentify a bank at US, have 9 number

CREATE TABLE linked_bank_accounts
(
    account_id INT PRIMARY KEY IDENTITY(1,1),
    user_id INT FOREIGN KEY REFERENCES users(user_id),
    bank_name NVARCHAR(255) NOT NULL,
    account_number NVARCHAR(50) NOT NULL,
    routing_number NVARCHAR(50),
    account_type NVARCHAR(50)
);

CREATE TABLE transactions
(
    transaction_id INT PRIMARY KEY IDENTITY(1,1),
    user_id INT FOREIGN KEY REFERENCES users(user_id),
    linked_account_id INT FOREIGN KEY REFERENCES linked_bank_accounts(account_id),
    transaction_type NVARCHAR(50),
    -- deposi, withdrawal
    amount DECIMAL(18,2),
    transaction_date DATETIME,
);
GO

-- SELECT * FROM users;

-- create procedures

-- username NVARCHAR(100) UNIQUE NOT NULL,
--     hashed_password NVARCHAR(100) NOT NULL,
--     email NVARCHAR(255) UNIQUE NOT NULL,
--     phone NVARCHAR(20) NOT NULL,
--     fullname NVARCHAR(255),
--     date_of_birth DATE,
--     country NVARCHAR(200),

CREATE PROCEDURE RegisterUser
    @username NVARCHAR(200),
    @password NVARCHAR(100),
    @email NVARCHAR(255),
    @phone NVARCHAR(20),
    @fullname NVARCHAR(255),
    @date_of_birth DATE,
    @country NVARCHAR(200)
AS
BEGIN
    INSERT INTO users
        (username, hashed_password, email, phone, fullname, date_of_birth, country)
    VALUES
        (@username, HASHBYTES('SHA2_256', @password), @email, @phone, @fullname, @date_of_birth, @country)
END
-- GO

-- add data to procedures by users
EXEC RegisterUser 'user1', 'pass1', N'user1@gmail.com', N'987654321', N'User One', '1995-03-15', N'USA';
EXEC RegisterUser 'john_doe', N'secure123', N'john.doe@email.com', N'555888999', N'John Doe', '1988-07-22', N'Canada';
EXEC RegisterUser 'test_user', N'testpass', N'test.user@email.com', N'123987456', N'Test User', '2000-01-10', N'Australia';
EXEC RegisterUser 'alex_smith', N'password123', N'alex.smith@email.com', N'111222333', N'Alex Smith', '1992-09-05', N'UK';
EXEC RegisterUser 'mary_jane', N'mypass456', N'mary.jane@email.com', N'777888999', N'Mary Jane', '1985-12-18', N'USA';
EXEC RegisterUser 'new_user', N'newpass789', N'new.user@email.com', N'444555666', N'New User', '1998-04-30', N'Canada';
EXEC RegisterUser 'demo_account', N'demopass', N'demo.account@email.com', N'888999000', N'Demo Account', '1993-06-12', N'Australia';
EXEC RegisterUser 'samuel_k', N'sam123', N'samuel.k@email.com', N'123456789', N'Samuel K', '1987-11-03', N'UK';
EXEC RegisterUser 'user2', N'pass2', N'user2@email.com', N'987654321', N'User Two', '1996-08-17', N'USA';
EXEC RegisterUser 'lisa_w', N'lisa456', N'lisa.w@email.com', N'555888999', N'Lisa W', '1990-02-25', N'Canada';
GO

-- check login
CREATE PROCEDURE dbo.CheckLogin
    @Email NVARCHAR(50),
    @Password NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @HashedPassword VARBINARY(32)
    SET @HashedPassword = HASHBYTES('SHA2_256', @Password)
    BEGIN
        SELECT *
        FROM users
        WHERE Email IN
        (SELECT email
        FROM users
        WHERE email = @Email AND hashed_password = @HashedPassword);
    END
END;
GO

EXEC dbo.CheckLogin N'lisa.w@email.com', N'lisa456';


