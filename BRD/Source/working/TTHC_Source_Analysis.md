# Tài liệu khảo sát nguồn và ánh xạ Atomic — Phân hệ TTHC

**Phân hệ:** TTHC — Quản lý thủ tục hành chính UBCKNN  
**Nền tảng nguồn:** Orchard Core CMS / EAV (SQLite)  
**Nguồn tài liệu:** Đặc tả yêu cầu TTHC (05/03/2026) · Thiết kế CSDL TTHC (20/03/2026) · Khảo sát JSON schema 45 Eform  
**Atomic mapping:** `atomic_entities.csv` · `TTHC_HLD_Overview.md`

> **Quy ước cột Ánh xạ Atomic:**
> - 🟢 Tên entity — Atomic entity được thiết kế
> - 🟢 `CV: CODE` — Classification Value scheme
> - 🟢 ↳ denormalize vào *Entity* — bảng phụ flatten vào entity chính
> - 🔴 (Out of scope) *lý do* — Ngoài scope Atomic
>
> **Lưu ý:** `ref_shared_entity_classifications.csv` chưa được cung cấp — CV scheme code lấy từ HLD 7c.

---

## Mục lục

1. [Kiến trúc nguồn tổng quan](#1-kiến-trúc-nguồn-tổng-quan)
2. [UID-01 — Bảng chi tiết tổ chức theo hồ sơ](#2-uid-01--bảng-chi-tiết-tổ-chức-theo-hồ-sơ)
3. [UID-02 — Hồ sơ đăng ký chào bán](#3-uid-02--hồ-sơ-đăng-ký-chào-bán)
4. [Phụ lục: Danh mục dùng chung](#4-phụ-lục-danh-mục-dùng-chung)

---

## 1. Kiến trúc nguồn tổng quan

Hệ thống TTHC xây dựng trên **Orchard Core CMS** theo kiến trúc **EAV (Entity–Attribute–Value)**. Không có bảng riêng cho từng loại hồ sơ — toàn bộ dữ liệu đi qua 2 tầng:

```
Tầng lưu trữ gốc (không dùng trong ETL):
  Document.Content  →  nội dung hồ sơ serialize thành JSON

Tầng index — nguồn thực tế cho ETL:
  ContentItemIndex        →  metadata hồ sơ (ContentType, ngày tạo, Published, Latest)
  *FieldIndex (11 bảng)   →  từng giá trị field Eform đã index (Text, Numeric, Date...)
  WorkflowIndex           →  workflow instance xét duyệt hồ sơ
  WorkflowTypeIndex       →  danh mục loại workflow → Classification Value TTHC_WORKFLOW_TYPE (không có entity riêng)
```

**`ContentType`** trong `ContentItemIndex` đóng vai trò tên bảng trong RDBMS thông thường — phân biệt 11 loại hồ sơ chào bán và các loại kết quả (GCN / từ chối).

### Quy tắc đặt tên ContentField trong `*FieldIndex`

```
EformzzContentItemsww0wwzz{EformID}zz{TênField}zz{Suffix}

Suffix theo loại trường:
  input-text / textarea / select  →  zzText
  input-number / input-date       →  zzValue
  radios (Có/Không)               →  zzValues
```

> ⚠️ **Eform 10, 16, 17** dùng `Tentochuctuvan` (có tiền tố "Ten") thay vì `Tochuctuvan` như các Eform còn lại — ETL cần xử lý cả 2 pattern.

---

## 2. UID-01 — Bảng chi tiết tổ chức theo hồ sơ

Bảng "Chi tiết số lượng chứng khoán chào bán & phát hành" hiển thị danh sách hồ sơ với 6 cột thông tin tổ chức: **Doanh nghiệp, Hình thức chào bán, Đơn vị tư vấn, Tổ chức kiểm toán, Đơn vị bảo lãnh, Đơn vị xếp hạng tín nhiệm.**

Toàn bộ 6 cột đến từ dữ liệu khai báo trong tờ khai Eform của tổ chức / cá nhân nộp — không cần join sang kết quả GCN.

### Quan hệ dữ liệu

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `ContentItemIndex` | Mỗi hồ sơ đăng ký chào bán — 1 row. `ContentType` xác định hình thức chào bán (cột 2); `CreatedUtc` phục vụ lọc kỳ. Điều kiện: `Latest=1`, `Published=1`, `ContentType` IN danh sách 11 loại Eform chào bán. | 🟢 Securities Offering Application |
| └── `TextFieldIndex` | Giá trị text của từng field Eform — join qua `ContentItemId`. Mỗi row là 1 field–value pair. Các `ContentField` phục vụ báo cáo: `%Tentochucphathanh%` / `%Tencongty%` (cột 1); `%Tochuctuvan%` / `%Tentochuctuvan%` (cột 3); `%Tochuckiemtoan%` (cột 4); `%baolanh%` trừ `%baolanhthanhtoan%` (cột 5); `%xephang%` (cột 6). | 🟢 Application Eform Field Value |

**Ghi chú nghiệp vụ từng cột:**

| Cột | ContentField pattern | Eform có field | Ghi chú |
|---|---|---|---|
| Doanh nghiệp | `%Tentochucphathanh%` hoặc `%Tencongty%` | Tất cả | Eform 16/17 dùng `Tencongty`; các Eform còn lại dùng `Tentochucphathanh` |
| Hình thức chào bán | `ContentItemIndex.ContentType` | — | Map ContentType → nhãn qua 🟢 `CV: TTHC_CONTENT_TYPE` |
| Đơn vị tư vấn | `%Tochuctuvan%` hoặc `%Tentochuctuvan%` | Tất cả | 2 pattern — Eform 10/16/17 có tiền tố "Ten" |
| Tổ chức kiểm toán | `%Tochuckiemtoan%` | Tất cả | Tên field đồng nhất trên tất cả Eform |
| Đơn vị bảo lãnh | `%baolanh%` (loại trừ `%baolanhthanhtoan%`) | Eform 3, 5, 7 | NULL hợp lệ với các loại hình khác |
| Đơn vị XHTN | `%xephang%` | **Eform 7 (trái phiếu)** | NULL hợp lệ với tất cả loại hình CP / CCQ / Chứng quyền |

### Cách lấy dữ liệu

ETL pivot `TextFieldIndex` theo `ContentItemId` — **không cần parse `Document.Content`**. Orchard Core đã tự đánh index toàn bộ field Eform khi hồ sơ được submit.

```sql
SELECT
  ci.ContentItemId,
  ci.ContentType                                                     AS content_type_code,
  ci.CreatedUtc,
  MAX(CASE WHEN tf.ContentField LIKE '%Tentochucphathanh%'
        OR tf.ContentField LIKE '%Tencongty%'
       THEN tf.Text END)                                             AS issuer_name,
  MAX(CASE WHEN tf.ContentField LIKE '%Tochuctuvan%'
        OR tf.ContentField LIKE '%Tentochuctuvan%'
       THEN tf.Text END)                                             AS advisor_name,
  MAX(CASE WHEN tf.ContentField LIKE '%Tochuckiemtoan%'
       THEN tf.Text END)                                             AS auditor_name,
  MAX(CASE WHEN tf.ContentField LIKE '%baolanh%'
        AND tf.ContentField NOT LIKE '%baolanhthanhtoan%'
       THEN tf.Text END)                                             AS underwriter_name,
  MAX(CASE WHEN tf.ContentField LIKE '%xephang%'
       THEN tf.Text END)                                             AS rating_agency_name

FROM ContentItemIndex ci
JOIN TextFieldIndex tf
  ON ci.ContentItemId = tf.ContentItemId AND tf.Latest = 1
WHERE ci.ContentType IN ( /* danh sách 11 ContentType chào bán — xem Phụ lục 4a */ )
  AND ci.Latest = 1 AND ci.Published = 1
GROUP BY ci.ContentItemId, ci.ContentType, ci.CreatedUtc
```

> ⚠️ **Cần xác nhận:** ContentField thực tế có khớp pattern khảo sát không — profile DB bằng:
> `SELECT DISTINCT ContentField FROM TextFieldIndex WHERE ContentType = '{ContentType thực tế}' AND Latest = 1 ORDER BY ContentField`

---

## 3. UID-02 — Hồ sơ đăng ký chào bán

Dashboard tab "Hồ sơ đăng ký chào bán" gồm 3 widget: **KPI cards** (Đăng ký / Đang xử lý / Bị từ chối), **Biểu đồ donut** (tỷ lệ 4 trạng thái: Chờ xử lý / Đang xử lý / Đã chấp thuận / Bị từ chối), **Bảng chi tiết** (Hình thức × Năm → số lượng theo từng trạng thái).

Trạng thái hồ sơ **không lưu trong 1 bảng tập trung** — ETL tổng hợp từ 3 bảng nguồn.

### Quan hệ dữ liệu

| Bảng | Ý nghĩa | Ánh xạ Atomic |
|---|---|---|
| `ContentItemIndex` *(hồ sơ đăng ký)* | Tập hồ sơ chào bán gốc — lọc `ContentType` IN 11 loại hình; `CreatedUtc` lấy năm và lọc kỳ. Điều kiện: `Latest=1`, `Published=1`. | 🟢 Securities Offering Application |
| ├── `WorkflowIndex` | Workflow instance gắn với hồ sơ qua `CorrelationId = ContentItemId`. `WorkflowStatus` IN (Idle, Executing) → đang xử lý; IN (Finished, Aborted) → đã kết thúc. | 🟢 Application Review Workflow |
| │&nbsp;&nbsp;&nbsp;&nbsp;└── `WorkflowTypeIndex` | Danh mục loại workflow — dùng để filter đúng loại quy trình xét duyệt chào bán qua `WorkflowTypeId`. ETL filter: `IsEnabled=1`. | 🟢 `CV: TTHC_WORKFLOW_TYPE` (Classification Value — không có entity riêng, D-07) |
| └── `ContentItemIndex` *(kết quả)* | ContentItem kết quả (GCN hoặc văn bản từ chối) — cùng bảng `ContentItemIndex` nhưng `ContentType` khác. `Published=1` = kết quả chính thức đã ký duyệt. | 🟢 Securities Offering Application |
| &nbsp;&nbsp;&nbsp;&nbsp;└── `ContentPickerFieldIndex` | Liên kết từ ContentItem kết quả → ContentItem hồ sơ gốc qua `SelectedContentItemId`. Đây là cơ chế xác định hồ sơ nào đã có kết quả. | 🟢 ↳ denormalize vào *Application Eform Field Value* |

### Logic xác định `application_status_code` (ETL derived — `TTHC_APPLICATION_STATUS`)

ETL thực hiện theo thứ tự ưu tiên — trạng thái ưu tiên cao hơn override trạng thái thấp hơn:

| Ưu tiên | Trạng thái | Điều kiện xác định | Bảng nguồn |
|---|---|---|---|
| 1 | `DA_CAP_PHEP` | Tồn tại ContentItem GCN (`ContentType` = GCN result, `Published=1`) liên kết về hồ sơ qua `ContentPickerFieldIndex` | `ContentItemIndex` (GCN) + `ContentPickerFieldIndex` |
| 2 | `TU_CHOI` | Tồn tại ContentItem từ chối (`ContentType` = từ chối result, `Published=1`) liên kết về hồ sơ | `ContentItemIndex` (từ chối) + `ContentPickerFieldIndex` |
| 3 | `DANG_XU_LY` | `WorkflowIndex` tồn tại với `WorkflowStatus` IN (Idle, Executing) và hồ sơ chưa thuộc ưu tiên 1/2 | `WorkflowIndex` |
| 4 | `CHO_XU_LY` | Hồ sơ không match 3 trường hợp trên — vừa nộp, chưa có workflow hoặc workflow chưa khởi động | `ContentItemIndex` (không có match) |

### Query tổng hợp bảng chi tiết

```sql
WITH base AS (
  SELECT ContentItemId, ContentType,
         strftime('%Y', CreatedUtc) AS nam
  FROM ContentItemIndex
  WHERE ContentType IN ( /* xem Phụ lục 4a */ )
    AND Latest = 1 AND Published = 1
    AND CreatedUtc BETWEEN :tu_ngay AND :den_ngay
),
da_cap_phep AS (
  SELECT DISTINCT cpf.SelectedContentItemId AS ContentItemId
  FROM ContentItemIndex gcn
  JOIN ContentPickerFieldIndex cpf
    ON gcn.ContentItemId = cpf.ContentItemId AND cpf.Latest = 1
  WHERE gcn.ContentType LIKE '%GiayChungNhan%'  -- cần xác nhận ContentType thực tế
    AND gcn.Published = 1 AND gcn.Latest = 1
),
tu_choi AS (
  SELECT DISTINCT cpf.SelectedContentItemId AS ContentItemId
  FROM ContentItemIndex tc
  JOIN ContentPickerFieldIndex cpf
    ON tc.ContentItemId = cpf.ContentItemId AND cpf.Latest = 1
  WHERE tc.ContentType LIKE '%TuChoi%'          -- cần xác nhận ContentType thực tế
    AND tc.Published = 1 AND tc.Latest = 1
),
dang_xu_ly AS (
  SELECT DISTINCT wi.CorrelationId AS ContentItemId
  FROM WorkflowIndex wi
  WHERE wi.WorkflowStatus IN ('Idle', 'Executing')
    AND wi.WorkflowTypeId IN ( /* WorkflowTypeId cho luồng xét duyệt chào bán — xem 4b #4 */ )
)
SELECT
  b.ContentType                                                       AS hinh_thuc_chao_ban,
  b.nam,
  COUNT(CASE WHEN b.ContentItemId NOT IN (SELECT ContentItemId FROM da_cap_phep)
              AND b.ContentItemId NOT IN (SELECT ContentItemId FROM tu_choi)
              AND b.ContentItemId NOT IN (SELECT ContentItemId FROM dang_xu_ly)
             THEN 1 END)                                              AS sl_cho_xu_ly,
  COUNT(CASE WHEN b.ContentItemId IN (SELECT ContentItemId FROM dang_xu_ly)
             THEN 1 END)                                              AS sl_dang_xu_ly,
  COUNT(CASE WHEN b.ContentItemId IN (SELECT ContentItemId FROM da_cap_phep)
             THEN 1 END)                                              AS sl_da_cap_phep,
  COUNT(CASE WHEN b.ContentItemId IN (SELECT ContentItemId FROM tu_choi)
             THEN 1 END)                                              AS sl_tu_choi,
  COUNT(*)                                                            AS tong_ho_so
FROM base b
GROUP BY b.ContentType, b.nam
ORDER BY b.nam DESC, b.ContentType
```

### Có cần bóc tách chi tiết form không?

**Không cần** với yêu cầu này. UID-02 chỉ đếm hồ sơ theo trạng thái và hình thức — toàn bộ thông tin đều có ở tầng metadata (`ContentItemIndex`, `WorkflowIndex`) mà không cần đọc nội dung bên trong Eform.

---

## 4. Phụ lục: Danh mục dùng chung

### 4a. Map ContentType → Hình thức chào bán

| ContentType (dự kiến) | Hình thức chào bán | Eform | Loại CK | Luồng nghiệp vụ |
|---|---|---|---|---|
| `ChaobanCophieuIPO` | Chào bán CP lần đầu ra công chúng | Eform 3 | Cổ phiếu | Đăng ký xin cấp phép |
| `ChaobanCophieuCoDongHienHuu` | Chào bán cho CĐ hiện hữu | Eform 5 | Cổ phiếu | Đăng ký xin cấp phép |
| `ChaobanCophieuCoDong` | Chào bán CP ra công chúng (CĐ CTĐC) | Eform 6 | Cổ phiếu | Đăng ký xin cấp phép |
| `ChaobanTraiphieu` | Chào bán trái phiếu ra công chúng | Eform 7 | Trái phiếu | Đăng ký xin cấp phép |
| `ChaobanCophieuRiengle` | Chào bán CP riêng lẻ | Eform 10 | Cổ phiếu | Đăng ký xin cấp phép |
| `PhathanhCophieuHoanDoiNo` | Phát hành CP hoán đổi nợ | Eform 11 | Cổ phiếu | Đăng ký xin cấp phép |
| `PhathanhCophieuRiengleHoanDoiNo` | Phát hành Riêng lẻ hoán đổi nợ | Eform 15 | Cổ phiếu | Đăng ký xin cấp phép |
| `PhathanhCophieuBonus` | Phát hành CP thường (Bonus/Cổ tức) | Eform 16 | Cổ phiếu | **Báo cáo kết quả** — không qua xét duyệt |
| `PhathanhCophieuESOP` | Phát hành CP ESOP | Eform 17 | Cổ phiếu | **Báo cáo kết quả** — không qua xét duyệt |
| `ChaobanChungquyen` | Chào bán chứng quyền có bảo đảm | Eform 76A | Chứng quyền | Đăng ký xin cấp phép |
| `ChaobanCCQ` | Chào bán chứng chỉ quỹ | Eform 100 | CCQ | Đăng ký xin cấp phép |

> ⚠️ Giá trị ContentType thực tế cần xác nhận: `SELECT DISTINCT ContentType FROM ContentItemIndex WHERE Published=1 ORDER BY ContentType`

### 4b. Checklist điểm cần xác nhận với đội dev TTHC

| # | Câu hỏi | Ảnh hưởng |
|---|---|---|
| 1 | ContentType thực tế của 11 loại hồ sơ chào bán là gì? | Điều kiện `WHERE ContentType IN (...)` toàn bộ UID-01 và UID-02 |
| 2 | ContentType của ContentItem GCN và văn bản từ chối là gì? Có tạo ContentItem riêng cho từ chối không? | Logic `application_status_code` và truy vấn UID-02 |
| 3 | Liên kết GCN / từ chối → hồ sơ gốc: qua `ContentPickerFieldIndex.SelectedContentItemId` hay cơ chế khác? | JOIN logic xác định `DA_CAP_PHEP` và `TU_CHOI` trong UID-02 |
| 4 | `WorkflowIndex.CorrelationId` có đúng = `ContentItemId` hồ sơ gốc? `WorkflowTypeId` cho luồng xét duyệt chào bán là gì? | FK `Application Review Workflow` → `Securities Offering Application` + filter `dang_xu_ly` |
| 5 | Eform 16 (Bonus) và Eform 17 (ESOP) có qua workflow không? | Logic `application_status_code` cho 2 loại báo cáo kết quả — nếu không qua workflow, `application_status_code` mặc định là gì? |
| 6 | ContentField thực tế trong `TextFieldIndex` có khớp pattern khảo sát (`%Tochuctuvan%`, `%Tochuckiemtoan%`...)? | Toàn bộ UID-01 — pivot lấy tên tổ chức |
