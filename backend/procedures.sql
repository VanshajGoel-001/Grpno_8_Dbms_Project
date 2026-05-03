-- ============================================================================
-- STARTUP INVESTMENT ANALYSIS AND MANAGEMENT SYSTEM
-- Stored Procedures (PL/SQL - Procedural Logic)
-- ============================================================================
-- Stored Procedures are precompiled SQL programs stored in the database.
-- They encapsulate complex business logic, improve performance through
-- pre-compilation, and provide a clean interface for application code.
-- ============================================================================

USE startup_investment_db;

-- ============================================================================
-- PROCEDURE 1: RECORD NEW INVESTMENT (with Equity Validation)
-- ============================================================================
-- Purpose: Records a new investment with built-in validation.
-- Parameters: IN - investor_id, startup_id, amount, equity, round, security
--             OUT - result_message (success/failure message)
-- Logic:
--   1. Validates investor exists and has sufficient capital
--   2. Validates startup exists
--   3. Checks equity limit won't be exceeded
--   4. Inserts investment record
--   5. Returns confirmation message
-- Uses: SAVEPOINT for partial rollback capability
-- ============================================================================

DELIMITER //

CREATE PROCEDURE sp_record_investment(
    IN p_investor_id    INT,
    IN p_startup_id     INT,
    IN p_amount         DECIMAL(15,2),
    IN p_equity         DECIMAL(5,2),
    IN p_funding_round  VARCHAR(20),
    IN p_security_type  VARCHAR(20),
    OUT p_result        VARCHAR(255)
)
BEGIN
    DECLARE v_available_capital DECIMAL(15,2);
    DECLARE v_current_equity    DECIMAL(5,2);
    DECLARE v_investor_name     VARCHAR(100);
    DECLARE v_startup_name      VARCHAR(150);

    -- Error handler
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_result = 'ERROR: Transaction failed. Investment not recorded.';
    END;

    START TRANSACTION;

    -- Step 1: Validate Investor exists and check capital
    SELECT Name, Capital_Available
    INTO v_investor_name, v_available_capital
    FROM INVESTOR
    WHERE Investor_ID = p_investor_id;

    IF v_investor_name IS NULL THEN
        SET p_result = 'ERROR: Investor not found.';
        ROLLBACK;
    ELSEIF v_available_capital < p_amount THEN
        SET p_result = CONCAT('ERROR: Insufficient capital. Available: ₹', 
        FORMAT(v_available_capital, 2));
        ROLLBACK;
    ELSE
        -- Step 2: Validate Startup exists
        SELECT Name INTO v_startup_name
        FROM STARTUP
        WHERE Startup_ID = p_startup_id;

        IF v_startup_name IS NULL THEN
            SET p_result = 'ERROR: Startup not found.';
            ROLLBACK;
        ELSE
            -- Step 3: Create SAVEPOINT before equity check
            SAVEPOINT before_equity_check;

            -- Check current equity allocation
            SELECT COALESCE(SUM(Equity_Percentage), 0)
            INTO v_current_equity
            FROM INVESTMENT
            WHERE Startup_ID = p_startup_id;

            IF (v_current_equity + p_equity) > 100.00 THEN
                -- Rollback to savepoint (equity exceeded)
                ROLLBACK TO SAVEPOINT before_equity_check;
                SET p_result = CONCAT('ERROR: Equity limit exceeded. Current: ',
                               v_current_equity, '%, Requested: ', p_equity, '%');
                ROLLBACK;
            ELSE
                -- Step 4: Insert the investment
                INSERT INTO INVESTMENT (
                    Investor_ID, Startup_ID, Investment_Amount,
                    Equity_Percentage, Investment_Date, Funding_Round, Security_Type
                ) VALUES (
                    p_investor_id, p_startup_id, p_amount,
                    p_equity, CURDATE(), p_funding_round, p_security_type
                );

                COMMIT;
                SET p_result = CONCAT('SUCCESS: ₹', FORMAT(p_amount, 2),
                               ' invested in ', v_startup_name,
                               ' by ', v_investor_name,
                               '. Equity: ', p_equity, '%');
            END IF;
        END IF;
    END IF;
END //

DELIMITER ;


-- ============================================================================
-- PROCEDURE 2: CALCULATE PORTFOLIO VALUE FOR AN INVESTOR
-- ============================================================================
-- Purpose: Computes the total portfolio value for a specific investor
--          by summing the latest performance records of all investments.
-- Uses: Multi-table JOINs, Aggregate functions (SUM), Subqueries
-- ============================================================================

DELIMITER //

CREATE PROCEDURE sp_calculate_portfolio_value(
    IN p_investor_id INT,
    OUT p_total_invested DECIMAL(15,2),
    OUT p_current_value  DECIMAL(15,2),
    OUT p_total_roi      DECIMAL(8,2),
    OUT p_investment_count INT
)
BEGIN
    -- Count investments
    SELECT COUNT(*)
    INTO p_investment_count
    FROM INVESTMENT
    WHERE Investor_ID = p_investor_id;

    -- Calculate total amount invested
    SELECT COALESCE(SUM(Investment_Amount), 0)
    INTO p_total_invested
    FROM INVESTMENT
    WHERE Investor_ID = p_investor_id;

    -- Calculate current portfolio value from latest performance records
    SELECT COALESCE(SUM(pr.Current_Valuation), 0)
    INTO p_current_value
    FROM PERFORMANCE_RECORD pr
    INNER JOIN (
        -- Subquery: Get the latest performance record for each investment
        SELECT Investment_ID, MAX(Valuation_Date) AS Latest_Date
        FROM PERFORMANCE_RECORD
        GROUP BY Investment_ID
    ) latest ON pr.Investment_ID = latest.Investment_ID
            AND pr.Valuation_Date = latest.Latest_Date
    INNER JOIN INVESTMENT i ON pr.Investment_ID = i.Investment_ID
    WHERE i.Investor_ID = p_investor_id;

    -- Calculate overall ROI
    IF p_total_invested > 0 THEN
        SET p_total_roi = ROUND(
            ((p_current_value - p_total_invested) / p_total_invested) * 100, 2
        );
    ELSE
        SET p_total_roi = 0.00;
    END IF;
END //

DELIMITER ;


-- ============================================================================
-- PROCEDURE 3: GENERATE ROI REPORT (Investor Portfolio Report)
-- ============================================================================
-- Purpose: Generates a detailed ROI report for a specific investor,
--          showing each investment with its current performance.
-- Uses: Multi-table JOINs (4 tables), GROUP BY, ORDER BY
-- ============================================================================

DELIMITER //

CREATE PROCEDURE sp_generate_roi_report(
    IN p_investor_id INT
)
BEGIN
    SELECT
        i.Investment_ID,
        s.Name AS Startup_Name,
        sec.Sector_Name,
        i.Investment_Amount,
        i.Equity_Percentage,
        i.Funding_Round,
        i.Investment_Date,
        pr.Current_Valuation,
        pr.Return_Multiple,
        pr.ROI_Percentage,
        pr.Unrealized_Gain_Loss,
        pr.Status,
        ra.Overall_Rating AS Risk_Level
    FROM INVESTMENT i
    -- JOIN with Startup to get startup details
    INNER JOIN STARTUP s ON i.Startup_ID = s.Startup_ID
    -- JOIN with Sector to get sector info
    INNER JOIN SECTOR sec ON s.Sector_ID = sec.Sector_ID
    -- LEFT JOIN with latest Performance Record
    LEFT JOIN (
        SELECT pr1.*
        FROM PERFORMANCE_RECORD pr1
        INNER JOIN (
            SELECT Investment_ID, MAX(Valuation_Date) AS MaxDate
            FROM PERFORMANCE_RECORD
            GROUP BY Investment_ID
        ) pr2 ON pr1.Investment_ID = pr2.Investment_ID
             AND pr1.Valuation_Date = pr2.MaxDate
    ) pr ON i.Investment_ID = pr.Investment_ID
    -- LEFT JOIN with latest Risk Assessment
    LEFT JOIN (
        SELECT ra1.*
        FROM RISK_ASSESSMENT ra1
        INNER JOIN (
            SELECT Investment_ID, MAX(Assessment_Date) AS MaxDate
            FROM RISK_ASSESSMENT
            GROUP BY Investment_ID
        ) ra2 ON ra1.Investment_ID = ra2.Investment_ID
             AND ra1.Assessment_Date = ra2.MaxDate
    ) ra ON i.Investment_ID = ra.Investment_ID
    WHERE i.Investor_ID = p_investor_id
    ORDER BY pr.ROI_Percentage DESC;
END //

DELIMITER ;


-- ============================================================================
-- PROCEDURE 4: SECTOR ANALYSIS REPORT
-- ============================================================================
-- Purpose: Generates sector-wise performance analysis showing total
--          investments, average ROI, and startup counts per sector.
-- Uses: Multi-table JOINs, GROUP BY, Aggregate functions (SUM, AVG, COUNT)
-- ============================================================================

DELIMITER //

CREATE PROCEDURE sp_sector_analysis()
BEGIN
    SELECT
        sec.Sector_Name,
        sec.Market_Volatility_Index,
        COUNT(DISTINCT s.Startup_ID) AS Total_Startups,
        COUNT(DISTINCT i.Investment_ID) AS Total_Investments,
        COALESCE(SUM(i.Investment_Amount), 0) AS Total_Capital_Invested,
        COALESCE(AVG(i.Equity_Percentage), 0) AS Avg_Equity_Per_Deal,
        COALESCE(AVG(pr.ROI_Percentage), 0) AS Avg_ROI,
        COALESCE(MAX(pr.ROI_Percentage), 0) AS Best_ROI,
        COALESCE(MIN(pr.ROI_Percentage), 0) AS Worst_ROI
    FROM SECTOR sec
    LEFT JOIN STARTUP s ON sec.Sector_ID = s.Sector_ID
    LEFT JOIN INVESTMENT i ON s.Startup_ID = i.Startup_ID
    LEFT JOIN (
        SELECT pr1.*
        FROM PERFORMANCE_RECORD pr1
        INNER JOIN (
            SELECT Investment_ID, MAX(Valuation_Date) AS MaxDate
            FROM PERFORMANCE_RECORD
            GROUP BY Investment_ID
        ) pr2 ON pr1.Investment_ID = pr2.Investment_ID
             AND pr1.Valuation_Date = pr2.MaxDate
    ) pr ON i.Investment_ID = pr.Investment_ID
    GROUP BY sec.Sector_ID, sec.Sector_Name, sec.Market_Volatility_Index
    ORDER BY Total_Capital_Invested DESC;
END //

DELIMITER ;


-- ============================================================================
-- PROCEDURE 5: UPDATE STARTUP FINANCIAL METRICS
-- ============================================================================
-- Purpose: Updates startup's revenue and valuation based on latest
--          financial data, ensuring the STARTUP table stays current.
-- Uses: Subquery, UPDATE with JOIN
-- ============================================================================

DELIMITER //

CREATE PROCEDURE sp_update_startup_metrics(
    IN p_startup_id INT
)
BEGIN
    DECLARE v_latest_revenue DECIMAL(15,2);
    DECLARE v_latest_arr     DECIMAL(15,2);

    -- Get the latest financial data for the startup
    SELECT Revenue, ARR
    INTO v_latest_revenue, v_latest_arr
    FROM FINANCIAL_DATA
    WHERE Startup_ID = p_startup_id
    ORDER BY Reporting_Period DESC
    LIMIT 1;

    -- Update the startup record with latest metrics
    UPDATE STARTUP
    SET Revenue = v_latest_revenue
    WHERE Startup_ID = p_startup_id;

    SELECT CONCAT('Startup ID ', p_startup_id,
                  ' updated. Latest Revenue: ₹', FORMAT(v_latest_revenue, 2),
                  ', Latest ARR: ₹', FORMAT(v_latest_arr, 2)) AS Result;
END //

DELIMITER ;


-- ============================================================================
-- STORED PROCEDURES SUMMARY
-- ============================================================================
-- | #  | Procedure Name              | Purpose                              |
-- |----|----------------------------|--------------------------------------|
-- | 1  | sp_record_investment       | Record investment with validations   |
-- | 2  | sp_calculate_portfolio_value | Calculate investor portfolio value |
-- | 3  | sp_generate_roi_report     | Detailed ROI report per investor     |
-- | 4  | sp_sector_analysis         | Sector-wise performance analysis     |
-- | 5  | sp_update_startup_metrics  | Sync startup with financial data     |
--
-- Key DBMS Concepts Demonstrated:
--   - IN/OUT Parameters
--   - DECLARE variables
--   - START TRANSACTION, COMMIT, ROLLBACK
--   - SAVEPOINT for partial rollback
--   - EXIT HANDLER for error management
--   - Multi-table JOINs and Subqueries
--   - Aggregate Functions (SUM, AVG, COUNT, MAX, MIN)
-- ============================================================================
