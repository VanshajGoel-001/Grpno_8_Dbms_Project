-- ============================================================================
-- STARTUP INVESTMENT ANALYSIS AND MANAGEMENT SYSTEM
-- Seed Data (DML - Data Manipulation Language)
-- ============================================================================
-- This file contains INSERT statements to populate all 7 tables with
-- realistic sample data for testing and demonstration purposes.
-- ============================================================================

USE startup_investment_db;

-- ============================================================================
-- SECTOR DATA (6 sectors)
-- ============================================================================
INSERT INTO SECTOR (Sector_Name, Description, Market_Volatility_Index) VALUES
('FinTech',     'Financial technology companies disrupting banking, payments, lending, and insurance through digital innovation.', 7.20),
('HealthTech',  'Healthcare technology startups leveraging AI, IoT, and data analytics to improve patient care and medical processes.', 5.80),
('EdTech',      'Education technology platforms providing online learning, skill development, and institutional management solutions.', 4.50),
('AI & ML',     'Artificial Intelligence and Machine Learning companies building intelligent systems across various domains.', 8.50),
('E-Commerce',  'Online retail and marketplace platforms connecting buyers and sellers through digital storefronts.', 6.30),
('CleanTech',   'Clean energy and sustainable technology companies focused on renewable energy, waste management, and green infrastructure.', 5.10);

-- ============================================================================
-- INVESTOR DATA (12 investors - mix of types)
-- ============================================================================
INSERT INTO INVESTOR (Name, Type, Email, Phone, Capital_Available, Risk_Preference, Registration_Date) VALUES
('Rajesh Mehta',          'Angel',            'rajesh.mehta@gmail.com',       '+91-9876543210',  5000000.00,   'Aggressive',    '2023-01-15'),
('Priya Sharma',          'Angel',            'priya.sharma@outlook.com',     '+91-9812345678',  3500000.00,   'Moderate',      '2023-03-20'),
('Sequoia Capital India', 'Venture Capital',   'deals@sequoia-india.com',      '+91-1144556677',  250000000.00, 'Aggressive',    '2022-06-01'),
('Accel Partners',        'Venture Capital',   'invest@accel.com',             '+91-1133445566',  180000000.00, 'Moderate',      '2022-08-15'),
('Tata Capital PE',       'Private Equity',    'pe@tatacapital.com',           '+91-1122334455',  500000000.00, 'Conservative',  '2022-01-10'),
('Infosys Ventures',      'Corporate',         'ventures@infosys.com',         '+91-8011223344',  100000000.00, 'Moderate',      '2023-05-01'),
('Ankit Gupta',           'Angel',            'ankit.gupta@yahoo.com',        '+91-9988776655',  2000000.00,   'Conservative',  '2023-07-12'),
('Neha Kapoor',           'Angel',            'neha.kapoor@gmail.com',        '+91-9977665544',  4500000.00,   'Aggressive',    '2023-02-28'),
('SIDBI Fund',            'Government',        'startup@sidbi.in',             '+91-1100998877',  300000000.00, 'Conservative',  '2022-04-01'),
('Kalaari Capital',       'Venture Capital',   'pitch@kalaari.com',            '+91-1166778899',  120000000.00, 'Aggressive',    '2022-11-20'),
('Rohit Bansal',          'Angel',            'rohit.bansal@gmail.com',       '+91-9955443322',  8000000.00,   'Moderate',      '2024-01-05'),
('Blume Ventures',        'Venture Capital',   'founders@blume.vc',            '+91-1199887766',  90000000.00,  'Aggressive',    '2023-09-15');

-- ============================================================================
-- STARTUP DATA (15 startups across 6 sectors)
-- ============================================================================
INSERT INTO STARTUP (Name, Sector_ID, Founding_Year, Current_Stage, Revenue, Valuation, Employee_Count, Location, Website) VALUES
('PayFast India',       1, 2021, 'Growth',          45000000.00,   350000000.00,  220, 'Bengaluru, Karnataka',   'https://payfast.in'),
('LendQuick',           1, 2022, 'Early Traction',  12000000.00,   85000000.00,   65,  'Mumbai, Maharashtra',    'https://lendquick.in'),
('MediScan AI',         2, 2020, 'Growth',          28000000.00,   200000000.00,  150, 'Hyderabad, Telangana',   'https://mediscan.ai'),
('HealthBridge',        2, 2023, 'MVP',             2000000.00,    15000000.00,   22,  'Pune, Maharashtra',      'https://healthbridge.in'),
('SkillForge',          3, 2021, 'Early Traction',  18000000.00,   120000000.00,  95,  'Delhi NCR',              'https://skillforge.edu'),
('CampusConnect',       3, 2022, 'Early Traction',  8000000.00,    55000000.00,   40,  'Chandigarh, Punjab',     'https://campusconnect.in'),
('NeuralWorks',         4, 2020, 'Expansion',       60000000.00,   500000000.00,  310, 'Bengaluru, Karnataka',   'https://neuralworks.ai'),
('DataMind Labs',       4, 2022, 'Early Traction',  10000000.00,   70000000.00,   55,  'Chennai, Tamil Nadu',    'https://datamind.in'),
('ShopEase',            5, 2019, 'Mature',          150000000.00,  800000000.00,  520, 'Mumbai, Maharashtra',    'https://shopease.com'),
('KrushiMart',          5, 2021, 'Growth',          35000000.00,   180000000.00,  130, 'Pune, Maharashtra',      'https://krushimart.in'),
('FreshBasket',         5, 2023, 'MVP',             3000000.00,    20000000.00,   18,  'Jaipur, Rajasthan',      'https://freshbasket.in'),
('SolarGrid Tech',      6, 2020, 'Growth',          40000000.00,   280000000.00,  175, 'Ahmedabad, Gujarat',     'https://solargrid.tech'),
('GreenCycle',          6, 2022, 'Early Traction',  7000000.00,    45000000.00,   35,  'Kochi, Kerala',          'https://greencycle.in'),
('VoiceBot AI',         4, 2023, 'MVP',             1500000.00,    12000000.00,   15,  'Noida, UP',              'https://voicebot.ai'),
('CryptoVault',         1, 2021, 'Early Traction',  22000000.00,   150000000.00,  80,  'Bengaluru, Karnataka',   'https://cryptovault.in');

-- ============================================================================
-- INVESTMENT DATA (22 investments across various rounds)
-- ============================================================================
INSERT INTO INVESTMENT (Investor_ID, Startup_ID, Investment_Amount, Equity_Percentage, Investment_Date, Funding_Round, Security_Type) VALUES
-- PayFast India investments
(3,  1,  25000000.00,  8.00,  '2023-06-15', 'Series A',   'Preferred Stock'),
(1,  1,  2000000.00,   1.50,  '2022-03-10', 'Seed',       'Equity'),
(10, 1,  50000000.00,  12.00, '2024-08-20', 'Series B',   'Preferred Stock'),

-- LendQuick investments
(4,  2,  15000000.00,  15.00, '2023-09-01', 'Seed',       'SAFE'),
(8,  2,  1500000.00,   3.00,  '2023-04-15', 'Pre-Seed',   'Convertible Note'),

-- MediScan AI investments
(3,  3,  30000000.00,  10.00, '2023-01-20', 'Series A',   'Preferred Stock'),
(6,  3,  20000000.00,  7.00,  '2024-03-10', 'Series B',   'Preferred Stock'),
(9,  3,  5000000.00,   3.00,  '2022-06-01', 'Seed',       'Equity'),

-- HealthBridge investments
(2,  4,  1000000.00,   8.00,  '2024-01-15', 'Pre-Seed',   'SAFE'),

-- SkillForge investments
(4,  5,  18000000.00,  12.00, '2023-07-01', 'Series A',   'Preferred Stock'),
(11, 5,  3000000.00,   4.00,  '2023-02-20', 'Seed',       'Equity'),

-- CampusConnect investments
(12, 6,  8000000.00,   14.00, '2024-02-05', 'Seed',       'SAFE'),

-- NeuralWorks investments (high-value)
(3,  7,  80000000.00,  12.00, '2022-11-15', 'Series B',   'Preferred Stock'),
(5,  7,  100000000.00, 15.00, '2024-05-01', 'Series C',   'Preferred Stock'),
(10, 7,  40000000.00,  6.00,  '2023-08-20', 'Series A',   'Equity'),

-- DataMind Labs investments
(12, 8,  10000000.00,  12.00, '2024-01-10', 'Seed',       'SAFE'),

-- ShopEase investments (mature company)
(5,  9,  150000000.00, 18.00, '2022-03-01', 'Series C',   'Preferred Stock'),
(3,  9,  50000000.00,  8.00,  '2021-06-15', 'Series B',   'Preferred Stock'),

-- KrushiMart investments
(4,  10, 25000000.00,  12.00, '2024-04-10', 'Series A',   'Preferred Stock'),
(7,  10, 1500000.00,   2.00,  '2023-08-01', 'Seed',       'Equity'),

-- SolarGrid Tech investments
(9,  12, 15000000.00,  5.00,  '2023-05-15', 'Series A',   'Equity'),
(6,  12, 30000000.00,  8.00,  '2024-09-01', 'Series B',   'Preferred Stock');

-- ============================================================================
-- FINANCIAL_DATA (quarterly records for startups)
-- ============================================================================
INSERT INTO FINANCIAL_DATA (Startup_ID, Reporting_Period, Revenue, Expenses, Net_Income, Cash_Balance, Burn_Rate, Customer_Count, MRR, ARR) VALUES
-- PayFast India (4 quarters)
(1, 'Q1-2025', 10000000.00, 7500000.00, 2500000.00,  45000000.00,  7500000.00, 15000, 3333333.33, 40000000.00),
(1, 'Q2-2025', 12500000.00, 8000000.00, 4500000.00,  50000000.00,  8000000.00, 18500, 4166666.67, 50000000.00),
(1, 'Q3-2025', 14000000.00, 8500000.00, 5500000.00,  55000000.00,  8500000.00, 22000, 4666666.67, 56000000.00),
(1, 'Q4-2025', 16000000.00, 9000000.00, 7000000.00,  62000000.00,  9000000.00, 26000, 5333333.33, 64000000.00),

-- MediScan AI (4 quarters)
(3, 'Q1-2025', 6000000.00,  5000000.00, 1000000.00,  30000000.00,  5000000.00, 800,   2000000.00, 24000000.00),
(3, 'Q2-2025', 7500000.00,  5200000.00, 2300000.00,  33000000.00,  5200000.00, 1050,  2500000.00, 30000000.00),
(3, 'Q3-2025', 8500000.00,  5500000.00, 3000000.00,  36000000.00,  5500000.00, 1300,  2833333.33, 34000000.00),
(3, 'Q4-2025', 9500000.00,  5800000.00, 3700000.00,  40000000.00,  5800000.00, 1600,  3166666.67, 38000000.00),

-- NeuralWorks (4 quarters)
(7, 'Q1-2025', 14000000.00, 10000000.00, 4000000.00, 80000000.00,  10000000.00, 250,  4666666.67, 56000000.00),
(7, 'Q2-2025', 16000000.00, 11000000.00, 5000000.00, 85000000.00,  11000000.00, 310,  5333333.33, 64000000.00),
(7, 'Q3-2025', 18000000.00, 12000000.00, 6000000.00, 92000000.00,  12000000.00, 380,  6000000.00, 72000000.00),
(7, 'Q4-2025', 20000000.00, 13000000.00, 7000000.00, 100000000.00, 13000000.00, 460,  6666666.67, 80000000.00),

-- ShopEase (4 quarters - mature)
(9, 'Q1-2025', 35000000.00, 28000000.00, 7000000.00,  120000000.00, 28000000.00, 150000, 11666666.67, 140000000.00),
(9, 'Q2-2025', 40000000.00, 30000000.00, 10000000.00, 130000000.00, 30000000.00, 175000, 13333333.33, 160000000.00),
(9, 'Q3-2025', 42000000.00, 31000000.00, 11000000.00, 140000000.00, 31000000.00, 195000, 14000000.00, 168000000.00),
(9, 'Q4-2025', 45000000.00, 32000000.00, 13000000.00, 155000000.00, 32000000.00, 220000, 15000000.00, 180000000.00),

-- SkillForge (2 quarters)
(5, 'Q3-2025', 4500000.00,  3800000.00, 700000.00,   15000000.00,  3800000.00, 5000,  1500000.00, 18000000.00),
(5, 'Q4-2025', 5500000.00,  4000000.00, 1500000.00,  17000000.00,  4000000.00, 6200,  1833333.33, 22000000.00),

-- SolarGrid Tech (2 quarters)
(12, 'Q3-2025', 9000000.00,  7000000.00, 2000000.00,  35000000.00,  7000000.00, 120,   3000000.00, 36000000.00),
(12, 'Q4-2025', 11000000.00, 7500000.00, 3500000.00,  40000000.00,  7500000.00, 155,   3666666.67, 44000000.00),

-- KrushiMart (2 quarters)
(10, 'Q3-2025', 8000000.00,  6500000.00, 1500000.00,  22000000.00,  6500000.00, 8500,  2666666.67, 32000000.00),
(10, 'Q4-2025', 9500000.00,  7000000.00, 2500000.00,  25000000.00,  7000000.00, 10200, 3166666.67, 38000000.00);

-- ============================================================================
-- RISK_ASSESSMENT DATA (assessments for major investments)
-- ============================================================================
INSERT INTO RISK_ASSESSMENT (Investment_ID, Assessment_Date, Market_Risk_Score, Technology_Risk_Score, Management_Risk_Score, Financial_Risk_Score, Overall_Rating) VALUES
-- PayFast India investments
(1,  '2024-01-15', 6.5, 4.0, 3.5, 4.0, 'Medium'),
(2,  '2023-06-20', 7.0, 5.0, 4.0, 5.5, 'Medium'),
(3,  '2024-12-01', 5.5, 3.5, 3.0, 3.5, 'Low'),

-- MediScan AI investments
(6,  '2024-02-10', 5.0, 6.5, 3.0, 4.0, 'Medium'),
(7,  '2024-09-15', 4.5, 5.5, 3.5, 3.5, 'Low'),
(8,  '2023-08-01', 6.0, 7.0, 4.0, 5.0, 'Medium'),

-- NeuralWorks investments
(13, '2024-06-01', 8.0, 3.0, 2.5, 3.0, 'Medium'),
(14, '2025-01-10', 7.5, 2.5, 2.0, 2.5, 'Low'),
(15, '2024-10-20', 7.0, 3.5, 3.0, 3.5, 'Medium'),

-- ShopEase investments
(17, '2024-04-01', 5.0, 2.0, 2.0, 2.5, 'Low'),
(18, '2023-12-15', 5.5, 2.5, 2.5, 3.0, 'Low'),

-- SolarGrid Tech investments
(21, '2024-07-01', 4.0, 5.0, 3.5, 4.0, 'Medium'),
(22, '2025-02-01', 3.5, 4.5, 3.0, 3.5, 'Low'),

-- Higher risk assessments
(4,  '2024-11-01', 7.5, 6.0, 5.5, 7.0, 'High'),
(9,  '2024-06-15', 5.0, 4.5, 6.0, 7.5, 'High'),
(16, '2024-08-20', 6.5, 7.5, 5.0, 6.0, 'High');

-- ============================================================================
-- PERFORMANCE_RECORD DATA (tracking investment performance over time)
-- ============================================================================
INSERT INTO PERFORMANCE_RECORD (Investment_ID, Valuation_Date, Current_Valuation, Investment_Value, Return_Multiple, ROI_Percentage, Unrealized_Gain_Loss, Status) VALUES
-- PayFast India (Investor: Sequoia - Series A)
(1,  '2024-06-01', 35000000.00,  25000000.00,  1.40,   40.00,   10000000.00,  'Active'),
(1,  '2025-01-01', 42000000.00,  25000000.00,  1.68,   68.00,   17000000.00,  'Active'),

-- PayFast India (Investor: Rajesh - Seed)
(2,  '2024-06-01', 4200000.00,   2000000.00,   2.10,   110.00,  2200000.00,   'Active'),
(2,  '2025-01-01', 5250000.00,   2000000.00,   2.63,   162.50,  3250000.00,   'Active'),

-- MediScan AI (Investor: Sequoia - Series A)
(6,  '2024-06-01', 35000000.00,  30000000.00,  1.17,   16.67,   5000000.00,   'Active'),
(6,  '2025-01-01', 40000000.00,  30000000.00,  1.33,   33.33,   10000000.00,  'Active'),

-- NeuralWorks (Investor: Sequoia - Series B)
(13, '2024-06-01', 100000000.00, 80000000.00,  1.25,   25.00,   20000000.00,  'Active'),
(13, '2025-01-01', 130000000.00, 80000000.00,  1.63,   62.50,   50000000.00,  'Active'),

-- NeuralWorks (Investor: Tata PE - Series C)
(14, '2025-01-01', 115000000.00, 100000000.00, 1.15,   15.00,   15000000.00,  'Active'),

-- ShopEase (Investor: Tata PE - Series C) - partially exited
(17, '2024-06-01', 200000000.00, 150000000.00, 1.33,   33.33,   50000000.00,  'Active'),
(17, '2025-01-01', 220000000.00, 150000000.00, 1.47,   46.67,   70000000.00,  'Partially Exited'),

-- ShopEase (Investor: Sequoia - Series B)
(18, '2024-06-01', 70000000.00,  50000000.00,  1.40,   40.00,   20000000.00,  'Active'),
(18, '2025-01-01', 80000000.00,  50000000.00,  1.60,   60.00,   30000000.00,  'Active'),

-- SolarGrid Tech (Investor: SIDBI - Series A)
(21, '2024-12-01', 18000000.00,  15000000.00,  1.20,   20.00,   3000000.00,   'Active'),
(21, '2025-03-01', 21000000.00,  15000000.00,  1.40,   40.00,   6000000.00,   'Active'),

-- KrushiMart (Investor: Accel - Series A)
(19, '2025-01-01', 30000000.00,  25000000.00,  1.20,   20.00,   5000000.00,   'Active'),

-- HealthBridge (Investor: Priya - Pre-Seed) - written off example
(9,  '2024-12-01', 500000.00,    1000000.00,   0.50,   -50.00,  -500000.00,   'Active');

-- ============================================================================
-- SEED DATA SUMMARY
-- ============================================================================
-- Total Records Inserted:
--   SECTOR:             6 records
--   INVESTOR:          12 records
--   STARTUP:           15 records
--   INVESTMENT:        22 records
--   FINANCIAL_DATA:    22 records
--   RISK_ASSESSMENT:   16 records
--   PERFORMANCE_RECORD: 17 records
--   TOTAL:             110 records across all tables
-- ============================================================================
