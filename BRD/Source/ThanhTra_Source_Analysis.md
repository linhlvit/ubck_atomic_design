# Khảo sát nguồn và ánh xạ Atomic — Phân hệ Thanh Tra

**Phân hệ:** Thanh Tra (Phục vụ công tác thanh tra chứng khoán)  
**Mục đích:** Tài liệu tham chiếu cho thiết kế Atomic layer — tổng hợp nghiệp vụ nguồn, quan hệ bảng, và ánh xạ Atomic entity theo từng nhóm chức năng.  
**Nguồn tài liệu:**
- Đặc tả yêu cầu: `New_UBCKNN_Dac_ta_yeu_cau_ThanhTra_18_03_2026.docx`
- Thiết kế CSDL: `New_UBCKNN_Thiet_ke_co_so_du_lieu_ThanhTra_20_03_2026.docx`
- HLD Overview: `ThanhTra_HLD_Overview.md`

**Tổng quan:** 56 bảng nguồn → 33 Atomic entities (30 mới + 2 reuse + 1 Geographic Area shared) · 13 Classification Value · 2 Geographic Area shared · 8 Out-of-scope (SYS_*)

---

## Quy ước cột Ánh xạ Atomic

| Ký hiệu | Ý nghĩa |
|---|---|
| 🟢 Tên entity | Atomic entity được thiết kế |
| 🟢 `CV: CODE` | Classification Value (danh mục mã hóa) |
| 🟢 Geographic Area *(shared)* | Geographic Area dùng chung |
| 🔴 (Out of scope) *lý do* | Ngoài scope Atomic |

---

## Mục lục

- [B.1 — Hoạt động thanh tra - kiểm tra](#b1--hoạt-động-thanh-tra---kiểm-tra)
  - [B.1.1 Truy vấn thông tin đối tượng TT/KT](#b11-truy-vấn-thông-tin-đối-tượng-ttkt)
  - [B.1.2 Thanh tra](#b12-thanh-tra)
  - [B.1.3 Kiểm tra](#b13-kiểm-tra)
  - [B.1.4 Báo cáo thanh tra - kiểm tra](#b14-báo-cáo-thanh-tra---kiểm-tra)
- [B.2 — Xử lý vi phạm hành chính](#b2--xử-lý-vi-phạm-hành-chính)
  - [B.2.1 Truy vấn thông tin đối tượng vi phạm](#b21-truy-vấn-thông-tin-đối-tượng-vi-phạm)
  - [B.2.2 Xử lý VPHC](#b22-xử-lý-vphc)
  - [B.2.3 Báo cáo xử lý VPHC](#b23-báo-cáo-xử-lý-vphc)
- [B.3 — Tiếp công dân, xử lý đơn thư](#b3--tiếp-công-dân-xử-lý-đơn-thư)
  - [B.3.1 Quản lý thông tin tiếp công dân](#b31-quản-lý-thông-tin-tiếp-công-dân)
  - [B.3.2 Quản lý thông tin xử lý đơn thư](#b32-quản-lý-thông-tin-xử-lý-đơn-thư)
  - [B.3.3 Báo cáo TCD, xử lý đơn thư](#b33-báo-cáo-tcd-xử-lý-đơn-thư)
- [B.4 — Phòng chống tham nhũng, tiêu cực](#b4--phòng-chống-tham-nhũng-tiêu-cực)
  - [B.4.1 Quản lý văn bản chỉ đạo, triển khai PCTN](#b41-quản-lý-văn-bản-chỉ-đạo-triển-khai-pctn)
  - [B.4.2 Báo cáo PCTN](#b42-báo-cáo-pctn)
- [B.5 — Phòng chống rửa tiền, tài trợ khủng bố](#b5--phòng-chống-rửa-tiền-tài-trợ-khủng-bố)
  - [B.5.1 Quản lý văn bản chỉ đạo, triển khai PCRT](#b51-quản-lý-văn-bản-chỉ-đạo-triển-khai-pcrt)
  - [B.5.2 Báo cáo PCRT](#b52-báo-cáo-pcrt)
- [B.6 — Biện pháp bảo đảm an ninh, an toàn TTCK](#b6--biện-pháp-bảo-đảm-an-ninh-an-toàn-ttck)
- [B.7 — Tiện ích](#b7--tiện-ích)
- [B.8 — Quản trị phân hệ](#b8--quản-trị-phân-hệ)
- [Phụ lục: Danh mục dùng chung](#phụ-lục-danh-mục-dùng-chung)

---

## B.1 — Hoạt động thanh tra - kiểm tra

Nhóm chức năng chính của phân hệ, bao gồm toàn bộ quy trình quản lý kế hoạch thanh tra/kiểm tra hằng năm, hồ sơ đoàn thanh tra/kiểm tra, kết luận thanh tra, xử lý sau thanh tra, và các báo cáo thống kê. Dữ liệu nghiệp vụ tập trung ở nhóm bảng TT_*, do Thanh tra viên, Chuyên viên và Lãnh đạo Thanh tra thao tác.

### B.1.1 Truy vấn thông tin đối tượng TT/KT

**Nghiệp vụ:** Cho phép cán bộ Thanh tra tra cứu tổng hợp thông tin về các đối tượng thanh tra, kiểm tra (CTĐC, CTCK, CT QLQ, đối tượng khác) từ CSDL tập trung UBCKNN. Phục vụ lập kế hoạch, chuẩn bị thanh tra, và rà soát xác minh trong xử lý VPHC. Vai trò: CV, TTV, CTT/PCTT.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `DM_CONG_TY_DC` | Công ty đại chúng | 🟢 Public Company |
| `DM_CONG_TY_CK` | Công ty chứng khoán | 🟢 Securities Company *(shared — bổ sung source)* |
| `DM_CONG_TY_QLQ` | Công ty QLQ và Quỹ ĐT | 🟢 Fund Management Company *(shared — bổ sung source)* |
| `DM_DOI_TUONG_KHAC` | Đối tượng thanh tra khác (cá nhân/tổ chức) | 🟢 Inspection Subject Other Party |

### B.1.2 Thanh tra

**Nghiệp vụ:** Quản lý toàn bộ vòng đời thanh tra: lập kế hoạch thanh tra hằng năm → tạo quyết định thanh tra → quản lý hồ sơ đoàn thanh tra → phân công cán bộ → kết luận thanh tra → xử lý sau thanh tra → công bố xử phạt. Dữ liệu bao gồm thanh tra định kỳ theo kế hoạch và thanh tra đột xuất. Vai trò: CV, TTV, LĐTT.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `TT_KE_HOACH` | Kế hoạch thanh tra hằng năm | 🟢 Inspection Annual Plan |
| ├── `TT_KE_HOACH_DOI_TUONG` | Đối tượng trong kế hoạch | 🟢 Inspection Annual Plan Subject |
| ├── `TT_KE_HOACH_VAN_BAN` | Văn bản kèm kế hoạch | 🟢 Inspection Annual Plan Document Attachment |
| └── `TT_QUYET_DINH` | Quyết định thanh tra | 🟢 Inspection Decision |
| &emsp;&emsp;├── `TT_QUYET_DINH_DOI_TUONG` | Đối tượng trong quyết định | 🟢 Inspection Decision Subject |
| &emsp;&emsp;├── `TT_QUYET_DINH_THANH_PHAN` | Thành phần đoàn thanh tra | 🟢 Inspection Decision Team Member |
| &emsp;&emsp;├── `TT_QUYET_DINH_VAN_BAN` | Văn bản kèm quyết định | 🟢 Inspection Decision Document Attachment |
| &emsp;&emsp;└── `TT_HO_SO` | Hồ sơ thanh tra | 🟢 Inspection Case |
| &emsp;&emsp;&emsp;&emsp;├── `TT_HO_SO_CAN_BO` | Phân công cán bộ xử lý | 🟢 Inspection Case Officer Assignment |
| &emsp;&emsp;&emsp;&emsp;├── `TT_HO_SO_VAN_BAN` | Văn bản đính kèm hồ sơ | 🟢 Inspection Case Document Attachment |
| &emsp;&emsp;&emsp;&emsp;└── `TT_KET_LUAN` | Kết luận thanh tra / văn bản xử lý sau TT | 🟢 Inspection Case Conclusion |
| &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;└── `TT_CONG_BO_XU_PHAT` | Công bố quyết định xử phạt | 🟢 Inspection Penalty Announcement |
| *Danh mục tham chiếu:* | `DM_CAN_BO`, `DM_CAN_CU_THANH_TRA`, `DM_MANG_NGHIEP_VU`, `DM_TRANG_THAI_HO_SO`, `DM_MUC_DO_BAO_MAT`, `DM_LINH_VUC`, `DM_HANH_VI_VI_PHAM`, `DM_HINH_THUC_PHAT`, `DM_HINH_THUC_VAN_BAN` | *(xem Phụ lục)* |

### B.1.3 Kiểm tra

**Nghiệp vụ:** Quản lý kế hoạch kiểm tra chuyên đề hằng năm, hồ sơ đoàn kiểm tra (do Thanh tra hoặc đơn vị giám sát chủ trì), thông báo kết quả kiểm tra, biên bản VPHC gắn đoàn kiểm tra. Cấu trúc dữ liệu dùng chung với Thanh tra (nhóm bảng TT_*), phân biệt bằng trường `LOAI_HINH` = `KIEM_TRA`. Vai trò: CV, TTV, LĐTT, ĐVGS.

**Quan hệ dữ liệu:** Cùng cấu trúc bảng với B.1.2 *(xem B.1.2)* — các bảng `TT_KE_HOACH`, `TT_QUYET_DINH`, `TT_HO_SO` và bảng con phân biệt nghiệp vụ kiểm tra qua cột `LOAI_HINH`/`LOAI_KE_HOACH` = `KIEM_TRA`. Atomic entity giữ nguyên — 1 entity phục vụ cả thanh tra và kiểm tra.

### B.1.4 Báo cáo thanh tra - kiểm tra

**Nghiệp vụ:** Quản lý báo cáo hoạt động kiểm tra của các đơn vị giám sát, đề cương báo cáo theo TT 06/2025/TT-TTCP, báo cáo thống kê định kỳ, báo cáo đột xuất. Dữ liệu tổng hợp từ `TT_HO_SO`, `TT_KET_LUAN`; đề cương/biểu mẫu từ `DM_BIEU_MAU`. Vai trò: CV, TTV, CTT/PCTT, ĐVGS.

**Quan hệ dữ liệu:** Đọc dữ liệu từ các bảng `TT_HO_SO` *(xem B.1.2)*, `TT_KET_LUAN` *(xem B.1.2)* để tổng hợp thống kê. Không tạo dữ liệu nghiệp vụ mới — đề cương báo cáo lưu qua `DM_BIEU_MAU` *(xem Phụ lục)*.

---

## B.2 — Xử lý vi phạm hành chính

Nhóm chức năng quản lý toàn bộ quy trình xử lý vi phạm hành chính trong lĩnh vực chứng khoán, từ tiếp nhận hồ sơ vi phạm đến lập biên bản, ra quyết định xử phạt, theo dõi thi hành, và xử lý VPHC trên môi trường điện tử. Dữ liệu nghiệp vụ tập trung ở nhóm bảng GS_*.

### B.2.1 Truy vấn thông tin đối tượng vi phạm

**Nghiệp vụ:** Tra cứu tổng hợp thông tin đối tượng vi phạm (cá nhân, tổ chức) từ nhiều nguồn: CSDL tập trung UBCKNN, CSDL quốc gia về dân cư (C06), cơ quan Thuế. Phục vụ rà soát, xác minh danh tính trong quá trình xử lý VPHC. Phân hệ Thanh Tra không lưu trữ dữ liệu gốc — chỉ truy vấn. Vai trò: CV, TTV, CTT/PCTT.

**Quan hệ dữ liệu:** Truy vấn từ các bảng đối tượng *(xem B.1.1)*: `DM_CONG_TY_CK`, `DM_CONG_TY_QLQ`, `DM_CONG_TY_DC`, `DM_DOI_TUONG_KHAC`. Ngoài ra kết nối CSDL quốc gia về dân cư và cơ quan Thuế (ngoài phạm vi CSDL phân hệ).

### B.2.2 Xử lý VPHC

**Nghiệp vụ:** Quản lý hồ sơ xử lý VPHC (khởi tạo, tiếp nhận văn bản vi phạm từ các đơn vị giám sát), biên bản VPHC (do Thanh tra hoặc ĐVGS lập, hỗ trợ cả giấy và điện tử), quyết định xử phạt VPHC (tạo, phê duyệt, ký số, ban hành), theo dõi thi hành (nộp phạt, cưỡng chế), tạo công văn theo biểu mẫu, và xử lý VPHC trên môi trường điện tử (ký số, gửi đối tượng qua website, xác nhận nhận văn bản). Vai trò: CV, TTV, LĐTT, ĐVGS, Văn thư.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `GS_HO_SO` | Hồ sơ xử lý vi phạm từ giám sát | 🟢 Surveillance Enforcement Case |
| ├── `GS_HO_SO_VAN_BAN` | Văn bản đính kèm hồ sơ | 🟢 Surveillance Case Document Attachment |
| ├── `GS_VAN_BAN_XU_LY` | Văn bản xử lý (QĐ xử phạt, BB VPHC, CV nhắc nhở) | 🟢 Surveillance Enforcement Decision |
| │&emsp;&emsp;└── `GS_VAN_BAN_XU_LY_FILE` | File đính kèm văn bản xử lý | 🟢 Surveillance Enforcement Decision File Attachment |
| └── `GS_CONG_BO_XU_PHAT` | Công bố QĐ xử phạt lên cổng TTĐT | 🟢 Surveillance Penalty Announcement |
| *Danh mục tham chiếu:* | `DM_CAN_BO`, `DM_MANG_NGHIEP_VU`, `DM_HANH_VI_VI_PHAM`, `DM_HINH_THUC_PHAT`, `DM_TRANG_THAI_HO_SO`, `DM_BIEU_MAU`, `DM_HINH_THUC_VAN_BAN`, `DM_MUC_DO_BAO_MAT` | *(xem Phụ lục)* |

### B.2.3 Báo cáo xử lý VPHC

**Nghiệp vụ:** Quản lý đề cương báo cáo thi hành pháp luật VPHC, báo cáo thống kê định kỳ, báo cáo đột xuất về xử lý VPHC. Vai trò: CV, TTV, CTT/PCTT.

**Quan hệ dữ liệu:** Đọc dữ liệu từ `GS_HO_SO`, `GS_VAN_BAN_XU_LY` *(xem B.2.2)* để tổng hợp thống kê. Đề cương báo cáo sử dụng `DM_BIEU_MAU` *(xem Phụ lục)*.

---

## B.3 — Tiếp công dân, xử lý đơn thư

Nhóm chức năng quản lý thông tin tiếp công dân và xử lý đơn thư khiếu nại, tố cáo, phản ánh kiến nghị tại Thanh tra UBCKNN. Dữ liệu nghiệp vụ tập trung ở nhóm bảng DT_*. Luồng dữ liệu hoàn toàn độc lập với luồng TT_ và GS_.

### B.3.1 Quản lý thông tin tiếp công dân

**Nghiệp vụ:** Tạo, quản lý vụ việc tiếp công dân, đính kèm văn bản, cập nhật trạng thái xử lý, khai thác báo cáo tổng hợp. Vai trò: TTV, CV, CTT/PCTT.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `DT_DON_THU` | Thông tin tiếp nhận và phân loại đơn thư KNTC | 🟢 Complaint Petition |
| *Danh mục tham chiếu:* | `DM_TINH_THANH`, `DM_QUOC_GIA` | *(xem Phụ lục)* |

### B.3.2 Quản lý thông tin xử lý đơn thư

**Nghiệp vụ:** Nhập đơn thư (thủ công hoặc import từ Excel), phân loại, tạo hồ sơ giải quyết, theo dõi xử lý, tạo phiếu/công văn theo biểu mẫu (phiếu chuyển đơn, công văn trả lời, thông báo thụ lý/không thụ lý…), kết luận giải quyết, xử phạt nếu có vi phạm. Vai trò: Cán bộ Tổ đơn thư, CTT/PCTT.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `DT_DON_THU` | Đơn thư KNTC, phản ánh kiến nghị | 🟢 Complaint Petition *(xem B.3.1)* |
| └── `DT_HO_SO` | Hồ sơ giải quyết đơn thư | 🟢 Complaint Processing Case |
| &emsp;&emsp;├── `DT_HO_SO_VAN_BAN` | Văn bản đính kèm hồ sơ | 🟢 Complaint Processing Case Document Attachment |
| &emsp;&emsp;├── `DT_KET_LUAN` | Kết luận giải quyết đơn thư | 🟢 Complaint Processing Conclusion |
| &emsp;&emsp;├── `DT_VAN_BAN_XU_LY` | Văn bản xử lý (QĐ xử phạt, BB VPHC) | 🟢 Complaint Enforcement Decision |
| &emsp;&emsp;│&emsp;&emsp;└── `DT_CONG_BO_XU_PHAT` | Công bố QĐ xử phạt lên cổng TTĐT | 🟢 Complaint Penalty Announcement |
| *Danh mục tham chiếu:* | `DM_CAN_BO`, `DM_TRANG_THAI_HO_SO`, `DM_BIEU_MAU`, `DM_TINH_THANH` | *(xem Phụ lục)* |

### B.3.3 Báo cáo TCD, xử lý đơn thư

**Nghiệp vụ:** Quản lý đề cương báo cáo tiếp công dân, giải quyết KN-TC theo TT 06/2025/TT-TTCP, khai thác biểu báo cáo định kỳ. Vai trò: Cán bộ Tổ Tổng hợp, CTT/PCTT.

**Quan hệ dữ liệu:** Đọc dữ liệu từ `DT_DON_THU` *(xem B.3.1)*, `DT_HO_SO`, `DT_KET_LUAN` *(xem B.3.2)* để tổng hợp thống kê. Đề cương báo cáo sử dụng `DM_BIEU_MAU` *(xem Phụ lục)*.

---

## B.4 — Phòng chống tham nhũng, tiêu cực

Nhóm chức năng quản lý hoạt động phòng chống tham nhũng tại UBCKNN gồm hai mảng: (1) triển khai công tác PCTN (văn bản chỉ đạo, công văn hướng dẫn) và (2) tổng hợp báo cáo định kỳ/đột xuất theo TT 06/2025/TT-TTCP. Dữ liệu tập trung ở bảng `PCTN_BAO_CAO`, chỉ lưu thông tin không hạn chế tiếp cận.

### B.4.1 Quản lý văn bản chỉ đạo, triển khai PCTN

**Nghiệp vụ:** Lưu trữ các văn bản chỉ đạo, triển khai công tác PCTN (tờ trình, công văn hướng dẫn, kế hoạch). Vai trò: CV, TTV.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `PCTN_BAO_CAO` | Báo cáo phòng chống tham nhũng | 🟢 Anti-Corruption Report |
| *Danh mục tham chiếu:* | `DM_CAN_BO` | *(xem Phụ lục)* |

### B.4.2 Báo cáo PCTN

**Nghiệp vụ:** Quản lý đề cương báo cáo (Mẫu số 03), báo cáo định kỳ (biểu số liệu theo TT 06/2025), báo cáo đột xuất về PCTN. Dữ liệu báo cáo bao gồm dữ liệu trong kỳ và dữ liệu lũy kế từ đầu năm. Vai trò: CV, TTV, CTT/PCTT.

**Quan hệ dữ liệu:** Sử dụng `PCTN_BAO_CAO` *(xem B.4.1)* để lưu trữ báo cáo. Đề cương/biểu mẫu từ `DM_BIEU_MAU` *(xem Phụ lục)*.

---

## B.5 — Phòng chống rửa tiền, tài trợ khủng bố

Nhóm chức năng quản lý công tác phòng chống rửa tiền, tài trợ khủng bố, tài trợ phổ biến vũ khí hủy diệt hàng loạt trong lĩnh vực chứng khoán. Gồm quản lý hồ sơ PCRT, văn bản xử lý vi phạm, và báo cáo định kỳ/theo yêu cầu. Dữ liệu nghiệp vụ tập trung ở nhóm bảng PCRT_*.

### B.5.1 Quản lý văn bản chỉ đạo, triển khai PCRT

**Nghiệp vụ:** Lưu trữ văn bản chỉ đạo, tờ trình lãnh đạo, hồ sơ PCRT, văn bản xử lý vi phạm (QĐ xử phạt, BB VPHC). Vai trò: CV, TTV, CTT/PCTT.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `PCRT_HO_SO` | Hồ sơ phòng chống rửa tiền | 🟢 AML Enforcement Case |
| ├── `PCRT_HO_SO_VAN_BAN` | Văn bản đính kèm hồ sơ PCRT | 🟢 AML Case Document Attachment |
| └── `PCRT_VAN_BAN_XU_LY` | Văn bản xử lý vi phạm PCRT | 🟢 AML Enforcement Decision |
| *Danh mục tham chiếu:* | `DM_CAN_BO`, `DM_MANG_NGHIEP_VU`, `DM_TRANG_THAI_HO_SO` | *(xem Phụ lục)* |

### B.5.2 Báo cáo PCRT

**Nghiệp vụ:** Quản lý báo cáo định kỳ và theo yêu cầu về PCRT, thống kê xử phạt PCRT (filter trên QĐ xử phạt có đánh dấu "Có nội dung về phòng chống rửa tiền"). Vai trò: CV, TTV, CTT/PCTT.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `PCRT_BAO_CAO` | Báo cáo phòng chống rửa tiền | 🟢 AML Periodic Report |
| *Đọc thêm:* | `PCRT_HO_SO` *(xem B.5.1)*, `GS_VAN_BAN_XU_LY` *(xem B.2.2)* để thống kê xử phạt PCRT | |

---

## B.6 — Biện pháp bảo đảm an ninh, an toàn TTCK

Nhóm chức năng quản lý việc áp dụng các biện pháp phòng ngừa, ngăn chặn vi phạm pháp luật về chứng khoán theo Nghị định 155/2020/NĐ-CP: cấm đảm nhiệm chức vụ, cấm giao dịch, cấm hoạt động chứng khoán, phong tỏa tài khoản. Dữ liệu sử dụng chung nhóm bảng GS_* (cùng cấu trúc với xử lý VPHC nhưng nghiệp vụ khác).

**Nghiệp vụ:** Tạo QĐ áp dụng biện pháp phòng ngừa, gửi QĐ đến đối tượng/tổ chức liên quan (VSDC, Sở GDCK, CTCK), ghi nhận báo cáo thực hiện, theo dõi tình hình. Vai trò: CV, TTV, LĐTT, Lãnh đạo UBCKNN.

**Quan hệ dữ liệu:** Sử dụng các bảng `GS_HO_SO`, `GS_VAN_BAN_XU_LY`, `GS_VAN_BAN_XU_LY_FILE`, `GS_CONG_BO_XU_PHAT` *(xem B.2.2)* — phân biệt nghiệp vụ "biện pháp bảo đảm an ninh" qua nội dung/loại quyết định. Danh mục tham chiếu: `DM_CAN_BO`, `DM_MANG_NGHIEP_VU` *(xem Phụ lục)*.

---

## B.7 — Tiện ích

Nhóm chức năng hỗ trợ: Dashboard tổng quan tình hình xử lý, thông báo nhắc việc tự động khi đến/quá hạn, gửi thông báo chủ động đến đối tượng qua cổng báo cáo trực tuyến.

**Nghiệp vụ:** Dashboard đọc tổng hợp từ `TT_HO_SO`, `GS_HO_SO`, `DT_DON_THU`, `DT_HO_SO` để hiển thị chỉ số. Nhắc việc tự động dựa trên ngày hạn trong các bảng hồ sơ. Vai trò: CV, TTV, CTT/PCTT.

**Quan hệ dữ liệu:** Đọc từ các bảng đã mô tả: `TT_HO_SO` *(xem B.1.2)*, `GS_HO_SO` *(xem B.2.2)*, `DT_DON_THU` *(xem B.3.1)*, `DT_HO_SO` *(xem B.3.2)*. Không tạo dữ liệu nghiệp vụ mới.

---

## B.8 — Quản trị phân hệ

Nhóm chức năng quản trị hệ thống: quản lý danh mục dùng riêng (hành vi vi phạm, hình thức xử phạt), cấu hình biểu mẫu, quản lý người dùng, nhật ký, sao lưu. Vai trò: Quản trị phân hệ (QTPH).

**Nghiệp vụ:** Cấu hình và duy trì các bảng danh mục phục vụ nghiệp vụ, quản lý tài khoản người dùng và phân quyền, ghi nhật ký hoạt động, cấu hình sao lưu. Bảng danh mục nghiệp vụ đã mô tả tại Phụ lục. Nhóm bảng SYS_* dưới đây phục vụ quản trị hệ thống.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `SYS_NGUOI_DUNG` | Tài khoản người dùng hệ thống | 🔴 (Out of scope) *Operational/system data* |
| ├── `SYS_NGUOI_DUNG_NHOM` | Quan hệ người dùng – nhóm quyền | 🔴 (Out of scope) *Operational/system data* |
| ├── `SYS_NHAT_KY` | Nhật ký hoạt động người dùng | 🔴 (Out of scope) *Audit Log nguồn* |
| `SYS_NHOM_NGUOI_DUNG` | Nhóm người dùng và phân quyền | 🔴 (Out of scope) *Operational/system data* |
| `SYS_THAM_SO` | Tham số cấu hình hệ thống | 🔴 (Out of scope) *Operational/system data* |
| `SYS_SAO_LUU` | Lịch và cấu hình sao lưu | 🔴 (Out of scope) *Operational/system data* |
| └── `SYS_NHAT_KY_SAO_LUU` | Lịch sử các lần sao lưu | 🔴 (Out of scope) *Operational/system data* |
| `SYS_VAN_BAN_PHAP_QUY` | Văn bản pháp quy tham chiếu | 🔴 (Out of scope) *Regulatory ref. — ngoài scope Atomic* |

---

## Phụ lục: Danh mục dùng chung

Các bảng DM_* được tham chiếu xuyên suốt nhiều nhóm chức năng. Phân loại: Atomic entity, Classification Value (CV), hoặc Geographic Area shared.

### A. Atomic entities — Danh mục đối tượng

| Bảng | Ý nghĩa | Sử dụng bởi | Ánh xạ Atomic |
|---|---|---|---|
| `DM_CAN_BO` | Cán bộ thanh tra UBCKNN | B.1.2, B.1.3, B.2.2, B.3.2, B.4, B.5, B.6 | 🟢 Inspection Officer |
| `DM_CONG_TY_DC` | Công ty đại chúng | B.1.1, B.2.1 | 🟢 Public Company |
| `DM_CONG_TY_CK` | Công ty chứng khoán | B.1.1, B.2.1 | 🟢 Securities Company *(shared — bổ sung source)* |
| `DM_CONG_TY_QLQ` | Công ty QLQ và Quỹ ĐT | B.1.1, B.2.1 | 🟢 Fund Management Company *(shared — bổ sung source)* |
| `DM_DOI_TUONG_KHAC` | Đối tượng thanh tra khác | B.1.1, B.2.1 | 🟢 Inspection Subject Other Party |

### B. Classification Values

| Bảng | Ý nghĩa | Sử dụng bởi | Ánh xạ Atomic |
|---|---|---|---|
| `DM_BIEU_MAU` | Biểu mẫu văn bản | B.1.4, B.2.2, B.2.3, B.3.2, B.3.3, B.4.2, B.5.2, B.8 | 🟢 `CV: TT_FORM_TYPE` |
| `DM_CHUC_VU` | Chức vụ cán bộ | B.8 | 🟢 `CV: TT_POSITION_TYPE` |
| `DM_DON_VI` | Đơn vị (cấu trúc cây) | B.1.2, B.8 | 🟢 `CV: TT_UNIT_TYPE` |
| `DM_HO_SO` | Loại hồ sơ | B.8 | 🟢 `CV: TT_CASE_TYPE` |
| `DM_TRANG_THAI_HO_SO` | Trạng thái hồ sơ | B.1.2, B.1.3, B.2.2, B.3.2, B.5.1 | 🟢 `CV: TT_CASE_STATUS` |
| `DM_LINH_VUC` | Lĩnh vực chứng khoán | B.1.2, B.1.3 | 🟢 `CV: TT_INSPECTION_SECTOR` |
| `DM_HANH_VI_VI_PHAM` | Hành vi vi phạm | B.1.2, B.2.2, B.8 | 🟢 `CV: TT_VIOLATION_TYPE` |
| `DM_HINH_THUC_PHAT` | Hình thức phạt | B.1.2, B.2.2, B.8 | 🟢 `CV: TT_PENALTY_TYPE` |
| `DM_HINH_THUC_VAN_BAN` | Hình thức văn bản | B.1.2, B.2.2 | 🟢 `CV: TT_DOCUMENT_FORM_TYPE` |
| `DM_MANG_NGHIEP_VU` | Mảng nghiệp vụ | B.2.2, B.5.1, B.6 | 🟢 `CV: TT_BUSINESS_SECTOR` |
| `DM_MUC_DO_BAO_MAT` | Mức độ bảo mật | B.1.2, B.2.2 | 🟢 `CV: TT_SECURITY_LEVEL` |
| `DM_CAN_CU_THANH_TRA` | Căn cứ thanh tra | B.1.2, B.1.3 | 🟢 `CV: TT_LEGAL_BASIS_TYPE` |
| `DM_DANH_MUC_KHAC` | Danh mục khác (dùng chung) | B.8 | 🟢 `CV: TT_MISC_CATEGORY` |

### C. Geographic Area (shared)

| Bảng | Ý nghĩa | Sử dụng bởi | Ánh xạ Atomic |
|---|---|---|---|
| `DM_QUOC_GIA` | Quốc gia (ISO 3166) | B.1.1, B.3.1 | 🟢 Geographic Area (COUNTRY) *(shared — bổ sung source)* |
| `DM_TINH_THANH` | Tỉnh thành Việt Nam | B.3.1, B.3.2, B.8 | 🟢 Geographic Area (PROVINCE) *(shared — bổ sung source)* |
