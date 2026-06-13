# Risk HLD — Tier 2

**Source system:** Risk (Quản lý Rủi ro)  
**Tier 2:** Entity phụ thuộc Tier 1 — có FK đến Risk Indicator hoặc Risk Report Type.

---

## 6a. Bảng tổng quan BCV Concept

| BCV Core Object | BCV Concept | Category | Source Table | Mô tả bảng nguồn | Atomic Entity | table_type | BCV Term |
|---|---|---|---|---|---|---|---|
| Condition | [Condition] Criterion | Condition | risk_indicator_schedule | Cấu hình job đồng bộ chỉ tiêu | Risk Indicator Schedule | Fundamental | BCV term **Criterion** (ID 8945): "Identifies a Condition that specifies a characteristic used as a basis of judgment." Bảng risk_indicator_schedule lưu cấu hình lịch chạy job (frequency_type, cron_expression, next_run_time) — đây là quy tắc/điều kiện chạy đồng bộ, không phải sự kiện phát sinh. Gần hơn với Criterion hơn là Arrangement vì không có 2 bên tham gia thoả thuận. Grain: 1 dòng = 1 chỉ tiêu (1-1 với Risk Indicator). table_type = Fundamental vì có lifecycle riêng (is_enabled, last_status). |
| Condition | [Condition] Criterion | Condition | risk_alert_config | Cấu hình ngưỡng cảnh báo và người xử lý theo từng chỉ tiêu | Risk Alert Config | Fundamental | BCV term **Criterion** (ID 8945): quy tắc/tiêu chí xác định ngưỡng cảnh báo (threshold_direction, threshold_value, compare_period_time). Đây là cấu hình nghiệp vụ — định nghĩa điều kiện kích hoạt alert. Không phải Condition Financial Charge (không phải biểu phí). Grain: 1 dòng = 1 cấu hình ngưỡng cho 1 chỉ tiêu. FK → Risk Indicator (sau gộp, chỉ còn 1 FK). |
| Documentation | [Documentation] Regulatory Report | Documentation | risk_report_placeholder_config | Cấu hình "đục lỗ" — mapping placeholder trong template báo cáo | *(Ngoài scope Atomic)* | — | Đây là cấu hình kỹ thuật (data_source_table, formula_expression) — không có giá trị nghiệp vụ độc lập. Chốt không lưu trên Atomic. |

---

## 6b. Diagram Source (Mermaid)

```mermaid
erDiagram
    risk_indicator {
        bigint id PK
        string indicator_code
        string indicator_name
        string set_code
        bigint category_id FK
        string unit_code
        string source_code
        string period_type
        int status
    }

    risk_indicator_custom {
        bigint id PK
        string indicator_name
        string unit_code
        string source_code
        string period_type
        int status
    }

    risk_indicator_schedule {
        bigint id PK
        bigint indicator_id FK
        string frequency_type
        int frequency_value
        datetime start_time
        datetime next_run_time
        datetime last_run_time
        string cron_expression
        int is_enabled
        int total_runs
        string last_status
        string last_error
    }

    risk_alert_config {
        bigint id PK
        int indicator_type
        bigint indicator_id FK
        bigint custom_indicator_id FK
        string threshold_direction
        string threshold_unit_code
        decimal threshold_value
        int compare_period_time
        string alert_message_template
        bigint handler_user_id
        string handler_user_name
        int notify_bell_flag
        int notify_email_flag
        int notify_toast_flag
        int is_active
        int display_order
    }

    risk_report_type {
        bigint id PK
        string code
        string name
        string description
        int is_active
    }

    risk_report_placeholder_config {
        bigint id PK
        bigint report_type_id FK
        string placeholder_code
        int value_type
        string data_source_table
        string data_source_column
        string data_source_filter
        string formula_expression
        string data_format
        int use_previous_period
        int is_active
    }

    risk_report_upload_batch {
        bigint id PK
        bigint report_type_id FK
        date report_date
        int file_count
    }

    risk_indicator_schedule ||--|| risk_indicator : "indicator_id"
    risk_alert_config }o--|| risk_indicator : "indicator_id"
    risk_alert_config }o--|| risk_indicator_custom : "custom_indicator_id"
    risk_report_placeholder_config ||--o{ risk_report_type : "report_type_id"
    risk_report_upload_batch ||--o{ risk_report_type : "report_type_id"
```

---

## 6c. Diagram Atomic (Mermaid)

```mermaid
erDiagram
    RISK_Indicator["Risk Indicator (Tier 1)"] {
        bigint ds_indicator_id PK
        string indicator_code
        string indicator_type_code
    }

    RISK_Report_Type["Risk Report Type (Tier 1)"] {
        bigint ds_report_type_id PK
        string report_type_code
    }

    RISK_Indicator_Schedule {
        bigint ds_indicator_schedule_id PK
        bigint indicator_id FK
        string indicator_code
        string frequency_type_code
        int frequency_value
        datetime start_time
        datetime next_run_time
        datetime last_run_time
        string cron_expression
        string is_enabled_flag
        int total_runs
        string last_run_status_code
        string last_error
        string ds_status_code
    }

    RISK_Alert_Config {
        bigint ds_alert_config_id PK
        bigint indicator_id FK
        string indicator_code
        string threshold_direction_code
        string threshold_unit_code
        decimal threshold_value
        int compare_period_count
        string alert_message_template
        bigint handler_user_id
        string handler_user_name
        string notify_bell_flag
        string notify_email_flag
        string notify_toast_flag
        string ds_status_code
    }

    RISK_Report_Upload_Batch {
        bigint ds_report_upload_batch_id PK
        bigint report_type_id FK
        string report_type_code
        date report_date
        int file_count
        string ds_created_by
        datetime ds_created_at
    }

    RISK_Indicator_Schedule ||--|| RISK_Indicator : "indicator_id"
    RISK_Alert_Config }o--|| RISK_Indicator : "indicator_id"
    RISK_Report_Upload_Batch }o--|| RISK_Report_Type : "report_type_id"
```

---

## 6d. Danh mục & Tham chiếu (Reference Data)

| Source Field | Mô tả | Scheme Code | source_type |
|---|---|---|---|
| risk_indicator_schedule.frequency_type (1=Giờ, 2=Ngày, 3=Tháng, 4=Quý, 5=Năm) | Tần suất chạy job | `RISK_JOB_FREQUENCY_TYPE` | etl_derived |
| risk_indicator_schedule.last_status (SUCCESS/FAILED) | Kết quả lần chạy gần nhất | `RISK_JOB_RUN_STATUS` | etl_derived |
| risk_alert_config.threshold_direction (1=Tăng, 2=Giảm, 3=Tăng/Giảm) | Chiều ngưỡng cảnh báo | `RISK_ALERT_THRESHOLD_DIRECTION` | etl_derived |
| risk_report_upload_batch (Business Activity entity) | *(gộp vào 6a)* | — | — |

---

## 6e. Bảng ngoài scope

| Source Table | Mô tả bảng nguồn | Lý do ngoài scope |
|---|---|---|
| risk_report_placeholder_config | Cấu hình placeholder kỹ thuật trong template báo cáo | Operational/system data — không có giá trị nghiệp vụ |

---

## 6f. Điểm cần xác nhận

*(Tất cả điểm cần xác nhận Tier 2 đã được chốt.)*

| # | Câu hỏi | Kết quả |
|---|---|---|
| T2-01 | `risk_alert_config.handler_user_id` — có entity User riêng không? | **Không có** — lưu denormalized (handler_user_id + handler_user_name). |
| T2-02 | Mapping FK sau gộp Indicator: indicator_type=1 → indicator_id; indicator_type=2 → custom_indicator_id, cả 2 → ds_indicator_id. | **Đúng** — confirmed. |
| T2-03 | Risk Report Upload Batch đặt Tier 2 — phù hợp, không cần thêm attribute. | **Confirmed.** |
