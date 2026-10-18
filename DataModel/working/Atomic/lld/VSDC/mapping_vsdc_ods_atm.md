# Source to Atomic Mapping


## PHẦN 1: SCHEMA VSDC (uat_vsdc_stg)


### Bảng 2: open_investors  →  open_investor_account

| Schema nguồn | Bảng nguồn | Trường nguồn | Kiểu DL nguồn | Schema atomic | Bảng atomic | Trường atomic | Kiểu DL atomic | Transformation / Ghi chú |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| — | — | (generated) | STRING | atomic.uat_atm | open_investor_account | open_investor_account_id | STRING | Surrogate key — UUID generated |
| — | — | (system) | STRING | atomic.uat_atm | open_investor_account | src_stm_code | STRING | Mã hệ thống nguồn — hardcode per pipeline |
| uat_vsdc_stg | open_investors | trading_account_no | STRING | atomic.uat_atm | open_investor_account | investor_account_nbr | STRING | Business key |
| uat_vsdc_stg | open_investors | customer_name | STRING | atomic.uat_atm | open_investor_account | investor_nm | STRING | — |
| uat_vsdc_stg | open_investors | investor_type | STRING | atomic.uat_atm | open_investor_account | investor_tp_code | INT | LOOKUP Classification Value (Cá nhân/Tổ chức) → code; CAST INT |
| uat_vsdc_stg | open_investors | address | STRING | atomic.uat_atm | open_investor_account | address | STRING | — |
| uat_vsdc_stg | open_investors | id_number | STRING | atomic.uat_atm | open_investor_account | identification_nbr | STRING | — |
| uat_vsdc_stg | open_investors | issue_date | DATE | atomic.uat_atm | open_investor_account | issue_dt | DATE | — |
| uat_vsdc_stg | open_investors | issue_place | STRING | atomic.uat_atm | open_investor_account | issue_place | STRING | — |
| uat_vsdc_stg | open_investors | open_date | DATE | atomic.uat_atm | open_investor_account | open_dt | DATE | — |
| uat_vsdc_stg | open_investors | nationality | STRING | atomic.uat_atm | open_investor_account | nationality_code | INT | Crosswalk: LEFT JOIN uat_vsdc_stg.nationality ON nationality = autoid (CAST BIGINT); CAST INT |
| uat_vsdc_stg | open_investors | phone_number | STRING | atomic.uat_atm | open_investor_account | phone_nbr | STRING | — |
| uat_vsdc_stg | open_investors | email | STRING | atomic.uat_atm | open_investor_account | email | STRING | — |
| — | — | — | — | atomic.uat_atm | open_investor_account | ds_snpst_dt | DATE | ⚙ Dev xử lý — không map từ nguồn |
| — | — | — | — | atomic.uat_atm | open_investor_account | ds_etl_pcs_tms | TIMESTAMP | ⚙ Dev xử lý — không map từ nguồn |


### Bảng 3: closed_investors  →  closed_investor_account

| Schema nguồn | Bảng nguồn | Trường nguồn | Kiểu DL nguồn | Schema atomic | Bảng atomic | Trường atomic | Kiểu DL atomic | Transformation / Ghi chú |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| — | — | (generated) | STRING | atomic.uat_atm | closed_investor_account | closed_investor_account_id | STRING | Surrogate key — UUID generated |
| — | — | (system) | STRING | atomic.uat_atm | closed_investor_account | src_stm_code | STRING | Mã hệ thống nguồn — hardcode per pipeline |
| uat_vsdc_stg | closed_investors | trading_account_no | STRING | atomic.uat_atm | closed_investor_account | investor_account_nbr | STRING | Business key |
| uat_vsdc_stg | closed_investors | customer_name | STRING | atomic.uat_atm | closed_investor_account | investor_nm | STRING | — |
| uat_vsdc_stg | closed_investors | investor_type | STRING | atomic.uat_atm | closed_investor_account | investor_tp_code | INT | LOOKUP Classification Value (Cá nhân/Tổ chức) → code; CAST INT |
| uat_vsdc_stg | closed_investors | address | STRING | atomic.uat_atm | closed_investor_account | address | STRING | — |
| uat_vsdc_stg | closed_investors | id_number | STRING | atomic.uat_atm | closed_investor_account | identification_nbr | STRING | — |
| uat_vsdc_stg | closed_investors | issue_date | DATE | atomic.uat_atm | closed_investor_account | issue_dt | DATE | — |
| uat_vsdc_stg | closed_investors | issue_place | STRING | atomic.uat_atm | closed_investor_account | issue_place | STRING | — |
| uat_vsdc_stg | closed_investors | close_date | DATE | atomic.uat_atm | closed_investor_account | close_dt | DATE | — |
| uat_vsdc_stg | closed_investors | nationality | STRING | atomic.uat_atm | closed_investor_account | nationality_code | INT | Crosswalk: LEFT JOIN uat_vsdc_stg.nationality ON nationality = autoid (CAST BIGINT); CAST INT |
| uat_vsdc_stg | closed_investors | phone_number | STRING | atomic.uat_atm | closed_investor_account | phone_nbr | STRING | — |
| uat_vsdc_stg | closed_investors | email | STRING | atomic.uat_atm | closed_investor_account | email | STRING | — |
| uat_vsdc_stg | closed_investors | notes | STRING | atomic.uat_atm | closed_investor_account | close_note | STRING | — |
| — | — | — | — | atomic.uat_atm | closed_investor_account | ds_snpst_dt | DATE | ⚙ Dev xử lý — không map từ nguồn |
| — | — | — | — | atomic.uat_atm | closed_investor_account | ds_etl_pcs_tms | TIMESTAMP | ⚙ Dev xử lý — không map từ nguồn |


### Bảng 4: updated_investors  →  updated_investor_account

| Schema nguồn | Bảng nguồn | Trường nguồn | Kiểu DL nguồn | Schema atomic | Bảng atomic | Trường atomic | Kiểu DL atomic | Transformation / Ghi chú |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| — | — | (generated) | STRING | atomic.uat_atm | updated_investor_account | updated_investor_account_id | STRING | Surrogate key — UUID generated |
| — | — | (system) | STRING | atomic.uat_atm | updated_investor_account | src_stm_code | STRING | Mã hệ thống nguồn — hardcode per pipeline |
| uat_vsdc_stg | updated_investors | trading_account_no | STRING | atomic.uat_atm | updated_investor_account | investor_account_nbr | STRING | Business key |
| uat_vsdc_stg | updated_investors | customer_name | STRING | atomic.uat_atm | updated_investor_account | investor_nm | STRING | — |
| uat_vsdc_stg | updated_investors | investor_type | STRING | atomic.uat_atm | updated_investor_account | investor_tp_code | INT | LOOKUP Classification Value (Cá nhân/Tổ chức) → code; CAST INT |
| uat_vsdc_stg | updated_investors | address | STRING | atomic.uat_atm | updated_investor_account | address | STRING | — |
| uat_vsdc_stg | updated_investors | id_number | STRING | atomic.uat_atm | updated_investor_account | identification_nbr | STRING | — |
| uat_vsdc_stg | updated_investors | issue_date | DATE | atomic.uat_atm | updated_investor_account | issue_dt | DATE | — |
| uat_vsdc_stg | updated_investors | issue_place | STRING | atomic.uat_atm | updated_investor_account | issue_place | STRING | — |
| uat_vsdc_stg | updated_investors | update_date | DATE | atomic.uat_atm | updated_investor_account | update_dt | DATE | — |
| uat_vsdc_stg | updated_investors | nationality | STRING | atomic.uat_atm | updated_investor_account | nationality_code | INT | Crosswalk: LEFT JOIN uat_vsdc_stg.nationality ON nationality = autoid (CAST BIGINT); CAST INT |
| uat_vsdc_stg | updated_investors | phone_number | STRING | atomic.uat_atm | updated_investor_account | phone_nbr | STRING | — |
| uat_vsdc_stg | updated_investors | email | STRING | atomic.uat_atm | updated_investor_account | email | STRING | — |
| uat_vsdc_stg | updated_investors | notes | STRING | atomic.uat_atm | updated_investor_account | update_note | STRING | — |
| — | — | — | — | atomic.uat_atm | updated_investor_account | ds_snpst_dt | DATE | ⚙ Dev xử lý — không map từ nguồn |
| — | — | — | — | atomic.uat_atm | updated_investor_account | ds_etl_pcs_tms | TIMESTAMP | ⚙ Dev xử lý — không map từ nguồn |


### Bảng 1: outstanding_shares  +  Bảng 19/27: listed_securities_list (HNX/HOSE)  →  listed_share_info

| Schema nguồn | Bảng nguồn | Trường nguồn | Kiểu DL nguồn | Schema atomic | Bảng atomic | Trường atomic | Kiểu DL atomic | Transformation / Ghi chú |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| — | — | (generated) | STRING | atomic.uat_atm | listed_share_info | listed_share_info_id | STRING | Surrogate key — UUID generated |
| — | — | (system) | STRING | atomic.uat_atm | listed_share_info | src_stm_code | STRING | Mã hệ thống nguồn — hardcode per pipeline |
| uat_vsdc_stg | outstanding_shares | ticker_symbol | STRING | atomic.uat_atm | listed_share_info | ticker_symbol | STRING | Business key |
| uat_vsdc_stg | outstanding_shares | isin_code | STRING | atomic.uat_atm | listed_share_info | isin_code | STRING | — |
| uat_vsdc_stg | outstanding_shares | total_issued_shares | BIGINT | atomic.uat_atm | listed_share_info | total_issued_share_quantity | BIGINT | — |
| uat_vsdc_stg / uat_hnx_stg / uat_hose_stg | outstanding_shares | treasury_shares | BIGINT | atomic.uat_atm | listed_share_info | treasury_share_quantity | BIGINT | — |
| uat_vsdc_stg | outstanding_shares | outstanding_shares | BIGINT | atomic.uat_atm | listed_share_info | outstanding_share_quantity | BIGINT | — |
| uat_vsdc_stg | outstanding_shares | free_float_shares | BIGINT | atomic.uat_atm | listed_share_info | free_float_share_quantity | BIGINT | — |
| uat_vsdc_stg | outstanding_shares | restricted_shares | BIGINT | atomic.uat_atm | listed_share_info | restricted_share_quantity | BIGINT | — |
| uat_vsdc_stg | outstanding_shares | voting_shares | BIGINT | atomic.uat_atm | listed_share_info | voting_share_quantity | BIGINT | — |
| uat_hnx_stg / uat_hose_stg | listed_securities_list | issuer_name | STRING | atomic.uat_atm | listed_share_info | issuer_nm | STRING | Bổ sung từ listed_securities_list |
| uat_hnx_stg / uat_hose_stg | listed_securities_list | listed_shares | BIGINT | atomic.uat_atm | listed_share_info | listed_share_quantity | BIGINT | — |
| uat_hnx_stg / uat_hose_stg | listed_securities_list | reference_price | DECIMAL(18,2) | atomic.uat_atm | listed_share_info | reference_price | DECIMAL(23,2) | Đổi precision |
| — | — | — | — | atomic.uat_atm | listed_share_info | ds_snpst_dt | DATE | ⚙ Dev xử lý — không map từ nguồn |
| — | — | — | — | atomic.uat_atm | listed_share_info | ds_etl_pcs_tms | TIMESTAMP | ⚙ Dev xử lý — không map từ nguồn |


### Bảng 9: foreign_investor_info  →  foreign_ownership_info

| Schema nguồn | Bảng nguồn | Trường nguồn | Kiểu DL nguồn | Schema atomic | Bảng atomic | Trường atomic | Kiểu DL atomic | Transformation / Ghi chú |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| — | — | (generated) | STRING | atomic.uat_atm | foreign_ownership_info | foreign_ownership_info_id | STRING | Surrogate key — UUID generated |
| — | — | (system) | STRING | atomic.uat_atm | foreign_ownership_info | src_stm_code | STRING | Mã hệ thống nguồn — hardcode per pipeline |
| uat_vsdc_stg | foreign_investor_info | ticker_symbol | STRING | atomic.uat_atm | foreign_ownership_info | ticker_symbol | STRING | Business key |
| uat_vsdc_stg | foreign_investor_info | isin_code | STRING | atomic.uat_atm | foreign_ownership_info | isin_code | STRING | — |
| uat_vsdc_stg | foreign_investor_info | total_issued_shares | BIGINT | atomic.uat_atm | foreign_ownership_info | total_issued_share_quantity | BIGINT | — |
| uat_vsdc_stg | foreign_investor_info | max_foreign_ownership_ratio | DECIMAL(10,2) | atomic.uat_atm | foreign_ownership_info | max_foreign_ownership_ratio | DECIMAL(5,2) | Đổi precision |
| uat_vsdc_stg | foreign_investor_info | max_shares_foreign_can_hold | BIGINT | atomic.uat_atm | foreign_ownership_info | max_foreign_holding_quantity | BIGINT | — |
| uat_vsdc_stg | foreign_investor_info | current_shares_foreign_hold | BIGINT | atomic.uat_atm | foreign_ownership_info | current_foreign_holding_quantity | BIGINT | — |
| uat_vsdc_stg | foreign_investor_info | remaining_shares_foreign_can_hold | BIGINT | atomic.uat_atm | foreign_ownership_info | remaining_foreign_holding_quantity | BIGINT | — |
| — | — | — | — | atomic.uat_atm | foreign_ownership_info | ds_snpst_dt | DATE | ⚙ Dev xử lý — không map từ nguồn |
| — | — | — | — | atomic.uat_atm | foreign_ownership_info | ds_etl_pcs_tms | TIMESTAMP | ⚙ Dev xử lý — không map từ nguồn |


### Bảng 5: major_shareholder  →  major_shareholder_ownership

| Schema nguồn | Bảng nguồn | Trường nguồn | Kiểu DL nguồn | Schema atomic | Bảng atomic | Trường atomic | Kiểu DL atomic | Transformation / Ghi chú |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| — | — | (generated) | STRING | atomic.uat_atm | major_shareholder_ownership | major_shareholder_ownership_id | STRING | Surrogate key — UUID generated |
| — | — | (system) | STRING | atomic.uat_atm | major_shareholder_ownership | src_stm_code | STRING | Mã hệ thống nguồn — hardcode per pipeline |
| uat_vsdc_stg | major_shareholder | ticker_symbol | STRING | atomic.uat_atm | major_shareholder_ownership | ticker_symbol | STRING | Business key |
| uat_vsdc_stg | major_shareholder | isin_code | STRING | atomic.uat_atm | major_shareholder_ownership | isin_code | STRING | — |
| uat_vsdc_stg | major_shareholder | shareholder_name | STRING | atomic.uat_atm | major_shareholder_ownership | major_shareholder_nm | STRING | — |
| uat_vsdc_stg | major_shareholder | id_number | STRING | atomic.uat_atm | major_shareholder_ownership | identification_nbr | STRING | Business key |
| uat_vsdc_stg | major_shareholder | issue_date | DATE | atomic.uat_atm | major_shareholder_ownership | issue_dt | DATE | — |
| uat_vsdc_stg | major_shareholder | contact_address | STRING | atomic.uat_atm | major_shareholder_ownership | address | STRING | — |
| uat_vsdc_stg | major_shareholder | voting_shares | DECIMAL(18,0) | atomic.uat_atm | major_shareholder_ownership | voting_share_quantity | BIGINT | CAST DECIMAL→BIGINT |
| uat_vsdc_stg | major_shareholder | begin_period_date | DATE | atomic.uat_atm | major_shareholder_ownership | opening_balance_date | DATE | — |
| uat_vsdc_stg | major_shareholder | begin_period_shares | DECIMAL(18,0) | atomic.uat_atm | major_shareholder_ownership | opening_share_quantity | BIGINT | CAST |
| uat_vsdc_stg | major_shareholder | begin_period_ratio | DECIMAL(10,2) | atomic.uat_atm | major_shareholder_ownership | opening_ratio | DECIMAL(7,4) | Đổi precision |
| uat_vsdc_stg | major_shareholder | end_period_date | DATE | atomic.uat_atm | major_shareholder_ownership | closing_balance_date | DATE | — |
| uat_vsdc_stg | major_shareholder | end_period_shares | DECIMAL(18,0) | atomic.uat_atm | major_shareholder_ownership | closing_share_quantity | BIGINT | CAST |
| uat_vsdc_stg | major_shareholder | end_period_ratio | DECIMAL(10,2) | atomic.uat_atm | major_shareholder_ownership | closing_ratio | DECIMAL(7,4) | Đổi precision |
| uat_vsdc_stg | major_shareholder | notes | STRING | atomic.uat_atm | major_shareholder_ownership | note | STRING | — |
| — | — | — | — | atomic.uat_atm | major_shareholder_ownership | ds_snpst_dt | DATE | ⚙ Dev xử lý — không map từ nguồn |
| — | — | — | — | atomic.uat_atm | major_shareholder_ownership | ds_etl_pcs_tms | TIMESTAMP | ⚙ Dev xử lý — không map từ nguồn |


### Bảng 6: end_of_day_open_interest  →  end_of_day_open_interest

| Schema nguồn | Bảng nguồn | Trường nguồn | Kiểu DL nguồn | Schema atomic | Bảng atomic | Trường atomic | Kiểu DL atomic | Transformation / Ghi chú |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| — | — | (generated) | STRING | atomic.uat_atm | end_of_day_open_interest | end_of_day_open_interest_id | STRING | Surrogate key — UUID generated |
| — | — | (system) | STRING | atomic.uat_atm | end_of_day_open_interest | src_stm_code | STRING | Mã hệ thống nguồn — hardcode per pipeline |
| uat_vsdc_stg | end_of_day_open_interest | contract_code | STRING | atomic.uat_atm | end_of_day_open_interest | ticker_symbol | STRING | — |
| uat_vsdc_stg | end_of_day_open_interest | open_interest_volume | BIGINT | atomic.uat_atm | end_of_day_open_interest | open_interest_quantity | BIGINT | — |
| — | — | — | — | atomic.uat_atm | end_of_day_open_interest | ds_snpst_dt | DATE | ⚙ Dev xử lý — không map từ nguồn |
| — | — | — | — | atomic.uat_atm | end_of_day_open_interest | ds_etl_pcs_tms | TIMESTAMP | ⚙ Dev xử lý — không map từ nguồn |

### Bảng 7. account_opening_closing_status (Bỏ không còn khai thác)
### Bảng 8: foreign_investor_bond_portfolio  →  foreign_bond_portfolio

| Schema nguồn | Bảng nguồn | Trường nguồn | Kiểu DL nguồn | Schema atomic | Bảng atomic | Trường atomic | Kiểu DL atomic | Transformation / Ghi chú |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| — | — | (generated) | STRING | atomic.uat_atm | foreign_bond_portfolio | foreign_bond_portfolio_id | STRING | Surrogate key — UUID generated |
| — | — | (system) | STRING | atomic.uat_atm | foreign_bond_portfolio | src_stm_code | STRING | Mã hệ thống nguồn — hardcode per pipeline |
| uat_vsdc_stg | foreign_investor_bond_portfolio | trading_code | STRING | atomic.uat_atm | foreign_bond_portfolio | foreign_investor_code | STRING | — |
| uat_vsdc_stg | foreign_investor_bond_portfolio | investor_name | STRING | atomic.uat_atm | foreign_bond_portfolio | foreign_investor_nm | STRING | — |
| uat_vsdc_stg | foreign_investor_bond_portfolio | investor_category | STRING | atomic.uat_atm | foreign_bond_portfolio | foreign_investor_tp_code | STRING | — |
| uat_vsdc_stg | foreign_investor_bond_portfolio | nationality | STRING | atomic.uat_atm | foreign_bond_portfolio | nationality_code | STRING | — |
| uat_vsdc_stg | foreign_investor_bond_portfolio | address | STRING | atomic.uat_atm | foreign_bond_portfolio | address | STRING | — |
| uat_vsdc_stg | foreign_investor_bond_portfolio | trading_representative_name | STRING | atomic.uat_atm | foreign_bond_portfolio | trading_representative_nm | STRING | — |
| uat_vsdc_stg | foreign_investor_bond_portfolio | institutional_investor_type | STRING | atomic.uat_atm | foreign_bond_portfolio | institutional_investor_tp | STRING | — |
| uat_vsdc_stg | foreign_investor_bond_portfolio | bond_code | STRING | atomic.uat_atm | foreign_bond_portfolio | bond_code | STRING | — |
| uat_vsdc_stg | foreign_investor_bond_portfolio | owned_volume | BIGINT | atomic.uat_atm | foreign_bond_portfolio | owned_bond_quantity | BIGINT | — |
| uat_vsdc_stg | foreign_investor_bond_portfolio | report_month | STRING | atomic.uat_atm | foreign_bond_portfolio | rpt_month | STRING | — |
| — | — | — | — | atomic.uat_atm | foreign_bond_portfolio | ds_snpst_dt | DATE | ⚙ Dev xử lý — không map từ nguồn |
| — | — | — | — | atomic.uat_atm | foreign_bond_portfolio | ds_etl_pcs_tms | TIMESTAMP | ⚙ Dev xử lý — không map từ nguồn |


## PHẦN 2: SCHEMA HNX (uat_hnx_stg)


### Bảng 10: share_auction (HNX)  +  Bảng 25: share_auction (HOSE)  →  share_auction_result

| Schema nguồn | Bảng nguồn | Trường nguồn | Kiểu DL nguồn | Schema atomic | Bảng atomic | Trường atomic | Kiểu DL atomic | Transformation / Ghi chú |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| — | — | (generated) | STRING | atomic.uat_atm | share_auction_result | share_auction_result_id | STRING | Surrogate key — UUID generated |
| — | — | (system) | STRING | atomic.uat_atm | share_auction_result | src_stm_code | STRING | Mã hệ thống nguồn — hardcode per pipeline |
| uat_hnx_stg / uat_hose_stg | share_auction | issuer_name | STRING | atomic.uat_atm | share_auction_result | issuer_nm | STRING | Business key |
| uat_hnx_stg / uat_hose_stg | share_auction | auction_type | STRING | atomic.uat_atm | share_auction_result | auction_tp | STRING | Business key |
| uat_hnx_stg / uat_hose_stg | share_auction | registered_offering_shares | BIGINT | atomic.uat_atm | share_auction_result | registered_offering_share_quantity | BIGINT | — |
| uat_hnx_stg / uat_hose_stg | share_auction | total_registered_investors | BIGINT | atomic.uat_atm | share_auction_result | registered_investor_count | BIGINT | — |
| uat_hnx_stg / uat_hose_stg | share_auction | starting_price | DECIMAL(18,2) | atomic.uat_atm | share_auction_result | starting_price | DECIMAL(23,2) | — |
| uat_hnx_stg / uat_hose_stg | share_auction | average_winning_price | DECIMAL(18,2) | atomic.uat_atm | share_auction_result | average_winning_price | DECIMAL(23,2) | — |
| uat_hnx_stg / uat_hose_stg | share_auction | domestic_institutional_winners | BIGINT | atomic.uat_atm | share_auction_result | domestic_institutional_winner_count | BIGINT | — |
| uat_hnx_stg / uat_hose_stg | share_auction | foreign_institutional_winners | BIGINT | atomic.uat_atm | share_auction_result | foreign_institutional_winner_count | BIGINT | — |
| uat_hnx_stg / uat_hose_stg | share_auction | domestic_individual_winners | BIGINT | atomic.uat_atm | share_auction_result | domestic_individual_winner_count | BIGINT | — |
| uat_hnx_stg / uat_hose_stg | share_auction | foreign_individual_winners | BIGINT | atomic.uat_atm | share_auction_result | foreign_individual_winner_count | BIGINT | — |
| uat_hnx_stg / uat_hose_stg | share_auction | domestic_registered_buy_volume | BIGINT | atomic.uat_atm | share_auction_result | domestic_registered_buy_quantity | BIGINT | — |
| uat_hnx_stg / uat_hose_stg | share_auction | foreign_registered_buy_volume | BIGINT | atomic.uat_atm | share_auction_result | foreign_registered_buy_quantity | BIGINT | — |
| uat_hnx_stg / uat_hose_stg | share_auction | domestic_winning_shares | BIGINT | atomic.uat_atm | share_auction_result | domestic_winning_share_quantity | BIGINT | — |
| uat_hnx_stg / uat_hose_stg | share_auction | foreign_winning_shares | BIGINT | atomic.uat_atm | share_auction_result | foreign_winning_share_quantity | BIGINT | — |
| uat_hnx_stg / uat_hose_stg | share_auction | domestic_winning_value | DECIMAL(18,2) | atomic.uat_atm | share_auction_result | domestic_winning_val | DECIMAL(23,2) | — |
| uat_hnx_stg / uat_hose_stg | share_auction | foreign_winning_value | DECIMAL(18,2) | atomic.uat_atm | share_auction_result | foreign_winning_val | DECIMAL(23,2) | — |
| uat_hnx_stg / uat_hose_stg | share_auction | domestic_actual_sold_shares | BIGINT | atomic.uat_atm | share_auction_result | domestic_actual_sold_share_quantity | BIGINT | — |
| uat_hnx_stg / uat_hose_stg | share_auction | foreign_actual_sold_shares | BIGINT | atomic.uat_atm | share_auction_result | foreign_actual_sold_share_quantity | BIGINT | — |
| uat_hnx_stg / uat_hose_stg | share_auction | domestic_actual_sold_value | DECIMAL(18,2) | atomic.uat_atm | share_auction_result | domestic_actual_sold_val | DECIMAL(23,2) | — |
| uat_hnx_stg / uat_hose_stg | share_auction | foreign_actual_sold_value | DECIMAL(18,2) | atomic.uat_atm | share_auction_result | foreign_actual_sold_val | DECIMAL(23,2) | — |
| uat_hnx_stg / uat_hose_stg | share_auction | report_month | STRING | atomic.uat_atm | share_auction_result | rpt_month | STRING | — |
| uat_hnx_stg / uat_hose_stg | share_auction | report_year | STRING | atomic.uat_atm | share_auction_result | rpt_year | STRING | — |
| — | — | — | — | atomic.uat_atm | share_auction_result | ds_snpst_dt | DATE | ⚙ Dev xử lý — không map từ nguồn |
| — | — | — | — | atomic.uat_atm | share_auction_result | ds_etl_pcs_tms | TIMESTAMP | ⚙ Dev xử lý — không map từ nguồn |


### Bảng 11: private_corp_bond_trading  →  private_corp_bond_trading_summary

| Schema nguồn | Bảng nguồn | Trường nguồn | Kiểu DL nguồn | Schema atomic | Bảng atomic | Trường atomic | Kiểu DL atomic | Transformation / Ghi chú |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| — | — | (generated) | STRING | atomic.uat_atm | private_corp_bond_trading_summary | private_corp_bond_trading_summary_id | STRING | Surrogate key — UUID generated |
| — | — | (system) | STRING | atomic.uat_atm | private_corp_bond_trading_summary | src_stm_code | STRING | Mã hệ thống nguồn — hardcode per pipeline |
| uat_hnx_stg | private_corp_bond_trading | indicator | STRING | atomic.uat_atm | private_corp_bond_trading_summary | indicator_nm | STRING | — |
| uat_hnx_stg | private_corp_bond_trading | unit | STRING | atomic.uat_atm | private_corp_bond_trading_summary | measurement_unit | STRING | — |
| uat_hnx_stg | private_corp_bond_trading | value | DECIMAL(18,4) | atomic.uat_atm | private_corp_bond_trading_summary | indicator_val | DECIMAL(23,4) | Đổi precision |
| — | — | — | — | atomic.uat_atm | private_corp_bond_trading_summary | ds_snpst_dt | DATE | ⚙ Dev xử lý — không map từ nguồn |
| — | — | — | — | atomic.uat_atm | private_corp_bond_trading_summary | ds_etl_pcs_tms | TIMESTAMP | ⚙ Dev xử lý — không map từ nguồn |


### Bảng 12: gov_bond_offering  →  gov_bond_bidding_result

| Schema nguồn | Bảng nguồn | Trường nguồn | Kiểu DL nguồn | Schema atomic | Bảng atomic | Trường atomic | Kiểu DL atomic | Transformation / Ghi chú |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| — | — | (generated) | STRING | atomic.uat_atm | gov_bond_bidding_result | gov_bond_bidding_result_id | STRING | Surrogate key — UUID generated |
| — | — | (system) | STRING | atomic.uat_atm | gov_bond_bidding_result | src_stm_code | STRING | Mã hệ thống nguồn — hardcode per pipeline |
| uat_hnx_stg | gov_bond_offering | bidding_session | STRING | atomic.uat_atm | gov_bond_bidding_result | bidding_session | STRING | Business key |
| uat_hnx_stg | gov_bond_offering | bidding_method | STRING | atomic.uat_atm | gov_bond_bidding_result | bidding_method | STRING | — |
| uat_hnx_stg | gov_bond_offering | bond_code | STRING | atomic.uat_atm | gov_bond_bidding_result | bond_code | STRING | — |
| uat_hnx_stg | gov_bond_offering | issuer_name | STRING | atomic.uat_atm | gov_bond_bidding_result | issuer_nm | STRING | — |
| uat_hnx_stg | gov_bond_offering | bond_type | STRING | atomic.uat_atm | gov_bond_bidding_result | bond_tp | STRING | — |
| uat_hnx_stg | gov_bond_offering | term | STRING | atomic.uat_atm | gov_bond_bidding_result | bond_term | STRING | — |
| uat_hnx_stg | gov_bond_offering | issue_date | DATE | atomic.uat_atm | gov_bond_bidding_result | issue_dt | DATE | — |
| uat_hnx_stg | gov_bond_offering | issue_method | STRING | atomic.uat_atm | gov_bond_bidding_result | issue_method | STRING | — |
| uat_hnx_stg | gov_bond_offering | calling_value | DECIMAL(18,2) | atomic.uat_atm | gov_bond_bidding_result | calling_val | DECIMAL(23,2) | — |
| uat_hnx_stg | gov_bond_offering | bidding_value | DECIMAL(18,2) | atomic.uat_atm | gov_bond_bidding_result | bidding_val | DECIMAL(23,2) | — |
| uat_hnx_stg | gov_bond_offering | winning_value | DECIMAL(18,2) | atomic.uat_atm | gov_bond_bidding_result | winning_val | DECIMAL(23,2) | — |
| uat_hnx_stg | gov_bond_offering | nominal_interest_rate | DECIMAL(10,2) | atomic.uat_atm | gov_bond_bidding_result | nominal_interest_rate | DECIMAL(5,2) | — |
| uat_hnx_stg | gov_bond_offering | winning_interest_rate | DECIMAL(10,2) | atomic.uat_atm | gov_bond_bidding_result | winning_interest_rate | DECIMAL(5,2) | — |
| uat_hnx_stg | gov_bond_offering | report_month | STRING | atomic.uat_atm | gov_bond_bidding_result | rpt_month | STRING | — |
| — | — | — | — | atomic.uat_atm | gov_bond_bidding_result | ds_snpst_dt | DATE | ⚙ Dev xử lý — không map từ nguồn |
| — | — | — | — | atomic.uat_atm | gov_bond_bidding_result | ds_etl_pcs_tms | TIMESTAMP | ⚙ Dev xử lý — không map từ nguồn |


### Bảng 13: gov_bond_listed_list  →  gov_bond_listing

| Schema nguồn | Bảng nguồn | Trường nguồn | Kiểu DL nguồn | Schema atomic | Bảng atomic | Trường atomic | Kiểu DL atomic | Transformation / Ghi chú |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| — | — | (generated) | STRING | atomic.uat_atm | gov_bond_listing | gov_bond_listing_id | STRING | Surrogate key — UUID generated |
| — | — | (system) | STRING | atomic.uat_atm | gov_bond_listing | src_stm_code | STRING | Mã hệ thống nguồn — hardcode per pipeline |
| uat_hnx_stg | gov_bond_listed_list | bond_code | STRING | atomic.uat_atm | gov_bond_listing | bond_code | STRING | Business key |
| uat_hnx_stg | gov_bond_listed_list | issuer_name | STRING | atomic.uat_atm | gov_bond_listing | issuer_nm | STRING | — |
| uat_hnx_stg | gov_bond_listed_list | bond_type | STRING | atomic.uat_atm | gov_bond_listing | bond_tp | STRING | — |
| uat_hnx_stg | gov_bond_listed_list | listed_volume | BIGINT | atomic.uat_atm | gov_bond_listing | listed_bond_quantity | BIGINT | — |
| uat_hnx_stg | gov_bond_listed_list | bond_term | STRING | atomic.uat_atm | gov_bond_listing | bond_term | STRING | — |
| uat_hnx_stg | gov_bond_listed_list | remaining_term | STRING | atomic.uat_atm | gov_bond_listing | remaining_bond_term | STRING | — |
| uat_hnx_stg | gov_bond_listed_list | interest_payment_method | STRING | atomic.uat_atm | gov_bond_listing | interest_payment_method | STRING | — |
| uat_hnx_stg | gov_bond_listed_list | interest_payment_type | STRING | atomic.uat_atm | gov_bond_listing | interest_payment_tp | STRING | — |
| uat_hnx_stg | gov_bond_listed_list | interest_rate | DECIMAL(10,2) | atomic.uat_atm | gov_bond_listing | interest_rate | DECIMAL(5,2) | — |
| uat_hnx_stg | gov_bond_listed_list | first_trading_date | DATE | atomic.uat_atm | gov_bond_listing | first_trading_dt | DATE | — |
| uat_hnx_stg | gov_bond_listed_list | status | STRING | atomic.uat_atm | gov_bond_listing | listing_status | STRING | — |
| uat_hnx_stg | gov_bond_listed_list | report_month | STRING | atomic.uat_atm | gov_bond_listing | rpt_month | STRING | — |
| — | — | — | — | atomic.uat_atm | gov_bond_listing | ds_snpst_dt | DATE | ⚙ Dev xử lý — không map từ nguồn |
| — | — | — | — | atomic.uat_atm | gov_bond_listing | ds_etl_pcs_tms | TIMESTAMP | ⚙ Dev xử lý — không map từ nguồn |


### Bảng 14: gov_bond_additional_listing  →  additional_gov_bond_listing

| Schema nguồn | Bảng nguồn | Trường nguồn | Kiểu DL nguồn | Schema atomic | Bảng atomic | Trường atomic | Kiểu DL atomic | Transformation / Ghi chú |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| — | — | (generated) | STRING | atomic.uat_atm | additional_gov_bond_listing | additional_gov_bond_listing_id | STRING | Surrogate key — UUID generated |
| — | — | (system) | STRING | atomic.uat_atm | additional_gov_bond_listing | src_stm_code | STRING | Mã hệ thống nguồn — hardcode per pipeline |
| uat_hnx_stg | gov_bond_additional_listing | bond_code | STRING | atomic.uat_atm | additional_gov_bond_listing | bond_code | STRING | Business key |
| uat_hnx_stg | gov_bond_additional_listing | bond_type | STRING | atomic.uat_atm | additional_gov_bond_listing | bond_tp | STRING | — |
| uat_hnx_stg | gov_bond_additional_listing | volume | BIGINT | atomic.uat_atm | additional_gov_bond_listing | additional_bond_quantity | BIGINT | — |
| uat_hnx_stg | gov_bond_additional_listing | par_value | DECIMAL(18,2) | atomic.uat_atm | additional_gov_bond_listing | par_val | BIGINT | — |
| uat_hnx_stg | gov_bond_additional_listing | status | STRING | atomic.uat_atm | additional_gov_bond_listing | listing_status | STRING | Business key |
| uat_hnx_stg | gov_bond_additional_listing | listing_change_date | DATE | atomic.uat_atm | additional_gov_bond_listing | listing_change_dt | DATE | Business key |
| uat_hnx_stg | gov_bond_additional_listing | report_month | STRING | atomic.uat_atm | additional_gov_bond_listing | rpt_month | STRING | — |
| — | — | — | — | atomic.uat_atm | additional_gov_bond_listing | ds_snpst_dt | DATE | ⚙ Dev xử lý — không map từ nguồn |
| — | — | — | — | atomic.uat_atm | additional_gov_bond_listing | ds_etl_pcs_tms | TIMESTAMP | ⚙ Dev xử lý — không map từ nguồn |


### Bảng 15: private_corp_bond_offering  →  private_corp_bond_offering

| Schema nguồn | Bảng nguồn | Trường nguồn | Kiểu DL nguồn | Schema atomic | Bảng atomic | Trường atomic | Kiểu DL atomic | Transformation / Ghi chú |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| — | — | (generated) | STRING | atomic.uat_atm | private_corp_bond_offering | private_corp_bond_offering_id | STRING | Surrogate key — UUID generated |
| — | — | (system) | STRING | atomic.uat_atm | private_corp_bond_offering | src_stm_code | STRING | Mã hệ thống nguồn — hardcode per pipeline |
| uat_hnx_stg | private_corp_bond_offering | bond_code | STRING | atomic.uat_atm | private_corp_bond_offering | bond_code | STRING | Business key |
| uat_hnx_stg | private_corp_bond_offering | market_type | STRING | atomic.uat_atm | private_corp_bond_offering | market_tp | STRING | Business key |
| uat_hnx_stg | private_corp_bond_offering | posting_date | DATE | atomic.uat_atm | private_corp_bond_offering | posting_dt | DATE | Business key |
| uat_hnx_stg | private_corp_bond_offering | report_month | STRING | atomic.uat_atm | private_corp_bond_offering | rpt_month | STRING | — |
| uat_hnx_stg | private_corp_bond_offering | issuer_name | STRING | atomic.uat_atm | private_corp_bond_offering | issuer_nm | STRING | — |
| uat_hnx_stg | private_corp_bond_offering | enterprise_type | STRING | atomic.uat_atm | private_corp_bond_offering | enterprise_tp | STRING | — |
| uat_hnx_stg | private_corp_bond_offering | business_sector | STRING | atomic.uat_atm | private_corp_bond_offering | business_sector | STRING | — |
| uat_hnx_stg | private_corp_bond_offering | currency | STRING | atomic.uat_atm | private_corp_bond_offering | currency_code | STRING | — |
| uat_hnx_stg | private_corp_bond_offering | term_unit | STRING | atomic.uat_atm | private_corp_bond_offering | bond_term_unit | STRING | — |
| uat_hnx_stg | private_corp_bond_offering | term | INT | atomic.uat_atm | private_corp_bond_offering | bond_term | INT | — |
| uat_hnx_stg | private_corp_bond_offering | issue_date | DATE | atomic.uat_atm | private_corp_bond_offering | issue_dt | DATE | — |
| uat_hnx_stg | private_corp_bond_offering | maturity_date | DATE | atomic.uat_atm | private_corp_bond_offering | maturity_dt | DATE | — |
| uat_hnx_stg | private_corp_bond_offering | remaining_term | INT | atomic.uat_atm | private_corp_bond_offering | remaining_bond_term | INT | — |
| uat_hnx_stg | private_corp_bond_offering | offering_volume | BIGINT | atomic.uat_atm | private_corp_bond_offering | offering_bond_quantity | BIGINT | — |
| uat_hnx_stg | private_corp_bond_offering | par_value | DECIMAL(18,2) | atomic.uat_atm | private_corp_bond_offering | par_val | BIGINT | — |
| uat_hnx_stg | private_corp_bond_offering | interest_payment_type | STRING | atomic.uat_atm | private_corp_bond_offering | interest_payment_tp | STRING | — |
| uat_hnx_stg | private_corp_bond_offering | interest_rate_type | STRING | atomic.uat_atm | private_corp_bond_offering | interest_rate_tp | STRING | — |
| uat_hnx_stg | private_corp_bond_offering | interest_payment_method | STRING | atomic.uat_atm | private_corp_bond_offering | interest_payment_method | STRING | — |
| uat_hnx_stg | private_corp_bond_offering | repurchase_and_swap | STRING | atomic.uat_atm | private_corp_bond_offering | repurchase_and_swap | STRING | — |
| uat_hnx_stg | private_corp_bond_offering | issue_market | STRING | atomic.uat_atm | private_corp_bond_offering | issue_market | STRING | — |
| uat_hnx_stg | private_corp_bond_offering | issue_interest_rate | DECIMAL(10,2) | atomic.uat_atm | private_corp_bond_offering | issue_interest_rate | DECIMAL(5,2) | — |
| uat_hnx_stg | private_corp_bond_offering | convertible_bond | STRING | atomic.uat_atm | private_corp_bond_offering | convertible_bond_ind | INT | — |
| uat_hnx_stg | private_corp_bond_offering | warrant_linked_bond | STRING | atomic.uat_atm | private_corp_bond_offering | warrant_linked_bond_ind | INT | — |
| uat_hnx_stg | private_corp_bond_offering | secured_bond | STRING | atomic.uat_atm | private_corp_bond_offering | secured_bond_ind | INT | — |
| — | — | — | — | atomic.uat_atm | private_corp_bond_offering | ds_snpst_dt | DATE | ⚙ Dev xử lý — không map từ nguồn |
| — | — | — | — | atomic.uat_atm | private_corp_bond_offering | ds_etl_pcs_tms | TIMESTAMP | ⚙ Dev xử lý — không map từ nguồn |


### Bảng 16: private_corp_bond_registration  →  private_corp_bond_registration

| Schema nguồn | Bảng nguồn | Trường nguồn | Kiểu DL nguồn | Schema atomic | Bảng atomic | Trường atomic | Kiểu DL atomic | Transformation / Ghi chú |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| — | — | (generated) | STRING | atomic.uat_atm | private_corp_bond_registration | private_corp_bond_registration_id | STRING | Surrogate key — UUID generated |
| — | — | (system) | STRING | atomic.uat_atm | private_corp_bond_registration | src_stm_code | STRING | Mã hệ thống nguồn — hardcode per pipeline |
| uat_hnx_stg | private_corp_bond_registration | bond_code | STRING | atomic.uat_atm | private_corp_bond_registration | bond_code | STRING | Business key |
| uat_hnx_stg | private_corp_bond_registration | currency | STRING | atomic.uat_atm | private_corp_bond_registration | currency_code | STRING | — |
| uat_hnx_stg | private_corp_bond_registration | issuer_name | STRING | atomic.uat_atm | private_corp_bond_registration | issuer_nm | STRING | — |
| uat_hnx_stg | private_corp_bond_registration | par_value | DECIMAL(18,2) | atomic.uat_atm | private_corp_bond_registration | par_val | BIGINT | — |
| uat_hnx_stg | private_corp_bond_registration | term_unit | STRING | atomic.uat_atm | private_corp_bond_registration | bond_term_unit | STRING | — |
| uat_hnx_stg | private_corp_bond_registration | remaining_term | INT | atomic.uat_atm | private_corp_bond_registration | remaining_bond_term | INT | — |
| uat_hnx_stg | private_corp_bond_registration | issue_date | DATE | atomic.uat_atm | private_corp_bond_registration | issue_dt | DATE | — |
| uat_hnx_stg | private_corp_bond_registration | maturity_date | DATE | atomic.uat_atm | private_corp_bond_registration | maturity_dt | DATE | — |
| uat_hnx_stg | private_corp_bond_registration | interest_payment_method | STRING | atomic.uat_atm | private_corp_bond_registration | interest_payment_method | STRING | — |
| uat_hnx_stg | private_corp_bond_registration | interest_payment_term | STRING | atomic.uat_atm | private_corp_bond_registration | interest_payment_term | STRING | — |
| uat_hnx_stg | private_corp_bond_registration | issued_volume | BIGINT | atomic.uat_atm | private_corp_bond_registration | issued_bond_quantity | BIGINT | — |
| uat_hnx_stg | private_corp_bond_registration | repurchased_converted_swapped_volume | BIGINT | atomic.uat_atm | private_corp_bond_registration | repurchased_converted_swapped_bond_quantity | BIGINT | — |
| uat_hnx_stg | private_corp_bond_registration | registered_trading_volume | BIGINT | atomic.uat_atm | private_corp_bond_registration | registered_trading_bond_quantity | BIGINT | — |
| uat_hnx_stg | private_corp_bond_registration | outstanding_volume | BIGINT | atomic.uat_atm | private_corp_bond_registration | outstanding_bond_quantity | BIGINT | — |
| uat_hnx_stg | private_corp_bond_registration | issue_interest_rate | DECIMAL(10,2) | atomic.uat_atm | private_corp_bond_registration | issue_interest_rate | DECIMAL(5,2) | — |
| uat_hnx_stg | private_corp_bond_registration | first_trading_date | DATE | atomic.uat_atm | private_corp_bond_registration | first_trading_date | DATE | — |
| uat_hnx_stg | private_corp_bond_registration | report_month | STRING | atomic.uat_atm | private_corp_bond_registration | rpt_month | STRING | — |
| — | — | — | — | atomic.uat_atm | private_corp_bond_registration | ds_snpst_dt | DATE | ⚙ Dev xử lý — không map từ nguồn |
| — | — | — | — | atomic.uat_atm | private_corp_bond_registration | ds_etl_pcs_tms | TIMESTAMP | ⚙ Dev xử lý — không map từ nguồn |


### Bảng 17: registration_status_change  →  bond_trading_registration_status

| Schema nguồn | Bảng nguồn | Trường nguồn | Kiểu DL nguồn | Schema atomic | Bảng atomic | Trường atomic | Kiểu DL atomic | Transformation / Ghi chú |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| — | — | (generated) | STRING | atomic.uat_atm | bond_trading_registration_status | bond_trading_registration_status_id | STRING | Surrogate key — UUID generated |
| — | — | (system) | STRING | atomic.uat_atm | bond_trading_registration_status | src_stm_code | STRING | Mã hệ thống nguồn — hardcode per pipeline |
| uat_hnx_stg | registration_status_change | bond_code | STRING | atomic.uat_atm | bond_trading_registration_status | bond_code | STRING | Business key |
| uat_hnx_stg | registration_status_change | trading_registration_status | STRING | atomic.uat_atm | bond_trading_registration_status | trading_registration_status | STRING | Business key |
| uat_hnx_stg | registration_status_change | issuer_name | STRING | atomic.uat_atm | bond_trading_registration_status | issuer_nm | STRING | — |
| uat_hnx_stg | registration_status_change | par_value | DECIMAL(18,2) | atomic.uat_atm | bond_trading_registration_status | par_val | BIGINT | — |
| uat_hnx_stg | registration_status_change | currently_registered_trading_volume | BIGINT | atomic.uat_atm | bond_trading_registration_status | registered_trading_bond_quantity | BIGINT | — |
| uat_hnx_stg | registration_status_change | first_trading_date | DATE | atomic.uat_atm | bond_trading_registration_status | first_trading_dt | DATE | — |
| uat_hnx_stg | registration_status_change | last_trading_date | DATE | atomic.uat_atm | bond_trading_registration_status | last_trading_dt | DATE | — |
| uat_hnx_stg | registration_status_change | report_month | STRING | atomic.uat_atm | bond_trading_registration_status | rpt_month | STRING | — |
| — | — | — | — | atomic.uat_atm | bond_trading_registration_status | ds_snpst_dt | DATE | ⚙ Dev xử lý — không map từ nguồn |
| — | — | — | — | atomic.uat_atm | bond_trading_registration_status | ds_etl_pcs_tms | TIMESTAMP | ⚙ Dev xử lý — không map từ nguồn |


### Bảng 18: listing_status_change (HNX)  +  Bảng 26: listing_status_change (HOSE)  →  listing_status_change

| Schema nguồn | Bảng nguồn | Trường nguồn | Kiểu DL nguồn | Schema atomic | Bảng atomic | Trường atomic | Kiểu DL atomic | Transformation / Ghi chú |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| — | — | (generated) | STRING | atomic.uat_atm | listing_status_change | listing_status_change_id | STRING | Surrogate key — UUID generated |
| — | — | (system) | STRING | atomic.uat_atm | listing_status_change | src_stm_code | STRING | Mã hệ thống nguồn — hardcode per pipeline |
| uat_hnx_stg / uat_hose_stg | listing_status_change | decision_no | STRING | atomic.uat_atm | listing_status_change | decision_nbr | STRING | Business key |
| uat_hnx_stg / uat_hose_stg | listing_status_change | decision_date | DATE | atomic.uat_atm | listing_status_change | decision_dt | DATE | Business key |
| uat_hnx_stg / uat_hose_stg | listing_status_change | ticker_symbol | STRING | atomic.uat_atm | listing_status_change | ticker_symbol | STRING | Business key |
| uat_hnx_stg / uat_hose_stg | listing_status_change | new_listed_shares | BIGINT | atomic.uat_atm | listing_status_change | new_listed_share_quantity | BIGINT | — |
| uat_hnx_stg / uat_hose_stg | listing_status_change | additional_listed_shares | BIGINT | atomic.uat_atm | listing_status_change | additional_listed_share_quantity | BIGINT | — |
| uat_hnx_stg / uat_hose_stg | listing_status_change | delisted_shares | BIGINT | atomic.uat_atm | listing_status_change | delisted_share_quantity | BIGINT | — |
| uat_hnx_stg / uat_hose_stg | listing_status_change | exchange_transfer | STRING | atomic.uat_atm | listing_status_change | exchange_transfer | STRING | — |
| uat_hnx_stg / uat_hose_stg | listing_status_change | listed_value | DECIMAL(18,2) | atomic.uat_atm | listing_status_change | listed_share_val | DECIMAL(23,2) | — |
| uat_hnx_stg / uat_hose_stg | listing_status_change | additional_listed_value | DECIMAL(18,2) | atomic.uat_atm | listing_status_change | additional_listed_share_val | DECIMAL(23,2) | — |
| uat_hnx_stg / uat_hose_stg | listing_status_change | delisted_value | DECIMAL(18,2) | atomic.uat_atm | listing_status_change | delisted_share_val | DECIMAL(23,2) | — |
| uat_hnx_stg / uat_hose_stg | listing_status_change | issuer_name | STRING | atomic.uat_atm | listing_status_change | issuer_nm | STRING | — |
| uat_hnx_stg / uat_hose_stg | listing_status_change | effective_date | DATE | atomic.uat_atm | listing_status_change | effective_dt | DATE | — |
| uat_hnx_stg / uat_hose_stg | listing_status_change | first_trading_date | DATE | atomic.uat_atm | listing_status_change | first_trading_dt | DATE | — |
| uat_hnx_stg / uat_hose_stg | listing_status_change | last_trading_date | DATE | atomic.uat_atm | listing_status_change | last_trading_dt | DATE | — |
| uat_hnx_stg / uat_hose_stg | listing_status_change | delist_transfer_reason | STRING | atomic.uat_atm | listing_status_change | delist_transfer_reason | STRING | — |
| uat_hnx_stg / uat_hose_stg | listing_status_change | report_month | STRING | atomic.uat_atm | listing_status_change | rpt_month | STRING | — |
| — | — | — | — | atomic.uat_atm | listing_status_change | ds_snpst_dt | DATE | ⚙ Dev xử lý — không map từ nguồn |
| — | — | — | — | atomic.uat_atm | listing_status_change | ds_etl_pcs_tms | TIMESTAMP | ⚙ Dev xử lý — không map từ nguồn |


### Bảng 20: brokerage_market_share (HNX)  +  Bảng 28: brokerage_market_share (HOSE)  →  brokerage_market_share

| Schema nguồn | Bảng nguồn | Trường nguồn | Kiểu DL nguồn | Schema atomic | Bảng atomic | Trường atomic | Kiểu DL atomic | Transformation / Ghi chú |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| — | — | (generated) | STRING | atomic.uat_atm | brokerage_market_share | brokerage_market_share_id | STRING | Surrogate key — UUID generated |
| — | — | (system) | STRING | atomic.uat_atm | brokerage_market_share | src_stm_code | STRING | Mã hệ thống nguồn — hardcode per pipeline |
| uat_hnx_stg / uat_hose_stg | brokerage_market_share | member_code | STRING | atomic.uat_atm | brokerage_market_share | sc_member_code | STRING | Business key |
| uat_hnx_stg / uat_hose_stg | brokerage_market_share | broker_name | STRING | atomic.uat_atm | brokerage_market_share | sc_nm | STRING | — |
| uat_hnx_stg / uat_hose_stg | brokerage_market_share | total_trading_value | DECIMAL(18,2) | atomic.uat_atm | brokerage_market_share | total_trading_val | DECIMAL(23,2) | — |
| uat_hnx_stg / uat_hose_stg | brokerage_market_share | market_share_by_value | DECIMAL(10,2) | atomic.uat_atm | brokerage_market_share | market_share_by_val | DECIMAL(5,2) | — |
| uat_hnx_stg / uat_hose_stg | brokerage_market_share | classification | STRING | atomic.uat_atm | brokerage_market_share | security_tp_code | STRING | — |
| uat_hnx_stg / uat_hose_stg | brokerage_market_share | report_quarter | STRING | atomic.uat_atm | brokerage_market_share | rpt_quarter | STRING | — |
| — | — | — | — | atomic.uat_atm | brokerage_market_share | ds_snpst_dt | DATE | ⚙ Dev xử lý — không map từ nguồn |
| — | — | — | — | atomic.uat_atm | brokerage_market_share | ds_etl_pcs_tms | TIMESTAMP | ⚙ Dev xử lý — không map từ nguồn |


### Bảng 21: outright_order_book  +  22: repo_order_book  +  23: repo2_order_book  →  bond_order_book

| Schema nguồn | Bảng nguồn | Trường nguồn | Kiểu DL nguồn | Schema atomic | Bảng atomic | Trường atomic | Kiểu DL atomic | Transformation / Ghi chú |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| — | — | (generated) | STRING | atomic.uat_atm | bond_order_book | bond_order_book_id | STRING | Surrogate key — UUID generated |
| — | — | (system) | STRING | atomic.uat_atm | bond_order_book | src_stm_code | STRING | Mã hệ thống nguồn — hardcode per pipeline |
| — | (derived) | — | — | atomic.uat_atm | bond_order_book | order_book_type | STRING | Hardcode: 'OUTRIGHT'/'REPO'/'REPO2' theo bảng nguồn |
| uat_hnx_stg | All 3 | order_no | STRING | atomic.uat_atm | bond_order_book | order_nbr | STRING | Business key |
| uat_hnx_stg | All 3 | original_order_no | STRING | atomic.uat_atm | bond_order_book | original_order_nbr | STRING | — |
| uat_hnx_stg | All 3 | time | STRING | atomic.uat_atm | bond_order_book | order_time | STRING | — |
| uat_hnx_stg | All 3 | order_type | STRING | atomic.uat_atm | bond_order_book | order_tp | STRING | — |
| uat_hnx_stg | All 3 | order_side | STRING | atomic.uat_atm | bond_order_book | order_side | STRING | — |
| uat_hnx_stg | All 3 | order_status | STRING | atomic.uat_atm | bond_order_book | order_status | STRING | — |
| uat_hnx_stg | All 3 | order_creator_rep | STRING | atomic.uat_atm | bond_order_book | order_creator_rep | STRING | — |
| uat_hnx_stg | All 3 | bond_code | STRING | atomic.uat_atm | bond_order_book | bond_code | STRING | — |
| uat_hnx_stg | All 3 | instrument_type | STRING | atomic.uat_atm | bond_order_book | instrument_tp | STRING | — |
| uat_hnx_stg | All 3 | interest_payment_type | STRING | atomic.uat_atm | bond_order_book | interest_payment_tp | STRING | — |
| uat_hnx_stg | All 3 | interest_payment_method | STRING | atomic.uat_atm | bond_order_book | interest_payment_method | STRING | — |
| uat_hnx_stg | All 3 | interest_rate_type | STRING | atomic.uat_atm | bond_order_book | interest_rate_tp | STRING | — |
| uat_hnx_stg | All 3 | remaining_term_days | BIGINT | atomic.uat_atm | bond_order_book | remaining_term_days | BIGINT | — |
| uat_hnx_stg | All 3 | remaining_term | STRING | atomic.uat_atm | bond_order_book | remaining_term | STRING | — |
| uat_hnx_stg | All 3 | currency_code | STRING | atomic.uat_atm | bond_order_book | currency_code | STRING | — |
| uat_hnx_stg | All 3 | quoted_price | DECIMAL(18,4) | atomic.uat_atm | bond_order_book | quoted_price | DECIMAL(23,4) | — |
| uat_hnx_stg | All 3 | execution_price | DECIMAL(18,4) | atomic.uat_atm | bond_order_book | execution_price | DECIMAL(23,4) | — |
| uat_hnx_stg | All 3 | yield_rate | DECIMAL(10,4) | atomic.uat_atm | bond_order_book | yield_rate | DECIMAL(7,4) | — |
| uat_hnx_stg | All 3 | discount_rate | DECIMAL(10,4) | atomic.uat_atm | bond_order_book | discount_rate | DECIMAL(7,4) | — |
| uat_hnx_stg | All 3 | volume | BIGINT | atomic.uat_atm | bond_order_book | order_bond_quantity | BIGINT | — |
| uat_hnx_stg | All 3 | trading_method | STRING | atomic.uat_atm | bond_order_book | trading_method | STRING | — |
| uat_hnx_stg | All 3 | trading_date | DATE | atomic.uat_atm | bond_order_book | trading_dt | DATE | Partition key |
| uat_hnx_stg | outright_order_book | trading_value | DECIMAL(18,2) | atomic.uat_atm | bond_order_book | trading_val | DECIMAL(23,2) | NULL với REPO/REPO2 |
| uat_hnx_stg | All 3 | settlement_method | STRING | atomic.uat_atm | bond_order_book | settlement_method | STRING | — |
| uat_hnx_stg | All 3 | payment_status | STRING | atomic.uat_atm | bond_order_book | payment_status | STRING | — |
| uat_hnx_stg | All 3 | selling_member_code | STRING | atomic.uat_atm | bond_order_book | selling_member_code | STRING | — |
| uat_hnx_stg | All 3 | selling_rep | STRING | atomic.uat_atm | bond_order_book | selling_rep | STRING | — |
| uat_hnx_stg | All 3 | selling_account_no | STRING | atomic.uat_atm | bond_order_book | selling_account_nbr | STRING | — |
| uat_hnx_stg | All 3 | selling_broker_dealer | STRING | atomic.uat_atm | bond_order_book | selling_broker_dealer | STRING | — |
| uat_hnx_stg | All 3 | selling_proxy_entry | STRING | atomic.uat_atm | bond_order_book | selling_proxy_entry | STRING | — |
| uat_hnx_stg | All 3 | buying_member_code | STRING | atomic.uat_atm | bond_order_book | buying_member_code | STRING | — |
| uat_hnx_stg | All 3 | buying_rep | STRING | atomic.uat_atm | bond_order_book | buying_rep | STRING | — |
| uat_hnx_stg | All 3 | buying_account_no | STRING | atomic.uat_atm | bond_order_book | buying_account_nbr | STRING | — |
| uat_hnx_stg | All 3 | buying_broker_dealer | STRING | atomic.uat_atm | bond_order_book | buying_broker_dealer | STRING | — |
| uat_hnx_stg | All 3 | buying_proxy_entry | STRING | atomic.uat_atm | bond_order_book | buying_proxy_entry | STRING | — |
| uat_hnx_stg | outright_order_book | settlement_date | DATE | atomic.uat_atm | bond_order_book | settlement_dt | DATE | NULL với REPO, REPO2 |
| uat_hnx_stg | outright_order_book + repo2_order_book | settlement_status | STRING | atomic.uat_atm | bond_order_book | settlement_status | STRING | NULL với REPO |
| uat_hnx_stg | outright_order_book + repo2_order_book | settlement_bond_code | STRING | atomic.uat_atm | bond_order_book | settlement_bond_code | STRING | NULL với REPO |
| uat_hnx_stg | outright_order_book + repo2_order_book | settlement_volume | BIGINT | atomic.uat_atm | bond_order_book | settlement_bond_quantity | BIGINT | NULL với REPO |
| uat_hnx_stg | outright_order_book + repo2_order_book | equivalent_bond_settlement_value | DECIMAL(18,2) | atomic.uat_atm | bond_order_book | equivalent_bond_settlement_val | DECIMAL(23,2) | NULL với REPO |
| uat_hnx_stg | repo_order_book + repo2_order_book | par_value | DECIMAL(18,2) | atomic.uat_atm | bond_order_book | par_val | DECIMAL(23,2) | NULL với OUTRIGHT |
| uat_hnx_stg | repo_order_book + repo2_order_book | repo_term | BIGINT | atomic.uat_atm | bond_order_book | repo_term | BIGINT | NULL với OUTRIGHT |
| uat_hnx_stg | repo_order_book + repo2_order_book | repo_rate | DECIMAL(10,4) | atomic.uat_atm | bond_order_book | repo_rate | DECIMAL(7,4) | NULL với OUTRIGHT |
| uat_hnx_stg | repo_order_book + repo2_order_book | repo_interest | DECIMAL(18,2) | atomic.uat_atm | bond_order_book | repo_interest | DECIMAL(23,2) | NULL với OUTRIGHT |
| uat_hnx_stg | repo_order_book + repo2_order_book | risk_margin_ratio | DECIMAL(10,2) | atomic.uat_atm | bond_order_book | risk_margin_ratio | DECIMAL(5,2) | NULL với OUTRIGHT |
| uat_hnx_stg | repo_order_book + repo2_order_book | coupon_rate | DECIMAL(10,4) | atomic.uat_atm | bond_order_book | coupon_rate | DECIMAL(7,4) | NULL với OUTRIGHT |
| uat_hnx_stg | repo_order_book + repo2_order_book | coupon_interest | DECIMAL(18,2) | atomic.uat_atm | bond_order_book | coupon_interest | DECIMAL(23,2) | NULL với OUTRIGHT |
| uat_hnx_stg | repo_order_book + repo2_order_book | receive_coupon_interest | STRING | atomic.uat_atm | bond_order_book | receive_coupon_interest_ind | INT | NULL với OUTRIGHT |
| uat_hnx_stg | repo_order_book + repo2_order_book | interest_on_coupon | DECIMAL(18,2) | atomic.uat_atm | bond_order_book | interest_on_coupon | DECIMAL(23,2) | NULL với OUTRIGHT |
| uat_hnx_stg | repo_order_book + repo2_order_book | first_settlement_date | DATE | atomic.uat_atm | bond_order_book | first_settlement_dt | DATE | NULL với OUTRIGHT |
| uat_hnx_stg | repo_order_book + repo2_order_book | first_settlement_value | DECIMAL(18,2) | atomic.uat_atm | bond_order_book | first_settlement_val | DECIMAL(23,2) | NULL với OUTRIGHT |
| uat_hnx_stg | repo_order_book + repo2_order_book | second_settlement_date | DATE | atomic.uat_atm | bond_order_book | second_settlement_dt | DATE | NULL với OUTRIGHT |
| uat_hnx_stg | repo_order_book + repo2_order_book | second_settlement_value | DECIMAL(18,2) | atomic.uat_atm | bond_order_book | second_settlement_val | DECIMAL(23,2) | NULL với OUTRIGHT |
| uat_hnx_stg | repo_order_book + repo2_order_book | end_trading_date | DATE | atomic.uat_atm | bond_order_book | end_trading_dt | DATE | NULL với OUTRIGHT |
| uat_hnx_stg | repo2_order_book | mark_settlement_bond | STRING | atomic.uat_atm | bond_order_book | mark_settlement_bond_ind | INT | NULL với OUTRIGHT, REPO |
| — | — | — | — | atomic.uat_atm | bond_order_book | ds_snpst_dt | DATE | ⚙ Dev xử lý — không map từ nguồn |
| — | — | — | — | atomic.uat_atm | bond_order_book | ds_etl_pcs_tms | TIMESTAMP | ⚙ Dev xử lý — không map từ nguồn |

---

## Business Key & Filter

| # | Schema | Bảng atomic | Business Key | Trường lọc (Filter) | Ghi chú |
| --- | --- | --- | --- | --- | --- |
| 1 | atomic.uat_atm | listed_share_info | ticker_symbol | ds_snpst_dt | — |
| 2 | atomic.uat_atm | foreign_ownership_info | ticker_symbol | ds_snpst_dt | — |
| 3 | atomic.uat_atm | major_shareholder_ownership | ticker_symbol, identification_nbr | ds_snpst_dt | — |
| 4 | atomic.uat_atm | end_of_day_open_interest | ticker_symbol | ds_snpst_dt | — |
| 5 | atomic.uat_atm | depository_account_movement | depository_member_code | ds_snpst_dt | — |
| 6 | atomic.uat_atm | foreign_bond_portfolio | foreign_investor_code | ds_snpst_dt | — |
| 7 | atomic.uat_atm | share_auction_result | issuer_nm, auction_tp | ds_snpst_dt | — |
| 8 | atomic.uat_atm | private_corp_bond_trading_summary | indicator_nm | ds_snpst_dt | — |
| 9 | atomic.uat_atm | gov_bond_bidding_result | bidding_session | ds_snpst_dt | — |
| 10 | atomic.uat_atm | gov_bond_listing | bond_code | ds_snpst_dt | — |
| 11 | atomic.uat_atm | additional_gov_bond_listing | bond_code, listing_status, listing_change_dt | ds_snpst_dt | — |
| 12 | atomic.uat_atm | private_corp_bond_offering | bond_code, market_tp, posting_dt | ds_snpst_dt | — |
| 13 | atomic.uat_atm | private_corp_bond_registration | bond_code | ds_snpst_dt | — |
| 14 | atomic.uat_atm | bond_trading_registration_status | bond_code, trading_registration_status | ds_snpst_dt | — |
| 15 | atomic.uat_atm | listing_status_change | decision_nbr, decision_dt, ticker_symbol | ds_snpst_dt | — |
| 16 | atomic.uat_atm | brokerage_market_share | sc_member_code | ds_snpst_dt | — |
| 17 | atomic.uat_atm | bond_order_book | order_nbr | ds_snpst_dt | — |
| 18 | atomic.uat_atm | open_investor_account | investor_account_nbr | ds_snpst_dt | — |
| 19 | atomic.uat_atm | closed_investor_account | investor_account_nbr | ds_snpst_dt | — |
| 20 | atomic.uat_atm | updated_investor_account | investor_account_nbr | ds_snpst_dt | — |

---

## Chú giải

### Màu sắc

| Màu nền | Ý nghĩa |
| --- | --- |
| Xanh dương nhạt (cols 1–4) | Dữ liệu thuộc bảng nguồn (staging) |
| Xanh lá nhạt (cols 5–8) | Map thẳng sang atomic — rename thuần |
| Vàng nhạt | Có transformation: CAST, LOOKUP, DERIVE, đổi precision |
| Cam nhạt | NULL theo loại nguồn (đặc thù bond_order_book) |
| Tím nhạt | Surrogate key — tự sinh, không từ nguồn |
| Xám nhạt | Metadata/ETL: src_stm_code, ds_snpst_dt, ds_etl_pcs_tms |

### Lưu ý

| Mục | Nội dung |
| --- | --- |
| Bảng 2/3/4 | open/closed/updated_investors map thành 3 bảng atomic độc lập: open_/closed_/updated_investor_account |
| Thứ tự trường | Theo đúng thứ tự DDL file vsdc_atomic.sql |

### Pattern đặt tên

| Pattern | Ý nghĩa |
| --- | --- |
| date → dt | Rút gọn date |
| volume → quantity | Số lượng đơn vị CK/TP |
| shares → share_quantity | Số lượng cổ phiếu |
| _type → _tp | Rút gọn category fields |
| _name → _nm | Rút gọn name fields |
| _ind suffix | Boolean flag (Map 1/0 từ Có/Không) |
| begin_ → opening_ / end_ → closing_ | Chuẩn hóa kỳ đầu/cuối |
