# Source to Atomic Mapping


## PHẦN 1: SCHEMA VSDC (uat_vsdc_stg)


### Bảng 1: outstanding_shares  +  Bảng 19/27: listed_securities_list (HNX/HOSE)  →  listed_share_info

| Schema nguồn | Bảng nguồn | Trường nguồn | Kiểu DL nguồn | Schema atomic | Bảng atomic | Trường atomic | Kiểu DL atomic | Transformation / Ghi chú |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| — | — | (generated) | STRING | atomic.uat_atm | listed_share_info | listed_share_info_id | STRING | Surrogate key — UUID generated |
| — | — | (system) | STRING | atomic.uat_atm | listed_share_info | src_stm_code | STRING | Mã hệ thống nguồn — hardcode per pipeline |
| uat_vsdc_stg | outstanding_shares | ticker_symbol | STRING | atomic.uat_atm | listed_share_info | ticker_symbol | STRING | Giữ nguyên — business key |
| uat_vsdc_stg | outstanding_shares | isin_code | STRING | atomic.uat_atm | listed_share_info | isin_code | STRING | Giữ nguyên |
| uat_vsdc_stg | outstanding_shares | total_issued_shares | BIGINT | atomic.uat_atm | listed_share_info | total_issued_share_quantity | BIGINT | Đổi tên: thêm _quantity |
| uat_vsdc_stg | outstanding_shares | treasury_shares | BIGINT | atomic.uat_atm | listed_share_info | treasury_share_quantity | BIGINT | Đổi tên: thêm _quantity |
| uat_vsdc_stg | outstanding_shares | outstanding_shares | BIGINT | atomic.uat_atm | listed_share_info | outstanding_share_quantity | BIGINT | Đổi tên: thêm _quantity |
| uat_vsdc_stg | outstanding_shares | free_float_shares | BIGINT | atomic.uat_atm | listed_share_info | free_float_share_quantity | BIGINT | Đổi tên: thêm _quantity |
| uat_vsdc_stg | outstanding_shares | restricted_shares | BIGINT | atomic.uat_atm | listed_share_info | restricted_share_quantity | BIGINT | Đổi tên: thêm _quantity |
| uat_vsdc_stg | outstanding_shares | voting_shares | BIGINT | atomic.uat_atm | listed_share_info | voting_share_quantity | BIGINT | Đổi tên: thêm _quantity |
| uat_hnx_stg / uat_hose_stg | listed_securities_list | issuer_name | STRING | atomic.uat_atm | listed_share_info | issuer_name | STRING | Bổ sung từ listed_securities_list |
| uat_hnx_stg / uat_hose_stg | listed_securities_list | listed_shares | BIGINT | atomic.uat_atm | listed_share_info | listed_share_quantity | BIGINT | Đổi tên: thêm _quantity |
| uat_hnx_stg / uat_hose_stg | listed_securities_list | reference_price | DECIMAL(18,2) | atomic.uat_atm | listed_share_info | reference_price | DECIMAL(23,2) | Đổi precision |
| — | — | — | — | atomic.uat_atm | listed_share_info | ds_snpst_dt | DATE | ⚙ Dev xử lý — không map từ nguồn |
| — | — | — | — | atomic.uat_atm | listed_share_info | ds_snpst_dt | DATE | ⚙ Dev xử lý — không map từ nguồn |
| — | — | — | — | atomic.uat_atm | listed_share_info | ds_etl_pcs_tms | TIMESTAMP | ⚙ Dev xử lý — không map từ nguồn |


### Bảng 9: foreign_investor_info  →  foreign_ownership_info

| Schema nguồn | Bảng nguồn | Trường nguồn | Kiểu DL nguồn | Schema atomic | Bảng atomic | Trường atomic | Kiểu DL atomic | Transformation / Ghi chú |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| — | — | (generated) | STRING | atomic.uat_atm | foreign_ownership_info | foreign_ownership_info_id | STRING | Surrogate key — UUID generated |
| — | — | (system) | STRING | atomic.uat_atm | foreign_ownership_info | src_stm_code | STRING | Mã hệ thống nguồn — hardcode per pipeline |
| uat_vsdc_stg | foreign_investor_info | ticker_symbol | STRING | atomic.uat_atm | foreign_ownership_info | ticker_symbol | STRING | Giữ nguyên — business key |
| uat_vsdc_stg | foreign_investor_info | isin_code | STRING | atomic.uat_atm | foreign_ownership_info | isin_code | STRING | Giữ nguyên |
| uat_vsdc_stg | foreign_investor_info | total_issued_shares | BIGINT | atomic.uat_atm | foreign_ownership_info | total_issued_share_quantity | BIGINT | Đổi tên: thêm _quantity |
| uat_vsdc_stg | foreign_investor_info | max_foreign_ownership_ratio | DECIMAL(10,2) | atomic.uat_atm | foreign_ownership_info | max_foreign_ownership_ratio | DECIMAL(5,2) | Đổi precision |
| uat_vsdc_stg | foreign_investor_info | max_shares_foreign_can_hold | BIGINT | atomic.uat_atm | foreign_ownership_info | max_foreign_holding_quantity | BIGINT | Đổi tên rõ nghĩa |
| uat_vsdc_stg | foreign_investor_info | current_shares_foreign_hold | BIGINT | atomic.uat_atm | foreign_ownership_info | current_foreign_holding_quantity | BIGINT | Đổi tên rõ nghĩa |
| uat_vsdc_stg | foreign_investor_info | remaining_shares_foreign_can_hold | BIGINT | atomic.uat_atm | foreign_ownership_info | remaining_foreign_holding_quantity | BIGINT | Đổi tên rõ nghĩa |
| — | — | — | — | atomic.uat_atm | foreign_ownership_info | ds_snpst_dt | DATE | ⚙ Dev xử lý — không map từ nguồn |
| — | — | — | — | atomic.uat_atm | foreign_ownership_info | ds_snpst_dt | DATE | ⚙ Dev xử lý — không map từ nguồn |
| — | — | — | — | atomic.uat_atm | foreign_ownership_info | ds_etl_pcs_tms | TIMESTAMP | ⚙ Dev xử lý — không map từ nguồn |


### Bảng 5: major_shareholder  →  major_shareholder_ownership

| Schema nguồn | Bảng nguồn | Trường nguồn | Kiểu DL nguồn | Schema atomic | Bảng atomic | Trường atomic | Kiểu DL atomic | Transformation / Ghi chú |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| — | — | (generated) | STRING | atomic.uat_atm | major_shareholder_ownership | major_shareholder_ownership_id | STRING | Surrogate key — UUID generated |
| — | — | (system) | STRING | atomic.uat_atm | major_shareholder_ownership | src_stm_code | STRING | Mã hệ thống nguồn — hardcode per pipeline |
| uat_vsdc_stg | major_shareholder | ticker_symbol | STRING | atomic.uat_atm | major_shareholder_ownership | ticker_symbol | STRING | Giữ nguyên — business key |
| uat_vsdc_stg | major_shareholder | isin_code | STRING | atomic.uat_atm | major_shareholder_ownership | isin_code | STRING | Giữ nguyên |
| uat_vsdc_stg | major_shareholder | shareholder_name | STRING | atomic.uat_atm | major_shareholder_ownership | major_shareholder_nm | STRING | Đổi tên |
| uat_vsdc_stg | major_shareholder | id_number | STRING | atomic.uat_atm | major_shareholder_ownership | identification_nbr | STRING | Đổi tên — business key |
| uat_vsdc_stg | major_shareholder | issue_date | DATE | atomic.uat_atm | major_shareholder_ownership | issue_dt | DATE | Đổi tên |
| uat_vsdc_stg | major_shareholder | contact_address | STRING | atomic.uat_atm | major_shareholder_ownership | address | STRING | Đổi tên rút gọn |
| uat_vsdc_stg | major_shareholder | voting_shares | DECIMAL(18,0) | atomic.uat_atm | major_shareholder_ownership | voting_share_quantity | BIGINT | Đổi tên + CAST DECIMAL→BIGINT |
| uat_vsdc_stg | major_shareholder | begin_period_date | DATE | atomic.uat_atm | major_shareholder_ownership | opening_balance_date | DATE | begin→opening |
| uat_vsdc_stg | major_shareholder | begin_period_shares | DECIMAL(18,0) | atomic.uat_atm | major_shareholder_ownership | opening_share_quantity | BIGINT | Đổi tên + CAST |
| uat_vsdc_stg | major_shareholder | begin_period_ratio | DECIMAL(10,2) | atomic.uat_atm | major_shareholder_ownership | opening_ratio | DECIMAL(7,4) | Đổi tên + đổi precision |
| uat_vsdc_stg | major_shareholder | end_period_date | DATE | atomic.uat_atm | major_shareholder_ownership | closing_balance_date | DATE | end→closing |
| uat_vsdc_stg | major_shareholder | end_period_shares | DECIMAL(18,0) | atomic.uat_atm | major_shareholder_ownership | closing_share_quantity | BIGINT | Đổi tên + CAST |
| uat_vsdc_stg | major_shareholder | end_period_ratio | DECIMAL(10,2) | atomic.uat_atm | major_shareholder_ownership | closing_ratio | DECIMAL(7,4) | Đổi tên + đổi precision |
| uat_vsdc_stg | major_shareholder | notes | STRING | atomic.uat_atm | major_shareholder_ownership | note | STRING | Đổi tên rút gọn |
| — | — | — | — | atomic.uat_atm | major_shareholder_ownership | ds_snpst_dt | DATE | ⚙ Dev xử lý — không map từ nguồn |
| — | — | — | — | atomic.uat_atm | major_shareholder_ownership | ds_snpst_dt | DATE | ⚙ Dev xử lý — không map từ nguồn |
| — | — | — | — | atomic.uat_atm | major_shareholder_ownership | ds_etl_pcs_tms | TIMESTAMP | ⚙ Dev xử lý — không map từ nguồn |


### Bảng 6: end_of_day_open_interest  →  end_of_day_open_interest

| Schema nguồn | Bảng nguồn | Trường nguồn | Kiểu DL nguồn | Schema atomic | Bảng atomic | Trường atomic | Kiểu DL atomic | Transformation / Ghi chú |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| — | — | (generated) | STRING | atomic.uat_atm | end_of_day_open_interest | end_of_day_open_interest_id | STRING | Surrogate key — UUID generated |
| — | — | (system) | STRING | atomic.uat_atm | end_of_day_open_interest | src_stm_code | STRING | Mã hệ thống nguồn — hardcode per pipeline |
| uat_vsdc_stg | end_of_day_open_interest | contract_code | STRING | atomic.uat_atm | end_of_day_open_interest | ticker_symbol | STRING | Đổi tên: contract_code → ticker_symbol |
| uat_vsdc_stg | end_of_day_open_interest | open_interest_volume | BIGINT | atomic.uat_atm | end_of_day_open_interest | open_interest_quantity | BIGINT | volume→quantity |
| — | — | — | — | atomic.uat_atm | end_of_day_open_interest | ds_snpst_dt | DATE | ⚙ Dev xử lý — không map từ nguồn |
| — | — | — | — | atomic.uat_atm | end_of_day_open_interest | ds_snpst_dt | DATE | ⚙ Dev xử lý — không map từ nguồn |
| — | — | — | — | atomic.uat_atm | end_of_day_open_interest | ds_etl_pcs_tms | TIMESTAMP | ⚙ Dev xử lý — không map từ nguồn |


### Bảng 7: account_opening_closing_status  →  depository_account_movement

| Schema nguồn | Bảng nguồn | Trường nguồn | Kiểu DL nguồn | Schema atomic | Bảng atomic | Trường atomic | Kiểu DL atomic | Transformation / Ghi chú |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| — | — | (generated) | STRING | atomic.uat_atm | depository_account_movement | depository_account_movement_id | STRING | Surrogate key — UUID generated |
| — | — | (system) | STRING | atomic.uat_atm | depository_account_movement | src_stm_code | STRING | Mã hệ thống nguồn — hardcode per pipeline |
| uat_vsdc_stg | account_opening_closing_status | depository_member | STRING | atomic.uat_atm | depository_account_movement | depository_member_code | STRING | Thêm _code |
| uat_vsdc_stg | account_opening_closing_status | begin_period_dom_indiv_accounts | BIGINT | atomic.uat_atm | depository_account_movement | opening_domestic_individual_account_count | BIGINT | begin→opening, viết tắt→đầy đủ, thêm _count |
| uat_vsdc_stg | account_opening_closing_status | begin_period_dom_inst_accounts | BIGINT | atomic.uat_atm | depository_account_movement | opening_domestic_institutional_account_count | BIGINT | Đổi tên |
| uat_vsdc_stg | account_opening_closing_status | begin_period_for_indiv_accounts | BIGINT | atomic.uat_atm | depository_account_movement | opening_foreign_individual_account_count | BIGINT | Đổi tên |
| uat_vsdc_stg | account_opening_closing_status | begin_period_for_inst_accounts | BIGINT | atomic.uat_atm | depository_account_movement | opening_foreign_institutional_account_count | BIGINT | Đổi tên |
| uat_vsdc_stg | account_opening_closing_status | begin_period_total_accounts | BIGINT | atomic.uat_atm | depository_account_movement | opening_total_account_count | BIGINT | Đổi tên |
| uat_vsdc_stg | account_opening_closing_status | opened_dom_indiv_accounts | BIGINT | atomic.uat_atm | depository_account_movement | opened_domestic_individual_account_count | BIGINT | Đổi tên |
| uat_vsdc_stg | account_opening_closing_status | opened_dom_inst_accounts | BIGINT | atomic.uat_atm | depository_account_movement | opened_domestic_institutional_account_count | BIGINT | Đổi tên |
| uat_vsdc_stg | account_opening_closing_status | opened_for_indiv_accounts | BIGINT | atomic.uat_atm | depository_account_movement | opened_foreign_individual_account_count | BIGINT | Đổi tên |
| uat_vsdc_stg | account_opening_closing_status | opened_for_inst_accounts | BIGINT | atomic.uat_atm | depository_account_movement | opened_foreign_institutional_account_count | BIGINT | Đổi tên |
| uat_vsdc_stg | account_opening_closing_status | closed_dom_indiv_accounts | BIGINT | atomic.uat_atm | depository_account_movement | closed_domestic_individual_account_count | BIGINT | Đổi tên |
| uat_vsdc_stg | account_opening_closing_status | closed_dom_inst_accounts | BIGINT | atomic.uat_atm | depository_account_movement | closed_domestic_institutional_account_count | BIGINT | Đổi tên |
| uat_vsdc_stg | account_opening_closing_status | closed_for_indiv_accounts | BIGINT | atomic.uat_atm | depository_account_movement | closed_foreign_individual_account_count | BIGINT | Đổi tên |
| uat_vsdc_stg | account_opening_closing_status | closed_for_inst_accounts | BIGINT | atomic.uat_atm | depository_account_movement | closed_foreign_institutional_account_count | BIGINT | Đổi tên |
| uat_vsdc_stg | account_opening_closing_status | end_period_dom_indiv_accounts | BIGINT | atomic.uat_atm | depository_account_movement | closing_domestic_individual_account_count | BIGINT | end→closing, thêm _count |
| uat_vsdc_stg | account_opening_closing_status | end_period_dom_inst_accounts | BIGINT | atomic.uat_atm | depository_account_movement | closing_domestic_institutional_account_count | BIGINT | Đổi tên |
| uat_vsdc_stg | account_opening_closing_status | end_period_for_indiv_accounts | BIGINT | atomic.uat_atm | depository_account_movement | closing_foreign_individual_account_count | BIGINT | Đổi tên |
| uat_vsdc_stg | account_opening_closing_status | end_period_for_inst_accounts | BIGINT | atomic.uat_atm | depository_account_movement | closing_foreign_institutional_account_count | BIGINT | Đổi tên |
| uat_vsdc_stg | account_opening_closing_status | total_accounts | BIGINT | atomic.uat_atm | depository_account_movement | closing_total_account_count | BIGINT | Thêm closing_ và _count |
| uat_vsdc_stg | account_opening_closing_status | notes | STRING | atomic.uat_atm | depository_account_movement | notes | STRING | Giữ nguyên |
| — | — | — | — | atomic.uat_atm | depository_account_movement | ds_snpst_dt | DATE | ⚙ Dev xử lý — không map từ nguồn |
| — | — | — | — | atomic.uat_atm | depository_account_movement | ds_snpst_dt | DATE | ⚙ Dev xử lý — không map từ nguồn |
| — | — | — | — | atomic.uat_atm | depository_account_movement | ds_etl_pcs_tms | TIMESTAMP | ⚙ Dev xử lý — không map từ nguồn |


### Bảng 8: foreign_investor_bond_portfolio  →  foreign_bond_portfolio

| Schema nguồn | Bảng nguồn | Trường nguồn | Kiểu DL nguồn | Schema atomic | Bảng atomic | Trường atomic | Kiểu DL atomic | Transformation / Ghi chú |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| — | — | (generated) | STRING | atomic.uat_atm | foreign_bond_portfolio | foreign_bond_portfolio_id | STRING | Surrogate key — UUID generated |
| — | — | (system) | STRING | atomic.uat_atm | foreign_bond_portfolio | src_stm_code | STRING | Mã hệ thống nguồn — hardcode per pipeline |
| uat_vsdc_stg | foreign_investor_bond_portfolio | trading_code | STRING | atomic.uat_atm | foreign_bond_portfolio | foreign_investor_code | STRING | Đổi tên: mã định danh duy nhất NĐT NN |
| uat_vsdc_stg | foreign_investor_bond_portfolio | investor_name | STRING | atomic.uat_atm | foreign_bond_portfolio | foreign_investor_name | STRING | Thêm foreign_ |
| uat_vsdc_stg | foreign_investor_bond_portfolio | investor_category | STRING | atomic.uat_atm | foreign_bond_portfolio | foreign_investor_tp_code | STRING | category→tp_code |
| uat_vsdc_stg | foreign_investor_bond_portfolio | nationality | STRING | atomic.uat_atm | foreign_bond_portfolio | nationality_code | STRING | Thêm _code |
| uat_vsdc_stg | foreign_investor_bond_portfolio | address | STRING | atomic.uat_atm | foreign_bond_portfolio | address | STRING | Giữ nguyên |
| uat_vsdc_stg | foreign_investor_bond_portfolio | trading_representative_name | STRING | atomic.uat_atm | foreign_bond_portfolio | trading_representative_nm | STRING | _name→_nm |
| uat_vsdc_stg | foreign_investor_bond_portfolio | institutional_investor_type | STRING | atomic.uat_atm | foreign_bond_portfolio | institutional_investor_tp | STRING | _type→_tp |
| uat_vsdc_stg | foreign_investor_bond_portfolio | bond_code | STRING | atomic.uat_atm | foreign_bond_portfolio | bond_code | STRING | Giữ nguyên |
| uat_vsdc_stg | foreign_investor_bond_portfolio | owned_volume | BIGINT | atomic.uat_atm | foreign_bond_portfolio | owned_bond_quantity | BIGINT | volume→quantity, thêm bond_ |
| uat_vsdc_stg | foreign_investor_bond_portfolio | report_month | STRING | atomic.uat_atm | foreign_bond_portfolio | report_month | STRING | Giữ nguyên |
| — | — | — | — | atomic.uat_atm | foreign_bond_portfolio | ds_snpst_dt | DATE | ⚙ Dev xử lý — không map từ nguồn |
| — | — | — | — | atomic.uat_atm | foreign_bond_portfolio | ds_snpst_dt | DATE | ⚙ Dev xử lý — không map từ nguồn |
| — | — | — | — | atomic.uat_atm | foreign_bond_portfolio | ds_etl_pcs_tms | TIMESTAMP | ⚙ Dev xử lý — không map từ nguồn |


## PHẦN 2: SCHEMA HNX (uat_hnx_stg)


### Bảng 10: share_auction (HNX)  +  Bảng 25: share_auction (HOSE)  →  share_auction_result

| Schema nguồn | Bảng nguồn | Trường nguồn | Kiểu DL nguồn | Schema atomic | Bảng atomic | Trường atomic | Kiểu DL atomic | Transformation / Ghi chú |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| — | — | (generated) | STRING | atomic.uat_atm | share_auction_result | share_auction_result_id | STRING | Surrogate key — UUID generated |
| — | — | (system) | STRING | atomic.uat_atm | share_auction_result | src_stm_code | STRING | Mã hệ thống nguồn — hardcode per pipeline |
| uat_hnx_stg / uat_hose_stg | share_auction | issuer_name | — | atomic.uat_atm | share_auction_result | issuer_name | — | Giữ nguyên — business key |
| uat_hnx_stg / uat_hose_stg | share_auction | auction_type | — | atomic.uat_atm | share_auction_result | auction_tp | — | _type→_tp — business key |
| uat_hnx_stg / uat_hose_stg | share_auction | registered_offering_shares | — | atomic.uat_atm | share_auction_result | registered_offering_share_quantity | — | Thêm _quantity |
| uat_hnx_stg / uat_hose_stg | share_auction | total_registered_investors | — | atomic.uat_atm | share_auction_result | registered_investor_count | — | Bỏ total_, thêm _count |
| uat_hnx_stg / uat_hose_stg | share_auction | starting_price | — | atomic.uat_atm | share_auction_result | starting_price | — | Giữ nguyên |
| uat_hnx_stg / uat_hose_stg | share_auction | average_winning_price | — | atomic.uat_atm | share_auction_result | average_winning_price | — | Giữ nguyên |
| uat_hnx_stg / uat_hose_stg | share_auction | domestic_institutional_winners | — | atomic.uat_atm | share_auction_result | domestic_institutional_winner_count | — | Thêm _count |
| uat_hnx_stg / uat_hose_stg | share_auction | foreign_institutional_winners | — | atomic.uat_atm | share_auction_result | foreign_institutional_winner_count | — | Thêm _count |
| uat_hnx_stg / uat_hose_stg | share_auction | domestic_individual_winners | — | atomic.uat_atm | share_auction_result | domestic_individual_winner_count | — | Thêm _count |
| uat_hnx_stg / uat_hose_stg | share_auction | foreign_individual_winners | — | atomic.uat_atm | share_auction_result | foreign_individual_winner_count | — | Thêm _count |
| uat_hnx_stg / uat_hose_stg | share_auction | domestic_registered_buy_volume | — | atomic.uat_atm | share_auction_result | domestic_registered_buy_quantity | — | volume→quantity |
| uat_hnx_stg / uat_hose_stg | share_auction | foreign_registered_buy_volume | — | atomic.uat_atm | share_auction_result | foreign_registered_buy_quantity | — | volume→quantity |
| uat_hnx_stg / uat_hose_stg | share_auction | domestic_winning_shares | — | atomic.uat_atm | share_auction_result | domestic_winning_share_quantity | — | Thêm _quantity |
| uat_hnx_stg / uat_hose_stg | share_auction | foreign_winning_shares | — | atomic.uat_atm | share_auction_result | foreign_winning_share_quantity | — | Thêm _quantity |
| uat_hnx_stg / uat_hose_stg | share_auction | domestic_winning_value | — | atomic.uat_atm | share_auction_result | domestic_winning_value | — | Giữ nguyên |
| uat_hnx_stg / uat_hose_stg | share_auction | foreign_winning_value | — | atomic.uat_atm | share_auction_result | foreign_winning_value | — | Giữ nguyên |
| uat_hnx_stg / uat_hose_stg | share_auction | domestic_actual_sold_shares | — | atomic.uat_atm | share_auction_result | domestic_actual_sold_share_quantity | — | Thêm _quantity |
| uat_hnx_stg / uat_hose_stg | share_auction | foreign_actual_sold_shares | — | atomic.uat_atm | share_auction_result | foreign_actual_sold_share_quantity | — | Thêm _quantity |
| uat_hnx_stg / uat_hose_stg | share_auction | domestic_actual_sold_value | — | atomic.uat_atm | share_auction_result | domestic_actual_sold_value | — | Giữ nguyên |
| uat_hnx_stg / uat_hose_stg | share_auction | foreign_actual_sold_value | — | atomic.uat_atm | share_auction_result | foreign_actual_sold_value | — | Giữ nguyên |
| uat_hnx_stg / uat_hose_stg | share_auction | report_month | — | atomic.uat_atm | share_auction_result | report_month | — | Giữ nguyên |
| uat_hnx_stg / uat_hose_stg | share_auction | report_year | — | atomic.uat_atm | share_auction_result | report_year | — | Giữ nguyên |
| — | — | — | — | atomic.uat_atm | share_auction_result | ds_snpst_dt | DATE | ⚙ Dev xử lý — không map từ nguồn |
| — | — | — | — | atomic.uat_atm | share_auction_result | ds_snpst_dt | DATE | ⚙ Dev xử lý — không map từ nguồn |
| — | — | — | — | atomic.uat_atm | share_auction_result | ds_etl_pcs_tms | TIMESTAMP | ⚙ Dev xử lý — không map từ nguồn |


### Bảng 11: private_corp_bond_trading  →  private_corp_bond_trading_summary

| Schema nguồn | Bảng nguồn | Trường nguồn | Kiểu DL nguồn | Schema atomic | Bảng atomic | Trường atomic | Kiểu DL atomic | Transformation / Ghi chú |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| — | — | (generated) | STRING | atomic.uat_atm | private_corp_bond_trading_summary | private_corp_bond_trading_summary_id | STRING | Surrogate key — UUID generated |
| — | — | (system) | STRING | atomic.uat_atm | private_corp_bond_trading_summary | src_stm_code | STRING | Mã hệ thống nguồn — hardcode per pipeline |
| uat_hnx_stg | private_corp_bond_trading | indicator | STRING | atomic.uat_atm | private_corp_bond_trading_summary | indicator_name | STRING | Thêm _name |
| uat_hnx_stg | private_corp_bond_trading | unit | STRING | atomic.uat_atm | private_corp_bond_trading_summary | measurement_unit | STRING | Tránh nhầm DB keyword |
| uat_hnx_stg | private_corp_bond_trading | value | DECIMAL(18,4) | atomic.uat_atm | private_corp_bond_trading_summary | indicator_value | DECIMAL(23,4) | Thêm prefix, đổi precision |
| — | — | — | — | atomic.uat_atm | private_corp_bond_trading_summary | ds_snpst_dt | DATE | ⚙ Dev xử lý — không map từ nguồn |
| — | — | — | — | atomic.uat_atm | private_corp_bond_trading_summary | ds_snpst_dt | DATE | ⚙ Dev xử lý — không map từ nguồn |
| — | — | — | — | atomic.uat_atm | private_corp_bond_trading_summary | ds_etl_pcs_tms | TIMESTAMP | ⚙ Dev xử lý — không map từ nguồn |


### Bảng 12: gov_bond_offering  →  gov_bond_bidding_result

| Schema nguồn | Bảng nguồn | Trường nguồn | Kiểu DL nguồn | Schema atomic | Bảng atomic | Trường atomic | Kiểu DL atomic | Transformation / Ghi chú |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| — | — | (generated) | STRING | atomic.uat_atm | gov_bond_bidding_result | gov_bond_bidding_result_id | STRING | Surrogate key — UUID generated |
| — | — | (system) | STRING | atomic.uat_atm | gov_bond_bidding_result | src_stm_code | STRING | Mã hệ thống nguồn — hardcode per pipeline |
| uat_hnx_stg | gov_bond_offering | bidding_session | — | atomic.uat_atm | gov_bond_bidding_result | bidding_session | — | Giữ nguyên — business key |
| uat_hnx_stg | gov_bond_offering | bidding_method | — | atomic.uat_atm | gov_bond_bidding_result | bidding_method | — | Giữ nguyên |
| uat_hnx_stg | gov_bond_offering | bond_code | — | atomic.uat_atm | gov_bond_bidding_result | bond_code | — | Giữ nguyên |
| uat_hnx_stg | gov_bond_offering | issuer_name | — | atomic.uat_atm | gov_bond_bidding_result | issuer_name | — | Giữ nguyên |
| uat_hnx_stg | gov_bond_offering | bond_type | — | atomic.uat_atm | gov_bond_bidding_result | bond_tp | — | _type→_tp |
| uat_hnx_stg | gov_bond_offering | term | — | atomic.uat_atm | gov_bond_bidding_result | bond_term | — | Thêm bond_ tránh SQL keyword |
| uat_hnx_stg | gov_bond_offering | issue_date | — | atomic.uat_atm | gov_bond_bidding_result | issue_date | — | Giữ nguyên |
| uat_hnx_stg | gov_bond_offering | issue_method | — | atomic.uat_atm | gov_bond_bidding_result | issue_method | — | Giữ nguyên |
| uat_hnx_stg | gov_bond_offering | calling_value | — | atomic.uat_atm | gov_bond_bidding_result | calling_value | — | Giữ nguyên |
| uat_hnx_stg | gov_bond_offering | bidding_value | — | atomic.uat_atm | gov_bond_bidding_result | bidding_value | — | Giữ nguyên |
| uat_hnx_stg | gov_bond_offering | winning_value | — | atomic.uat_atm | gov_bond_bidding_result | winning_value | — | Giữ nguyên |
| uat_hnx_stg | gov_bond_offering | nominal_interest_rate | — | atomic.uat_atm | gov_bond_bidding_result | nominal_interest_rate | — | Giữ nguyên |
| uat_hnx_stg | gov_bond_offering | winning_interest_rate | — | atomic.uat_atm | gov_bond_bidding_result | winning_interest_rate | — | Giữ nguyên |
| uat_hnx_stg | gov_bond_offering | report_month | — | atomic.uat_atm | gov_bond_bidding_result | report_month | — | Giữ nguyên |
| — | — | — | — | atomic.uat_atm | gov_bond_bidding_result | ds_snpst_dt | DATE | ⚙ Dev xử lý — không map từ nguồn |
| — | — | — | — | atomic.uat_atm | gov_bond_bidding_result | ds_snpst_dt | DATE | ⚙ Dev xử lý — không map từ nguồn |
| — | — | — | — | atomic.uat_atm | gov_bond_bidding_result | ds_etl_pcs_tms | TIMESTAMP | ⚙ Dev xử lý — không map từ nguồn |


### Bảng 13: gov_bond_listed_list  →  gov_bond_listing

| Schema nguồn | Bảng nguồn | Trường nguồn | Kiểu DL nguồn | Schema atomic | Bảng atomic | Trường atomic | Kiểu DL atomic | Transformation / Ghi chú |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| — | — | (generated) | STRING | atomic.uat_atm | gov_bond_listing | gov_bond_listing_id | STRING | Surrogate key — UUID generated |
| — | — | (system) | STRING | atomic.uat_atm | gov_bond_listing | src_stm_code | STRING | Mã hệ thống nguồn — hardcode per pipeline |
| uat_hnx_stg | gov_bond_listed_list | bond_code | — | atomic.uat_atm | gov_bond_listing | bond_code | — | Giữ nguyên — business key |
| uat_hnx_stg | gov_bond_listed_list | issuer_name | — | atomic.uat_atm | gov_bond_listing | issuer_name | — | Giữ nguyên |
| uat_hnx_stg | gov_bond_listed_list | bond_type | — | atomic.uat_atm | gov_bond_listing | bond_tp | — | _type→_tp |
| uat_hnx_stg | gov_bond_listed_list | listed_volume | — | atomic.uat_atm | gov_bond_listing | listed_bond_quantity | — | volume→quantity, thêm bond_ |
| uat_hnx_stg | gov_bond_listed_list | term | — | atomic.uat_atm | gov_bond_listing | bond_term | — | Thêm bond_ |
| uat_hnx_stg | gov_bond_listed_list | remaining_term | — | atomic.uat_atm | gov_bond_listing | remaining_bond_term | — | Thêm bond_ |
| uat_hnx_stg | gov_bond_listed_list | interest_payment_method | — | atomic.uat_atm | gov_bond_listing | interest_payment_method | — | Giữ nguyên |
| uat_hnx_stg | gov_bond_listed_list | interest_payment_type | — | atomic.uat_atm | gov_bond_listing | interest_payment_tp | — | _type→_tp |
| uat_hnx_stg | gov_bond_listed_list | interest_rate | — | atomic.uat_atm | gov_bond_listing | interest_rate | — | Giữ nguyên |
| uat_hnx_stg | gov_bond_listed_list | first_trading_date | — | atomic.uat_atm | gov_bond_listing | first_trading_date | — | Giữ nguyên |
| uat_hnx_stg | gov_bond_listed_list | status | — | atomic.uat_atm | gov_bond_listing | listing_status | — | Thêm listing_ prefix |
| uat_hnx_stg | gov_bond_listed_list | report_month | — | atomic.uat_atm | gov_bond_listing | report_month | — | Giữ nguyên |
| — | — | — | — | atomic.uat_atm | gov_bond_listing | ds_snpst_dt | DATE | ⚙ Dev xử lý — không map từ nguồn |
| — | — | — | — | atomic.uat_atm | gov_bond_listing | ds_snpst_dt | DATE | ⚙ Dev xử lý — không map từ nguồn |
| — | — | — | — | atomic.uat_atm | gov_bond_listing | ds_etl_pcs_tms | TIMESTAMP | ⚙ Dev xử lý — không map từ nguồn |


### Bảng 14: gov_bond_additional_listing  →  additional_gov_bond_listing

| Schema nguồn | Bảng nguồn | Trường nguồn | Kiểu DL nguồn | Schema atomic | Bảng atomic | Trường atomic | Kiểu DL atomic | Transformation / Ghi chú |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| — | — | (generated) | STRING | atomic.uat_atm | additional_gov_bond_listing | additional_gov_bond_listing_id | STRING | Surrogate key — UUID generated |
| — | — | (system) | STRING | atomic.uat_atm | additional_gov_bond_listing | src_stm_code | STRING | Mã hệ thống nguồn — hardcode per pipeline |
| uat_hnx_stg | gov_bond_additional_listing | bond_code | — | atomic.uat_atm | additional_gov_bond_listing | bond_code | — | Giữ nguyên — business key |
| uat_hnx_stg | gov_bond_additional_listing | bond_type | — | atomic.uat_atm | additional_gov_bond_listing | bond_tp | — | _type→_tp |
| uat_hnx_stg | gov_bond_additional_listing | volume | — | atomic.uat_atm | additional_gov_bond_listing | additional_bond_quantity | — | volume→quantity, thêm additional_bond_ |
| uat_hnx_stg | gov_bond_additional_listing | par_value | — | atomic.uat_atm | additional_gov_bond_listing | par_value | — | Giữ nguyên |
| uat_hnx_stg | gov_bond_additional_listing | status | — | atomic.uat_atm | additional_gov_bond_listing | listing_status | — | Thêm listing_ prefix — business key |
| uat_hnx_stg | gov_bond_additional_listing | listing_change_date | — | atomic.uat_atm | additional_gov_bond_listing | listing_change_date | — | Giữ nguyên — business key |
| uat_hnx_stg | gov_bond_additional_listing | report_month | — | atomic.uat_atm | additional_gov_bond_listing | report_month | — | Giữ nguyên |
| — | — | — | — | atomic.uat_atm | additional_gov_bond_listing | ds_snpst_dt | DATE | ⚙ Dev xử lý — không map từ nguồn |
| — | — | — | — | atomic.uat_atm | additional_gov_bond_listing | ds_snpst_dt | DATE | ⚙ Dev xử lý — không map từ nguồn |
| — | — | — | — | atomic.uat_atm | additional_gov_bond_listing | ds_etl_pcs_tms | TIMESTAMP | ⚙ Dev xử lý — không map từ nguồn |


### Bảng 15: private_corp_bond_offering  →  private_corp_bond_offering

| Schema nguồn | Bảng nguồn | Trường nguồn | Kiểu DL nguồn | Schema atomic | Bảng atomic | Trường atomic | Kiểu DL atomic | Transformation / Ghi chú |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| — | — | (generated) | STRING | atomic.uat_atm | private_corp_bond_offering | private_corp_bond_offering_id | STRING | Surrogate key — UUID generated |
| — | — | (system) | STRING | atomic.uat_atm | private_corp_bond_offering | src_stm_code | STRING | Mã hệ thống nguồn — hardcode per pipeline |
| uat_hnx_stg | private_corp_bond_offering | bond_code | — | atomic.uat_atm | private_corp_bond_offering | bond_code | — | Giữ nguyên — business key |
| uat_hnx_stg | private_corp_bond_offering | market_type | — | atomic.uat_atm | private_corp_bond_offering | market_type | — | Giữ nguyên — business key |
| uat_hnx_stg | private_corp_bond_offering | posting_date | — | atomic.uat_atm | private_corp_bond_offering | posting_date | — | Giữ nguyên — business key |
| uat_hnx_stg | private_corp_bond_offering | report_month | — | atomic.uat_atm | private_corp_bond_offering | report_month | — | Giữ nguyên |
| uat_hnx_stg | private_corp_bond_offering | issuer_name | — | atomic.uat_atm | private_corp_bond_offering | issuer_name | — | Giữ nguyên |
| uat_hnx_stg | private_corp_bond_offering | enterprise_type | — | atomic.uat_atm | private_corp_bond_offering | enterprise_type | — | Giữ nguyên |
| uat_hnx_stg | private_corp_bond_offering | business_sector | — | atomic.uat_atm | private_corp_bond_offering | business_sector | — | Giữ nguyên |
| uat_hnx_stg | private_corp_bond_offering | currency | — | atomic.uat_atm | private_corp_bond_offering | currency_code | — | Thêm _code |
| uat_hnx_stg | private_corp_bond_offering | term_unit | — | atomic.uat_atm | private_corp_bond_offering | bond_term_unit | — | Thêm bond_ |
| uat_hnx_stg | private_corp_bond_offering | term | — | atomic.uat_atm | private_corp_bond_offering | bond_term | — | Thêm bond_ |
| uat_hnx_stg | private_corp_bond_offering | issue_date | — | atomic.uat_atm | private_corp_bond_offering | issue_date | — | Giữ nguyên |
| uat_hnx_stg | private_corp_bond_offering | maturity_date | — | atomic.uat_atm | private_corp_bond_offering | maturity_date | — | Giữ nguyên |
| uat_hnx_stg | private_corp_bond_offering | remaining_term | — | atomic.uat_atm | private_corp_bond_offering | remaining_bond_term | — | Thêm bond_ |
| uat_hnx_stg | private_corp_bond_offering | offering_volume | — | atomic.uat_atm | private_corp_bond_offering | offering_bond_quantity | — | volume→quantity |
| uat_hnx_stg | private_corp_bond_offering | par_value | — | atomic.uat_atm | private_corp_bond_offering | par_value | — | Giữ nguyên |
| uat_hnx_stg | private_corp_bond_offering | interest_payment_type | — | atomic.uat_atm | private_corp_bond_offering | interest_payment_type | — | Giữ nguyên |
| uat_hnx_stg | private_corp_bond_offering | interest_rate_type | — | atomic.uat_atm | private_corp_bond_offering | interest_rate_type | — | Giữ nguyên |
| uat_hnx_stg | private_corp_bond_offering | interest_payment_method | — | atomic.uat_atm | private_corp_bond_offering | interest_payment_method | — | Giữ nguyên |
| uat_hnx_stg | private_corp_bond_offering | repurchase_and_swap | — | atomic.uat_atm | private_corp_bond_offering | repurchase_and_swap | — | Giữ nguyên |
| uat_hnx_stg | private_corp_bond_offering | issue_market | — | atomic.uat_atm | private_corp_bond_offering | issue_market | — | Giữ nguyên |
| uat_hnx_stg | private_corp_bond_offering | issue_interest_rate | — | atomic.uat_atm | private_corp_bond_offering | issue_interest_rate | — | Giữ nguyên |
| uat_hnx_stg | private_corp_bond_offering | convertible_bond | — | atomic.uat_atm | private_corp_bond_offering | convertible_bond_ind | — | Thêm _ind boolean flag |
| uat_hnx_stg | private_corp_bond_offering | warrant_linked_bond | — | atomic.uat_atm | private_corp_bond_offering | warrant_linked_bond_ind | — | Thêm _ind boolean flag |
| uat_hnx_stg | private_corp_bond_offering | secured_bond | — | atomic.uat_atm | private_corp_bond_offering | secured_bond_ind | — | Thêm _ind boolean flag |
| — | — | — | — | atomic.uat_atm | private_corp_bond_offering | ds_snpst_dt | DATE | ⚙ Dev xử lý — không map từ nguồn |
| — | — | — | — | atomic.uat_atm | private_corp_bond_offering | ds_snpst_dt | DATE | ⚙ Dev xử lý — không map từ nguồn |
| — | — | — | — | atomic.uat_atm | private_corp_bond_offering | ds_etl_pcs_tms | TIMESTAMP | ⚙ Dev xử lý — không map từ nguồn |


### Bảng 16: private_corp_bond_registration  →  private_corp_bond_registration

| Schema nguồn | Bảng nguồn | Trường nguồn | Kiểu DL nguồn | Schema atomic | Bảng atomic | Trường atomic | Kiểu DL atomic | Transformation / Ghi chú |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| — | — | (generated) | STRING | atomic.uat_atm | private_corp_bond_registration | private_corp_bond_registration_id | STRING | Surrogate key — UUID generated |
| — | — | (system) | STRING | atomic.uat_atm | private_corp_bond_registration | src_stm_code | STRING | Mã hệ thống nguồn — hardcode per pipeline |
| uat_hnx_stg | private_corp_bond_registration | bond_code | — | atomic.uat_atm | private_corp_bond_registration | bond_code | — | Giữ nguyên — business key |
| uat_hnx_stg | private_corp_bond_registration | currency | — | atomic.uat_atm | private_corp_bond_registration | currency_code | — | Thêm _code |
| uat_hnx_stg | private_corp_bond_registration | issuer_name | — | atomic.uat_atm | private_corp_bond_registration | issuer_name | — | Giữ nguyên |
| uat_hnx_stg | private_corp_bond_registration | par_value | — | atomic.uat_atm | private_corp_bond_registration | par_value | — | Giữ nguyên |
| uat_hnx_stg | private_corp_bond_registration | term_unit | — | atomic.uat_atm | private_corp_bond_registration | bond_term_unit | — | Thêm bond_ |
| uat_hnx_stg | private_corp_bond_registration | remaining_term | — | atomic.uat_atm | private_corp_bond_registration | remaining_bond_term | — | Thêm bond_ |
| uat_hnx_stg | private_corp_bond_registration | issue_date | — | atomic.uat_atm | private_corp_bond_registration | issue_date | — | Giữ nguyên |
| uat_hnx_stg | private_corp_bond_registration | maturity_date | — | atomic.uat_atm | private_corp_bond_registration | maturity_date | — | Giữ nguyên |
| uat_hnx_stg | private_corp_bond_registration | interest_payment_method | — | atomic.uat_atm | private_corp_bond_registration | interest_payment_method | — | Giữ nguyên |
| uat_hnx_stg | private_corp_bond_registration | interest_payment_term | — | atomic.uat_atm | private_corp_bond_registration | interest_payment_term | — | Giữ nguyên |
| uat_hnx_stg | private_corp_bond_registration | issued_volume | — | atomic.uat_atm | private_corp_bond_registration | issued_bond_quantity | — | volume→quantity |
| uat_hnx_stg | private_corp_bond_registration | repurchased_converted_swapped_volume | — | atomic.uat_atm | private_corp_bond_registration | repurchased_converted_swapped_bond_quantity | — | volume→quantity |
| uat_hnx_stg | private_corp_bond_registration | registered_trading_volume | — | atomic.uat_atm | private_corp_bond_registration | registered_trading_bond_quantity | — | volume→quantity |
| uat_hnx_stg | private_corp_bond_registration | outstanding_volume | — | atomic.uat_atm | private_corp_bond_registration | outstanding_bond_quantity | — | volume→quantity |
| uat_hnx_stg | private_corp_bond_registration | issue_interest_rate | — | atomic.uat_atm | private_corp_bond_registration | issue_interest_rate | — | Giữ nguyên |
| uat_hnx_stg | private_corp_bond_registration | first_trading_date | — | atomic.uat_atm | private_corp_bond_registration | first_trading_date | — | Giữ nguyên |
| uat_hnx_stg | private_corp_bond_registration | report_month | — | atomic.uat_atm | private_corp_bond_registration | report_month | — | Giữ nguyên |
| — | — | — | — | atomic.uat_atm | private_corp_bond_registration | ds_snpst_dt | DATE | ⚙ Dev xử lý — không map từ nguồn |
| — | — | — | — | atomic.uat_atm | private_corp_bond_registration | ds_snpst_dt | DATE | ⚙ Dev xử lý — không map từ nguồn |
| — | — | — | — | atomic.uat_atm | private_corp_bond_registration | ds_etl_pcs_tms | TIMESTAMP | ⚙ Dev xử lý — không map từ nguồn |


### Bảng 17: registration_status_change  →  bond_trading_registration_status

| Schema nguồn | Bảng nguồn | Trường nguồn | Kiểu DL nguồn | Schema atomic | Bảng atomic | Trường atomic | Kiểu DL atomic | Transformation / Ghi chú |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| — | — | (generated) | STRING | atomic.uat_atm | bond_trading_registration_status | bond_trading_registration_status_id | STRING | Surrogate key — UUID generated |
| — | — | (system) | STRING | atomic.uat_atm | bond_trading_registration_status | src_stm_code | STRING | Mã hệ thống nguồn — hardcode per pipeline |
| uat_hnx_stg | registration_status_change | bond_code | — | atomic.uat_atm | bond_trading_registration_status | bond_code | — | Giữ nguyên — business key |
| uat_hnx_stg | registration_status_change | trading_registration_status | — | atomic.uat_atm | bond_trading_registration_status | trading_registration_status | — | Giữ nguyên — business key |
| uat_hnx_stg | registration_status_change | issuer_name | — | atomic.uat_atm | bond_trading_registration_status | issuer_name | — | Giữ nguyên |
| uat_hnx_stg | registration_status_change | par_value | — | atomic.uat_atm | bond_trading_registration_status | par_value | — | Giữ nguyên |
| uat_hnx_stg | registration_status_change | currently_registered_trading_volume | — | atomic.uat_atm | bond_trading_registration_status | registered_trading_bond_quantity | — | Bỏ currently_, volume→quantity |
| uat_hnx_stg | registration_status_change | first_trading_date | — | atomic.uat_atm | bond_trading_registration_status | first_trading_date | — | Giữ nguyên |
| uat_hnx_stg | registration_status_change | last_trading_date | — | atomic.uat_atm | bond_trading_registration_status | last_trading_date | — | Giữ nguyên |
| uat_hnx_stg | registration_status_change | report_month | — | atomic.uat_atm | bond_trading_registration_status | report_month | — | Giữ nguyên |
| — | — | — | — | atomic.uat_atm | bond_trading_registration_status | ds_snpst_dt | DATE | ⚙ Dev xử lý — không map từ nguồn |
| — | — | — | — | atomic.uat_atm | bond_trading_registration_status | ds_snpst_dt | DATE | ⚙ Dev xử lý — không map từ nguồn |
| — | — | — | — | atomic.uat_atm | bond_trading_registration_status | ds_etl_pcs_tms | TIMESTAMP | ⚙ Dev xử lý — không map từ nguồn |


### Bảng 18: listing_status_change (HNX)  +  Bảng 26: listing_status_change (HOSE)  →  listing_status_change

| Schema nguồn | Bảng nguồn | Trường nguồn | Kiểu DL nguồn | Schema atomic | Bảng atomic | Trường atomic | Kiểu DL atomic | Transformation / Ghi chú |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| — | — | (generated) | STRING | atomic.uat_atm | listing_status_change | listing_status_change_id | STRING | Surrogate key — UUID generated |
| — | — | (system) | STRING | atomic.uat_atm | listing_status_change | src_stm_code | STRING | Mã hệ thống nguồn — hardcode per pipeline |
| uat_hnx_stg / uat_hose_stg | listing_status_change | decision_no | — | atomic.uat_atm | listing_status_change | decision_no | — | Giữ nguyên — business key |
| uat_hnx_stg / uat_hose_stg | listing_status_change | decision_date | — | atomic.uat_atm | listing_status_change | decision_date | — | Giữ nguyên — business key |
| uat_hnx_stg / uat_hose_stg | listing_status_change | ticker_symbol | — | atomic.uat_atm | listing_status_change | ticker_symbol | — | Giữ nguyên — business key |
| uat_hnx_stg / uat_hose_stg | listing_status_change | new_listed_shares | — | atomic.uat_atm | listing_status_change | new_listed_share_quantity | — | Thêm _quantity |
| uat_hnx_stg / uat_hose_stg | listing_status_change | additional_listed_shares | — | atomic.uat_atm | listing_status_change | additional_listed_share_quantity | — | Thêm _quantity |
| uat_hnx_stg / uat_hose_stg | listing_status_change | delisted_shares | — | atomic.uat_atm | listing_status_change | delisted_share_quantity | — | Thêm _quantity |
| uat_hnx_stg / uat_hose_stg | listing_status_change | exchange_transfer | — | atomic.uat_atm | listing_status_change | exchange_transfer | — | Giữ nguyên |
| uat_hnx_stg / uat_hose_stg | listing_status_change | listed_value | — | atomic.uat_atm | listing_status_change | listed_share_value | — | Thêm _share_ |
| uat_hnx_stg / uat_hose_stg | listing_status_change | additional_listed_value | — | atomic.uat_atm | listing_status_change | additional_listed_share_value | — | Thêm _share_ |
| uat_hnx_stg / uat_hose_stg | listing_status_change | delisted_value | — | atomic.uat_atm | listing_status_change | delisted_share_value | — | Thêm _share_ |
| uat_hnx_stg / uat_hose_stg | listing_status_change | issuer_name | — | atomic.uat_atm | listing_status_change | issuer_name | — | Giữ nguyên |
| uat_hnx_stg / uat_hose_stg | listing_status_change | effective_date | — | atomic.uat_atm | listing_status_change | effective_date | — | Giữ nguyên |
| uat_hnx_stg / uat_hose_stg | listing_status_change | first_trading_date | — | atomic.uat_atm | listing_status_change | first_trading_date | — | Giữ nguyên |
| uat_hnx_stg / uat_hose_stg | listing_status_change | last_trading_date | — | atomic.uat_atm | listing_status_change | last_trading_date | — | Giữ nguyên |
| uat_hnx_stg / uat_hose_stg | listing_status_change | delist_transfer_reason | — | atomic.uat_atm | listing_status_change | delist_transfer_reason | — | Giữ nguyên |
| uat_hnx_stg / uat_hose_stg | listing_status_change | report_month | — | atomic.uat_atm | listing_status_change | report_month | — | Giữ nguyên |
| — | — | — | — | atomic.uat_atm | listing_status_change | ds_snpst_dt | DATE | ⚙ Dev xử lý — không map từ nguồn |
| — | — | — | — | atomic.uat_atm | listing_status_change | ds_snpst_dt | DATE | ⚙ Dev xử lý — không map từ nguồn |
| — | — | — | — | atomic.uat_atm | listing_status_change | ds_etl_pcs_tms | TIMESTAMP | ⚙ Dev xử lý — không map từ nguồn |


### Bảng 20: brokerage_market_share (HNX)  +  Bảng 28: brokerage_market_share (HOSE)  →  brokerage_market_share

| Schema nguồn | Bảng nguồn | Trường nguồn | Kiểu DL nguồn | Schema atomic | Bảng atomic | Trường atomic | Kiểu DL atomic | Transformation / Ghi chú |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| — | — | (generated) | STRING | atomic.uat_atm | brokerage_market_share | brokerage_market_share_id | STRING | Surrogate key — UUID generated |
| — | — | (system) | STRING | atomic.uat_atm | brokerage_market_share | src_stm_code | STRING | Mã hệ thống nguồn — hardcode per pipeline |
| uat_hnx_stg / uat_hose_stg | brokerage_market_share | member_code | — | atomic.uat_atm | brokerage_market_share | sc_member_code | — | Thêm sc_ prefix — business key |
| uat_hnx_stg / uat_hose_stg | brokerage_market_share | broker_name | — | atomic.uat_atm | brokerage_market_share | sc_nm | — | Đổi tên rút gọn |
| uat_hnx_stg / uat_hose_stg | brokerage_market_share | total_trading_value | — | atomic.uat_atm | brokerage_market_share | total_trading_value | — | Giữ nguyên |
| uat_hnx_stg / uat_hose_stg | brokerage_market_share | market_share_by_value | — | atomic.uat_atm | brokerage_market_share | market_share_by_value | — | Giữ nguyên |
| uat_hnx_stg / uat_hose_stg | brokerage_market_share | classification | — | atomic.uat_atm | brokerage_market_share | security_tp_code | — | Đổi tên rõ nghĩa hơn |
| uat_hnx_stg / uat_hose_stg | brokerage_market_share | report_quarter | — | atomic.uat_atm | brokerage_market_share | report_quarter | — | Giữ nguyên |
| — | — | — | — | atomic.uat_atm | brokerage_market_share | ds_snpst_dt | DATE | ⚙ Dev xử lý — không map từ nguồn |
| — | — | — | — | atomic.uat_atm | brokerage_market_share | ds_snpst_dt | DATE | ⚙ Dev xử lý — không map từ nguồn |
| — | — | — | — | atomic.uat_atm | brokerage_market_share | ds_etl_pcs_tms | TIMESTAMP | ⚙ Dev xử lý — không map từ nguồn |


### Bảng 21: outright_order_book  +  22: repo_order_book  +  23: repo2_order_book  →  bond_order_book

| Schema nguồn | Bảng nguồn | Trường nguồn | Kiểu DL nguồn | Schema atomic | Bảng atomic | Trường atomic | Kiểu DL atomic | Transformation / Ghi chú |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| — | — | (generated) | STRING | atomic.uat_atm | bond_order_book | bond_order_book_id | STRING | Surrogate key — UUID generated |
| — | — | (system) | STRING | atomic.uat_atm | bond_order_book | src_stm_code | STRING | Mã hệ thống nguồn — hardcode per pipeline |
| — | (derived) | — | — | atomic.uat_atm | bond_order_book | order_book_type | STRING | Hardcode: 'OUTRIGHT'/'REPO'/'REPO2' theo bảng nguồn |
| uat_hnx_stg | All 3 | order_no | — | atomic.uat_atm | bond_order_book | order_no | — | Giữ nguyên — business key |
| uat_hnx_stg | All 3 | original_order_no | — | atomic.uat_atm | bond_order_book | original_order_no | — | Giữ nguyên |
| uat_hnx_stg | All 3 | time | — | atomic.uat_atm | bond_order_book | order_time | — | Thêm order_ |
| uat_hnx_stg | All 3 | order_type | — | atomic.uat_atm | bond_order_book | order_type | — | Giữ nguyên |
| uat_hnx_stg | All 3 | order_side | — | atomic.uat_atm | bond_order_book | order_side | — | Giữ nguyên |
| uat_hnx_stg | All 3 | order_status | — | atomic.uat_atm | bond_order_book | order_status | — | Giữ nguyên |
| uat_hnx_stg | All 3 | order_creator_rep | — | atomic.uat_atm | bond_order_book | order_creator_rep | — | Giữ nguyên |
| uat_hnx_stg | All 3 | bond_code | — | atomic.uat_atm | bond_order_book | bond_code | — | Giữ nguyên |
| uat_hnx_stg | All 3 | instrument_type | — | atomic.uat_atm | bond_order_book | instrument_type | — | Giữ nguyên |
| uat_hnx_stg | All 3 | interest_payment_type | — | atomic.uat_atm | bond_order_book | interest_payment_type | — | Giữ nguyên |
| uat_hnx_stg | All 3 | interest_payment_method | — | atomic.uat_atm | bond_order_book | interest_payment_method | — | Giữ nguyên |
| uat_hnx_stg | All 3 | interest_rate_type | — | atomic.uat_atm | bond_order_book | interest_rate_type | — | Giữ nguyên |
| uat_hnx_stg | All 3 | remaining_term_days | — | atomic.uat_atm | bond_order_book | remaining_term_days | — | Giữ nguyên |
| uat_hnx_stg | All 3 | remaining_term | — | atomic.uat_atm | bond_order_book | remaining_term | — | Giữ nguyên |
| uat_hnx_stg | All 3 | currency_code | — | atomic.uat_atm | bond_order_book | currency_code | — | Giữ nguyên |
| uat_hnx_stg | All 3 | quoted_price | — | atomic.uat_atm | bond_order_book | quoted_price | — | Giữ nguyên |
| uat_hnx_stg | All 3 | execution_price | — | atomic.uat_atm | bond_order_book | execution_price | — | Giữ nguyên |
| uat_hnx_stg | All 3 | yield_rate | — | atomic.uat_atm | bond_order_book | yield_rate | — | Giữ nguyên |
| uat_hnx_stg | All 3 | discount_rate | — | atomic.uat_atm | bond_order_book | discount_rate | — | Giữ nguyên |
| uat_hnx_stg | All 3 | volume | — | atomic.uat_atm | bond_order_book | order_bond_quantity | — | volume→quantity, thêm bond_ |
| uat_hnx_stg | All 3 | trading_method | — | atomic.uat_atm | bond_order_book | trading_method | — | Giữ nguyên |
| uat_hnx_stg | All 3 | trading_date | — | atomic.uat_atm | bond_order_book | trading_date | — | Giữ nguyên — partition key |
| uat_hnx_stg | outright_order_book | trading_value | — | atomic.uat_atm | bond_order_book | trading_value | — | Giữ nguyên \| NULL với REPO/REPO2 |
| uat_hnx_stg | All 3 | settlement_method | — | atomic.uat_atm | bond_order_book | settlement_method | — | Giữ nguyên |
| uat_hnx_stg | All 3 | payment_status | — | atomic.uat_atm | bond_order_book | payment_status | — | Giữ nguyên |
| uat_hnx_stg | All 3 | selling_member_code | — | atomic.uat_atm | bond_order_book | selling_member_code | — | Giữ nguyên |
| uat_hnx_stg | All 3 | selling_rep | — | atomic.uat_atm | bond_order_book | selling_rep | — | Giữ nguyên |
| uat_hnx_stg | All 3 | selling_account_no | — | atomic.uat_atm | bond_order_book | selling_account_no | — | Giữ nguyên |
| uat_hnx_stg | All 3 | selling_broker_dealer | — | atomic.uat_atm | bond_order_book | selling_broker_dealer | — | Giữ nguyên |
| uat_hnx_stg | All 3 | selling_proxy_entry | — | atomic.uat_atm | bond_order_book | selling_proxy_entry | — | Giữ nguyên |
| uat_hnx_stg | All 3 | buying_member_code | — | atomic.uat_atm | bond_order_book | buying_member_code | — | Giữ nguyên |
| uat_hnx_stg | All 3 | buying_rep | — | atomic.uat_atm | bond_order_book | buying_rep | — | Giữ nguyên |
| uat_hnx_stg | All 3 | buying_account_no | — | atomic.uat_atm | bond_order_book | buying_account_no | — | Giữ nguyên |
| uat_hnx_stg | All 3 | buying_broker_dealer | — | atomic.uat_atm | bond_order_book | buying_broker_dealer | — | Giữ nguyên |
| uat_hnx_stg | All 3 | buying_proxy_entry | — | atomic.uat_atm | bond_order_book | buying_proxy_entry | — | Giữ nguyên |
| uat_hnx_stg | outright_order_book | settlement_date | — | atomic.uat_atm | bond_order_book | settlement_date | — | NULL với REPO, REPO2 |
| uat_hnx_stg | outright_order_book + repo2_order_book | settlement_status | — | atomic.uat_atm | bond_order_book | settlement_status | — | NULL với REPO |
| uat_hnx_stg | outright_order_book + repo2_order_book | settlement_bond_code | — | atomic.uat_atm | bond_order_book | settlement_bond_code | — | NULL với REPO |
| uat_hnx_stg | outright_order_book + repo2_order_book | settlement_volume | — | atomic.uat_atm | bond_order_book | settlement_bond_quantity | — | volume→quantity \| NULL với REPO |
| uat_hnx_stg | outright_order_book + repo2_order_book | equivalent_bond_settlement_value | — | atomic.uat_atm | bond_order_book | equivalent_bond_settlement_value | — | NULL với REPO |
| uat_hnx_stg | repo_order_book + repo2_order_book | par_value | — | atomic.uat_atm | bond_order_book | par_value | — | NULL với OUTRIGHT |
| uat_hnx_stg | repo_order_book + repo2_order_book | repo_term | — | atomic.uat_atm | bond_order_book | repo_term | — | NULL với OUTRIGHT |
| uat_hnx_stg | repo_order_book + repo2_order_book | repo_rate | — | atomic.uat_atm | bond_order_book | repo_rate | — | NULL với OUTRIGHT |
| uat_hnx_stg | repo_order_book + repo2_order_book | repo_interest | — | atomic.uat_atm | bond_order_book | repo_interest | — | NULL với OUTRIGHT |
| uat_hnx_stg | repo_order_book + repo2_order_book | risk_margin_ratio | — | atomic.uat_atm | bond_order_book | risk_margin_ratio | — | NULL với OUTRIGHT |
| uat_hnx_stg | repo_order_book + repo2_order_book | coupon_rate | — | atomic.uat_atm | bond_order_book | coupon_rate | — | NULL với OUTRIGHT |
| uat_hnx_stg | repo_order_book + repo2_order_book | coupon_interest | — | atomic.uat_atm | bond_order_book | coupon_interest | — | NULL với OUTRIGHT |
| uat_hnx_stg | repo_order_book + repo2_order_book | receive_coupon_interest | — | atomic.uat_atm | bond_order_book | receive_coupon_interest_ind | — | Thêm _ind \| NULL với OUTRIGHT |
| uat_hnx_stg | repo_order_book + repo2_order_book | interest_on_coupon | — | atomic.uat_atm | bond_order_book | interest_on_coupon | — | NULL với OUTRIGHT |
| uat_hnx_stg | repo_order_book + repo2_order_book | first_settlement_date | — | atomic.uat_atm | bond_order_book | first_settlement_date | — | NULL với OUTRIGHT |
| uat_hnx_stg | repo_order_book + repo2_order_book | first_settlement_value | — | atomic.uat_atm | bond_order_book | first_settlement_value | — | NULL với OUTRIGHT |
| uat_hnx_stg | repo_order_book + repo2_order_book | second_settlement_date | — | atomic.uat_atm | bond_order_book | second_settlement_date | — | NULL với OUTRIGHT |
| uat_hnx_stg | repo_order_book + repo2_order_book | second_settlement_value | — | atomic.uat_atm | bond_order_book | second_settlement_value | — | NULL với OUTRIGHT |
| uat_hnx_stg | repo_order_book + repo2_order_book | end_trading_date | — | atomic.uat_atm | bond_order_book | end_trading_date | — | NULL với OUTRIGHT |
| uat_hnx_stg | repo2_order_book | mark_settlement_bond | — | atomic.uat_atm | bond_order_book | mark_settlement_bond_ind | — | Thêm _ind \| NULL với OUTRIGHT, REPO |
| — | — | — | — | atomic.uat_atm | bond_order_book | ds_snpst_dt | DATE | ⚙ Dev xử lý — không map từ nguồn |
| — | — | — | — | atomic.uat_atm | bond_order_book | ds_snpst_dt | DATE | ⚙ Dev xử lý — không map từ nguồn |
| — | — | — | — | atomic.uat_atm | bond_order_book | ds_etl_pcs_tms | TIMESTAMP | ⚙ Dev xử lý — không map từ nguồn |


### Bảng 24: mdds_order_book (HNX)  +  Bảng 29: mdds_order_book (HOSE)  →  mdds_order_book

| Schema nguồn | Bảng nguồn | Trường nguồn | Kiểu DL nguồn | Schema atomic | Bảng atomic | Trường atomic | Kiểu DL atomic | Transformation / Ghi chú |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| — | — | (generated) | STRING | atomic.uat_atm | mdds_order_book | mdds_order_book_id | STRING | Surrogate key — UUID generated |
| — | — | (system) | STRING | atomic.uat_atm | mdds_order_book | src_stm_code | STRING | Mã hệ thống nguồn — hardcode per pipeline |
| uat_hnx_stg / uat_hose_stg | mdds_order_book | ticker_symbol | — | atomic.uat_atm | mdds_order_book | ticker_symbol | — | Giữ nguyên — business key |
| uat_hnx_stg / uat_hose_stg | mdds_order_book | trading_date | — | atomic.uat_atm | mdds_order_book | trading_date | — | Giữ nguyên — partition key |
| uat_hnx_stg / uat_hose_stg | mdds_order_book | order_receive_time | — | atomic.uat_atm | mdds_order_book | order_receive_time | — | Giữ nguyên |
| uat_hnx_stg / uat_hose_stg | mdds_order_book | order_id | — | atomic.uat_atm | mdds_order_book | order_id | — | Giữ nguyên — business key |
| uat_hnx_stg / uat_hose_stg | mdds_order_book | order_type | — | atomic.uat_atm | mdds_order_book | order_type | — | Giữ nguyên |
| uat_hnx_stg / uat_hose_stg | mdds_order_book | order_side | — | atomic.uat_atm | mdds_order_book | order_side | — | Giữ nguyên |
| uat_hnx_stg / uat_hose_stg | mdds_order_book | volume | — | atomic.uat_atm | mdds_order_book | order_quantity | — | volume→quantity |
| uat_hnx_stg / uat_hose_stg | mdds_order_book | price | — | atomic.uat_atm | mdds_order_book | order_price | — | Thêm order_ prefix |
| uat_hnx_stg / uat_hose_stg | mdds_order_book | order_status | — | atomic.uat_atm | mdds_order_book | order_status | — | Giữ nguyên |
| uat_hnx_stg / uat_hose_stg | mdds_order_book | matched_volume | — | atomic.uat_atm | mdds_order_book | matched_quantity | — | volume→quantity |
| uat_hnx_stg / uat_hose_stg | mdds_order_book | matched_price | — | atomic.uat_atm | mdds_order_book | matched_price | — | Giữ nguyên |
| uat_hnx_stg / uat_hose_stg | mdds_order_book | member_code | — | atomic.uat_atm | mdds_order_book | member_code | — | Giữ nguyên |
| uat_hnx_stg / uat_hose_stg | mdds_order_book | trading_account_no | — | atomic.uat_atm | mdds_order_book | trading_account_no | — | Giữ nguyên |
| — | — | — | — | atomic.uat_atm | mdds_order_book | ds_snpst_dt | DATE | ⚙ Dev xử lý — không map từ nguồn |
| — | — | — | — | atomic.uat_atm | mdds_order_book | ds_snpst_dt | DATE | ⚙ Dev xử lý — không map từ nguồn |
| — | — | — | — | atomic.uat_atm | mdds_order_book | ds_etl_pcs_tms | TIMESTAMP | ⚙ Dev xử lý — không map từ nguồn |
