# Danh sách Enum nghiệp vụ / hệ thống FMS

> Chỉ gồm enum trong `**/enums/**` (common + domain) — phục vụ entity/nghiệp vụ hệ thống.
> Không gồm enum helper nội bộ (Excel, formula, nested Mode, v.v.).

**Ngày quét:** 2026-08-25

**Tổng số:** 42 enum

## Mục lục nhanh

| Enum | Số giá trị | File |
|------|------------|------|
| `AnnouncePeriodTypeEnum` | 4 | `com/tinhvan/fmsservice/common/enums/AnnouncePeriodTypeEnum.java` |
| `AnnounceTypeEnum` | 4 | `com/tinhvan/fmsservice/common/enums/AnnounceTypeEnum.java` |
| `ApprovalActionEnum` | 2 | `com/tinhvan/fmsservice/rptmember/domain/enums/ApprovalActionEnum.java` |
| `BondTypeEnum` | 3 | `com/tinhvan/fmsservice/common/enums/BondTypeEnum.java` |
| `CdtWarnWarningTypeEnum` | 2 | `com/tinhvan/fmsservice/common/enums/CdtWarnWarningTypeEnum.java` |
| `CompanyTypeEnum` | 4 | `com/tinhvan/fmsservice/distributoragent/domain/enums/CompanyTypeEnum.java` |
| `EventTypeCategoryEnum` | 18 | `com/tinhvan/fmsservice/common/enums/EventTypeCategoryEnum.java` |
| `EventTypeClassification` | 4 | `com/tinhvan/fmsservice/common/enums/EventTypeClassification.java` |
| `EventTypeDataPeriodType` | 7 | `com/tinhvan/fmsservice/common/enums/EventTypeDataPeriodType.java` |
| `EventTypeDeadlineMode` | 2 | `com/tinhvan/fmsservice/common/enums/EventTypeDeadlineMode.java` |
| `EventTypeObligation` | 4 | `com/tinhvan/fmsservice/common/enums/EventTypeObligation.java` |
| `FactorScaleValueConditionEnum` | 6 | `com/tinhvan/fmsservice/common/enums/FactorScaleValueConditionEnum.java` |
| `FmsChiTieuDataType` | 8 | `com/tinhvan/fmsservice/danhmuchitieu/domain/enums/FmsChiTieuDataType.java` |
| `FmsEventSubject` | 17 | `com/tinhvan/fmsservice/common/enums/FmsEventSubject.java` |
| `FmsSysVarsEnum` | 46 | `com/tinhvan/fmsservice/common/enums/FmsSysVarsEnum.java` |
| `IntegrationSubsystem` | 14 | `com/tinhvan/fmsservice/integrationconfig/domain/enums/IntegrationSubsystem.java` |
| `MemberProfileTypeEnum` | 28 | `com/tinhvan/fmsservice/common/enums/MemberProfileTypeEnum.java` |
| `NotificationTypeEnum` | 13 | `com/tinhvan/fmsservice/common/enums/NotificationTypeEnum.java` |
| `OfferingDataSourceEnum` | 2 | `com/tinhvan/fmsservice/common/enums/OfferingDataSourceEnum.java` |
| `OfferingTargetEnum` | 7 | `com/tinhvan/fmsservice/common/enums/OfferingTargetEnum.java` |
| `OfferingTypeEnum` | 14 | `com/tinhvan/fmsservice/common/enums/OfferingTypeEnum.java` |
| `OtherAgentCompanyType` | 4 | `com/tinhvan/fmsservice/otheragent/domain/enums/OtherAgentCompanyType.java` |
| `PensionAgentCompanyType` | 4 | `com/tinhvan/fmsservice/pensionagent/domain/enums/PensionAgentCompanyType.java` |
| `PensionProviderCompanyType` | 5 | `com/tinhvan/fmsservice/pensionprovider/domain/enums/PensionProviderCompanyType.java` |
| `PeriodTypeEnum` | 7 | `com/tinhvan/fmsservice/common/enums/PeriodTypeEnum.java` |
| `RecoveryStatusEnum` | 2 | `com/tinhvan/fmsservice/common/enums/RecoveryStatusEnum.java` |
| `ReminderTargetType` | 2 | `com/tinhvan/fmsservice/auditfirm/domain/enums/ReminderTargetType.java` |
| `ReportGroupsEnum` | 19 | `com/tinhvan/fmsservice/common/enums/ReportGroupsEnum.java` |
| `ReportOutGroupsEnum` | 17 | `com/tinhvan/fmsservice/common/enums/ReportOutGroupsEnum.java` |
| `ReportTypeEnum` | 4 | `com/tinhvan/fmsservice/common/enums/ReportTypeEnum.java` |
| `ResponseCode` | 206 | `com/tinhvan/fmsservice/common/enums/ResponseCode.java` |
| `RptMemberStatusEnum` | 10 | `com/tinhvan/fmsservice/common/enums/RptMemberStatusEnum.java` |
| `RptTempStatusEnum` | 4 | `com/tinhvan/fmsservice/common/enums/RptTempStatusEnum.java` |
| `SecuritiesOfferingTypeEnum` | 5 | `com/tinhvan/fmsservice/common/enums/SecuritiesOfferingTypeEnum.java` |
| `StatusAnnounceEnum` | 4 | `com/tinhvan/fmsservice/common/enums/StatusAnnounceEnum.java` |
| `StockClassEnum` | 2 | `com/tinhvan/fmsservice/common/enums/StockClassEnum.java` |
| `StockOfferingPlanMethodEnum` | 10 | `com/tinhvan/fmsservice/common/enums/StockOfferingPlanMethodEnum.java` |
| `SystemDaysOfWeekEnum` | 7 | `com/tinhvan/fmsservice/common/enums/SystemDaysOfWeekEnum.java` |
| `SystemObjectEnum` | 15 | `com/tinhvan/fmsservice/common/enums/SystemObjectEnum.java` |
| `SysVarsEnum` | 34 | `com/tinhvan/fmsservice/common/enums/SysVarsEnum.java` |
| `TransferAgentCompanyTypeEnum` | 3 | `com/tinhvan/fmsservice/transferagent/domain/enums/TransferAgentCompanyTypeEnum.java` |
| `WarnSubjectTypeEnum` | 12 | `com/tinhvan/fmsservice/common/enums/WarnSubjectTypeEnum.java` |

---

## `AnnouncePeriodTypeEnum`

**File:** `com/tinhvan/fmsservice/common/enums/AnnouncePeriodTypeEnum.java`  
**Số giá trị:** 4

| # | Constant | Code / tham số constructor |
|---|----------|----------------------------|
| 1 | `QUARTER_REPORT` | `1, "Quý"` |
| 2 | `HALF_YEAR` | `2, "Bán Niên"` |
| 3 | `YEAR` | `3, "Năm"` |
| 4 | `OTHER` | `4, "Khác"` |

## `AnnounceTypeEnum`

**File:** `com/tinhvan/fmsservice/common/enums/AnnounceTypeEnum.java`  
**Số giá trị:** 4

| # | Constant | Code / tham số constructor |
|---|----------|----------------------------|
| 1 | `PERIODICAL` | `1, "Công bố định kỳ"` |
| 2 | `FADDINESS` | `2, "Công bố bất thường"` |
| 3 | `INSISTENCE` | `3, "Công bố theo yêu cầu"` |
| 4 | `OTHER` | `4, "Công bố khác"` |

## `ApprovalActionEnum`

**File:** `com/tinhvan/fmsservice/rptmember/domain/enums/ApprovalActionEnum.java`  
**Số giá trị:** 2

| # | Constant | Code / tham số constructor |
|---|----------|----------------------------|
| 1 | `APPROVE` | `1, "Chấp thuận"` |
| 2 | `REJECT` | `2, "Từ chối"` |

## `BondTypeEnum`

**File:** `com/tinhvan/fmsservice/common/enums/BondTypeEnum.java`  
**Số giá trị:** 3

| # | Constant | Code / tham số constructor |
|---|----------|----------------------------|
| 1 | `NON_CONVERTIBLE` | `"01", "TPDN không chuyển đổi"` |
| 2 | `WITHOUT_WARRANT` | `"02", "TPDN không kèm chứng quyền"` |
| 3 | `WITHOUT_COLLATERAL` | `"03", "TPDN không có tài sản bảo đảm"` |

## `CdtWarnWarningTypeEnum`

**File:** `com/tinhvan/fmsservice/common/enums/CdtWarnWarningTypeEnum.java`  
**Số giá trị:** 2

| # | Constant | Code / tham số constructor |
|---|----------|----------------------------|
| 1 | `NUMERIC` | `0, "Cảnh báo so sánh số liệu"` |
| 2 | `ABNORMAL_CONTENT` | `1, "Cảnh báo nội dung bất thường"` |

## `CompanyTypeEnum`

**File:** `com/tinhvan/fmsservice/distributoragent/domain/enums/CompanyTypeEnum.java`  
**Số giá trị:** 4

| # | Constant | Code / tham số constructor |
|---|----------|----------------------------|
| 1 | `CT_CK` | `1, "Công ty chứng khoán"` |
| 2 | `NH_THUONG_MAI` | `2, "Ngân hàng thương mại"` |
| 3 | `CONG_TY_BAO_HIEM` | `3, "Công ty bảo hiểm"` |
| 4 | `TO_CHUC_KHAC` | `4, "Tổ chức khác"` |

## `EventTypeCategoryEnum`

**File:** `com/tinhvan/fmsservice/common/enums/EventTypeCategoryEnum.java`  
**Số giá trị:** 18

| # | Constant | Code / tham số constructor |
|---|----------|----------------------------|
| 1 | `CBTT_CONG_TY_QLQ` | `"CBTT_CONG_TY_QLQ", "CBTT công ty QLQ"` |
| 2 | `CBTT_QUY_DAU_TU` | `"CBTT_QUY_DAU_TU", "CBTT quỹ đầu tư"` |
| 3 | `CONG_TY_QLQ` | `"CONG_TY_QLQ", "Công ty QLQ"` |
| 4 | `NHAN_SU` | `"NHAN_SU", "Nhân sự"` |
| 5 | `QUY_DAU_TU` | `"QUY_DAU_TU", "Quỹ đầu tư"` |
| 6 | `QUY_HUU_TRI` | `"QUY_HUU_TRI", "Quỹ hưu trí"` |
| 7 | `VPDD_QLQ_NN` | `"VPDD_QLQ_NN", "VPĐD công ty QLQ NN"` |
| 8 | `CN_QLQ_NN` | `"CN_QLQ_NN", "CN công ty QLQ NN"` |
| 9 | `DAI_LY_PHAN_PHOI` | `"DAI_LY_PHAN_PHOI", "Đại lý phân phối"` |
| 10 | `DAI_LY_CHUYEN_NHUONG` | `"DAI_LY_CHUYEN_NHUONG", "Đại lý chuyển nhượng"` |
| 11 | `DAI_LY_HUU_TRI` | `"DAI_LY_HUU_TRI", "Đại lý hưu trí"` |
| 12 | `TO_CHUC_QUAN_TRI_TKHT` | `"TO_CHUC_QUAN_TRI_TKHT", "Tổ chức cung cấp dịch vụ quản trị tài khoản hưu trí cá nhân"` |
| 13 | `DAI_LY_KHAC` | `"DAI_LY_KHAC", "Đại lý khác"` |
| 14 | `NGAN_HANG_LKGS` | `"NGAN_HANG_LKGS", "Ngân hàng LKGS"` |
| 15 | `DTCK_RIENG_TU_QL` | `"DTCK_RIENG_TU_QL", "Công ty ĐTCK riêng lẻ tự quản lý"` |
| 16 | `DAI_LY_QUY` | `"DAI_LY_QUY", "Đại lý quỹ"` |
| 17 | `CONG_TY_KIEM_TOAN` | `"CONG_TY_KIEM_TOAN", "Công ty kiểm toán"` |
| 18 | `KIEM_TOAN_VIEN` | `"KIEM_TOAN_VIEN", "Kiểm toán viên"` |

## `EventTypeClassification`

**File:** `com/tinhvan/fmsservice/common/enums/EventTypeClassification.java`  
**Số giá trị:** 4

| # | Constant | Code / tham số constructor |
|---|----------|----------------------------|
| 1 | `DINH_KY` | `"DINH_KY", "Định kỳ"` |
| 2 | `BAT_THUONG` | `"BAT_THUONG", "Bất thường"` |
| 3 | `THEO_YEU_CAU` | `"THEO_YEU_CAU", "Theo yêu cầu"` |
| 4 | `KHAC` | `"KHAC", "Khác"` |

## `EventTypeDataPeriodType`

**File:** `com/tinhvan/fmsservice/common/enums/EventTypeDataPeriodType.java`  
**Số giá trị:** 7

| # | Constant |
|---|----------|
| 1 | `NGAY` |
| 2 | `TUAN` |
| 3 | `NUA_THANG` |
| 4 | `THANG` |
| 5 | `QUY` |
| 6 | `BAN_NIEN` |
| 7 | `NAM` |

## `EventTypeDeadlineMode`

**File:** `com/tinhvan/fmsservice/common/enums/EventTypeDeadlineMode.java`  
**Số giá trị:** 2

| # | Constant | Code / tham số constructor |
|---|----------|----------------------------|
| 1 | `DINH_KY` | `"DINH_KY", "Theo định kỳ"` |
| 2 | `SU_KIEN` | `"SU_KIEN", "Theo sự kiện phát sinh"` |

## `EventTypeObligation`

**File:** `com/tinhvan/fmsservice/common/enums/EventTypeObligation.java`  
**Số giá trị:** 4

| # | Constant | Code / tham số constructor |
|---|----------|----------------------------|
| 1 | `CHI_BAO_CAO` | `"CHI_BAO_CAO", "Chỉ báo cáo"` |
| 2 | `CHI_CBTT` | `"CHI_CBTT", "Chỉ công bố thông tin"` |
| 3 | `BAO_CAO_VA_CBTT` | `"BAO_CAO_VA_CBTT", "Vừa báo cáo vừa công bố thông tin"` |
| 4 | `THAY_DOI_HO_SO` | `"THAY_DOI_HO_SO", "Thay đổi hồ sơ"` |

## `FactorScaleValueConditionEnum`

**File:** `com/tinhvan/fmsservice/common/enums/FactorScaleValueConditionEnum.java`  
**Số giá trị:** 6

| # | Constant | Code / tham số constructor |
|---|----------|----------------------------|
| 1 | `LESS_EQUAL_THAN` | `1, "<="` |
| 2 | `LESS_THAN` | `2, "<"` |
| 3 | `GREATER_EQUAL_THAN` | `3, ">="` |
| 4 | `GREATER_THAN` | `4, ">"` |
| 5 | `EQUAL` | `5, "="` |
| 6 | `OTHER` | `6, "#"` |

## `FmsChiTieuDataType`

**File:** `com/tinhvan/fmsservice/danhmuchitieu/domain/enums/FmsChiTieuDataType.java`  
**Số giá trị:** 8

| # | Constant |
|---|----------|
| 1 | `TEXT` |
| 2 | `NUMBER` |
| 3 | `DATE` |
| 4 | `DROPDOWN` |
| 5 | `MULTISELECT` |
| 6 | `TEXTAREA` |
| 7 | `CHECKBOX` |
| 8 | `FILE` |

## `FmsEventSubject`

**File:** `com/tinhvan/fmsservice/common/enums/FmsEventSubject.java`  
**Số giá trị:** 17

| # | Constant | Code / tham số constructor |
|---|----------|----------------------------|
| 1 | `CONG_TY_QLQ` | `"CONG_TY_QLQ", "Công ty QLQ"` |
| 2 | `NHAN_SU` | `"NHAN_SU", "Nhân sự"` |
| 3 | `QUY_DAU_TU` | `"QUY_DAU_TU", "Quỹ đầu tư"` |
| 4 | `QUY_HUU_TRI` | `"QUY_HUU_TRI", "Quỹ hưu trí"` |
| 5 | `NGAN_HANG_LKGS` | `"NGAN_HANG_LKGS", "Ngân hàng lưu ký giám sát"` |
| 6 | `CN_QLQ_NN` | `"CN_QLQ_NN", "Chi nhánh công ty QLQ nước ngoài tại VN"` |
| 7 | `VPDD_QLQ_NN` | `"VPDD_QLQ_NN", "VPĐD công ty QLQ nước ngoài tại VN"` |
| 8 | `DTCK_RIENG_TU_QL` | `"DTCK_RIENG_TU_QL", "Công ty ĐTCK riêng lẻ tự quản lý"` |
| 9 | `DAI_LY_PHAN_PHOI` | `"DAI_LY_PHAN_PHOI", "Đại lý phân phối"` |
| 10 | `DAI_LY_CHUYEN_NHUONG` | `"DAI_LY_CHUYEN_NHUONG", "Đại lý chuyển nhượng"` |
| 11 | `DAI_LY_HUU_TRI` | `"DAI_LY_HUU_TRI", "Đại lý hưu trí"` |
| 12 | `TO_CHUC_QUAN_TRI_TKHT` | `"TO_CHUC_QUAN_TRI_TKHT", "Tổ chức cung cấp dịch vụ quản trị tài khoản hưu trí cá nhân"` |
| 13 | `DAI_LY_KHAC` | `"DAI_LY_KHAC", "Đại lý khác"` |
| 14 | `CONG_TY_KIEM_TOAN` | `"CONG_TY_KIEM_TOAN", "Công ty kiểm toán"` |
| 15 | `KIEM_TOAN_VIEN` | `"KIEM_TOAN_VIEN", "Kiểm toán viên"` |
| 16 | `KET_QUA_CHAO_BAN` | `"KET_QUA_CHAO_BAN", "Kết quả chào bán"` |
| 17 | `DAI_LY_QUY` | `"DAI_LY_QUY", "Đại lý quỹ"` |

## `FmsSysVarsEnum`

**File:** `com/tinhvan/fmsservice/common/enums/FmsSysVarsEnum.java`  
**Số giá trị:** 46

| # | Constant | Code / tham số constructor |
|---|----------|----------------------------|
| 1 | `TOTALPERCENT_IN2COM` | `1` |
| 2 | `PERCENTLARGER_IN2COM` | `2` |
| 3 | `ECapital` | `3` |
| 4 | `LINKNDTNN` | `4` |
| 5 | `AUTOREPORT` | `5` |
| 6 | `EMAIL` | `6` |
| 7 | `HOTLINE` | `7` |
| 8 | `FILESIZE` | `8` |
| 9 | `LENPASS` | `9` |
| 10 | `PERCENT` | `10` |
| 11 | `CERTIFICATE` | `11` |
| 12 | `MAIL_SERVER` | `12` |
| 13 | `MAIL_PORT` | `13` |
| 14 | `MAIL_PASSWORD` | `14` |
| 15 | `MAIL_USER` | `15` |
| 16 | `MAIL_BCC_CONFIG` | `16` |
| 17 | `MAIL_BCC` | `17` |
| 18 | `MAIL_SUBJECT` | `18` |
| 19 | `MAIL_CONTENT` | `19` |
| 20 | `MAIL_SUBJECT_CANCEL_REPORT` | `20` |
| 21 | `MAIL_CONTENT_CANCEL_REPORT` | `21` |
| 22 | `MAIL_SUBJECT_CBTT` | `22` |
| 23 | `MAIL_CONTENT_CBTT` | `23` |
| 24 | `VALUE` | `24` |
| 25 | `PERCENT10` | `25` |
| 26 | `PERCENT25` | `26` |
| 27 | `PERCENT50` | `27` |
| 28 | `PERCENT75` | `28` |
| 29 | `MBFPERCENT` | `29` |
| 30 | `LINKSYSTEMFMS` | `30` |
| 31 | `MAIL_CONTENT_FORGOTPASSWORD` | `31` |
| 32 | `NUMBER_LOOP_TABLE` | `32` |
| 33 | `MAIL_CONTENT_CERTIFICATE_EXPIRED` | `33` |
| 34 | `DAY_CHECK_CERTIFICATE_EXPRIED` | `34` |
| 35 | `DAY_CHECK_CERTIFICATE` | `35` |
| 36 | `DAY_REPORT_CHECK_TEST` | `36` |
| 37 | `WEEK_REPORT_CHECK_TEST` | `37` |
| 38 | `MONTH_REPORT_CHECK_TEST` | `38` |
| 39 | `HAFMONTH_REPORT_CHECK_TEST` | `46` |
| 40 | `QUARTER_REPORT_CHECK_TEST` | `39` |
| 41 | `HAFLYEAR_REPORT_CHECK_TEST` | `40` |
| 42 | `YEAR_REPORT_CHECK_TEST` | `41` |
| 43 | `NAME_OTHER_REPORT_HALF_YEAR` | `42` |
| 44 | `NAME_OTHER_REPORT_YEAR` | `43` |
| 45 | `NUMBER_DAY_REPORT_EXPRIED` | `44` |
| 46 | `DAY_CHECK_RATTINGPD` | `45` |

## `IntegrationSubsystem`

**File:** `com/tinhvan/fmsservice/integrationconfig/domain/enums/IntegrationSubsystem.java`  
**Số giá trị:** 14

| # | Constant | Code / tham số constructor |
|---|----------|----------------------------|
| 1 | `CSDL_DKKD` | `1, "Hệ thống CSDL quốc gia về đăng ký doanh nghiệp"` |
| 2 | `SGD_HOSE_HNX` | `2, "Dữ liệu của Sở giao dịch (HOSE, HNX)"` |
| 3 | `VSDC` | `3, "Dữ liệu của VSDC"` |
| 4 | `CONG_BCTT` | `4, "Cổng báo cáo trực tuyến"` |
| 5 | `CONG_TRUY_CAP_TT` | `5, "Cổng truy cập tập trung nội bộ"` |
| 6 | `DM_DIEN_TU_DUNG_CHUNG` | `6, "Phân hệ quản lý danh mục điện tử dùng trung"` |
| 7 | `GIAM_SAT_NHN` | `7, "Phân hệ quản lý, giám sát người hành nghề"` |
| 8 | `GIAM_SAT_CTCK` | `8, "Phân hệ quản lý, giám sát công ty chứng khoán"` |
| 9 | `GIAM_SAT_NDT_NN` | `9, "Phân hệ quản lý, giám sát NĐT nước ngoài"` |
| 10 | `GIAM_SAT_TO_CHUC_KIEM_TOAN` | `10, "Phân hệ quản lý, giám sát tổ chức kiểm toán được chấp thuận kiểm toán cho đơn vị có lợi ích công chúng thuộc lĩnh vực chứng khoán"` |
| 11 | `THANH_TRA_CK` | `11, "Phân hệ Phục vụ công tác Thanh tra chứng khoán"` |
| 12 | `QUAN_LY_TTHC` | `12, "Phân hệ quản lý TTHC"` |
| 13 | `NSD_TAP_TRUNG` | `13, "Phân hệ quản lý người dùng tập trung"` |
| 14 | `DL_TRAO_DOI_TC` | `14, "Phân hệ quản lý dữ liệu trao đổi giữa UBCKNN và đơn vị trong ngành tài chính"` |

## `MemberProfileTypeEnum`

**File:** `com/tinhvan/fmsservice/common/enums/MemberProfileTypeEnum.java`  
**Số giá trị:** 28

| # | Constant | Code / tham số constructor |
|---|----------|----------------------------|
| 1 | `LIST_OF_FUND_COMPANIES` | `1, "Danh sách công ty QLQ"` |
| 2 | `LIST_OF_INVESTORS` | `4, "Danh sách nhà đầu tư ủy thác"` |
| 3 | `LIST_OF_FUNDS` | `5, "Danh sách quỹ đầu tư"` |
| 4 | `LIST_OF_MEMBER_FUNDS` | `6, "Nhà đầu tư quỹ"` |
| 5 | `LIST_OF_DISTRIBUTORS` | `7, "Danh sách đại lý phân phối"` |
| 6 | `LIST_OF_TRANSFER_AGENTS` | `8, "Danh sách đại lý chuyển nhượng"` |
| 7 | `LIST_OF_PENSION_AGENTS` | `9, "Danh sách đại lý hưu trí"` |
| 8 | `LIST_OF_PENSION_PROVIDERS` | `10, "Danh sách TCCCDV quản trị TK hưu trí"` |
| 9 | `LIST_OF_OTHER_AGENTS` | `11, "Danh sách đại lý khác"` |
| 10 | `LIST_OF_PENSION_FUNDS` | `12, "Danh sách quỹ hưu trí"` |
| 11 | `LIST_OF_CUSTODIAN_BANKS` | `13, "Danh sách ngân hàng LKGS"` |
| 12 | `LIST_OF_FOREIGN_BRANCHES` | `14, "Danh sách CN công ty QLQ nước ngoài tại VN"` |
| 13 | `LIST_OF_FOREIGN_REP_OFFICES` | `15, "Danh sách VPĐD công ty QLQ nước ngoài tại VN"` |
| 14 | `LIST_OF_SELF_MANAGED_SECURITIES` | `16, "Danh sách công ty ĐTCK riêng lẻ tự quản lý"` |
| 15 | `LIST_OF_AUDIT_FIRMS` | `17, "Danh sách công ty kiểm toán"` |
| 16 | `LIST_OF_AUDITORS` | `18, "Danh sách kiểm toán viên"` |
| 17 | `LIST_OF_SEC_HISTORY` | `19, "Lịch sử công ty"` |
| 18 | `LIST_OF_DOMESTIC_BRANCHES` | `20, "Chi nhánh trong nước"` |
| 19 | `LIST_OF_DOMESTIC_REP_OFFICES` | `21, "VPĐD trong nước"` |
| 20 | `LIST_OF_SHAREHOLDERS` | `22, "Danh sách cổ đông"` |
| 21 | `LIST_OF_TL_PROFILES` | `23, "Danh sách nhân sự"` |
| 22 | `LIST_OF_BANK_HISTORY` | `24, "Lịch sử ngân hàng LKGS"` |
| 23 | `LIST_OF_FOREIGN_BR_HISTORY` | `25, "Lịch sử CN/VPĐD QLQ nước ngoài"` |
| 24 | `LIST_OF_AUDIT_FIRM_REMINDERS` | `26, "Nhắc nhở kiểm toán"` |
| 25 | `LIST_OF_RELATED_PARTIES` | `27, "Danh sách bên liên quan"` |
| 26 | `LIST_OF_PENALTY_DECISIONS` | `28, "Danh sách quyết định xử phạt"` |
| 27 | `LIST_OF_INSIDER_HISTORY` | `29, "Lịch sử cổ đông"` |
| 28 | `LIST_OF_TL_PROFILE_HISTORY` | `30, "Lịch sử nhân sự"` |

## `NotificationTypeEnum`

**File:** `com/tinhvan/fmsservice/common/enums/NotificationTypeEnum.java`  
**Số giá trị:** 13

| # | Constant | Code / tham số constructor |
|---|----------|----------------------------|
| 1 | `MEMBER_CHANGE_INFOR` | `1, "Thành viên thị trường thay đổi thông tin trong hồ sơ của thành viên"` |
| 2 | `MEMBER_SEND_REPORT` | `2, "Thành viên thị trường gửi báo cáo lên hệ thống"` |
| 3 | `MEMBER_PUBLISH` | `3, "Thành viên thị trường gửi công bố thông tin trên hệ thống"` |
| 4 | `MEMBER_INFOR_EXCHANGE` | `4, "Thành viên thị trường gửi tin nhắn trao đổi"` |
| 5 | `WARNING_VIOLT` | `5, "Cảnh báo vi phạm tham số cảnh báo của hệ thống"` |
| 6 | `UBCK_DESTROY_REPORT` | `6, "UBCK huỷ báo cáo"` |
| 7 | `WARNING_CERTIFICATE_EXPIRED` | `7, "Cảnh báo hết hạn chứng thư số"` |
| 8 | `UBCK_INFOR_EXCHANGE` | `8, "UBCK gửi tin nhắn trao đổi"` |
| 9 | `UBCK_ACTIVE_RPTTEMP` | `9, "UBCK đưa biểu mẫu mới vào sử dụng"` |
| 10 | `UBCK_SEND_NOTIFI` | `10, "Thông báo từ UBCK gửi đến đối tượng gửi báo cáo"` |
| 11 | `UBCK_USER_NOTI` | `11, "Thông báo tài khoản"` |
| 12 | `MEMBER_UPDATE_COMPANY_PROFILE` | `12, "Yêu cầu cập nhật thông tin hồ sơ công ty"` |
| 13 | `IRREGULAR_REPORT_APPROVAL` | `13, "Phê duyệt hồ sơ báo cáo bất thường"` |

## `OfferingDataSourceEnum`

**File:** `com/tinhvan/fmsservice/common/enums/OfferingDataSourceEnum.java`  
**Số giá trị:** 2

| # | Constant | Code / tham số constructor |
|---|----------|----------------------------|
| 1 | `MANUAL` | `"MANUAL", "Nhập trên SCMS"` |
| 2 | `TTHC` | `"TTHC", "Phân hệ TTHC"` |

## `OfferingTargetEnum`

**File:** `com/tinhvan/fmsservice/common/enums/OfferingTargetEnum.java`  
**Số giá trị:** 7

| # | Constant | Code / tham số constructor |
|---|----------|----------------------------|
| 1 | `CO_DONG_HIEN_HUU` | `"01", "Cổ đông hiện hữu"` |
| 2 | `CAN_BO_CNV` | `"02", "Cán bộ CNV, HĐQT, BKS"` |
| 3 | `DOI_TAC_CHIEN_LUOC` | `"03", "Đối tác chiến lược"` |
| 4 | `CHAO_BAN_RIENG_LE` | `"04", "Chào bán riêng lẻ"` |
| 5 | `DAU_GIA` | `"05", "Đấu giá"` |
| 6 | `DOI_TUONG_KHAC` | `"06", "Đối tượng khác"` |
| 7 | `TRAI_PHIEU_QT` | `"07", "Phát hành trái phiếu ra thị trường quốc tế"` |

## `OfferingTypeEnum`

**File:** `com/tinhvan/fmsservice/common/enums/OfferingTypeEnum.java`  
**Số giá trị:** 14

| # | Constant | Code / tham số constructor |
|---|----------|----------------------------|
| 1 | `TYPE_01` | `"01", "Chào bán cổ phiếu ra công chúng"` |
| 2 | `TYPE_02` | `"02", "Phát hành cổ phiếu để hoán đổi"` |
| 3 | `TYPE_03` | `"03", "Chào bán của cổ đông lớn"` |
| 4 | `TYPE_04` | `"04", "Chủ sở hữu góp vốn"` |
| 5 | `TYPE_05` | `"05", "Chào bán cổ phiếu riêng lẻ"` |
| 6 | `TYPE_06` | `"06", "Chào bán trái phiếu ra công chúng"` |
| 7 | `TYPE_07` | `"07", "Phát hành cổ phiếu để tăng vốn"` |
| 8 | `TYPE_08` | `"08", "Phát hành cổ phiếu để trả cổ tức"` |
| 9 | `TYPE_09` | `"09", "Phát hành cổ phiếu theo chương trình ESOP"` |
| 10 | `TYPE_10` | `"10", "Phát hành chứng quyền có bảo đảm"` |
| 11 | `TYPE_11` | `"11", "Phát hành có thu tiền"` |
| 12 | `TYPE_12` | `"12", "Phát hành cổ phiếu để hoán đổi"` |
| 13 | `TYPE_13` | `"13", "Cổ phiếu thưởng"` |
| 14 | `TYPE_14` | `"14", "Khác"` |

## `OtherAgentCompanyType`

**File:** `com/tinhvan/fmsservice/otheragent/domain/enums/OtherAgentCompanyType.java`  
**Số giá trị:** 4

| # | Constant | Code / tham số constructor |
|---|----------|----------------------------|
| 1 | `CT_CK` | `1, "Công ty chứng khoán"` |
| 2 | `NH_THUONG_MAI` | `2, "Ngân hàng thương mại"` |
| 3 | `CONG_TY_BAO_HIEM` | `3, "Công ty bảo hiểm"` |
| 4 | `TO_CHUC_KHAC` | `4, "Tổ chức khác"` |

## `PensionAgentCompanyType`

**File:** `com/tinhvan/fmsservice/pensionagent/domain/enums/PensionAgentCompanyType.java`  
**Số giá trị:** 4

| # | Constant | Code / tham số constructor |
|---|----------|----------------------------|
| 1 | `CT_CK` | `1, "Công ty chứng khoán"` |
| 2 | `NH_THUONG_MAI` | `2, "Ngân hàng thương mại"` |
| 3 | `CONG_TY_BAO_HIEM` | `3, "Công ty bảo hiểm"` |
| 4 | `TO_CHUC_KHAC` | `4, "Tổ chức khác"` |

## `PensionProviderCompanyType`

**File:** `com/tinhvan/fmsservice/pensionprovider/domain/enums/PensionProviderCompanyType.java`  
**Số giá trị:** 5

| # | Constant | Code / tham số constructor |
|---|----------|----------------------------|
| 1 | `TONG_CONG_TY_LUU_KY` | `1, "Tổng công ty Lưu ký và Bù trừ chứng khoán Việt Nam"` |
| 2 | `CT_CK` | `2, "Công ty chứng khoán"` |
| 3 | `NH_THUONG_MAI` | `3, "Ngân hàng thương mại"` |
| 4 | `CONG_TY_BAO_HIEM` | `4, "Công ty bảo hiểm"` |
| 5 | `TO_CHUC_KHAC` | `5, "Tổ chức khác"` |

## `PeriodTypeEnum`

**File:** `com/tinhvan/fmsservice/common/enums/PeriodTypeEnum.java`  
**Số giá trị:** 7

| # | Constant | Code / tham số constructor |
|---|----------|----------------------------|
| 1 | `PERIOD_DATE` | `1, "Ngày"` |
| 2 | `PERIOD_WEEK` | `2, "Tuần"` |
| 3 | `PERIOD_HALF_MONTH` | `7, "Nửa tháng"` |
| 4 | `PERIOD_MONTH` | `3, "Tháng"` |
| 5 | `PERIOD_QUARTER` | `4, "Quý"` |
| 6 | `PERIOD_HALF_A_YEAR` | `5, "Bán niên"` |
| 7 | `PERIOD_YEAR` | `6, "Năm"` |

## `RecoveryStatusEnum`

**File:** `com/tinhvan/fmsservice/common/enums/RecoveryStatusEnum.java`  
**Số giá trị:** 2

| # | Constant | Code / tham số constructor |
|---|----------|----------------------------|
| 1 | `CHUA_KHAC_PHUC` | `0, "Chưa khắc phục"` |
| 2 | `DA_KHAC_PHUC` | `1, "Đã khắc phục"` |

## `ReminderTargetType`

**File:** `com/tinhvan/fmsservice/auditfirm/domain/enums/ReminderTargetType.java`  
**Số giá trị:** 2

| # | Constant | Code / tham số constructor |
|---|----------|----------------------------|
| 1 | `AUDIT_FIRM` | `"AUDIT_FIRM", "Công ty kiểm toán"` |
| 2 | `AUDITOR` | `"AUDITOR", "Kiểm toán viên"` |

## `ReportGroupsEnum`

**File:** `com/tinhvan/fmsservice/common/enums/ReportGroupsEnum.java`  
**Số giá trị:** 19

| # | Constant | Code / tham số constructor |
|---|----------|----------------------------|
| 1 | `FUND_MANAGEMENT_REPORT` | `1, "Báo cáo công ty QLQ"` |
| 2 | `SECURITIES_STAFF_REPORT` | `2, "Báo cáo người hành nghề chứng khoán"` |
| 3 | `OPEN_FUND_REPORT` | `3, "Báo cáo quỹ mở"` |
| 4 | `CLOSE_FUND_REPORT` | `4, "Báo cáo quỹ đóng"` |
| 5 | `MEMBER_FUND_REPORT` | `5, "Báo cáo quỹ thành viên"` |
| 6 | `REAL_ESTATE_FUND_REPORT` | `6, "Báo cáo quỹ BĐS/ công ty ĐTCK BĐS"` |
| 7 | `INVEST_STOCK_REPORT` | `7, "Báo cáo công ty ĐTCK"` |
| 8 | `FUND_ETF_REPORT` | `8, "Báo cáo quỹ ETF"` |
| 9 | `PENSION_FUND_REPORT` | `13, "Báo cáo quỹ hưu trí"` |
| 10 | `SELF_MANAGED_DTK_REPORT` | `14, "Báo cáo công ty ĐTCK riêng lẻ tự quản lý"` |
| 11 | `DISTRIBUTOR_AGENT_REPORT` | `15, "Báo cáo đại lý phân phối"` |
| 12 | `TRANSFER_AGENT_REPORT` | `16, "Báo cáo đại lý chuyển nhượng"` |
| 13 | `PENSION_AGENT_REPORT` | `17, "Báo cáo đại lý hưu trí"` |
| 14 | `PENSION_PROVIDER_REPORT` | `18, "Báo cáo Tổ chức cung cấp dịch vụ quản trị tài khoản hưu trí cá nhân"` |
| 15 | `CBTT_FORM` | `19, "Biểu mẫu CBTT"` |
| 16 | `BANK_MONI_REPORT` | `9, "Báo cáo ngân hàng LKGS"` |
| 17 | `OFFICES_BRANCH_REPORT` | `10, "Báo cáo CN công ty QLQ nước ngoài"` |
| 18 | `OFFICES_REPORT` | `11, "Báo cáo VPĐD công ty QLQ nước ngoài"` |
| 19 | `OTHER` | `12, "Khác"` |

## `ReportOutGroupsEnum`

**File:** `com/tinhvan/fmsservice/common/enums/ReportOutGroupsEnum.java`  
**Số giá trị:** 17

| # | Constant | Code / tham số constructor |
|---|----------|----------------------------|
| 1 | `SUPERVISION_SUMMARY` | `1, "Thống kê, tổng hợp báo cáo giám sát"` |
| 2 | `APPRAISAL_SUPPORT_SUMMARY` | `2, "Thống kê, tổng hợp hỗ trợ thẩm định"` |
| 3 | `FMC_SUMMARY` | `3, "Thống kê, tổng hợp công ty QLQ"` |
| 4 | `FUND_SUMMARY` | `4, "Thống kê, tổng hợp quỹ đầu tư"` |
| 5 | `CUSTODIAN_BANK_SUMMARY` | `5, "Thống kê, tổng hợp Ngân hàng LKGS"` |
| 6 | `FOREIGN_BRANCH_SUMMARY` | `6, "Thống kê, tổng hợp CN công ty QLQ nước ngoài tại VN"` |
| 7 | `FOREIGN_REPRESENTATIVE_OFFICE_SUMMARY` | `7, "Thống kê, tổng hợp VPĐD công ty QLQ NN tại VN"` |
| 8 | `SELF_MANAGED_SECURITIES_COMPANY_SUMMARY` | `8, "Thống kê Công ty ĐTCK riêng lẻ tự quản lý"` |
| 9 | `DISTRIBUTOR_AGENT_SUMMARY` | `9, "Thống kê, tổng hợp Đại lý phân phối"` |
| 10 | `TRANSFER_AGENT_SUMMARY` | `10, "Thống kê, tổng hợp Đại lý chuyển nhượng"` |
| 11 | `PENSION_FUND_SUMMARY` | `11, "Thống kê, tổng hợp Quỹ hưu trí"` |
| 12 | `PENSION_AGENT_SUMMARY` | `12, "Thống kê, tổng hợp Đại lý hưu trí"` |
| 13 | `PENSION_PROVIDER_SUMMARY` | `13, "Thống kê, tổng hợp Tổ chức cung cấp dịch vụ quản trị tài khoản hưu trí cá nhân"` |
| 14 | `INSIDER_SUMMARY` | `14, "Thống kê, tổng hợp người nội bộ, người có liên quan của người nội bộ"` |
| 15 | `INSPECTION_SUMMARY` | `15, "Thống kê, tổng hợp thanh tra, kiểm tra, xử phạt"` |
| 16 | `AUDIT_SUMMARY` | `16, "Thống kê, tổng hợp Công ty kiểm toán, Kiểm toán viên"` |
| 17 | `OTHER_SUMMARY` | `17, "Thống kê, tổng hợp khác"` |

## `ReportTypeEnum`

**File:** `com/tinhvan/fmsservice/common/enums/ReportTypeEnum.java`  
**Số giá trị:** 4

| # | Constant | Code / tham số constructor |
|---|----------|----------------------------|
| 1 | `PERIODIC` | `1, "Báo cáo định kỳ"` |
| 2 | `IRREGULAR` | `2, "Báo cáo bất thường"` |
| 3 | `ON_REQUEST` | `3, "Báo cáo theo yêu cầu"` |
| 4 | `OTHER` | `4, "Báo cáo khác"` |

## `ResponseCode`

**File:** `com/tinhvan/fmsservice/common/enums/ResponseCode.java`  
**Số giá trị:** 206

| # | Constant | Code / tham số constructor |
|---|----------|----------------------------|
| 1 | `SUCCESS` | `"SUCCESS", HttpStatus.OK, "OK"` |
| 2 | `DUPLICATE_NAME` | `"DUPLICATE_NAME", HttpStatus.OK, "Tên đã tồn tại"` |
| 3 | `DUPLICATE_CODE` | `"DUPLICATE_CODE", HttpStatus.OK, "Mã đã tồn tại"` |
| 4 | `CAPITAL_INVALID` | `"CAPITAL_INVALID", HttpStatus.OK, "Vốn điều lệ không được thấp hơn vốn pháp định"` |
| 5 | `DUPLICATE_IDCODE` | `"DUPLICATE_IDCODE", HttpStatus.OK, "Số CMND/CCCD đã tồn tại trong hệ thống"` |
| 6 | `DUPLICATE_REPRESENT` | `"DUPLICATE_REPRESENT", HttpStatus.OK, "VPĐD/CNNN này đã có người đại diện"` |
| 7 | `DUPLICATE_ISP` | `"DUPLICATE_ISP", HttpStatus.OK, "VPĐD/CNNN này đã có người phụ trách ISP"` |
| 8 | `RESOURCE_NOT_FOUND` | `"RESOURCE_NOT_FOUND", HttpStatus.NOT_FOUND, "Không tìm thấy dữ liệu"` |
| 9 | `DELETE_HAS_REFERENCE` | `"DELETE_HAS_REFERENCE", HttpStatus.OK, "Không thể xóa vì đang được sử dụng"` |
| 10 | `MBFUND_EXISTS` | `"MBFUND_EXISTS", HttpStatus.OK, "Nhà đầu tư quỹ đã tồn tại"` |
| 11 | `CAPITAL_MBFUND_INVALID` | `"CAPITAL_MBFUND_INVALID", HttpStatus.OK, "Vốn góp phải lớn hơn 0"` |
| 12 | `SUM_CAPITAL_MBFUND_INVALID` | `"SUM_CAPITAL_MBFUND_INVALID", HttpStatus.OK, "Tổng vốn góp vượt quá vốn điều lệ quỹ"` |
| 13 | `ADD_FAILED` | `"ADD_FAILED", HttpStatus.OK, "Thêm thất bại"` |
| 14 | `UPDATE_FAILED` | `"UPDATE_FAILED", HttpStatus.OK, "Cập nhật thất bại"` |
| 15 | `BUSINESS_ERROR` | `"BUSINESS_ERROR", HttpStatus.OK, "Lỗi nghiệp vụ"` |
| 16 | `VALIDATION_ERROR` | `"VALIDATION_ERROR", HttpStatus.BAD_REQUEST, "Dữ liệu không hợp lệ"` |
| 17 | `INVALID_REQUEST` | `"INVALID_REQUEST", HttpStatus.BAD_REQUEST, "Yêu cầu không hợp lệ"` |
| 18 | `FILE_INVALID` | `"FILE_INVALID", HttpStatus.BAD_REQUEST, "File không hợp lệ"` |
| 19 | `FACTOR_WEIGHT_PERCENT_EXCEED` | `"FACTOR_WEIGHT_PERCENT_EXCEED", HttpStatus.OK, "Tổng trọng số các nhân tố trong nhóm vượt quá 100%"` |
| 20 | `FACTOR_PARENT_REQUIRED` | `"FACTOR_PARENT_REQUIRED", HttpStatus.OK, "Vui lòng chọn nhân tố cha"` |
| 21 | `FACTOR_SNAPSHOT_EMPTY` | `"FACTOR_SNAPSHOT_EMPTY", HttpStatus.OK, "Không có nhóm nhân tố đang hoạt động để lưu snapshot"` |
| 22 | `FACTOR_SNAPSHOT_SERIALIZE_ERROR` | `"FACTOR_SNAPSHOT_SERIALIZE_ERROR", HttpStatus.INTERNAL_SERVER_ERROR, "Lỗi khi serialize dữ liệu snapshot nhân tố"` |
| 23 | `BANKMONI_CANNOT_DELETE_HAS_FUNDS` | `"BANKMONI_CANNOT_DELETE_HAS_FUNDS", HttpStatus.OK, "Không thể xóa vì đang có quỹ đang hoạt động"` |
| 24 | `BANKMONI_CANNOT_DELETE_HAS_BANK_EMPLOY` | `"BANKMONI_CANNOT_DELETE_HAS_BANK_EMPLOY", HttpStatus.OK, "Không thể xóa vì đang có nhân sự ngân hàng đang hoạt động"` |
| 25 | `BANKMONI_CANNOT_DELETE_HAS_REPORTS` | `"BANKMONI_CANNOT_DELETE_HAS_REPORTS", HttpStatus.OK, "Không thể xóa vì ngân hàng đã có dữ liệu báo cáo trong phân hệ"` |
| 26 | `BANKMONI_BANK_CODE_EXISTS` | `"BANKMONI_BANK_CODE_EXISTS", HttpStatus.OK, "Mã ngân hàng đã tồn tại"` |
| 27 | `BANKMONI_EVENT_TYPE_REQUIRED` | `"BANKMONI_EVENT_TYPE_REQUIRED", HttpStatus.OK, "Sự vụ không được để trống khi cập nhật hồ sơ ngân hàng"` |
| 28 | `BANKMONI_PROVINCE_REQUIRED` | `"BANKMONI_PROVINCE_REQUIRED", HttpStatus.OK, "Tỉnh/thành phố không được để trống"` |
| 29 | `BANKMONI_WARD_REQUIRED` | `"BANKMONI_WARD_REQUIRED", HttpStatus.OK, "Xã/phường không được để trống"` |
| 30 | `BANKMONI_PROVINCE_NOT_FOUND` | `"BANKMONI_PROVINCE_NOT_FOUND", HttpStatus.OK, "Tỉnh/thành phố không tồn tại trong danh mục"` |
| 31 | `BANKMONI_WARD_NOT_FOUND` | `"BANKMONI_WARD_NOT_FOUND", HttpStatus.OK, "Xã/phường không tồn tại trong danh mục"` |
| 32 | `BANKMONI_WARD_PROVINCE_MISMATCH` | `"BANKMONI_WARD_PROVINCE_MISMATCH", HttpStatus.OK, "Xã/phường không thuộc tỉnh/thành phố đã chọn"` |
| 33 | `BANKEMPLOY_IDNO_EXISTS` | `"BANKEMPLOY_IDNO_EXISTS", HttpStatus.OK, "Nhân sự với số CMND này đã tồn tại trong ngân hàng"` |
| 34 | `BANKEMPLOY_CANNOT_CHANGE_BANK` | `"BANKEMPLOY_CANNOT_CHANGE_BANK", HttpStatus.OK, "Không cho phép thay đổi ngân hàng khi cập nhật nhân sự"` |
| 35 | `BANKEMPLOY_EVENT_TYPE_REQUIRED` | `"BANKEMPLOY_EVENT_TYPE_REQUIRED", HttpStatus.OK, "Sự vụ không được để trống khi cập nhật nhân sự ngân hàng"` |
| 36 | `CERTFCATE_SERIAL_EXISTS` | `"CERTFCATE_SERIAL_EXISTS", HttpStatus.OK, "Số serial chứng chỉ hành nghề đã tồn tại"` |
| 37 | `AGENCIES_SHORTNAME_EXISTS` | `"AGENCIES_SHORTNAME_EXISTS", HttpStatus.OK, "Tên viết tắt đã tồn tại"` |
| 38 | `AGENCIES_CANNOT_DELETE_HAS_REFERENCE` | `"AGENCIES_CANNOT_DELETE_HAS_REFERENCE", HttpStatus.OK, "Không thể xóa đại lý vì đang được sử dụng"` |
| 39 | `DISTRIBUTOR_AGENT_TAX_CODE_DUPLICATE` | `"DISTRIBUTOR_AGENT_TAX_CODE_DUPLICATE", HttpStatus.OK, "Mã số doanh nghiệp đại lý phân phối đã tồn tại trong hệ thống"` |
| 40 | `DISTRIBUTOR_AGENT_HAS_FUND` | `"DISTRIBUTOR_AGENT_HAS_FUND", HttpStatus.OK, "Không thể xóa đại lý phân phối vì đang được khai báo cho quỹ đầu tư"` |
| 41 | `TRANSFER_AGENT_TAX_CODE_DUPLICATE` | `"TRANSFER_AGENT_TAX_CODE_DUPLICATE", HttpStatus.OK, "Mã số doanh nghiệp đại lý chuyển nhượng đã tồn tại trong hệ thống"` |
| 42 | `TRANSFER_AGENT_HAS_FUND` | `"TRANSFER_AGENT_HAS_FUND", HttpStatus.OK, "Không thể xóa đại lý chuyển nhượng vì đang được khai báo cho quỹ đầu tư"` |
| 43 | `PENSION_AGENT_IN_USE` | `"PENSION_AGENT_IN_USE", HttpStatus.OK, "Không thể xóa đại lý hưu trí đã được khai báo cho quỹ hưu trí"` |
| 44 | `PENSION_AGENT_INVALID_LICENSE_DATE` | `"PENSION_AGENT_INVALID_LICENSE_DATE", HttpStatus.OK, "Ngày cấp không được lớn hơn ngày hiện tại"` |
| 45 | `PENSION_AGENT_INVALID_TERMINATION_DATE` | `"PENSION_AGENT_INVALID_TERMINATION_DATE", HttpStatus.OK, "Ngày chấm dứt hoạt động không được nhỏ hơn ngày cấp"` |
| 46 | `PENSION_AGENT_INVALID_TAX_CODE` | `"PENSION_AGENT_INVALID_TAX_CODE", HttpStatus.OK, "Định dạng Mã số doanh nghiệp không hợp lệ"` |
| 47 | `PENSION_PROVIDER_IN_USE` | `"PENSION_PROVIDER_IN_USE", HttpStatus.OK, "Không thể xóa tổ chức cung cấp dịch vụ quản trị tài khoản hưu trí cá nhân đã được khai báo cho quỹ hưu trí"` |
| 48 | `PENSION_PROVIDER_INVALID_LICENSE_DATE` | `"PENSION_PROVIDER_INVALID_LICENSE_DATE", HttpStatus.OK, "Ngày cấp không được lớn hơn ngày hiện tại"` |
| 49 | `PENSION_PROVIDER_INVALID_TERMINATION_DATE` | `"PENSION_PROVIDER_INVALID_TERMINATION_DATE", HttpStatus.OK, "Ngày chấm dứt hoạt động không được nhỏ hơn ngày cấp"` |
| 50 | `PENSION_FUND_NOT_FOUND` | `"PENSION_FUND_NOT_FOUND", HttpStatus.NOT_FOUND, "Không tìm thấy quỹ hưu trí"` |
| 51 | `AUDIT_FIRM_REMINDER_AUDITOR_REQUIRED` | `"AUDIT_FIRM_REMINDER_AUDITOR_REQUIRED", HttpStatus.OK, "Kiểm toán viên là bắt buộc khi đối tượng nhắc nhở là Kiểm toán viên"` |
| 52 | `AUDIT_FIRM_REMINDER_AUDITOR_NOT_IN_FIRM` | `"AUDIT_FIRM_REMINDER_AUDITOR_NOT_IN_FIRM", HttpStatus.OK, "Kiểm toán viên không thuộc công ty kiểm toán đã chọn"` |
| 53 | `AUDIT_FIRM_REMINDER_EMAIL_NOT_CONFIGURED` | `"AUDIT_FIRM_REMINDER_EMAIL_NOT_CONFIGURED", HttpStatus.OK, "Chức năng gửi email chưa được tích hợp — đang chờ Phase 8B.3"` |
| 54 | `AUDIT_FIRM_REMINDER_CANNOT_CHANGE_TARGET` | `"AUDIT_FIRM_REMINDER_CANNOT_CHANGE_TARGET", HttpStatus.OK, "Không được phép thay đổi đối tượng và thành viên khi chỉnh sửa nhắc nhở"` |
| 55 | `OTHER_AGENT_IN_USE` | `"OTHER_AGENT_IN_USE", HttpStatus.OK, "Không thể xóa đại lý khác đã được khai báo"` |
| 56 | `OTHER_AGENT_INVALID_LICENSE_DATE` | `"OTHER_AGENT_INVALID_LICENSE_DATE", HttpStatus.OK, "Ngày cấp không được lớn hơn ngày hiện tại"` |
| 57 | `OTHER_AGENT_INVALID_TERMINATION_DATE` | `"OTHER_AGENT_INVALID_TERMINATION_DATE", HttpStatus.OK, "Ngày chấm dứt hoạt động không được nhỏ hơn ngày cấp"` |
| 58 | `SECURITIES_HAS_TLPROFILES` | `"SECURITIES_HAS_TLPROFILES", HttpStatus.OK, "Không thể xóa vì còn nhân sự đang hoạt động"` |
| 59 | `SECURITIES_HAS_FUNDS` | `"SECURITIES_HAS_FUNDS", HttpStatus.OK, "Không thể xóa vì còn quỹ đang hoạt động"` |
| 60 | `SECURITIES_HAS_BRANCHS` | `"SECURITIES_HAS_BRANCHS", HttpStatus.OK, "Không thể xóa vì còn chi nhánh đang hoạt động"` |
| 61 | `SECURITIES_HAS_INSIDERS` | `"SECURITIES_HAS_INSIDERS", HttpStatus.OK, "Không thể xóa vì còn cổ đông đang hoạt động"` |
| 62 | `SECURITIES_HAS_STAKES` | `"SECURITIES_HAS_STAKES", HttpStatus.OK, "Không thể xóa vì còn cổ đông/thành viên góp vốn đang hoạt động"` |
| 63 | `SECURITIES_HAS_INVES` | `"SECURITIES_HAS_INVES", HttpStatus.OK, "Không thể xóa vì còn nhà đầu tư ủy thác đang hoạt động"` |
| 64 | `SECURITIES_HAS_TRSFERINDERS` | `"SECURITIES_HAS_TRSFERINDERS", HttpStatus.OK, "Không thể xóa vì còn chuyển nhượng người hành nghề đang hoạt động"` |
| 65 | `SECURITIES_HAS_RPTMBS` | `"SECURITIES_HAS_RPTMBS", HttpStatus.OK, "Không thể xóa vì còn báo cáo thành viên đang hoạt động"` |
| 66 | `SECURITIES_HAS_ANNOUNCE` | `"SECURITIES_HAS_ANNOUNCE", HttpStatus.OK, "Không thể xóa vì còn thông tin công bố"` |
| 67 | `SECURITIES_HAS_RANKS` | `"SECURITIES_HAS_RANKS", HttpStatus.OK, "Không thể xóa vì còn xếp hạng"` |
| 68 | `SECURITIES_HAS_VIOLTS` | `"SECURITIES_HAS_VIOLTS", HttpStatus.OK, "Không thể xóa vì còn vi phạm"` |
| 69 | `SECURITIES_HAS_SEFPDS` | `"SECURITIES_HAS_SEFPDS", HttpStatus.OK, "Không thể xóa vì còn kỳ đánh giá"` |
| 70 | `SECURITIES_LICENSE_REQUIRED` | `"SECURITIES_LICENSE_REQUIRED", HttpStatus.OK, "Vui lòng nhập số quyết định và ngày quyết định khi thay đổi thông tin quan trọng"` |
| 71 | `SECURITIES_INVALID_LEGAL_REP` | `"SECURITIES_INVALID_LEGAL_REP", HttpStatus.OK, "Người đại diện theo pháp luật không hợp lệ — phải là nhân sự của công ty QLQ này"` |
| 72 | `SECURITIES_BUSINESS_BRA_IN_USE` | `"SECURITIES_BUSINESS_BRA_IN_USE", HttpStatus.OK, "Nghiệp vụ kinh doanh đang được sử dụng tại chi nhánh"` |
| 73 | `SECURITIES_BUSINESS_TLPR_IN_USE` | `"SECURITIES_BUSINESS_TLPR_IN_USE", HttpStatus.OK, "Nghiệp vụ kinh doanh đang được sử dụng tại nhân sự"` |
| 74 | `SECURITIES_EMAIL_INVALID` | `"SECURITIES_EMAIL_INVALID", HttpStatus.OK, "Địa chỉ email không hợp lệ"` |
| 75 | `SECURITIES_WEBSITE_INVALID` | `"SECURITIES_WEBSITE_INVALID", HttpStatus.OK, "Địa chỉ website không hợp lệ"` |
| 76 | `SECURITIES_PROVINCE_REQUIRED` | `"SECURITIES_PROVINCE_REQUIRED", HttpStatus.OK, "Tỉnh/thành phố không được để trống"` |
| 77 | `SECURITIES_WARD_REQUIRED` | `"SECURITIES_WARD_REQUIRED", HttpStatus.OK, "Xã/phường không được để trống"` |
| 78 | `SECURITIES_COUNTRY_REQUIRED` | `"SECURITIES_COUNTRY_REQUIRED", HttpStatus.OK, "Quốc gia không được để trống"` |
| 79 | `SECURITIES_PROVINCE_NOT_FOUND` | `"SECURITIES_PROVINCE_NOT_FOUND", HttpStatus.OK, "Tỉnh/thành phố không tồn tại trong danh mục"` |
| 80 | `SECURITIES_WARD_NOT_FOUND` | `"SECURITIES_WARD_NOT_FOUND", HttpStatus.OK, "Xã/phường không tồn tại trong danh mục"` |
| 81 | `SECURITIES_COUNTRY_NOT_FOUND` | `"SECURITIES_COUNTRY_NOT_FOUND", HttpStatus.OK, "Quốc gia không tồn tại trong danh mục"` |
| 82 | `SECURITIES_WARD_PROVINCE_MISMATCH` | `"SECURITIES_WARD_PROVINCE_MISMATCH", HttpStatus.OK, "Xã/phường không thuộc tỉnh/thành phố đã chọn"` |
| 83 | `BRANCHS_LICENSE_REQUIRED` | `"BRANCHS_LICENSE_REQUIRED", HttpStatus.OK, "Vui lòng nhập số chấp thuận điều chỉnh và ngày chấp thuận khi thay đổi tên hoặc địa chỉ chi nhánh"` |
| 84 | `OFFICES_PROVINCE_REQUIRED` | `"OFFICES_PROVINCE_REQUIRED", HttpStatus.OK, "Tỉnh/thành phố không được để trống"` |
| 85 | `OFFICES_WARD_REQUIRED` | `"OFFICES_WARD_REQUIRED", HttpStatus.OK, "Xã/phường không được để trống"` |
| 86 | `OFFICES_PROVINCE_NOT_FOUND` | `"OFFICES_PROVINCE_NOT_FOUND", HttpStatus.OK, "Tỉnh/thành phố không tồn tại trong danh mục"` |
| 87 | `OFFICES_WARD_NOT_FOUND` | `"OFFICES_WARD_NOT_FOUND", HttpStatus.OK, "Xã/phường không tồn tại trong danh mục"` |
| 88 | `OFFICES_WARD_PROVINCE_MISMATCH` | `"OFFICES_WARD_PROVINCE_MISMATCH", HttpStatus.OK, "Xã/phường không thuộc tỉnh/thành phố đã chọn"` |
| 89 | `BRANCHS_HAS_TLPROFILES` | `"BRANCHS_HAS_TLPROFILES", HttpStatus.OK, "Không thể xóa chi nhánh vì còn nhân sự đang hoạt động"` |
| 90 | `BRANCHS_INVALID_DIRECTOR` | `"BRANCHS_INVALID_DIRECTOR", HttpStatus.OK, "Giám đốc chi nhánh không hợp lệ — phải là nhân sự của công ty QLQ quản lý chi nhánh này"` |
| 91 | `INSDERRPRST_INSIDER_IS_PERSONAL` | `"INSDERRPRST_INSIDER_IS_PERSONAL", HttpStatus.OK, "Cổ đông này là cá nhân, không thể thêm người đại diện"` |
| 92 | `INSDERRPRST_PER_REP_INVALID` | `"INSDERRPRST_PER_REP_INVALID", HttpStatus.OK, "Tỉ lệ đại diện phải trong khoảng 0 đến 100"` |
| 93 | `INSIDER_TLPROFILE_NOT_FOUND` | `"INSIDER_TLPROFILE_NOT_FOUND", HttpStatus.OK, "Không tìm thấy nhân sự được chọn"` |
| 94 | `INSIDER_TLPROFILE_NOT_IN_COMPANY` | `"INSIDER_TLPROFILE_NOT_IN_COMPANY", HttpStatus.OK, "Nhân sự không thuộc công ty đã chọn"` |
| 95 | `INSIDER_UPDATE_NO_CHANGES` | `"INSIDER_UPDATE_NO_CHANGES", HttpStatus.OK, "Không có thay đổi thông tin"` |
| 96 | `INSIDER_MODIFY_REASON_REQUIRED` | `"INSIDER_MODIFY_REASON_REQUIRED", HttpStatus.OK, "Lý do sửa đổi không được để trống"` |
| 97 | `INSIDER_INSDCHANGE_DELETE` | `"INSIDER_INSDCHANGE_DELETE", HttpStatus.OK, "Bản ghi đang có lịch sử thay đổi vốn góp, bạn không thể xóa!"` |
| 98 | `INSIDER_TRSFER_DELETE` | `"INSIDER_TRSFER_DELETE", HttpStatus.OK, "Bản ghi đang có thông tin chuyển nhượng, bạn không thể xóa!"` |
| 99 | `INSDER_RELA_INVALID_ID_DATE` | `"INSDER_RELA_INVALID_ID_DATE", HttpStatus.OK, "Ngày cấp không được lớn hơn ngày hiện tại"` |
| 100 | `INSDER_RELA_MODIFY_REASON_REQUIRED` | `"INSDER_RELA_MODIFY_REASON_REQUIRED", HttpStatus.OK, "Lý do sửa đổi không được để trống"` |
| 101 | `INSDER_RELA_UPDATE_NO_CHANGES` | `"INSDER_RELA_UPDATE_NO_CHANGES", HttpStatus.OK, "Không có thay đổi để lưu"` |
| 102 | `TRSFERINDER_IN_FRM_IN_TO_CANNOT_EQUAL` | `"TRSFERINDER_IN_FRM_IN_TO_CANNOT_EQUAL", HttpStatus.OK, "Cổ đông chuyển nhượng và nhận nhượng không được trùng nhau"` |
| 103 | `TRSFERINDER_TRANSFER_AMOUNT_INVALID` | `"TRSFERINDER_TRANSFER_AMOUNT_INVALID", HttpStatus.OK, "Số lượng chuyển nhượng không hợp lệ (phải > 0 và <= số đang nắm giữ của bên chuyển nhượng)"` |
| 104 | `TRSFERINDER_CANNOT_EDIT_TRANSFEROR` | `"TRSFERINDER_CANNOT_EDIT_TRANSFEROR", HttpStatus.OK, "Không cho phép sửa thông tin bên chuyển nhượng"` |
| 105 | `TRSFERINDER_CANNOT_EDIT_TRANSFER_PARTIES` | `"TRSFERINDER_CANNOT_EDIT_TRANSFER_PARTIES", HttpStatus.OK, "Không cho phép sửa thông tin bên chuyển/nhận của giao dịch"` |
| 106 | `TRSFERINDER_MODIFY_REASON_REQUIRED` | `"TRSFERINDER_MODIFY_REASON_REQUIRED", HttpStatus.OK, "Lý do sửa đổi không được để trống"` |
| 107 | `TRSFERINDER_UPDATE_NO_CHANGES` | `"TRSFERINDER_UPDATE_NO_CHANGES", HttpStatus.OK, "Không có thay đổi để lưu"` |
| 108 | `INSPECTION_INVALID_PERIOD_DATES` | `"INSPECTION_INVALID_PERIOD_DATES", HttpStatus.OK, "Thời gian kiểm tra không hợp lệ (startDate phải <= endDate)"` |
| 109 | `INSPECTION_CANNOT_CHANGE_OBJECT_TYPE` | `"INSPECTION_CANNOT_CHANGE_OBJECT_TYPE", HttpStatus.OK, "Không cho phép thay đổi loại đối tượng khi cập nhật đợt kiểm tra"` |
| 110 | `INSPECTION_TARGET_NOT_IN_ROUND` | `"INSPECTION_TARGET_NOT_IN_ROUND", HttpStatus.OK, "Đối tượng xử phạt không thuộc đợt kiểm tra đã chọn"` |
| 111 | `TLPROFILES_IDNO_EXISTS` | `"TLPROFILES_IDNO_EXISTS", HttpStatus.OK, "Nhân sự với CMND/CCCD này đã tồn tại trong công ty"` |
| 112 | `TLPROFILES_ISP_EXISTS` | `"TLPROFILES_ISP_EXISTS", HttpStatus.OK, "Công ty đã có người công bố thông tin"` |
| 113 | `TLPROFILES_HOST_EXISTS` | `"TLPROFILES_HOST_EXISTS", HttpStatus.OK, "Chi nhánh đã có người phụ trách"` |
| 114 | `TLPROFILES_IS_CERT_CANNOT_DELETE` | `"TLPROFILES_IS_CERT_CANNOT_DELETE", HttpStatus.OK, "Không thể xóa nhân sự đã được xác nhận hành nghề"` |
| 115 | `TLPROFILES_WORK_DATES_INVALID` | `"TLPROFILES_WORK_DATES_INVALID", HttpStatus.OK, "Ngày kết thúc làm việc không được nhỏ hơn ngày bắt đầu"` |
| 116 | `TLPROFILES_EXPIRED_REQUIRES_END_DATE` | `"TLPROFILES_EXPIRED_REQUIRES_END_DATE", HttpStatus.OK, "Trạng thái Hết hiệu lực bắt buộc nhập ngày kết thúc làm việc"` |
| 117 | `TLPROFILES_CERT_REQUIRED` | `"TLPROFILES_CERT_REQUIRED", HttpStatus.OK, "Có chứng chỉ hành nghề thì bắt buộc nhập số CCHN, ngày cấp CCHN và bộ phận nghiệp vụ"` |
| 118 | `TLPROFILES_CERT_NUMBER_DATE_REQUIRED` | `"TLPROFILES_CERT_NUMBER_DATE_REQUIRED", HttpStatus.OK, "Có chứng chỉ hành nghề thì bắt buộc nhập số CCHN và ngày cấp CCHN"` |
| 119 | `TLPROFILES_CERT_BUSINESS_REQUIRED` | `"TLPROFILES_CERT_BUSINESS_REQUIRED", HttpStatus.OK, "Bắt buộc chọn bộ phận nghiệp vụ khi có chứng chỉ hành nghề (công ty không thuộc nhóm ĐTCK riêng lẻ tự quản lý)"` |
| 120 | `TLPROFILES_CERT_FORBIDDEN_WHEN_NO_CERT` | `"TLPROFILES_CERT_FORBIDDEN_WHEN_NO_CERT", HttpStatus.OK, "Không có CCHN thì không được nhập thông tin chứng chỉ hành nghề"` |
| 121 | `TLPROFILES_CBTT_EMAIL_NOT_ALLOWED` | `"TLPROFILES_CBTT_EMAIL_NOT_ALLOWED", HttpStatus.OK, "Chỉ được nhập email CBTT khi là đại diện công bố thông tin"` |
| 122 | `TLPROFILES_BRANCH_NOT_IN_COMPANY` | `"TLPROFILES_BRANCH_NOT_IN_COMPANY", HttpStatus.OK, "Nơi làm việc không thuộc công ty đã chọn"` |
| 123 | `TLPROFILES_HOST_REQUIRES_BRANCH` | `"TLPROFILES_HOST_REQUIRES_BRANCH", HttpStatus.OK, "Đại diện VPĐD/Giám đốc CN yêu cầu chọn chi nhánh/văn phòng"` |
| 124 | `TLPROFILES_CANNOT_CHANGE_COMPANY` | `"TLPROFILES_CANNOT_CHANGE_COMPANY", HttpStatus.OK, "Không được phép thay đổi công ty quản lý quỹ của nhân sự"` |
| 125 | `TLPROFILES_UPDATE_EVENT_TYPE_REQUIRED` | `"TLPROFILES_UPDATE_EVENT_TYPE_REQUIRED", HttpStatus.OK, "Vui lòng chọn sự vụ thay đổi nhân sự"` |
| 126 | `TLPROFILES_UPDATE_REASON_REQUIRED` | `"TLPROFILES_UPDATE_REASON_REQUIRED", HttpStatus.OK, "Vui lòng nhập lý do sửa đổi"` |
| 127 | `TLPROFILES_EVENT_TYPE_INVALID` | `"TLPROFILES_EVENT_TYPE_INVALID", HttpStatus.OK, "Loại sự vụ không hợp lệ hoặc không thuộc danh mục Nhân sự"` |
| 128 | `TLPROFILES_EVENT_PAYLOAD_INVALID` | `"TLPROFILES_EVENT_PAYLOAD_INVALID", HttpStatus.OK, "Thông tin bổ sung theo sự vụ (JSON) không hợp lệ"` |
| 129 | `STAKE_CANNOT_CHANGE_SECURITY` | `"STAKE_CANNOT_CHANGE_SECURITY", HttpStatus.OK, "Không cho phép thay đổi công ty quản lý quỹ"` |
| 130 | `STFFGBRCH_LICENSE_REQUIRED` | `"STFFGBRCH_LICENSE_REQUIRED", HttpStatus.OK, "Vui lòng nhập số quyết định bổ nhiệm người đại diện"` |
| 131 | `STFFGBRCH_LICENSE_DATE_REQUIRED` | `"STFFGBRCH_LICENSE_DATE_REQUIRED", HttpStatus.OK, "Vui lòng nhập ngày quyết định bổ nhiệm người đại diện"` |
| 132 | `STFFGBRCH_FILE_DATA_REQUIRED` | `"STFFGBRCH_FILE_DATA_REQUIRED", HttpStatus.OK, "Vui lòng đính kèm file quyết định bổ nhiệm người đại diện"` |
| 133 | `FTORSCALE_NOT_FOUND_FOR_FACTOR` | `"FTORSCALE_NOT_FOUND_FOR_FACTOR", HttpStatus.OK, "Không tìm thấy thang điểm cho nhân tố này"` |
| 134 | `FTORSCALE_MINUS_SCORE_EXCEEDED` | `"FTORSCALE_MINUS_SCORE_EXCEEDED", HttpStatus.OK, "Điểm trừ vượt quá giới hạn tối đa cho phép"` |
| 135 | `FTORSCALE_FACTOR_NOT_FOUND` | `"FTORSCALE_FACTOR_NOT_FOUND", HttpStatus.OK, "Nhân tố không tồn tại"` |
| 136 | `FTORSCALE_CONDITION_REQUIRED` | `"FTORSCALE_CONDITION_REQUIRED", HttpStatus.OK, "Vui lòng nhập điều kiện (FromValue/ToValue)"` |
| 137 | `FTORSCALE_CONDITION_INVALID` | `"FTORSCALE_CONDITION_INVALID", HttpStatus.OK, "Điều kiện không hợp lệ (giá trị và điều kiện phải cùng có hoặc cùng trống)"` |
| 138 | `FTORSCALE_VALUE_RANGE_INVALID` | `"FTORSCALE_VALUE_RANGE_INVALID", HttpStatus.OK, "Giá trị FromValue phải nhỏ hơn ToValue"` |
| 139 | `PARAWARN_VIOLT_EXISTS` | `"PARAWARN_VIOLT_EXISTS", HttpStatus.OK, "Không thể sửa tham số cảnh báo vì đã có vi phạm được ghi nhận"` |
| 140 | `PARAWARN_FORMULA_LOCKED` | `"PARAWARN_FORMULA_LOCKED", HttpStatus.OK, "Không thể sửa công thức của tham số vì đã có dữ liệu vi phạm liên quan"` |
| 141 | `PARAWARN_SYSTEM_OBJECT_LOCKED` | `"PARAWARN_SYSTEM_OBJECT_LOCKED", HttpStatus.OK, "Không được sửa đối tượng cảnh báo của tham số"` |
| 142 | `CDTWARN_CONDITION_NOT_FOUND` | `"CDTWARN_CONDITION_NOT_FOUND", HttpStatus.OK, "Điều kiện cảnh báo không được để trống"` |
| 143 | `CDTWARN_CONDITION_INVALID` | `"CDTWARN_CONDITION_INVALID", HttpStatus.OK, "Điều kiện cảnh báo không hợp lệ (giá trị và điều kiện phải cùng có hoặc cùng trống)"` |
| 144 | `CDTWARN_VALUE_RANGE_INVALID` | `"CDTWARN_VALUE_RANGE_INVALID", HttpStatus.OK, "Giá trị FromValue phải nhỏ hơn ToValue"` |
| 145 | `CDTWARN_HAS_VIOLT` | `"CDTWARN_HAS_VIOLT", HttpStatus.OK, "Không thể xóa điều kiện cảnh báo vì đang có vi phạm liên kết"` |
| 146 | `VIOLT_INVALID_RECOVERY_STATUS_TRANSITION` | `"VIOLT_INVALID_RECOVERY_STATUS_TRANSITION", HttpStatus.OK, "Trạng thái khắc phục không hợp lệ"` |
| 147 | `RATINGPD_ALREADY_EXISTS` | `"RATINGPD_ALREADY_EXISTS", HttpStatus.OK, "Kỳ đánh giá với năm và kỳ này đã tồn tại"` |
| 148 | `RATINGPD_HAS_RANKS` | `"RATINGPD_HAS_RANKS", HttpStatus.OK, "Không thể thực hiện vì kỳ đánh giá đã có dữ liệu xếp loại"` |
| 149 | `RATINGPD_RATING_IN_PROGRESS` | `"RATINGPD_RATING_IN_PROGRESS", HttpStatus.OK, "Hệ thống đang xử lý đánh giá xếp loại cho kỳ này"` |
| 150 | `RATINGPD_NOT_FOUND` | `"RATINGPD_NOT_FOUND", HttpStatus.OK, "Không tìm thấy kỳ đánh giá"` |
| 151 | `RATINGPD_ALREADY_ENDED` | `"RATINGPD_ALREADY_ENDED", HttpStatus.OK, "Kỳ đánh giá đã kết thúc, không thể thao tác"` |
| 152 | `RATINGPD_SNAPSHOT_EMPTY` | `"RATINGPD_SNAPSHOT_EMPTY", HttpStatus.OK, "Không có dữ liệu xếp hạng để lưu snapshot"` |
| 153 | `RPTTPOUT_REPORT_GROUP_REQUIRED` | `"RPTTPOUT_REPORT_GROUP_REQUIRED", HttpStatus.OK, "Vui lòng chọn nhóm báo cáo"` |
| 154 | `RPTTPOUT_CODE_EXISTS` | `"RPTTPOUT_CODE_EXISTS", HttpStatus.OK, "Mã biểu mẫu báo cáo đầu ra đã tồn tại"` |
| 155 | `RPTTPOUT_SYSTEM_OBJECT_CANNOT_CHANGE` | `"RPTTPOUT_SYSTEM_OBJECT_CANNOT_CHANGE", HttpStatus.OK, "Không thể thay đổi đối tượng hệ thống"` |
| 156 | `RPTTPOUT_NOT_FOUND` | `"RPTTPOUT_NOT_FOUND", HttpStatus.NOT_FOUND, "Không tìm thấy biểu mẫu báo cáo đầu ra"` |
| 157 | `RPTTPOUT_IN_USE` | `"RPTTPOUT_IN_USE", HttpStatus.OK, "Không thể xóa biểu mẫu đã được phân quyền cho người dùng"` |
| 158 | `RPTOUTGROUP_CODE_EXISTS` | `"RPTOUTGROUP_CODE_EXISTS", HttpStatus.OK, "Mã nhóm tổng hợp đã tồn tại"` |
| 159 | `RPTOUTGROUP_NOT_FOUND` | `"RPTOUTGROUP_NOT_FOUND", HttpStatus.NOT_FOUND, "Không tìm thấy nhóm tổng hợp báo cáo"` |
| 160 | `EXPORT_RPT_NOT_FOUND` | `"EXPORT_RPT_NOT_FOUND", HttpStatus.OK, "Biểu mẫu báo cáo không tồn tại"` |
| 161 | `EXPORT_RPT_NO_SHEET` | `"EXPORT_RPT_NO_SHEET", HttpStatus.OK, "Biểu mẫu báo cáo chưa có sheet"` |
| 162 | `EXPORT_FILE_INVALID` | `"EXPORT_FILE_INVALID", HttpStatus.OK, "File tải xuống không hợp lệ"` |
| 163 | `EXPORT_FAILED` | `"EXPORT_FAILED", HttpStatus.OK, "Kết xuất không thành công"` |
| 164 | `RPT_MEMBER_INVALID_STATUS` | `"RPT_MEMBER_INVALID_STATUS", HttpStatus.OK, "Trạng thái báo cáo không hợp lệ cho thao tác này"` |
| 165 | `RPT_MEMBER_INVALID_APPROVAL_ACTION` | `"RPT_MEMBER_INVALID_APPROVAL_ACTION", HttpStatus.OK, "Hành động phê duyệt không hợp lệ"` |
| 166 | `RPT_MEMBER_INVALID_DATE_RANGE` | `"RPT_MEMBER_INVALID_DATE_RANGE", HttpStatus.OK, "Khoảng ngày không hợp lệ: Từ ngày phải nhỏ hơn hoặc bằng Đến ngày"` |
| 167 | `RPT_MEMBER_DIRECT_INPUT_DISABLED` | `"RPT_MEMBER_DIRECT_INPUT_DISABLED", HttpStatus.OK, "Đã dừng luồng nhập báo cáo trực tiếp. Vui lòng gửi qua Cổng BCTT để đồng bộ về hệ thống"` |
| 168 | `EVENT_TYPE_IN_USE` | `"EVENT_TYPE_IN_USE", HttpStatus.OK, "Không thể xóa loại sự vụ đang được sử dụng"` |
| 169 | `REPRES_OFFICE_EVENT_TYPE_REQUIRED` | `"REPRES_OFFICE_EVENT_TYPE_REQUIRED", HttpStatus.OK, "Sự vụ không được để trống khi cập nhật hồ sơ VPĐD"` |
| 170 | `REPRES_OFFICE_ADJUSTED_LICENSE_REQUIRED` | `"REPRES_OFFICE_ADJUSTED_LICENSE_REQUIRED", HttpStatus.OK, "Phải nhập số GCN sửa đổi khi thay đổi thông tin bắt buộc"` |
| 171 | `REPRES_OFFICE_PROVINCE_REQUIRED` | `"REPRES_OFFICE_PROVINCE_REQUIRED", HttpStatus.OK, "Tỉnh/thành phố không được để trống"` |
| 172 | `REPRES_OFFICE_WARD_REQUIRED` | `"REPRES_OFFICE_WARD_REQUIRED", HttpStatus.OK, "Xã/phường không được để trống"` |
| 173 | `REPRES_OFFICE_PROVINCE_NOT_FOUND` | `"REPRES_OFFICE_PROVINCE_NOT_FOUND", HttpStatus.OK, "Tỉnh/thành phố không tồn tại trong danh mục"` |
| 174 | `REPRES_OFFICE_WARD_NOT_FOUND` | `"REPRES_OFFICE_WARD_NOT_FOUND", HttpStatus.OK, "Xã/phường không tồn tại trong danh mục"` |
| 175 | `REPRES_OFFICE_WARD_PROVINCE_MISMATCH` | `"REPRES_OFFICE_WARD_PROVINCE_MISMATCH", HttpStatus.OK, "Xã/phường không thuộc tỉnh/thành phố đã chọn"` |
| 176 | `FOR_BRANCH_EVENT_TYPE_REQUIRED` | `"FOR_BRANCH_EVENT_TYPE_REQUIRED", HttpStatus.OK, "Sự vụ không được để trống khi cập nhật hồ sơ chi nhánh"` |
| 177 | `FOR_BRANCH_ADJUSTED_LICENSE_REQUIRED` | `"FOR_BRANCH_ADJUSTED_LICENSE_REQUIRED", HttpStatus.OK, "Phải nhập số GP sửa đổi khi thay đổi thông tin bắt buộc"` |
| 178 | `FOR_BRANCH_STAFF_DUPLICATE_INFO_DISCLOSURE` | `"FOR_BRANCH_STAFF_DUPLICATE_INFO_DISCLOSURE", HttpStatus.OK, "Mỗi chi nhánh chỉ có một nhân sự đại diện công bố thông tin tại thời điểm hiện tại"` |
| 179 | `FOR_BRANCH_STAFF_DUPLICATE_DIRECTOR` | `"FOR_BRANCH_STAFF_DUPLICATE_DIRECTOR", HttpStatus.OK, "Mỗi chi nhánh chỉ có một giám đốc chi nhánh tại thời điểm hiện tại"` |
| 180 | `FOR_BRANCH_STAFF_DELETE_HAS_DISCLOSURE_REFERENCE` | `"FOR_BRANCH_STAFF_DELETE_HAS_DISCLOSURE_REFERENCE", HttpStatus.OK, "Không thể xóa nhân sự vì đã phát sinh dữ liệu công bố thông tin"` |
| 181 | `FOR_BRANCH_INVALID_EMAIL` | `"FOR_BRANCH_INVALID_EMAIL", HttpStatus.OK, "Email không đúng định dạng"` |
| 182 | `FOR_BRANCH_INVALID_WEBSITE` | `"FOR_BRANCH_INVALID_WEBSITE", HttpStatus.OK, "Website không đúng định dạng"` |
| 183 | `FOR_BRANCH_CHANGE_NOTE_REQUIRED` | `"FOR_BRANCH_CHANGE_NOTE_REQUIRED", HttpStatus.OK, "Lý do sửa không được để trống"` |
| 184 | `SECURITIES_EVENT_TYPE_REQUIRED` | `"SECURITIES_EVENT_TYPE_REQUIRED", HttpStatus.OK, "Sự vụ không được để trống khi cập nhật hồ sơ công ty"` |
| 185 | `SECURITIES_EDIT_REASON_REQUIRED` | `"SECURITIES_EDIT_REASON_REQUIRED", HttpStatus.OK, "Lý do sửa đổi không được để trống"` |
| 186 | `SECURITIES_EVENT_TYPE_INVALID` | `"SECURITIES_EVENT_TYPE_INVALID", HttpStatus.OK, "Loại sự vụ không hợp lệ cho hồ sơ công ty"` |
| 187 | `SECURITIES_EVENT_PAYLOAD_INVALID` | `"SECURITIES_EVENT_PAYLOAD_INVALID", HttpStatus.OK, "Thông tin thay đổi bổ sung không đúng định dạng JSON"` |
| 188 | `FOR_BRANCH_INVALID_DATE_START_LICENSE` | `"FOR_BRANCH_INVALID_DATE_START_LICENSE", HttpStatus.OK, "Ngày bắt đầu hoạt động phải lớn hơn hoặc bằng ngày được cấp GP"` |
| 189 | `FOR_BRANCH_INVALID_DATE_END_START` | `"FOR_BRANCH_INVALID_DATE_END_START", HttpStatus.OK, "Ngày kết thúc phải lớn hơn hoặc bằng ngày bắt đầu"` |
| 190 | `FOR_BRANCH_INVALID_DATE_CHANGE_LICENSE` | `"FOR_BRANCH_INVALID_DATE_CHANGE_LICENSE", HttpStatus.OK, "Ngày chấp thuận phải lớn hơn hoặc bằng ngày cấp"` |
| 191 | `FOR_BRANCH_HAS_STAFF` | `"FOR_BRANCH_HAS_STAFF", HttpStatus.OK, "CNNN/VPĐD đang tồn tại nhân sự, không thể xóa"` |
| 192 | `FOR_BRANCH_PROVINCE_REQUIRED` | `"FOR_BRANCH_PROVINCE_REQUIRED", HttpStatus.OK, "Tỉnh/thành phố không được để trống"` |
| 193 | `FOR_BRANCH_WARD_REQUIRED` | `"FOR_BRANCH_WARD_REQUIRED", HttpStatus.OK, "Xã/phường không được để trống"` |
| 194 | `FOR_BRANCH_PROVINCE_NOT_FOUND` | `"FOR_BRANCH_PROVINCE_NOT_FOUND", HttpStatus.OK, "Tỉnh/thành phố không tồn tại trong danh mục"` |
| 195 | `FOR_BRANCH_WARD_NOT_FOUND` | `"FOR_BRANCH_WARD_NOT_FOUND", HttpStatus.OK, "Xã/phường không tồn tại trong danh mục"` |
| 196 | `FOR_BRANCH_WARD_PROVINCE_MISMATCH` | `"FOR_BRANCH_WARD_PROVINCE_MISMATCH", HttpStatus.OK, "Xã/phường không thuộc tỉnh/thành phố đã chọn"` |
| 197 | `DTCK_AMENDMENT_INFO_REQUIRED` | `"DTCK_AMENDMENT_INFO_REQUIRED", HttpStatus.OK, "Phải nhập số GP/QĐ sửa đổi và ngày chấp thuận khi thay đổi thông tin trọng yếu của CT ĐTCK"` |
| 198 | `DTCK_STAFF_IMPORT_NOT_IMPLEMENTED` | `"DTCK_STAFF_IMPORT_NOT_IMPLEMENTED", HttpStatus.OK, "Chức năng import nhân sự CT ĐTCK chưa được triển khai trong giai đoạn hiện tại"` |
| 199 | `OFFERING_SEC_NOT_FOUND` | `"OFFERING_SEC_NOT_FOUND", HttpStatus.OK, "Không tìm thấy công ty QLQ"` |
| 200 | `OFFERING_INVALID_TYPE` | `"OFFERING_INVALID_TYPE", HttpStatus.OK, "Loại chào bán không hợp lệ"` |
| 201 | `OFFERING_INVALID_SECURITIES_TYPE` | `"OFFERING_INVALID_SECURITIES_TYPE", HttpStatus.OK, "Loại chứng khoán không hợp lệ"` |
| 202 | `OFFERING_TTHC_EXTERNAL_ID_REQUIRED` | `"OFFERING_TTHC_EXTERNAL_ID_REQUIRED", HttpStatus.OK, "Thiếu ID hồ sơ TTHC khi đồng bộ"` |
| 203 | `OFFERING_TTHC_DUPLICATE` | `"OFFERING_TTHC_DUPLICATE", HttpStatus.OK, "Hồ sơ TTHC đã được đồng bộ trước đó"` |
| 204 | `OFFERING_STOCK_DOSSIER_INVALID` | `"OFFERING_STOCK_DOSSIER_INVALID", HttpStatus.OK, "%s"` |
| 205 | `OFFERING_CANNOT_DELETE_HAS_RESULT` | `"OFFERING_CANNOT_DELETE_HAS_RESULT", HttpStatus.OK, "Không được xóa hồ sơ đã có kết quả chào bán"` |
| 206 | `INTERNAL_ERROR` | `"INTERNAL_ERROR", HttpStatus.INTERNAL_SERVER_ERROR, "Lỗi hệ thống"` |

## `RptMemberStatusEnum`

**File:** `com/tinhvan/fmsservice/common/enums/RptMemberStatusEnum.java`  
**Số giá trị:** 10

| # | Constant | Code / tham số constructor |
|---|----------|----------------------------|
| 1 | `DRAFT` | `1, "Chưa gửi"` |
| 2 | `SUBMITTED` | `2, "Đã gửi"` |
| 3 | `SUBMITTED_LATE` | `3, "Gửi muộn"` |
| 4 | `REJECTED` | `4, "Bị hủy"` |
| 5 | `SENT_BACK` | `5, "Đã gửi lại"` |
| 6 | `WAITING_DEPUTY_APPROVAL` | `6, "Chờ Phó Ban phê duyệt"` |
| 7 | `DEPUTY_REJECTED` | `7, "Phó Ban từ chối duyệt"` |
| 8 | `WAITING_HEAD_APPROVAL` | `8, "Chờ Trưởng Ban phê duyệt"` |
| 9 | `HEAD_REJECTED` | `9, "Trưởng Ban từ chối duyệt"` |
| 10 | `HEAD_APPROVED` | `10, "Trưởng Ban đã duyệt"` |

## `RptTempStatusEnum`

**File:** `com/tinhvan/fmsservice/common/enums/RptTempStatusEnum.java`  
**Số giá trị:** 4

| # | Constant | Code / tham số constructor |
|---|----------|----------------------------|
| 1 | `DRAFT` | `0, "Bản nháp"` |
| 2 | `ACTIVE` | `1, "Đang sử dụng"` |
| 3 | `UNACTIVE` | `2, "Không sử dụng"` |
| 4 | `PENDING` | `3, "Chờ sử dụng"` |

## `SecuritiesOfferingTypeEnum`

**File:** `com/tinhvan/fmsservice/common/enums/SecuritiesOfferingTypeEnum.java`  
**Số giá trị:** 5

| # | Constant | Code / tham số constructor |
|---|----------|----------------------------|
| 1 | `CP` | `"CP", "Cổ phiếu"` |
| 2 | `TP` | `"TP", "Trái phiếu"` |
| 3 | `CCQ` | `"CCQ", "Chứng chỉ quỹ"` |
| 4 | `CQC` | `"CQC", "Chứng quyền có bảo đảm"` |
| 5 | `KHAC` | `"KH", "Khác"` |

## `StatusAnnounceEnum`

**File:** `com/tinhvan/fmsservice/common/enums/StatusAnnounceEnum.java`  
**Số giá trị:** 4

| # | Constant | Code / tham số constructor |
|---|----------|----------------------------|
| 1 | `SENT` | `1, "Đã gửi"` |
| 2 | `UNSENT` | `2, "Chưa gửi"` |
| 3 | `DELAY_SENT` | `3, "Gửi muộn"` |
| 4 | `ERROR` | `4, "Lỗi"` |

## `StockClassEnum`

**File:** `com/tinhvan/fmsservice/common/enums/StockClassEnum.java`  
**Số giá trị:** 2

| # | Constant | Code / tham số constructor |
|---|----------|----------------------------|
| 1 | `COMMON` | `"01", "Cổ phiếu phổ thông"` |
| 2 | `PREFERRED` | `"02", "Cổ phiếu ưu đãi"` |

## `StockOfferingPlanMethodEnum`

**File:** `com/tinhvan/fmsservice/common/enums/StockOfferingPlanMethodEnum.java`  
**Số giá trị:** 10

| # | Constant | Code / tham số constructor |
|---|----------|----------------------------|
| 1 | `M01` | `"01", "Chào bán ra công chúng"` |
| 2 | `M02` | `"02", "Cổ phiếu thưởng"` |
| 3 | `M03` | `"03", "Trả cổ tức bằng CP"` |
| 4 | `M04` | `"04", "Phát hành có thu tiền"` |
| 5 | `M05` | `"05", "Đấu giá"` |
| 6 | `M06` | `"06", "Chào bán riêng lẻ"` |
| 7 | `M07` | `"07", "Phát hành CP để hoán đổi"` |
| 8 | `M08` | `"08", "Cổ đông lớn chào bán"` |
| 9 | `M09` | `"09", "Chủ sở hữu góp vốn"` |
| 10 | `M10` | `"10", "Khác"` |

## `SystemDaysOfWeekEnum`

**File:** `com/tinhvan/fmsservice/common/enums/SystemDaysOfWeekEnum.java`  
**Số giá trị:** 7

| # | Constant | Code / tham số constructor |
|---|----------|----------------------------|
| 1 | `SUNDAY` | `0, "Chủ nhật"` |
| 2 | `MONDAY` | `1, "Thứ hai"` |
| 3 | `TUESDAY` | `2, "Thứ ba"` |
| 4 | `WEDNESDAY` | `3, "Thứ tư"` |
| 5 | `THURSDAY` | `4, "Thứ năm"` |
| 6 | `FRIDAY` | `5, "Thứ sáu"` |
| 7 | `SATURDAY` | `6, "Thứ bảy"` |

## `SystemObjectEnum`

**File:** `com/tinhvan/fmsservice/common/enums/SystemObjectEnum.java`  
**Số giá trị:** 15

| # | Constant | Code / tham số constructor |
|---|----------|----------------------------|
| 1 | `UBCK` | `1, "Ủy ban chứng khoán"` |
| 2 | `FUND_MANAGEMENT_COMPANY` | `2, "Công ty QLQ"` |
| 3 | `CUSTODIAN_BANK` | `3, "Ngân hàng lưu ký, giám sát"` |
| 4 | `BRANCH_OF_FOREIGN_FMC` | `4, "CN công ty QLQ nước ngoài tại VN"` |
| 5 | `REPRESENTATIVE_OFFICE_OF_THE_FOREIGN` | `5, "VPĐD công ty QLQ nước ngoài tại VN"` |
| 6 | `SELF_MANAGED_SECURITIES_INVESTMENT` | `6, "Công ty ĐTCK riêng lẻ tự quản lý"` |
| 7 | `FUNDS` | `7, "Quỹ đầu tư"` |
| 8 | `DISTRIBUTOR_AGENT` | `8, "Đại lý phân phối"` |
| 9 | `TRANSFER_AGENT` | `9, "Đại lý chuyển nhượng"` |
| 10 | `PENSION_AGENT` | `10, "Đại lý hưu trí"` |
| 11 | `PENSION_PROVIDER` | `11, "Tổ chức cung cấp dịch vụ quản trị tài khoản hưu trí cá nhân"` |
| 12 | `OTHER_AGENT` | `12, "Đại lý khác"` |
| 13 | `PENSION_FUND` | `13, "Quỹ hưu trí"` |
| 14 | `AUDIT_FIRM` | `14, "Công ty kiểm toán"` |
| 15 | `AUDITOR` | `15, "Kiểm toán viên"` |

## `SysVarsEnum`

**File:** `com/tinhvan/fmsservice/common/enums/SysVarsEnum.java`  
**Số giá trị:** 34

| # | Constant | Code / tham số constructor |
|---|----------|----------------------------|
| 1 | `LINKSYSTEMFIMS` | `1` |
| 2 | `HOTLINE` | `2` |
| 3 | `FILESIZE` | `3` |
| 4 | `MAIL_SERVER` | `4` |
| 5 | `MAIL_PORT` | `5` |
| 6 | `MAIL_USER` | `6` |
| 7 | `MAIL_PASSWORD` | `7` |
| 8 | `MAIL_CC` | `8` |
| 9 | `MAIL_BCC` | `9` |
| 10 | `IP_UNACCESS` | `10` |
| 11 | `MAIL_CONTENT_FORGOTPASSWORD` | `11` |
| 12 | `MAIL_CONTENT_CERTIFICATE_EXPIRED` | `12` |
| 13 | `MAIL_CONTENT_SENDMAKENOTICE_ACCOUNT` | `13` |
| 14 | `DATE_CONFIG_GEN_REPORT_DAY` | `14` |
| 15 | `DATE_CONFIG_GEN_REPORT_WEEK` | `15` |
| 16 | `DATE_CONFIG_GEN_REPORT_HAFTMONTH` | `16` |
| 17 | `DATE_CONFIG_GEN_REPORT_MONTH` | `17` |
| 18 | `DATE_CONFIG_GEN_REPORT_QUARTER` | `18` |
| 19 | `DATE_CONFIG_GEN_REPORT_HAFTYEAR` | `19` |
| 20 | `DATE_CONFIG_GEN_REPORT_YEAR` | `20` |
| 21 | `LOGIN_CONFIG_CAPTCHA` | `21` |
| 22 | `SYSTEM_TIMEOUT` | `22` |
| 23 | `PASSWORD_RULE_NOT_ACCOUNT` | `23` |
| 24 | `PASSWORD_RULE_CHARACTER` | `24` |
| 25 | `PASSWORD_RULE_LOCK` | `25` |
| 26 | `PASSWORD_RULE_LIMIT` | `26` |
| 27 | `PASSWORD_RULE_UNLOCK_ACCOUNT` | `27` |
| 28 | `PASSWORD_RULE_TIME_ACTIVE` | `28` |
| 29 | `PASSWORD_RULE_TIME_CHANGE` | `29` |
| 30 | `PASSWORD_RULE_LIMIT_CHAR` | `30` |
| 31 | `PASSWORD_RULE_NEW_FIRST` | `31` |
| 32 | `DAY_CHECK_CERTIFICATE_EXPRIED` | `32` |
| 33 | `DAY_CHECK_CERTIFICATE` | `33` |
| 34 | `DAY_GET_DATA_MSS` | `34` |

## `TransferAgentCompanyTypeEnum`

**File:** `com/tinhvan/fmsservice/transferagent/domain/enums/TransferAgentCompanyTypeEnum.java`  
**Số giá trị:** 3

| # | Constant | Code / tham số constructor |
|---|----------|----------------------------|
| 1 | `VSDC` | `1, "Tổng công ty lưu ký và bù trừ chứng khoán Việt Nam"` |
| 2 | `NH_THUONG_MAI` | `2, "Ngân hàng thương mại"` |
| 3 | `TO_CHUC_KHAC` | `3, "Tổ chức khác"` |

## `WarnSubjectTypeEnum`

**File:** `com/tinhvan/fmsservice/common/enums/WarnSubjectTypeEnum.java`  
**Số giá trị:** 12

| # | Constant | Code / tham số constructor |
|---|----------|----------------------------|
| 1 | `CONG_TY_QLQ` | `2, "Công ty QLQ"` |
| 2 | `NGAN_HANG_LKGS` | `3, "Ngân hàng LKGS"` |
| 3 | `CN_CONG_TY_QLQ_NN` | `4, "CN công ty QLQ NN tại Việt Nam"` |
| 4 | `VPDD_CONG_TY_QLQ_NN` | `5, "VPDD công ty QLQ NN tại Việt Nam"` |
| 5 | `QUY_DAU_TU` | `7, "Quỹ đầu tư"` |
| 6 | `QUY_HUU_TRI` | `8, "Quỹ hưu trí"` |
| 7 | `DAI_LY_PHAN_PHOI` | `9, "Đại lý phân phối"` |
| 8 | `DAI_LY_CHUYEN_NHUONG` | `10, "Đại lý chuyển nhượng"` |
| 9 | `DAI_LY_HUU_TRI` | `11, "Đại lý hưu trí"` |
| 10 | `TO_CHUC_QTTK_HUU_TRI` | `12, "Tổ chức QTTK hưu trí"` |
| 11 | `DAI_LY_KHAC` | `13, "Đại lý khác"` |
| 12 | `CONG_TY_DTCK_TU_QUAN_LY` | `14, "Công ty ĐTCK riêng lẻ tự quản lý"` |

