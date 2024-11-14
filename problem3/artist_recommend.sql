-- 1. Drop existing tables and indexes
DROP TABLE IF EXISTS friend CASCADE;
DROP TABLE IF EXISTS like_table CASCADE;
DROP TABLE IF EXISTS symmetric_friends CASCADE;
DROP INDEX IF EXISTS idx_friend_p1;
DROP INDEX IF EXISTS idx_friend_p2;
DROP INDEX IF EXISTS idx_like_person;
DROP INDEX IF EXISTS idx_like_artist;
DROP INDEX IF EXISTS idx_sym_friends;
\timing on
CREATE TABLE friend (
    person1 INTEGER,
    person2 INTEGER
);
CREATE TABLE like_table (
    person INTEGER,
    artist INTEGER
);

-- 2. Import data from CSV files
\COPY friend FROM 'friends.csv' WITH (FORMAT csv, HEADER true)
\COPY like_table FROM 'like.csv' WITH (FORMAT csv, HEADER true)

-- 3. Create basic indexes for performance
CREATE INDEX idx_friend_p1 ON friend(person1);
CREATE INDEX idx_friend_p2 ON friend(person2);
CREATE INDEX idx_like_person ON like_table(person);
CREATE INDEX idx_like_artist ON like_table(artist);

-- 4. Create temporary table for symmetric friendship relationships
CREATE TEMP TABLE symmetric_friends AS
SELECT person1 as person, person2 as friend
FROM friend
UNION
SELECT person2 as person, person1 as friend
FROM friend;

CREATE INDEX idx_sym_friends ON symmetric_friends(person, friend);

-- 5. Analyze query execution plan
EXPLAIN ANALYZE
SELECT DISTINCT f.person as u1, f.friend as u2, l.artist as a
FROM symmetric_friends f
JOIN like_table l ON f.friend = l.person
WHERE NOT EXISTS (
    SELECT 1
    FROM like_table l2
    WHERE l2.person = f.person
    AND l2.artist = l.artist
)
ORDER BY u1, u2, a;
-- 6. Main query: Export results to CSV
--\COPY (SELECT DISTINCT f.person as u1, f.friend as u2, l.artist as a FROM symmetric_friends f JOIN like_table l ON f.friend = l.person WHERE NOT EXISTS (SELECT 1 FROM like_table l2 WHERE l2.person = f.person AND l2.artist = l.artist) ORDER BY u1, u2, a) TO 'recommendations.csv' WITH (FORMAT csv, HEADER true)
