USE master;
-- CREATE DATABASE StockApp;
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'StockApp')
    CREATE DATABASE StockApp;
GO
USE StockApp;
CREATE TABLE users (
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
CREATE TABLE user_devices (
    id INT PRIMARY KEY IDENTITY,
    user_id INT NOT NULL,
    device_id NVARCHAR(255) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE stocks (
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
CREATE TABLE quotes (
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
CREATE TABLE market_indices (
    index_id INT PRIMARY KEY IDENTITY,
    name NVARCHAR(255) NOT NULL,
    symbol NVARCHAR(59) UNIQUE NOT NULL
);

-- market_indices - stocks => n - n
-- index_constituents: list of companies that have been selected 
-- for index calculation of a certain stock market index
-- association table
CREATE TABLE index_constituents (
    index_id INT FOREIGN KEY REFERENCES market_indices(index_id),
    stock_id INT FOREIGN KEY REFERENCES stocks(stock_id)
)

CREATE TABLE derivatives (
    drivaive_id INT PRIMARY KEY IDENTITY,
    name NVARCHAR(255) NOT NULL,
    underlying_asset_id INT FOREIGN KEY REFERENCES stocks(stock_id),
    contract_size INT,
    expiration_date DATE, -- Date contract
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
)

-- covered warrants ensure by third party (ex: banks, company)
CREATE TABLE covered_warrants (
    wrrant_id INT PRIMARY KEY IDENTITY,
    name NVARCHAR(255) NOT NULL,
    underlying_asset_id INT FOREIGN KEY REFERENCES stocks(stock_id), -- ID of stakeholder's base asset 
    issue_date DATE,
    expiration_date DATE,
    strike_price DECIMAL(18,4),
    warrant_type NVARCHAR(50),
)

CREATE TABLE etfs (
    eft_id INT PRIMARY KEY IDENTITY,
    name NVARCHAR(255) NOT NULL,
    symbol NVARCHAR(50) UNIQUE NOT NULL,
    management_company NVARCHAR(255),
    inception_date DATE,
)

-- relationship between etf and etf_quotes is 1 - n 
-- an investment fund can have multiple quotes on the same day
CREATE TABLE etf_quotes (
    quote_id INT PRIMARY KEY IDENTITY(1,1),
    etf_id INT FOREIGN KEY REFERENCES etfs(eft_id),
    price DECIMAL(18,2) NOT NULL,
    change DECIMAL(18,2) NOT NULL, -- price movement of ETFs compared to the previous day
    percent_change DECIMAL(18,2) NOT NULL,  -- the price movement of the ETF compared to the previous day
    total_volume INT NOT NULL,
    time_stamp DATETIME NOT NULL,
)

CREATE TABLE etf_holdings (
    eft_id INT FOREIGN KEY REFERENCES etfs(eft_id),
    stock_id INT FOREIGN KEY REFERENCES stocks(stock_id),
    shares_held DECIMAL(18,4),
    weight DECIMAL(18,4)
)
-- relationship between user and stocks: n - n
CREATE TABLE watch_lists (
    user_id INT FOREIGN KEY REFERENCES users(user_id),
    stock_id INT FOREIGN KEY REFERENCES stocks(stock_id)
)

-- Orders table (place an order)
/*
    Market order:
    Limit order:
    Stop order:
*/

CREATE TABLE orders (
    order_id INT PRIMARY KEY IDENTITY(1,1),
    user_id INT FOREIGN KEY REFERENCES users(user_id),
    stock_id INT FOREIGN KEY REFERENCES stocks(stock_id),
    order_type NVARCHAR(20), -- market, limit, stop
    direction NVARCHAR(20), -- buy, sell
    quantity INT,
    price DECIMAL(18,4),
    status NVARCHAR(20), -- pending, executed, cancelled
    order_date DATETIME,
)

CREATE TABLE porfolios (
    user_id INT FOREIGN KEY REFERENCES users(user_id),
    stock_id INT FOREIGN KEY REFERENCES stocks(stock_id),
    quantity INT,
    purchase_price DECIMAL(18,4),
    purchase_date DATETIME
)
