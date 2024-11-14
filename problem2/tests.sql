\echo '=== Starting Performance Test ==='
\timing on

\echo '\n1. Creating Original Tables'
CREATE TABLE trade (
    stocksymbol INTEGER,
    time INTEGER,
    quantity INTEGER,
    price INTEGER
);

CREATE TABLE uniform_trade (
    stocksymbol INTEGER,
    time INTEGER,
    quantity INTEGER,
    price INTEGER
);

\echo '\n2. Importing Data'
COPY trade FROM '/home/yg3370/AQuery2/tests/trades.csv' WITH (FORMAT csv, DELIMITER ',', HEADER);
COPY uniform_trade FROM '/home/yg3370/AQuery2/tests/uniform_trade_data.csv' WITH (FORMAT csv, DELIMITER ',', HEADER);

\echo '\n3. Testing Original Query on Trade'
--EXPLAIN (ANALYZE true, BUFFERS true, FORMAT text) 
SELECT stocksymbol, AVG(price) as avg_price
FROM trade
WHERE stocksymbol = 3456
GROUP BY stocksymbol;

\echo '\n4. Testing Original Query on Uniform Trade'
--EXPLAIN (ANALYZE true, BUFFERS true, FORMAT text) 
SELECT stocksymbol, AVG(price) as avg_price
FROM uniform_trade
WHERE stocksymbol = 3456
GROUP BY stocksymbol;

\echo '\n5. Creating Indexes'
CREATE INDEX idx_trade_symbol ON trade(stocksymbol);
CREATE INDEX idx_uniform_trade_symbol ON uniform_trade(stocksymbol);

\echo '\n6. Testing Query with Index on Trade'
--EXPLAIN (ANALYZE true, BUFFERS true, FORMAT text) 
SELECT stocksymbol, AVG(price) as avg_price
FROM trade
WHERE stocksymbol = 3456
GROUP BY stocksymbol;

\echo '\n7. Testing Query with Index on Uniform Trade'
--EXPLAIN (ANALYZE true, BUFFERS true, FORMAT text) 
SELECT stocksymbol, AVG(price) as avg_price
FROM uniform_trade
WHERE stocksymbol = 3456
GROUP BY stocksymbol;

\echo '\n8. Dropping Indexes'
DROP INDEX idx_trade_symbol;
DROP INDEX idx_uniform_trade_symbol;

\echo '\n9. Creating Split Tables for Trade'
CREATE TABLE trade_0_2m AS
    SELECT stocksymbol, time, quantity, price
    FROM trade
    WHERE time >= 1000 AND time <= 2000000;

CREATE TABLE trade_2m_4m AS
    SELECT stocksymbol, time, quantity, price
    FROM trade
    WHERE time > 2000000 AND time <= 4000000;

CREATE TABLE trade_4m_6m AS
    SELECT stocksymbol, time, quantity, price
    FROM trade
    WHERE time > 4000000 AND time <= 6000000;

CREATE TABLE trade_6m_8m AS
    SELECT stocksymbol, time, quantity, price
    FROM trade
    WHERE time > 6000000 AND time <= 8000000;

CREATE TABLE trade_8m_10m AS
    SELECT stocksymbol, time, quantity, price
    FROM trade
    WHERE time > 8000000 AND time <= 10000000;

\echo '\n10. Creating Split Tables for Uniform Trade'
CREATE TABLE uniform_trade_0_2m AS
    SELECT stocksymbol, time, quantity, price
    FROM uniform_trade
    WHERE time >= 1000 AND time <= 2000000;

CREATE TABLE uniform_trade_2m_4m AS
    SELECT stocksymbol, time, quantity, price
    FROM uniform_trade
    WHERE time > 2000000 AND time <= 4000000;

CREATE TABLE uniform_trade_4m_6m AS
    SELECT stocksymbol, time, quantity, price
    FROM uniform_trade
    WHERE time > 4000000 AND time <= 6000000;

CREATE TABLE uniform_trade_6m_8m AS
    SELECT stocksymbol, time, quantity, price
    FROM uniform_trade
    WHERE time > 6000000 AND time <= 8000000;

CREATE TABLE uniform_trade_8m_10m AS
    SELECT stocksymbol, time, quantity, price
    FROM uniform_trade
    WHERE time > 8000000 AND time <= 10000000;

\echo '\n11. Testing Split Table Query on Trade'
--EXPLAIN (ANALYZE true, BUFFERS true, FORMAT text)
SELECT stocksymbol, AVG(price) as avg_price
FROM (
    SELECT * FROM trade_0_2m WHERE stocksymbol = 3456
    UNION ALL
    SELECT * FROM trade_2m_4m WHERE stocksymbol = 3456
    UNION ALL
    SELECT * FROM trade_4m_6m WHERE stocksymbol = 3456
    UNION ALL
    SELECT * FROM trade_6m_8m WHERE stocksymbol = 3456
    UNION ALL
    SELECT * FROM trade_8m_10m WHERE stocksymbol = 3456
) t
GROUP BY stocksymbol;

\echo '\n12. Testing Split Table Query on Uniform Trade'
--EXPLAIN (ANALYZE true, BUFFERS true, FORMAT text)
SELECT stocksymbol, AVG(price) as avg_price
FROM (
    SELECT * FROM uniform_trade_0_2m WHERE stocksymbol = 3456
    UNION ALL
    SELECT * FROM uniform_trade_2m_4m WHERE stocksymbol = 3456
    UNION ALL
    SELECT * FROM uniform_trade_4m_6m WHERE stocksymbol = 3456
    UNION ALL
    SELECT * FROM uniform_trade_6m_8m WHERE stocksymbol = 3456
    UNION ALL
    SELECT * FROM uniform_trade_8m_10m WHERE stocksymbol = 3456
) t
GROUP BY stocksymbol;

\echo '\n=== Test Complete ==='
