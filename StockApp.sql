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

-- CHANGE NAME OF COLUMN
-- EXEC sp_rename 'derivatives.drivative_id', 'derivative_id', 'COLUMN';

CREATE TABLE derivatives
(
    derivative_id INT PRIMARY KEY IDENTITY,
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
    warrant_id INT PRIMARY KEY IDENTITY,
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

SELECT *
FROM stocks;
-- fake data generate from chatGPT, just for study
INSERT INTO stocks
    (symbol, company_name, market_cap, sector, industry, stock_type, sector_en, industry_en)
VALUES
    ('VCB', N'Ngân hàng Ngoại thương Việt Nam', 45000000000, N'Tài chính', N'Ngân hàng', 'Cổ phiếu thường', 'Dịch vụ tài chính', 'Ngân hàng'),
    ('ACB', N'Ngân hàng Á Châu', 35000000000, N'Tài chính', N'Ngân hàng', 'Cổ phiếu thường', 'Dịch vụ tài chính', 'Ngân hàng'),
    ('VNDB', N'Ngân hàng Phát triển Việt Nam', 30000000000, N'Tài chính', N'Ngân hàng', 'Cổ phiếu thường', 'Dịch vụ tài chính', 'Ngân hàng'),
    ('FPT', N'Tập đoàn FPT', 28000000000, N'Công nghệ', N'Công nghệ thông tin', 'Cổ phiếu thường', 'Công nghệ', 'Dịch vụ IT'),
    ('VNM', N'Vinamilk', 20000000000, N'Thực phẩm', N'Sữa và sản phẩm sữa', 'Cổ phiếu thường', 'Thực phẩm', 'Sản phẩm sữa'),
    ('PNJ', N'Phú Nhuận Jewelry', 12000000000, N'Bán lẻ', N'Đồ trang sức', 'Cổ phiếu thường', 'Hàng tiêu dùng', 'Bán lẻ'),
    ('BID', N'Ngân hàng BIDV', 42000000000, N'Tài chính', N'Ngân hàng', 'Cổ phiếu thường', 'Dịch vụ tài chính', 'Ngân hàng'),
    ('HAG', N'HAGL Agrico', 8000000000, N'Nông nghiệp', N'Sản phẩm nông nghiệp', 'Cổ phiếu thường', 'Nông nghiệp', 'Nông nghiệp'),
    ('HDB', N'Ngân hàng HDBank', 25000000000, N'Tài chính', N'Ngân hàng', 'Cổ phiếu thường', 'Dịch vụ tài chính', 'Ngân hàng'),
    ('DQC', N'Công ty Digiworld', 15000000000, N'Bán lẻ', N'Điện tử', 'Cổ phiếu thường', 'Hàng tiêu dùng', 'Điện tử'),
    ('VIC', N'Vingroup', 55000000000, N'Bất động sản', N'Phát triển dự án', 'Cổ phiếu thường', 'Bất động sản', 'Phát triển dự án'),
    ('MWG', N'Tập đoàn Thế giới di động', 18000000000, N'Bán lẻ', N'Điện tử', 'Cổ phiếu thường', 'Hàng tiêu dùng', 'Điện tử'),
    ('SHB', N'Ngân hàng Sài Gòn - Hà Nội', 32000000000, N'Tài chính', N'Ngân hàng', 'Cổ phiếu thường', 'Dịch vụ tài chính', 'Ngân hàng'),
    ('PVG', N'Tổng công ty Khí Việt Nam', 30000000000, N'Energia', N'Dầu và khí', 'Cổ phiếu thường', 'Năng lượng', 'Dầu và khí'),
    ('CTG', N'Ngân hàng VietinBank', 40000000000, N'Tài chính', N'Ngân hàng', 'Cổ phiếu thường', 'Dịch vụ tài chính', 'Ngân hàng'),
    ('MSN', N'Tập đoàn Masan', 23000000000, N'Hàng tiêu dùng', N'Thực phẩm và Đồ uống', 'Cổ phiếu thường', 'Hàng tiêu dùng', 'Thực phẩm và Đồ uống'),
    ('HPG', N'Tập đoàn Hòa Phát', 10000000000, N'Công nghiệp', N'Nhôm và Thép', 'Cổ phiếu thường', 'Sản xuất', 'Thép'),
    ('SSI', N'Công ty Chứng khoán SSI', 28000000000, N'Tài chính', N'Chứng khoán', 'Cổ phiếu thường', 'Dịch vụ tài chính', 'Chứng khoán'),
    ('STB', N'Ngân hàng Sacombank', 19000000000, N'Tài chính', N'Ngân hàng', 'Cổ phiếu thường', 'Dịch vụ tài chính', 'Ngân hàng'),
    ('PVD', N'Tổng công ty Khoan và Dịch vụ Khoan Dầu khí', 15000000000, N'Energia', N'Dầu và khí', 'Cổ phiếu thường', 'Năng lượng', 'Dầu và khí'),
    ('TCO', N'TechCo Solutions', 8000000000, N'Technology', N'Software', 'Common Stock', 'Technology', 'Software'),
    ('GMC', N'Global Motors Corp', 12000000000, N'Automotive', N'Car Manufacturing', 'Common Stock', 'Automotive', 'Car Manufacturing'),
    ('HLC', N'HealthLife Corp', 15000000000, N'Healthcare', N'Pharmaceuticals', 'Common Stock', 'Healthcare', 'Pharmaceuticals'),
    ('ENE', N'EcoEnergy Ltd', 10000000000, N'Energy', N'Renewable Energy', 'Common Stock', 'Energy', 'Renewable Energy'),
    ('FSC', N'FoodSupp Corp', 7000000000, N'Food & Beverage', N'Food Supplements', 'Common Stock', 'Food & Beverage', 'Food Supplements'),
    ('MTC', N'MetroTech Communications', 11000000000, N'Telecommunications', N'Networking', 'Common Stock', 'Telecommunications', 'Networking'),
    ('LOG', N'Logistics Ltd', 9000000000, N'Logistics', N'Shipping', 'Common Stock', 'Logistics', 'Shipping'),
    ('AIR', N'AeroTech Systems', 18000000000, N'Aerospace', N'Aircraft Manufacturing', 'Common Stock', 'Aerospace', 'Aircraft Manufacturing');
GO

SELECT *
FROM quotes;
INSERT INTO quotes
    (stock_id, price, change, percent_change, volume, time_stamp)
VALUES
    (1, 100.50, 1.50, 1.5, 1000, '2022-04-10 10:00:00'),
    (2, 75.20, -0.80, -1.1, 800, '2022-04-10 10:15:00'),
    (3, 120.75, 2.25, 2.0, 1200, '2022-04-10 10:30:00'),
    (4, 50.80, -1.20, -2.3, 600, '2022-04-10 10:45:00'),
    (5, 90.25, 0.50, 0.6, 1500, '2022-04-10 11:00:00'),
    (6, 110.30, 1.80, 1.7, 900, '2022-04-10 11:15:00');
GO

SELECT *
FROM market_indices;
-- SELECT * FROM market_indices ORDER BY name DESC
-- fake data generate from chatGPT, just for study
INSERT INTO market_indices
    (name, symbol)
VALUES
    ('FinMart TechWave Index', 'TWI'),
    ('FinMart GreenEco Composite', 'GEC'),
    ('FinMart HealthLink 500', 'HL500'),
    ('FinMart AutoTech Benchmark', 'ATB'),
    ('FinMart GlobalEnergy Tracker', 'GET'),
    ('FinMart LuxuryElite Index', 'LEI'),
    ('FinMart FoodTech 100', 'FT100'),
    ('FinMart BioPharma Pulse', 'BPP'),
    ('FinMart SustainableFuture 200', 'SF200'),
    ('FinMart RenewablePower Index', 'RPI'),

    ('InvestMart TechElite Index', 'TEI'),
    ('InvestMart BioGrowth 200 Index', 'BG200'),
    ('InvestMart EnergyPulse Index', 'EPI'),
    ('InvestMart GreenInnovate Index', 'GI'),
    ('InvestMart GlobalDynamics 500 Index', 'GD500'),
    ('InvestMart CryptoWave Index', 'CW'),
    ('InvestMart HealthVitality 150 Index', 'HV150'),
    ('InvestMart AeroTech Index', 'ATI'),
    ('InvestMart FutureHarbor 300 Index', 'FH300'),
    ('InvestMart SilverLinx Index', 'SLI'),

    ('TradeMart GlobalTech 100 Index', 'GT100'),
    ('TradeMart AlphaFinance Composite', 'AFC'),
    ('TradeMart InnovateX Growth Index', 'IGI'),
    ('TradeMart EnergyPros Elite', 'EPE'),
    ('TradeMart TechWiz 2000', 'TW2K'),
    ('TradeMart GreenEco Sustainability', 'GES'),
    ('TradeMart BlueChip Dynamic', 'BCD'),
    ('TradeMart DividendMaster 500', 'DM500'),
    ('TradeMart HealthWealth BioTech', 'HWB'),
    ('TradeMart CryptoGenius 100', 'CG100');
GO

SELECT *
FROM index_constituents;
INSERT INTO index_constituents
    (index_id, stock_id)
VALUES
    (1, 1),
    (1, 2),
    (1, 3),
    (1, 4),
    (1, 5),
    (1, 6),
    (2, 7),
    (2, 8),
    (2, 9),
    (2, 10),
    (2, 11),
    (2, 12),
    (3, 13),
    (3, 14),
    (3, 15),
    (3, 16),
    (3, 17),
    (3, 18),
    (4, 19),
    (4, 20),
    (4, 21),
    (4, 22),
    (4, 23),
    (4, 24),
    (5, 25),
    (5, 25),
    (5, 26),
    (5, 27),
    (5, 28);
GO

SELECT *
FROM stocks;
SELECT *
FROM index_constituents;
SELECT *
FROM market_indices;
GO;

-- USE StockApp;
-- DROP VIEW v_stock_index 
-- GO;

CREATE VIEW v_stock_index
AS
    SELECT
        s.stock_id,
        s.symbol,
        s.company_name,
        s.market_cap,
        s.sector_en,
        s.sector,
        s.industry_en,
        s.industry,
        s.stock_type,
        i.index_id,
        m.symbol AS index_symbol,
        m.name AS index_name
    FROM stocks AS s
        INNER JOIN index_constituents AS i
        ON s.stock_id = i.stock_id
        INNER JOIN market_indices AS m
        ON m.index_id = i.index_id;
GO

SELECT
    v.index_symbol,
    v.index_name,
    v.symbol AS stock_symbol,
    v.company_name
FROM v_stock_index AS v
-- WHERE v.index_symbol = 'ATB'
ORDER BY v.index_symbol;
GO

SELECT
    v.index_symbol,
    v.index_name,
    COUNT(DISTINCT v.company_name) AS total_companies
FROM v_stock_index AS v
GROUP BY v.index_symbol, v.index_name
ORDER BY v.index_symbol;

SELECT *
FROM v_stock_index
WHERE market_cap > 42000000000;

-- SELECT COUNT(*) AS total_companies
-- FROM v_stock_index
-- WHERE market_cap > 42000000000;

-- SELECT 
--     v.symbol,
--     FORMAT(v.market_cap, '#,##0') AS market_cap
-- FROM v_stock_index AS v

-- SELECT * FROM derivatives;
INSERT INTO derivatives
    (name, underlying_asset_id, contract_size, expiration_date,
    strike_price, last_price, change, percent_change, open_price, high_price, low_price, volume, open_interest, time_stamp)
VALUES
    (N'OptionA', 1, 100, '2023-01-15', 150.50, 10.75, 1.25, 12.5, 10.50, 11.25, 9.75, 500, 200, '2023-01-01 08:30:00'),
    (N'FuturesB', 3, 500, '2023-02-28', 180.25, 22.60, -3.20, -12.4, 25.00, 26.75, 20.50, 800, 300, '2023-01-05 10:15:00'),
    (N'SwapC', 6, 200, '2023-03-20', 75.80, 18.45, 2.30, 14.3, 16.75, 17.90, 16.50, 300, 150, '2023-01-10 12:45:00'),
    (N'OptionD', 9, 150, '2023-04-18', 120.30, 12.90, -1.75, -11.9, 13.25, 14.50, 12.00, 400, 180, '2023-01-15 14:30:00'),
    (N'FuturesE', 12, 300, '2023-05-25', 200.75, 30.20, 4.50, 17.5, 28.50, 32.00, 27.00, 700, 250, '2023-01-20 16:00:00'),
    (N'SwapF', 15, 250, '2023-06-10', 95.25, 15.75, -2.80, -15.1, 16.00, 17.25, 15.50, 350, 120, '2023-01-25 18:20:00'),
    (N'OptionG', 18, 180, '2023-07-15', 140.90, 14.25, 1.90, 15.4, 12.50, 15.75, 12.00, 450, 220, '2023-01-30 20:45:00'),
    (N'FuturesH', 21, 400, '2023-08-30', 185.40, 25.80, 3.75, 16.9, 24.75, 26.50, 23.00, 900, 350, '2023-02-05 22:10:00'),
    (N'SwapI', 24, 300, '2023-09-18', 80.60, 20.45, 2.60, 14.6, 18.00, 19.75, 17.50, 400, 180, '2023-02-10 23:30:00'),
    (N'OptionJ', 27, 220, '2023-10-20', 125.15, 13.90, -1.20, -8.0, 14.75, 15.50, 13.25, 500, 200, '2023-02-15 01:45:00');
GO

SELECT
    d.underlying_asset_id,
    d.name
FROM derivatives AS d
ORDER BY underlying_asset_id;
GO

-- DROP VIEW v_stocks_derivatives;
-- GO

CREATE VIEW v_stocks_derivatives
AS
    SELECT
        s.*,
        d.*
    FROM stocks s
        INNER JOIN derivatives d ON d.underlying_asset_id = s.stock_id;
GO

SELECT *
FROM v_stocks_derivatives;

SELECT
    v.stock_id,
    v.symbol,
    v.company_name,
    v.derivative_id,
    v.name AS derivative_name
FROM v_stocks_derivatives v
ORDER BY stock_id

SELECT
    symbol,
    company_name,
    COUNT(derivative_id) AS num_derivatives
FROM v_stocks_derivatives
GROUP BY symbol, company_name;

SELECT *
FROM covered_warrants;

-- SELECT COUNT(*)
-- FROM covered_warrants WHERE warrant_type='Call'

INSERT INTO covered_warrants
    (name, underlying_asset_id, issue_date, expiration_date, strike_price, warrant_type)
VALUES
    (N'CallWarrantA', 1, '2023-01-15', '2023-03-15', 120.50, N'Call'),
    (N'PutWarrantB', 2, '2023-02-28', '2023-04-30', 85.20, N'Put'),
    (N'CallWarrantC', 3, '2023-03-20', '2023-05-20', 150.75, N'Call'),
    (N'PutWarrantD', 4, '2023-04-18', '2023-06-18', 45.80, N'Put'),
    (N'CallWarrantE', 5, '2023-05-25', '2023-07-25', 100.25, N'Call'),
    (N'PutWarrantF', 6, '2023-06-10', '2023-08-10', 70.30, N'Put'),
    (N'CallWarrantG', 7, '2023-07-15', '2023-09-15', 130.90, N'Call'),
    (N'PutWarrantH', 8, '2023-08-30', '2023-10-30', 175.40, N'Put'),
    (N'CallWarrantI', 9, '2023-09-18', '2023-11-18', 90.60, N'Call'),
    (N'PutWarrantJ', 10, '2023-10-20', '2023-12-20', 125.15, N'Put'),
    (N'CallWarrantK', 11, '2023-11-15', '2024-01-15', 140.75, N'Call'),
    (N'PutWarrantL', 12, '2023-12-05', '2024-02-05', 65.80, N'Put'),
    (N'CallWarrantM', 13, '2024-01-10', '2024-03-10', 110.25, N'Call'),
    (N'PutWarrantN', 14, '2024-02-18', '2024-04-18', 55.30, N'Put'),
    (N'CallWarrantO', 15, '2024-03-15', '2024-05-15', 120.90, N'Call'),
    (N'PutWarrantP', 16, '2024-04-30', '2024-06-30', 85.20, N'Put');
GO


-- Call both warrant_type sell and buy

-- SELECT 'Sell' AS order_type, COUNT(*) AS num_orders
-- FROM covered_warrants
-- WHERE warrant_type = 'Call'
-- UNION ALL
-- SELECT 'Buy' AS order_type, COUNT(*) AS num_orders
-- FROM covered_warrants
-- WHERE warrant_type = 'Put';

SELECT *
FROM etfs;

INSERT INTO etfs
    (name, symbol, management_company, inception_date)
VALUES
    (N'TechETF1', N'TE1', N'Tech Management', '2022-01-15'),
    (N'FinanceETF2', N'FE2', N'Finance Co.', '2022-02-28'),
    (N'HealthcareETF3', N'HE3', N'Health Management', '2022-03-20'),
    (N'EnergyETF4', N'EE4', N'Energy Inc.', '2022-04-18'),
    (N'ConsumerETF5', N'CE5', N'Consumer Holdings', '2022-05-25'),
    (N'IndustrialsETF6', N'IE6', N'Industrials Ltd.', '2022-06-10'),
    (N'TelecomETF7', N'TE7', N'Telecom Group', '2022-07-15'),
    (N'MaterialsETF8', N'ME8', N'Materials Corp.', '2022-08-30'),
    (N'RealEstateETF9', N'RE9', N'Real Estate Management', '2022-09-18'),
    (N'UtilitiesETF10', N'UE10', N'Utilities Co.', '2022-10-20'),
    (N'TransportationETF11', N'TE11', N'Transportation Inc.', '2022-11-15'),
    (N'AgricultureETF12', N'AE12', N'Agriculture Holdings', '2022-12-05'),
    (N'BiotechETF13', N'BE13', N'Biotech Group', '2023-01-10'),
    (N'RenewableEnergyETF14', N'REE14', N'Renewable Energy Management', '2023-02-18'),
    (N'GlobalTechETF15', N'GTE15', N'Global Tech Inc.', '2023-03-15'),
    (N'SocialMediaETF16', N'SME16', N'Social Media Co.', '2023-04-30');
GO