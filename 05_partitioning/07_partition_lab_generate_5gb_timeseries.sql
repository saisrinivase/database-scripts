/*
MySQL DBA Script: Partition Lab Generate 5gb Timeseries
Purpose: Provide MySQL DBA diagnostics for partition lab generate 5gb timeseries.
Area: Partitioning
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Partition Lab Generate 5gb Timeseries') AS script_name;

CREATE TABLE mysql_partition_lab_orders (
  order_id BIGINT AUTO_INCREMENT,
  order_ts DATETIME NOT NULL,
  customer_id BIGINT NOT NULL,
  amount DECIMAL(12,2),
  PRIMARY KEY (order_id, order_ts)
)
PARTITION BY RANGE COLUMNS(order_ts) (
  PARTITION p202601 VALUES LESS THAN ('2026-02-01'),
  PARTITION pmax VALUES LESS THAN (MAXVALUE)
);
