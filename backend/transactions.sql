-- ============================================================================
-- STARTUP INVESTMENT ANALYSIS AND MANAGEMENT SYSTEM
-- Transactions (ACID Properties Demonstration)
-- ============================================================================
-- Transactions are sequences of SQL operations executed as a single logical
-- unit of work. They ensure ACID properties:
--   A - Atomicity:    All operations complete, or none do
--   C - Consistency:  Database moves from one valid state to another
--   I - Isolation:    Concurrent transactions don't interfere
--   D - Durability:   Once committed, changes are permanent
-- ============================================================================

USE startup_investment_db;

-- ============================================================================
-- TRANSACTION 1: INVESTMENT-PORTFOLIO SYNCHRONIZATION
-- ============================================================================
-- Scenario: When recording a new investment, we must ALSO create an initial
--           performance record. Both must succeed or neither should persist.
-- Demonstrates: COMMIT and ROLLBACK for atomicity
-- ============================================================================

-- Successful Transaction Example:
START TRANSACTION;

    -- Step 1: Insert the investment
    INSERT INTO INVESTMENT (
        Investor_ID, Startup_ID, Investment_Amount,
        Equity_Percentage, Investment_Date, Funding_Round, Security_Type
    ) VALUES (
        1, 11, 500000.00, 5.00, '2025-03-15', 'Pre-Seed', 'SAFE'
    );

    -- Step 2: Get the auto-generated Investment_ID
    SET @new_investment_id = LAST_INSERT_ID();

    -- Step 3: Create initial performance record
    INSERT INTO PERFORMANCE_RECORD (
        Investment_ID, Valuation_Date, Current_Valuation,
        Investment_Value, Return_Multiple, ROI_Percentage,
        Unrealized_Gain_Loss, Status
    ) VALUES (
        @new_investment_id, '2025-03-15', 500000.00,
        500000.00, 1.00, 0.00,
        0.00, 'Active'
    );

-- Both inserts succeeded → COMMIT makes changes permanent
COMMIT;

-- In case of error, we would use ROLLBACK:
-- ROLLBACK;  -- This would undo BOTH inserts, maintaining atomicity


-- ============================================================================
-- TRANSACTION 2: EQUITY VALIDATION WITH SAVEPOINT
-- ============================================================================
-- Scenario: Multi-step investment recording where we use SAVEPOINT to
--           temporarily hold data while validating equity constraints.
--           If equity exceeds 100%, we rollback to the savepoint.
-- Demonstrates: SAVEPOINT and ROLLBACK TO SAVEPOINT
-- ============================================================================

START TRANSACTION;

    -- Step 1: Prepare investment data
    SET @target_startup = 4;  -- HealthBridge
    SET @new_equity = 15.00;

    -- Step 2: Create a SAVEPOINT before inserting
    SAVEPOINT before_investment;

    -- Step 3: Check current equity allocation for this startup
    SELECT @current_equity := COALESCE(SUM(Equity_Percentage), 0)
    FROM INVESTMENT
    WHERE Startup_ID = @target_startup;

    -- Step 4: Validate equity constraint
    -- If total equity would exceed 100%, rollback to savepoint
    -- Otherwise, proceed with the investment

    -- Case A: Equity is within limits → Proceed
    -- (HealthBridge currently has 8% equity allocated)
    -- 8% + 15% = 23% (< 100%) → Valid
    INSERT INTO INVESTMENT (
        Investor_ID, Startup_ID, Investment_Amount,
        Equity_Percentage, Investment_Date, Funding_Round, Security_Type
    ) VALUES (
        7, @target_startup, 2000000.00,
        @new_equity, '2025-04-01', 'Seed', 'Equity'
    );

    -- Verify: Show the updated equity allocation
    SELECT
        s.Name AS Startup,
        SUM(i.Equity_Percentage) AS Total_Equity,
        CASE
            WHEN SUM(i.Equity_Percentage) <= 100 THEN 'VALID - Within Limits'
            ELSE 'INVALID - Exceeds 100%'
        END AS Validation_Result
    FROM INVESTMENT i
    JOIN STARTUP s ON i.Startup_ID = s.Startup_ID
    WHERE i.Startup_ID = @target_startup
    GROUP BY s.Name;

COMMIT;


-- ============================================================================
-- TRANSACTION 3: FAILED EQUITY VALIDATION (ROLLBACK EXAMPLE)
-- ============================================================================
-- Scenario: Attempting to invest with too much equity → ROLLBACK
-- This demonstrates what happens when a business rule is violated.
-- ============================================================================

START TRANSACTION;

    SAVEPOINT before_invalid_investment;

    -- Check current equity for ShopEase (Startup_ID = 9)
    -- Current equity: ~26% (18% + 8%)
    SET @target_startup = 9;
    SET @requested_equity = 80.00;  -- This would make total > 100%

    SELECT @current_equity := COALESCE(SUM(Equity_Percentage), 0)
    FROM INVESTMENT
    WHERE Startup_ID = @target_startup;

    -- Equity check: 26% + 80% = 106% → EXCEEDS 100%!
    -- The trigger (trg_validate_equity) would catch this,
    -- but we also demonstrate programmatic rollback:

    -- Since 106% > 100%, we ROLLBACK TO SAVEPOINT
    ROLLBACK TO SAVEPOINT before_invalid_investment;

    -- Log the rejection (in a real system, this would go to an audit table)
    SELECT CONCAT(
        'Investment REJECTED: Equity limit exceeded. ',
        'Current: ', @current_equity, '%, ',
        'Requested: ', @requested_equity, '%, ',
        'Total would be: ', (@current_equity + @requested_equity), '%'
    ) AS Transaction_Result;

ROLLBACK;  -- End the transaction cleanly


-- ============================================================================
-- TRANSACTION 4: BATCH FINANCIAL UPDATE (Multiple Operations)
-- ============================================================================
-- Scenario: Updating multiple financial records for a startup as part
--           of a quarterly reporting cycle. All updates must succeed.
-- Demonstrates: Multiple DML operations within a single transaction
-- ============================================================================

START TRANSACTION;

    -- Update Q1-2026 financial data for PayFast India
    INSERT INTO FINANCIAL_DATA (
        Startup_ID, Reporting_Period, Revenue, Expenses,
        Net_Income, Cash_Balance, Burn_Rate,
        Customer_Count, MRR, ARR
    ) VALUES (
        1, 'Q1-2026', 18000000.00, 9500000.00,
        8500000.00, 70000000.00, 9500000.00,
        30000, 6000000.00, 72000000.00
    );

    -- Update the startup's current revenue
    UPDATE STARTUP
    SET Revenue = 18000000.00
    WHERE Startup_ID = 1;

    -- Update performance records for all active investments in PayFast
    UPDATE PERFORMANCE_RECORD
    SET Current_Valuation = Current_Valuation * 1.15,  -- 15% growth
        Valuation_Date = '2026-03-31'
    WHERE Investment_ID IN (
        SELECT Investment_ID FROM INVESTMENT WHERE Startup_ID = 1
    )
    AND Status = 'Active';

-- All three operations succeeded → COMMIT
COMMIT;


-- ============================================================================
-- TRANSACTION 5: CONCURRENT ACCESS SIMULATION
-- ============================================================================
-- Scenario: Two investors trying to invest in the same startup
--           simultaneously. Demonstrates isolation levels.
-- Note: Run these in separate MySQL sessions to test concurrency.
-- ============================================================================

-- Session 1: Investor A wants 40% equity in FreshBasket (ID=11)
-- START TRANSACTION;
-- SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
-- INSERT INTO INVESTMENT (...) VALUES (..., 40.00, ...);
-- -- Wait before committing to simulate concurrent access
-- -- SELECT SLEEP(5);
-- COMMIT;

-- Session 2: Investor B also wants 70% equity in FreshBasket
-- START TRANSACTION;
-- SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
-- -- This would WAIT until Session 1 completes (SERIALIZABLE isolation)
-- -- Then the equity trigger would reject it (40% + 70% = 110% > 100%)
-- INSERT INTO INVESTMENT (...) VALUES (..., 70.00, ...);
-- COMMIT;


-- ============================================================================
-- TRANSACTION SUMMARY
-- ============================================================================
-- | #  | Transaction                        | Concept Demonstrated              |
-- |----|------------------------------------|------------------------------------|
-- | 1  | Investment-Portfolio Sync          | COMMIT / ROLLBACK (Atomicity)      |
-- | 2  | Equity Validation (Success)        | SAVEPOINT / COMMIT                 |
-- | 3  | Equity Validation (Failure)        | ROLLBACK TO SAVEPOINT              |
-- | 4  | Batch Financial Update             | Multiple DML in one transaction    |
-- | 5  | Concurrent Access                  | Isolation levels (SERIALIZABLE)    |
--
-- ACID Properties Demonstrated:
--   Atomicity:    Transactions 1, 4 (all-or-nothing execution)
--   Consistency:  Transactions 2, 3 (equity constraint maintains valid state)
--   Isolation:    Transaction 5 (concurrent access handled correctly)
--   Durability:   All COMMIT operations (changes survive system failure)
-- ============================================================================
