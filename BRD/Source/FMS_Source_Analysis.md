# Phân hệ FMS — Khảo sát nguồn và ánh xạ Silver

## Thông tin chung

| Mục | Nội dung |
|---|---|
| **Phân hệ** | FMS — Quản lý giám sát công ty Quản lý Quỹ và Quỹ đầu tư chứng khoán |
| **Mục đích** | Tài liệu tham chiếu cho thiết kế Silver layer — tổng hợp nghiệp vụ nguồn, quan hệ bảng, và ánh xạ Silver entity theo từng nhóm chức năng |
| **Nguồn tài liệu** | Thiết kế CSDL FMS (20/03/2026), Phụ lục 02 DW, FMS_HLD_Overview.md |
| **Đặc tả yêu cầu** | ⚠️ Chưa có tài liệu đặc tả yêu cầu riêng cho FMS. Nghiệp vụ suy luận từ thiết kế CSDL và ngữ cảnh tích hợp NHNCK. |
| **HLD / Silver mapping** | ✅ Có — FMS_HLD_Overview.md (Tier 1–4). |
| **Tổng số bảng** | 79 |

## Bảng quy ước

| Ký hiệu | Ý nghĩa |
|---|---|
| 🟢 *Tên entity* | Silver entity được thiết kế |
| 🟢 *Tên entity* *(shared — bổ sung source)* | Silver entity dùng chung nhiều source |
| 🟢 `CV: CODE` | Classification Value (danh mục mã hóa) |
| 🟢 ↳ denormalize vào *Entity* | Junction table flatten vào entity chính |
| 🔴 (Out of scope) *lý do* | Ngoài scope Silver |

## Mục lục

- [FMS.1 — Quản trị phân hệ](#fms1--quản-trị-phân-hệ)
- [FMS.2 — Danh mục dùng riêng](#fms2--danh-mục-dùng-riêng)
- [FMS.3 — Thông tin thành viên — Công ty QLQ](#fms3--thông-tin-thành-viên--công-ty-qlq)
- [FMS.4 — Quỹ đầu tư chứng khoán](#fms4--quỹ-đầu-tư-chứng-khoán)
- [FMS.5 — Quản lý báo cáo](#fms5--quản-lý-báo-cáo)
- [FMS.6 — Đánh giá xếp loại và cảnh báo](#fms6--đánh-giá-xếp-loại-và-cảnh-báo)
- [FMS.7 — Tiện ích và hệ thống](#fms7--tiện-ích-và-hệ-thống)
- [Phụ lục: Danh mục dùng chung](#phụ-lục-danh-mục-dùng-chung)

---

## FMS.1 — Quản trị phân hệ

Nhóm chức năng quản trị hạ tầng hệ thống FMS: quản lý người dùng, phân quyền chức năng theo nhóm quyền và menu, quản lý phiên đăng nhập, lịch làm việc, và chứng thư số. Toàn bộ nhóm nằm ngoài scope Silver (hạ tầng IT / isolated).

### FMS.1.1 — Quản lý người dùng và phiên đăng nhập

**Nghiệp vụ:** Quản lý danh sách người dùng hệ thống FMS (cán bộ UBCKNN, quản trị viên). Hệ thống cấp tài khoản, quản lý trạng thái, theo dõi phiên đăng nhập và token xác thực.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `USERS` | Người dùng hệ thống | 🔴 (Out of scope) *Hạ tầng IT* |
| ├── `REFRESHTOKEN` | Phiên làm việc (token đăng nhập) | 🔴 (Out of scope) *Hạ tầng IT* |
| └── `USERSESSIONS` | Quản lý tài khoản đang truy cập | 🔴 (Out of scope) *Hạ tầng IT* |

### FMS.1.2 — Phân quyền chức năng

**Nghiệp vụ:** Phân quyền chức năng theo mô hình RBAC. Mỗi nhóm quyền (ROLES) được gán danh sách menu (ROLESMENUS), người dùng được phân quyền thêm ở mức cá nhân (USERSMENUS). Phân quyền báo cáo đầu ra (USERRPTO).

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `ROLES` | Nhóm quyền chức năng | 🔴 (Out of scope) *Hạ tầng IT* |
| ├── `ROLESMENUS` | Phân quyền menu → nhóm quyền | 🔴 (Out of scope) *Hạ tầng IT* |
| `MENUS` | Danh mục quyền chức năng (menu) | 🔴 (Out of scope) *Hạ tầng IT* |
| ├── `USERSMENUS` | Phân quyền chức năng → người dùng | 🔴 (Out of scope) *Hạ tầng IT* |
| └── `USERRPTO` | Phân quyền người dùng UBCK với BC đầu ra | 🔴 (Out of scope) *Chưa có cột* |

### FMS.1.3 — Lịch hệ thống và chứng thư số

**Nghiệp vụ:** Quản lý lịch làm việc/lịch nghỉ làm căn cứ tính thời hạn nộp báo cáo. Quản lý chứng thư số phục vụ xác thực giao dịch điện tử.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `CALENDAR` | Lịch làm việc và lịch nghỉ | 🔴 (Out of scope) *Isolated — không FK* |
| `CERTFCATE` | Chứng thư số thành viên thị trường | 🔴 (Out of scope) *Isolated — không FK* |

---

## FMS.2 — Danh mục dùng riêng

Nhóm danh mục master data riêng của phân hệ FMS. Phần lớn được thiết kế thành Classification Value trên Silver; riêng NATIONAL → Silver entity Geographic Area (shared).

### FMS.2.1 — Danh mục tham chiếu

**Nghiệp vụ:** Các bảng danh mục tham chiếu xuyên suốt phân hệ FMS.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `BUSINESS` | Danh mục ngành nghề kinh doanh | 🟢 `CV: FMS_BUSINESS_TYPE` |
| `JOBTYPE` | Danh sách loại chức vụ | 🟢 `CV: FMS_JOB_TYPE` |
| `LOCATION` | Danh sách tỉnh/thành phố | *(Chưa phân loại trong HLD)* |
| `NATIONAL` | Danh sách quốc gia/quốc tịch | 🟢 Geographic Area *(shared)* |
| `PARVALUE` | Danh sách mệnh giá cổ phần | 🔴 (Out of scope) *Orphan — không bảng nào FK đến* |
| `RELATION` | Mối quan hệ cổ đông | *(Chưa phân loại trong HLD)* |
| `STATUS` | Danh sách trạng thái hoạt động | 🟢 `CV: FMS_STATUS` |
| `STOCKHOLDERTYPE` | Danh sách loại hình NĐT/cổ đông | 🟢 `CV: FMS_STOCKHOLDER_TYPE` |

---

## FMS.3 — Thông tin thành viên — Công ty QLQ

Nhóm chức năng quản lý thông tin thành viên thị trường: công ty QLQ trong nước, chi nhánh/VPĐD, nhân sự, các bên liên quan, phân quyền dữ liệu. Vai trò: chuyên viên Ban QLQ (UBCKNN), thành viên thị trường.

### FMS.3.1 — Thông tin công ty QLQ

**Nghiệp vụ:** Quản lý hồ sơ công ty QLQ trong nước: thông tin pháp lý, giấy phép, trạng thái, ngành nghề. Lịch sử thay đổi theo cơ chế snapshot JSON (SECBUP) và audit log (SECHISTORY).

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `SECURITIES` | Danh sách công ty QLQ trong nước | 🟢 Fund Management Company |
| ├── `SECHISTORY` | Lịch sử thông tin công ty QLQ | 🔴 (Out of scope) *Audit Log nguồn* |
| │   └── `SECBUP` | Chi tiết lịch sử (snapshot JSON, cờ IsBefore) | 🔴 (Out of scope) *Snapshot nguồn* |
| ├── `SECBUSINES` | Ngành nghề kinh doanh của công ty QLQ | 🟢 ↳ denormalize vào Fund Management Company |
| └── `STAKE` | Các bên liên quan | 🔴 (Out of scope) *Chưa có cột* |
| Danh mục: `STATUS`, `BUSINESS`, `PARVALUE` | | |

### FMS.3.2 — Chi nhánh / VPĐD công ty QLQ trong nước

**Nghiệp vụ:** Quản lý danh sách chi nhánh và VPĐD của công ty QLQ trong nước. Theo dõi lịch sử thay đổi.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `SECURITIES` | Công ty QLQ cha *(xem FMS.3.1)* | 🟢 Fund Management Company |
| └── `BRANCHES` | CN/VPĐD công ty QLQ trong nước | 🟢 Fund Management Company Organization Unit |
|     └── `BRCHBUP` | Lịch sử chi tiết CN/VPĐD | 🔴 (Out of scope) *Snapshot nguồn* |

### FMS.3.3 — VPĐD / CN công ty QLQ nước ngoài tại VN

**Nghiệp vụ:** Quản lý VPĐD và chi nhánh của công ty QLQ nước ngoài hoạt động tại Việt Nam. Hoạt động độc lập trong scope giám sát UBCKNN. Bao gồm ngành nghề, nhân sự riêng, và lịch sử.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `FORBRCH` | Danh sách VPĐD/CN công ty QLQ NN tại VN | 🟢 Foreign Fund Management Organization Unit |
| ├── `FGBRBUP` | Lịch sử chi tiết VPĐD/CN QLQ NN | 🔴 (Out of scope) *Audit Log nguồn* |
| ├── `FGBUSINESS` | Ngành nghề VPĐD/CN QLQ NN | 🟢 ↳ denormalize vào Foreign Fund Management Organization Unit |
| └── `STFFGBRCH` | Nhân sự VPĐD/CN QLQ NN | 🟢 Foreign Fund Management Organization Unit Staff |
| Danh mục: `STATUS`, `BUSINESS` | | |

### FMS.3.4 — Nhân sự công ty QLQ

**Nghiệp vụ:** Quản lý nhân sự (HĐQT, BGĐ, người đại diện pháp luật, đại diện CBTT) của công ty QLQ. Lịch sử theo cơ chế snapshot JSON (TLPROBUP). Tích hợp NHNCK: cung cấp thông tin người hành nghề tại QLQ.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `SECURITIES` | Công ty QLQ cha *(xem FMS.3.1)* | 🟢 Fund Management Company |
| └── `TLProfiles` | Nhân sự công ty QLQ | 🟢 Fund Management Company Key Person |
|     ├── `TLPRHISTORY` | Lịch sử nhân sự | 🔴 (Out of scope) *Audit Log nguồn* |
|     │   └── `TLPROBUP` | Chi tiết lịch sử nhân sự (snapshot JSON) | 🔴 (Out of scope) *Snapshot nguồn* |
|     └── `STFFGBRCH` | Nhân sự kiêm nhiệm VPĐD/CN QLQ NN *(xem FMS.3.3)* | 🟢 Foreign Fund Management Organization Unit Staff |
| Danh mục: `JOBTYPE`, `NATIONAL` | | |

### FMS.3.5 — Phân quyền dữ liệu

**Nghiệp vụ:** Phân quyền dữ liệu cho chuyên viên Ban QLQ theo 3 chiều: NH LKGS, QĐT, và VPĐD/CN QLQ NN.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `DTSCOPE` | Phân quyền dữ liệu — phạm vi | 🔴 (Out of scope) *Hạ tầng IT* |
| ├── `DTSCBMN` | Phân quyền dữ liệu NH LKGS | 🔴 (Out of scope) *Hạ tầng IT* |
| ├── `DTSCFND` | Phân quyền dữ liệu QĐT | 🔴 (Out of scope) *Hạ tầng IT* |
| └── `DTSCFR` | Phân quyền VPĐD/CN QLQ NN | 🔴 (Out of scope) *Hạ tầng IT* |

---

## FMS.4 — Quỹ đầu tư chứng khoán

Nhóm chức năng quản lý quỹ đầu tư: hồ sơ quỹ, NH LKGS, đại lý, nhà đầu tư, ban đại diện, giao dịch CCQ và chuyển nhượng cổ phần. Vai trò: chuyên viên Ban QLQ, thành viên thị trường.

### FMS.4.1 — Thông tin quỹ đầu tư

**Nghiệp vụ:** Quản lý hồ sơ quỹ đầu tư chứng khoán: loại hình, vốn điều lệ, giấy phép, trạng thái. Mỗi quỹ thuộc một công ty QLQ (SecId). Lịch sử thay đổi qua FUNDHISTORY → FNDBUP.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `SECURITIES` | Công ty QLQ quản lý quỹ *(xem FMS.3.1)* | 🟢 Fund Management Company |
| └── `FUNDS` | Danh sách quỹ đầu tư chứng khoán | 🟢 Investment Fund |
|     ├── `FUNDHISTORY` | Lịch sử quỹ đầu tư | 🔴 (Out of scope) *Audit Log nguồn* |
|     │   └── `FNDBUP` | Chi tiết lịch sử quỹ | 🔴 (Out of scope) *Snapshot nguồn — chưa có cột* |
|     └── `REPRESENT` | Ban đại diện/HĐQT quỹ đầu tư (FK → TLProfiles) | 🟢 Investment Fund Representative Board Member |
| Danh mục: `STATUS` | | |

### FMS.4.2 — Ngân hàng lưu ký giám sát

**Nghiệp vụ:** Quản lý danh sách NH thực hiện lưu ký và giám sát hoạt động quỹ. Mỗi quỹ gắn nhiều NH LKGS qua bảng trung gian FNDSBMN.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `BANKMONI` | Danh sách ngân hàng lưu ký giám sát | 🟢 Custodian Bank |
| └── `FNDSBMN` | Map FUNDS ↔ BANKMONI (trung gian N-N) | 🟢 ↳ denormalize vào Investment Fund |
| Danh mục: `STATUS` | | |

### FMS.4.3 — Đại lý quỹ đầu tư

**Nghiệp vụ:** Quản lý đại lý phân phối CCQ: thông tin đại lý, loại đại lý, CN/PGD. Mỗi đại lý phân phối cho nhiều quỹ qua AGENFUNDS.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `AGENCIES` | Danh sách đại lý quỹ đầu tư | 🟢 Fund Distribution Agent |
| ├── `AGENCIESBRA` | CN/PGD của đại lý quỹ | 🟢 Fund Distribution Agent Organization Unit |
| ├── `AGENFUNDS` | Map đại lý ↔ quỹ (trung gian N-N) | 🟢 ↳ denormalize vào Investment Fund |
| `AGENCYTYPE` | Danh sách loại đại lý | 🟢 `CV: FMS_AGENCY_TYPE` |

### FMS.4.4 — Nhà đầu tư

**Nghiệp vụ:** Quản lý 2 loại NĐT: (1) NĐT quỹ (MBFUND) — nắm giữ CCQ, theo dõi vốn góp/tỷ lệ sở hữu; (2) NĐT ủy thác (INVES) — ủy thác vốn cho QLQ quản lý, có tài khoản lưu ký riêng (INVESACC).

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `FUNDS` | Quỹ đầu tư *(xem FMS.4.1)* | 🟢 Investment Fund |
| ├── `MBFUND` | Nhà đầu tư quỹ (nắm giữ CCQ) | 🟢 Investment Fund Investor Membership |
| │   └── `MBCHANGE` | Lịch sử thay đổi vốn góp NĐT quỹ | 🟢 Investment Fund Investor Capital Change Log |
| `SECURITIES` | Công ty QLQ *(xem FMS.3.1)* | 🟢 Fund Management Company |
| └── `INVES` | Nhà đầu tư ủy thác | 🟢 Discretionary Investment Investor |
|     └── `INVESACC` | Tài khoản NĐT ủy thác | 🟢 Discretionary Investment Account |
| Danh mục: `STOCKHOLDERTYPE`, `NATIONAL` | | |

### FMS.4.5 — Giao dịch chứng chỉ quỹ và chuyển nhượng cổ phần

**Nghiệp vụ:** Ghi nhận giao dịch: (1) `TRANSFERMBF` — giao dịch CCQ của NĐT quỹ; (2) `TRSFERINDER` — chuyển nhượng cổ phần/vốn góp giữa các cổ đông trong công ty QLQ.

⚠️ **GAP:** `TRSFERINDER` nguồn mới chỉ có FK SecId → SECURITIES. Nguồn cũ có InFrmId/InToId → INSIDER (bên chuyển/nhận). Bảng INSIDER đã bị loại bỏ — mất thông tin ai chuyển cho ai. HLD điểm xác nhận #7: cần làm rõ giao dịch này có liên quan đến INVES không.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `FUNDS` | Quỹ đầu tư *(xem FMS.4.1)* | 🟢 Investment Fund |
| └── `TRANSFERMBF` | Giao dịch chứng chỉ quỹ (FK → FUNDS, MBFUND) | 🟢 Investment Fund Certificate Transfer |
| `SECURITIES` | Công ty QLQ *(xem FMS.3.1)* | 🟢 Fund Management Company |
| └── `TRSFERINDER` | Chuyển nhượng cổ phần ⚠️ mất FK bên mua/bán | 🟢 Fund Management Company Share Transfer |

---

## FMS.5 — Quản lý báo cáo

Nhóm chức năng quản lý báo cáo định kỳ/bất thường của thành viên thị trường. Nguồn cũ chỉ có 2 bảng; nguồn mới xây framework 16 bảng. Phần lớn bảng cấu hình/biểu mẫu chưa có thiết kế chi tiết cột → ngoài scope Silver.

### FMS.5.1 — Báo cáo thành viên và dữ liệu import

**Nghiệp vụ:** Thành viên thị trường (QLQ, quỹ, NH LKGS, VPĐD/CN QLQ NN) nộp báo cáo định kỳ. RPTMEMBER lưu metadata, RPTVALUES lưu dữ liệu chi tiết import. Cán bộ UBCKNN xử lý, phê duyệt. RPTMBHS lưu lịch sử thay đổi trạng thái.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `RPTMEMBER` | Báo cáo định kỳ thành viên thị trường | 🟢 Member Periodic Report |
| ├── `RPTVALUES` | Dữ liệu import báo cáo (theo sheet/ô) | 🟢 Report Import Value |
| ├── `RPTMBHS` | Lịch sử báo cáo thành viên | 🟢 Member Periodic Report Status Log |
| └── `RPTPROCESS` | Lịch sử xử lý báo cáo | 🔴 (Out of scope) *Chưa có cột* |
| Tham chiếu: `SECURITIES`, `FUNDS`, `BANKMONI`, `FORBRCH`, `RPTPERIOD` | | |

### FMS.5.2 — Kỳ báo cáo, biểu mẫu và cấu hình

**Nghiệp vụ:** Quản lý kỳ báo cáo (RPTPERIOD), biểu mẫu đầu vào (RPTTEMP + SHEET) và đầu ra (RPTTPOUT + SHEETOUT). Cho phép thành viên tự thiết lập kỳ gửi (SELFSETPD). Cấu hình hiển thị báo cáo (SECURITIESREPORT).

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `RPTPERIOD` | Kỳ báo cáo | 🟢 Reporting Period |
| ├── `RPTPDSHT` | Map SHEET ↔ RPTPERIOD (trung gian) | 🔴 (Out of scope) *Chưa có cột* |
| `RPTTEMP` | Biểu mẫu báo cáo đầu vào | 🔴 (Out of scope) *Chưa có cột* |
| ├── `SHEET` | Sheet báo cáo đầu vào | 🔴 (Out of scope) *Chưa có cột* |
| ├── `RPTHTORY` | Lịch sử thay đổi BC đầu vào | 🔴 (Out of scope) *Chưa có cột* |
| `RPTTPOUT` | Biểu mẫu báo cáo đầu ra | 🔴 (Out of scope) *Chưa có cột* |
| ├── `SHEETOUT` | Sheet báo cáo đầu ra | 🔴 (Out of scope) *Chưa có cột* |
| ├── `STTRGTOUT` | Cấu hình lấy dữ liệu BC đầu ra | 🔴 (Out of scope) *Chưa có cột* |
| │   └── `TOTSTTG` | Map cấu hình ↔ ô dữ liệu | 🔴 (Out of scope) *Chưa có cột* |
| ├── `TPOUTHTORY` | Lịch sử thay đổi BC đầu ra | 🔴 (Out of scope) *Chưa có cột* |
| `SELFSETPD` | Thành viên tự thiết lập gửi BC | 🔴 (Out of scope) *Chưa có cột* |
| `SECURITIESREPORT` | Thiết lập hiển thị BC cho QLQ | 🔴 (Out of scope) *Cấu hình UI* |

---

## FMS.6 — Đánh giá xếp loại và cảnh báo

Nhóm chức năng đánh giá xếp loại thành viên theo nhiều nhân tố, xếp hạng theo kỳ, và cảnh báo tự động. Hoàn toàn mới so với nguồn cũ.

### FMS.6.1 — Đánh giá xếp loại

**Nghiệp vụ:** Đánh giá thành viên (QLQ) theo kỳ (RATINGPD). Bộ nhân tố dạng cha-con (RNKFACTOR, self-ref ParentId), gắn trọng số và điểm tối đa. Kết quả xếp hạng (RANK) = điểm + hạng + lớp cho từng QLQ theo kỳ.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `RATINGPD` | Kỳ đánh giá xếp loại | 🟢 Member Rating Period |
| ├── `RANK` | Xếp hạng theo kỳ (FK → SECURITIES, RATINGPD) | 🟢 Member Rating |
| `RNKFACTOR` | Nhân tố chấm điểm (cha/con, self-ref ParentId) | 🟢 Rating Criterion |
| ├── `RNKGRFTOR` | Map Ranks ↔ RNKFACTOR (trung gian) | 🔴 (Out of scope) *Chờ thiết kế — chưa có cột* |
| └── `RNKFACTHISTORY` | Kết quả tổng hợp đánh giá | 🔴 (Out of scope) *Chờ thiết kế — chưa có cột* |

### FMS.6.2 — Cảnh báo

**Nghiệp vụ:** Thiết lập tham số cảnh báo (ngưỡng, loại) cho hệ thống giám sát tự động.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `PARAWARN` | Tham số cảnh báo (tên, ngưỡng, loại) | 🔴 (Out of scope) *Isolated — không FK* |

---

## FMS.7 — Tiện ích và hệ thống

Nhóm chức năng hỗ trợ: tham số cấu hình, email, thông báo, hiển thị, vi phạm. Phần lớn ngoài scope Silver trừ VIOLT.

### FMS.7.1 — Cấu hình và thông báo

**Nghiệp vụ:** Tham số cấu hình hệ thống, email trao đổi, thông báo, thiết lập hiển thị.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `SYSVAR` | Tham số cấu hình hệ thống | 🔴 (Out of scope) *Isolated — không FK* |
| `SYSEMAIL` | Nội dung trao đổi thông tin | 🔴 (Out of scope) *Hạ tầng IT* |
| `NOTIFICATION` | Thông báo hệ thống | 🔴 (Out of scope) *Hạ tầng IT* |
| `TABSINFO` | Thiết lập hiển thị dữ liệu | 🔴 (Out of scope) *Cấu hình UI* |

### FMS.7.2 — Quản lý vi phạm

**Nghiệp vụ:** Ghi nhận vi phạm pháp luật hoặc hành chính của công ty QLQ hoặc quỹ đầu tư. SecId/FndId nullable — thuộc QLQ hoặc quỹ, không đồng thời cả hai.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Silver |
|---|---|---|
| `VIOLT` | Danh sách vi phạm (FK nullable → SECURITIES, FUNDS) | 🟢 Fund Management Conduct Violation |

---

## Phụ lục: Danh mục dùng chung

| Bảng | Ý nghĩa | Sử dụng bởi | Ánh xạ Silver |
|---|---|---|---|
| `BUSINESS` | Ngành nghề kinh doanh | FMS.3.1 (`SECBUSINES`), FMS.3.3 (`FGBUSINESS`), FMS.3.4 (`TLProfiles`) | 🟢 `CV: FMS_BUSINESS_TYPE` |
| `JOBTYPE` | Loại chức vụ | FMS.3.4 (`TLProfiles`) | 🟢 `CV: FMS_JOB_TYPE` |
| `LOCATION` | Tỉnh/thành phố | FMS.3.1 (`SECURITIES`), FMS.4.3 (`AGENCIES`) | *(Chưa phân loại trong HLD)* |
| `NATIONAL` | Quốc gia/quốc tịch | FMS.3.1 (`SECURITIES`), FMS.3.4 (`TLProfiles`), FMS.4.4 (`INVES`, `MBFUND`) | 🟢 Geographic Area *(shared)* |
| `PARVALUE` | Mệnh giá cổ phần | FMS.3.1 (`SECURITIES`) | 🔴 (Out of scope) *Orphan* |
| `RELATION` | Mối quan hệ cổ đông | FMS.3.1 (`STAKE`), FMS.4.4 (`INVES`) | *(Chưa phân loại trong HLD)* |
| `STATUS` | Trạng thái hoạt động | FMS.3.1, FMS.3.3, FMS.4.1, FMS.4.2 | 🟢 `CV: FMS_STATUS` |
| `STOCKHOLDERTYPE` | Loại hình NĐT/cổ đông | FMS.4.4 (`MBFUND`, `INVES`) | 🟢 `CV: FMS_STOCKHOLDER_TYPE` |

---

## Verify

Tổng số bảng backtick-quoted trong file: **79** (khớp master list).

Phân bổ Silver:

| Phân loại | Số bảng |
|---|---|
| 🟢 Silver entity (7a) | 24 |
| 🟢 Classification Value (7c) | 6 |
| 🟢 Junction denormalize (7d) | 4 |
| 🔴 Out of scope (7f) | 43 |
| *(Chưa phân loại trong HLD)* | 2 (`LOCATION`, `RELATION`) |
| **Tổng** | **79** |
