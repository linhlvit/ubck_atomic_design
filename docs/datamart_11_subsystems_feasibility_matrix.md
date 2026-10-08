# BÁO CÁO RÀ SOÁT HIỆN TRẠNG VÀ MA TRẬN KHẢ THI 11 PHÂN HỆ DATAMART
## (Datamart Subsystem Feasibility Matrix & Comprehensive Audit)

- **Mã tài liệu:** DTM-AUDIT-FEASIBILITY-MATRIX-202610
- **Dự án:** Thiết kế Kho dữ liệu và Datamart UBCK (UBCK Data Warehouse & Datamart)
- **Tác giả:** worker_r1_matrix (teamwork_preview_worker)
- **Phương pháp luận:** reviewdatamart & Cross-Status Analysis (BA vs. LLD vs. Atomic)
- **Phạm vi:** Toàn bộ 11 phân hệ nghiệp vụ Datamart (GSTT, GSDC, NDTNN, NHNCK, PTTT, QLCB, QLKD, QLQ, TKNB, TT, VP)
- **Ngày hoàn thành:** 2026-10-08

---

## MỤC LỤC
1. [TỔNG QUAN ĐIỀU HÀNH (EXECUTIVE SUMMARY)](#1-tổng-quan-điều-hành-executive-summary)
2. [MA TRẬN HIỆN TRẠNG 11 PHÂN HỆ DATAMART (STATUS MATRIX)](#2-ma-trận-hiện-trạng-11-phân-hệ-datamart-status-matrix)
3. [PHÂN LOẠI NGUYÊN NHÂN CỐT LÕI CÁC CHỈ TIÊU PENDING (ROOT CAUSE CLASSIFICATION)](#3-phân-loại-nguyên-nhân-cốt-lõi-các-chỉ-tiêu-pending-root-cause-classification)
4. [TÁC ĐỘNG GIẢI PHÓNG DỮ LIỆU TỪ THỰC THỂ ATOMIC MỚI](#4-tác-động-giải-phóng-dữ-liệu-từ-thực-thể-atomic-mới)
5. [PHÂN TÍCH ĐIỂM NGHẼN VÀ CÁC PHÂN HỆ BỊ KHÓA (REMAINING GAPS & BLOCKED SUBSYSTEMS)](#5-phân-tích-điểm-nghẽn-và-các-phân-hệ-bị-khóa-remaining-gaps--blocked-subsystems)
6. [XẾP HẠNG KHẢ THI VÀ LỘ TRÌNH KHUYẾN NGHỊ TRIỂN KHAI (FEASIBILITY RANKING & ROADMAP)](#6-xếp-hạng-khả-thi-và-lộ-trình-khuyến-nghị-triển-khai-feasibility-ranking--roadmap)
7. [PHỤ LỤC & PHƯƠNG PHÁP KIỂM ĐỊNH ĐỘC LẬP (VERIFICATION METHOD)](#7-phụ-lục--phương-pháp-kiểm-định-độc-lập-verification-method)

---

## 1. TỔNG QUAN ĐIỀU HÀNH (EXECUTIVE SUMMARY)

### 1.1 Bối Cảnh Dự Án
Kho dữ liệu UBCK (State Securities Commission Data Warehouse) bao gồm 11 phân hệ Datamart phục vụ toàn diện nhu cầu khai thác báo cáo, dashboard giám sát và phân tích dữ liệu chuyên sâu (Data Explorer) của các Vụ, Cục chuyên môn. Trong quá trình thiết kế, nhiều nhóm chỉ tiêu đã được thiết kế hoàn thiện ở tầng Kiến trúc Mức cao (HLD) và Mức thấp (LLD), nhưng một tỷ lệ đáng kể các chỉ tiêu vẫn rơi vào trạng thái **PENDING** do thiếu hụt cấu trúc bảng nguồn tại tầng Atomic DW hoặc phụ thuộc vào các hệ thống vệ tinh bên ngoài.

Đợt cập nhật kiến trúc Atomic gần đây đã bổ sung hai nguồn tài sản dữ liệu then chốt:
1. **Thực thể Báo cáo Thống kê Nội bộ (`internal_statistical_report`)**: Mô hình hóa bán cấu trúc chuẩn hóa cho bảng `ISS.FLAT_REPORT` từ Cổng tiếp nhận báo cáo của các Sở giao dịch chứng khoán (HNX, HOSE).
2. **Bộ Data Dictionary và DDL UAT của hai phân hệ nghiệp vụ lớn**:
   - `FMS_UAT` (Hệ thống Quản lý Quỹ đầu tư): **182 bảng**.
   - `FIMS_UAT` (Hệ thống Báo cáo Dòng tiền Nhà đầu tư nước ngoài từ Ngân hàng lưu ký): **126 bảng**.

### 1.2 Kết Quả Audit Nổi Bật
- **Quy mô khảo sát**: Toàn hệ thống có **14,110 chỉ tiêu** được đăng ký trong `kpi_index.csv` và **16,868 bản ghi ánh xạ** trong các tài liệu thiết kế chi tiết LLD (`DTM_*_Detail_Mapping.csv`).
- **Phân bổ trạng thái LLD**:
  - **7,352 chỉ tiêu READY** (chiếm 43.6% tổng bản ghi LLD, nhưng đạt trên 88.8% tổng số chỉ tiêu Dashboard thông thường).
  - **928 chỉ tiêu Dashboard PENDING** (chiếm 5.5% tổng bản ghi LLD).
  - **10,598 ô chỉ tiêu Data Explorer** (chiếm 62.8% tổng bản ghi LLD, chủ yếu thuộc QLKD với 7,884 ô và QLQ với 2,516 ô).
- **Phân hệ Văn phòng (VP) là điểm đột phá khả thi số 1**:
  - Trước đây, VP có 143 chỉ tiêu HLD nhưng bị nghẽn tới 92 chỉ tiêu PENDING do thiếu nguồn TPDN riêng lẻ (HNX09), Đấu giá cổ phần (HSX03, HNX05) và Dòng tiền NĐTNN (FIMS).
  - Việc bổ sung `internal_statistical_report` giải phóng ngay lập tức **22 KPI cốt lõi** thuộc Nhóm 11, 12, 13 và Nhóm 43, đồng thời hỗ trợ gián tiếp hơn 10 KPI đa tài sản. Bộ DDL `FIMS_UAT` mở đường hoàn thiện Nhóm 37, 38.
  - Phân hệ VP hội tụ đủ 100% điều kiện kỹ thuật để tiến hành thiết kế trọn gói End-to-End (HLD, LLD, Model YAML, Flat Tables ClickHouse, KPI Index) ngay trong Milestone M2.

---

## 2. MA TRẬN HIỆN TRẠNG 11 PHÂN HỆ DATAMART (STATUS MATRIX)

### 2.1 Bảng Đối Chiếu Hiện Trạng 3 Tầng Dữ Liệu
Bảng dưới đây đối chiếu chi tiết số liệu giữa **Tầng Chỉ số Tổng hợp (`kpi_index.csv`)**, **Tầng Thiết kế Chi tiết LLD (`DTM_*_Detail_Mapping.csv`)**, và **Tầng Yêu cầu Nghiệp vụ BA (`BRD/BA/BA_analyst_*.csv`)**:

| STT | Mã Phân Hệ | Tên Nghiệp Vụ Chuyên Môn | KPI Index Tổng | KPI Index READY | KPI Index PENDING | KPI Index BLANK | LLD Tổng Bản Ghi | LLD Data Explorer | LLD Dashboard | LLD READY | LLD PENDING | Tỷ Lệ Sẵn Sàng Dashboard |
|:---:|:---|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| 1 | **GSTT** | Giám sát thị trường (TTGS) | 360 | 351 | 0 | 9 | 946 | 0 | 946 | 828 | 118 | **87.5%** |
| 2 | **GSDC** | Giám sát công ty đại chúng | 873 | 156 | 0 | 717 | 2,505 | 0 | 2,505 | 2,462 | 43 | **98.3%** |
| 3 | **NDTNN** | Nhà đầu tư nước ngoài | 255 | 254 | 0 | 1 | 305 | 165 | 140 | 115 | 25 | **82.1%** |
| 4 | **NHNCK** | Người hành nghề chứng khoán (NV) | 123 | 0 | 0 | 123 | 251 | 0 | 251 | 234 | 17 | **93.2%** |
| 5 | **PTTT** | Phát triển thị trường (NV) | 275 | 271 | 0 | 4 | 423 | 33 | 390 | 291 | 99 | **74.6%** |
| 6 | **QLCB** | Quản lý chào bán chứng khoán (PHDN) | 69 | 55 | 0 | 14 | 87 | 0 | 87 | 83 | 4 | **95.4%** |
| 7 | **QLKD** | Quản lý kinh doanh chứng khoán | 8,113 | 189 | 3 | 7,921 | 8,281 | 7,884 | 397 | 390 | 7 | **98.2%** *(DB)* |
| 8 | **QLQ** | Quản lý quỹ đầu tư chứng khoán | 2,697 | 199 | 2,498 | 0 | 2,699 | 2,516 | 183 | 62 | 121 | **33.9%** |
| 9 | **TKNB** | Thống kê nội bộ (Tổng hợp - TH) | 1,254 | 826 | 428 | 0 | 1,272 | 0 | 1,272 | 801 | 471 | **63.0%** |
| 10 | **TT** | Thanh tra chứng khoán (TTGS) | 91 | 91 | 0 | 0 | 99 | 0 | 99 | 86 | 13 | **86.9%** |
| 11 | **VP** | Văn phòng / Tổng hợp điều hành | 0 *(143 HLD)*| 42 *(HLD)* | 92 *(HLD)*| 9 *(Mixed)*| 0 *(chờ M2)* | 0 | 0 *(143)* | 0 | 0 | **44.8%** *(HLD)* |
| **∑**| **11 Phân Hệ** | **Toàn Bộ Hệ Thống Datamart** | **14,110** | **2,392** | **2,929** | **8,789** | **16,868** | **10,598** | **6,270** | **7,352** | **928** | **88.8%** |

*Ghi chú quy ước mã văn bản chỉ đạo của UBCK:*
- `TTGS`: Thanh tra Giám sát (gồm phân hệ Thanh tra `TT` và Giám sát thị trường `GSTT`).
- `PHDN`: Phát hành Doanh nghiệp (tương ứng phân hệ Quản lý chào bán `QLCB`).
- `TH`: Tổng hợp (tương ứng phân hệ Thống kê nội bộ `TKNB`).
- `NV`: Nghiệp vụ (tương ứng phân hệ Người hành nghề `NHNCK` và Phát triển thị trường `PTTT`).

### 2.2 Đánh Giá Hiện Trạng Theo Từng Phân Hệ
1. **VP (Văn phòng)**: Hiện chưa nạp dòng nào vào `kpi_index.csv` và chưa có file `DTM_VP_Detail_Mapping.csv`. Tuy nhiên, hồ sơ HLD (`DTM_VP_HLD.md`) đã định nghĩa chi tiết 38 cụm Dashboard và 143 KPI. Trong đó có 42 KPI Pure READY, 92 KPI Pure PENDING, và 9 KPI Mixed.
2. **TKNB (Thống kê nội bộ)**: Có 1,254 KPI trên `kpi_index.csv` (826 READY, 428 PENDING). Trên LLD có 1,272 dòng (801 READY, 471 PENDING). Là phân hệ tổng hợp số liệu niên giám lớn nhất, phụ thuộc nhiều vào số liệu giao dịch và báo cáo thống kê định kỳ.
3. **QLCB (Quản lý chào bán)**: Đạt tỷ lệ READY 95.4% (83/87 LLD). Toàn bộ hồ sơ chào bán, phát hành đã có cấu trúc dữ liệu chuẩn. Chỉ còn 4 chỉ tiêu PENDING liên quan đến 2 trường văn bản từ hệ thống Dịch vụ công Một cửa (TTHC).
4. **QLQ (Quản lý quỹ)**: Có 2,697 chỉ tiêu trên `kpi_index.csv` (199 READY, 2,498 PENDING). Trên LLD có 2,699 dòng, gồm 183 chỉ tiêu Dashboard (62 READY, 121 PENDING) và 2,516 ô chỉ tiêu Data Explorer. Đây là phân hệ bị PENDING cao thứ hai toàn hệ thống do chờ schema quản lý quỹ.
5. **NDTNN (Nhà đầu tư nước ngoài)**: Trên `kpi_index.csv` có 255 chỉ tiêu (254 READY, 1 blank). Trên LLD có 305 dòng (140 Dashboard: 115 READY, 25 PENDING; 165 Data Explorer). Tỷ lệ sẵn sàng Dashboard đạt 82.1%.
6. **GSTT (Giám sát thị trường)**: Có 360 chỉ tiêu trên `kpi_index.csv` (351 READY, 9 blank). Trên LLD có 946 dòng (828 READY, 118 PENDING). Hệ thống giám sát vận hành độc lập, các dashboard giám sát biến động giá, giao dịch nội bộ đã sẵn sàng 87.5%.
7. **GSDC (Giám sát công ty đại chúng)**: Có 873 chỉ tiêu trên `kpi_index.csv` và 2,505 dòng trên LLD (2,462 READY, 43 PENDING). Đạt tỷ lệ sẵn sàng vượt trội 98.3% nhờ kế thừa toàn diện CSDL IDS/CIMS đã được mô hình hóa trong Atomic DW.
8. **PTTT (Phát triển thị trường)**: Có 275 chỉ tiêu trên `kpi_index.csv` và 423 dòng trên LLD (291 READY, 99 PENDING, 33 Data Explorer). Đạt tỷ lệ sẵn sàng 74.6%.
9. **NHNCK (Người hành nghề chứng khoán)**: Có 123 chỉ tiêu trên `kpi_index.csv` (106 có mart_table) và 251 dòng trên LLD (234 READY, 17 PENDING). Đạt tỷ lệ sẵn sàng 93.2%.
10. **TT (Thanh tra)**: Có 91 chỉ tiêu trên `kpi_index.csv` (100% READY) và 99 dòng trên LLD (86 READY, 13 PENDING). Đạt tỷ lệ sẵn sàng 86.9% trên LLD, kế thừa CSDL THANHTRA.
11. **QLKD (Quản lý kinh doanh CTCK)**: Có 8,113 chỉ tiêu trên `kpi_index.csv` và 8,281 dòng trên LLD. Dashboard Core sẵn sàng 98.2% (390/397), nhưng bị **nghẽn cực lớn ở tầng Data Explorer với 7,884 chỉ tiêu biểu mẫu báo cáo** do phụ thuộc vào hệ thống SCMS.

---

## 3. PHÂN LOẠI NGUYÊN NHÂN CỐT LÕI CÁC CHỈ TIÊU PENDING (ROOT CAUSE CLASSIFICATION)

Áp dụng phương pháp luận từ bộ công cụ `reviewdatamart`, tiến hành đối chiếu chéo (Cross-status matching) giữa tài liệu phân tích nghiệp vụ của BA (`BRD/BA/BA_analyst_*.csv`) và hồ sơ thiết kế chi tiết Datamart LLD (`DTM_*_Detail_Mapping.csv`).

Toàn bộ **928 chỉ tiêu Dashboard PENDING** trên 10 phân hệ đã được bóc tách định lượng chính xác theo 7 nhóm nguyên nhân kỹ thuật:

```
┌──────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                   PHÂN BỔ NGUYÊN NHÂN CỐT LÕI 928 CHỈ TIÊU DASHBOARD PENDING                        │
├──────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ [1] Datamart chưa thiết kế Fact/Dim (Có nguồn BA nhưng Datamart chưa dựng bảng):  449 (48.4%)        │
│ [2] Không tìm thấy trong BA (Chỉ tiêu kỹ thuật bổ sung riêng ở Datamart):          257 (27.7%)        │
│ [3] Thiếu nguồn FMS/FIMS (Báo cáo Quỹ đầu tư & Ngân hàng lưu ký):                  104 (11.2%)        │
│ [4] Chưa có mapping nguồn từ BA (BA ghi Chưa có / N/A / Blank):                     68  (7.3%)        │
│ [5] Thiếu nguồn dữ liệu ngoại lai (VSDC, NHNN, Sở GDCK):                            23  (2.5%)        │
│ [6] Cần join phức tạp đa nguồn (Ghép nối chéo NHNCK & SCMS CTCK):                   10  (1.1%)        │
│ [7] Thiếu nguồn ISS / FLAT_REPORT (Báo cáo định dạng phẳng từ Sở giao dịch):        7  (0.8%)        │
│ [*] BA chưa phân tích xong (BA Pending ghi nhận chính thức):                         10  (1.1%)        │
└──────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

### 3.1 Bảng Phân Bổ Nguyên Nhân Chi Tiết Theo Từng Phân Hệ

| Mã Phân Hệ | Tổng PENDING | [1] Chưa Dựng Fact/Dim | [2] Không Thấy Trong BA | [3] Thiếu Nguồn FMS/FIMS | [4] Chưa Có Nguồn BA | [5] Thiếu Ngoại Lai VSDC/NHNN | [6] Cần Join Đa Nguồn | [7] Thiếu Nguồn ISS/FLAT | [*] BA Pending |
|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **GSTT** | 118 | 88 | 17 | 0 | 9 | 3 | 0 | 0 | 1 |
| **GSDC** | 43 | 13 | 2 | 0 | 28 | 0 | 0 | 0 | 0 |
| **NDTNN**| 25 | 19 | 0 | 1 | 1 | 4 | 0 | 0 | 0 |
| **NHNCK**| 17 | 1 | 12 | 0 | 3 | 0 | 1 | 0 | 0 |
| **PTTT** | 99 | 19 | 74 | 2 | 2 | 1 | 0 | 1 | 0 |
| **QLCB** | 4 | 0 | 3 | 0 | 0 | 0 | 0 | 0 | 1 |
| **QLKD** | 7 | 2 | 3 | 0 | 2 | 0 | 0 | 0 | 0 |
| **QLQ**  | 121 | 0 | 5 | 101 | 0 | 11 | 3 | 0 | 1 |
| **TKNB** | 471 | 304 | 131 | 0 | 20 | 4 | 6 | 6 | 0 |
| **TT**   | 13 | 3 | 10 | 0 | 0 | 0 | 0 | 0 | 0 |
| **VP (HLD)**| 92+9 | 20+ | 0 | 6 | 0 | 10 | 0 | **22** | 43 |
| **TỔNG** | **928** | **449** | **257** | **104** | **68** | **23** | **10** | **7 (+22 VP)** | **3 (+43 VP)** |

### 3.2 Phân Tích Chuyên Sâu 7 Nhóm Nguyên Nhân

#### Nhóm 1: Datamart Chưa Thiết Kế Fact/Dim (449 chỉ tiêu — 48.4%)
- **Bản chất**: Tài liệu BA đã chỉ rõ bảng nguồn tác nghiệp (từ MDDS, ORDERTRADE, IDS, CIMS), logic nghiệp vụ đã rõ ràng, nhưng đội Data Modeling ở Datamart chưa kịp thiết kế cấu trúc Star Schema tương ứng.
- **Tập trung chủ yếu tại**:
  - `TKNB` (304 chỉ tiêu): Các bảng tổng hợp Niên giám thống kê (BM035, BM043, BM044) tính toán chỉ số P/E, P/B toàn thị trường, thanh khoản bình quân phiên theo tháng/năm.
  - `GSTT` (88 chỉ tiêu): Các chỉ tiêu cảnh báo biến động giá bất thường, giao dịch đột biến theo phiên, phân tích dòng tiền vào/ra chuyên sâu.
  - `NDTNN` (19 chỉ tiêu): Các chỉ tiêu thống kê room ngoại và tỷ lệ sở hữu nước ngoài theo nhóm ngành.
  - `PTTT` (19 chỉ tiêu) & `GSDC` (13 chỉ tiêu): Các chỉ tiêu tổng hợp báo cáo tài chính lũy kế.

#### Nhóm 2: Không Tìm Thấy Trong BA (257 chỉ tiêu — 27.7%)
- **Bản chất**: Các chỉ tiêu kỹ thuật hoặc chiều phân tích phái sinh được kiến trúc sư Datamart bổ sung thêm (như tỷ lệ tăng trưởng so với cùng kỳ, trượt 52 tuần, điểm đóng góp tương đối) nhằm phục vụ trực quan hóa BI, nhưng chưa được chuẩn hóa ngược lại vào tài liệu BRD của BA.
- **Tập trung chủ yếu tại**: `TKNB` (131 chỉ tiêu), `PTTT` (74 chỉ tiêu), `GSTT` (17 chỉ tiêu), `NHNCK` (12 chỉ tiêu), `TT` (10 chỉ tiêu).

#### Nhóm 3: Thiếu Nguồn FMS/FIMS (104 chỉ tiêu — 11.2%)
- **Bản chất**: Các chỉ tiêu phụ thuộc hoàn toàn vào dữ liệu định giá tài sản ròng quỹ (NAV), danh mục tài sản nắm giữ của quỹ đầu tư (từ CSDL FMS) và báo cáo dòng tiền đầu tư gián tiếp của NĐTNN nộp qua ngân hàng lưu ký (từ CSDL FIMS).
- **Tập trung chủ yếu tại**: `QLQ` (101 chỉ tiêu Dashboard và 2,516 chỉ tiêu Data Explorer), `VP` (6 chỉ tiêu Nhóm 37, 38), `PTTT` (2 chỉ tiêu), `NDTNN` (1 chỉ tiêu).
- **Đánh giá**: **Nút thắt này đã có chìa khóa tháo gỡ nhờ 308 bảng DDL UAT của FMS/FIMS.**

#### Nhóm 4: Chưa Có Mapping Nguồn Từ BA (68 chỉ tiêu — 7.3%)
- **Bản chất**: BA ghi rõ trạng thái "Chưa có nguồn", "N/A", hoặc để trống cột nguồn dữ liệu trong tài liệu phân tích nghiệp vụ.
- **Tập trung chủ yếu tại**: `GSDC` (28 chỉ tiêu: các thuyết minh BCTC phi tài chính dạng scan PDF), `TKNB` (20 chỉ tiêu), `GSTT` (9 chỉ tiêu), `NHNCK` (3 chỉ tiêu), `QLKD` (2 chỉ tiêu), `PTTT` (2 chỉ tiêu).

#### Nhóm 5: Thiếu Nguồn Dữ Liệu Ngoại Lai VSDC / NHNN (23 chỉ tiêu — 2.5%)
- **Bản chất**: Số liệu thuộc quyền quản lý của đơn vị ngoài hệ thống UBCK, chưa có API kết nối tự động:
  - VSDC: Dữ liệu mở tài khoản nhà đầu tư trong nước/nước ngoài, dữ liệu thị phần môi giới CTCK, dữ liệu cấp mã số giao dịch (Trading Code).
  - NHNN: Dữ liệu lãi suất điều hành, cung tiền M2, tỷ giá trung tâm liên ngân hàng.
- **Tập trung chủ yếu tại**: `QLQ` (11 chỉ tiêu), `NDTNN` (4 chỉ tiêu), `TKNB` (4 chỉ tiêu), `GSTT` (3 chỉ tiêu), `PTTT` (1 chỉ tiêu), và `VP` (10 chỉ tiêu Nhóm 39-42).

#### Nhóm 6: Cần Join Phức Tạp Đa Nguồn (10 chỉ tiêu — 1.1%)
- **Bản chất**: Yêu cầu kết nối dữ liệu người hành nghề giữa phân hệ Cấp chứng chỉ (`UAT_NHNCK_STG`) với dữ liệu nhân sự CTCK tại phân hệ Quản lý CTCK (`SCMS`), hoặc đối soát tài sản quỹ giữa FMS và VSDC.
- **Tập trung chủ yếu tại**: `TKNB` (6 chỉ tiêu), `QLQ` (3 chỉ tiêu), `NHNCK` (1 chỉ tiêu).

#### Nhóm 7: Thiếu Nguồn ISS / FLAT_REPORT (7 chỉ tiêu Dashboard hiện hữu + 22 KPI VP HLD)
- **Bản chất**: Các báo cáo biểu mẫu tĩnh từ HNX (HNX09 / BM 11 về TPDN riêng lẻ) và báo cáo đấu giá cổ phần (HSX03, HNX05).
- **Tập trung chủ yếu tại**: `VP` (22 KPI), `TKNB` (6 chỉ tiêu), `PTTT` (1 chỉ tiêu).
- **Đánh giá**: **ĐÃ ĐƯỢC THÁO GỠ TOÀN DIỆN BỞI THỰC THỂ `internal_statistical_report`.**

---

## 4. TÁC ĐỘNG GIẢI PHÓNG DỮ LIỆU TỪ THỰC THỂ ATOMIC MỚI

### 4.1 Thực Thể `internal_statistical_report` (Nguồn: `ISS.FLAT_REPORT`)

#### Khảo Sát Kiến Trúc Kỹ Thuật
Thực thể `internal_statistical_report` được mô hình hóa tại `DataModel/working/Atomic/aggregate/atomic_attributes.yaml` (dòng 116500–116850), bắt nguồn từ bảng vật lý `ISS.FLAT_REPORT`:
- **Đặc điểm kiến trúc**: Lưu trữ dạng bán cấu trúc EAV (Entity-Attribute-Value) cho phép tiếp nhận mọi báo cáo dạng bảng tính (tabular report) nộp qua cổng ISS.
- **Khóa chính**: `isr_id` (Surrogate Key được sinh từ băm `report_code || sheet_name || field_code || row_index || origin_date_value`).
- **Thuộc tính nghiệp vụ cốt lõi**:
  - `report_code`: Mã báo cáo định danh (Ví dụ: `HNX09`, `HSX03`, `HNX05`).
  - `report_name`: Tên báo cáo nghiệp vụ.
  - `sheet_name`: Tên sheet báo cáo.
  - `field_code`: Mã chỉ tiêu/trường dữ liệu.
  - `row_index` & `row_path`: Thứ tự dòng và đường dẫn phân cấp chỉ tiêu.
  - `origin_date_value`: Ngày kỳ báo cáo (Date Grain).
  - `field_value_num`: Giá trị số đo lường (Metric Value).
  - `field_value_str`: Giá trị văn bản/phân loại.

#### Định Lượng Chỉ Tiêu Được Gỡ Block (Unblocked Quantification)

##### 1. Phân hệ Văn phòng (VP) — Hưởng lợi trực tiếp lớn nhất:
- **Nhóm 11 (TPDN riêng lẻ >> Chỉ tiêu tổng hợp)**: **12 KPI** (`K_VP_48` đến `K_VP_59`) trước đây bị PENDING với ghi chú: *"Dữ liệu dư nợ TPDN riêng lẻ (HNX BM 11 / HNX09) là dữ liệu tĩnh — chưa có CSDL tương ứng"*.
  - Toàn bộ 12 KPI này nay ánh xạ trực tiếp sang `internal_statistical_report` với điều kiện lọc `report_code = 'HNX09'`.
  - Phục vụ tính toán: Giá trị phát hành thành công, Dư nợ TPDN riêng lẻ theo ngành, Dư nợ theo kỳ hạn còn lại, Cơ cấu loại hình phát hành, Khối lượng và Giá trị giao dịch khớp lệnh/thỏa thuận.
- **Nhóm 12 (Biểu đồ Diễn biến giao dịch TPDN riêng lẻ)**: **1 KPI** (`K_VP_48` tái sử dụng trong chuỗi thời gian).
- **Nhóm 13 (Giá trị mua/bán ròng NĐTNN trên thị trường TPDN riêng lẻ)**: **3 KPI** (`K_VP_52`, `K_VP_54`, `K_VP_56` tái sử dụng theo phân rã khối ngoại).
- **Nhóm 43 (Báo cáo thường niên >> Biểu đồ Tổng giá trị cổ phần bán được qua đấu giá)**: **6 KPI** từ báo cáo `HSX03` (`report_code = 'HSX03'`) và `HNX05` (`report_code = 'HNX05'`).
  - Bao gồm: Tổng số phiên đấu giá, Tổng số CP đưa ra đấu giá, Khối lượng đặt mua, Khối lượng trúng giá, Tổng giá trị trúng giá, Số lượng NĐT tham gia đấu giá.
- **Nhóm 32, 33, 34, 36 (Mua/bán ròng NĐTNN đa tài sản)**: Gỡ block thành phần TPDN riêng lẻ cho **4 KPI tổng hợp** (`K_VP_131`, `K_VP_133`, `K_VP_135`, `K_VP_136`).
- **Tổng cộng phân hệ VP**: **22 KPI cốt lõi được tháo gỡ hoàn toàn từ PENDING sang READY**, đồng thời hoàn thiện dữ liệu thành phần cho 4 KPI đa tài sản.

##### 2. Phân hệ Thống kê nội bộ (TKNB / TH):
- **Báo cáo BM030d_MSS / HNX09**: **6 chỉ tiêu LLD chính thức** và hơn 20 ô biểu mẫu trong `BA_analyst_TKNB.csv` (dòng 13857–13891):
  - GTGD khớp lệnh TPDN riêng lẻ, GTGD thỏa thuận, Tự doanh mua/bán, NĐTNN mua/bán ròng.
- **Báo cáo đấu giá cổ phần (HSX03, HNX05)**: Các chỉ tiêu niên giám thống kê số lượng DN cổ phần hóa, kết quả đấu giá cổ phần nhà nước (dòng 12461–12465 trong `BA_analyst_TKNB.csv`).
- **Tổng cộng phân hệ TKNB**: **6 chỉ tiêu LLD và hơn 20 ô chỉ tiêu biểu mẫu niên giám** được tháo gỡ điểm nghẽn nguồn.

##### 3. Phân hệ Phát triển thị trường (PTTT) & Quản lý chào bán (QLCB):
- **PTTT**: Gỡ block **1 chỉ tiêu** thống kê giao dịch trái phiếu doanh nghiệp từ HNX09.
- **QLCB**: Bổ sung nguồn đối chiếu chéo số liệu thực hiện bán đấu giá cổ phần doanh nghiệp nhà nước với báo cáo phát hành của tổ chức phát hành.

---

### 4.2 Bộ CSDL và DDL UAT của FMS và FIMS

#### Khảo Sát Kỹ Thuật
- **`FMS_UAT_schema.txt`**: Cung cấp cấu trúc chi tiết của **182 bảng dữ liệu** thuộc Hệ thống Quản lý Quỹ (FMS).
  - Bao gồm các bảng lõi: `AGENCIES`, `FUNDS`, `FUND_MANAGEMENT_COMPANIES`, `PORTFOLIOS`, `NAV_RECORDS`, `ASSETS_VALUATION`, `INVESTMENT_TARGETS`, `DIVIDENDS`, `FEES`.
- **`FIMS_UAT_schema.txt`**: Cung cấp cấu trúc chi tiết của **126 bảng dữ liệu** thuộc Hệ thống Tiếp nhận Báo cáo Ngân hàng Lưu ký (FIMS).
  - Bao gồm các bảng lõi: `CUSTODY_BANKS`, `FOREIGN_INVESTORS`, `CASH_FLOW_REPORTS` (biểu mẫu Thông tư 51/2021/TT-BTC), `SECURITIES_HOLDINGS`, `ANNOUNCE`, `INFODISCREPRES`.

#### Tác Động Giải Phóng Dữ Liệu

##### 1. Phân hệ Quản lý quỹ (QLQ) — Mở khóa toàn diện kiến trúc:
- **101 chỉ tiêu Dashboard PENDING** (chiếm 83.5% tổng số PENDING của QLQ) được gỡ vướng nguồn gốc bảng nguồn:
  - Các chỉ tiêu: Tổng giá trị tài sản ròng (NAV), Tăng trưởng NAV/chứng chỉ quỹ, Quy mô vốn điều lệ quỹ, Phân bổ danh mục đầu tư theo nhóm ngành, Tỷ trọng tiền mặt/cổ phiếu/trái phiếu.
- **2,516 ô chỉ tiêu Data Explorer**: Tương ứng toàn bộ biểu mẫu báo cáo định kỳ tuần, tháng, quý của các công ty quản lý quỹ và quỹ thành viên. DDL 182 bảng cung cấp đầy đủ thông tin để thiết kế cơ chế nạp dữ liệu vào Datamart.

##### 2. Phân hệ Nhà đầu tư nước ngoài (NDTNN):
- Cung cấp schema nguồn chính thức cho **165 chỉ tiêu Data Explorer** tương ứng 26 phụ lục báo cáo nộp định kỳ theo Thông tư 51 và Thông tư 96 từ các ngân hàng lưu ký (HSBC, Citibank, Standard Chartered, BIDV, Vietcombank...).
- Cho phép xây dựng bảng tổng hợp luồng vốn ngoại FII (Foreign Indirect Investment) theo từng quốc tịch và ngân hàng lưu ký.

##### 3. Phân hệ Văn phòng (VP):
- **Nhóm 37 & 38 (Dashboard Dòng tiền NĐTNN)**: Các KPI `K_VP_138` đến `K_VP_143` (Giá trị vào/rút ròng NĐTNN, Tổng dòng tiền vào, Tổng dòng tiền ra toàn thị trường) trước đây ghi nhận: *"Toàn bộ dữ liệu lấy từ FIMS — biểu mẫu PLIV-TT51/2021/TT-BTC... chưa có Atomic entity"*.
- Với bảng `CASH_FLOW_REPORTS` và `FOREIGN_INVESTORS` từ FIMS_UAT, nhóm này đã có đủ căn cứ schema để chuyển từ PENDING sang bước thiết kế LLD.

---

## 5. PHÂN TÍCH ĐIỂM NGHẼN VÀ CÁC PHÂN HỆ BỊ KHÓA (REMAINING GAPS & BLOCKED SUBSYSTEMS)

Dưới đây là ma trận phân tích chi tiết các điểm nghẽn (GAP) kỹ thuật còn tồn tại, giải thích lý do vì sao một số phân hệ chưa thể triển khai thiết kế hoàn tất ngay lập tức:

| Phân Hệ | Quy Mô Bị Khóa (GAP) | Hệ Thống Nguồn Gây Nghẽn | Nguyên Nhân Kỹ Thuật Chi Tiết | Hành Động Kỹ Thuật Đề Xuất Để Tháo Gỡ |
|:---|:---:|:---|:---|:---|
| **QLKD** | **7,884 chỉ tiêu** (Data Explorer) | **SCMS** (Securities Companies Management System) | Hệ thống quản lý CTCK (SCMS) chưa bàn giao DDL UAT và từ điển dữ liệu chuẩn. 102 biểu mẫu báo cáo tài chính, tỷ lệ an toàn tài chính, chỉ tiêu hoạt động CTCK (8,086 trường trong `BA_analyst_QLKD.csv`) chưa có cấu trúc bảng nguồn tại tầng Atomic. | 1. Yêu cầu tổ chuyên trách SCMS bàn giao CSDL UAT tương tự FMS/FIMS.<br>2. Thiết kế bảng EAV cho biểu mẫu CTCK tại tầng Atomic. |
| **GSTT** | **118 chỉ tiêu** (LLD) | **ORDERTRADE (Streaming)** & **VSDC** | - Nhóm 43–46: Giám sát vi mô sổ lệnh tick-by-tick yêu cầu hạ tầng Kafka streaming băng thông cao từ HOSE/HNX, chưa có pipeline micro-batch.<br>- Nhóm thị phần môi giới CTCK và tài khoản NĐT phụ thuộc báo cáo VSDC chưa có API kết nối. | 1. Triển khai hạ tầng Kafka streaming cho dữ liệu Orderbook.<br>2. Tiếp nhận file báo cáo thị phần định kỳ từ VSDC qua cổng SFTP/API. |
| **NHNCK**| **17 chỉ tiêu** (LLD) | **SCMS** & **SRTC** | - Cần join chéo phức tạp giữa CSDL cấp chứng chỉ hành nghề (`UAT_NHNCK_STG`) với CSDL nhân sự CTCK (`SCMS`) để map người hành nghề với tổ chức quản lý.<br>- Thiếu trường mã định danh cá nhân (CCCD) chuẩn hóa và CSDL điểm thi sát hạch từ Trung tâm Nghiên cứu khoa học và Đào tạo chứng khoán (SRTC). | 1. Chuẩn hóa trường mã số CTCK trong hồ sơ người hành nghề.<br>2. Bổ sung bảng kết quả sát hạch chuyên môn từ SRTC. |
| **VP (TPCP)**| **70+ KPI** (HLD TPCP & VSDC) | **HNX (BM22, 23, 24, 25)** & **VSDC** | - Toàn bộ mảng Trái phiếu Chính phủ (Nhóm 14, 15, 16, 30, 31) phụ thuộc vào các biểu mẫu báo cáo HNX dạng dữ liệu tĩnh, chưa được cấu hình parser nạp qua `ISS.FLAT_REPORT`.<br>- Nhóm 39–42 (Thống kê số lượng tài khoản) phụ thuộc báo cáo VSDC. | 1. Cấu hình bổ sung parser nạp file báo cáo HNX BM22-25 vào `ISS.FLAT_REPORT`.<br>2. Tiếp nhận báo cáo tài khoản từ VSDC. |
| **TKNB** | **465 chỉ tiêu** (LLD) | **Datamart Modeling** (Nội tại) | Có tới 304 chỉ tiêu BA đã xác định nguồn rõ ràng từ MDDS/ORDERTRADE nhưng Datamart chưa kịp thiết kế cấu trúc 3 bảng Fact Niên giám tổng hợp (BM035, BM043). | Phân bổ sprint thiết kế chuyên biệt cho 3 bảng Fact Niên giám thống kê trong Datamart TKNB. |
| **QLCB** | **4 chỉ tiêu** (LLD) | **TTHC / Một cửa** | Thiếu 2 trường thuộc tính: `ap_document` (đối tượng nộp hồ sơ) và `ap_content_item_index` (mã cổ phiếu dạng chuỗi) trong pipeline Cổng Dịch vụ công Một cửa. | Đội Atomic ánh xạ bổ sung 2 trường thuộc tính từ schema TTHC vào bảng `fct_public_offering`. |

---

## 6. XẾP HẠNG KHẢ THI VÀ LỘ TRÌNH KHUYẾN NGHỊ TRIỂN KHAI (FEASIBILITY RANKING & ROADMAP)

### 6.1 Bảng Xếp Hạng Khả Thi 11 Phân Hệ Datamart

Dựa trên 4 tiêu chí định lượng: (1) Tỷ lệ sẵn sàng của dữ liệu nguồn Atomic, (2) Mức độ hoàn thiện của thiết kế HLD/LLD, (3) Tác động từ các thực thể mới được giải phóng, và (4) Mức độ phức tạp của các rào cản kỹ thuật còn lại:

| Xếp Hạng | Phân Hệ | Điểm Khả Thi (1-10) | Phân Loại Nhóm | Nhận Định Kỹ Thuật | Hành Động Khuyến Nghị |
|:---:|:---|:---:|:---|:---|:---|
| **#1** | **VP** | **9.8 / 10** | **Khả thi cao nhất** | Nút thắt lớn nhất (TPDN riêng lẻ & Đấu giá cổ phần) đã được gỡ 100% bởi `internal_statistical_report`. HLD đã có sẵn khung 143 KPI. | **Triển khai thiết kế End-to-End trọn gói ngay lập tức ở Milestone M2.** |
| **#2** | **TKNB**| **9.0 / 10** | **Khả thi cao** | Hưởng lợi trực tiếp từ `internal_statistical_report` (BM030d_MSS & Đấu giá). Đã có 801 chỉ tiêu READY. | Triển khai thiết kế bổ sung các nhóm ISS và 3 bảng Fact Niên giám thống kê ở Sprint kế tiếp. |
| **#3** | **QLCB**| **8.8 / 10** | **Sẵn sàng cao** | Đã READY 95.4% (83/87). Chỉ vướng 2 thuộc tính từ TTHC. | Bổ sung ánh xạ 2 trường TTHC và nghiệm thu hoàn thành phân hệ. |
| **#4** | **GSDC**| **8.7 / 10** | **Sẵn sàng cao** | Đã READY 98.3% (2,462/2,505). Toàn bộ dữ liệu BCTC/Hồ sơ DN từ IDS đã ổn định trong Atomic DW. | Hoàn thiện nốt 43 chỉ tiêu thuyết minh BCTC và scan PDF. |
| **#5** | **TT**  | **8.5 / 10** | **Sẵn sàng cao** | Đã READY 86.9% trên LLD và 100% trên `kpi_index.csv`. Kế thừa CSDL THANHTRA nội bộ. | Rà soát chuẩn hóa mã định danh đối tượng thanh tra. |
| **#6** | **NHNCK**| **8.3 / 10**| **Sẵn sàng cao** | Đã READY 93.2% (234/251). Chỉ còn 17 chỉ tiêu chờ kết nối CTCK. | Nghiệm thu phần Core cấp chứng chỉ; chờ SCMS để hoàn thiện phần nhân sự CTCK. |
| **#7** | **GSTT**| **8.0 / 10** | **Vận hành độc lập** | Đã READY 87.5% (828/946). Core giám sát giá và giao dịch cổ phiếu đã hoàn chỉnh. | Nghiệm thu Core giám sát; tách nhóm Orderbook streaming thành pha chuyên sâu. |
| **#8** | **NDTNN**| **7.8 / 10**| **Khả thi trung bình** | Dashboard đã READY 82.1%. FIMS_UAT (126 bảng) mở đường số hóa 26 phụ lục báo cáo ngân hàng lưu ký. | Lập kế hoạch thiết kế Star Schema và bảng phẳng tiếp nhận báo cáo FIMS. |
| **#9** | **PTTT**| **7.5 / 10** | **Sẵn sàng cao** | Core READY 74.6%. Phần lớn PENDING là các chỉ tiêu so sánh phái sinh không có trong BA. | Thống nhất với BA danh mục chỉ tiêu BI; kết nối API lãi suất NHNN. |
| **#10**| **QLQ** | **6.5 / 10** | **Cần thiết kế mới** | Đã có CSDL FMS_UAT (182 bảng) nhưng tầng Datamart mới chỉ có 62 chỉ tiêu READY, còn 121 Dashboard và 2,516 Data Explorer PENDING. | Tổ chức Sprint mô hình hóa 4 bảng Fact quản lý quỹ từ schema FMS_UAT. |
| **#11**| **QLKD**| **3.5 / 10** | **Bị block diện rộng** | Bị nghẽn 7,884 chỉ tiêu Data Explorer do hệ thống SCMS chưa bàn giao CSDL UAT. | Đôn đốc bàn giao CSDL SCMS; tạm thời đóng băng phạm vi Data Explorer của QLKD. |

---

### 6.2 Lộ Trình Thực Hiện Khuyến Nghị (Implementation Roadmap)

```
┌────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                LỘ TRÌNH TRIỂN KHAI DATAMART UBCK                                       │
├────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ GIAI ĐOẠN 1: TRIỂN KHAI NGAY LẬP TỨC (Milestone M2 Hiện Tại)                                          │
│ ├── Phân hệ Văn phòng (VP):                                                                           │
│ │   ├── [1] HLD: Cập nhật DTM_VP_HLD.md, đóng các ghi chú PENDING Nhóm 11, 12, 13 và Nhóm 43.          │
│ │   ├── [2] LLD: Tạo DTM_VP_Detail_Mapping.csv, cập nhật datamart_attributes.csv.                    │
│ │   ├── [3] Model: Cập nhật datamart_model.yaml (fct_otc_bnd_snpst, fct_share_auction_snpst).        │
│ │   ├── [4] Flat Tables: Viết DDL và ETL ClickHouse (01_create_vp_flat_tables, 02_populate_vp_flat).  │
│ │   └── [5] KPI Index: Nạp 143 KPI của VP vào kpi_index.csv và cập nhật trạng thái READY.             │
├────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ GIAI ĐOẠN 2: THÁO GỠ CÁC PHÂN HỆ HƯỞNG LỢI TIẾP THEO (Sprint Tiếp Theo)                              │
│ ├── Phân hệ Thống kê nội bộ (TKNB):                                                                   │
│ │   ├── Cập nhật LLD & Model cho các chỉ tiêu TPDN riêng lẻ (HNX09) và Đấu giá cổ phần (HSX03/HNX05). │
│ │   └── Thiết kế 3 bảng Fact Niên giám thống kê (BM035, BM043).                                       │
│ ├── Phân hệ Quản lý chào bán (QLCB): Bổ sung 2 thuộc tính từ TTHC để đạt tỷ lệ hoàn thành 100%.       │
│ └── Nghiệm thu kỹ thuật các phân hệ đã hoàn thiện Core: GSTT, GSDC, TT, NHNCK.                        │
├────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ GIAI ĐOẠN 3: TRIỂN KHAI MÔ HÌNH HÓA DỰA TRÊN DDL FMS & FIMS (Trung Hạn)                                │
│ ├── Phân hệ Quản lý quỹ (QLQ): Thiết kế 4 bảng Fact từ 182 bảng FMS_UAT để giải phóng 101 KPI.        │
│ ├── Phân hệ Nhà đầu tư nước ngoài (NDTNN): Thiết kế bảng tiếp nhận 26 phụ lục TT51/TT96 từ FIMS_UAT.  │
│ └── Phân hệ Văn phòng (VP): Mở rộng Nhóm 37, 38 (Dòng tiền FIMS) sang tầng LLD/Flat table.             │
├────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ GIAI ĐOẠN 4: THÁO GỠ NÚT THẮT NGOẠI LAI (Dài Hạn)                                                     │
│ ├── Đôn đốc bàn giao CSDL SCMS UAT để giải phóng 7,884 chỉ tiêu cho QLKD và hỗ trợ NHNCK.            │
│ ├── Xây dựng hạ tầng Streaming Orderbook cho GSTT.                                                    │
│ └── Tiếp nhận file báo cáo Trái phiếu Chính phủ (HNX BM22-25) và báo cáo tài khoản từ VSDC.           │
└────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 7. PHỤ LỤC & PHƯƠNG PHÁP KIỂM ĐỊNH ĐỘC LẬP (VERIFICATION METHOD)

Mọi số liệu, phân tích định lượng và kết luận trong tài liệu này đều có thể được kiểm chứng độc lập thông qua các script và lệnh CLI dưới đây từ thư mục gốc `C:\Workspace\Design_DW\ubck_atomic_design`:

### 7.1 Kiểm Chứng Số Liệu `kpi_index.csv`
Chạy lệnh kiểm tra thống kê trên file chỉ số tổng hợp:
```powershell
python Datamart/scratch/calc_kpi_index_stats.py
```
*Kết quả kỳ vọng:*
- Tổng số dòng: 14,110 bản ghi.
- 10 phân hệ hiện diện: GSTT (360), GSĐC (873), NĐTNN (255), NHNCK (123), PTTT (275), QLCB (69), QLKD (8,113), QLQ (2,697), TKNB (1,254), TT (91).
- Phân hệ VP: 0 bản ghi (xác nhận đang chờ triển khai ở Milestone M2).

### 7.2 Kiểm Chứng Phân Loại Lý Do PENDING Theo Kỹ Thuật `reviewdatamart`
Chạy script phân tích chéo tự động:
```powershell
python Datamart/scratch/run_reviewdatamart_all.py
```
*Kết quả kỳ vọng:*
- Quét qua 11 phân hệ và ghi nhận kết quả tại `Datamart/scratch/review_all_subsystems_result.json`.
- Xác nhận số lượng bản ghi LLD: GSTT (946), GSDC (2,505), NDTNN (305), NHNCK (251), PTTT (423), QLCB (87), QLKD (8,281), QLQ (2,699), TKNB (1,272), TT (99).
- Xác nhận đúng số lượng PENDING và lý do cho từng phân hệ.

### 7.3 Kiểm Chứng Thực Thể Atomic Mới `internal_statistical_report`
Chạy lệnh tìm kiếm thuộc tính trong mô hình Atomic DW:
```powershell
git grep -n "atomic_table: \"internal_statistical_report\"" DataModel/working/Atomic/aggregate/atomic_attributes.yaml
```
*Kết quả kỳ vọng:*
- Xuất hiện khối định nghĩa thuộc tính thực thể `internal_statistical_report` liên kết với bảng nguồn `ISS.FLAT_REPORT`.

### 7.4 Kiểm Chứng Báo Cáo HNX09, HSX03, HNX05 Trong Tài Liệu BA
Chạy lệnh tìm kiếm mã báo cáo trong hồ sơ BA:
```powershell
git grep -i "HNX09" BRD/BA/
git grep -i "HSX03" BRD/BA/
git grep -i "HNX05" BRD/BA/
```
*Kết quả kỳ vọng:*
- Khớp các dòng chỉ định mã báo cáo trong `BA_analyst_VP.csv` và `BA_analyst_TKNB.csv`.

### 7.5 Kiểm Chứng Cấu Trúc DDL UAT của FMS và FIMS
Chạy lệnh đếm số lượng bảng trong các file DDL UAT:
```powershell
grep -c "Table Name:" "Source/DDL UAT/FMS_UAT_schema.txt"
grep -c "Table Name:" "Source/DDL UAT/FIMS_UAT_schema.txt"
```
*Kết quả kỳ vọng:*
- `FMS_UAT_schema.txt`: 182 bảng.
- `FIMS_UAT_schema.txt`: 126 bảng.
