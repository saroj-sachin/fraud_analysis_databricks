--- 1. Total Transactions and Fraud Rate
SELECT 
  COUNT(*) AS total_transactions,
  SUM(isFraud) AS fraud_count,
  ROUND(AVG(isFraud) * 100, 2) AS fraud_rate
FROM workspace.default.fraud_dataset;

--- 2. Fraud Distribution by Transaction Type:
SELECT
  type AS transaction_type,
  COUNT(*) AS total_transactions,
  SUM(isFraud) AS fraud_count,
  ROUND(fraud_count / COUNT(*) * 100, 2) AS fraud_rate_pct
FROM workspace.default.fraud_dataset
GROUP BY type
ORDER BY fraud_count DESC;

--- 3. Are high-value transactions riskier?
SELECT 
    CASE 
        WHEN amount > 200000 THEN 'High'
        ELSE 'Normal'
    END AS amount_bucket,
    COUNT(*) AS total_txns,
    SUM(isFraud) AS fraud_count,
    ROUND(100.0 * SUM(isFraud) / COUNT(*), 2) AS fraud_rate
FROM fraud_dataset
GROUP BY amount_bucket;

--- 4. Do fraud transactions drain accounts?
SELECT 
    CASE 
        WHEN newbalanceOrig = 0 THEN 'Drained'
        ELSE 'Not Drained'
    END AS account_status,
    COUNT(*) AS total_txns,
    SUM(isFraud) AS fraud_count
FROM fraud_dataset
GROUP BY account_status;

--- 5. Fraud rate in suspicious transactions
SELECT 
    CASE 
        WHEN oldbalanceOrg - newbalanceOrig != amount THEN 'Anomaly'
        ELSE 'Normal'
    END AS txn_type,
    COUNT(*) AS total_txns,
    SUM(isFraud) AS fraud_count
FROM fraud_dataset
GROUP BY txn_type;

--- 6. Fraud by transaction sequence
SELECT COUNT(*) 
FROM fraud_dataset
WHERE type IN ('TRANSFER', 'CASH_OUT')
AND isFraud = 1;

--- 7. Fraud by hour of day
SELECT 
    step % 24 AS hour,
    COUNT(*) AS total_txns,
    SUM(isFraud) AS fraud_count
FROM fraud_dataset
GROUP BY hour
ORDER BY hour;

--- 9. Most suspicious customers
SELECT 
    nameOrig,
    COUNT(*) AS txn_count,
    SUM(isFraud) AS fraud_count
FROM fraud_dataset
GROUP BY nameOrig
HAVING fraud_count > 0
ORDER BY fraud_count DESC
LIMIT 10;

--- 10. Customers with highest transaction volume
SELECT 
    nameOrig,
    SUM(amount) AS total_amount
FROM fraud_dataset
GROUP BY nameOrig
ORDER BY total_amount DESC
LIMIT 10;

--- 11. Fraud by destination account
SELECT 
    nameDest,
    COUNT(*) AS txn_count,
    SUM(isFraud) AS fraud_count
FROM fraud_dataset
GROUP BY nameDest
HAVING fraud_count > 0
ORDER BY fraud_count DESC
LIMIT 10;

--- 12. Are there frauds below the 200k threshold?
SELECT COUNT(*)
FROM fraud_dataset
WHERE isFraud = 1 AND amount < 200000;