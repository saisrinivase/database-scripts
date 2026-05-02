# 22_application_orm_performance

ORM patterns, select-star risk, chatty SQL, parse pressure, and idle transactions.

Scripts in this area: `4`.

## Usage

Run with the mysql client, for example: `mysql -u root -p < 22_application_orm_performance/<script>.sql`.

## Scripts

- `01_n_plus_one_query_candidates.sql`
- `02_select_star_candidates.sql`
- `03_chatty_small_result_queries.sql`
- `04_app_idle_in_transaction_risk.sql`
