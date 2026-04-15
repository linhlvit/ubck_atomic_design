# ThanhTra HLD — Tier 4 (và Tier 5)

**Source system:** ThanhTra  
**Tier 4:** Các entity có FK đến Tier 3.  
**Tier 5:** `TT_CONG_BO_XU_PHAT` — FK đến Tier 4 (TT_KET_LUAN). Gộp chung file để tiện tham chiếu.

---

## 6a. Bảng tổng quan BCV Concept

| Tier | BCV Core Object | BCV Concept | Source Table | Mô tả bảng nguồn | Silver Entity | table_type | Ghi chú |
|---|---|---|---|---|---|---|---|
| T4 | Business Activity | [Business Activity] Audit Investigation | TT_HO_SO_CAN_BO | Phân công cán bộ xử lý hồ sơ thanh tra | Inspection Case Officer Assignment | Fundamental | FK → Inspection Case (T3) + FK → Inspection Officer (T1). Grain: 1 cán bộ × 1 hồ sơ × 1 vai trò. |
| T4 | Documentation | [Documentation] Supporting Documentation | TT_HO_SO_VAN_BAN | Văn bản đính kèm hồ sơ thanh tra (biên bản làm việc, yêu cầu cung cấp tài liệu...) | Inspection Case Document Attachment | Fundamental | FK → Inspection Case (T3). Grain: 1 văn bản. |
| T4 | Business Activity | [Business Activity] Audit Investigation | TT_KET_LUAN | Kết luận thanh tra và văn bản xử lý sau thanh tra | Inspection Case Conclusion | Fundamental | FK → Inspection Case (T3). Grain: 1 kết luận = 1 cuộc thanh tra. Có thể kèm quyết định xử phạt. |
| T4 | Business Activity | [Business Activity] Conduct Violation | DT_CONG_BO_XU_PHAT | Công bố quyết định xử phạt từ hồ sơ đơn thư | Complaint Penalty Announcement | Fundamental | FK → Complaint Enforcement Decision (T3). Grain: 1 lần công bố. |
| T5 | Business Activity | [Business Activity] Conduct Violation | TT_CONG_BO_XU_PHAT | Công bố quyết định xử phạt từ kết luận thanh tra | Inspection Penalty Announcement | Fundamental | FK → Inspection Case Conclusion (T4). Grain: 1 lần công bố. |

---

## 6b. Diagram Source (Mermaid)

```mermaid
erDiagram
    TT_HO_SO {
        int ID PK
        int QUYET_DINH_ID FK
        string MA_HO_SO
        string TRANG_THAI
    }

    TT_HO_SO_CAN_BO {
        int ID PK
        int HO_SO_ID FK
        int CAN_BO_ID FK
        int CHUC_VU_ID FK
        string VAI_TRO
        date NGAY_PHAN_CONG
        date NGAY_KET_THUC
    }

    TT_HO_SO_VAN_BAN {
        int ID PK
        int HO_SO_ID FK
        string TEN_VAN_BAN
        string SO_HIEU_VAN_BAN
        date NGAY_BAN_HANH
        string LOAI_VAN_BAN
        string FILE_DINH_KEM
        string MUC_DO_BAO_MAT
    }

    TT_KET_LUAN {
        int ID PK
        int HO_SO_ID FK
        string SO_VAN_BAN
        date NGAY_KY
        string NOI_DUNG_KET_LUAN
        string HANH_VI_VI_PHAM
        string HINH_THUC_XU_LY
        decimal SO_TIEN_PHAT
        int NGUOI_KY FK
        string TRANG_THAI
    }

    DT_VAN_BAN_XU_LY {
        int ID PK
        int HO_SO_ID FK
    }

    DT_CONG_BO_XU_PHAT {
        int ID PK
        int VAN_BAN_XU_LY_ID FK
        date NGAY_CONG_BO
        string KENH_CONG_BO
        string TRANG_THAI_CONG_BO
    }

    TT_CONG_BO_XU_PHAT {
        int ID PK
        int KET_LUAN_ID FK
        date NGAY_CONG_BO
        string KENH_CONG_BO
        string TRANG_THAI_CONG_BO
    }

    TT_HO_SO ||--o{ TT_HO_SO_CAN_BO : "HO_SO_ID"
    TT_HO_SO ||--o{ TT_HO_SO_VAN_BAN : "HO_SO_ID"
    TT_HO_SO ||--o{ TT_KET_LUAN : "HO_SO_ID"
    DT_VAN_BAN_XU_LY ||--o{ DT_CONG_BO_XU_PHAT : "VAN_BAN_XU_LY_ID"
    TT_KET_LUAN ||--o{ TT_CONG_BO_XU_PHAT : "KET_LUAN_ID"
```

---

## 6c. Diagram Silver (Mermaid)

```mermaid
erDiagram
    InspectionCase["Inspection Case (T3)"] {
        bigint inspection_case_id PK
    }

    InspectionCaseOfficerAssignment["Inspection Case Officer Assignment"] {
        bigint inspection_case_officer_assignment_id PK
        bigint inspection_case_id FK
        bigint inspection_officer_id FK
        string officer_role_code
        date assignment_start_date
        date assignment_end_date
    }

    InspectionCaseDocAttachment["Inspection Case Document Attachment"] {
        bigint inspection_case_doc_attachment_id PK
        bigint inspection_case_id FK
        string document_name
        string document_number
        date issue_date
        string document_type_code
        string security_level_code
        string attachment_url
    }

    InspectionCaseConclusion["Inspection Case Conclusion"] {
        bigint inspection_case_conclusion_id PK
        bigint inspection_case_id FK
        small_counter conclusion_sequence_number
        string conclusion_document_number
        date signing_date
        string conclusion_summary
        string violation_type_code
        string penalty_type_code
        currency_amount penalty_amount
        bigint signing_officer_id FK
        string conclusion_status_code
    }

    ComplaintEnforcementDecision["Complaint Enforcement Decision (T3)"] {
        bigint complaint_enforcement_decision_id PK
    }

    ComplaintPenaltyAnnouncement["Complaint Penalty Announcement"] {
        bigint complaint_penalty_announcement_id PK
        bigint complaint_enforcement_decision_id FK
        date announcement_date
        string announcement_channel
        string announcement_status_code
    }

    InspectionPenaltyAnnouncement["Inspection Penalty Announcement"] {
        bigint inspection_penalty_announcement_id PK
        bigint inspection_case_conclusion_id FK
        date announcement_date
        string announcement_channel
        string announcement_status_code
    }

    InspectionOfficer["Inspection Officer (T1)"] {
        bigint inspection_officer_id PK
    }

    InspectionCase ||--o{ InspectionCaseOfficerAssignment : "inspection_case_id"
    InspectionCase ||--o{ InspectionCaseDocAttachment : "inspection_case_id"
    InspectionCase ||--o{ InspectionCaseConclusion : "inspection_case_id"
    InspectionCaseOfficerAssignment ||--o{ InspectionOfficer : "inspection_officer_id"
    InspectionCaseConclusion ||--o{ InspectionOfficer : "signing_officer_id"
    InspectionCaseConclusion ||--o{ InspectionPenaltyAnnouncement : "inspection_case_conclusion_id"
    ComplaintEnforcementDecision ||--o{ ComplaintPenaltyAnnouncement : "complaint_enforcement_decision_id"
```

---

## 6d. Quyết định thiết kế quan trọng

### D1 — TT_KET_LUAN: quan hệ 1:N với TT_HO_SO

**Xác nhận:** 1 hồ sơ (`Inspection Case`) có thể có nhiều kết luận — ví dụ kết luận sơ bộ, kết luận chính thức, kết luận bổ sung sau khiếu nại.

→ Grain: 1 kết luận = 1 lần ban hành văn bản kết luận cho 1 hồ sơ. Thêm `conclusion_sequence_number` (data domain: Small Counter) để xác định thứ tự phiên bản trong cùng 1 hồ sơ.

`TT_KET_LUAN` đồng thời chứa thông tin xử lý (HANH_VI_VI_PHAM, HINH_THUC_XU_LY, SO_TIEN_PHAT). Không tách thành entity riêng vì không có bảng nguồn riêng cho "quyết định xử phạt" trong luồng TT_ (khác với GS_/DT_ có bảng _VAN_BAN_XU_LY riêng).

→ Lưu `violation_type_code`, `penalty_type_code` (Classification Values) và `penalty_amount` trực tiếp trong `Inspection Case Conclusion`.

### D2 — TT_CONG_BO_XU_PHAT vs. GS_CONG_BO_XU_PHAT vs. DT_CONG_BO_XU_PHAT

Ba bảng này có cấu trúc tương tự (NGAY_CONG_BO, KENH_CONG_BO, TRANG_THAI) nhưng FK đến các entity cha khác nhau:
- `TT_CONG_BO_XU_PHAT` → `Inspection Case Conclusion` (T4)
- `GS_CONG_BO_XU_PHAT` → `Surveillance Enforcement Decision` (T2)
- `DT_CONG_BO_XU_PHAT` → `Complaint Enforcement Decision` (T3)

**Quyết định: KHÔNG gộp** — cùng lý do như Document Attachment: FK không đồng nhất. Giữ 3 entity riêng với tên rõ theo luồng nghiệp vụ.

### D3 — TT_HO_SO_CAN_BO.CHUC_VU_ID

FK đến `DM_CHUC_VU` → CV `TT_POSITION_TYPE`. Tương tự `TT_QUYET_DINH_THANH_PHAN`. Lưu `officer_role_code` (CV).

---

## 6e. Bảng chờ thiết kế

Không còn bảng nào trong scope ThanhTra chưa được xử lý, ngoại trừ:
- **`PCRT_BAO_CAO`**: chờ xác nhận (xem 6f)
- **SYS_* tables (8 bảng)**: xác nhận out-of-scope

---

## 6f. Điểm cần xác nhận

| # | Câu hỏi | Ảnh hưởng |
|---|---|---|
| 1 | **PCRT_BAO_CAO** (báo cáo PCRT định kỳ) — có FK đến PCRT_HO_SO hay độc lập? | Nếu độc lập → Tier 1 Fact Append (thêm vào silver_entities.csv cùng với `Anti-Corruption Report`). Nếu có FK → Tier 2. |
| 2 | **TT_KET_LUAN** có 1 hồ sơ → nhiều kết luận (revisions) hay chỉ 1 kết luận cuối? | Nếu 1:1 → grain không thay đổi. Nếu 1:N → cần thêm `revision_number` hoặc `is_current` indicator. |
| 3 | **TT_CONG_BO_XU_PHAT** trực tiếp FK → TT_KET_LUAN hay có bảng trung gian nào khác? | Ảnh hưởng tier assignment. |
