-- Author: Scott Grivner
-- Website: scottgrivner.dev
-- Abstract: Useful Db2 SQL Queries

-- Check Service Level:
select service_level from sysibmadm.env_inst_info;

-- Create Identifiers:
-- Generate UUID
SELECT  
  (LEFT(TRANSLATE(CHAR(BIGINT(RAND() * 10000000000 )), 'abcdef123456789', '1234567890' ),8) 
  CONCAT '-' 
  CONCAT LEFT(TRANSLATE (CHAR(BIGINT(RAND() * 10000000000 )), 'abcdef123456789', '1234567890' ),4) 
  CONCAT '-' 
  CONCAT LEFT(TRANSLATE ( CHAR(BIGINT(RAND() * 10000000000 )), 'abcdef123456789', '1234567890' ),4) 
  CONCAT '-' 
  CONCAT LEFT(TRANSLATE ( CHAR(BIGINT(RAND() * 10000000000 )), 'abcdef123456789', '1234567890' ),4) 
  CONCAT '-' 
  CONCAT LEFT(TRANSLATE ( CHAR(BIGINT(RAND() * 10000000000000 )), 'abcdef123456789', '1234567890' ),12))
  AS UUID
FROM sysibm.sysdummy1

-- Generate GUID HEX value using GENERATE_UNIQUE() 
SELECT TRIM(CHAR(HEX(GENERATE_UNIQUE()))) AS GUID FROM sysibm.sysdummy1

-- Reference:
-- https://dbfiddle.uk/0RQZ1GR8

-- Date/Time Functions:
-- Select Current Date
SELECT CURRENT_DATE AS CURRENTDATE
FROM   SYSIBM.SYSDUMMY1
FETCH FIRST 1 ROWS ONLY;

-- Select Current Date/Time
SELECT CURRENT_TIMESTAMP
FROM   SYSIBM.SYSDUMMY1;

-- Select Current Date in YYY-MM-DD Format
SELECT CHAR(CURRENT DATE, ISO) AS CURRENTDATE
FROM   SYSIBM.SYSDUMMY1
FETCH FIRST 1 ROWS ONLY;

-- Select Current Date in YYYYMMDD Format
SELECT VARCHAR_FORMAT(CURRENT_DATE, 'YYYYMMDD')
FROM   SYSIBM.SYSDUMMY1;

-- Select Date a Month from Today
SELECT CURRENT DATE + 1 MONTHS
FROM   SYSIBM.SYSDUMMY1;

-- Select Current Day - Day of Week (1-7)
SELECT DAYOFWEEK(CURRENT_TIMESTAMP)
FROM   SYSIBM.SYSDUMMY1;

-- Select Current Week
SELECT VARCHAR_FORMAT(TIMESTAMP_FORMAT(CHAR(CURRENT DATE, ISO), 'YYYYMMDD'),
       'WW') AS
       CURRENT_WEEK
FROM   SYSIBM.SYSDUMMY1;

-- Build YYYY-MM-DD Format with Date Column
SELECT ( SUBSTRING(CHAR(CURRENT_DATE), 1, 4)
         || '-'
         || SUBSTRING(CHAR(CURRENT_DATE), 6, 2)
         || '-'
         || SUBSTRING(CHAR(CURRENT_DATE), 9, 2) ) AS CURRENTDATE
FROM   SYSIBM.SYSDUMMY1
FETCH FIRST 1 ROWS ONLY;

-- Select Date Formats  
SELECT CURRENT DATE,
       MONTHNAME(CURRENT DATE),
       MONTH(CURRENT TIMESTAMP),
       DAY(CURRENT TIMESTAMP),
       CURRENT_DATE,
       DAYOFWEEK(CURRENT TIMESTAMP),
       DAYOFWEEK_ISO(CURRENT TIMESTAMP),
       DAYOFMONTH(CURRENT TIMESTAMP)
FROM   SYSIBM.SYSDUMMY1;

-- First Wednesday of the Month
SELECT KURRENT - FIRSTY + 1
FROM   (-- AVOID CURRENT AND FIRST KEYWORD 
       SELECT WEEK_ISO(DATE(1) + ( YEAR('2020-01-07') - 1 ) YEARS +
                              ( MONTH('2020-01-07') - 1 ) MONTHS)AS FIRSTY,
              WEEK_ISO(DATE('2020-01-07'))                       AS KURRENT
        FROM   SYSIBM.SYSDUMMY1) AS T;

-- Select Day of Week for Specific Date
SELECT DAYOFWEEK(DATE('2020-01-07'))
FROM   SYSIBM.SYSDUMMY1;

-- Select First Day of Next Month
SELECT ( LAST_DAY(CURRENT DATE + 1 MONTHS) + 1 DAY - 1 MONTH ) AS
       First_Day_of_Month
FROM   SYSIBM.SYSDUMMY1;

-- Select Third Monday of Current Month
SELECT (( LAST_DAY(CURRENT DATE) + 1 DAY - 1 MONTH )) + ( 23 -
              DAYOFWEEK(( LAST_DAY(
                        CURRENT DATE) + 1 DAY - 1 MONTH )) ) DAYS AS
       third_monday
FROM   SYSIBM.SYSDUMMY1;

-- Select Next Wednesday
SELECT NEXT_DAY(CURRENT DATE, 'WEDNESDAY')
FROM   SYSIBM.SYSDUMMY1;

-- Misc Functions:
-- Find Column Values with Non-Standard Characters
SELECT COLUMN_NAME
FROM   TABLE_NAME
WHERE  ASCII(TRIM(TRANSLATE(COLUMN_NAME,
-- Empty String (Must contain the same number of characters as the search string below)
'                                                                                                                                                                                               ',
'âäàáãåçñ¢.<(+|&éêëèíîïìß!$*);¬-/ÂÄÀÁÃÅÇÑ¦,%_>?øÉÊËÈÍÎÏÌ`:#@''="Øabcdefghi«»ðýþ±°jklmnopqrªºæ¸Æ¤µ~stuvwxyz¡¿ÐÝÞ®^£¥·©§¶¼½¾[]¯¨´×{ABCDEFGHI­ôöòóõ}JKLMNOPQR¹ûüùúÿ\÷STUVWXYZ²ÔÖÒÓÕ0123456789³ÛÜÙÚŸ'
))) NOT IN ( 10, 64 );

-- Replace non-numeric with only numeric
SELECT '000000A',
       REPLACE(TRANSLATE(TRIM('000000A'),
'_____________________________________________________________________________________________',
' abcdefghijklmnopqrstuvwzyaABCDEFGHIJKLMNOPQRSTUVWXYZ`~!@#$%^&*()-_=+\|[]{};:",.<>/?'
), '_', '')
FROM   SYSIBM.SYSDUMMY1;

-- Replace Email
SELECT DISTINCT USER_COLUMN   AS "DIR_User",
                EMAIL_COLUMN  AS "DIR_Email",
                LEFT(EMAIL_COLUMN, LOCATE_IN_STRING(EMAIL_COLUMN, '@') - 1) CONCAT
                '@to_email_domain.com'
FROM   TABLE_NAME
WHERE  LOCATE_IN_STRING(EMAIL_COLUMN, '@') > 1
       AND UCASE(EMAIL_COLUMN) LIKE '%from_email_domain.com%'; 
