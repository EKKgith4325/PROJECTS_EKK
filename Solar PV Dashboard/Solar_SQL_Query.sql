-- Generate 365 rows with seasonal variation (safe structure)
-- 1) Drop and create the table
DROP TABLE IF EXISTS solar_monthly_data CASCADE;

CREATE TABLE solar_monthly_data (
  Serial_No        SERIAL PRIMARY KEY,
  day              DATE         NOT NULL,
  site_id          VARCHAR(50)  NOT NULL,
  installed_dc_kwp NUMERIC(10,3) NOT NULL,
  ghi              NUMERIC(10,3) NOT NULL,
  pv_energy_kwh    NUMERIC(10,3) NOT NULL,
  cuf_percent      NUMERIC(10,3),
  pr_percent       NUMERIC(10,3)
);

-- 2) Insert 365 rows with simple seasonal variation

-- Insert daily data with seasonally tuned PR ranges
INSERT INTO solar_monthly_data
  (day, site_id, installed_dc_kwp, ghi, pv_energy_kwh, cuf_percent, pr_percent)
SELECT gs::date AS day,'PLANT_A', 250::numeric(10,3),

-- GHI by season
  CASE
    WHEN EXTRACT(MONTH FROM gs) BETWEEN 5 AND 7 THEN (random() * 1.5 + 6.5)::numeric(10,3)  -- 6.5–8.0
    WHEN EXTRACT(MONTH FROM gs) BETWEEN 8 AND 10 THEN (random() * 1.5 + 4.5)::numeric(10,3) -- 4.5–6.0
    ELSE (random() * 1.0 + 5.0)::numeric(10,3)  -- 5.0–6.0
  END AS ghi,

-- Energy based on target PR × GHI × capacity
  CASE
    WHEN EXTRACT(MONTH FROM gs) BETWEEN 4 AND 7 THEN((random() * 10 + 70)::numeric(10,3) / 100) * 250 * 
  CASE 
    WHEN EXTRACT(MONTH FROM gs) BETWEEN 5 AND 7 THEN (random() * 1.5 + 6.5)::numeric(10,3)
    ELSE (random() * 1.5 + 5.5)::numeric(10,3)
  END
    WHEN EXTRACT(MONTH FROM gs) BETWEEN 8 AND 10 THEN((random() * 10 + 65)::numeric(10,3) / 100) * 250 * (random() * 1.5 + 4.5)::numeric(10,3)
    ELSE((random() * 10 + 68)::numeric(10,3) / 100) * 250 * (random() * 1.0 + 5.0)::numeric(10,3)
  END AS pv_energy_kwh,

  -- CUF = energy / (installed × 24) × 100
  (
    CASE
      WHEN EXTRACT(MONTH FROM gs) BETWEEN 4 AND 7 THEN((random() * 10 + 70)::numeric(10,3) / 100) * 250 * 
    CASE 
	  WHEN EXTRACT(MONTH FROM gs) BETWEEN 5 AND 7 THEN (random() * 1.5 + 6.5)::numeric(10,3)
      ELSE (random() * 1.5 + 5.5)::numeric(10,3)
    END
      WHEN EXTRACT(MONTH FROM gs) BETWEEN 8 AND 10 THEN((random() * 10 + 65)::numeric(10,3) / 100) * 250 * (random() * 1.5 + 4.5)::numeric(10,3)
      ELSE((random() * 10 + 68)::numeric(10,3) / 100) * 250 * (random() * 1.0 + 5.0)::numeric(10,3)
    END / (250 * 24) * 100
  )::numeric(10,3) AS cuf_percent,

  -- PR = energy / (GHI × capacity) × 100
  CASE
    WHEN EXTRACT(MONTH FROM gs) BETWEEN 4 AND 7 THEN (random() * 10 + 70)::numeric(10,3)  -- 70–80%
    WHEN EXTRACT(MONTH FROM gs) BETWEEN 8 AND 10 THEN (random() * 10 + 65)::numeric(10,3) -- 65–75%
    ELSE(random() * 10 + 68)::numeric(10,3) -- 68–78%
  END AS pr_percent

FROM generate_series('2023-01-01'::date, '2023-12-31'::date, '1 day') AS gs;


-- 3) Verify
SELECT *
FROM solar_monthly_data
ORDER BY day
LIMIT 365;

-- 1.1 Check for any zeros or negatives
SELECT COUNT(*) AS bad_rows
FROM solar_monthly_data
WHERE installed_dc_kwp <= 0 OR ghi <= 0;

-- 1.2 Check CUF/PR ranges
SELECT
  SUM(CASE WHEN cuf_percent NOT BETWEEN 0 AND 100 THEN 1 ELSE 0 END) AS cuf_bad,
  SUM(CASE WHEN pr_percent NOT BETWEEN 0 AND 200 THEN 1 ELSE 0 END) AS pr_bad
FROM solar_monthly_data;

----- ANALYSIS STARTS -------
-- 2.1 Monthly Aggregation (e.g., average CUF & PR)
CREATE OR REPLACE VIEW solar_monthly_summary AS
SELECT
  to_char(day, 'YYYY-MM') AS month,
  COUNT(*)                             AS days_count,
  ROUND(AVG(ghi)::numeric,2)          AS avg_ghi,
  ROUND(AVG(pv_energy_kwh)::numeric,2)AS avg_energy,
  ROUND(AVG(cuf_percent)::numeric,2)  AS avg_cuf,
  ROUND(AVG(pr_percent)::numeric,2)   AS avg_pr
FROM solar_monthly_data
GROUP BY month
ORDER BY month;

-- 2.2 Quaterly Aggregation (e.g., average CUF & PR)
CREATE OR REPLACE VIEW solar_quarterly_summary AS
SELECT
  to_char(date_trunc('quarter', day), 'YYYY-"Q"Q') AS quarter,
  COUNT(*)                             AS days_count,
  ROUND(AVG(ghi)::numeric,2)          AS avg_ghi,
  ROUND(AVG(pv_energy_kwh)::numeric,2)AS avg_energy,
  ROUND(AVG(cuf_percent)::numeric,2)  AS avg_cuf,
  ROUND(AVG(pr_percent)::numeric,2)   AS avg_pr
FROM solar_monthly_data
GROUP BY quarter
ORDER BY quarter;

-- Monthly Summary
SELECT * FROM solar_monthly_summary;

-- Quarterly Summary
SELECT * FROM solar_quarterly_summary;

-- 3.1: Top 5 most efficient days --
SELECT day, pr_percent, cuf_percent
FROM solar_monthly_data
ORDER BY pr_percent DESC
LIMIT 5;

-- 3.2: Potential risk days --
SELECT day, pr_percent, cuf_percent
FROM solar_monthly_data
WHERE pr_percent < 65 OR cuf_percent < 15
ORDER BY day DESC;

-- 3.3: Performance flag ----
ALTER TABLE solar_monthly_data
ADD COLUMN performance VARCHAR(10);

UPDATE solar_monthly_data
SET performance = 
  CASE
    WHEN pr_percent >= 75 THEN 'High'
    WHEN pr_percent >= 70 THEN 'Normal'
    ELSE 'Low'
  END;

-- 3.4: Add season tag -----
ALTER TABLE solar_monthly_data
ADD COLUMN Season VARCHAR(10);
UPDATE solar_monthly_data
SET season = 
  CASE
    WHEN EXTRACT(MONTH FROM day) BETWEEN 4 AND 6 THEN 'Summer'
    WHEN EXTRACT(MONTH FROM day) BETWEEN 7 AND 9 THEN 'Monsoon'
    ELSE 'Winter'
  END;
