# Đối chiếu Atomic_LinhLV vs HLD ThanhTra — Phân tích tái sử dụng

**Ngày:** 2026-06-24
**Mục đích:** Xác định entity nào trong `DataModel/working/Atomic_LinhLV/` (source ThanhTra) có thể tái sử dụng cho thiết kế LLD theo `ThanhTra_HLD_Overview.md`.

---

## 1. Bối cảnh: 2 schema nguồn khác nhau

| | LinhLV (cũ) | HLD ThanhTra mới |
|---|---|---|
| **Schema nguồn** | TT_KE_HOACH, TT_QUYET_DINH, TT_HO_SO, TT_KET_LUAN, DT_HO_SO, GS_HO_SO, PCRT_HO_SO… | INSPECTION_ANNUAL_PLAN, INSPECTION_TEAM, VIOLATION_CASE, PENALTY_DECISION… |
| **Ngôn ngữ bảng** | Tiếng Việt | Tiếng Anh |
| **Cấu trúc module** | 4 module riêng: TT / DT / GS / PCRT | 1 hệ thống thống nhất |
| **BCV Concept chính** | `[Business Activity] Audit Investigation` | `[Business Activity] Business Review` / `Conduct Violation` |
| **table_type** | Fact Append | Fundamental / Classification |

LinhLV thiết kế từ **schema cũ** của ThanhTra. HLD mới dựa trên **schema đã tái cấu trúc** hoàn toàn. Không thể map 1-1 mà cần đối chiếu theo concept nghiệp vụ.

---

## 2. Nhóm 1 — Tái sử dụng được (có điều chỉnh)

Các entity có concept trùng khớp, physical_name giữ nguyên, cần đổi `source_table` và bổ sung/bỏ attribute.

| Entity LinhLV | Source cũ | Entity HLD mới | Source mới | Điều chỉnh cần thiết |
|---|---|---|---|---|
| `Inspection Annual Plan` | TT_KE_HOACH | Inspection Annual Plan | INSPECTION_ANNUAL_PLAN | Đổi `source_table`; bổ sung `DECISION_NUMBER`, `STATUS (DRAFT/APPROVED)` |
| `Inspection Annual Plan Target` | TT_KE_HOACH_DOI_TUONG | Inspection Annual Plan Target | INSPECTION_ANNUAL_PLAN_TARGET | Đổi `source_table`; cập nhật `TARGET_TYPE` values |
| `Inspection Case Conclusion` | TT_KET_LUAN | Inspection Conclusion | INSPECTION_CONCLUSION | Đổi tên entity + FK từ `insp_case` → `insp_team`; bỏ `pny_amt`, `vln_claus` (nay thuộc Violation Case) |
| `Inspection Conclusion Remedial` (nếu có) | TT_KET_LUAN sub | Inspection Conclusion Remedial | INSPECTION_CONCLUSION_REMEDIAL | Đổi `source_table` |
| `Inspection Team Member` | TT_QUYET_DINH_THANH_PHAN | Inspection Team Member | INSPECTION_TEAM_MEMBER | Đổi `source_table`; kiểm tra `ROLE_TYPE` mapping |
| `Inspection Team Target` | TT_QUYET_DINH_DOI_TUONG | Inspection Team Target | INSPECTION_TEAM_TARGET | Đổi `source_table`; `TARGET_TYPE` mới có 7 values |

> **Lưu ý quan trọng:** `Inspection Case` (TT_HO_SO) + `Inspection Decision` (TT_QUYET_DINH) của LinhLV tương ứng với 1 entity `Inspection Team` (INSPECTION_TEAM) trong HLD mới. LinhLV tách 2 bảng riêng, HLD mới gộp lại. Cần **merge attributes**, không tái sử dụng nguyên xi.

---

## 3. Nhóm 2 — LinhLV có, HLD mới không có (schema cũ không còn)

Các entity này thiết kế từ module cũ (DT/GS/PCRT) không tồn tại trong schema mới → **bỏ qua, không tái sử dụng**.

### Module DT (Đơn thư — khiếu nại/tố cáo)

| Entity LinhLV | Source cũ | Thay thế trong HLD mới |
|---|---|---|
| `Complaint Petition` | DT_DON_THU | → `TT Petition` (PETITION) |
| `Complaint Processing Case` | DT_HO_SO | → Không có equivalent trực tiếp |
| `Complaint Processing Conclusion` | DT_KET_LUAN | → Không có equivalent |
| `Complaint Enforcement Decision` | DT_VAN_BAN_XU_LY | → Không có equivalent |
| `Complaint Penalty Announcement` | DT_CONG_BO_XU_PHAT | → Không có equivalent |

### Module GS (Giám sát — xử lý vi phạm từ giám sát thị trường)

| Entity LinhLV | Source cũ | Thay thế trong HLD mới |
|---|---|---|
| `Surveillance Enforcement Case` | GS_HO_SO | → Gần với `TT Violation Case` nhưng khác concept |
| `Surveillance Enforcement Decision` | GS_VAN_BAN_XU_LY | → Không có equivalent |
| `Surveillance Penalty Announcement` | GS_CONG_BO_XU_PHAT | → Không có equivalent |

### Module PCRT / PCTN (Phòng chống rửa tiền / tham nhũng)

| Entity LinhLV | Source cũ | Thay thế trong HLD mới |
|---|---|---|
| `AML Enforcement Case` | PCRT_HO_SO | → Ngoài scope HLD mới |
| `AML Enforcement Decision` | PCRT_VAN_BAN_XU_LY | → Ngoài scope HLD mới |
| `AML Periodic Report` | PCRT_BAO_CAO | → Ngoài scope HLD mới |
| `Anti-corruption Report` | PCTN_BAO_CAO | → Ngoài scope HLD mới |

---

## 4. Nhóm 3 — HLD mới có, LinhLV không có (thiết kế mới hoàn toàn)

37 entity trong HLD mới, LinhLV chỉ cover một phần module TT. Các entity dưới đây cần LLD từ đầu.

### Tier 1

| Entity HLD mới | Source | Ghi chú |
|---|---|---|
| `Examination Annual Plan` | EXAMINATION_ANNUAL_PLAN | LinhLV không có module kiểm tra riêng |
| `Legal Document` | LEGAL_DOCUMENT | Không thiết kế trong LinhLV |
| `Petition` | PETITION | LinhLV có `cpln_petition` nhưng schema khác, concept khác |
| `Proactive Notice` | PROACTIVE_NOTICE | Hoàn toàn mới |
| `Security Measure Decision` | SECURITY_MEASURE_DECISION | Hoàn toàn mới |
| `Penalty Type` | PENALTY_TYPE | Hoàn toàn mới |

### Tier 2

| Entity HLD mới | Source | Ghi chú |
|---|---|---|
| `Examination Annual Plan Target` | EXAMINATION_ANNUAL_PLAN_TARGET | Mới hoàn toàn |
| `Examination Team` | EXAMINATION_TEAM | Mới hoàn toàn |
| `Citizen Reception` | CITIZEN_RECEPTION | Mới hoàn toàn |
| `Petition Document` | PETITION_DOCUMENT | Mới hoàn toàn |
| `Proactive Notice Recipient` | PROACTIVE_NOTICE_RECIPIENT | Mới hoàn toàn |
| `Security Measure Decision Subject` | SECURITY_MEASURE_DECISION_SUBJECT | Mới hoàn toàn |
| `Security Measure Decision Recipient` | SECURITY_MEASURE_DECISION_RECIPIENT | Mới hoàn toàn |
| `Security Measure Execution` | SECURITY_MEASURE_EXECUTION | Mới hoàn toàn |
| `Violation Behavior` | VIOLATION_BEHAVIOR | Mới hoàn toàn |

### Tier 3

| Entity HLD mới | Source | Ghi chú |
|---|---|---|
| `Examination Team Member` | EXAMINATION_TEAM_MEMBER | Mới hoàn toàn |
| `Examination Team Target` | EXAMINATION_TEAM_TARGET | Mới hoàn toàn |
| `Examination Result Notice` | EXAMINATION_RESULT_NOTICE | Mới hoàn toàn |
| `Violation Case` | VIOLATION_CASE | LinhLV không có — khác với GS_HO_SO |
| `Violation Record` | VIOLATION_RECORD | Mới hoàn toàn |

### Tier 4–7

| Entity HLD mới | Source | Tier |
|---|---|---|
| `Penalty Decision` | PENALTY_DECISION | T4 |
| `Violation Case Output Document` | VIOLATION_CASE_OUTPUT_DOCUMENT | T4 |
| `Violation Case Received Document` | VIOLATION_CASE_RECEIVED_DOCUMENT | T4 |
| `Violation Record Behavior` | VIOLATION_RECORD_BEHAVIOR | T4 |
| `Inspection Conclusion Remedial` | INSPECTION_CONCLUSION_REMEDIAL | T4 |
| `Examination Result Notice Remedial` | EXAMINATION_RESULT_NOTICE_REMEDIAL | T4 |
| `Inspection Post Processing` | POST_INSPECTION_PROCESSING | T4 |
| `Penalty Decision Subject` | PENALTY_DECISION_SUBJECT | T5 |
| `VPHC Official Letter` | VPHC_PROCESS_OFFICIAL_LETTER | T5 |
| `Penalty Decision Subject Behavior` | PENALTY_DECISION_SUBJECT_BEHAVIOR | T6 |
| `Penalty Decision Subject Behavior Circumstance` | PENALTY_DECISION_CIRCUMSTANCE | T7 |

---

## 5. Nhóm 4 — Shared Entity (IP/Location) — Tái sử dụng trực tiếp

Các entity shared không thuộc riêng ThanhTra, chỉ cần thêm source mới vào file YAML hiện có.

| Entity | File LinhLV | Hành động |
|---|---|---|
| `IP Electronic Address` | dm_atm_ip_elc_adr-ThanhTra.DM_CAN_BO.yaml (và các file tương tự) | Thêm source `ThanhTra` mới (INSPECTION_TEAM_MEMBER…) vào shared entity |
| `IP Postal Address` | dm_atm_ip_pst_adr-ThanhTra.*.yaml | Tương tự |
| `Securities Company` | dm_atm_scr_co-ThanhTra.DM_CONG_TY_CK.yaml | Thêm source reference |
| `Public Company` | dm_atm_pblc_co-ThanhTra.DM_CONG_TY_DC.yaml | Thêm source reference |
| `Fund Management Company` | dm_atm_fnd_mgt_co-ThanhTra.DM_CONG_TY_QLQ.yaml | Thêm source reference |
| `Inspection Officer` | dm_atm_insp_ofcr-ThanhTra.DM_CAN_BO.yaml | Review: HLD mới dùng `USER_ID` FK → cần xác nhận có entity cán bộ riêng không |

---

## 6. Tổng hợp

| Nhóm | Số entity | Hành động |
|---|---|---|
| Tái sử dụng được (có điều chỉnh) | ~6 | Giữ physical_name, đổi `source_table`, cập nhật attributes |
| LinhLV có nhưng không dùng được (schema cũ) | ~12 | Bỏ qua |
| Cần thiết kế mới hoàn toàn | ~25 | Thiết kế LLD từ BRD theo HLD |
| Shared IP/Location entity | ~5 nhóm | Extend thêm source reference mới |

---

## 7. Khuyến nghị thực hiện

1. **Ưu tiên tái sử dụng Nhóm 1** trước: copy YAML, đổi `source_table`, `ldm.id`, cập nhật attributes delta. Tiết kiệm thời gian cho 6 entity core.
2. **Nhóm 4 (shared IP):** Không cần tạo file mới — chỉ bổ sung `source_column` mapping từ schema mới vào file LinhLV hiện có.
3. **Nhóm 3 (entity mới):** Thiết kế LLD từ đầu theo HLD. Ưu tiên theo thứ tự Tier (T1 → T7) để đảm bảo FK dependency đã có entity cha trước.
4. **Nhóm 2 (schema cũ):** Không xóa file LinhLV — giữ nguyên nhưng đánh dấu `status: deprecated` để tránh nhầm lẫn.
