-- ============================================================================
-- STARTUP INVESTMENT ANALYSIS AND MANAGEMENT SYSTEM
-- Database Schema (DDL - Data Definition Language)
-- ============================================================================
-- Course: UCS310 - Database Management Systems
-- Institute: Thapar Institute of Engineering and Technology, Patiala
-- Session: Jan-May 2026
-- ============================================================================
-- This file contains all CREATE TABLE statements (DDL) for the 7 normalized
-- tables in our investment management database. Each table is in 3NF.
-- ============================================================================

-- Create the database
CREATE DATABASE IF NOT EXISTS startup_investment_db;
USE startup_investment_db;

-- ============================================================================
-- TABLE 1: INVESTOR
-- Stores information about individual and institutional investors.
-- Each investor is uniquely identified by Investor_ID (AUTO_INCREMENT).
-- Normalization: All attributes are atomic (1NF), fully dependent on PK (2NF),
-- and no transitive dependencies exist (3NF).
-- -----------------------------------------------------------------------------

CREATE TABLE INVESTOR (
    Investor_ID     INT             AUTO_INCREMENT,
    Name            VARCHAR(100)    NOT NULL,
    Type  ENUM('Angel', 'Venture Capital', 'Private Equity', 'Corporate', 'Government') NOT NULL DEFAULT 'Angel',
    Email VARCHAR(150)    NOT NULL,
    Phone  VARCHAR(20),
    Capital_Available DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    Risk_Preference ENUM('Conservative', 'Moderate', 'Aggressive') NOT NULL DEFAULT 'Moderate',
    Registration_Date DATE  NOT NULL,
    CONSTRAINT pk_investor          PRIMARY KEY (Investor_ID),
    CONSTRAINT uq_investor_email    UNIQUE (Email),
    CONSTRAINT chk_capital          CHECK (Capital_Available >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================================
-- TABLE 2: SECTOR
-- ============================================================================
-- Classifies startups into industry sectors.
-- The Market_Volatility_Index (0.00 to 10.00) helps assess sector risk.
-- Cardinality: One sector contains MANY startups (1:M relationship).
-- -=----------------------------------------------------------------
CREATE TABLE SECTOR (
    Sector_ID INT  AUTO_INCREMENT,
    Sector_Name   VARCHAR(100)    NOT NULL,
    Description  TEXT,
    Market_Volatility_Index DECIMAL(4,2)    NOT NULL DEFAULT 5.00,
    CONSTRAINT pk_sector     PRIMARY KEY (Sector_ID),
    CONSTRAINT uq_sector_name  UNIQUE (Sector_Name),
    CONSTRAINT chk_volatility CHECK (Market_Volatility_Index BETWEEN 0.00 AND 10.00)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ============================================================================
-- TABLE 3: STARTUP
-- ============================================================================
-- Stores detailed profiles of startups seeking or receiving investment.
-- References SECTOR via Foreign Key (Sector_ID) to classify the startup.
-- Current_Stage tracks the lifecycle phase of the startup.
-- Normalization: Sector details are NOT stored here (3NF - no transitive deps).
-- ==--------------------------------------------------------------------------------


CREATE TABLE STARTUP (
    Startup_ID      INT             AUTO_INCREMENT,
    Name            VARCHAR(150)    NOT NULL,
    Sector_ID       INT             NOT NULL,
    Founding_Year   YEAR            NOT NULL,
    Current_Stage   ENUM('Idea', 'MVP', 'Early Traction', 'Growth', 'Expansion', 'Mature') NOT NULL DEFAULT 'Idea',
    Revenue         DECIMAL(15,2)   DEFAULT 0.00,
    Valuation       DECIMAL(15,2)   DEFAULT 0.00,
    Employee_Count  INT             DEFAULT 0,
    Location        VARCHAR(100),
    Website         VARCHAR(255),
    Founded_Date    DATE,

    CONSTRAINT pk_startup           PRIMARY KEY (Startup_ID),
    CONSTRAINT fk_startup_sector    FOREIGN KEY (Sector_ID)  REFERENCES SECTOR(Sector_ID)  ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_revenue          CHECK (Revenue >= 0),
    CONSTRAINT chk_valuation        CHECK (Valuation >= 0),
    CONSTRAINT chk_employees        CHECK (Employee_Count >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;



-- ============================================================================
-- TABLE 4: INVESTMENT
-- ============================================================================
-- Records individual investment transactions between investors and startups.
-- This is the central junction table linking INVESTOR and STARTUP.
-- Cardinalities:
--   Investor → Investment: 1:M (one investor, many investments)
--   Startup  → Investment: 1:M (one startup, many investors)
-- Together this creates an M:N relationship resolved through INVESTMENT.
-- --------------------------------------------------------------------------

CREATE TABLE INVESTMENT (
    Investment_ID       INT             AUTO_INCREMENT,
    Investor_ID         INT             NOT NULL,
    Startup_ID          INT             NOT NULL,
    Investment_Amount   DECIMAL(15,2)   NOT NULL,
    Equity_Percentage   DECIMAL(5,2)    NOT NULL,
    Investment_Date     DATE            NOT NULL,
    Funding_Round       ENUM('Pre-Seed', 'Seed', 'Series A', 'Series B', 'Series C', 'Series D', 'IPO') NOT NULL DEFAULT 'Seed',
    Security_Type       ENUM('Equity', 'Convertible Note', 'SAFE', 'Preferred Stock') NOT NULL DEFAULT 'Equity',

    CONSTRAINT pk_investment            PRIMARY KEY (Investment_ID),
    CONSTRAINT fk_investment_investor   FOREIGN KEY (Investor_ID) REFERENCES INVESTOR(Investor_ID) ON UPDATE CASCADE  ON DELETE RESTRICT,
    CONSTRAINT fk_investment_startup    FOREIGN KEY (Startup_ID) REFERENCES STARTUP(Startup_ID) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_amount              CHECK (Investment_Amount > 0),
    CONSTRAINT chk_equity              CHECK (Equity_Percentage > 0 AND Equity_Percentage <= 100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================================
-- TABLE 5: FINANCIAL_DATA
-- ============================================================================
-- Stores periodic financial metrics for each startup.
-- Cardinality: One startup has MANY financial records (1:M by reporting period).
-- Includes key SaaS metrics: MRR (Monthly Recurring Revenue), ARR (Annual),
-- Burn Rate, and Customer Count.
-- Normalization: Startup details are NOT duplicated here (3NF compliant).
-- ============================================================================
CREATE TABLE FINANCIAL_DATA (
    Financial_ID    INT             AUTO_INCREMENT,
    Startup_ID      INT             NOT NULL,
    Reporting_Period VARCHAR(10)    NOT NULL,  
    Revenue         DECIMAL(15,2)   DEFAULT 0.00,
    Expenses        DECIMAL(15,2)   DEFAULT 0.00,
    Net_Income      DECIMAL(15,2)   DEFAULT 0.00,
    Cash_Balance    DECIMAL(15,2)   DEFAULT 0.00,
    Burn_Rate       DECIMAL(15,2)   DEFAULT 0.00,
    Customer_Count  INT             DEFAULT 0,
    MRR             DECIMAL(15,2)   DEFAULT 0.00,  -- Monthly Recurring Revenue
    ARR             DECIMAL(15,2)   DEFAULT 0.00,  -- Annual Recurring Revenue

    CONSTRAINT pk_financial             PRIMARY KEY (Financial_ID),
    CONSTRAINT fk_financial_startup     FOREIGN KEY (Startup_ID) REFERENCES STARTUP(Startup_ID) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT uq_startup_period        UNIQUE (Startup_ID, Reporting_Period),
    CONSTRAINT chk_customer_count       CHECK (Customer_Count >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;




-- ============================================================================
-- TABLE 6: RISK_ASSESSMENT
-- ============================================================================
-- Tracks risk scoring for each investment over time.
-- Cardinality: One investment can have MANY risk assessments (1:M).
-- Scores range from 1 (Low Risk) to 10 (High Risk).
-- Overall_Rating is a weighted composite of individual risk scores.
-- ============================================================================

CREATE TABLE RISK_ASSESSMENT (
    Risk_ID                 INT             AUTO_INCREMENT,
    Investment_ID           INT             NOT NULL,
    Assessment_Date         DATE            NOT NULL,
    Market_Risk_Score       DECIMAL(3,1)    NOT NULL DEFAULT 5.0,
    Technology_Risk_Score   DECIMAL(3,1)    NOT NULL DEFAULT 5.0,
    Management_Risk_Score   DECIMAL(3,1)    NOT NULL DEFAULT 5.0,
    Financial_Risk_Score    DECIMAL(3,1)    NOT NULL DEFAULT 5.0,
    Overall_Rating          ENUM('Low', 'Medium', 'High', 'Critical') NOT NULL DEFAULT 'Medium',

    CONSTRAINT pk_risk                  PRIMARY KEY (Risk_ID),
    CONSTRAINT fk_risk_investment       FOREIGN KEY (Investment_ID) REFERENCES INVESTMENT(Investment_ID) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT chk_market_risk          CHECK (Market_Risk_Score BETWEEN 1.0 AND 10.0),
    CONSTRAINT chk_tech_risk            CHECK (Technology_Risk_Score BETWEEN 1.0 AND 10.0),
    CONSTRAINT chk_mgmt_risk            CHECK (Management_Risk_Score BETWEEN 1.0 AND 10.0),
    CONSTRAINT chk_fin_risk             CHECK (Financial_Risk_Score BETWEEN 1.0 AND 10.0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;



-- ============================================================================
-- TABLE 7: PERFORMANCE_RECORD
-- ============================================================================
-- Tracks the financial performance of each investment over time.
-- Cardinality: One investment has MANY performance snapshots (1:M).
-- Key metrics: Current Valuation, ROI Percentage, Return Multiple.
-- Status tracks whether the investment is Active, Exited, or Written Off.
-- ============================================================================
CREATE TABLE PERFORMANCE_RECORD (
    Record_ID               INT             AUTO_INCREMENT,
    Investment_ID           INT             NOT NULL,
    Valuation_Date          DATE            NOT NULL,
    Current_Valuation       DECIMAL(15,2)   NOT NULL DEFAULT 0.00,
    Investment_Value        DECIMAL(15,2)   NOT NULL DEFAULT 0.00,
    Return_Multiple         DECIMAL(8,2)    DEFAULT 0.00,
    ROI_Percentage          DECIMAL(8,2)    DEFAULT 0.00,
    Unrealized_Gain_Loss    DECIMAL(15,2)   DEFAULT 0.00,
    Status                  ENUM('Active', 'Partially Exited', 'Fully Exited', 'Written Off') NOT NULL DEFAULT 'Active',
    CONSTRAINT pk_performance           PRIMARY KEY (Record_ID),
    CONSTRAINT fk_performance_invest    FOREIGN KEY (Investment_ID) REFERENCES INVESTMENT(Investment_ID) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT chk_current_val          CHECK (Current_Valuation >= 0),
    CONSTRAINT chk_invest_val           CHECK (Investment_Value >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX idx_perf_investment ON PERFORMANCE_RECORD(Investment_ID);
CREATE INDEX idx_perf_date       ON PERFORMANCE_RECORD(Valuation_Date);
CREATE INDEX idx_perf_status     ON PERFORMANCE_RECORD(Status);


-- ============================================================================
-- SCHEMA SUMMARY
-- ============================================================================
-- Total Tables:    7
-- Primary Keys:    7 (one per table, all AUTO_INCREMENT)
-- Foreign Keys:    7 (linking tables through relationships)
-- UNIQUE:          3 (Email, Sector_Name, Startup+Period)
-- CHECK:           14 (data validation constraints)
-- INDEXES:         15 (performance optimization)
-- ENUM Types:      8 (controlled vocabulary for categorical data)
--
-- Entity Relationships:
--   SECTOR  (1:M) > STARTUP
--   INVESTOR (1:M)> INVESTMENT
--   STARTUP (1:M)> INVESTMENT
--   STARTUP (1:M) FINANCIAL_DATA
--   INVESTMENT (1:M) RISK_ASSESSMENT
--   INVESTMENT (1:M) PERFORMANCE_RECORD
-- ============================================================================
