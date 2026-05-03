-- ============================================================================
-- STARTUP INVESTMENT ANALYSIS AND MANAGEMENT SYSTEM
-- Triggers (PL/SQL Automation)
-- ============================================================================
-- Triggers are automatic actions executed BEFORE or AFTER DML operations
-- (INSERT, UPDATE, DELETE). They enforce business rules without requiring
-- application-level code, ensuring data integrity at the database level.
-- ============================================================================

USE startup_investment_db;

-- ============================================================================
-- TRIGGER 1: EQUITY VALIDATION TRIGGER (BEFORE INSERT)
-- ============================================================================
-- Purpose: Prevents total equity allocation for a startup from exceeding 100%.
-- When: Fires BEFORE a new investment is inserted.
-- Logic: Sums existing equity for the target startup, adds the new equity,
--        and rejects the INSERT with an error if total > 100%.
-- Business Rule: No startup can give away more than 100% equity.
-- ============================================================================

DELIMITER //

CREATE TRIGGER trg_validate_equity
BEFORE INSERT ON INVESTMENT
FOR EACH ROW
BEGIN
    DECLARE current_total_equity DECIMAL(5,2);

    -- Calculate total equity already allocated for this startup
    SELECT COALESCE(SUM(Equity_Percentage), 0)
    INTO current_total_equity
    FROM INVESTMENT
    WHERE Startup_ID = NEW.Startup_ID;

    -- Check if adding new equity would exceed 100%
    IF (current_total_equity + NEW.Equity_Percentage) > 100.00 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERROR: Total equity allocation would exceed 100%. Investment rejected.';
    END IF;
END //

DELIMITER ;


-- ============================================================================
-- TRIGGER 2: EQUITY VALIDATION ON UPDATE (BEFORE UPDATE)
-- ============================================================================
-- Purpose: Similar to Trigger 1, but validates equity when an existing
--          investment's equity percentage is modified.
-- ============================================================================

DELIMITER //

CREATE TRIGGER trg_validate_equity_update
BEFORE UPDATE ON INVESTMENT
FOR EACH ROW
BEGIN
    DECLARE current_total_equity DECIMAL(5,2);

    -- Calculate total equity excluding the current investment being updated
    SELECT COALESCE(SUM(Equity_Percentage), 0)
    INTO current_total_equity
    FROM INVESTMENT
    WHERE Startup_ID = NEW.Startup_ID
      AND Investment_ID != NEW.Investment_ID;

    -- Check if updated equity would exceed 100%
    IF (current_total_equity + NEW.Equity_Percentage) > 100.00 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERROR: Updated equity would exceed 100%. Modification rejected.';
    END IF;
END //

DELIMITER ;


-- ============================================================================
-- TRIGGER 3: AUTO ROI CALCULATION (BEFORE INSERT on PERFORMANCE_RECORD)
-- ============================================================================
-- Purpose: Automatically calculates Return Multiple, ROI Percentage, and
--          Unrealized Gain/Loss when a performance record is inserted.
-- When: BEFORE INSERT on PERFORMANCE_RECORD.
-- Logic:
--   Return_Multiple = Current_Valuation / Investment_Value
--   ROI_Percentage  = ((Current_Valuation - Investment_Value) / Investment_Value) * 100
--   Unrealized_Gain = Current_Valuation - Investment_Value
-- ============================================================================

DELIMITER //

CREATE TRIGGER trg_calculate_roi
BEFORE INSERT ON PERFORMANCE_RECORD
FOR EACH ROW
BEGIN
    -- Auto-calculate Return Multiple
    IF NEW.Investment_Value > 0 THEN
        SET NEW.Return_Multiple = ROUND(NEW.Current_Valuation / NEW.Investment_Value, 2);
        SET NEW.ROI_Percentage = ROUND(
            ((NEW.Current_Valuation - NEW.Investment_Value) / NEW.Investment_Value) * 100, 2
        );
    ELSE
        SET NEW.Return_Multiple = 0.00;
        SET NEW.ROI_Percentage = 0.00;
    END IF;

    -- Auto-calculate Unrealized Gain/Loss
    SET NEW.Unrealized_Gain_Loss = NEW.Current_Valuation - NEW.Investment_Value;
END //

DELIMITER ;


-- ============================================================================
-- TRIGGER 4: ROI RECALCULATION ON UPDATE (BEFORE UPDATE)
-- ============================================================================
-- Purpose: Recalculates ROI metrics when performance records are updated.
-- ============================================================================

DELIMITER //

CREATE TRIGGER trg_recalculate_roi
BEFORE UPDATE ON PERFORMANCE_RECORD
FOR EACH ROW
BEGIN
    IF NEW.Investment_Value > 0 THEN
        SET NEW.Return_Multiple = ROUND(NEW.Current_Valuation / NEW.Investment_Value, 2);
        SET NEW.ROI_Percentage = ROUND(
            ((NEW.Current_Valuation - NEW.Investment_Value) / NEW.Investment_Value) * 100, 2
        );
    END IF;
    SET NEW.Unrealized_Gain_Loss = NEW.Current_Valuation - NEW.Investment_Value;
END //

DELIMITER ;


-- ============================================================================
-- TRIGGER 5: NET INCOME AUTO-CALCULATION (BEFORE INSERT on FINANCIAL_DATA)
-- ============================================================================
-- Purpose: Automatically calculates Net_Income = Revenue - Expenses
--          when a financial record is inserted, ensuring consistency.
-- ============================================================================

DELIMITER //

CREATE TRIGGER trg_calculate_net_income
BEFORE INSERT ON FINANCIAL_DATA
FOR EACH ROW
BEGIN
    SET NEW.Net_Income = NEW.Revenue - NEW.Expenses;

    -- Auto-calculate ARR from MRR if ARR is not provided
    IF NEW.ARR = 0.00 AND NEW.MRR > 0 THEN
        SET NEW.ARR = NEW.MRR * 12;
    END IF;
END //

DELIMITER ;


-- ============================================================================
-- TRIGGER 6: INVESTOR CAPITAL UPDATE (AFTER INSERT on INVESTMENT)
-- ============================================================================
-- Purpose: Automatically reduces the investor's available capital after
--          a new investment is recorded. This maintains synchronization
--          between the INVESTMENT and INVESTOR tables.
-- ============================================================================

DELIMITER //

CREATE TRIGGER trg_update_investor_capital
AFTER INSERT ON INVESTMENT
FOR EACH ROW
BEGIN
    UPDATE INVESTOR
    SET Capital_Available = Capital_Available - NEW.Investment_Amount
    WHERE Investor_ID = NEW.Investor_ID;
END //

DELIMITER ;


-- ============================================================================
-- TRIGGER SUMMARY
-- ============================================================================
-- Total Triggers: 6
--
-- | #  | Trigger Name                  | Table              | Timing        | Event  |
-- |----|-------------------------------|--------------------|---------------|--------|
-- | 1  | trg_validate_equity           | INVESTMENT         | BEFORE INSERT | INSERT |
-- | 2  | trg_validate_equity_update    | INVESTMENT         | BEFORE UPDATE | UPDATE |
-- | 3  | trg_calculate_roi             | PERFORMANCE_RECORD | BEFORE INSERT | INSERT |
-- | 4  | trg_recalculate_roi           | PERFORMANCE_RECORD | BEFORE UPDATE | UPDATE |
-- | 5  | trg_calculate_net_income      | FINANCIAL_DATA     | BEFORE INSERT | INSERT |
-- | 6  | trg_update_investor_capital   | INVESTMENT         | AFTER INSERT  | INSERT |
--
-- Business Rules Enforced:
--   1. Equity never exceeds 100% per startup
--   2. ROI metrics are always accurately calculated
--   3. Financial metrics remain internally consistent
--   4. Investor capital is automatically synchronized
-- ============================================================================
