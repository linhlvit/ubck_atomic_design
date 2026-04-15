# SCMS — Khảo sát nguồn: Quản lý giám sát Công ty chứng khoán

> **Phân hệ:** SCMS — Securities Company Management System
> **Mục đích:** Tài liệu tham chiếu cho thiết kế Silver layer — hiểu nghiệp vụ nguồn, cấu trúc bảng, quan hệ dữ liệu, và ánh xạ Silver entity.
> **Nguồn:** Đặc tả yêu cầu SCMS (11/03/2026) + Thiết kế CSDL SCMS (19/03/2026) + HLD Overview SCMS

### Quy ước cột Ánh xạ Silver

| Ký hiệu | Ý nghĩa |
|---|---|
| 🟢 Tên entity | Silver entity được thiết kế (xem HLD 7a) |
| 🟢 `CV: CODE` | Classification Value — danh mục mã hóa (xem HLD 7c) |
| 🟢 ↳ denormalize vào *Entity* | Junction table — flatten vào entity chính (xem HLD 7d) |
| 🔴 (Out of scope) *lý do* | Ngoài scope Silver (xem HLD 7f) |

---

## Mục lục

- [1. SCMS_UID01 — Quản lý CTCK](#1-scms_uid01--quản-lý-ctck)
- [2. SCMS_UID02 — Quản lý CN CTCK nước ngoài tại VN](#2-scms_uid02--quản-lý-cn-ctck-nước-ngoài-tại-vn)
- [3. SCMS_UID03 — Quản lý VPDD CTCK nước ngoài tại VN](#3-scms_uid03--quản-lý-vpdd-ctck-nước-ngoài-tại-vn)
- [4. SCMS_UID04 — Quản lý ngân hàng thanh toán, lưu ký](#4-scms_uid04--quản-lý-ngân-hàng-thanh-toán-lưu-ký)
- [5. SCMS_UID05 — Khai thác công ty kiểm toán và kiểm toán viên](#5-scms_uid05--khai-thác-công-ty-kiểm-toán-và-kiểm-toán-viên)
- [6. SCMS_UID06 — Cảnh báo vi phạm](#6-scms_uid06--cảnh-báo-vi-phạm)
- [7. SCMS_UID07 — Tiện ích và trợ giúp](#7-scms_uid07--tiện-ích-và-trợ-giúp)
- [8. SCMS_UID08 — Quản trị phân hệ](#8-scms_uid08--quản-trị-phân-hệ)
- [Phụ lục: Danh mục dùng chung](#phụ-lục-danh-mục-dùng-chung)

---

## 1. SCMS_UID01 — Quản lý CTCK

**Nghiệp vụ tổng quan:** Quản lý toàn bộ vòng đời hồ sơ Công ty chứng khoán trong nước — từ cấp phép, cập nhật thông tin, quản lý nhân sự/cổ đông, đến tiếp nhận báo cáo, công bố thông tin và khai thác báo cáo đầu ra phục vụ giám sát.

### 1.1 Quản lý hồ sơ CTCK trong nước

**Nghiệp vụ:** Quản lý thông tin pháp lý, tổ chức và hoạt động của CTCK cùng các đơn vị trực thuộc (chi nhánh, VPĐD, PGD). Hồ sơ được cập nhật từ 3 nguồn: phân hệ TTHC (khi UBCKNN cấp phép điều chỉnh), cổng báo cáo trực tuyến (CTCK tự cập nhật), hoặc cán bộ Ban QLKD nhập thủ công. Mọi thay đổi đều lưu lịch sử và đồng bộ sang trang CBTT.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `CTCK_THONG_TIN` | Bảng master — thông tin CTCK | 🟢 Securities Company |
| ├── `CTCK_CHI_NHANH` | Chi nhánh CTCK trong nước | 🟢 Securities Company Organization Unit |
| ├── `CTCK_VP_DAI_DIEN` | Văn phòng đại diện trong nước | 🟢 Securities Company Organization Unit |
| ├── `CTCK_PHONG_GIAO_DICH` | Phòng giao dịch | 🟢 Securities Company Organization Unit |
| ├── `CTCK_DICH_VU` | Dịch vụ đăng ký của CTCK | 🟢 ↳ denormalize vào *Securities Company* |
| ├── `LK_CTCK_NGANH_NGHE_KD` | Liên kết CTCK — ngành nghề KD (junction) | 🟢 ↳ denormalize vào *Securities Company* |
| ├── `CTCK_HS_LICH_SU` | Lịch sử thay đổi hồ sơ | 🔴 (Out of scope) *Audit Log nguồn — ghi lịch sử dạng generic* |
| ├── `CTCK_LICH_SU_XOA` | Lịch sử xóa hồ sơ | 🔴 (Out of scope) *Audit Log nguồn — cơ chế đặc thù source system* |
| └── `CTCK_XU_LY_HANH_CHINH` | Quyết định xử phạt vi phạm | 🟢 Securities Company Administrative Penalty |
| *Danh mục tham chiếu:* | DM_TINH_THANH, DM_LOAI_CONG_TY, DM_QUOC_TICH, DM_DICH_VU, DM_NGANH_NGHE_KD, DM_TRANG_THAI_CTCK | *(xem Phụ lục)* |

### 1.2 Quản lý NHN, người nội bộ, cổ đông

**Nghiệp vụ:** Quản lý thông tin người hành nghề chứng khoán đăng ký tại CTCK, nhân sự cao cấp (người nội bộ: Chủ tịch HĐQT, TGĐ, Kế toán trưởng...), cổ đông lớn/chủ sở hữu, và mối quan hệ/giao dịch chuyển nhượng giữa các cổ đông. Nguồn dữ liệu NHN CK từ cổng báo cáo trực tuyến (CTCK kê khai) và đối chiếu hệ thống NHNCK.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `CTCK_THONG_TIN` | *(master — xem 1.1)* | 🟢 Securities Company |
| ├── `CTCK_NGUOI_HANH_NGHE_CK` | Người hành nghề CK tại CTCK | 🟢 Securities Practitioner *(shared — bổ sung source)* |
| ├── `CTCK_NHAN_SU_CAO_CAP` | Nhân sự cao cấp (người nội bộ) | 🟢 Securities Company Senior Personnel |
| └── `CTCK_CO_DONG` | Cổ đông lớn / chủ sở hữu | 🟢 Securities Company Shareholder |
| ⠀⠀├── `CTCK_CD_CHUYEN_NHUONG` | Giao dịch chuyển nhượng cổ đông | 🟢 Securities Company Shareholder Transfer |
| ⠀⠀├── `CTCK_CD_DAI_DIEN` | Người đại diện được ủy quyền bởi cổ đông | 🟢 Securities Company Shareholder Representative |
| ⠀⠀└── `CTCK_CD_MOI_QUAN_HE` | Mối quan hệ của cổ đông | 🟢 Securities Company Shareholder Related Party |
| *Danh mục tham chiếu:* | DM_CHUC_VU, DM_QUOC_TICH, DM_MOI_QUAN_HE, DM_LOAI_GIAO_DICH_CD | *(xem Phụ lục)* |

### 1.3 Khai thác báo cáo đầu vào CTCK

**Nghiệp vụ:** Tiếp nhận và quản lý báo cáo mà CTCK gửi lên UBCKNN qua cổng báo cáo trực tuyến — bao gồm báo cáo định kỳ (BCTC, ATTTC, hoạt động...), bất thường và theo yêu cầu. Chuyên viên Ban QLKD rà soát, yêu cầu gửi lại nếu sai sót. Hệ thống theo dõi tình hình vi phạm nghĩa vụ nộp báo cáo.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `BC_THANH_VIEN` | Bản ghi báo cáo đơn vị đã gửi theo kỳ | 🟢 Member Periodic Report *(shared — bổ sung source)* |
| ├── `BC_THANH_VIEN_LS` | Lịch sử thay đổi trạng thái báo cáo | 🔴 (Out of scope) *Audit Log nguồn — snapshot từng phiên bản gửi* |
| ├── `BC_THANH_VIEN_XU_LY` | Tiếp nhận / xử lý báo cáo bởi chuyên viên | 🔴 (Out of scope) *Operational — workflow xử lý nội bộ hệ thống* |
| └── `BC_BAO_CAO_GT` | Giá trị từng chỉ tiêu trong báo cáo (cell-level) | 🟢 Member Report Indicator Value |
| `BC_GT_HDR` | Dữ liệu báo cáo nháp — header | 🔴 (Out of scope) *Draft data — dữ liệu trạng thái trung gian* |
| └── `BC_GT_DTL` | Dữ liệu báo cáo nháp — detail (giá trị cell) | 🔴 (Out of scope) *Draft data — phụ thuộc BC_GT_HDR* |
| `BC_VI_PHAM` | Tình hình vi phạm nộp báo cáo của đơn vị | 🟢 Securities Company Report Violation |
| └── `BC_VI_PHAM_LOAI_VP` | Chi tiết loại vi phạm báo cáo | 🟢 ↳ denormalize vào *Securities Company Report Violation* |

### 1.4 Khai thác thông tin công bố CTCK

**Nghiệp vụ:** Quản lý thông tin công bố của CTCK trên trang CBTT của UBCKNN — bao gồm CBTT định kỳ (từ BCTC), CBTT bất thường/theo yêu cầu, thông tin chào bán phát hành chứng khoán, và công bố giao dịch cổ đông lớn/cổ đông nội bộ/người liên quan. Tin CBTT được tự động sinh khi CTCK gửi báo cáo hoặc do người đại diện CBTT nhập trực tiếp.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `CBTT_BAO_CAO` | Tin công bố thông tin của CTCK | 🟢 Disclosure Report Submission |
| `CBTT_CHAO_BAN_CHUNG_KHOAN` | Thông tin chào bán CK được công bố | 🟢 Disclosure Securities Offering |
| `CBTT_CO_DONG` | Thông tin cổ đông được công bố | 🟢 Disclosure Shareholder Change |

### 1.5 Khai thác báo cáo đầu ra CTCK

**Nghiệp vụ:** Chuyên viên/Lãnh đạo Ban QLKD khai thác báo cáo tổng hợp phục vụ giám sát — chọn mẫu báo cáo, nhập tiêu chí lọc, hệ thống thống kê và xuất kết quả. Bao gồm cả báo cáo chưa xác định trước biểu mẫu (truy vấn tự do) và báo cáo đã xác định trước biểu mẫu.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `BC_KHAI_THAC` | Phiên khai thác báo cáo tổng hợp | 🔴 (Out of scope) *Gold/intermediate — dữ liệu pre-aggregated nội bộ* |
| └── `BC_KHAI_THAC_GT` | Giá trị dữ liệu khai thác tổng hợp | 🔴 (Out of scope) *Gold/intermediate — phụ thuộc BC_KHAI_THAC* |
| *Danh mục tham chiếu:* | DM_CHI_TIEU_THONG_KE, DM_THONG_KE | *(xem Phụ lục)* |

### 1.6 Báo cáo thẩm định TTHC

**Nghiệp vụ:** Khai thác dữ liệu báo cáo phục vụ thẩm định hồ sơ thủ tục hành chính — truy vấn theo đối tượng CTCK để lấy tình hình báo cáo, vi phạm, và các chỉ tiêu tài chính phục vụ đánh giá.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `BC_KHAI_THAC` | *(xem 1.5)* | 🔴 (Out of scope) *Gold/intermediate* |
| └── `BC_KHAI_THAC_GT` | *(xem 1.5)* | 🔴 (Out of scope) *Gold/intermediate* |

### 1.7 Biểu đồ thống kê

**Nghiệp vụ:** Trực quan hóa dữ liệu giám sát CTCK dưới dạng biểu đồ — thống kê theo các chỉ tiêu đã cấu hình, phục vụ lãnh đạo Ban QLKD nắm bắt nhanh tình hình.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `BC_KHAI_THAC` | *(xem 1.5)* | 🔴 (Out of scope) *Gold/intermediate* |
| *Danh mục tham chiếu:* | DM_CHI_TIEU_THONG_KE, DM_THONG_KE | *(xem Phụ lục)* |

---

## 2. SCMS_UID02 — Quản lý CN CTCK nước ngoài tại VN

**Nghiệp vụ tổng quan:** Quản lý hồ sơ chi nhánh công ty chứng khoán nước ngoài được cấp phép hoạt động tại Việt Nam — bao gồm thông tin pháp lý, nhân sự, người hành nghề, tiếp nhận báo cáo và công bố thông tin. CN CTCK NN là pháp nhân có giấy phép riêng, dùng chung bảng `CTCK_THONG_TIN` phân biệt bằng loại công ty.

### 2.1 Quản lý hồ sơ CN CTCK NN

**Nghiệp vụ:** Khai báo và cập nhật hồ sơ CN CTCK NN khi được UBCKNN cấp phép hoạt động tại VN. Hồ sơ bao gồm thông tin CN, công ty mẹ nước ngoài, người đại diện theo pháp luật, vốn và nghiệp vụ kinh doanh.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `CTCK_THONG_TIN` | Hồ sơ CN CTCK NN (phân biệt bằng loại công ty) | 🟢 Securities Company |
| └── `CTCK_HS_LICH_SU` | Lịch sử thay đổi hồ sơ | 🔴 (Out of scope) *Audit Log nguồn* |

### 2.2 Quản lý nhân sự, người hành nghề CN CTCK NN

**Nghiệp vụ:** Quản lý nhân sự cao cấp (Tổng GĐ, Phó TGĐ, Kế toán trưởng) và người hành nghề CK đăng ký làm việc tại CN CTCK NN.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `CTCK_THONG_TIN` | *(master — xem 2.1)* | 🟢 Securities Company |
| ├── `CTCK_NHAN_SU_CAO_CAP` | Nhân sự cao cấp CN CTCK NN | 🟢 Securities Company Senior Personnel |
| └── `CTCK_NGUOI_HANH_NGHE_CK` | Người hành nghề CK tại CN CTCK NN | 🟢 Securities Practitioner *(shared)* |
| *Danh mục tham chiếu:* | DM_CHUC_VU | *(xem Phụ lục)* |

### 2.3 Khai thác báo cáo đầu vào/ra CN CTCK NN

**Nghiệp vụ:** Tiếp nhận báo cáo định kỳ, bất thường, theo yêu cầu của CN CTCK NN và khai thác báo cáo tổng hợp đầu ra — cùng cơ chế với CTCK trong nước.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `BC_THANH_VIEN` | Báo cáo CN CTCK NN đã gửi | 🟢 Member Periodic Report *(shared)* |
| └── `BC_BAO_CAO_GT` | Giá trị chỉ tiêu báo cáo | 🟢 Member Report Indicator Value |
| `BC_KHAI_THAC` | Khai thác báo cáo tổng hợp | 🔴 (Out of scope) *Gold/intermediate* |
| └── `BC_KHAI_THAC_GT` | Giá trị khai thác tổng hợp | 🔴 (Out of scope) *Gold/intermediate* |

### 2.4 Khai thác thông tin công bố CN CTCK NN

**Nghiệp vụ:** Tra cứu tin CBTT định kỳ, bất thường, theo yêu cầu của CN CTCK NN trên trang CBTT.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `CBTT_BAO_CAO` | Tin công bố thông tin CN CTCK NN | 🟢 Disclosure Report Submission |

---

## 3. SCMS_UID03 — Quản lý VPDD CTCK nước ngoài tại VN

**Nghiệp vụ tổng quan:** Quản lý hồ sơ văn phòng đại diện công ty chứng khoán nước ngoài tại VN — pháp nhân độc lập, không FK đến CTCK trong nước. VPDD CTCK NN có phạm vi hoạt động hạn chế hơn CN CTCK NN (không kinh doanh chứng khoán).

### 3.1 Quản lý hồ sơ VPDD CTCK NN

**Nghiệp vụ:** Khai báo và cập nhật hồ sơ VPDD CTCK NN. Thông tin bao gồm tên VPDD, công ty mẹ nước ngoài, trưởng đại diện, địa chỉ và nội dung hoạt động.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `CTCK_VP_DAI_DIEN_NN` | Bảng master — hồ sơ VPDD CTCK NN (pháp nhân độc lập) | 🟢 Foreign Representative Office |
| └── `CTCK_HS_LICH_SU` | Lịch sử thay đổi hồ sơ | 🔴 (Out of scope) *Audit Log nguồn* |
| *Danh mục tham chiếu:* | DM_QUOC_TICH | *(xem Phụ lục)* |

### 3.2 Quản lý nhân sự VPDD CTCK NN

**Nghiệp vụ:** Quản lý nhân sự của VPDD CTCK NN (trưởng đại diện, nhân viên). Phạm vi đơn giản hơn CN CTCK NN — không có người hành nghề CK.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `CTCK_VP_DAI_DIEN_NN` | *(master — xem 3.1)* | 🟢 Foreign Representative Office |
| └── `CTCK_NHAN_SU_CAO_CAP` | Nhân sự VPDD CTCK NN | 🟢 Securities Company Senior Personnel |

### 3.3 Khai thác báo cáo đầu vào/ra VPDD CTCK NN

**Nghiệp vụ:** Tiếp nhận báo cáo định kỳ của VPDD CTCK NN và khai thác báo cáo tổng hợp đầu ra.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `BC_THANH_VIEN` | Báo cáo VPDD đã gửi | 🟢 Member Periodic Report *(shared)* |
| └── `BC_BAO_CAO_GT` | Giá trị chỉ tiêu báo cáo | 🟢 Member Report Indicator Value |
| `BC_KHAI_THAC` | Khai thác báo cáo tổng hợp | 🔴 (Out of scope) *Gold/intermediate* |
| └── `BC_KHAI_THAC_GT` | Giá trị khai thác tổng hợp | 🔴 (Out of scope) *Gold/intermediate* |

---

## 4. SCMS_UID04 — Quản lý ngân hàng thanh toán, lưu ký

**Nghiệp vụ tổng quan:** Quản lý hồ sơ ngân hàng thanh toán và ngân hàng lưu ký được UBCKNN chấp thuận hoạt động. Ngân hàng dùng chung bảng `CTCK_THONG_TIN` phân biệt bằng loại công ty. Tiếp nhận báo cáo định kỳ, bất thường và khai thác báo cáo đầu ra.

### 4.1 Quản lý hồ sơ ngân hàng

**Nghiệp vụ:** Khai báo và cập nhật hồ sơ NHTT/NHLK — thông tin pháp lý, nghiệp vụ được chấp thuận, người đại diện, và lịch sử thay đổi.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `CTCK_THONG_TIN` | Hồ sơ ngân hàng (phân biệt bằng loại công ty) | 🟢 Securities Company |
| └── `CTCK_HS_LICH_SU` | Lịch sử thay đổi hồ sơ | 🔴 (Out of scope) *Audit Log nguồn* |

### 4.2 Khai thác báo cáo đầu vào/ra ngân hàng

**Nghiệp vụ:** Tiếp nhận báo cáo định kỳ, bất thường, theo yêu cầu của NHTT/NHLK. Theo dõi tình hình vi phạm nghĩa vụ nộp báo cáo và khai thác báo cáo tổng hợp đầu ra.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `BC_THANH_VIEN` | Báo cáo ngân hàng đã gửi | 🟢 Member Periodic Report *(shared)* |
| └── `BC_BAO_CAO_GT` | Giá trị chỉ tiêu báo cáo | 🟢 Member Report Indicator Value |
| `BC_VI_PHAM` | Vi phạm nộp báo cáo ngân hàng | 🟢 Securities Company Report Violation |
| `BC_KHAI_THAC` | Khai thác báo cáo tổng hợp | 🔴 (Out of scope) *Gold/intermediate* |
| └── `BC_KHAI_THAC_GT` | Giá trị khai thác tổng hợp | 🔴 (Out of scope) *Gold/intermediate* |

---

## 5. SCMS_UID05 — Khai thác công ty kiểm toán và kiểm toán viên

**Nghiệp vụ tổng quan:** Khai thác thông tin công ty kiểm toán được UBCKNN chấp thuận kiểm toán cho đơn vị có lợi ích công chúng thuộc lĩnh vực chứng khoán, và danh sách kiểm toán viên thuộc các công ty này. Dữ liệu được cập nhật từ phân hệ quản lý kiểm toán.

### 5.1 Khai thác thông tin CT kiểm toán & kiểm toán viên

**Nghiệp vụ:** Tra cứu chi tiết thông tin công ty kiểm toán (tên, giấy phép, trạng thái) và danh sách kiểm toán viên (chứng chỉ, tình trạng hành nghề). Dữ liệu chỉ đọc — không chỉnh sửa từ phân hệ SCMS.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `CT_KIEM_TOAN` | Công ty kiểm toán được chấp thuận | 🟢 Audit Firm |
| └── `CT_KIEM_TOAN_VIEN` | Kiểm toán viên thuộc CT kiểm toán | 🟢 Audit Firm Practitioner |

---

## 6. SCMS_UID06 — Cảnh báo vi phạm

**Nghiệp vụ tổng quan:** Thiết lập tham số và điều kiện cảnh báo để giám sát tình hình hoạt động CTCK theo quy định pháp luật. Hệ thống tự động hoặc thủ công tính toán giá trị tham số từ dữ liệu báo cáo, so sánh với ngưỡng cảnh báo và sinh danh sách vi phạm.

### 6.1 Quản lý tham số & điều kiện cảnh báo

**Nghiệp vụ:** Chuyên viên phụ trách hệ thống thiết lập tham số cảnh báo (chỉ tiêu tài chính, tỷ lệ an toàn vốn...) và điều kiện cảnh báo (ngưỡng, toán tử so sánh) đã được phê duyệt.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `DM_CANH_BAO` | Danh mục tham số cảnh báo | 🟢 `CV: SCMS_REPORT_WARNING_RULE` *(cần xác nhận)* |
| `DM_CHI_TIEU` | Danh mục chỉ tiêu báo cáo | 🟢 Report Indicator |
| └── `DM_CHI_TIEU_DM` | Ánh xạ chỉ tiêu — nhóm danh mục | 🟢 `CV: SCMS_INDICATOR_GROUP` |

### 6.2 Thực hiện & khai thác cảnh báo

**Nghiệp vụ:** Hệ thống tính giá trị tham số từ dữ liệu `BC_BAO_CAO_GT`, so sánh với điều kiện cảnh báo, sinh kết quả vào `BC_CANH_BAO`. Chuyên viên/lãnh đạo xem danh sách cảnh báo theo đối tượng, loại vi phạm và mức độ.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `BC_CANH_BAO` | Kết quả cảnh báo vi phạm | 🔴 (Out of scope) *Chờ thiết kế — kết quả thực tế cần lên Silver (xem HLD 7e #1)* |
| `BC_THANH_VIEN` | *(nguồn dữ liệu tính toán — xem 1.3)* | 🟢 Member Periodic Report *(shared)* |
| └── `BC_BAO_CAO_GT` | *(nguồn dữ liệu tính toán — xem 1.3)* | 🟢 Member Report Indicator Value |

---

## 7. SCMS_UID07 — Tiện ích và trợ giúp

**Nghiệp vụ tổng quan:** Các chức năng hỗ trợ tác nghiệp hàng ngày: trao đổi thông tin giữa UBCKNN và thành viên thị trường, gửi thông báo, nhắc việc (báo cáo quá hạn, thay đổi hồ sơ cần xử lý), và tra cứu log thông báo hệ thống.

### 7.1 Trao đổi thông tin & thông báo

**Nghiệp vụ:** Cán bộ UBCKNN gửi tin trao đổi đến CTCK/ngân hàng/CN CTCK NN qua hệ thống. UBCKNN gửi thông báo chính thức đến thành viên. Tất cả được ghi log hệ thống.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `QT_LOG_HE_THONG` | Log thao tác và thông báo hệ thống | 🔴 (Out of scope) *Operational/system data* |
| `QT_LICH_HE_THONG` | Lịch biểu hệ thống (job tự động) | 🔴 (Out of scope) *Operational/system data* |

### 7.2 Nhắc việc & tra cứu thông báo

**Nghiệp vụ:** Màn hình nhắc việc hiển thị số lượng BC quá hạn, hồ sơ thay đổi cần xử lý, tin CBTT chờ duyệt. Tra cứu lịch sử thông báo hệ thống theo thời gian và loại thông báo.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `QT_LOG_HE_THONG` | *(xem 7.1)* | 🔴 (Out of scope) *Operational/system data* |
| `QT_NGUOI_DUNG` | Người dùng hệ thống (nhận thông báo) | 🔴 (Out of scope) *Operational/system data* |

---

## 8. SCMS_UID08 — Quản trị phân hệ

**Nghiệp vụ tổng quan:** Cấu hình biểu mẫu báo cáo đầu vào/ra, quản lý tham số hệ thống, quản lý danh mục dùng riêng, và phân quyền dữ liệu cho người dùng.

### 8.1 Cấu hình biểu mẫu & tham số

**Nghiệp vụ:** Thiết lập cấu trúc biểu mẫu báo cáo (sheet, hàng, cột, chỉ tiêu), cấu hình định kỳ gửi và đơn vị có nghĩa vụ gửi. Quản lý tham số hệ thống (khuôn dạng ngày, giới hạn file upload...).

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `BM_BAO_CAO` | Danh sách biểu mẫu báo cáo | 🟢 Report Template *(shared — bổ sung source)* |
| ├── `BM_SHEET` | Sheet trong biểu mẫu | 🟢 Report Template Sheet |
| ├── `BM_BAO_CAO_HANG` | Hàng trong biểu mẫu | 🟢 Report Template Row |
| ├── `BM_BAO_CAO_COT` | Cột trong biểu mẫu | 🟢 Report Template Column |
| ├── `BM_BAO_CAO_CT` | Chỉ tiêu trong biểu mẫu (vị trí cụ thể) | 🟢 Report Template Indicator |
| ├── `BM_BAO_CAO_DINH_KY` | Định kỳ gửi báo cáo | 🟢 Report Submission Schedule |
| ├── `BM_BAO_CAO_DINH_KY_DON_VI` | Đơn vị có nghĩa vụ gửi theo định kỳ | 🟢 Report Submission Obligation |
| ├── `BM_BAO_CAO_TV` | Đơn vị có nghĩa vụ gửi theo biểu mẫu | 🟢 ↳ denormalize vào *Report Template* |
| ├── `BM_BAO_CAO_LS` | Lịch sử thay đổi biểu mẫu | 🔴 (Out of scope) *Audit Log nguồn* |
| ├── `BM_TIEUDE_HANG` | Tiêu đề hàng thiết kế động | 🔴 (Out of scope) *UI metadata — cấu hình layout hiển thị* |
| └── `BM_TIEUDE_HANG_COT` | Tiêu đề cột thiết kế động | 🔴 (Out of scope) *UI metadata — cấu hình layout hiển thị* |
| `QT_THAM_SO_HE_THONG` | Tham số cấu hình hệ thống | 🔴 (Out of scope) *Operational/system data* |

### 8.2 Quản lý danh mục dùng riêng

**Nghiệp vụ:** Quản lý các danh mục nghiệp vụ riêng của phân hệ SCMS: sự vụ (nghĩa vụ pháp lý), nghiệp vụ kinh doanh CK (môi giới, tự doanh, bảo lãnh...), dịch vụ CTCK, trạng thái hoạt động, và chức vụ.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `DM_SU_VU` | Danh mục sự vụ — nghĩa vụ pháp lý | 🟢 `CV: SCMS_INCIDENT_TYPE` |
| `DM_NGANH_NGHE_KD` | Danh mục nghiệp vụ kinh doanh CK | 🟢 `CV: SCMS_BUSINESS_SECTOR` |
| `DM_DICH_VU` | Danh mục dịch vụ CTCK | 🟢 `CV: SCMS_SERVICE_TYPE` |
| `DM_TRANG_THAI_CTCK` | Danh mục trạng thái hoạt động | 🟢 `CV: SCMS_COMPANY_STATUS` |
| `DM_CHUC_VU` | Danh mục chức vụ | 🟢 `CV: SCMS_POSITION_TYPE` |

### 8.3 Quản lý phân quyền

**Nghiệp vụ:** Phân quyền truy cập dữ liệu theo 3 chiều: phân quyền báo cáo đầu vào (cán bộ nào xem BC nào), phân quyền báo cáo đầu ra (cán bộ nào khai thác BC nào), và phân quyền dữ liệu (cán bộ nào quản lý CTCK nào). Quản lý người dùng, nhóm người dùng và gán chức năng.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `QT_NGUOI_DUNG` | Người dùng hệ thống | 🔴 (Out of scope) *Operational/system data* |
| ├── `QT_NGUOI_DUNG_IP` | Quản lý IP đăng ký của người dùng | 🔴 (Out of scope) *Operational/system data* |
| ├── `LK_NGUOI_DUNG_NHOM` | Liên kết người dùng — nhóm (junction) | 🔴 (Out of scope) *Operational/system data* |
| ├── `LK_NGUOI_DUNG_BAO_CAO` | Phân quyền khai thác báo cáo | 🔴 (Out of scope) *Operational/system data* |
| └── `LK_NGUOI_DUNG_CTCK` | Phân quyền quản trị CTCK | 🔴 (Out of scope) *Operational/system data* |
| `QT_NHOM_NGUOI_DUNG` | Nhóm người dùng | 🔴 (Out of scope) *Operational/system data* |
| `QT_CHUC_NANG` | Danh mục chức năng hệ thống | 🔴 (Out of scope) *Operational/system data* |
| ├── `LK_CHUC_NANG_NGUOI` | Liên kết chức năng — người dùng (junction) | 🔴 (Out of scope) *Operational/system data* |
| └── `LK_CHUC_NANG_NHOM_NGUOI` | Liên kết chức năng — nhóm (junction) | 🔴 (Out of scope) *Operational/system data* |

---

## Phụ lục: Danh mục dùng chung

Các bảng danh mục (DM_*) được tham chiếu xuyên suốt nhiều nhóm chức năng.

| Bảng | Ý nghĩa | Sử dụng bởi | Ánh xạ Silver |
|---|---|---|---|
| `DM_TINH_THANH` | Danh mục tỉnh thành | UID01, UID02, UID03 | 🟢 Geographic Area *(shared)* |
| `DM_QUOC_TICH` | Danh mục quốc tịch | UID01, UID02, UID03 | 🟢 Geographic Area *(shared)* |
| `DM_LOAI_CONG_TY` | Danh mục loại công ty | UID01, UID04 | 🟢 `CV: SCMS_COMPANY_TYPE` |
| `DM_TRANG_THAI_CTCK` | Danh mục trạng thái CTCK | UID01, UID08 | 🟢 `CV: SCMS_COMPANY_STATUS` |
| `DM_CHUC_VU` | Danh mục chức vụ | UID01, UID02, UID03, UID08 | 🟢 `CV: SCMS_POSITION_TYPE` |
| `DM_DICH_VU` | Danh mục dịch vụ | UID01, UID08 | 🟢 `CV: SCMS_SERVICE_TYPE` |
| `DM_NGANH_NGHE_KD` | Danh mục ngành nghề KD | UID01, UID08 | 🟢 `CV: SCMS_BUSINESS_SECTOR` |
| `DM_MOI_QUAN_HE` | Danh mục mối quan hệ | UID01 | 🟢 `CV: SCMS_SHAREHOLDER_RELATION_TYPE` |
| `DM_LOAI_GIAO_DICH_CD` | Danh mục loại giao dịch cổ đông | UID01 | 🟢 `CV: SCMS_SHAREHOLDER_TXN_TYPE` |
| `DM_LOAI_VI_PHAM` | Danh mục loại vi phạm | UID01 | 🟢 `CV: SCMS_VIOLATION_TYPE` |
| `DM_SU_VU` | Danh mục sự vụ | UID08 | 🟢 `CV: SCMS_INCIDENT_TYPE` |
| `DM_CHI_TIEU` | Danh mục chỉ tiêu | UID06 | 🟢 Report Indicator |
| `DM_CHI_TIEU_DM` | Danh mục nhóm chỉ tiêu | UID06 | 🟢 `CV: SCMS_INDICATOR_GROUP` |
| `DM_CHI_TIEU_THONG_KE` | Danh mục chỉ tiêu thống kê | UID01 | 🔴 (Out of scope) *Metadata — cross-reference giữa 2 scheme, dùng trong ETL* |
| `DM_THONG_KE` | Danh mục mã thống kê | UID01 | 🟢 `CV: SCMS_STATISTICAL_CODE` |
| `DM_CANH_BAO` | Danh mục cảnh báo | UID06 | 🟢 `CV: SCMS_REPORT_WARNING_RULE` *(cần xác nhận)* |
| `CHUNG_THU_SO` | Chứng thư số (chữ ký số) | UID01 | 🔴 (Out of scope) *Operational/system data* |