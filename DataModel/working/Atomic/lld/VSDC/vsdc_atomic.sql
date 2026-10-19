-- ==============================================================================
-- PHẦN 1: SCHEMA VSDC (uat_vsdc_stg)
-- ==============================================================================
-- Bảng: open_investors → open_investor_account
	Business key: investor_account_nbr
	Lọc ds_snpst_dt
	Concept Arrangement
CREATE TABLE atomic.uat_atm.open_investor_account (
  open_investor_account_id STRING,
  investor_account_nbr STRING COMMENT 'Mã tài khoản giao dịch',
  src_stm_code STRING,
  investor_nm STRING COMMENT 'Tên khách hàng',
  investor_tp_code INT COMMENT 'Loại hình (Cá nhân/Tổ chức)',
  address STRING COMMENT 'Địa chỉ',
  identification_nbr STRING COMMENT 'Số đăng ký sở hữu',
  issue_dt DATE COMMENT 'Ngày cấp',
  issue_place STRING COMMENT 'Nơi cấp',
  open_dt DATE COMMENT 'Ngày mở tài khoản',
  nationality_code INT COMMENT 'Quốc tịch',
  phone_nbr STRING COMMENT 'Số điện thoại',
  email STRING COMMENT 'Địa chỉ email',
  ds_snpst_dt DATE,
  ds_etl_pcs_tms TIMESTAMP)
USING ICEBERG
PARTITIONED BY (ds_snpst_dt, src_stm_code);

-- Bảng: closed_investors → closed_investor_account
	Business key: investor_account_nbr
	Lọc ds_snpst_dt
	Concept Arrangement
CREATE TABLE atomic.uat_atm.closed_investor_account (
  closed_investor_account_id STRING,
  investor_account_nbr STRING COMMENT 'Mã tài khoản giao dịch',
  src_stm_code STRING,
  investor_nm STRING COMMENT 'Tên khách hàng',
  investor_tp_code INT COMMENT 'Loại hình (Cá nhân/Tổ chức)',
  address STRING COMMENT 'Địa chỉ',
  identification_nbr STRING COMMENT 'Số đăng ký sở hữu',
  issue_dt DATE COMMENT 'Ngày cấp',
  issue_place STRING COMMENT 'Nơi cấp',
  close_dt DATE COMMENT 'Ngày đóng tài khoản',
  nationality_code INT COMMENT 'Quốc tịch',
  phone_nbr STRING COMMENT 'Số điện thoại',
  email STRING COMMENT 'Địa chỉ email',
  close_note STRING COMMENT 'Ghi chú đóng tài khoản',
  ds_snpst_dt DATE,
  ds_etl_pcs_tms TIMESTAMP)
USING ICEBERG
PARTITIONED BY (ds_snpst_dt, src_stm_code);

-- Bảng: updated_investors → updated_investor_account
	Business key: investor_account_nbr
	Lọc ds_snpst_dt
	Concept Arrangement
CREATE TABLE atomic.uat_atm.updated_investor_account (
  updated_investor_account_id STRING,
  investor_account_nbr STRING COMMENT 'Mã tài khoản giao dịch',
  src_stm_code STRING,
  investor_nm STRING COMMENT 'Tên khách hàng',
  investor_tp_code INT COMMENT 'Loại hình (Cá nhân/Tổ chức)',
  address STRING COMMENT 'Địa chỉ',
  identification_nbr STRING COMMENT 'Số đăng ký sở hữu',
  issue_dt DATE COMMENT 'Ngày cấp',
  issue_place STRING COMMENT 'Nơi cấp',
  update_dt DATE COMMENT 'Ngày thay đổi thông tin',
  nationality_code INT COMMENT 'Quốc tịch',
  phone_nbr STRING COMMENT 'Số điện thoại',
  email STRING COMMENT 'Địa chỉ email',
  update_note STRING COMMENT 'Ghi chú thay đổi',
  ds_snpst_dt DATE,
  ds_etl_pcs_tms TIMESTAMP)
USING ICEBERG
PARTITIONED BY (ds_snpst_dt, src_stm_code);

-- 1. Bảng: outstanding_shares, 19. Bảng: listed_securities_list (HNX), 27. Bảng: listed_securities_list (HOSE)
	Business key: ticker_symbol
	Lọc ds_snpst_dt
	Concept Product
CREATE TABLE IF NOT EXISTS atomic.uat_atm.listed_share_information (
  listed_share_information_id STRING,
  ticker_symbol STRING,
  src_stm_code STRING,
  isin_code STRING,
  total_issued_share_quantity BIGINT,
  treasury_share_quantity BIGINT,
  outstanding_share_quantity BIGINT,
  free_float_share_quantity BIGINT,
  restricted_share_quantity BIGINT,
  voting_share_quantity BIGINT,
  issuer_name STRING COMMENT 'Tổ chức phát hành',
  listed_share_quantity BIGINT COMMENT 'Số lượng cổ phiếu niêm yết',
  reference_price DECIMAL(23,2) COMMENT 'Giá tham chiếu',
  transaction_dt DATE,
  ds_snpst_dt              DATE,
  ds_etl_pcs_tms           TIMESTAMP)
USING ICEBERG
PARTITIONED BY (ds_snpst_dt, src_stm_code);

-- 9. Bảng: foreign_investor_info
	Business key: ticker_symbol
	Lọc ds_snpst_dt
	Concept Involved Party
CREATE TABLE IF NOT EXISTS atomic.uat_atm.foreign_ownership_information (
 foreign_ownership_information_id STRING,
  ticker_symbol STRING,
  src_stm_code STRING,
  isin_code STRING,
  total_issued_share_quantity BIGINT,
  max_foreign_ownership_ratio DECIMAL(5,2),
  max_foreign_holding_quantity BIGINT,
  current_foreign_holding_quantity BIGINT,
  remaining_foreign_holding_quantity BIGINT,
  ds_snpst_dt              DATE,
  ds_etl_pcs_tms           TIMESTAMP)
USING ICEBERG
PARTITIONED BY (ds_snpst_dt, src_stm_code);

-- 5. Bảng: major_shareholder (bảng kèo theo tháng)
	Business key: ticker_symbol, identification_nbr
	Lọc ds_snpst_dt
	Concept Involved Party
CREATE TABLE atomic.uat_atm.major_shareholder_ownership (
  major_shareholder_ownership_id STRING,
  src_stm_code STRING,
  ticker_symbol STRING,
  isin_code STRING,
  major_shareholder_nm STRING,
  identification_nbr STRING,
  issue_dt DATE,
  address STRING,
  voting_share_quantity BIGINT,
  opening_balance_date DATE,
  opening_share_quantity BIGINT,
  opening_ratio DECIMAL(7,4),
  closing_balance_date DATE,
  closing_share_quantity BIGINT,
  closing_ratio DECIMAL(7,4),
  note STRING,
  ds_snpst_dt              DATE,
  ds_etl_pcs_tms           TIMESTAMP)
USING ICEBERG
PARTITIONED BY (ds_snpst_dt, src_stm_code);

-- 6. Bảng: end_of_day_open_interest
	Business key: ticker_symbol
	Lọc ds_snpst_dt
	Concept Arrangement
CREATE TABLE IF NOT EXISTS atomic.uat_atm.end_of_day_open_interest (
  end_of_day_open_interest_id STRING,
  ticker_symbol STRING,
  src_stm_code STRING,
  open_interest_quantity BIGINT,
  ds_snpst_dt              DATE,
  ds_etl_pcs_tms           TIMESTAMP)
USING ICEBERG
PARTITIONED BY (ds_snpst_dt, src_stm_code);

-- 8. Bảng: foreign_investor_bond_portfolio (bảng kèo theo tháng)
	Business key: foreign_investor_code
	Lọc ds_snpst_dt
	Concept Involved Party
CREATE TABLE IF NOT EXISTS atomic.uat_atm.foreign_bond_portfolio (
  foreign_bond_portfolio_id STRING,
  foreign_investor_code STRING,
  src_stm_code STRING,
  foreign_investor_name STRING,
  foreign_investor_tp_code STRING,
  nationality_code STRING,
  address STRING,
  trading_representative_nm STRING,
  institutional_investor_tp STRING,
  bond_code STRING,
  owned_bond_quantity BIGINT,
  report_month STRING,
  ds_snpst_dt              DATE,
  ds_etl_pcs_tms           TIMESTAMP)
USING ICEBERG
PARTITIONED BY (ds_snpst_dt, src_stm_code);

-- ==============================================================================
-- PHẦN 2: SCHEMA HNX (uat_hnx_stg)
-- ==============================================================================

-- 10. Bảng: share_auction (HNX), 25. Bảng: share_auction (HOSE)
	Business key: issuer_name, auction_tp
	Lọc ds_snpst_dt
	Concept Business Activity
CREATE TABLE IF NOT EXISTS atomic.uat_atm.share_auction_result (
  share_auction_result_id STRING,
  issuer_name STRING COMMENT 'Tên tổ chức phát hành / Tên công ty',
  auction_tp STRING COMMENT 'Loại hình đấu giá',
  src_stm_code STRING,
  registered_offering_share_quantity BIGINT COMMENT 'Số CP đăng ký chào bán',
  registered_investor_count BIGINT COMMENT 'Tổng số NĐT đăng ký tham gia',
  starting_price DECIMAL(23,2) COMMENT 'Giá khởi điểm',
  average_winning_price DECIMAL(23,2) COMMENT 'Giá trúng bình quân',
  domestic_institutional_winner_count BIGINT COMMENT 'Số NĐT trúng giá tổ chức trong nước',
  foreign_institutional_winner_count BIGINT COMMENT 'Số NĐT trúng giá tổ chức nước ngoài',
  domestic_individual_winner_count BIGINT COMMENT 'Số NĐT trúng giá cá nhân trong nước',
  foreign_individual_winner_count BIGINT COMMENT 'Số NĐT trúng giá cá nhân nước ngoài',
  domestic_registered_buy_quantity BIGINT COMMENT 'KL CP đăng ký mua - NĐT trong nước',
  foreign_registered_buy_quantity BIGINT COMMENT 'KL CP đăng ký mua - NĐT nước ngoài',
  domestic_winning_share_quantity BIGINT COMMENT 'Số CP trúng giá - NĐT trong nước',
  foreign_winning_share_quantity BIGINT COMMENT 'Số CP trúng giá - NĐT nước ngoài',
  domestic_winning_value DECIMAL(23,2) COMMENT 'Giá trị CP trúng giá (VND) - Trong nước',
  foreign_winning_value DECIMAL(23,2) COMMENT 'Giá trị CP trúng giá (VND) - Nước ngoài',
  domestic_actual_sold_share_quantity BIGINT COMMENT 'Số CP thực tế bán được - Trong nước',
  foreign_actual_sold_share_quantity BIGINT COMMENT 'Số CP thực tế bán được - Nước ngoài',
  domestic_actual_sold_value DECIMAL(23,2) COMMENT 'Giá trị CP thực tế bán được - Trong nước',
  foreign_actual_sold_value DECIMAL(23,2) COMMENT 'Giá trị CP thực tế bán được - Nước ngoài',
  report_month STRING COMMENT 'Tháng báo cáo',
  report_year STRING COMMENT 'Năm báo cáo'
  ds_snpst_dt              DATE,
  ds_etl_pcs_tms           TIMESTAMP)
USING ICEBERG
PARTITIONED BY (ds_snpst_dt, src_stm_code);

-- 11. Bảng: private_corp_bond_trading
	Business key: indicator_name
	Lọc ds_snpst_dt
	Concept Documentation
CREATE TABLE IF NOT EXISTS atomic.uat_atm.private_corp_bond_trading_summary (
  private_corp_bond_trading_summary_id
  src_stm_code STRING,
  indicator_name STRING COMMENT 'Chỉ tiêu',
  measurement_unit STRING COMMENT 'Đơn vị tính',
  indicator_value DECIMAL(23,4) COMMENT 'Giá trị',
  ds_snpst_dt              DATE,
  ds_etl_pcs_tms           TIMESTAMP)
USING ICEBERG
PARTITIONED BY (ds_snpst_dt, src_stm_code);

-- 12. Bảng: gov_bond_offering
	Business key: bidding_session
	Lọc ds_snpst_dt
	Concept Business Activity
CREATE TABLE IF NOT EXISTS atomic.uat_atm.gov_bond_bidding_result (
  gov_bond_bidding_result_id STRING,
  bidding_session STRING COMMENT 'Đợt đấu thầu',
  src_stm_code STRING,
  bidding_method STRING COMMENT 'Phương thức đấu thầu',
  bond_code STRING COMMENT 'Mã trái phiếu',
  issuer_name STRING COMMENT 'Tên tổ chức phát hành',
  bond_tp STRING COMMENT 'Loại trái phiếu',
  bond_term STRING COMMENT 'Kỳ hạn',
  issue_date DATE COMMENT 'Ngày phát hành',
  issue_method STRING COMMENT 'Phương thức phát hành',
  calling_value DECIMAL(23,2) COMMENT 'Giá trị gọi thầu',
  bidding_value DECIMAL(23,2) COMMENT 'Giá trị đặt thầu',
  winning_value DECIMAL(23,2) COMMENT 'Giá trị trúng thầu',
  nominal_interest_rate DECIMAL(5,2) COMMENT 'Lãi suất danh nghĩa (%)',
  winning_interest_rate DECIMAL(5,2) COMMENT 'Lãi suất trúng thầu (%)',
  report_month STRING COMMENT 'Tháng báo cáo'
  ds_snpst_dt              DATE,
  ds_etl_pcs_tms           TIMESTAMP)
USING ICEBERG
PARTITIONED BY (ds_snpst_dt, src_stm_code);

-- 13. Bảng: gov_bond_listed_list
	Business key: bond_code
	Lọc ds_snpst_dt
	Concept Product
CREATE TABLE IF NOT EXISTS atomic.uat_atm.gov_bond_listing (
  gov_bond_listing_id STRING,
  bond_code STRING COMMENT 'Mã trái phiếu',
  src_stm_code STRING,
  issuer_name STRING COMMENT 'Tổ chức phát hành',
  bond_tp STRING COMMENT 'Loại trái phiếu',
  listed_bond_quantity BIGINT COMMENT 'Khối lượng niêm yết',
  bond_term STRING COMMENT 'Kỳ hạn trái phiếu',
  remaining_bond_term STRING COMMENT 'Kỳ hạn còn lại của trái phiếu',
  interest_payment_method STRING COMMENT 'Hình thức trả lãi',
  interest_payment_tp STRING COMMENT 'Loại hình trả lãi',
  interest_rate DECIMAL(5,2) COMMENT 'Lãi suất (%)',
  first_trading_date DATE COMMENT 'Ngày giao dịch đầu tiên',
  listing_status STRING COMMENT 'Trạng thái',
  report_month STRING COMMENT 'Tháng báo cáo'
  ds_snpst_dt              DATE,
  ds_etl_pcs_tms           TIMESTAMP)
USING ICEBERG
PARTITIONED BY (ds_snpst_dt, src_stm_code);

-- 14. Bảng: gov_bond_additional_listing
	Business key: bond_code, listing_status, listing_change_date
	Lọc ds_snpst_dt
	Concept Product
CREATE TABLE IF NOT EXISTS uat_hnx_stg.additional_gov_bond_listing (
  gov_bond_additional_listing_id STRING,
  bond_code STRING COMMENT 'Mã trái phiếu',
  src_stm_code STRING,
  bond_tp STRING COMMENT 'Loại trái phiếu',
  additional_bond_quantity BIGINT COMMENT 'Khối lượng',
  par_value BIGINT COMMENT 'Mệnh giá trái phiếu',
  listing_status STRING COMMENT 'Trạng thái',
  listing_change_date DATE COMMENT 'Ngày thay đổi niêm yết',
  report_month STRING COMMENT 'Tháng báo cáo'
  ds_snpst_dt              DATE,
  ds_etl_pcs_tms           TIMESTAMP)
USING ICEBERG
PARTITIONED BY (ds_snpst_dt, src_stm_code);

-- 15. Bảng: private_corp_bond_offering
	Business key: bond_code, market_type, posting_date
	Lọc ds_snpst_dt
	Concept Business Activity
CREATE TABLE IF NOT EXISTS uat_hnx_stg.private_corp_bond_offering (
  private_corp_bond_offering_id STRING,
  bond_code STRING COMMENT 'Mã trái phiếu',
  market_type STRING COMMENT 'Loại thị trường (Trong nước/Quốc tế)',
  posting_date DATE COMMENT 'Ngày đăng tin',
  src_stm_code STRING,
  report_month STRING COMMENT 'Tháng báo cáo',
  issuer_name STRING COMMENT 'Tên doanh nghiệp phát hành',
  enterprise_type STRING COMMENT 'Loại hình doanh nghiệp',
  business_sector STRING COMMENT 'Lĩnh vực hoạt động',
  currency_code STRING COMMENT 'Tiền tệ', 
  bond_term_unit STRING COMMENT 'Đơn vị kỳ hạn',
  bond_term INT COMMENT 'Kỳ hạn',
  issue_date DATE COMMENT 'Ngày phát hành',
  maturity_date DATE COMMENT 'Ngày đáo hạn',
  remaining_bond_term INT COMMENT 'Kỳ hạn còn lại',
  offering_bond_quantity BIGINT COMMENT 'Khối lượng chào bán',
  par_value BIGINT COMMENT 'Mệnh giá',
  interest_payment_type STRING COMMENT 'Loại hình trả lãi',
  interest_rate_type STRING COMMENT 'Loại lãi suất',
  interest_payment_method STRING COMMENT 'Phương thức thanh toán lãi',
  repurchase_and_swap STRING COMMENT 'Mua lại và hoán đổi',
  issue_market STRING COMMENT 'Thị trường phát hành',
  issue_interest_rate DECIMAL(5,2) COMMENT 'Lãi suất phát hành (%)',
  convertible_bond_ind STRING COMMENT 'Trái phiếu chuyển đổi (Có/Không)',
  warrant_linked_bond_ind STRING COMMENT 'Trái phiếu kèm chứng quyền (Có/Không)',
  secured_bond STRING_ind COMMENT 'Trái phiếu bảo đảm (Có/Không)'
  ds_snpst_dt              DATE,
  ds_etl_pcs_tms           TIMESTAMP)
USING ICEBERG
PARTITIONED BY (ds_snpst_dt, src_stm_code);

-- 16. Bảng: private_corp_bond_trading_registration_scale
	Business key: bond_code
	Lọc ds_snpst_dt
	Concept Business Activity
CREATE TABLE IF NOT EXISTS uat_hnx_stg.private_corp_bond_registration (
  private_corp_bond_registration_id STRING,
  bond_code STRING COMMENT 'Mã trái phiếu',
  src_stm_code STRING,
  currency_code STRING COMMENT 'Tiền tệ',
  issuer_name STRING COMMENT 'Tên doanh nghiệp phát hành',
  par_value BIGINT COMMENT 'Mệnh giá',
  bond_term_unit STRING COMMENT 'Đơn vị kỳ hạn',
  remaining_bond_term INT COMMENT 'Kỳ hạn còn lại',
  issue_date DATE COMMENT 'Ngày phát hành',
  maturity_date DATE COMMENT 'Ngày đáo hạn',
  interest_payment_method STRING COMMENT 'Phương thức trả lãi',
  interest_payment_term STRING COMMENT 'Kỳ hạn trả lãi',
  issued_bond_quantity BIGINT COMMENT 'Khối lượng phát hành',
  repurchased_converted_swapped_bond_quantity BIGINT COMMENT 'KL mua lại/chuyển đổi/hoán đổi',
  registered_trading_bond_quantity BIGINT COMMENT 'Khối lượng đăng ký giao dịch',
  outstanding_bond_quantity BIGINT COMMENT 'Khối lượng còn lưu hành',
  issue_interest_rate DECIMAL(5,2) COMMENT 'Lãi suất phát hành (%)',
  first_trading_date DATE COMMENT 'Ngày giao dịch đầu tiên',
  report_month STRING COMMENT 'Tháng báo cáo'
  ds_snpst_dt              DATE,
  ds_etl_pcs_tms           TIMESTAMP)
USING ICEBERG
PARTITIONED BY (ds_snpst_dt, src_stm_code);

-- 17. Bảng: registration_status_change
	Business key: bond_code, trading_registration_status
	Lọc ds_snpst_dt
	Concept Business Activity
CREATE TABLE IF NOT EXISTS uat_hnx_stg.bond_trading_registration_status (
  bond_trading_registration_status_id STRING,
  bond_code STRING COMMENT 'Mã trái phiếu',
  src_stm_code STRING,
  trading_registration_status STRING COMMENT 'Trạng thái ĐKGD',
  issuer_name STRING COMMENT 'Tên doanh nghiệp phát hành',
  par_value BIGINT COMMENT 'Mệnh giá trái phiếu',
  registered_trading_bond_quantity BIGINT COMMENT 'KL đang đăng ký giao dịch',
  first_trading_date DATE COMMENT 'Ngày giao dịch đầu tiên',
  last_trading_date DATE COMMENT 'Ngày giao dịch cuối cùng',
  report_month STRING COMMENT 'Tháng báo cáo'
  ds_snpst_dt              DATE,
  ds_etl_pcs_tms           TIMESTAMP)
USING ICEBERG
PARTITIONED BY (ds_snpst_dt, src_stm_code);

-- 18. Bảng: listing_status_change (HNX), 26. Bảng: listing_status_change (HOSE)
	Business key: decision_no, decision_date, ticker_symbol
	Lọc ds_snpst_dt
	Concept Business Activity
CREATE TABLE IF NOT EXISTS uat_hnx_stg.listing_status_change (
  listing_status_change_id STRING,
  decision_no STRING COMMENT 'Số quyết định',
  decision_date DATE COMMENT 'Ngày quyết định',
  ticker_symbol STRING COMMENT 'Mã CK',
  src_stm_code STRING,
  new_listed_share_quantity BIGINT COMMENT 'Số lượng CK niêm yết mới',
  additional_listed_share_quantity BIGINT COMMENT 'Số lượng CK niêm yết bổ sung',
  delisted_share_quantity BIGINT COMMENT 'Số lượng CK hủy niêm yết',
  exchange_transfer STRING COMMENT 'Chuyển sàn',
  listed_share_value DECIMAL(23,2) COMMENT 'Giá trị CK niêm yết',
  additional_listed_share_value DECIMAL(23,2) COMMENT 'Giá trị CK niêm yết bổ sung',
  delisted_share_value DECIMAL(23,2) COMMENT 'Giá trị chứng khoán huỷ niêm yết',
  issuer_name STRING COMMENT 'Tên Tổ chức phát hành / Tên Công ty',
  effective_date DATE COMMENT 'Ngày hiệu lực',
  first_trading_date DATE COMMENT 'Ngày giao dịch đầu tiên',
  last_trading_date DATE COMMENT 'Ngày giao dịch cuối cùng',
  delist_transfer_reason STRING COMMENT 'Lý do hủy, chuyển sàn',
  report_month STRING COMMENT 'Tháng báo cáo'
  ds_snpst_dt              DATE,
  ds_etl_pcs_tms           TIMESTAMP)
USING ICEBERG
PARTITIONED BY (ds_snpst_dt, src_stm_code);

-- 20. Bảng: brokerage_market_share (HNX), 28. Bảng: brokerage_market_share (HOSE)
	Business key: sc_member_code
	Lọc ds_snpst_dt 
	Concept Involved Party
CREATE TABLE IF NOT EXISTS uat_hnx_stg.brokerage_market_share (
  brokerage_market_share_id STRING,
  sc_member_code STRING COMMENT 'Mã thành viên',
  src_stm_code STRING,
  sc_nm STRING COMMENT 'Tên công ty chứng khoán',
  total_trading_value DECIMAL(23,2) COMMENT 'Tổng giá trị giao dịch',
  market_share_by_value DECIMAL(5,2) COMMENT 'Tỷ trọng theo tổng GTGD (%)',
  security_tp_code STRING COMMENT 'Phân loại',
  report_quarter STRING COMMENT 'Quý báo cáo'
  ds_snpst_dt              DATE,
  ds_etl_pcs_tms           TIMESTAMP)
USING ICEBERG
PARTITIONED BY (ds_snpst_dt, src_stm_code);

-- 21. Bảng: outright_order_book (HNX), 22. Bảng: repo_order_book (HNX), 23. Bảng: repo2_order_book (HNX)
	Business key: order_no
	Lọc ds_snpst_dt
	Concept Business Activity
CREATE TABLE IF NOT EXISTS uat_hnx_stg.bond_order_book (
  bond_order_book_id STRING,
  order_no                    STRING                  COMMENT 'Số hiệu lệnh',
  src_stm_code STRING,
  original_order_no           STRING                  COMMENT 'Số hiệu lệnh gốc',
  order_time                  STRING                  COMMENT 'Thời gian đặt lệnh',
  order_type                  STRING                  COMMENT 'Loại lệnh',
  order_side                  STRING                  COMMENT 'Chiều lệnh mua/bán',
  order_status                STRING                  COMMENT 'Trạng thái lệnh',
  order_creator_rep           STRING                  COMMENT 'Đại diện giao dịch tạo lệnh',
  bond_code                   STRING                  COMMENT 'Mã trái phiếu',
  instrument_type             STRING                  COMMENT 'Loại hàng hóa',
  interest_payment_type       STRING                  COMMENT 'Loại hình trả lãi',
  interest_payment_method     STRING                  COMMENT 'Kiểu trả lãi',
  interest_rate_type          STRING                  COMMENT 'Loại lãi suất',
  remaining_term_days         BIGINT                  COMMENT 'Kỳ hạn còn lại (ngày)',
  remaining_term              STRING                  COMMENT 'Kỳ hạn còn lại (mô tả)',
  currency_code               STRING                  COMMENT 'Mã tiền tệ',
  quoted_price                DECIMAL(23,4)           COMMENT 'Giá yết',
  execution_price             DECIMAL(23,4)           COMMENT 'Giá thực hiện',
  yield_rate                  DECIMAL(7,4)           COMMENT 'Lợi suất (%)',
  discount_rate               DECIMAL(7,4)           COMMENT 'Lãi suất chiết khấu (%)',
  order_bond_quantity         BIGINT                  COMMENT 'Khối lượng lệnh (trái phiếu)',
  trading_method              STRING                  COMMENT 'Phương thức giao dịch',
  trading_date                DATE                    COMMENT 'Ngày bắt đầu giao dịch',
  trading_value               DECIMAL(23,2)           COMMENT 'Giá trị giao dịch',
  settlement_method           STRING                  COMMENT 'Phương thức thanh toán',
  payment_status              STRING                  COMMENT 'Tình trạng thanh toán',
  selling_member_code         STRING                  COMMENT 'Mã thành viên bán',
  selling_rep                 STRING                  COMMENT 'Đại diện giao dịch bán',
  selling_account_no          STRING                  COMMENT 'Số tài khoản nhà đầu tư bán',
  selling_broker_dealer       STRING                  COMMENT 'Môi giới/Tự doanh bán',
  selling_proxy_entry         STRING                  COMMENT 'Nhập hộ bán',
  buying_member_code          STRING                  COMMENT 'Mã thành viên mua',
  buying_rep                  STRING                  COMMENT 'Đại diện giao dịch mua',
  buying_account_no           STRING                  COMMENT 'Số tài khoản nhà đầu tư mua',
  buying_broker_dealer        STRING                  COMMENT 'Môi giới/Tự doanh mua',
  buying_proxy_entry          STRING                  COMMENT 'Nhập hộ mua',
  settlement_date             DATE                    COMMENT 'Ngày thanh toán [OUTRIGHT] | NULL với REPO',
  settlement_status           STRING                  COMMENT 'Tình trạng thanh toán trái phiếu [OUTRIGHT, REPO2] | NULL với REPO',
  settlement_bond_code        STRING                  COMMENT 'Mã trái phiếu thanh toán [OUTRIGHT, REPO2] | NULL với REPO',
  settlement_bond_quantity    BIGINT                  COMMENT 'Khối lượng thanh toán [OUTRIGHT, REPO2] | NULL với REPO',
  equivalent_bond_settlement_value DECIMAL(23,2)      COMMENT 'Giá trị thanh toán bằng trái phiếu tương đương [OUTRIGHT, REPO2] | NULL với REPO',
  par_value                   DECIMAL(23,2)           COMMENT 'Giá trị mệnh giá [REPO, REPO2] | NULL với OUTRIGHT',
  repo_term                   BIGINT                  COMMENT 'Kỳ hạn Repo [REPO, REPO2] | NULL với OUTRIGHT',
  repo_rate                   DECIMAL(7,4)           COMMENT 'Lãi suất Repo (%) [REPO, REPO2] | NULL với OUTRIGHT',
  repo_interest               DECIMAL(23,2)           COMMENT 'Lãi Repo [REPO, REPO2] | NULL với OUTRIGHT',
  risk_margin_ratio           DECIMAL(5,2)           COMMENT 'Tỷ lệ phòng vệ rủi ro (%) [REPO, REPO2] | NULL với OUTRIGHT',
  coupon_rate                 DECIMAL(7,4)           COMMENT 'Lãi suất coupon (%) [REPO, REPO2] | NULL với OUTRIGHT',
  coupon_interest             DECIMAL(23,2)           COMMENT 'Lãi coupon [REPO, REPO2] | NULL với OUTRIGHT',
  receive_coupon_interest_ind STRING                  COMMENT 'Nhận lãi coupon (Có/Không) [REPO, REPO2] | NULL với OUTRIGHT',
  interest_on_coupon          DECIMAL(23,2)           COMMENT 'Lãi trên lãi coupon [REPO, REPO2] | NULL với OUTRIGHT',
  first_settlement_date       DATE                    COMMENT 'Ngày thanh toán lần 1 [REPO, REPO2] | NULL với OUTRIGHT',
  first_settlement_value      DECIMAL(23,2)           COMMENT 'Giá trị thanh toán lần 1 [REPO, REPO2] | NULL với OUTRIGHT',
  second_settlement_date      DATE                    COMMENT 'Ngày thanh toán lần 2 [REPO, REPO2] | NULL với OUTRIGHT',
  second_settlement_value     DECIMAL(23,2)           COMMENT 'Giá trị thanh toán lần 2 [REPO, REPO2] | NULL với OUTRIGHT',
  end_trading_date            DATE                    COMMENT 'Ngày kết thúc giao dịch [REPO, REPO2] | NULL với OUTRIGHT',
  mark_settlement_bond_ind     STRING                 COMMENT 'Đánh dấu trái phiếu thanh toán [REPO2] | NULL với OUTRIGHT, REPO'
  ds_snpst_dt              DATE,
  ds_etl_pcs_tms           TIMESTAMP)
USING ICEBERG
PARTITIONED BY (ds_snpst_dt, src_stm_code);