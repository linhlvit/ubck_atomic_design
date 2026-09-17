# Báo cáo đồng bộ ngược Code → Design — Module NHNCK
Ngày audit: 2026-09-04
Phạm vi: toàn bộ 13 bảng (Datamart: 13, ClickHouse: 11)

**Cập nhật 2026-09-04 (đợt 2)** — commit `742aede` "Xoá cột insert_dt 2 Fact NHNCK trên Click, bổ
sung cột first_license_dt cho fct_prac_daily". Phạm vi cập nhật lần này: đúng 3 file dev báo đã sửa —
`dtm_fct_practitioner_daily_snpst.sql` (Datamart), `nhnck_fct_practitioner_daily_snpst_flat.sql` và
`nhnck_fct_practitioner_license_certificate_snpst_flat.sql` (ClickHouse). Các bảng còn lại trong report
giữ nguyên từ đợt audit đầu (chưa re-audit lại).

## Tổng hợp
- Bảng không đổi: 4 (`opr_practitioner_360_profile`, `opr_practitioner_certificate_hist`, `securities_practitioner_dim`, `sp_license_certificate_type_dim`)
- Bảng có lệch cần cập nhật thiết kế: 9 (`fct_practitioner_license_certificate_snpst`, `fct_practitioner_daily_snpst`, `opr_practitioner_data_explorer`, `opr_practitioner_employment_hist`, `opr_practitioner_exam_hist`, `opr_practitioner_list_company_role`, `opr_practitioner_related_party_profile`, `opr_practitioner_training_hist`, `opr_practitioner_violation_hist`)
- Bảng có code thật nhưng CHƯA có trong LLD/flat-table: không có
- Bảng có trong LLD/flat-table nhưng CHƯA thấy code thật tương ứng: không có
- **Pattern xuyên suốt (không riêng bảng nào)**: hầu hết ClickHouse flat table thật đã chuyển sang `materialized: incremental_rebase` + `incremental_strategy: ck_snapshot` + `partition_by: ["ds_snpst_dt"]`, thay vì `CREATE TABLE` tĩnh partition theo cột ngày nghiệp vụ như thiết kế hiện ghi trong `01_create_nhnck_flat_tables.sql`. Xuất hiện ở 8/9 bảng có lệch bên dưới — nên xác nhận 1 lần xem đây là chuẩn hóa kiến trúc chủ đích cho toàn module hay design thật sự lỗi thời, thay vì xử lý riêng lẻ từng bảng.

## Chi tiết lệch theo bảng

### fct_practitioner_license_certificate_snpst (Datamart)
| Attribute/Cột | LLD hiện ghi | Code thực tế (sau test) | Loại thay đổi | Ghi chú |
|---|---|---|---|---|
| decision_signed_dt | Không có trong LLD | Cột mới `date` = `COALESCE(sp_li_de_do_2.decision_signed_dt, sp_li_de_do_3.decision_signed_dt)` (ngày ký quyết định thu hồi/hủy) | Schema | Cột output mới phát sinh ngoài thiết kế |

### fct_practitioner_license_certificate_snpst (ClickHouse)
| Attribute/Cột | Flat-table hiện ghi | Code thực tế (sau test) | Loại thay đổi | Ghi chú |
|---|---|---|---|---|
| decision_signed_dt | Không có | Cột mới pass-through từ dbt fact | Schema | Kéo theo từ lệch dbt phía trên |
| ~~practitioner_insert_dt~~ | Không có | *(đã xoá — không còn trong code)* | — | **ĐÃ FIX** trong commit `742aede` (2026-09-04) — dev tự xoá cột `prac_dim.ds_rcrd_isrt_dt AS practitioner_insert_dt`, đúng như flat-table design vốn không có cột này. Không cần cập nhật gì thêm, chỉ để lưu vết là lệch cũ đã được xử lý |
| Materialization/Partition | `ENGINE=ReplicatedReplacingMergeTree`, `PARTITION BY toYYYYMM(snpst_cdr_dt)`, `ORDER BY (snpst_cdr_dt, license_certificate_document_code)` | `incremental_rebase`/`ck_snapshot`, `partition_by: ["ds_snpst_dt"]` | Structure | Thuộc pattern xuyên suốt nêu ở Tổng hợp — không đổi trong commit này |

### fct_practitioner_daily_snpst (Datamart)
| Attribute/Cột | LLD hiện ghi | Code thực tế (sau test) | Loại thay đổi | Ghi chú |
|---|---|---|---|---|
| age | ETL logic: `YEAR(etl_date) - COALESCE(YEAR(birth_dt), CAST(birth_year AS INT))` (fallback khi birth_dt NULL) | Chỉ có `YEAR(etl_date) - YEAR(birth_dt)`, không SELECT `birth_year`, không COALESCE | Schema | **Nghi ngờ bug thật** — thay đổi giá trị output (age = NULL thay vì fallback). So sánh với `opr_practitioner_360_profile.sql` (cùng logic, có COALESCE đúng) → khác biệt triển khai giữa 2 bảng dùng chung logic. Không đổi trong commit `742aede` — vẫn tồn tại |
| violation_record_dt (đổi tên từ `violation_record_dt_dim_id`) | Không có trong LLD (cả tên cũ lẫn tên mới — kiểm tra `git log --follow` trên file LLD xác nhận cột này chưa từng xuất hiện trong thiết kế) | Commit `742aede` (2026-09-04) đổi tên output column `violation_record_dt_dim_id` → `violation_record_dt` (comment code không giải thích lý do đổi tên cụ thể, suy đoán hợp lý từ diff: bỏ hậu tố `_dim_id` gây hiểu nhầm là surrogate FK trong khi giá trị là ngày thô — đúng như báo cáo đợt 1 đã nghi vấn) | Schema | Lệch tồn tại từ trước (đợt 1), commit này chỉ đổi tên cột chứ chưa thêm vào LLD — **vẫn cần bổ sung vào LLD** |
| first_license_dt | Không có | Cột **mới hoàn toàn** — `MIN(issue_dt)` từ `{{ ref('atm_sp_license_certificate_document') }}_hstr` (lọc `src_stm_code='NHNCK_CERTIFICATE_RECORDS'`, `ds_rcrd_st='ACTIVE'`), GROUP BY `sp_code` | Schema + Source | Lý do rõ trong header comment code: "Bổ sung cột first_license_dt (ngày cấp chứng chỉ đầu tiên của NHN) qua join atm_sp_license_certificate_document". Cần bổ sung attribute mới vào LLD, gồm cả atomic source `atm_sp_license_certificate_document` (nguồn mới, bảng hiện tại chưa join tới) |

### fct_practitioner_daily_snpst (ClickHouse)

> ⚠️ **LỖI CÚ PHÁP SQL — BLOCK BUILD, KHÔNG PHẢI LỆCH THIẾT KẾ THÔNG THƯỜNG**
> File `nhnck_fct_practitioner_daily_snpst_flat.sql` (dòng 12-14) sau commit `742aede` hiện là:
> ```sql
>     f.violation_record_dt,
>     f.first_license_dt
>     TO_DATE(f.snpst_dt_dim_id, 'yyyyMMdd')           AS snpst_cdr_dt,
> ```
> Thiếu dấu `,` giữa `f.first_license_dt` và `TO_DATE(...)` → 2 select item dính liền nhau, sai cú
> pháp SQL, dbt compile/run sẽ **fail**. Ngoài ra dòng 24 (`prac_dim.src_stm_code AS
> practitioner_src_stm_code,`) hiện là item cuối cùng của SELECT nhưng vẫn còn dấu `,` treo trước
> `FROM` (dangling comma) — do dòng `practitioner_insert_dt` phía sau đã bị xoá mà quên bỏ dấu phẩy
> của dòng trước đó; **chưa chắc chắn** dấu phẩy treo này có tự fail hay không tùy engine (Spark SQL
> ANSI mode) — cần dev xác nhận, nhưng riêng lỗi thiếu dấu phẩy ở dòng 12-14 là chắc chắn sai cú
> pháp. Vì file này chưa compile được, danh sách cột "code thực tế" dưới đây là đọc trực tiếp từ
> source, **chưa phải kết quả đã chạy được**.

| Attribute/Cột | Flat-table hiện ghi | Code thực tế (sau test) | Loại thay đổi | Ghi chú |
|---|---|---|---|---|
| violation_record_dt (đổi tên từ `violation_record_dt_dim_id`) | Không có | Pass-through `f.violation_record_dt` (trước đây `f.violation_record_dt_dim_id` + `TO_DATE(...)` derive riêng ở CH layer — nay dbt Datamart đã cast sẵn thành `date`, CH chỉ pass-through) | Schema | Kéo theo lệch dbt phía trên; đồng thời đơn giản hoá — không còn derive `TO_DATE` ở CH layer nữa |
| first_license_dt | Không có | Cột mới pass-through từ dbt fact | Schema | Kéo theo cột mới ở dbt phía trên |
| ~~practitioner_insert_dt~~ | Không có | *(đã xoá — không còn trong code)* | — | **ĐÃ FIX** trong commit `742aede` — đúng như flat-table design vốn không có cột này. Lưu vết lệch cũ đã xử lý |
| Materialization/Partition | `ENGINE=ReplicatedReplacingMergeTree`, `PARTITION BY toYYYYMM(snpst_cdr_dt)`, `ORDER BY (snpst_cdr_dt, practitioner_dim_id)` | `incremental_rebase`/`ck_snapshot`, `partition_by: ["ds_snpst_dt"]` | Structure | Thuộc pattern xuyên suốt — không đổi trong commit này |

### opr_practitioner_data_explorer (Datamart)
Không có lệch — khớp hoàn toàn.

### opr_practitioner_data_explorer (ClickHouse)
| Attribute/Cột | Flat-table hiện ghi | Code thực tế (sau test) | Loại thay đổi | Ghi chú |
|---|---|---|---|---|
| PARTITION BY | `PARTITION BY tuple()` | `incremental_rebase`/`ck_snapshot`, `partition_by: ["ds_snpst_dt"]` | Structure | Thuộc pattern xuyên suốt; cột kỹ thuật `ds_snpst_dt` không có trong DDL thiết kế gốc |

### opr_practitioner_employment_hist (Datamart)
| Attribute/Cột | LLD hiện ghi | Code thực tế (sau test) | Loại thay đổi | Ghi chú |
|---|---|---|---|---|
| securities_organization_reference_nm, organization_tp_code, organization_tp_nm | `nullable=true`, ETL logic ghi rõ **LEFT JOIN** tới `securities_organization_reference` | Code dùng **INNER JOIN** | Structure | Có thể loại hẳn dòng employment report không có bản ghi organization reference active tương ứng — thay đổi grain thực tế so với thiết kế "1 lần công tác per NHN". Chưa chắc chắn có chủ đích |

### opr_practitioner_employment_hist (ClickHouse)
| Attribute/Cột | Flat-table hiện ghi | Code thực tế (sau test) | Loại thay đổi | Ghi chú |
|---|---|---|---|---|
| PARTITION BY | `PARTITION BY toYYYYMM(assumeNotNull(hire_dt))`, `ORDER BY (assumeNotNull(hire_dt), practitioner_code, organization_employment_rpt_code)` | `incremental_rebase`/`ck_snapshot`, `partition_by: ["ds_snpst_dt"]` | Structure | Thuộc pattern xuyên suốt; kết hợp thêm rủi ro mất dòng do INNER JOIN ở dbt layer phía trên |

### opr_practitioner_exam_hist (Datamart)
| Attribute/Cột | LLD hiện ghi | Code thực tế (sau test) | Loại thay đổi | Ghi chú |
|---|---|---|---|---|
| decision_nbr, decision_signed_dt | `nullable=false`; mô tả prose ghi "INNER JOIN — chỉ giữ lần thi có quyết định", nhưng `etl_logic` chi tiết lại ghi LEFT JOIN | Code dùng LEFT JOIN (đúng `etl_logic` chi tiết, không theo prose) → 2 cột có thể NULL | Schema | LLD tự mâu thuẫn nội bộ (prose vs etl_logic); design DDL ClickHouse của 2 cột này đã ghi `Nullable(...)` từ trước → gợi ý `nullable=false` phía dbt LLD là lỗi tài liệu, không phải code sai. Cần Data Modeler chốt lại nullable thật sự mong muốn |

### opr_practitioner_exam_hist (ClickHouse)
| Attribute/Cột | Flat-table hiện ghi | Code thực tế (sau test) | Loại thay đổi | Ghi chú |
|---|---|---|---|---|
| PARTITION BY | `PARTITION BY toYYYYMM(assumeNotNull(examination_start_dt))`, `ORDER BY (assumeNotNull(examination_start_dt), practitioner_code, examination_assessment_result_code)` | `incremental_rebase`/`ck_snapshot`, `partition_by: ["ds_snpst_dt"]` | Structure | Thuộc pattern xuyên suốt |

### opr_practitioner_list_company_role (Datamart)
| Attribute/Cột | LLD hiện ghi | Code thực tế (sau test) | Loại thay đổi | Ghi chú |
|---|---|---|---|---|
| account_nbr, account_holder_nm (nguồn investment_account) | `atomic_table = investment_account`, LLD đã ghi vấn đề mở **O_NHNCK_33** ("Atomic DDL trực tiếp, chưa có YAML LLD chính thức") | Query thẳng bảng vật lý `atomic.uat_atm.investment_account`, không qua `ref()` (comment code 2026-08-11: "dummy data tạm thời") | Structure | Không phải lệch mới — đã biết trước (O_NHNCK_33). Cần theo dõi khi atomic model chính thức có `ref()` |
| main_held_securities_code, vsdc_held_securities_vol (nguồn major_shareholder) | Cùng ghi chú O_NHNCK_33 | Query thẳng `atomic.uat_atm.major_shareholder`, không qua `ref()` | Structure | Cùng lý do trên |

### opr_practitioner_list_company_role (ClickHouse)
| Attribute/Cột | Flat-table hiện ghi | Code thực tế (sau test) | Loại thay đổi | Ghi chú |
|---|---|---|---|---|
| Materialization/Partition | `ENGINE=ReplicatedReplacingMergeTree`, `PARTITION BY tuple()` (bảng trạng thái hiện tại, không snapshot) | `incremental_rebase`/`ck_snapshot`, `partition_by: ["ds_snpst_dt"]`; select thật đọc `..._hstr WHERE ds_snpst_dt = etl_date` | Structure | Lệch cơ chế lưu trữ: thiết kế cũ là replace-in-place theo PK, code thật chạy theo mô hình snapshot theo ngày |
| account_nbr, account_holder_nm — nguồn dữ liệu | Comment CREATE TABLE cũ: "nguồn open_investors" | Không tìm thấy `open_investors` trong repo; code thật lấy từ `atomic.uat_atm.investment_account` | Source | Chưa chắc chắn — có thể `open_investors` là tên gọi cũ của cùng nguồn, cần xác nhận để sửa lại comment thiết kế |

### opr_practitioner_related_party_profile (Datamart)
Không có lệch — khớp hoàn toàn. (CTE `cv` đọc trực tiếp `atomic.uat_atm.cl_value` thay vì
`ref('atm_...')` — đã xác nhận với Data Modeler đây là cách làm CHUẨN cho Classification Value, vì
bảng này được khởi tạo trực tiếp ở tầng Atomic, không phải downstream của 1 dbt job khác. Không tính
là lệch Source.)

### opr_practitioner_related_party_profile (ClickHouse)
| Attribute/Cột | Flat-table hiện ghi | Code thực tế (sau test) | Loại thay đổi | Ghi chú |
|---|---|---|---|---|
| Materialization/Partition | `PARTITION BY tuple()` | `incremental_rebase`/`ck_snapshot`, `partition_by: ["ds_snpst_dt"]` | Structure | Thuộc pattern xuyên suốt |
| Cột kỹ thuật `ds_snpst_dt` | Không có trong danh sách 12 cột CREATE TABLE | Dùng làm partition key trong yml, nhưng không SELECT ra trong `.sql` | Schema | Chưa chắc chắn — có thể do macro materialization tự thêm ngoài phạm vi file đọc được |

### opr_practitioner_training_hist (Datamart)
Không có lệch — khớp hoàn toàn.

### opr_practitioner_training_hist (ClickHouse)
| Attribute/Cột | Flat-table hiện ghi | Code thực tế (sau test) | Loại thay đổi | Ghi chú |
|---|---|---|---|---|
| PARTITION BY | `toYYYYMM(assumeNotNull(training_start_dt))` | `partition_by: ["ds_snpst_dt"]` | Structure | Thuộc pattern xuyên suốt |
| ENGINE/Materialization | DDL tay `ENGINE=ReplicatedReplacingMergeTree()` | `incremental_rebase`/`ck_snapshot` (dbt-managed) | Structure | Thuộc pattern xuyên suốt |
| ORDER BY | `(assumeNotNull(training_start_dt), practitioner_code, training_result_code)` | Không khai báo tường minh (quản lý qua macro) | Structure | Chưa chắc chắn, cần xác nhận sort key thật |
| training_hours (kiểu dữ liệu) | `Nullable(Int64)` | Không CAST tường minh, kiểu inherit từ datamart layer là `int` | Schema | Chưa chắc chắn Int64 hay Int32 thật sự |
| COMMENT cột (lineage) | Mỗi cột có COMMENT lineage riêng | Không có COMMENT nào trong `.sql` | Structure | Chưa chắc chắn — giảm documentation hay chỉ đổi cơ chế gen |

### opr_practitioner_violation_hist (Datamart)
Không có lệch — khớp hoàn toàn.

### opr_practitioner_violation_hist (ClickHouse)
| Attribute/Cột | Flat-table hiện ghi | Code thực tế (sau test) | Loại thay đổi | Ghi chú |
|---|---|---|---|---|
| Partitioning strategy | `PARTITION BY toYYYYMM(decision_signed_dt)` (theo ngày nghiệp vụ) | `partition_by: ["ds_snpst_dt"]` (theo ngày snapshot ETL) | Structure | Thuộc pattern xuyên suốt |

### securities_practitioner_dim (Datamart)
Không có lệch — khớp hoàn toàn. Xác nhận: không có ClickHouse flat table tương ứng ở cả thiết kế lẫn code thật — nhất quán, không phải gap.

### sp_license_certificate_type_dim (Datamart)
Không có lệch — khớp hoàn toàn. Xác nhận: không có ClickHouse flat table tương ứng ở cả thiết kế lẫn code thật (chỉ được tiêu thụ làm nguồn của `fct_practitioner_license_certificate_snpst`) — nhất quán, không phải gap.

---

## Lưu ý bàn giao

Đây là báo cáo phát hiện — không file thiết kế nào bị chỉnh sửa trong quá trình audit. Data Modeler tự tay cập nhật `Datamart/lld/NHNCK/`, `Datamart/flat-table/NHNCK/`, và HLD nếu cần.

Ưu tiên xử lý trước các điểm sau:

**0. [MỚI — 2026-09-04, commit `742aede`] `nhnck_fct_practitioner_daily_snpst_flat.sql` — lỗi cú pháp SQL block build.** Báo ngay cho dev, không phải vấn đề thiết kế — thiếu dấu phẩy giữa `f.first_license_dt` và `TO_DATE(...) AS snpst_cdr_dt`. Xem chi tiết trong section ClickHouse của `fct_practitioner_daily_snpst` ở trên. Cần fix trước khi bàn tới các lệch thiết kế khác của cùng file, vì file hiện chưa chạy được.

Sau đó, ưu tiên 2 điểm sau vì có khả năng ảnh hưởng đúng đắn dữ liệu (không chỉ đồng bộ kỹ thuật) — nên trao đổi với dev trước khi quyết định sửa thiết kế hay yêu cầu sửa lại code:
1. `fct_practitioner_daily_snpst.age` — mất fallback `birth_year`, khác với bảng `opr_practitioner_360_profile` dùng chung logic.
2. `opr_practitioner_employment_hist` — LEFT JOIN thiết kế bị đổi thành INNER JOIN, có thể làm rớt dòng.

**[MỚI — 2026-09-04, commit `742aede`] Cần bổ sung LLD/flat-table (thuần đồng bộ kỹ thuật, không phải bug):**
3. `dtm_fct_practitioner_daily_snpst` — bổ sung 2 attribute mới vào LLD: `violation_record_dt` (đổi tên từ `violation_record_dt_dim_id`, lệch tồn tại từ đợt 1) và `first_license_dt` (cột mới, nguồn `atm_sp_license_certificate_document`).
4. `nhnck_fct_practitioner_daily_snpst_flat` (ClickHouse) — bổ sung 2 cột tương ứng vào flat-table design sau khi fix xong lỗi cú pháp mục 0.
5. 2 lệch cũ đã tự fix trong code (không cần Data Modeler làm gì): `practitioner_insert_dt` bị xoá khỏi cả `nhnck_fct_practitioner_daily_snpst_flat` và `nhnck_fct_practitioner_license_certificate_snpst_flat`, nay khớp lại với flat-table design.

Nếu quyết định sửa mang tính nghiệp vụ (không chỉ đồng bộ kỹ thuật), nên gọi skill `datamart-lld-design`/`datamart-hld-design` thay vì tự sửa tay trực tiếp.
