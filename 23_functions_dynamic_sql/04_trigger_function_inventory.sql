/*
MySQL DBA Script: Trigger Function Inventory
Purpose: Provide MySQL DBA diagnostics for trigger function inventory.
Area: Functions Dynamic Sql
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Trigger Function Inventory') AS script_name;

SELECT trigger_schema, trigger_name, event_manipulation, event_object_schema, event_object_table,
       action_timing, action_order, definer
FROM information_schema.triggers
WHERE trigger_schema NOT IN ('mysql','sys','performance_schema','information_schema')
ORDER BY trigger_schema, event_object_table, trigger_name;
