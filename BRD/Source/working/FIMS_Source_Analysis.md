# FIMS — Tài liệu khảo sát nguồn và ánh xạ Atomic

> **Phân hệ:** FIMS — Quản lý giám sát nhà đầu tư nước ngoài
>
> **Mục đích:** Tài liệu tham chiếu cho thiết kế Atomic layer — tổng hợp nghiệp vụ nguồn, quan hệ bảng, và ánh xạ Atomic entity theo từng nhóm chức năng (UID).
>
> **Nguồn tài liệu:**
> - Đặc tả yêu cầu: `New_UBCKNN_Dac_ta_yeu_cau_FIMS_09_02_2026.docx`
> - Thiết kế CSDL: `New_UBCKNN_Thiet_ke_co_so_du_lieu_FIMS_20_03_2026.docx`
> - HLD Overview: `FIMS_HLD_Overview.md` (7a Atomic Entities, 7c CV, 7d Junction, 7f Out of scope)
> - Classification Value registry: `ref_shared_entity_classifications.csv` (ưu tiên hơn HLD 7c)
> - Atomic mapping: `manifest.csv`
>
> **Tổng quan:** 10 nhóm chức năng (UID) · 85 bảng CSDL · 19 Atomic entities · 14 Classification Values · 9 Junction tables

---

## Quy ước cột Ánh xạ Atomic

| Ký hiệu | Ý nghĩa |
|---|---|
| 🟢 *Tên entity* | Atomic entity được thiết kế |
| 🟢 *(shared — bổ sung source)* | Entity dùng chung với FMS, FIMS là secondary source |
| 🟢 `CV: CODE` | Classification Value — danh mục mã hóa. Scheme code tra từ `ref_shared_entity_classifications.csv` (ưu tiên), fallback HLD 7c. |
| 🟢 ↳ denormalize vào *Entity* | Junction table flatten vào entity chính |
| 🔴 (Out of scope) *lý do* | Ngoài scope Atomic |

---

## Mục lục

- [FIMS_UID01 — Quản trị phân hệ](#fims_uid01--quản-trị-phân-hệ)
- [FIMS_UID02 — Quản lý tích hợp](#fims_uid02--quản-lý-tích-hợp)
- [FIMS_UID03 — Đối tượng gửi báo cáo](#fims_uid03--đối-tượng-gửi-báo-cáo)
- [FIMS_UID04 — Nhà đầu tư nước ngoài](#fims_uid04--nhà-đầu-tư-nước-ngoài)
- [FIMS_UID05 — Báo cáo thành viên](#fims_uid05--báo-cáo-thành-viên)
- [FIMS_UID06 — Tổng hợp báo cáo](#fims_uid06--tổng-hợp-báo-cáo)
- [FIMS_UID07 — Ủy quyền](#fims_uid07--ủy-quyền)
- [FIMS_UID08 — Công bố thông tin](#fims_uid08--công-bố-thông-tin)
- [FIMS_UID09 — Cảnh báo](#fims_uid09--cảnh-báo)
- [FIMS_UID10 — Tiện ích](#fims_uid10--tiện-ích)
- [Phụ lục: Danh mục dùng chung](#phụ-lục-danh-mục-dùng-chung)

---

## FIMS_UID01 — Quản trị phân hệ

Nhóm chức năng quản trị hệ thống FIMS: quản lý người dùng (tạo, phân quyền chức năng, phân quyền dữ liệu đối tượng gửi báo cáo), quản lý biểu mẫu báo cáo đầu vào/đầu ra, quản lý danh mục dùng riêng, và quản lý hệ thống (chứng thư số, session, error log).

### 1.1. Quản lý người dùng

**Nghiệp vụ:** Quản lý danh sách người dùng hệ thống FIMS (chuyên viên Ban QLQ, lãnh đạo, quản trị). Phân quyền chức năng theo nhóm quyền (Roles → Menus). Phân quyền dữ liệu theo đối tượng gửi báo cáo. Đồng bộ tài khoản từ phân hệ quản lý người dùng tập trung.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `USERS` | Người dùng hệ thống | 🔴 (Out of scope) *Operational/system data* |
| ├── `USERSMENUS` | Quyền phân cho người dùng | 🔴 (Out of scope) *Operational/system data* |
| ├── `USERRPTO` | Phân quyền BC đầu ra | 🔴 (Out of scope) *Operational/system data* |
| ├── `REFRESHTOKEN` | Phiên làm việc | 🔴 (Out of scope) *Operational/system data* |
| ├── `GROUPS` | Nhóm người dùng | 🔴 (Out of scope) *Operational/system data* |
| │   ├── `GROUPUSERS` | Người dùng trong nhóm | 🔴 (Out of scope) *Operational/system data* |
| │   └── `GROUPROLES` | Quyền phân cho nhóm | 🔴 (Out of scope) *Operational/system data* |
| ├── `ROLES` | Nhóm quyền chức năng | 🔴 (Out of scope) *Operational/system data* |
| └── `MENUS` | Danh sách quyền hệ thống | 🔴 (Out of scope) *Operational/system data* |

### 1.2. Quản lý biểu mẫu báo cáo đầu vào

**Nghiệp vụ:** Tạo, chỉnh sửa, đưa vào/ngừng sử dụng biểu mẫu báo cáo đầu vào. Mỗi biểu mẫu gồm nhiều sheet, gắn với kỳ báo cáo. Cán bộ UB có thể tự thiết lập kỳ gửi báo cáo bổ sung.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `RPTTEMP` | Biểu mẫu báo cáo đầu vào | 🟢 Report Template |
| ├── `SHEET` | Sheet trong biểu mẫu | 🟢 `CV: FIMS_REPORT_SHEET` |
| ├── `RPTPERIOD` | Kỳ báo cáo | 🟢 Reporting Period *(shared — bổ sung source)* |
| │   └── `RPTPDSHT` | Trung gian SHEET–RPTPERIOD | 🔴 (Out of scope) *Operational/system data* |
| ├── `RPTHTORY` | Lịch sử thay đổi biểu mẫu | 🔴 (Out of scope) *Snapshot nguồn* |
| └── `SELFSETPD` | Cấu hình kỳ BC tự thiết lập | 🔴 (Out of scope) *Operational/system data* |

### 1.3. Quản lý biểu mẫu báo cáo đầu ra

**Nghiệp vụ:** Tạo, chỉnh sửa biểu mẫu báo cáo tổng hợp đầu ra (20 báo cáo thống kê) phục vụ khai thác nội bộ UBCKNN.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `RPTTPOUT` | Biểu mẫu báo cáo đầu ra | 🔴 (Out of scope) *Báo cáo đầu ra hệ thống* |
| ├── `SHEETOUT` | Sheet báo cáo đầu ra | 🔴 (Out of scope) *Báo cáo đầu ra hệ thống* |
| └── `TPOUTHTORY` | Lịch sử thay đổi biểu mẫu đầu ra | 🔴 (Out of scope) *Snapshot nguồn* |

### 1.4. Quản lý danh mục dùng riêng

**Nghiệp vụ:** Quản lý các danh mục phục vụ phân hệ. Một số đồng bộ từ phân hệ danh mục điện tử dùng chung (quốc tịch, tỉnh/thành phố).

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `STATUS` | Tình trạng hoạt động | 🟢 `CV: LIFE_CYCLE_STATUS` |
| `INVESTORTYPE` | Loại nhà đầu tư | 🟢 `CV: FIMS_INVESTOR_TYPE` |
| `REPORTTYPE` | Loại báo cáo | 🟢 `CV: FIMS_REPORT_TYPE` |
| `SECURITIESTYPE` | Loại chứng khoán | 🟢 `CV: FIMS_SECURITIES_TYPE` |
| `SECURITIES` | Danh mục chứng khoán | 🟢 `CV: FIMS_SECURITIES_CODE` |
| `COMPANYTYPE` | Loại hình doanh nghiệp | 🟢 `CV: FIMS_COMPANY_TYPE` |
| `BUSINESS` | Nghiệp vụ kinh doanh | 🟢 `CV: FIMS_BUSINESS_TYPE` |
| `STOCKHOLDERTYPE` | Loại cổ đông | 🟢 `CV: FIMS_STOCKHOLDER_TYPE` |
| `JOBTYPE` | Chức vụ nhân sự | 🟢 `CV: FIMS_JOB_TYPE` |
| `DEGREE` | Trình độ học vấn | 🟢 `CV: FIMS_DEGREE` |
| `ANNOUNCETYPE` | Loại CBTT | 🟢 `CV: FIMS_ANNOUNCE_TYPE` |
| `RELATEDPROPERTIES` | Hình thức liên quan ủy quyền | 🟢 `CV: FIMS_RELATED_PROPERTIES` |
| `RELATIONSHIP` | Quan hệ ủy quyền CBTT | 🔴 (Out of scope) *Chờ thiết kế — chưa có cấu trúc cột* |
| `NATIONAL` | Quốc tịch/quốc gia | 🟢 Geographic Area *(xem 3.x, Phụ lục)* |
| `LOCATION` | Tỉnh/thành phố | 🔴 (Out of scope) *Chờ thiết kế — reference data địa giới* |
| `CURRENCY` | Tiền tệ | 🔴 (Out of scope) *Chờ thiết kế — danh mục tiền tệ* |
| `VIOLATIONTYPE` | Loại vi phạm | 🔴 (Out of scope) *Chờ thiết kế — danh mục loại vi phạm* |
| `UNIT` | Đơn vị | 🔴 (Out of scope) *Operational/system data* |
| `DEPARTMENT` | Phòng ban | 🔴 (Out of scope) *Operational/system data* |

### 1.5. Quản lý hệ thống

**Nghiệp vụ:** Quản lý lịch hệ thống, tham số phân hệ, chứng thư số, theo dõi session và error log.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `CALENDAR` | Lịch hệ thống | 🔴 (Out of scope) *Operational/system data* |
| ├── `CALENDARMANAGERMENT` | Thay đổi lịch hệ thống | 🔴 (Out of scope) *Operational/system data* |
| `SYSVAR` | Tham số hệ thống | 🔴 (Out of scope) *Operational/system data* |
| `CERTFCATE` | Chứng thư số | 🔴 (Out of scope) *Operational/system data* |
| `ERRORLOG` | Lịch sử lỗi hệ thống | 🔴 (Out of scope) *Operational/system data* |
| `USERSESSIONS` | Theo dõi tài khoản truy cập | 🔴 (Out of scope) *Operational/system data* |

---

## FIMS_UID02 — Quản lý tích hợp

Quản lý cấu hình kết nối giữa phân hệ FIMS với các hệ thống khác (MSS, danh mục dùng chung, QLQ, Cổng báo cáo trực tuyến...).

### 2.1. Cấu hình kết nối

**Nghiệp vụ:** Thêm/sửa/xóa cấu hình kết nối API. Lưu trữ dữ liệu kết nối MSS (giá đóng cửa CK, danh mục NĐT NN từ VSDC).

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `SYSTEMINTEGRATIONCONFIG` | Cấu hình kết nối hệ thống | 🔴 (Out of scope) *Operational/system data* |
| `SYSTEMINTEGRATIONDATA` | Dữ liệu kết nối MSS | 🔴 (Out of scope) *Operational/system data* |

---

## FIMS_UID03 — Đối tượng gửi báo cáo

Quản lý hồ sơ các đối tượng gửi báo cáo về NĐT nước ngoài cho UBCKNN. Một số đồng bộ từ phân hệ QLQ (FMS), một số quản lý trực tiếp trên FIMS.

### 3.1. Sở Giao dịch chứng khoán

**Nghiệp vụ:** Quản lý hồ sơ Sở GDCK (HOSE, HNX) — đồng bộ từ phân hệ danh mục dùng chung. Chuyên viên xem, chỉnh sửa, kết xuất.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `STOCKEXCHANGE` | Sở giao dịch chứng khoán | 🟢 Stock Exchange |
| └── `NATIONAL` | Quốc tịch/quốc gia | 🟢 Geographic Area *(xem Phụ lục)* |
| *Danh mục tham chiếu:* `STATUS` | | 🟢 `CV: LIFE_CYCLE_STATUS` |

### 3.2. Tổng Công ty Lưu ký và Bù trừ chứng khoán Việt Nam (VSDC)

**Nghiệp vụ:** Quản lý hồ sơ VSDC — đồng bộ từ phân hệ danh mục dùng chung. Tiếp nhận dữ liệu danh mục NĐT NN từ VSDC qua trục LGSP.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `DEPOSITORYCENTER` | Trung tâm lưu ký chứng khoán | 🟢 Depository Center |
| └── `NATIONAL` | Quốc tịch/quốc gia | 🟢 Geographic Area *(xem Phụ lục)* |
| *Danh mục tham chiếu:* `STATUS` | | 🟢 `CV: LIFE_CYCLE_STATUS` |

### 3.3. Công ty Quản lý Quỹ

**Nghiệp vụ:** Quản lý hồ sơ Công ty QLQ — đồng bộ từ phân hệ QLQ & QĐT (FMS). Lưu thông tin pháp lý, NVKD, loại hình DN. Gửi BC định kỳ về NĐT NN.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `FUNDCOMPANY` | Công ty quản lý quỹ | 🟢 Fund Management Company *(shared — bổ sung source)* |
| ├── `FUNDCOMBUSINES` | NVKD của CTQLQ | 🟢 ↳ denormalize vào *Fund Management Company* |
| ├── `FUNDCOMTYPE` | Loại hình DN của CTQLQ | 🟢 ↳ denormalize vào *Fund Management Company* |
| └── `NATIONAL` | Quốc tịch/quốc gia | 🟢 Geographic Area *(xem Phụ lục)* |
| *Danh mục tham chiếu:* `STATUS`, `BUSINESS`, `COMPANYTYPE` | | |

### 3.4. Công ty chứng khoán

**Nghiệp vụ:** Quản lý hồ sơ CTCK — đồng bộ từ phân hệ quản lý, giám sát CTCK. CTCK là nơi NĐT NN mở tài khoản giao dịch CK.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `SECURITIESCOMPANY` | Công ty chứng khoán | 🟢 Securities Company |
| ├── `SECCOMBUSINES` | NVKD của CTCK | 🟢 ↳ denormalize vào *Securities Company* |
| ├── `SECCOMTYPE` | Loại hình DN của CTCK | 🟢 ↳ denormalize vào *Securities Company* |
| └── `NATIONAL` | Quốc tịch/quốc gia | 🟢 Geographic Area *(xem Phụ lục)* |
| *Danh mục tham chiếu:* `STATUS`, `BUSINESS`, `COMPANYTYPE` | | |

### 3.5. Ngân hàng lưu ký

**Nghiệp vụ:** Quản lý hồ sơ Ngân hàng lưu ký — đồng bộ từ phân hệ QLQ (FMS). NĐT NN mở tài khoản lưu ký; NH gửi BC danh mục NĐT NN.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `BANKMONI` | Ngân hàng lưu ký | 🟢 Custodian Bank *(shared — bổ sung source)* |
| └── `NATIONAL` | Quốc tịch/quốc gia | 🟢 Geographic Area *(xem Phụ lục)* |
| *Danh mục tham chiếu:* `STATUS` | | 🟢 `CV: LIFE_CYCLE_STATUS` |

### 3.6. Chi nhánh công ty QLQ NN tại Việt Nam

**Nghiệp vụ:** Quản lý hồ sơ CN công ty QLQ nước ngoài tại VN — đồng bộ từ phân hệ QLQ (FMS). CN gửi báo cáo riêng.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `BRANCHS` | CN công ty QLQ NN tại VN | 🟢 Fund Management Company Organization Unit |
| ├── `BRANCHSBUSINES` | NVKD của CN | 🟢 ↳ denormalize vào *Fund Mgmt Co. Organization Unit* |
| └── `NATIONAL` | Quốc tịch/quốc gia | 🟢 Geographic Area *(xem Phụ lục)* |
| *Danh mục tham chiếu:* `STATUS`, `BUSINESS` | | |

### 3.7. Đại diện CBTT

**Nghiệp vụ:** Quản lý hồ sơ người đại diện CBTT — quản lý trực tiếp trên FIMS. Đại diện CBTT gửi BC định kỳ, thực hiện CBTT thay NĐT NN. Lưu danh sách nhân sự và chức vụ.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `INFODISCREPRES` | Người đại diện CBTT | 🟢 Disclosure Representative |
| ├── `INDIREBUSINESS` | NVKD của đại diện CBTT | 🟢 ↳ denormalize vào *Disclosure Representative* |
| ├── `TLPROFILES` | Nhân sự đại diện CBTT | 🟢 Disclosure Representative Key Person |
| │   ├── `TLPROJOB` | Chức vụ nhân sự | 🟢 ↳ denormalize vào *Disclosure Rep. Key Person* |
| │   └── `TLPROSTOCKH` | Loại cổ đông nhân sự | 🟢 ↳ denormalize vào *Disclosure Rep. Key Person* |
| └── `NATIONAL` | Quốc tịch/quốc gia | 🟢 Geographic Area *(xem Phụ lục)* |
| *Danh mục tham chiếu:* `STATUS`, `BUSINESS`, `JOBTYPE`, `STOCKHOLDERTYPE`, `DEGREE` | | |

### 3.8. Nhà đầu tư nước ngoài

**Nghiệp vụ:** *(xem FIMS_UID04)*

---

## FIMS_UID04 — Nhà đầu tư nước ngoài

Quản lý toàn bộ hồ sơ NĐT nước ngoài (cá nhân và tổ chức): thông tin định danh, tài khoản giao dịch CK, danh mục CK sở hữu. NĐT NN được thêm mới trực tiếp trên FIMS hoặc import từ VSDC. Hệ thống lưu lịch sử thay đổi (SCD).

### 4.1. Quản lý hồ sơ NĐT NN

**Nghiệp vụ:** Thêm mới, cập nhật, import danh sách NĐT NN. Phân biệt cá nhân (ObjectType=1) và tổ chức (ObjectType=2). Lưu: mã số giao dịch, quốc tịch, CCCD/hộ chiếu, loại NĐT, tài khoản lưu ký, đại diện giao dịch. Tự động lưu lịch sử thay đổi.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `INVESTOR` | Nhà đầu tư nước ngoài | 🟢 Foreign Investor |
| ├── `INVESTORHIS` | Lịch sử thay đổi NĐT | 🔴 (Out of scope) *Snapshot nguồn — SCD2 xử lý tại ETL* |
| ├── `SECURITIESACCOUNT` | Tài khoản giao dịch CK | 🟢 Foreign Investor Securities Account |
| │   └── `SECURITIESACCOUNTHIS` | Lịch sử tài khoản CK | 🔴 (Out of scope) *Snapshot nguồn* |
| ├── `CATEGORIESSTOCK` | Danh mục CK sở hữu | 🟢 Foreign Investor Stock Portfolio Snapshot |
| │   └── `CATEGORIESSTOCKHIS` | Lịch sử sở hữu CK | 🔴 (Out of scope) *Snapshot nguồn* |
| └── `NATIONAL` | Quốc tịch/quốc gia | 🟢 Geographic Area *(xem Phụ lục)* |
| *Danh mục tham chiếu:* `INVESTORTYPE`, `STATUS`, `SECURITIESTYPE`, `SECURITIES` | | |

---

## FIMS_UID05 — Báo cáo thành viên

Quản lý báo cáo định kỳ và bất thường mà các đối tượng gửi nộp cho UBCKNN. Chuyên viên xem, hủy, kết xuất; đối tượng gửi BC tạo, cập nhật, gửi qua Cổng báo cáo trực tuyến.

### 5.1. Báo cáo định kỳ & bất thường

**Nghiệp vụ:** Hệ thống tự động sinh lịch gửi BC theo kỳ. Đối tượng gửi BC import dữ liệu theo biểu mẫu. Trạng thái: Chưa gửi → Đã gửi/Gửi muộn → Bị hủy → Đã gửi lại. Lưu lịch sử xử lý.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `RPTMEMBER` | Báo cáo thành viên thị trường | 🟢 Member Regulatory Report |
| ├── `RPTVALUES` | Giá trị báo cáo (import) | 🟢 Member Report Value |
| ├── `RPTVALUESMANAGERMENT` | Quản lý bảng giá trị BC | 🔴 (Out of scope) *Operational/system data* |
| ├── `RPTPROCESS` | Lịch sử xử lý báo cáo | 🔴 (Out of scope) *Activity log nguồn* |
| ├── `RPTTEMP` | Biểu mẫu BC đầu vào | 🟢 Report Template *(xem 1.2)* |
| └── `RPTPERIOD` | Kỳ báo cáo | 🟢 Reporting Period *(xem 1.2)* |
| *FK nullable đến:* `FUNDCOMPANY`, `SECURITIESCOMPANY`, `BANKMONI`, `DEPOSITORYCENTER`, `STOCKEXCHANGE`, `BRANCHS`, `INFODISCREPRES` | | |
| *Danh mục tham chiếu:* `REPORTTYPE` | | 🟢 `CV: FIMS_REPORT_TYPE` |

### 5.2. Xem dữ liệu báo cáo

**Nghiệp vụ:** Chuyên viên xem dữ liệu BC đầu vào chi tiết theo sheet, kết xuất ra Excel. Sử dụng `RPTVALUES` *(xem 5.1)*.

---

## FIMS_UID06 — Tổng hợp báo cáo

Tổng hợp, thống kê dữ liệu từ BC đầu vào để xuất BC đầu ra (20 báo cáo thống kê). Hệ thống tự động gen file theo cấu hình.

### 6.1. Thống kê & gen file

**Nghiệp vụ:** Cấu hình gen file thống kê tự động theo lịch. File lưu trữ phục vụ khai thác, download.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `RPTOUTMANAGEMENT` | Cấu hình gen file thống kê | 🔴 (Out of scope) *Operational/system data* |
| `RPTOUTFILESAVE` | File thống kê đã gen | 🔴 (Out of scope) *Operational/system data* |

---

## FIMS_UID07 — Ủy quyền

Quản lý ủy quyền CBTT (NĐT NN ủy quyền cho người đại diện CBTT) và ủy quyền giao dịch. Lưu danh sách NĐT NN được ủy quyền, lịch sử thay đổi.

### 7.1. Ủy quyền CBTT

**Nghiệp vụ:** NĐT NN ủy quyền cho Đại diện CBTT thực hiện CBTT thay mình. Mỗi ủy quyền gắn danh sách NĐT NN. Lưu lịch sử ủy quyền.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `AUTHOANNOUNCE` | Ủy quyền CBTT | 🟢 Disclosure Authorization |
| ├── `AUTHOANNOUNCEHIS` | Lịch sử ủy quyền | 🔴 (Out of scope) *Snapshot nguồn* |
| ├── `ANNOUNCEINVES` | NĐT NN được ủy quyền | 🟢 ↳ denormalize vào *Disclosure Announcement* |
| │   └── `ANNOUNCEINVESHIS` | Lịch sử NĐT NN ủy quyền | 🔴 (Out of scope) *Snapshot nguồn* |
| └── `INFODISCREPRES` | Người đại diện CBTT | 🟢 Disclosure Representative *(xem 3.7)* |
| *Danh mục tham chiếu:* `RELATEDPROPERTIES` | | 🟢 `CV: FIMS_RELATED_PROPERTIES` |

### 7.2. Ủy quyền giao dịch

**Nghiệp vụ:** NĐT NN ủy quyền giao dịch cho CTCK hoặc đại diện giao dịch. Sử dụng cùng bộ bảng `AUTHOANNOUNCE` *(xem 7.1)* với phân biệt theo loại ủy quyền.

---

## FIMS_UID08 — Công bố thông tin

Quản lý các tin CBTT của thành viên thị trường. Đại diện CBTT gửi BC → hệ thống tự động tạo tin CBTT tương ứng.

### 8.1. Công bố thông tin

**Nghiệp vụ:** Tin CBTT được tạo tự động từ BC của Đại diện CBTT (định kỳ → CBTT định kỳ, bất thường → CBTT bất thường). Nội dung: tiêu đề, trích yếu, kỳ BC, file đính kèm, ngày CBTT.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `ANNOUNCE` | Tin công bố thông tin | 🟢 Disclosure Announcement |
| └── `INFODISCREPRES` | Người đại diện CBTT | 🟢 Disclosure Representative *(xem 3.7)* |
| *Danh mục tham chiếu:* `ANNOUNCETYPE` | | 🟢 `CV: FIMS_ANNOUNCE_TYPE` |

---

## FIMS_UID09 — Cảnh báo

Thiết lập tham số cảnh báo, điều kiện cảnh báo, thực hiện cảnh báo tự động trên dữ liệu BC NĐT NN. Kết quả tạo danh sách vi phạm.

### 9.1. Tham số & điều kiện cảnh báo

**Nghiệp vụ:** Thiết lập tham số cảnh báo (VD: giá trị danh mục NĐT biến động > X%), công thức tính, điều kiện ngưỡng.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `PARAWARN` | Tham số cảnh báo | 🔴 (Out of scope) *Operational/system data* |
| └── `CDTWARN` | Điều kiện cảnh báo | 🔴 (Out of scope) *Operational/system data* |

### 9.2. Danh sách vi phạm

**Nghiệp vụ:** Hệ thống tự động tạo danh sách vi phạm khi chạy cảnh báo. Chuyên viên xem, kết xuất, đổi trạng thái (Chưa khắc phục → Đã khắc phục).

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `VIOLT` | Danh sách vi phạm | 🟢 Member Conduct Violation |
| *FK nullable đến:* `FUNDCOMPANY`, `SECURITIESCOMPANY`, `BANKMONI`, `DEPOSITORYCENTER`, `STOCKEXCHANGE`, `BRANCHS`, `INFODISCREPRES` | | |

---

## FIMS_UID10 — Tiện ích

Các chức năng hỗ trợ: thông báo, trao đổi thông tin, quản lý tài liệu, nhắc việc.

### 10.1. Thông báo

**Nghiệp vụ:** Chuyên viên tạo, gửi thông báo đến đối tượng gửi BC. Đối tượng nhận trên phân hệ và qua email.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `NOTIFICATION` | Thông báo hệ thống | 🔴 (Out of scope) *Operational/system data* |

### 10.2. Trao đổi thông tin

**Nghiệp vụ:** Chuyên viên và đối tượng gửi BC trao đổi thông tin qua hệ thống, hỗ trợ gửi email.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `EMAILSENTSYSTEM` | Trao đổi thông tin | 🔴 (Out of scope) *Operational/system data* |
| `SYSEMAIL` | Trao đổi gửi qua mail | 🔴 (Out of scope) *Operational/system data* |

### 10.3. Quản lý tài liệu

**Nghiệp vụ:** Upload, quản lý file tài liệu hệ thống. Cho phép download.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `DOCUMENT` | Tài liệu hệ thống | 🔴 (Out of scope) *Không có FK inbound từ bảng nghiệp vụ* |

---

## Phụ lục: Danh mục dùng chung

Các bảng danh mục được tham chiếu xuyên suốt nhiều UID:

| Bảng | Ý nghĩa | Sử dụng bởi | Ánh xạ Atomic |
|---|---|---|---|
| `NATIONAL` | Quốc tịch/quốc gia | UID03 (tất cả đối tượng), UID04 (NĐT NN), UID03.7 (nhân sự CBTT) | 🟢 Geographic Area *(shared — bổ sung source)* |
| `STATUS` | Tình trạng hoạt động | UID03 (tất cả đối tượng), UID04 (NĐT NN) | 🟢 `CV: LIFE_CYCLE_STATUS` |
| `BUSINESS` | Nghiệp vụ kinh doanh | UID03.3 (CTQLQ), UID03.4 (CTCK), UID03.6 (CN), UID03.7 (ĐD CBTT) | 🟢 `CV: FIMS_BUSINESS_TYPE` |
| `COMPANYTYPE` | Loại hình doanh nghiệp | UID03.3 (CTQLQ), UID03.4 (CTCK) | 🟢 `CV: FIMS_COMPANY_TYPE` |
| `INVESTORTYPE` | Loại nhà đầu tư | UID04 (NĐT NN) | 🟢 `CV: FIMS_INVESTOR_TYPE` |
| `REPORTTYPE` | Loại báo cáo | UID05 (BC thành viên) | 🟢 `CV: FIMS_REPORT_TYPE` |
| `SECURITIESTYPE` | Loại chứng khoán | UID04 (danh mục CK) | 🟢 `CV: FIMS_SECURITIES_TYPE` |
| `SECURITIES` | Danh mục chứng khoán | UID04 (danh mục CK NĐT NN) | 🟢 `CV: FIMS_SECURITIES_CODE` |
| `STOCKHOLDERTYPE` | Loại cổ đông | UID03.7 (nhân sự CBTT) | 🟢 `CV: FIMS_STOCKHOLDER_TYPE` |
| `JOBTYPE` | Chức vụ nhân sự | UID03.7 (nhân sự CBTT) | 🟢 `CV: FIMS_JOB_TYPE` |
| `DEGREE` | Trình độ học vấn | UID03.7 (nhân sự CBTT) | 🟢 `CV: FIMS_DEGREE` |
| `ANNOUNCETYPE` | Loại CBTT | UID08 (công bố thông tin) | 🟢 `CV: FIMS_ANNOUNCE_TYPE` |
| `RELATEDPROPERTIES` | Hình thức liên quan | UID07 (ủy quyền) | 🟢 `CV: FIMS_RELATED_PROPERTIES` |
| `LOCATION` | Tỉnh/thành phố | UID01 (danh mục), UID03 (đối tượng) | 🔴 (Out of scope) *Chờ thiết kế* |
