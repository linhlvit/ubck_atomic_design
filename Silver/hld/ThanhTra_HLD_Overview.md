# ThanhTra HLD — Overview

**Source system:** ThanhTra  
**Tổng số bảng nguồn:** 56 (ThanhTra_Tables.csv)  
**Phạm vi thiết kế Silver:** 46 bảng nghiệp vụ (bỏ 8 SYS_, 2 SYS_VAN_BAN_PHAP_QUY)

---

## 1. Tổng quan Silver Entities theo Tier

| Tier | Entity | BCV Concept | Source Table(s) | Status |
|---|---|---|---|---|
| **T1** | Inspection Officer | [IP] Individual | DM_CAN_BO | draft |
| **T1** | ~~Inspection Subject Organization~~ → **Securities Company** (reuse) | [IP] Organization | DM_CONG_TY_CK → reuse entity gốc | draft |
| **T1** | ~~Inspection Subject Organization~~ → **Fund Management Company** (reuse) | [IP] Portfolio Fund Management Company | DM_CONG_TY_QLQ → reuse entity gốc | draft |
| **T1** | **Public Company** (new) | [IP] Organization | DM_CONG_TY_DC | draft |
| **T1** | Inspection Subject Other Party | [IP] Individual/Organization | DM_DOI_TUONG_KHAC | draft |
| **T1** | **AML Periodic Report** (new) | [BA] Audit Investigation | PCRT_BAO_CAO | draft |
| **T1** | Inspection Annual Plan | [BA] Audit Investigation | TT_KE_HOACH | draft |
| **T1** | Surveillance Enforcement Case | [BA] Conduct Violation | GS_HO_SO | draft |
| **T1** | Complaint Petition | [BA] Conduct Violation | DT_DON_THU | draft |
| **T1** | AML Enforcement Case | [BA] Audit Investigation | PCRT_HO_SO | draft |
| **T1** | Anti-Corruption Report | [BA] Audit Investigation | PCTN_BAO_CAO | draft |
| **T2** | Inspection Annual Plan Subject | [BA] Audit Investigation | TT_KE_HOACH_DOI_TUONG | draft |
| **T2** | Inspection Annual Plan Document Attachment | Documentation | TT_KE_HOACH_VAN_BAN | draft |
| **T2** | Inspection Decision | [BA] Audit Investigation | TT_QUYET_DINH | draft |
| **T2** | Complaint Processing Case | [BA] Conduct Violation | DT_HO_SO | draft |
| **T2** | Surveillance Case Document Attachment | Documentation | GS_HO_SO_VAN_BAN | draft |
| **T2** | Surveillance Enforcement Decision | [BA] Conduct Violation | GS_VAN_BAN_XU_LY | draft |
| **T2** | AML Case Document Attachment | Documentation | PCRT_HO_SO_VAN_BAN | draft |
| **T2** | AML Enforcement Decision | [BA] Conduct Violation | PCRT_VAN_BAN_XU_LY | draft |
| **T3** | Inspection Decision Subject | [BA] Audit Investigation | TT_QUYET_DINH_DOI_TUONG | draft |
| **T3** | Inspection Decision Team Member | [BA] Audit Investigation | TT_QUYET_DINH_THANH_PHAN | draft |
| **T3** | Inspection Decision Document Attachment | Documentation | TT_QUYET_DINH_VAN_BAN | draft |
| **T3** | Inspection Case | [BA] Audit Investigation | TT_HO_SO | draft |
| **T3** | Complaint Processing Case Document Attachment | Documentation | DT_HO_SO_VAN_BAN | draft |
| **T3** | Complaint Processing Conclusion | [BA] Conduct Violation | DT_KET_LUAN | draft |
| **T3** | Complaint Enforcement Decision | [BA] Conduct Violation | DT_VAN_BAN_XU_LY | draft |
| **T3** | Surveillance Enforcement Decision File Attachment | Documentation | GS_VAN_BAN_XU_LY_FILE | draft |
| **T3** | Surveillance Penalty Announcement | [BA] Conduct Violation | GS_CONG_BO_XU_PHAT | draft |
| **T4** | Inspection Case Officer Assignment | [BA] Audit Investigation | TT_HO_SO_CAN_BO | draft |
| **T4** | Inspection Case Document Attachment | Documentation | TT_HO_SO_VAN_BAN | draft |
| **T4** | Inspection Case Conclusion | [BA] Audit Investigation | TT_KET_LUAN | draft |
| **T4** | Complaint Penalty Announcement | [BA] Conduct Violation | DT_CONG_BO_XU_PHAT | draft |
| **T5** | Inspection Penalty Announcement | [BA] Conduct Violation | TT_CONG_BO_XU_PHAT | draft |

**Tổng: 32 Silver entities** (30 thiết kế mới + 2 reuse: Securities Company, Fund Management Company)

---

## 2. Bảng nguồn out-of-scope / xử lý đặc biệt

| Bảng nguồn | Lý do | Xử lý |
|---|---|---|
| DM_BIEU_MAU | Reference data | Classification Value `TT_FORM_TYPE` |
| DM_CHUC_VU | Reference data | Classification Value `TT_POSITION_TYPE` |
| DM_DON_VI | Reference data | Classification Value `TT_UNIT_TYPE` |
| DM_HO_SO | Reference data | Classification Value `TT_CASE_TYPE` |
| DM_TRANG_THAI_HO_SO | Reference data | Classification Value `TT_CASE_STATUS` |
| DM_LINH_VUC | Reference data | Classification Value `TT_INSPECTION_SECTOR` |
| DM_HANH_VI_VI_PHAM | Reference data | Classification Value `TT_VIOLATION_TYPE` |
| DM_HINH_THUC_PHAT | Reference data | Classification Value `TT_PENALTY_TYPE` |
| DM_HINH_THUC_VAN_BAN | Reference data | Classification Value `TT_DOCUMENT_FORM_TYPE` |
| DM_MANG_NGHIEP_VU | Reference data | Classification Value `TT_BUSINESS_SECTOR` |
| DM_MUC_DO_BAO_MAT | Reference data | Classification Value `TT_SECURITY_LEVEL` |
| DM_CAN_CU_THANH_TRA | Reference data | Classification Value `TT_LEGAL_BASIS_TYPE` |
| DM_DANH_MUC_KHAC | Reference data | Classification Value `TT_MISC_CATEGORY` |
| DM_QUOC_GIA | Geographic ref. | Geographic Area (COUNTRY) — dùng chung |
| DM_TINH_THANH | Geographic ref. | Geographic Area (PROVINCE) — dùng chung |
| SYS_NGUOI_DUNG | System/audit | Out-of-scope |
| SYS_NHOM_NGUOI_DUNG | System/audit | Out-of-scope |
| SYS_NGUOI_DUNG_NHOM | System/audit | Out-of-scope |
| SYS_NHAT_KY | System/audit | Out-of-scope |
| SYS_THAM_SO | System/audit | Out-of-scope |
| SYS_SAO_LUU | System/audit | Out-of-scope |
| SYS_NHAT_KY_SAO_LUU | System/audit | Out-of-scope |
| SYS_VAN_BAN_PHAP_QUY | Regulatory ref. — out of Silver scope | Out-of-scope |
| PCRT_BAO_CAO | Báo cáo PCRT định kỳ độc lập | **Silver entity `AML Periodic Report`** (T1 Fact Append) |
| SYS_NGUOI_DUNG + 8 bảng SYS_ | Out-of-scope — bảng hệ thống | Out-of-scope — ghi vào `pending_design.csv` |

---

## 3. Sơ đồ phụ thuộc Tier (Dependency Map)

```
T1:  Inspection Annual Plan ──────────────────────────────────┐
T1:  Inspection Officer ──────────────────────┐               │
T1:  Complaint Petition                       │               │
T1:  Surveillance Enforcement Case            │               │
T1:  AML Enforcement Case                     │               │
T1:  Inspection Subject Organization          │               │
T1:  Inspection Subject Other Party           │               │
T1:  Anti-Corruption Report (standalone)      │               │
                                              ↓               ↓
T2:  Inspection Decision ───────────────────────── (FK → T1: Annual Plan, nullable)
T2:  Inspection Annual Plan Subject (FK → T1)
T2:  Inspection Annual Plan Document Attachment (FK → T1)
T2:  Complaint Processing Case (FK → T1: Complaint Petition)
T2:  Surveillance Case Document Attachment (FK → T1)
T2:  Surveillance Enforcement Decision (FK → T1)
T2:  AML Case Document Attachment (FK → T1)
T2:  AML Enforcement Decision (FK → T1)
                              ↓
T3:  Inspection Case (FK → T2: Decision)
T3:  Inspection Decision Subject (FK → T2)
T3:  Inspection Decision Team Member (FK → T2 + T1: Officer)
T3:  Inspection Decision Document Attachment (FK → T2)
T3:  Complaint Processing Case Document Attachment (FK → T2)
T3:  Complaint Processing Conclusion (FK → T2)
T3:  Complaint Enforcement Decision (FK → T2)
T3:  Surveillance Enforcement Decision File Attachment (FK → T2)
T3:  Surveillance Penalty Announcement (FK → T2)
                              ↓
T4:  Inspection Case Officer Assignment (FK → T3 + T1: Officer)
T4:  Inspection Case Document Attachment (FK → T3)
T4:  Inspection Case Conclusion (FK → T3)
T4:  Complaint Penalty Announcement (FK → T3)
                              ↓
T5:  Inspection Penalty Announcement (FK → T4: Conclusion)
```

---

## 4. Luồng nghiệp vụ → Entity mapping

### Luồng TT (Thanh tra / Kiểm tra)
```
TT_KE_HOACH → TT_KE_HOACH_DOI_TUONG (danh sách đối tượng trong kế hoạch)
             → TT_KE_HOACH_VAN_BAN   (văn bản kèm kế hoạch)
             → TT_QUYET_DINH         (quyết định thanh tra cụ thể)
                → TT_QUYET_DINH_DOI_TUONG   (đối tượng trong quyết định)
                → TT_QUYET_DINH_THANH_PHAN  (đoàn thanh tra)
                → TT_QUYET_DINH_VAN_BAN     (văn bản kèm quyết định)
                → TT_HO_SO                  (hồ sơ thanh tra)
                   → TT_HO_SO_CAN_BO        (phân công cán bộ)
                   → TT_HO_SO_VAN_BAN       (văn bản đính kèm)
                   → TT_KET_LUAN            (kết luận thanh tra)
                      → TT_CONG_BO_XU_PHAT  (công bố xử phạt)
```

### Luồng GS (Giám sát)
```
GS_HO_SO → GS_HO_SO_VAN_BAN     (văn bản đính kèm hồ sơ)
          → GS_VAN_BAN_XU_LY    (văn bản xử lý vi phạm)
             → GS_VAN_BAN_XU_LY_FILE  (file đính kèm)
             → GS_CONG_BO_XU_PHAT     (công bố xử phạt)
```

### Luồng DT (Đơn thư)
```
DT_DON_THU → DT_HO_SO           (hồ sơ giải quyết)
               → DT_HO_SO_VAN_BAN    (văn bản đính kèm)
               → DT_KET_LUAN         (kết luận giải quyết)
               → DT_VAN_BAN_XU_LY   (văn bản xử lý)
                  → DT_CONG_BO_XU_PHAT   (công bố xử phạt)
```

### Luồng PCRT (Phòng chống rửa tiền)
```
PCRT_HO_SO → PCRT_HO_SO_VAN_BAN  (văn bản đính kèm)
            → PCRT_VAN_BAN_XU_LY  (văn bản xử lý)
PCRT_BAO_CAO                      (báo cáo định kỳ — pending xác nhận tier)
```

### Luồng PCTN (Phòng chống tham nhũng)
```
PCTN_BAO_CAO  (báo cáo định kỳ độc lập — T1 Fact Append)
```

---

## 5. Trạng thái Open Questions

| # | Câu hỏi | Trạng thái | Quyết định |
|---|---|---|---|
| OQ-1 | DM_CONG_TY_* trùng với Securities Company / Fund Management Company? | ✅ Resolved | Trùng. DM_CONG_TY_CK → reuse Securities Company; DM_CONG_TY_QLQ → reuse Fund Management Company; DM_CONG_TY_DC → tạo Public Company mới |
| OQ-2 | DM_CAN_BO vs. Regulatory Authority Organization Unit | ✅ Resolved | Khác nhau. Giữ Inspection Officer (Individual) riêng cho ThanhTra |
| OQ-3 | GS/DT/PCRT có cross-FK vào TT_ không? | ✅ Resolved | Không. Ba luồng hoàn toàn độc lập |
| OQ-4 | TT_QUYET_DINH.LANH_DAO_KY FK đến DM_CAN_BO hay SYS_NGUOI_DUNG? | ✅ Resolved | Trường không tồn tại trong bảng nguồn — không cần thiết kế attr |
| OQ-5 | DT_VAN_BAN_XU_LY FK đến DT_HO_SO hay DT_KET_LUAN? | ✅ Resolved | FK → DT_HO_SO. Thiết kế Tier 3 đã đúng (`Complaint Enforcement Decision` FK → `Complaint Processing Case`) |
| OQ-6 | PCRT_BAO_CAO — độc lập (T1) hay FK? | ✅ Resolved | Độc lập. T1 Fact Append — entity `AML Periodic Report` |
| OQ-7 | TT_KET_LUAN: 1:1 hay 1:N với TT_HO_SO? | ✅ Resolved | 1:N — 1 hồ sơ có thể có nhiều kết luận (revisions). Thêm `conclusion_sequence_number` vào `Inspection Case Conclusion` |
| OQ-8 | TT_KE_HOACH_DOI_TUONG có trường DOI_TUONG_ID không? | ✅ Resolved | Không có. Thông tin đối tượng trong kế hoạch là denormalized hoàn toàn (tên, loại) — không FK đến Securities Company/Public Company |
| OQ-9 | GS/PCRT_VAN_BAN_XU_LY là loại văn bản gì? | ✅ Resolved | Quyết định xử phạt. BCV `Conduct Violation` và tên entity hiện tại đã đúng |

---

## 6. Files thiết kế liên quan

| File | Nội dung |
|---|---|
| [ThanhTra_HLD_Tier1.md](ThanhTra_HLD_Tier1.md) | 8 entities T1 + 14 CV schemes + 2 Geographic Area shared |
| [ThanhTra_HLD_Tier2.md](ThanhTra_HLD_Tier2.md) | 9 entities T2 (incl. Inspection Decision) |
| [ThanhTra_HLD_Tier3.md](ThanhTra_HLD_Tier3.md) | 9 entities T3 (incl. Inspection Case) |
| [ThanhTra_HLD_Tier4.md](ThanhTra_HLD_Tier4.md) | 4 entities T4 + 1 entity T5 |
