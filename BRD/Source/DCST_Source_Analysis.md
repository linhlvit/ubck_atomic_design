# DCST — Tài liệu khảo sát nguồn và ánh xạ Silver

**Phân hệ:** Quản lý dữ liệu trao đổi giữa UBCKNN và Đơn vị trong ngành tài chính (DCST)  
**Mục đích:** Tài liệu tham chiếu cho thiết kế Silver layer — tổng hợp nghiệp vụ nguồn, quan hệ bảng, và ánh xạ Silver entity theo từng nhóm chức năng.  
**Nguồn tài liệu:**
- Thiết kế CSDL: `New_UBCKNN_Thiet_ke_co_so_du_lieu_DCST_19_03_2026.docx`
- HLD Overview: `DCST_HLD_Overview.md`

> **Lưu ý:** Phân hệ DCST không có tài liệu đặc tả yêu cầu riêng. Các nhóm chức năng (DCST-XX) được phân loại dựa trên cấu trúc nhóm dữ liệu trong thiết kế CSDL và phân tích nghiệp vụ.

---

## Bảng quy ước

| Ký hiệu | Ý nghĩa |
|----------|---------|
| 🟢 Tên entity | Silver entity được thiết kế |
| 🟢 `CV: CODE` | Classification Value (danh mục mã hóa) |
| 🟢 ↳ denormalize vào *Entity* | Junction table flatten vào entity chính |
| 🔴 (Out of scope) *lý do* | Ngoài scope Silver |

---

## Mục lục

- [DCST-01. Quản lý thông tin đăng ký thuế](#dcst-01-quản-lý-thông-tin-đăng-ký-thuế)
- [DCST-02. Báo cáo tài chính từ Tổng cục Thuế](#dcst-02-báo-cáo-tài-chính-từ-tổng-cục-thuế)
- [DCST-03. Cưỡng chế nợ thuế](#dcst-03-cưỡng-chế-nợ-thuế)
- [DCST-04. Xử lý vi phạm pháp luật về thuế](#dcst-04-xử-lý-vi-phạm-pháp-luật-về-thuế)
- [DCST-05. Giám sát doanh nghiệp rủi ro cao](#dcst-05-giám-sát-doanh-nghiệp-rủi-ro-cao)
- [DCST-SYS. Quản trị hệ thống & truyền nhận](#dcst-sys-quản-trị-hệ-thống--truyền-nhận)
- [DCST-OUT. Dữ liệu UBCKNN gửi đi (ngoài scope)](#dcst-out-dữ-liệu-ubcknn-gửi-đi-ngoài-scope)
- [Phụ lục: Danh mục dùng chung](#phụ-lục-danh-mục-dùng-chung)

---

## DCST-01. Quản lý thông tin đăng ký thuế

Nhận và lưu trữ thông tin đăng ký thuế của tổ chức/doanh nghiệp từ Tổng cục Thuế, bao gồm thông tin doanh nghiệp, trạng thái hoạt động, và thông tin người đại diện theo pháp luật. Đây là dữ liệu nền tảng, được các nhóm chức năng khác tham chiếu qua mã số thuế.

### DCST-01.1. Thông tin đăng ký thuế

**Nghiệp vụ:** Lưu thông tin đăng ký thuế của người nộp thuế (tổ chức/doanh nghiệp/hộ kinh doanh) do Tổng cục Thuế cung cấp. Bao gồm thông tin định danh, địa chỉ trụ sở, thông tin kinh doanh, trạng thái hoạt động, và thông tin người đại diện. Dữ liệu nhận về qua gói tin truyền nhận.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|------|---------|---------------|
| `THONG_TIN_DK_THUE` | Bảng lưu thông tin đăng ký thuế được lấy từ Cục Thuế | 🟢 Registered Taxpayer |
| ├── `TTKDT_NGUOI_DAI_DIEN` | Bảng lưu các thông tin người đại diện của tổ chức/ doanh nghiệp nộp thuế | 🟢 Taxpayer Representative |
| └── `GOI_TIN` | Lưu các thông tin về dữ liệu gói tin truyền nhận giữa UBCKNN và Cục Thuế | 🔴 (Out of scope) *System operational table* |
| *Shared entities:* | | |
| ├── IP Postal Address | Địa chỉ trụ sở chính (HEAD_OFFICE), địa chỉ kinh doanh (BUSINESS) | 🟢 IP Postal Address *(shared — bổ sung source)* |
| ├── IP Electronic Address | Điện thoại, fax, email của NNT và người đại diện | 🟢 IP Electronic Address *(shared — bổ sung source)* |
| └── IP Alt Identification | GPKD/QĐ thành lập (tổ chức), CMND/CCCD/Hộ chiếu (người đại diện) | 🟢 IP Alt Identification *(shared — bổ sung source)* |
| *Danh mục tham chiếu:* | | |
| ├── TRANG_THAI_HOAT_DONG | Trạng thái hoạt động của NNT | 🟢 `CV: TAXPAYER_ACTIVITY_STATUS` |
| └── LOAI_NGUNG_HOAT_DONG | Loại ngừng hoạt động | 🟢 `CV: TAXPAYER_CESSATION_TYPE` |

---

## DCST-02. Báo cáo tài chính từ Tổng cục Thuế

Nhận và lưu trữ báo cáo tài chính (tờ khai thuế) của doanh nghiệp do Tổng cục Thuế cung cấp cho UBCKNN, bao gồm thông tin header báo cáo và từng chỉ tiêu chi tiết.

### DCST-02.1. Tiếp nhận báo cáo tài chính

**Nghiệp vụ:** Lưu các tờ khai / báo cáo tài chính mà doanh nghiệp nộp lên cơ quan thuế. Mỗi bản ghi là một tờ khai với thông tin: loại tờ khai, kỳ kê khai, thông tin kiểm toán, người ký. Chi tiết từng chỉ tiêu tài chính (doanh thu, lợi nhuận, tài sản...) được lưu ở bảng con.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|------|---------|---------------|
| `TCT_BAO_CAO` | Bảng lưu các báo cáo tài chỉnh lấy từ Cục Thuế | 🟢 Tax Financial Statement |
| ├── `TCT_BAO_CAO_CHI_TIET` | Bảng lưu các thông tin chi tiết của báo cáo tài chỉnh lấy từ Cục Thuế | 🟢 Tax Financial Statement Item |
| └── `GOI_TIN` | *(xem DCST-01.1)* | 🔴 (Out of scope) *System operational table* |
| *Danh mục tham chiếu:* | | |
| ├── LOAI_TKHAI | Loại tờ khai thuế | 🟢 `CV: TAX_RETURN_TYPE` |
| ├── KIEU_KY | Kiểu kỳ báo cáo | 🟢 `CV: REPORTING_PERIOD_TYPE` |
| └── TRANG_THAI_KT | Trạng thái kiểm toán BCTC | 🟢 `CV: AUDIT_STATUS` |

---

## DCST-03. Cưỡng chế nợ thuế

Nhận và lưu trữ thông tin cưỡng chế nợ thuế từ Tổng cục Thuế. Quy trình cưỡng chế gồm 5 biện pháp leo thang (trích TK → khấu trừ → ngừng hóa đơn → kê biên tài sản → thu hồi GPKD). Dữ liệu chia thành: quyết định cưỡng chế (mọi hình thức), và chi tiết riêng cho biện pháp ngừng sử dụng hóa đơn.

### DCST-03.1. Quyết định cưỡng chế nợ

**Nghiệp vụ:** Lưu thông tin quyết định cưỡng chế nợ thuế cho mọi hình thức (trích tài khoản, khấu trừ, kê biên tài sản, thu hồi GPKD, ngừng hóa đơn). Mỗi bản ghi là một quyết định cưỡng chế đối với một người nộp thuế, bao gồm: đối tượng bị cưỡng chế, hình thức, số tiền, tài khoản/tài sản liên quan, hiệu lực.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|------|---------|---------------|
| `TCT_TT_CUONG_CHE_NO` | Bảng lưu các thông tin cưỡng chế nợ lấy từ Cục Thuế | 🟢 Tax Debt Enforcement Order |
| └── `GOI_TIN` | *(xem DCST-01.1)* | 🔴 (Out of scope) *System operational table* |
| *Danh mục tham chiếu:* | | |
| └── MA_HTCC | Mã hình thức cưỡng chế | 🟢 `CV: TAX_ENFORCEMENT_TYPE` |

### DCST-03.2. Cưỡng chế qua ngừng sử dụng hóa đơn

**Nghiệp vụ:** Lưu thông tin chi tiết cho biện pháp cưỡng chế ngừng sử dụng hóa đơn — biện pháp leo thang bước 3. Mỗi bản ghi là một quyết định ngừng hóa đơn, bao gồm: đối tượng bị cưỡng chế, quyết định, thông báo kèm theo, căn cứ pháp lý (viện dẫn QĐ cưỡng chế trước). Danh sách từng hóa đơn cụ thể bị ngừng lưu ở bảng con.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|------|---------|---------------|
| `TCT_TTCCN_HOA_DON` | Bảng lưu các thông tin cưỡng chế nợ thông qua hóa đơn | 🟢 Tax Invoice Enforcement Order |
| ├── `HOA_DON_CHI_TIET` | Bảng lưu các thông tin cấu hình hóa đơn | 🟢 Tax Invoice Enforcement Order Item |
| ├── `TCT_TT_CUONG_CHE_NO` | *(liên kết logic qua CAN_CU_QDSO — xem DCST-03.1)* | 🟢 Tax Debt Enforcement Order |
| └── `GOI_TIN` | *(xem DCST-01.1)* | 🔴 (Out of scope) *System operational table* |
| *Danh mục tham chiếu:* | | |
| ├── MA_HTCC | Mã hình thức cưỡng chế | 🟢 `CV: TAX_ENFORCEMENT_TYPE` |
| └── LOAI_HOA_DON | Loại hóa đơn | 🟢 `CV: INVOICE_TYPE` |

---

## DCST-04. Xử lý vi phạm pháp luật về thuế

Nhận và lưu trữ thông tin quyết định xử lý vi phạm pháp luật về thuế từ Tổng cục Thuế.

### DCST-04.1. Quyết định xử lý vi phạm

**Nghiệp vụ:** Lưu kết quả xử lý vi phạm sau thanh tra/kiểm tra thuế, bao gồm: đối tượng vi phạm, kỳ thanh tra, hành vi vi phạm, hình thức phạt (hành chính, truy thu thuế), cơ quan ban hành.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|------|---------|---------------|
| `TT_XLY_VI_PHAM` | Bảng lưu các thông tin xử lý vi phạm pháp luật về thuế | 🟢 Tax Violation Penalty Decision |
| └── `GOI_TIN` | *(xem DCST-01.1)* | 🔴 (Out of scope) *System operational table* |

---

## DCST-05. Giám sát doanh nghiệp rủi ro cao

Nhận và lưu trữ danh sách doanh nghiệp được Tổng cục Thuế đánh giá rủi ro cao theo từng năm.

### DCST-05.1. Doanh nghiệp rủi ro cao

**Nghiệp vụ:** Lưu danh sách doanh nghiệp rủi ro cao do Tổng cục Thuế đánh giá hằng năm, phục vụ công tác giám sát của UBCKNN. Mỗi bản ghi gồm: mã số doanh nghiệp, tên, địa chỉ, cơ quan thuế quản lý, năm đánh giá rủi ro.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|------|---------|---------------|
| `DN_RUI_RO_CAO` | Lưu các thông tin về Doanh nghiệp rủi ro cao được lấy về từ Cục Thuế | 🟢 High Risk Taxpayer Assessment Snapshot |
| └── `GOI_TIN` | *(xem DCST-01.1)* | 🔴 (Out of scope) *System operational table* |

---

## DCST-SYS. Quản trị hệ thống & truyền nhận

Các bảng phục vụ quản trị ứng dụng DCST và quản lý gói tin truyền nhận. Không chứa dữ liệu nghiệp vụ.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|------|---------|---------------|
| `GOI_TIN` | Lưu các thông tin về dữ liệu gói tin truyền nhận giữa UBCKNN và Cục Thuế | 🔴 (Out of scope) *System operational table* |
| `CAU_HINH_GOI_TIN` | Lưu các thông tin về cấu hình gói tin trao đổi giữa UBCKNN và Cục Thuế | 🔴 (Out of scope) *System operational table* |
| `THIET_LAP_LICH` | Bảng lưu cấu hình lịch truyền/ nhận dữ liệu giữa UBCKNN và Cục Thuế | 🔴 (Out of scope) *System operational table* |
| `HT_THAM_SO` | Lưu các thông tin về tham số hệ thống | 🔴 (Out of scope) *System operational table* |
| `NHAT_KY_HE_THONG` | Lưu các thông tin về nhật ký hệ thống, các thao tác của người dùng trên hệ thống | 🔴 (Out of scope) *Audit log nguồn* |
| `DB_LOG` | Bảng lưu log truy vấn trên database | 🔴 (Out of scope) *Audit log nguồn* |
| `NGUOIDUNG` | Lưu các thông tin về người dùng hệ thống | 🔴 (Out of scope) *Operational/system data* |
| `NHOMNGUOIDUNG` | Lưu các thông tin về nhóm người dùng trên hệ thống | 🔴 (Out of scope) *Operational/system data* |
| `NGUOIDUNG_NHOMNGUOIDUNG` | Bảng mapping giữa người dùng và nhóm người dùng | 🔴 (Out of scope) *Operational/system data* |
| `CHUCNANG` | Lưu các thông tin danh sách các menu hệ thống | 🔴 (Out of scope) *UI metadata* |
| `NHOMNGUOIDUNG_CHUCNANG` | Bảng mapping giữa nhóm người dùng và chức năng hệ thống | 🔴 (Out of scope) *Operational/system data* |
| `DM_CHUCVU` | Lưu các thông tin về danh mục chức vụ | 🔴 (Out of scope) *Operational/system data* |
| `DM_DON_VI` | Lưu các thông tin về danh mục đơn vị | 🔴 (Out of scope) *Operational/system data* |

---

## DCST-OUT. Dữ liệu UBCKNN gửi đi (ngoài scope)

Các bảng thuộc chiều UBCKNN → TCT, chứa dữ liệu phái sinh từ các hệ thống nguồn gốc khác. Ngoài scope thiết kế — thu thập tại nguồn gốc.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|------|---------|---------------|
| `THONG_TIN_CONG_TY` | Bảng lưu thông tin công ty bao gồm thông tin công ty đại chúng, công ty chứng khoán, công ty quản lý quỹ | 🔴 (Out of scope) *Dữ liệu phát sinh từ nguồn gốc khác (SCMS/FMS/IDS)* |
| `UBCK_XU_PHAT` | Bảng lưu các thông tin về xử phạt tại UBCKNN | 🔴 (Out of scope) *Dữ liệu phát sinh từ nguồn gốc khác (HT Thanh tra)* |
| `CONG_TY_KIEM_TOAN` | Lưu các thông tin về công ty kiểm toán | 🔴 (Out of scope) *Thu thập tại source gốc* |
| `KIEM_TOAN_VIEN` | Lưu các thông tin về Kiểm toán viên | 🔴 (Out of scope) *Thu thập tại source gốc* |
| `UBCK_BAO_CAO` | Bảng lưu các báo cáo tài chính lấy từ các hệ thống của UBCKNN | 🔴 (Out of scope) *Dữ liệu phát sinh từ nguồn gốc khác (FMS/IDS)* |
| `UBCK_BAO_CAO_CHI_TIET` | Bảng lưu các thông tin chi tiết của báo cáo tài chỉnh lấy từ các hệ thống tại UBCKNN | 🔴 (Out of scope) *Dữ liệu phát sinh từ nguồn gốc khác (FMS/IDS)* |

---

## Phụ lục: Danh mục dùng chung

| Bảng | Ý nghĩa | Sử dụng bởi | Ánh xạ Silver |
|------|---------|-------------|---------------|
| `DANH_MUC` | Bảng lưu các thông tin cấu hình danh mục | Tham chiếu xuyên suốt các bảng nghiệp vụ | 🟢 `CV: Classification Value` |
| `NHOM_DANH_MUC` | Bảng lưu các thông tin cấu hình nhóm danh mục | Phân nhóm danh mục (scheme) | 🟢 `CV: Classification Value` (scheme) |

---

## Verify

**Tổng số bảng trong master list:** 30

**Đếm bảng trong file (backtick-quoted):**

- DCST-01: `THONG_TIN_DK_THUE`, `TTKDT_NGUOI_DAI_DIEN`, `GOI_TIN` → 3 (GOI_TIN xuất hiện ở nhiều section)
- DCST-02: `TCT_BAO_CAO`, `TCT_BAO_CAO_CHI_TIET` → 2
- DCST-03: `TCT_TT_CUONG_CHE_NO`, `TCT_TTCCN_HOA_DON`, `HOA_DON_CHI_TIET` → 3
- DCST-04: `TT_XLY_VI_PHAM` → 1
- DCST-05: `DN_RUI_RO_CAO` → 1
- DCST-SYS: `GOI_TIN`, `CAU_HINH_GOI_TIN`, `THIET_LAP_LICH`, `HT_THAM_SO`, `NHAT_KY_HE_THONG`, `DB_LOG`, `NGUOIDUNG`, `NHOMNGUOIDUNG`, `NGUOIDUNG_NHOMNGUOIDUNG`, `CHUCNANG`, `NHOMNGUOIDUNG_CHUCNANG`, `DM_CHUCVU`, `DM_DON_VI` → 13
- DCST-OUT: `THONG_TIN_CONG_TY`, `UBCK_XU_PHAT`, `CONG_TY_KIEM_TOAN`, `KIEM_TOAN_VIEN`, `UBCK_BAO_CAO`, `UBCK_BAO_CAO_CHI_TIET` → 6
- Phụ lục: `DANH_MUC`, `NHOM_DANH_MUC` → 2

**Tổng unique:** 10 (Group A) + 13 (SYS) + 6 (OUT) + 2 (Phụ lục) – 1 (GOI_TIN trùng) = **30** ✅
