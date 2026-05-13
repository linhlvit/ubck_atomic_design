# IDS — Tài liệu khảo sát nguồn và ánh xạ Atomic

**Phân hệ:** IDS (Information Disclosure System — Hệ thống Công bố Thông tin)
**Phạm vi tài liệu:** 60 bảng thuộc 2 phân hệ con:
- Quản lý, giám sát công ty đại chúng (53 bảng)
- Quản lý, giám sát tổ chức kiểm toán được chấp thuận (7 bảng — trong đó có bảng dùng chung với phân hệ 1)

**Mục đích:** Tổng hợp nghiệp vụ nguồn, quan hệ bảng (tree FK), và ánh xạ Atomic entity theo từng nhóm chức năng (UID) — phục vụ tham chiếu cho thiết kế Atomic layer.

**Nguồn tài liệu:**
- Thiết kế CSDL: `New_UBCKNN_Thiet_ke_co_so_du_lieu_IDS_v0_2.docx`
- HLD Overview: `IDS_HLD_Overview.md`
- Classification Value registry: `ref_shared_entity_classifications.csv`
- Đặc tả yêu cầu: **Không có** — nhóm chức năng (UID) được suy luận từ cấu trúc CSDL + HLD Overview

> **Lưu ý về UID:** Do không có tài liệu đặc tả yêu cầu, các UID trong tài liệu này được suy luận từ (1) ngữ nghĩa nghiệp vụ của từng bảng, (2) phân nhóm bảng trong HLD Overview. Cần review với người am hiểu nghiệp vụ IDS để điều chỉnh nếu cần.

---

## Bảng quy ước

Ký hiệu trong cột **Ánh xạ Atomic**:

| Ký hiệu | Ý nghĩa |
|---|---|
| 🟢 *Tên entity* | Atomic entity được thiết kế, ví dụ `🟢 Public Company` |
| 🟢 *Entity* (shared — bổ sung source) | Bảng nguồn bổ sung cho shared entity đã có, chỉ extend cột `source_table` |
| 🟢 CV: `CODE` | Bảng nguồn là Classification Value scheme (danh mục mã hóa) |
| 🔴 (Out of scope) *lý do* | Bảng không thiết kế Atomic, kèm lý do ngắn gọn |

Ký hiệu phân cấp trong bảng quan hệ dữ liệu: `├──` / `└──` thể hiện quan hệ FK cha-con; indent lồng nhau thể hiện nhiều cấp.

---

## Mục lục

- [UID-01 — Quản lý hồ sơ công ty đại chúng](#uid-01--quản-lý-hồ-sơ-công-ty-đại-chúng)
- [UID-02 — Hoạt động kinh doanh / Corporate Actions của CTĐC](#uid-02--hoạt-động-kinh-doanh--corporate-actions-của-ctđc)
- [UID-03 — Giám sát và xử phạt CTĐC](#uid-03--giám-sát-và-xử-phạt-ctđc)
- [UID-04 — Quản lý cổ đông giao dịch](#uid-04--quản-lý-cổ-đông-giao-dịch)
- [UID-05 — Công bố thông tin và thông báo](#uid-05--công-bố-thông-tin-và-thông-báo)
- [UID-06 — Báo cáo tài chính và báo cáo định kỳ](#uid-06--báo-cáo-tài-chính-và-báo-cáo-định-kỳ)
- [UID-07 — Quản lý công ty kiểm toán](#uid-07--quản-lý-công-ty-kiểm-toán)
- [UID-08 — Lịch sử thay đổi (SCD2 kỹ thuật)](#uid-08--lịch-sử-thay-đổi-scd2-kỹ-thuật)
- [UID-09 — Quản trị hệ thống và danh mục dùng chung](#uid-09--quản-trị-hệ-thống-và-danh-mục-dùng-chung)
- [Phụ lục A — Danh mục dùng chung](#phụ-lục-a--danh-mục-dùng-chung)
- [Phụ lục B — Classification Value schemes từ lookup_values](#phụ-lục-b--classification-value-schemes-từ-lookup_values)

---

## UID-01 — Quản lý hồ sơ công ty đại chúng

Quản lý danh sách công ty đại chúng đã đăng ký với UBCKNN và các thông tin xung quanh hồ sơ: người đại diện pháp luật, sở hữu nhà nước, giới hạn sở hữu nước ngoài, quan hệ công ty mẹ/con/liên kết. Đây là **khối dữ liệu hạt nhân** của toàn bộ hệ thống IDS — hầu hết các bảng nghiệp vụ khác đều tham chiếu FK về `company_profiles`.

### 1.1 Hồ sơ công ty đại chúng

**Nghiệp vụ:** Lưu thông tin cơ bản (tên VI/EN, mã doanh nghiệp, mã chứng khoán, sàn niêm yết, trạng thái niêm yết) và thông tin chi tiết (địa chỉ, liên hệ, vốn điều lệ, ngày hoạt động, ngành nghề cấp 1/2) của công ty đại chúng. Cặp `company_profiles` + `company_detail` có quan hệ **1-1**, trong đó `company_profiles` là bảng hạt nhân và `company_detail` bổ sung các thuộc tính chi tiết.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `company_profiles` | Thông tin cơ bản của doanh nghiệp | 🟢 Public Company *(merge vào SCMS.DM_CONG_TY_DC; primary source cho trường 1-1)* |
| └── `company_detail` | Thông tin chi tiết của doanh nghiệp (1-1 với `company_profiles`) | 🟢 Public Company *(merge vào SCMS.DM_CONG_TY_DC; bổ sung trường chi tiết)*<br>🟢 Involved Party Postal Address *(shared — bổ sung source)*<br>🟢 Involved Party Electronic Address *(shared — bổ sung source)* |

Danh mục tham chiếu: `categories` (ngành nghề — cấp 1 + cấp 2 qua `parent_id`), `countries`, `provinces`, `lookup_values` (các CV: `IDS_COMPANY_STATUS`, `IDS_EQUITY_LISTING_EXCH`, `IDS_SECURITIES_TYPE`, `IDS_PUBLIC_COMPANY_FORM`, `IDS_FINANCIAL_STMT_TYPE`, `IDS_ENTERPRISE_TYPE`).

### 1.2 Người đại diện pháp luật & người CBTT

**Nghiệp vụ:** Lưu danh sách người đại diện pháp luật và người CBTT (Công bố Thông tin) của công ty đại chúng. Một công ty có thể có nhiều bản ghi (lịch sử người đại diện thay đổi theo thời gian, hoặc song song đại diện pháp luật + người CBTT). Vai trò được phân biệt qua cột `representative_role` (0 = Người đại diện pháp luật, 1 = Người CBTT).

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `company_profiles` | Công ty đại chúng (xem 1.1) | 🟢 Public Company |
| └── `legal_representative` | Người đại diện pháp luật và người CBTT | 🟢 Public Company Legal Representative |

CV column-level: `legal_representative.representative_role` → `IDS_REPRESENTATIVE_ROLE`.

### 1.3 Sở hữu nhà nước

**Nghiệp vụ:** Lưu thông tin tỷ lệ và cơ quan đại diện phần vốn nhà nước tại công ty đại chúng.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `company_profiles` | Công ty đại chúng (xem 1.1) | 🟢 Public Company |
| └── `state_capital` | Thông tin sở hữu nhà nước | 🟢 Public Company State Capital |

### 1.4 Giới hạn sở hữu nước ngoài (foreign ownership limit)

**Nghiệp vụ:** Lưu lịch sử các quyết định/văn bản quy định tỷ lệ giới hạn sở hữu nước ngoài tại công ty đại chúng. Một công ty có thể có nhiều bản ghi theo thời gian khi tỷ lệ thay đổi.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `company_profiles` | Công ty đại chúng (xem 1.1) | 🟢 Public Company |
| └── `foreign_owner_limit` | Giới hạn tỷ lệ sở hữu nước ngoài | 🟢 Public Company Foreign Ownership Limit |

### 1.5 Quan hệ công ty mẹ / con / liên kết

**Nghiệp vụ:** Lưu các mối quan hệ giữa công ty đại chúng và các công ty khác (mẹ, con, liên doanh, liên kết). Mỗi bản ghi mô tả một mối quan hệ giữa công ty chủ thể và một pháp nhân liên quan, kèm tỷ lệ sở hữu và loại quan hệ.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `company_profiles` | Công ty đại chúng (xem 1.1) | 🟢 Public Company |
| └── `company_relationship` | Công ty mẹ/con/liên kết của công ty đại chúng | 🟢 Public Company Related Entity |

Danh mục tham chiếu: `lookup_values` (CV: `IDS_COMPANY_RELATIONSHIP_TYPE`).

---

## UID-02 — Hoạt động kinh doanh / Corporate Actions của CTĐC

Ghi nhận các sự kiện/hoạt động (corporate actions) quan trọng của công ty đại chúng theo thời gian: quá trình tăng vốn (trước và sau khi thành đại chúng), chào bán/phát hành chứng khoán, chào mua công khai, mua bán cổ phiếu quỹ. Tất cả đều là **Fact Append entities** — mỗi bản ghi là một sự kiện độc lập.

### 2.1 Tăng vốn trước khi thành công ty đại chúng

**Nghiệp vụ:** Lưu lịch sử các đợt tăng vốn điều lệ của công ty trong giai đoạn **trước khi** trở thành công ty đại chúng. Phục vụ hồ sơ lịch sử vốn của doanh nghiệp.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `company_profiles` | Công ty đại chúng (xem 1.1) | 🟢 Public Company |
| └── `capital_mobilization` | Quá trình tăng vốn trước khi thành đại chúng | 🟢 Public Company Capital Mobilization |

### 2.2 Tăng vốn (sau khi thành CTĐC)

**Nghiệp vụ:** Lưu lịch sử các đợt tăng vốn điều lệ sau khi công ty đã là công ty đại chúng. Thông thường đi kèm các đợt chào bán hoặc phát hành chứng khoán (xem 2.3).

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `company_profiles` | Công ty đại chúng (xem 1.1) | 🟢 Public Company |
| └── `company_add_capital` | Quá trình tăng vốn | 🟢 Public Company Capital Increase |

### 2.3 Chào bán, phát hành chứng khoán

**Nghiệp vụ:** Ghi nhận các đợt chào bán/phát hành chứng khoán (cổ phiếu, trái phiếu, chứng quyền…) của công ty đại chúng, bao gồm loại chứng khoán, số lượng, giá trị, thời gian và kết quả đợt chào bán.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `company_profiles` | Công ty đại chúng (xem 1.1) | 🟢 Public Company |
| └── `company_securities_issuance` | Hoạt động chào bán, phát hành chứng khoán | 🟢 Public Company Securities Offering |

Danh mục tham chiếu: `lookup_values` (CV: `IDS_ISSUANCE_SECURITY_TYPE`).

### 2.4 Chào mua công khai

**Nghiệp vụ:** Ghi nhận các đợt chào mua công khai cổ phiếu của công ty đại chúng (tender offer) — bao gồm bên chào mua, số lượng dự kiến, giá chào mua và kết quả.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `company_profiles` | Công ty đại chúng (xem 1.1) | 🟢 Public Company |
| └── `company_tender_offer` | Quá trình chào mua công khai | 🟢 Public Company Tender Offer |

### 2.5 Giao dịch cổ phiếu quỹ

**Nghiệp vụ:** Ghi nhận các đợt mua lại/bán ra cổ phiếu quỹ của chính công ty đại chúng.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `company_profiles` | Công ty đại chúng (xem 1.1) | 🟢 Public Company |
| └── `company_treasury_stocks` | Cổ phiếu quỹ | 🟢 Public Company Treasury Stock Activity |

---

## UID-03 — Giám sát và xử phạt CTĐC

Ghi nhận các hoạt động thanh tra/kiểm tra và xử phạt hành chính đối với công ty đại chúng do UBCKNN/BTC thực hiện. Các bảng trong UID này là **Fact Append** — mỗi bản ghi là một sự kiện giám sát/xử phạt độc lập.

### 3.1 Thanh tra, kiểm tra

**Nghiệp vụ:** Lưu thông tin các đợt thanh tra, kiểm tra của UBCKNN đối với công ty đại chúng: loại kiểm tra (định kỳ/bất thường), nội dung kiểm tra, thời gian, đơn vị thực hiện và kết luận.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `company_profiles` | Công ty đại chúng (xem 1.1) | 🟢 Public Company |
| └── `company_inspection` | Thanh tra, kiểm tra | 🟢 Public Company Inspection |

Danh mục tham chiếu: `lookup_values` (CV: `IDS_INSPECTION_TYPE`, `IDS_INSPECTION_MODE`).

### 3.2 Xử phạt hành chính

**Nghiệp vụ:** Lưu thông tin các quyết định xử phạt hành chính đối với công ty đại chúng và/hoặc nhà đầu tư liên quan: cơ quan ra quyết định, số quyết định, nội dung vi phạm, hình thức xử phạt (phạt tiền, đình chỉ...), thời gian hiệu lực.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `company_profiles` | Công ty đại chúng (xem 1.1) | 🟢 Public Company |
| └── `company_penalize` | Xử phạt hành chính | 🟢 Public Company Penalty |

Danh mục tham chiếu: `lookup_values` (CV: `IDS_PENALIZED_SUBJECT_TYPE`).

---

## UID-04 — Quản lý cổ đông giao dịch

Quản lý thông tin các **cổ đông giao dịch** (stockholders) của công ty đại chúng. Cổ đông có thể là cá nhân hoặc tổ chức, với grain = *cổ đông × công ty* (cùng một cá nhân có thể là cổ đông của nhiều công ty đại chúng, mỗi công ty tạo 1 bản ghi `stock_holders` riêng). Bảng cổ đông là trung tâm, liên kết đến: tài khoản giao dịch, giấy tờ định danh, quan hệ cổ đông, và chứng khoán vào diện kiểm soát.

### 4.1 Hồ sơ cổ đông

**Nghiệp vụ:** Lưu thông tin hồ sơ cổ đông: họ tên, loại hình (cá nhân/tổ chức), giới tính, trình độ học vấn, địa chỉ liên hệ, quốc tịch, tỉnh thành. Mỗi cổ đông gắn với một công ty đại chúng qua `company_profile_id`.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `company_profiles` | Công ty đại chúng (xem 1.1) | 🟢 Public Company |
| └── `stock_holders` | Cổ đông giao dịch | 🟢 Stock Holder<br>🟢 Involved Party Postal Address *(shared — bổ sung source)*<br>🟢 Involved Party Electronic Address *(shared — bổ sung source)* |

Danh mục tham chiếu: `lookup_values` (CV: `IDS_ENTITY_TYPE`, `IDS_GENDER`, `IDS_EDUCATION_LEVEL`), `countries`, `provinces`.

### 4.2 Tài khoản giao dịch của cổ đông

**Nghiệp vụ:** Lưu danh sách tài khoản giao dịch chứng khoán của cổ đông tại các công ty chứng khoán (CTCK). Một cổ đông có thể mở nhiều tài khoản tại nhiều CTCK; có đánh dấu tài khoản chính (`primary_account_flg`).

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `stock_holders` | Cổ đông giao dịch (xem 4.1) | 🟢 Stock Holder |
| └── `account_numbers` | Tài khoản giao dịch của cổ đông | 🟢 Stock Holder Trading Account |

### 4.3 Giấy tờ định danh của cổ đông

**Nghiệp vụ:** Lưu thông tin giấy tờ định danh của cổ đông (CMND/CCCD/Hộ chiếu với cổ đông cá nhân; Giấy đăng ký kinh doanh với cổ đông tổ chức). Một cổ đông có thể có nhiều giấy tờ (lịch sử thay đổi, hoặc nhiều loại giấy tờ đồng thời).

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `stock_holders` | Cổ đông giao dịch (xem 4.1) | 🟢 Stock Holder |
| └── `identity` | Căn cước công dân / giấy ĐKKD của cổ đông | 🟢 Involved Party Alternative Identification *(shared — bổ sung source)* |

Danh mục tham chiếu: `lookup_values` (CV: `IDS_IDENTITY_TYPE` — ETL map sang `IP_ALT_ID_TYPE`).

### 4.4 Quan hệ cổ đông (related persons)

**Nghiệp vụ:** Lưu mối quan hệ giữa các cổ đông (ví dụ: vợ-chồng, cha-con, người được ủy quyền, tổ chức sở hữu chéo...). Mỗi bản ghi liên kết `stock_holder_id` (cổ đông chính) và `related_holder_id` (cổ đông liên quan) cùng loại quan hệ.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `stock_holders` | Cổ đông giao dịch (xem 4.1) | 🟢 Stock Holder |
| └── `holder_relationship` | Mối quan hệ của cổ đông giao dịch | 🟢 Stock Holder Relationship |

Danh mục tham chiếu: `lookup_values` (CV: `IDS_HOLDER_RELATIONSHIP_TYPE`).

### 4.5 Chứng khoán vào diện kiểm soát

**Nghiệp vụ:** Lưu danh sách các mã chứng khoán (gắn với cổ đông) bị đưa vào diện kiểm soát/hạn chế chuyển nhượng. Phục vụ quản lý rủi ro và tuân thủ quy định.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `stock_holders` | Cổ đông giao dịch (xem 4.1) | 🟢 Stock Holder |
| └── `stock_controls` | Chứng khoán vào diện kiểm soát | 🟢 Stock Control |

Danh mục tham chiếu: `lookup_values` (CV: `IDS_STOCK_RESTRICTION_TYPE`).

### 4.6 Chức vụ cổ đông *(chờ thiết kế Atomic)*

**Nghiệp vụ:** Lưu thông tin chức vụ của cổ đông (vd: Chủ tịch HĐQT, Thành viên BGĐ, Cổ đông lớn…). Bảng này không được đề cập trong HLD Overview hiện tại — cần xác nhận thiết kế Atomic.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `stock_holders` | Cổ đông giao dịch (xem 4.1) | 🟢 Stock Holder |
| └── `positions` | Chức vụ của cổ đông | 🔴 (Out of scope) *Chờ thiết kế — bảng chức vụ cổ đông, không có trong HLD hiện tại* |

---

## UID-05 — Công bố thông tin và thông báo

Quản lý các **form công bố thông tin** (CBTT) được công ty đại chúng nộp lên UBCKNN, cùng hệ thống thông báo (notifications) phát đi khi có sự kiện CBTT. Đây là luồng phức tạp nhất trong IDS, bao gồm: định nghĩa form động (template form + field), dữ liệu form đã nhập, phê duyệt, gia hạn, và thông báo (email/SMS/push).

> **Cập nhật scope Atomic:** `company_data` và `data` đã được đưa vào scope Atomic (quyết định D-05/D-06 đảo chiều) do Gold có requirement mới cần giá trị ô BCTC thực tế. `data_values`, `report_approval`, `report_extensions`, `fields`, `form_fields` vẫn out-of-scope.

### 5.1 Định nghĩa form CBTT

**Nghiệp vụ:** Định nghĩa template form CBTT — mỗi form là một loại hồ sơ hoặc loại tin công bố (ví dụ: "Hồ sơ đăng ký công ty đại chúng", "Tin công bố thông tin bất thường"). Form có thể tự-tham-chiếu qua `parent_form_id` để tạo cấu trúc cha-con (form chính chứa các form con). Các `fields` và `form_fields` định nghĩa trường và cấu trúc bố trí field trong form.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `forms` | Định nghĩa form CBTT (self-ref qua `parent_form_id`) | 🟢 Disclosure Form Definition |
| ├── `fields` | Định nghĩa trường của form | 🔴 (Out of scope) *Field definition metadata — denormalized vào data_values khi anchor khôi phục* |
| │   └── `fields_history` | Lịch sử thay đổi fields | 🔴 (Out of scope) *Bảng lịch sử kỹ thuật — SCD2 Atomic tự track* |
| ├── `form_fields` | Bảng nối: danh sách fields trong một form | 🔴 (Out of scope) *Field definition metadata — denormalized vào data_values* |
| │   └── `form_fields_history` | Lịch sử thay đổi form_fields | 🔴 (Out of scope) *Bảng lịch sử kỹ thuật — SCD2 Atomic tự track* |
| └── `data_types` | Định nghĩa kiểu dữ liệu cho fields | 🔴 (Out of scope) *System config/metadata — out-of-scope* |

Danh mục tham chiếu: `lookup_values` (CV: `IDS_FORM_TYPE`, `IDS_NEWS_TYPE`, `IDS_SUB_NEWS_TYPE`).

### 5.2 Dữ liệu form và quy trình phê duyệt

**Nghiệp vụ:** Khi công ty đại chúng nộp một form CBTT, một bản ghi `company_data` được tạo (liên kết `company_profile_id` với `form_id`), và các giá trị nhập vào được lưu trong `data_values` theo từng field. Bản ghi trải qua quy trình phê duyệt (`report_approval`) và có thể được gia hạn nộp (`report_extensions`). Bảng `data` phục vụ lưu dữ liệu báo cáo tài chính (giao thoa với UID-06).

> **Cập nhật:** `company_data` → 🟢 **Public Company Report Submission** (Tier 3, filter: news_status_cd = 'APPROVED'); `data` → 🟢 **Public Company Financial Report Value** (Tier 4, Fact Append). Các bảng còn lại (`data_values`, `report_approval`, `report_extensions`) vẫn out-of-scope.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `company_profiles` | Công ty đại chúng (xem 1.1) | 🟢 Public Company |
| └── `company_data` | Lần nộp báo cáo/tin CBTT của công ty (filter: APPROVED) | 🟢 *Public Company Report Submission* (Tier 3) |
| &nbsp;&nbsp;&nbsp;&nbsp;├── `data_values` | Giá trị nhập ứng với form, fields | 🔴 (Out of scope) *Field-level data động — cần map cả field_id + form_field_id, chưa có Gold requirement* |
| &nbsp;&nbsp;&nbsp;&nbsp;├── `report_approval` | Phê duyệt tin công bố | 🔴 (Out of scope) *Quy trình nội bộ hệ thống* |
| &nbsp;&nbsp;&nbsp;&nbsp;├── `report_extensions` | Gia hạn nộp báo cáo | 🔴 (Out of scope) *Quy trình nội bộ hệ thống* |
| &nbsp;&nbsp;&nbsp;&nbsp;└── `data` | Dữ liệu hàng/cột báo cáo tài chính (xem UID-06) | 🟢 *Public Company Financial Report Value* (Tier 4, Fact Append) |

### 5.3 Thông báo CBTT (Notifications)

**Nghiệp vụ:** Khi một tin CBTT được công bố/duyệt, hệ thống sinh các thông báo gửi đến các hệ thống đích (email/SMS/push) theo lịch gửi cấu hình. `noti_config` định nghĩa cấu hình thông báo (kênh, hệ thống đích, lịch gửi), `noti_config_apply` là bảng nối áp dụng cấu hình cho công ty cụ thể, `notifications` lưu từng instance thông báo đã phát sinh (sent_date, trạng thái).

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `notifications` | Instance thông báo đã gửi | 🟢 Disclosure Notification |
| `noti_config` | Cấu hình thông báo | 🟢 Disclosure Notification Config |
| └── `noti_config_apply` | Junction: cấu hình áp dụng cho công ty | 🔴 (Out of scope) *Pure junction table — không có business attribute* |

Danh mục tham chiếu: `lookup_values` (CV column-level của `notifications`: `IDS_NEWS_STATUS`, `IDS_NEWS_TYPE`, `IDS_NOTIFICATION_SEND_SCHEDULE`; của `noti_config`: `IDS_NOTIFICATION_SEND_CHANNEL`, `IDS_NOTIFICATION_TARGET_SYSTEM`).

---

## UID-06 — Báo cáo tài chính và báo cáo định kỳ

IDS quản lý 2 họ template báo cáo song song:
- **Báo cáo tài chính** (dùng bộ bảng `report_catalog` / `rrow` / `rcol`): template cho các báo cáo tài chính IFRS/VAS của công ty đại chúng, với khái niệm "hàng" (row) và "cột" (column) linh hoạt.
- **Báo cáo định kỳ** (dùng bộ bảng `rep_forms` / `rep_row` / `rep_column`): template cho các báo cáo định kỳ khác (tháng/quý/năm/bán niên), độc lập với báo cáo tài chính.

Dữ liệu thực tế nhập vào các template này được lưu tại `data` (liên kết ngược qua `company_data` — xem UID-05.2; cả hai đã được đưa vào scope Atomic).

### 6.1 Báo cáo tài chính — Template

**Nghiệp vụ:** `report_catalog` định nghĩa danh mục báo cáo tài chính (ví dụ: "Bảng cân đối kế toán", "Báo cáo kết quả kinh doanh"); mỗi catalog có một tập `rrow` (hàng báo cáo, có thể là value/formula/description) và một tập `rcol` (cột, thường là kỳ báo cáo). Dữ liệu thực tế sẽ được lưu trong `data` theo cặp `(rrow, rcol)`.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `report_catalog` | Danh mục báo cáo tài chính | 🟢 Financial Report Catalog |
| ├── `rrow` | Hàng của báo cáo tài chính | 🟢 Financial Report Row Template |
| ├── `rcol` | Cột của báo cáo tài chính | 🟢 Financial Report Column Template |
| └── `data` | Dữ liệu hàng/cột báo cáo (xem UID-05.2) | 🟢 *Public Company Financial Report Value* (Tier 4, Fact Append) |

CV column-level: `report_catalog.rc_type_cd` → `IDS_REPORT_CATALOG_TYPE`; `rrow.row_type_cd` → `IDS_REPORT_ROW_TYPE`.
Danh mục tham chiếu: `lookup_values` (CV: `IDS_REPORT_SCOPE`, `IDS_ENTERPRISE_TYPE`).

### 6.2 Báo cáo định kỳ — Template

**Nghiệp vụ:** `rep_forms` định nghĩa template báo cáo định kỳ (tháng/quý/năm/thường niên/bán niên); mỗi form có một tập `rep_row` và `rep_column` định nghĩa cấu trúc hàng/cột. Đây là bộ template độc lập với `report_catalog` (phục vụ các báo cáo thống kê, giám sát định kỳ thay vì báo cáo tài chính chuẩn).

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `rep_forms` | Template báo cáo định kỳ | 🟢 Periodic Report Form |
| ├── `rep_row` | Hàng của báo cáo định kỳ | 🟢 Periodic Report Form Row Template |
| └── `rep_column` | Cột của báo cáo định kỳ | 🟢 Periodic Report Form Column Template |

CV column-level: `rep_forms.rf_report_type_cd` → `IDS_PERIODIC_REPORT_FREQUENCY`; `rep_row.data_type_cd` → `IDS_PERIODIC_FORM_ROW_DATA_TYPE`; `rep_column.data_type_cd` → `IDS_PERIODIC_FORM_COLUMN_DATA_TYPE`.

---

## UID-07 — Quản lý công ty kiểm toán

Phân hệ con thứ 2 của IDS — quản lý hồ sơ các công ty kiểm toán được chấp thuận bởi Bộ Tài chính (BTC) và UBCKNN, các kiểm toán viên được chấp thuận, cùng các hoạt động nhắc nhở và xử phạt. Mỗi công ty kiểm toán có nhiều quyết định chấp thuận/đình chỉ (gộp BTC + SSC vào một entity `Audit Firm Approval`) và nhiều kiểm toán viên (`Auditor Approval`). Cả 2 (công ty và kiểm toán viên) đều có thể bị nhắc nhở (`af_warning`) hoặc xử phạt (`af_sanctions`).

### 7.1 Hồ sơ công ty kiểm toán

**Nghiệp vụ:** Lưu thông tin cơ bản công ty kiểm toán: tên VI/EN, mã, địa chỉ, liên hệ, vốn điều lệ thực góp, trạng thái thành viên hãng kiểm toán nước ngoài, ngày trở thành thành viên. Các trường liên hệ (địa chỉ, điện thoại, fax, website) được ánh xạ sang các shared Involved Party Address entities.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `af_profiles` | Hồ sơ công ty kiểm toán | 🟢 Audit Firm *(merge vào SCMS.CT_KIEM_TOAN)*<br>🟢 Involved Party Postal Address *(shared — bổ sung source)*<br>🟢 Involved Party Electronic Address *(shared — bổ sung source)* |

### 7.2 Người đại diện pháp luật công ty kiểm toán

**Nghiệp vụ:** Lưu danh sách người đại diện pháp luật của công ty kiểm toán (họ tên, số CMND/hộ chiếu, chức vụ, email, điện thoại). Một công ty có thể có nhiều bản ghi theo thời gian.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `af_profiles` | Công ty kiểm toán (xem 7.1) | 🟢 Audit Firm |
| └── `af_legal_representative` | Người đại diện pháp luật cho công ty kiểm toán | 🟢 Audit Firm Legal Representative<br>🟢 Involved Party Electronic Address *(shared — bổ sung source)*<br>🟢 Involved Party Alternative Identification *(shared — bổ sung source)* |

Danh mục tham chiếu: `lookup_values` (CV: `IDS_AF_POSITION_TITLE`).

### 7.3 Chấp thuận công ty kiểm toán

**Nghiệp vụ:** Ghi nhận các quyết định chấp thuận và đình chỉ đối với công ty kiểm toán được phát hành bởi cả Bộ Tài chính (BTC — các trường `mof_*`) và Ủy ban Chứng khoán Nhà nước (SSC — các trường `ssc_*`). Mỗi bản ghi thể hiện một hồ sơ chấp thuận có đủ các văn bản từ 2 cơ quan.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `af_profiles` | Công ty kiểm toán (xem 7.1) | 🟢 Audit Firm |
| └── `af_approval` | Các công ty kiểm toán được chấp thuận | 🟢 Audit Firm Approval *(gộp BTC + SSC)* |

### 7.4 Chấp thuận kiểm toán viên

**Nghiệp vụ:** Ghi nhận danh sách kiểm toán viên được chấp thuận, thuộc một công ty kiểm toán, kèm các quyết định chấp thuận/đình chỉ của BTC + SSC (cấu trúc tương tự 7.3 nhưng ở cấp cá nhân). Có trường `affiliation_end_date` đánh dấu kiểm toán viên rời công ty.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `af_profiles` | Công ty kiểm toán (xem 7.1) | 🟢 Audit Firm |
| └── `af_auditor_approval` | Kiểm toán viên được chấp thuận | 🟢 Auditor Approval |

Danh mục tham chiếu: `lookup_values` (CV: `IDS_AF_POSITION_TITLE`).

### 7.5 Nhắc nhở (Warning)

**Nghiệp vụ:** Ghi nhận các văn bản nhắc nhở do BTC hoặc UBCKNN phát hành đối với công ty kiểm toán **hoặc** kiểm toán viên. Loại đối tượng (`warning_target_type_cd`) xác định bản ghi thuộc về công ty hay kiểm toán viên: nếu là công ty thì `af_approval_id` có giá trị và `af_auditor_approval_id` = null (và ngược lại).

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `af_approval` | Chấp thuận công ty KT (xem 7.3) | 🟢 Audit Firm Approval |
| └── `af_warning` (khi target = công ty) | Nhắc nhở đối với công ty KT | 🟢 Audit Firm Warning |
| `af_auditor_approval` | Chấp thuận KTV (xem 7.4) | 🟢 Auditor Approval |
| └── `af_warning` (khi target = kiểm toán viên) | Nhắc nhở đối với KTV | 🟢 Audit Firm Warning *(xem ở trên)* |

Danh mục tham chiếu: `lookup_values` (CV: `IDS_WARNING_TARGET_TYPE`, `IDS_WARNING_SOURCE_TYPE`).

### 7.6 Xử phạt hành chính (Sanctions)

**Nghiệp vụ:** Ghi nhận các quyết định xử phạt do BTC hoặc UBCKNN phát hành đối với công ty kiểm toán hoặc kiểm toán viên (cấu trúc logic tương tự 7.5 với cặp FK `af_approval_id` / `af_auditor_approval_id` loại trừ nhau). Kèm file đính kèm (`attachment_file_url`).

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `af_approval` | Chấp thuận công ty KT (xem 7.3) | 🟢 Audit Firm Approval |
| └── `af_sanctions` (khi target = công ty) | Xử phạt đối với công ty KT | 🟢 Audit Firm Sanction |
| `af_auditor_approval` | Chấp thuận KTV (xem 7.4) | 🟢 Auditor Approval |
| └── `af_sanctions` (khi target = kiểm toán viên) | Xử phạt đối với KTV | 🟢 Audit Firm Sanction *(xem ở trên)* |

Danh mục tham chiếu: `lookup_values` (CV: `IDS_SANCTION_TARGET_TYPE`, `IDS_SANCTION_AUTHORITY`).

---

## UID-08 — Lịch sử thay đổi (SCD2 kỹ thuật)

Các bảng `*_his` trong IDS ghi nhận lịch sử thay đổi của hồ sơ nghiệp vụ theo thời gian. Theo quyết định thiết kế Atomic (D-xx trong HLD), các bảng lịch sử này **out-of-scope** vì Atomic layer tự triển khai SCD2 (Type 2 Slowly Changing Dimension) trên entity chính — không cần map lại bảng lịch sử kỹ thuật của nguồn.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `company_profiles` | Công ty đại chúng (xem 1.1) | 🟢 Public Company |
| ├── `company_profiles_his` | Lịch sử hồ sơ công ty | 🔴 (Out of scope) *Bảng lịch sử kỹ thuật — SCD2 Atomic tự track* |
| ├── `company_detail_his` | Lịch sử chi tiết công ty | 🔴 (Out of scope) *Bảng lịch sử kỹ thuật — SCD2 Atomic tự track* |
| └── `company_change_role_his` | Lịch sử thay đổi vai trò user (theo công ty) | 🔴 (Out of scope) *Bảng lịch sử kỹ thuật — SCD2 Atomic tự track* |
| `stock_holders` | Cổ đông giao dịch (xem 4.1) | 🟢 Stock Holder |
| └── `stockholder_history` | Lịch sử cổ đông | 🔴 (Out of scope) *Bảng lịch sử kỹ thuật — SCD2 Atomic tự track* |

*Các bảng `fields_history` và `form_fields_history` đã được đề cập tại UID-05.1 cùng với `fields` / `form_fields` tương ứng.*

---

## UID-09 — Quản trị hệ thống và danh mục dùng chung

Các bảng quản trị hệ thống, cấu hình, log, phân quyền, và danh mục tham chiếu chung của IDS. Phần lớn **out-of-scope** với Atomic layer vì là metadata hệ thống, trừ hai bảng danh mục lớn (`lookup_values`, `categories`) được ánh xạ thành Classification Value schemes.

### 9.1 Người dùng và đăng nhập

**Nghiệp vụ:** `logins` lưu thông tin tài khoản đăng nhập vào IDS (cả tài khoản nội bộ UBCKNN và tài khoản của công ty đại chúng/công ty kiểm toán). Phân hệ công ty kiểm toán còn có bảng `users` riêng (theo master list) nhưng thiết kế chi tiết không được cung cấp trong tài liệu.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `logins` | Thông tin đăng nhập | 🔴 (Out of scope) *Bảng hệ thống — không có giá trị nghiệp vụ Atomic* |
| `users` | Tài khoản sử dụng hệ thống (phân hệ AF, thiếu thiết kế chi tiết) | 🔴 (Out of scope) *Bảng hệ thống — không có giá trị nghiệp vụ Atomic* |

### 9.2 Phân quyền và tham số hệ thống

**Nghiệp vụ:** `data_access_rules` lưu các quy tắc phân quyền dữ liệu theo user (ai được xem dữ liệu của công ty nào). `sys_parameters` lưu cấu hình tham số hệ thống. `departments` lưu danh sách phòng ban của UBCKNN — khi Atomic cần FK tới department, sử dụng shared Regulatory Authority Organization Unit.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `data_access_rules` | Phân quyền dữ liệu cho user | 🔴 (Out of scope) *System config/metadata — out-of-scope* |
| `sys_parameters` | Tham số hệ thống | 🔴 (Out of scope) *System config/metadata — out-of-scope* |
| `departments` | Phòng ban của UBCKNN | 🔴 (Out of scope) *Dùng shared Regulatory Authority Organization Unit khi cần FK* |
| `data_types` | Kiểu dữ liệu cho fields của form | 🔴 (Out of scope) *System config/metadata — out-of-scope* |

### 9.3 Log hệ thống

**Nghiệp vụ:** Ghi log thao tác của user (`user_audit_log`) và log gửi SMS (`sms_log`). Cả hai đều là operational log, out-of-scope Atomic.

**Quan hệ dữ liệu:**

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `user_audit_log` | Log thao tác người dùng | 🔴 (Out of scope) *Operational log — out-of-scope* |
| `sms_log` | Log gửi SMS (liên kết `company_profiles_id`) | 🔴 (Out of scope) *Operational log — out-of-scope* |

### 9.4 Danh mục / Reference data

**Nghiệp vụ:** `lookup_values` là bảng LOV (List of Values) trung tâm của IDS — chứa 30 `lookup_group` khác nhau, mỗi group tương ứng một Classification Value scheme (xem Phụ lục B). `categories` là danh mục ngành nghề 2 cấp (self-ref qua `parent_id`) phục vụ phân loại công ty đại chúng. `countries` và `provinces` là danh mục địa lý chuẩn, ánh xạ vào shared Geographic Area entity của Atomic.

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `lookup_values` | LOV trung tâm — 30 schemes (xem Phụ lục B) | 🟢 CV: *(30 scheme — xem Phụ lục B)* |
| `categories` | Ngành nghề 2 cấp (self-ref) | 🟢 CV: `IDS_INDUSTRY_CATEGORY` |
| `countries` | Danh mục quốc gia | 🔴 (Out of scope) *Reference data — map vào shared Geographic Area (COUNTRY)* |
| `provinces` | Danh mục tỉnh thành | 🔴 (Out of scope) *Reference data — map vào shared Geographic Area (PROVINCE)* |

---

## Phụ lục A — Danh mục dùng chung

Các bảng được tham chiếu xuyên suốt nhiều UID:

| Bảng | Ý nghĩa | Sử dụng bởi | Ánh xạ Atomic |
|---|---|---|---|
| `lookup_values` | LOV trung tâm, 30 schemes CV | UID-01, UID-02, UID-03, UID-04, UID-05, UID-06, UID-07 | 🟢 CV: *(30 scheme — xem Phụ lục B)* |
| `categories` | Ngành nghề 2 cấp | UID-01 (company_detail) | 🟢 CV: `IDS_INDUSTRY_CATEGORY` |
| `countries` | Quốc gia | UID-01 (company_detail), UID-04 (stock_holders) | 🔴 (Out of scope) *Map vào shared Geographic Area (COUNTRY)* |
| `provinces` | Tỉnh thành | UID-01 (company_detail), UID-04 (stock_holders) | 🔴 (Out of scope) *Map vào shared Geographic Area (PROVINCE)* |
| `departments` | Phòng ban UBCKNN | UID-09 (phân quyền) + các trường `department_id` tham chiếu | 🔴 (Out of scope) *Dùng shared Regulatory Authority Organization Unit* |
| `logins` | Đăng nhập (login_name) | Tất cả UID (audit fields `created_by`, `last_updated_by` → `logins.login_name`) | 🔴 (Out of scope) *Bảng hệ thống* |

---

## Phụ lục B — Classification Value schemes từ `lookup_values`

Bảng `lookup_values` chứa 30 `lookup_group`, mỗi group tương ứng một Classification Value scheme trong Atomic layer. Danh sách đầy đủ (từ `ref_shared_entity_classifications.csv`):

| Scheme code | Mô tả | Sử dụng bởi Atomic entity |
|---|---|---|
| `IDS_AF_POSITION_TITLE` | Chức vụ kiểm toán | Audit Firm Legal Representative \| Auditor Approval |
| `IDS_COMPANY_RELATIONSHIP_TYPE` | Loại quan hệ công ty (mẹ, con, liên doanh liên kết) | Public Company Related Entity |
| `IDS_COMPANY_STATUS` | Trạng thái niêm yết IDS | Public Company |
| `IDS_EDUCATION_LEVEL` | Trình độ học vấn | Stock Holder |
| `IDS_ENTERPRISE_TYPE` | Loại hình doanh nghiệp (dn/bh/td/ck) | Financial Report Catalog \| Public Company |
| `IDS_ENTITY_TYPE` | Loại hình cổ đông (cá nhân, tổ chức) | Stock Holder |
| `IDS_EQUITY_LISTING_EXCH` | Sàn niêm yết cổ phiếu (HNX/HOSE/UPCoM) | Public Company |
| `IDS_FINANCIAL_STMT_TYPE` | Loại báo cáo tài chính (IFRS/VAS…) | Public Company |
| `IDS_FORM_TYPE` | Loại tin hay hồ sơ (hồ sơ, cbtt) | Disclosure Form Definition |
| `IDS_GENDER` | Giới tính | Stock Holder |
| `IDS_HOLDER_RELATIONSHIP_TYPE` | Loại quan hệ cổ đông | Stock Holder Relationship |
| `IDS_IDENTITY_TYPE` | Loại giấy tờ định danh | Involved Party Alternative Identification *(ETL map sang `IP_ALT_ID_TYPE`)* |
| `IDS_INSPECTION_MODE` | Thanh tra định kỳ/bất thường | Public Company Inspection |
| `IDS_INSPECTION_TYPE` | Loại thanh tra/kiểm tra | Public Company Inspection |
| `IDS_ISSUANCE_SECURITY_TYPE` | Loại chứng khoán phát hành | Public Company Securities Offering |
| `IDS_NEWS_STATUS` | Trạng thái tin thông báo | Disclosure Notification |
| `IDS_NEWS_TYPE` | Loại tin gốc | Disclosure Notification \| Disclosure Form Definition |
| `IDS_NOTIFICATION_SEND_CHANNEL` | Hình thức gửi thông báo (email/sms/push) | Disclosure Notification Config |
| `IDS_NOTIFICATION_SEND_SCHEDULE` | Lịch gửi tin định kỳ | Disclosure Notification |
| `IDS_NOTIFICATION_TARGET_SYSTEM` | Hệ thống nhận thông báo | Disclosure Notification Config |
| `IDS_PENALIZED_SUBJECT_TYPE` | Đối tượng xử phạt (CTĐC / nhà đầu tư liên quan) | Public Company Penalty |
| `IDS_PUBLIC_COMPANY_FORM` | Hình thức trở thành CTĐC (IPO / nộp hồ sơ trực tiếp) | Public Company |
| `IDS_REPORT_SCOPE` | Loại hình báo cáo (hợp nhất, mẹ) | Financial Report Catalog |
| `IDS_SANCTION_AUTHORITY` | Cơ quan xử phạt (BTC / UBCKNN) | Audit Firm Sanction |
| `IDS_SANCTION_TARGET_TYPE` | Đối tượng xử phạt | Audit Firm Sanction |
| `IDS_SECURITIES_TYPE` | Loại chứng khoán phát hành | Public Company |
| `IDS_STOCK_RESTRICTION_TYPE` | Loại hạn chế chuyển nhượng cổ phiếu | Stock Control |
| `IDS_SUB_NEWS_TYPE` | Loại tin con | Disclosure Form Definition |
| `IDS_WARNING_SOURCE_TYPE` | Cơ quan nhắc nhở (BTC / UBCKNN) | Audit Firm Warning |
| `IDS_WARNING_TARGET_TYPE` | Đối tượng nhắc nhở (công ty KT / KTV) | Audit Firm Warning |

Ngoài ra, một số CV column-level `etl_derived` không lấy từ `lookup_values` mà trực tiếp từ cột của bảng nghiệp vụ:

| Scheme code | Nguồn cột | Atomic entity |
|---|---|---|
| `IDS_REPORT_CATALOG_TYPE` | `report_catalog.rc_type_cd` | Financial Report Catalog \| Financial Report Row Template \| Financial Report Column Template |
| `IDS_REPORT_ROW_TYPE` | `rrow.row_type_cd` | Financial Report Row Template |
| `IDS_PERIODIC_REPORT_FREQUENCY` | `rep_forms.rf_report_type_cd` | Periodic Report Form |
| `IDS_PERIODIC_FORM_ROW_DATA_TYPE` | `rep_row.data_type_cd` | Periodic Report Form Row Template |
| `IDS_PERIODIC_FORM_COLUMN_DATA_TYPE` | `rep_column.data_type_cd` | Periodic Report Form Column Template |
| `IDS_REPRESENTATIVE_ROLE` | `legal_representative.representative_role` | Public Company Legal Representative |
