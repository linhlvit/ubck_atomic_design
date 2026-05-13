# ECAT — Tài liệu khảo sát nguồn và ánh xạ Atomic

## Thông tin chung

| Mục | Nội dung |
|---|---|
| **Phân hệ** | ECAT — Dịch vụ đồng bộ danh mục dùng chung từ HTTT |
| **Mục đích** | Tài liệu tham chiếu cho thiết kế Atomic layer — tổng hợp nghiệp vụ nguồn, quan hệ bảng, và ánh xạ Atomic entity theo từng nhóm chức năng |
| **Nguồn tài liệu** | `ECAT_Category.csv` (danh sách 46 danh mục), `ECAT_HLD_Overview.md` (v2), `ref_shared_entity_classifications.csv` |
| **Đặc thù nguồn** | ECAT là source thuần danh mục dùng chung — không có file đặc tả yêu cầu hay thiết kế CSDL riêng. Mặc định mọi bảng schema = `Code + Name` (+ `parent_code` với bảng phân cấp). Không có FK inbound giữa các bảng trong chính source ECAT — đây là tình huống bình thường cho source danh mục. Toàn bộ 46/46 bảng thuộc scope Atomic: 4 Atomic entity + 36 Classification Value scheme. |

## Quy ước ký hiệu cột Ánh xạ Atomic

| Ký hiệu | Ý nghĩa |
|---|---|
| 🟢 *Tên entity* | Atomic entity được thiết kế |
| 🟢 `CV: CODE` | Classification Value — danh mục mã hóa theo scheme |
| 🟢 ↳ denormalize vào *Entity* | Junction table flatten vào entity chính |
| 🔴 (Out of scope) *lý do* | Ngoài scope Atomic |
| *(shared — bổ sung source)* | Entity/CV đã được approved từ source khác, ECAT bổ sung thêm source |

---

## Mục lục

- [UID-01. Danh mục địa lý hành chính](#uid-01-danh-mục-địa-lý-hành-chính)
- [UID-02. Danh mục tổ chức & nhân sự](#uid-02-danh-mục-tổ-chức--nhân-sự)
- [UID-03. Danh mục tiền tệ](#uid-03-danh-mục-tiền-tệ)
- [UID-04. Danh mục chứng khoán & thị trường](#uid-04-danh-mục-chứng-khoán--thị-trường)
- [UID-05. Danh mục nghiệp vụ & dịch vụ](#uid-05-danh-mục-nghiệp-vụ--dịch-vụ)
- [UID-06. Danh mục đối tượng tham gia thị trường](#uid-06-danh-mục-đối-tượng-tham-gia-thị-trường)
- [UID-07. Danh mục hành nghề & trình độ](#uid-07-danh-mục-hành-nghề--trình-độ)
- [UID-08. Danh mục lịch & ngày nghỉ](#uid-08-danh-mục-lịch--ngày-nghỉ)
- [UID-09. Danh mục thủ tục hành chính](#uid-09-danh-mục-thủ-tục-hành-chính)
- [UID-10. Danh mục ngành nghề](#uid-10-danh-mục-ngành-nghề)
- [UID-11. Danh mục trạng thái & quy trình xử lý](#uid-11-danh-mục-trạng-thái--quy-trình-xử-lý)
- [UID-12. Danh mục cảnh báo](#uid-12-danh-mục-cảnh-báo)
- [UID-13. Danh mục chỉ tiêu nghiệp vụ](#uid-13-danh-mục-chỉ-tiêu-nghiệp-vụ)
- [Phụ lục: Tổng hợp Classification Value schemes](#phụ-lục-tổng-hợp-classification-value-schemes)

---

## UID-01. Danh mục địa lý hành chính

ECAT đồng bộ 7 danh mục hành chính Việt Nam từ HTTT, bao gồm quốc gia, vùng/miền, tỉnh/thành phố, quận/huyện, phường/xã ở cả phiên bản cũ (pre-2025) và mới (post-sáp nhập 2025). Đây là source authoritative cho Geographic Area trong hệ thống Atomic.

### 1.1. Danh mục quốc gia & vùng/miền

**Nghiệp vụ:** Quốc gia và vùng/miền là 2 cấp cao nhất của phân cấp hành chính. Quốc gia phục vụ tra cứu quốc tịch, nơi cấp giấy tờ; vùng/miền là phân nhóm địa lý nội địa Việt Nam.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `ECAT_01_Country` | Danh mục quốc gia | 🟢 Geographic Area *(shared — bổ sung source)* |
| `ECAT_02_Region` | Danh mục vùng/miền | 🟢 Geographic Area *(shared — bổ sung source)* |

> Không có FK giữa 2 bảng trong source ECAT. Ở Atomic, cả hai đều map vào Geographic Area với `geographic_area_type_code` khác nhau (COUNTRY, REGION).

### 1.2. Danh mục tỉnh/thành phố

**Nghiệp vụ:** Tỉnh/thành phố phục vụ tra cứu địa chỉ, nơi đăng ký. ECAT giữ song song 2 bộ: danh mục cũ (pre-2025) và danh mục mới (post-sáp nhập hành chính 2025) để data instance lịch sử vẫn tra cứu được.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `ECAT_03_ProvinceOld` | Danh mục tỉnh/thành phố (cũ) | 🟢 Geographic Area *(shared — bổ sung source)* |
| `ECAT_04_Province` | Danh mục tỉnh/thành phố (mới) | 🟢 Geographic Area *(shared — bổ sung source)* |

> Ở Atomic, `ECAT_03_ProvinceOld` dùng `geographic_area_type_code` = PROVINCE_OLD, `ECAT_04_Province` dùng PROVINCE.

### 1.3. Danh mục quận/huyện & phường/xã

**Nghiệp vụ:** Cấp hành chính chi tiết nhất. Quận/huyện chỉ có bộ cũ (cấp quận/huyện bị bỏ trong sáp nhập 2025). Phường/xã có cả bộ cũ và mới.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `ECAT_05_DistrictOld` | Danh mục quận/huyện (cũ) | 🟢 Geographic Area *(shared — bổ sung source)* |
| `ECAT_06_WardOld` | Danh mục phường/xã/thị trấn (cũ) | 🟢 Geographic Area *(shared — bổ sung source)* |
| `ECAT_07_Ward` | Danh mục phường/xã/thị trấn (mới) | 🟢 Geographic Area *(shared — bổ sung source)* |

> Ở Atomic, phân biệt qua `geographic_area_type_code`: DISTRICT_OLD, WARD_OLD, WARD. Phân cấp cha-con (quốc gia → vùng → tỉnh → quận → phường) thể hiện qua `parent_geographic_area_id` (self-join). Các bảng phân cấp địa lý có cột `parent_code` thực tế (user đã xác nhận).

---

## UID-02. Danh mục tổ chức & nhân sự

ECAT đồng bộ danh mục đơn vị/phòng ban và chức vụ nội bộ từ HTTT, phục vụ quản lý tổ chức của UBCKNN.

### 2.1. Đơn vị/phòng ban

**Nghiệp vụ:** Danh mục phòng ban, đơn vị trực thuộc UBCKNN. Được tham chiếu bởi các phân hệ khác khi phân quyền hoặc ghi nhận đơn vị xử lý.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `ECAT_08_Department` | Danh mục đơn vị/phòng ban | 🟢 `CV: ECAT_ORGANIZATION_UNIT` |

### 2.2. Chức vụ

**Nghiệp vụ:** Danh mục loại chức vụ (phân loại) và chức vụ cụ thể trong hệ thống tổ chức UBCKNN. Chức vụ có quan hệ phân cấp với loại chức vụ.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `ECAT_09_PositionType` | Danh mục loại chức vụ | 🟢 `CV: ECAT_POSITION_TYPE` |
| └── `ECAT_10_Position` | Danh mục chức vụ | 🟢 `CV: ECAT_POSITION` *(parent → ECAT_POSITION_TYPE)* |

---

## UID-03. Danh mục tiền tệ

ECAT là source chuẩn (authoritative) cho danh mục tiền tệ trong toàn hệ thống.

### 3.1. Đơn vị tiền tệ

**Nghiệp vụ:** Danh mục đơn vị tiền tệ tuân chuẩn ISO 4217 (3 ký tự), phục vụ ghi nhận giá trị tài chính xuyên suốt các phân hệ (báo cáo tài chính, vốn đầu tư, giao dịch...). Không cần bảng mapping nội bộ ↔ ISO.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `ECAT_11_Currency` | Danh mục đơn vị tiền tệ | 🟢 Currency |

> Currency là Atomic entity riêng (data domain — quy tắc #4), ECAT là source authoritative.

---

## UID-04. Danh mục chứng khoán & thị trường

ECAT là source chuẩn cho danh mục chứng khoán (Code + Name) và các danh mục phân loại liên quan.

### 4.1. Chứng khoán và phân loại

**Nghiệp vụ:** Danh mục chứng khoán niêm yết/đăng ký giao dịch, kèm phân loại theo loại chứng khoán (cổ phiếu, trái phiếu, chứng chỉ quỹ...) và thị trường (HOSE, HNX, UPCOM, OTC). Security Code unique toàn thị trường → BK = `security_code` đơn, không cần kết hợp `market_code`. Mệnh giá cổ phần là thuộc tính tham chiếu.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `ECAT_14_Security` | Danh mục chứng khoán | 🟢 Security |
| ├── `ECAT_12_SecurityType` | Danh mục loại chứng khoán | 🟢 `CV: ECAT_SECURITY_TYPE` |
| ├── `ECAT_13_Market` | Danh mục thị trường | 🟢 `CV: ECAT_MARKET` |
| └── `ECAT_15_SharePar` | Danh mục mệnh giá cổ phần | 🟢 `CV: ECAT_SHARE_PAR_VALUE` |

> Ở Atomic, `ECAT_12_SecurityType` và `ECAT_13_Market` là Classification Value thuộc entity Security (cột `security_type_code`, `market_code`). `ECAT_15_SharePar` là CV dùng chung, không gắn trực tiếp vào entity cụ thể.

---

## UID-05. Danh mục nghiệp vụ & dịch vụ

ECAT đồng bộ các danh mục phân loại liên quan đến hoạt động kinh doanh và dịch vụ trên thị trường chứng khoán.

### 5.1. Nghiệp vụ kinh doanh, dịch vụ, và phân loại công ty

**Nghiệp vụ:** Danh mục nghiệp vụ kinh doanh (môi giới, tự doanh, bảo lãnh phát hành...), dịch vụ cung cấp, loại công ty, loại hình doanh nghiệp, và loại hình quỹ đầu tư — phục vụ phân loại tổ chức tham gia thị trường.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `ECAT_18_BusinessOperation` | Danh mục nghiệp vụ kinh doanh | 🟢 `CV: ECAT_BUSINESS_OPERATION` |
| `ECAT_22_Service` | Danh mục dịch vụ | 🟢 `CV: ECAT_SERVICE` |
| `ECAT_21_CompanyType` | Danh mục loại công ty | 🟢 `CV: ECAT_COMPANY_TYPE` |
| `ECAT_43_EnterpriseType` | Danh mục loại hình doanh nghiệp | 🟢 `CV: ECAT_ENTERPRISE_TYPE` |
| `ECAT_44_FundType` | Danh mục loại hình quỹ đầu tư | 🟢 `CV: ECAT_FUND_TYPE` |

### 5.2. Chức vụ doanh nghiệp

**Nghiệp vụ:** Danh mục loại chức vụ và chức vụ trong doanh nghiệp (khác với chức vụ nội bộ UBCKNN ở UID-02). Phục vụ ghi nhận vị trí của cá nhân trong tổ chức tham gia thị trường. Có quan hệ phân cấp loại → chức vụ.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `ECAT_19_CorporatePositionType` | Danh mục loại chức vụ doanh nghiệp | 🟢 `CV: ECAT_CORPORATE_POSITION_TYPE` |
| └── `ECAT_20_CorporatePosition` | Danh mục chức vụ trong doanh nghiệp | 🟢 `CV: ECAT_CORPORATE_POSITION` *(parent → ECAT_CORPORATE_POSITION_TYPE)* |

### 5.3. Báo cáo tài chính và tần suất

**Nghiệp vụ:** Danh mục loại báo cáo tài chính (bảng CĐKT, KQHĐKD, LCTT...) và tần suất báo cáo (quý, năm, bán niên...). Loại tần suất phân nhóm tần suất.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `ECAT_17_FinancialReportType` | Danh mục loại báo cáo tài chính | 🟢 `CV: ECAT_FINANCIAL_REPORT_TYPE` |
| `ECAT_35_FrequencyType` | Danh mục loại tần suất | 🟢 `CV: ECAT_FREQUENCY_TYPE` |
| └── `ECAT_36_Frequency` | Danh mục tần suất | 🟢 `CV: ECAT_FREQUENCY` *(parent → ECAT_FREQUENCY_TYPE)* |

---

## UID-06. Danh mục đối tượng tham gia thị trường

ECAT đồng bộ các danh mục phân loại đối tượng tham gia thị trường chứng khoán.

### 6.1. Nhà đầu tư, cổ đông, đại lý và quan hệ

**Nghiệp vụ:** Danh mục loại nhà đầu tư/cổ đông (tổ chức, cá nhân, nước ngoài...), loại hình cổ đông, loại đại lý, mối quan hệ (người liên quan, bên liên quan...), và sự vụ — phục vụ phân loại và quản lý giám sát đối tượng thị trường.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `ECAT_24_InvestorType` | Danh mục loại nhà đầu tư/cổ đông | 🟢 `CV: ECAT_INVESTOR_TYPE` |
| `ECAT_46_ShareholderType` | Danh mục loại hình cổ đông/nhà đầu tư | 🟢 `CV: ECAT_SHAREHOLDER_TYPE` |
| `ECAT_25_AgentType` | Danh mục loại đại lý | 🟢 `CV: ECAT_AGENT_TYPE` |
| `ECAT_26_Relationship` | Danh mục mối quan hệ | 🟢 `CV: ECAT_RELATIONSHIP_TYPE` |
| `ECAT_23_Case` | Danh mục sự vụ | 🟢 `CV: ECAT_CASE_TYPE` |

---

## UID-07. Danh mục hành nghề & trình độ

ECAT đồng bộ danh mục liên quan đến trình độ và hành nghề chứng khoán.

### 7.1. Trình độ và chứng chỉ hành nghề

**Nghiệp vụ:** Danh mục trình độ học vấn/chuyên môn và loại chứng chỉ hành nghề (MGCK, PTTC, TVTC...) — phục vụ quản lý người hành nghề chứng khoán.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `ECAT_27_EducationLevel` | Danh mục trình độ | 🟢 `CV: ECAT_EDUCATION_LEVEL` |
| `ECAT_28_ProfessionalCertType` | Danh mục loại chứng chỉ hành nghề | 🟢 `CV: ECAT_PROFESSIONAL_CERTIFICATE_TYPE` |

---

## UID-08. Danh mục lịch & ngày nghỉ

ECAT cung cấp thông tin ngày nghỉ, là nguồn dữ liệu cho Calendar Date.

### 8.1. Thông tin ngày nghỉ

**Nghiệp vụ:** Danh sách ngày nghỉ lễ/tết, phục vụ tính toán ngày làm việc, deadline nộp báo cáo, xác định ngày giao dịch. ECAT chỉ gửi danh sách ngày nghỉ — bảng Calendar Date nền do ETL tự sinh dense (đủ mọi ngày trong năm), ECAT chỉ map 2 trường `holiday_flag` + `holiday_name`.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `ECAT_29_HolidayInfo` | Thông tin ngày nghỉ | 🟢 Calendar Date |

> Calendar Date là Atomic entity mới. Dense calendar do ETL tự generate; ECAT cung cấp holiday flag + holiday name.

---

## UID-09. Danh mục thủ tục hành chính

ECAT đồng bộ danh mục thủ tục hành chính (TTHC) liên quan đến lĩnh vực chứng khoán.

### 9.1. Thủ tục hành chính và thành phần

**Nghiệp vụ:** Danh mục TTHC (cấp phép thành lập CTCK, đăng ký phát hành...) và thành phần hồ sơ của từng TTHC. Thành phần TTHC có quan hệ phân cấp với TTHC cha.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `ECAT_30_AdminProcedure` | Danh mục thủ tục hành chính | 🟢 `CV: ECAT_ADMINISTRATIVE_PROCEDURE` |
| └── `ECAT_31_AdminProcedureComponent` | Danh mục thành phần TTHC | 🟢 `CV: ECAT_ADMINISTRATIVE_PROCEDURE_COMPONENT` *(parent → ECAT_ADMINISTRATIVE_PROCEDURE)* |

---

## UID-10. Danh mục ngành nghề

ECAT đồng bộ danh mục ngành nghề kinh doanh theo hệ thống phân ngành 2 cấp.

### 10.1. Ngành nghề cấp 1 và cấp 2

**Nghiệp vụ:** Phân loại ngành nghề kinh doanh của tổ chức tham gia thị trường. Cấp 2 là chi tiết của cấp 1.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `ECAT_32_IndustryLv1` | Danh mục ngành nghề cấp 1 | 🟢 `CV: ECAT_INDUSTRY_LV1` |
| └── `ECAT_33_IndustryLv2` | Danh mục ngành nghề cấp 2 | 🟢 `CV: ECAT_INDUSTRY_LV2` *(parent → ECAT_INDUSTRY_LV1)* |

---

## UID-11. Danh mục trạng thái & quy trình xử lý

ECAT đồng bộ các danh mục trạng thái phục vụ quy trình phê duyệt, xử lý báo cáo, thông báo, và trạng thái hoạt động.

### 11.1. Trạng thái duyệt và trạng thái hoạt động

**Nghiệp vụ:** Trạng thái duyệt (chờ duyệt, đã duyệt, từ chối...) áp dụng xuyên suốt các quy trình phê duyệt. Trạng thái hoạt động (hoạt động, tạm dừng, giải thể...) phản ánh tình trạng pháp lý của tổ chức.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `ECAT_34_ApprovalStatus` | Danh mục trạng thái duyệt | 🟢 `CV: ECAT_APPROVAL_STATUS` |
| `ECAT_45_OperatingStatus` | Danh mục trạng thái hoạt động | 🟢 `CV: ECAT_OPERATING_STATUS` |

### 11.2. Trạng thái xử lý báo cáo và thông báo

**Nghiệp vụ:** Danh mục loại trạng thái xử lý báo cáo, trạng thái thông báo — phục vụ theo dõi quy trình xử lý giám sát. Trạng thái thông báo có quan hệ phân cấp với loại trạng thái.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `ECAT_39_ReportProcessingStatusType` | Danh mục loại trạng thái xử lý báo cáo | 🟢 `CV: ECAT_REPORT_PROCESSING_STATUS_TYPE` |
| `ECAT_41_NotificationStatusType` | Danh mục loại trạng thái thông báo | 🟢 `CV: ECAT_NOTIFICATION_STATUS_TYPE` |
| └── `ECAT_42_NotificationStatus` | Danh mục trạng thái thông báo | 🟢 `CV: ECAT_NOTIFICATION_STATUS` *(parent → ECAT_NOTIFICATION_STATUS_TYPE)* |

---

## UID-12. Danh mục cảnh báo

ECAT đồng bộ danh mục phân loại và xử lý cảnh báo giám sát thị trường.

### 12.1. Loại cảnh báo, mức độ, và trạng thái xử lý

**Nghiệp vụ:** Danh mục loại cảnh báo (giao dịch bất thường, vi phạm công bố thông tin...), mức độ cảnh báo (thấp, trung bình, cao, nghiêm trọng), và trạng thái xử lý cảnh báo — phục vụ quy trình giám sát.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `ECAT_37_AlertType` | Danh mục loại cảnh báo | 🟢 `CV: ECAT_ALERT_TYPE` |
| `ECAT_38_AlertSeverity` | Danh mục mức độ cảnh báo | 🟢 `CV: ECAT_ALERT_SEVERITY` |
| `ECAT_40_AlertProcessingStatus` | Danh mục trạng thái xử lý cảnh báo | 🟢 `CV: ECAT_ALERT_PROCESSING_STATUS` |

---

## UID-13. Danh mục chỉ tiêu nghiệp vụ

ECAT đồng bộ danh mục chỉ tiêu nghiệp vụ chung từ HTTT.

### 13.1. Danh mục chỉ tiêu

**Nghiệp vụ:** Danh mục chỉ tiêu nghiệp vụ chung (không phải risk indicator — đã được user chốt). Phục vụ phân loại các chỉ tiêu báo cáo, đánh giá xuyên suốt các phân hệ.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `ECAT_16_Indicator` | Danh mục chỉ tiêu nghiệp vụ chung | 🟢 `CV: ECAT_BUSINESS_INDICATOR` |

---

## Phụ lục: Tổng hợp Classification Value schemes

Bảng dưới đây gom tất cả 36 bảng danh mục ECAT được thiết kế thành Classification Value scheme trong Atomic.

| Bảng | Ý nghĩa | Sử dụng bởi | Ánh xạ Atomic |
|---|---|---|---|
| `ECAT_08_Department` | Đơn vị/phòng ban | UID-02 | 🟢 `CV: ECAT_ORGANIZATION_UNIT` |
| `ECAT_09_PositionType` | Loại chức vụ | UID-02 | 🟢 `CV: ECAT_POSITION_TYPE` |
| `ECAT_10_Position` | Chức vụ | UID-02 | 🟢 `CV: ECAT_POSITION` *(parent → ECAT_POSITION_TYPE)* |
| `ECAT_12_SecurityType` | Loại chứng khoán | UID-04 | 🟢 `CV: ECAT_SECURITY_TYPE` |
| `ECAT_13_Market` | Thị trường | UID-04 | 🟢 `CV: ECAT_MARKET` |
| `ECAT_15_SharePar` | Mệnh giá cổ phần | UID-04 | 🟢 `CV: ECAT_SHARE_PAR_VALUE` |
| `ECAT_16_Indicator` | Danh mục chỉ tiêu nghiệp vụ chung | UID-13 | 🟢 `CV: ECAT_BUSINESS_INDICATOR` |
| `ECAT_17_FinancialReportType` | Loại báo cáo tài chính | UID-05 | 🟢 `CV: ECAT_FINANCIAL_REPORT_TYPE` |
| `ECAT_18_BusinessOperation` | Nghiệp vụ kinh doanh | UID-05 | 🟢 `CV: ECAT_BUSINESS_OPERATION` |
| `ECAT_19_CorporatePositionType` | Loại chức vụ doanh nghiệp | UID-05 | 🟢 `CV: ECAT_CORPORATE_POSITION_TYPE` |
| `ECAT_20_CorporatePosition` | Chức vụ trong doanh nghiệp | UID-05 | 🟢 `CV: ECAT_CORPORATE_POSITION` *(parent → ECAT_CORPORATE_POSITION_TYPE)* |
| `ECAT_21_CompanyType` | Loại công ty | UID-05 | 🟢 `CV: ECAT_COMPANY_TYPE` |
| `ECAT_22_Service` | Dịch vụ | UID-05 | 🟢 `CV: ECAT_SERVICE` |
| `ECAT_23_Case` | Sự vụ | UID-06 | 🟢 `CV: ECAT_CASE_TYPE` |
| `ECAT_24_InvestorType` | Loại nhà đầu tư/cổ đông | UID-06 | 🟢 `CV: ECAT_INVESTOR_TYPE` |
| `ECAT_25_AgentType` | Loại đại lý | UID-06 | 🟢 `CV: ECAT_AGENT_TYPE` |
| `ECAT_26_Relationship` | Mối quan hệ | UID-06 | 🟢 `CV: ECAT_RELATIONSHIP_TYPE` |
| `ECAT_27_EducationLevel` | Trình độ | UID-07 | 🟢 `CV: ECAT_EDUCATION_LEVEL` |
| `ECAT_28_ProfessionalCertType` | Loại chứng chỉ hành nghề | UID-07 | 🟢 `CV: ECAT_PROFESSIONAL_CERTIFICATE_TYPE` |
| `ECAT_30_AdminProcedure` | Thủ tục hành chính | UID-09 | 🟢 `CV: ECAT_ADMINISTRATIVE_PROCEDURE` |
| `ECAT_31_AdminProcedureComponent` | Thành phần TTHC | UID-09 | 🟢 `CV: ECAT_ADMINISTRATIVE_PROCEDURE_COMPONENT` *(parent → ECAT_ADMINISTRATIVE_PROCEDURE)* |
| `ECAT_32_IndustryLv1` | Ngành nghề cấp 1 | UID-10 | 🟢 `CV: ECAT_INDUSTRY_LV1` |
| `ECAT_33_IndustryLv2` | Ngành nghề cấp 2 | UID-10 | 🟢 `CV: ECAT_INDUSTRY_LV2` *(parent → ECAT_INDUSTRY_LV1)* |
| `ECAT_34_ApprovalStatus` | Trạng thái duyệt | UID-11 | 🟢 `CV: ECAT_APPROVAL_STATUS` |
| `ECAT_35_FrequencyType` | Loại tần suất | UID-05 | 🟢 `CV: ECAT_FREQUENCY_TYPE` |
| `ECAT_36_Frequency` | Tần suất | UID-05 | 🟢 `CV: ECAT_FREQUENCY` *(parent → ECAT_FREQUENCY_TYPE)* |
| `ECAT_37_AlertType` | Loại cảnh báo | UID-12 | 🟢 `CV: ECAT_ALERT_TYPE` |
| `ECAT_38_AlertSeverity` | Mức độ cảnh báo | UID-12 | 🟢 `CV: ECAT_ALERT_SEVERITY` |
| `ECAT_39_ReportProcessingStatusType` | Loại trạng thái xử lý báo cáo | UID-11 | 🟢 `CV: ECAT_REPORT_PROCESSING_STATUS_TYPE` |
| `ECAT_40_AlertProcessingStatus` | Trạng thái xử lý cảnh báo | UID-12 | 🟢 `CV: ECAT_ALERT_PROCESSING_STATUS` |
| `ECAT_41_NotificationStatusType` | Loại trạng thái thông báo | UID-11 | 🟢 `CV: ECAT_NOTIFICATION_STATUS_TYPE` |
| `ECAT_42_NotificationStatus` | Trạng thái thông báo | UID-11 | 🟢 `CV: ECAT_NOTIFICATION_STATUS` *(parent → ECAT_NOTIFICATION_STATUS_TYPE)* |
| `ECAT_43_EnterpriseType` | Loại hình doanh nghiệp | UID-05 | 🟢 `CV: ECAT_ENTERPRISE_TYPE` |
| `ECAT_44_FundType` | Loại hình quỹ đầu tư | UID-05 | 🟢 `CV: ECAT_FUND_TYPE` |
| `ECAT_45_OperatingStatus` | Trạng thái hoạt động | UID-11 | 🟢 `CV: ECAT_OPERATING_STATUS` |
| `ECAT_46_ShareholderType` | Loại hình cổ đông/nhà đầu tư | UID-06 | 🟢 `CV: ECAT_SHAREHOLDER_TYPE` |
