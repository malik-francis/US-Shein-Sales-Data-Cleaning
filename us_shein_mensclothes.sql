SELECT 
    *
FROM
    us_shein_mensclothes
ORDER BY 1 ASC;

# Lets clean up the columns a bit and standardize what we can.

UPDATE us_shein_mensclothes 
SET 
    goods_title_link = TRIM(goods_title_link),
    selling_proposition = TRIM(selling_proposition),
    rank_title = TRIM(rank_title),
    rank_sub = TRIM(rank_sub);

UPDATE us_shein_mensclothes 
SET 
    price = REPLACE(price, '$', '');

UPDATE us_shein_mensclothes 
SET 
    price = NULL
WHERE
    price = '' OR price IS NULL;

ALTER TABLE us_shein_mensclothes
MODIFY price DECIMAL(10,2);

UPDATE us_shein_mensclothes 
SET 
    discount = REPLACE(discount, '%', '');

UPDATE us_shein_mensclothes 
SET 
    discount = NULL
WHERE
    discount = '' OR price IS NULL;

ALTER TABLE us_shein_mensclothes
MODIFY discount INT;

UPDATE us_shein_mensclothes
SET discount = 0
WHERE discount IS NULL OR discount = '';

# Now we want to work on standardizing the selling_proposition information into an integer format.

ALTER TABLE us_shein_mensclothes ADD COLUMN sold_recently INT;

UPDATE us_shein_mensclothes 
SET 
    sold_recently = CASE
        WHEN
            selling_proposition LIKE '%k+%'
        THEN
            CAST(REPLACE(SUBSTRING_INDEX(selling_proposition, 'k+', 1),
                    '+',
                    '')
                AS DECIMAL (5 , 2 )) * 1000
        WHEN
            selling_proposition LIKE '%+ sold recently%'
        THEN
            CAST(REPLACE(SUBSTRING_INDEX(selling_proposition, '+', 1),
                    '+',
                    '')
                AS UNSIGNED)
        ELSE NULL
    END;


# Lets take a look at rank and status to organize that some more.

ALTER TABLE us_shein_mensclothes
  ADD COLUMN rank_number INT,
  ADD COLUMN rank_status VARCHAR(50);
  
UPDATE us_shein_mensclothes
SET
  rank_number = CASE
    WHEN rank_title REGEXP '^#[0-9]+' THEN  -- Only process valid formats like "#8 Best Seller"
      CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(rank_title, ' ', 1), '#', -1) AS UNSIGNED)
    ELSE NULL
  END,
  rank_status = CASE
    WHEN rank_title REGEXP '^#[0-9]+' THEN
      TRIM(SUBSTRING(rank_title, LOCATE(' ', rank_title) + 1))
    ELSE NULL
  END;

UPDATE us_shein_mensclothes
SET rank_title = NULL
WHERE LENGTH(rank_title) = 0;

# With this, the data should be cleaned up and standardized. Now it is ready for analysis.









