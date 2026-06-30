# IAM HLD — Tier 1

**Source system:** IAM (Identity and Access Management — Quản lý danh tính và phân quyền người dùng hệ thống UBCK)
**Tier 1:** Main entities không FK đến bảng nghiệp vụ khác. IAM chỉ có 1 bảng nguồn duy nhất: `USERS`.

---

## 6a. Bảng tổng quan BCV Concept

| BCV Core Object | BCV Concept | Category | Source Table | Source Table Change Mode | Mô tả bảng nguồn | Atomic Entity | Table Type | BCV Term |
|---|---|---|---|---|---|---|---|---|
| Involved Party | [Involved Party] Individual | Personal Information | USERS | Update | Người dùng hệ thống IAM — cán bộ UBCK, cán bộ CTCK, chuyên gia đăng nhập hệ thống | Identity and Access Management User | Fundamental | (1) **Individual** (BCV 10902): "Identifies an Involved Party who is a natural person" — BCV mô tả thể nhân. (2) Cấu trúc trường USERS có FULL_NAME, DATE_OF_BIRTH, GENDER, CITIZEN_ID_NUMBER, TAX_ID_NUMBER, ORGANIZATION_CODE, DEPARTMENT_ID — đây là thể nhân có danh tính, tổ chức, chức vụ. (3) Chọn [Involved Party] Individual: người dùng IAM là cá nhân thực tế (cán bộ), không phải Organization. |
| Involved Party | Shared Entity | — | USERS | Update | Thông tin địa chỉ của người dùng | Involved Party Postal Address | Fundamental | Shared entity đã có — extend source_table IAM.USERS. Grain = 1 người dùng → bắt buộc tách. Trường nguồn: ADDRESS. |
| Involved Party | Shared Entity | — | USERS | Update | Thông tin liên lạc điện tử của người dùng | Involved Party Electronic Address | Fundamental | Shared entity đã có — extend source_table IAM.USERS. Grain = 1 người dùng → bắt buộc tách. Trường nguồn: EMAIL, PHONE, DIAL_NUMBER, OFFICE_PHONE. |
| Involved Party | Shared Entity | — | USERS | Update | Giấy tờ định danh của người dùng | Involved Party Alternative Identification | Fundamental | Shared entity đã có — extend source_table IAM.USERS. Grain = 1 người dùng → bắt buộc tách. Trường nguồn: CITIZEN_ID_NUMBER, TAX_ID_NUMBER. |

---

## 6b. Diagram Source (Mermaid)

```mermaid
erDiagram
    USERS {
        varchar ID PK
        varchar FULL_NAME
        varchar USERNAME
        varchar EMAIL
        varchar PHONE
        varchar OFFICE_PHONE
        varchar DIAL_NUMBER
        varchar ADDRESS
        date DATE_OF_BIRTH
        number GENDER
        varchar CITIZEN_ID_NUMBER
        varchar TAX_ID_NUMBER
        varchar CODE
        varchar KEY_CLOAK_ID
        number USER_TYPE
        varchar USER_SUB_TYPE
        varchar ORGANIZATION_CODE
        varchar ORGANIZATION_NAME
        varchar DEPARTMENT_ID
        varchar POSTION_ID
        varchar STOCK_CODE
        varchar PRACTICE_CERTIFICATE_TYPE_ID
        varchar REPRESENTATIVE_NAME
        varchar REPRESENTATIVE_CITIZEN_ID
        varchar REPRESENTATIVE_PHONE
        varchar REPRESENTATIVE_EMAIL
        varchar REPRESENTATIVE_POSITION_ID
        varchar IS_SUPER_ADMIN
        varchar AVATAR_PATH
        varchar STATUS_REASON
        number COUNT_LOGIN_FALSE
        timestamp EXPIRE_LOCK_USER
        timestamp LAST_LOGIN
        varchar CREATED_BY_ID FK
        varchar UPDATED_BY_ID FK
    }

    USERS ||--o{ USERS : "CREATED_BY_ID / UPDATED_BY_ID (self-ref audit)"
```

> Trường hệ thống đã loại: STATUS, DELETED, CREATED_AT, UPDATED_AT, CREATED_BY_ID, CREATED_BY_NAME, UPDATED_BY_ID, UPDATED_BY_NAME, VERSION (không thiết kế Atomic).

---

## 6c. Diagram Atomic (Mermaid)

```mermaid
erDiagram
    IAM_System_User {
        bigint ds_id PK
        string user_code
        string username
        string full_name
        date date_of_birth
        string gender_code
        string user_type_code
        string user_sub_type_code
        string keycloak_id
        string organization_code
        string department_id
        string position_id
        string stock_code
        string practice_certificate_type_code
        string representative_name
        string representative_citizen_id
        string representative_phone_email
        string representative_position_id
        string is_super_admin_ind
        string avatar_path
        string status_reason
        smallint count_login_fail
        timestamp expire_lock_ts
        timestamp last_login_ts
    }

    Involved_Party_Postal_Address {
        bigint ip_id
        string src_stm_code
        string adr_tp_code
        string adr_val
    }

    Involved_Party_Electronic_Address {
        bigint ip_id
        string src_stm_code
        string elc_adr_tp_code
        string elc_adr_val
    }

    Involved_Party_Alternative_Identification {
        bigint ip_id
        string src_stm_code
        string identn_tp_code
        string identn_nbr
    }

    IAM_System_User ||--o{ Involved_Party_Postal_Address : "ip_id (shared entity)"
    IAM_System_User ||--o{ Involved_Party_Electronic_Address : "ip_id (shared entity)"
    IAM_System_User ||--o{ Involved_Party_Alternative_Identification : "ip_id (shared entity)"
```

---

## 6d. Mục Danh mục & Tham chiếu (Reference Data)

| Source Field / Bảng | Mô tả | Scheme Code | source_type | Ghi chú |
|---|---|---|---|---|
| `USERS.GENDER` | Giới tính (1: Nam, 2: Nữ, 3: Khác) | `IAM_GENDER` | etl_derived | ETL map NUMBER → MALE/FEMALE/OTHER |
| `USERS.USER_TYPE` | Loại người dùng (NUMBER) | `IAM_USER_TYPE` | modeler_defined | Cần profile values từ team IAM |
| `USERS.USER_SUB_TYPE` | Phân loại người dùng (VARCHAR) | `IAM_USER_SUB_TYPE` | source_table | Lấy distinct values từ USERS.USER_SUB_TYPE |
| `USERS.PRACTICE_CERTIFICATE_TYPE_ID` | Loại chứng chỉ hành nghề | `IAM_PRACTICE_CERT_TYPE` | modeler_defined | Cần xác nhận bảng ref gốc (hiện chỉ là VARCHAR2(36) không có FK rõ) |

---

## 6e. Bảng chờ thiết kế

*(Để trống — IAM chỉ có 1 bảng USERS, đã thiết kế đủ)*

---

## 6f. Điểm cần xác nhận

| # | Câu hỏi | Kết quả |
|---|---|---|
| T1-01 | `DEPARTMENT_ID` và `POSTION_ID` (typo?) có FK đến bảng nào? Hiện không có FK constraint rõ trong schema IAM. Nếu có bảng DEPARTMENTS/POSITIONS riêng → cần bổ sung source. | Chờ xác nhận với team IAM |
| T1-02 | `PRACTICE_CERTIFICATE_TYPE_ID` trỏ về bảng nào? Có phải bảng từ source NHNCK không? Nếu có → cần review FK cross-source. | Chờ xác nhận |
| T1-03 | `REPRESENTATIVE_*` fields (tên, CCCD, SĐT, email, chức vụ người đại diện) — đây là người đại diện pháp lý của tổ chức (khi USER_TYPE = tổ chức) hay là người giám sát nội bộ? Có cần tách thành entity riêng không? | Tạm giữ denormalized trên `Identity and Access Management User`. Nếu xác nhận là Involved Party thực sự → cần tách Tier 2. |
| T1-04 | `ORGANIZATION_CODE` + `ORGANIZATION_NAME` — có FK đến bảng tổ chức nào trong hệ thống (SCMS, NHNCK)? Hay chỉ là text denormalized? | Chờ xác nhận — ảnh hưởng đến cross-source FK |
| T1-05 | `USERS.UPDATE` mode ↔ `Identity and Access Management User` Fundamental (SCD4A): cơ chế ETL cần xác nhận — SCD4A track lịch sử, phù hợp với Update mode. Không có issue. | OK — ghi nhận để review ETL. |
