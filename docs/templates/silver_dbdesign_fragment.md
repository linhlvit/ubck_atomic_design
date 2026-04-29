## 2.{{ idx }} {{ source }} — {{ source_desc }}

### 2.{{ idx }}.1 Các mô hình quan hệ dữ liệu

- DBML tổng hợp (tất cả bảng): [`{{ source }}.dbml`]({{ source }}.dbml) — paste vào https://dbdiagram.io để render.
{% if uid_groups %}- Diagram theo mảng nghiệp vụ:
{% for g in uid_groups %}  - **{{ g.uid }} — {{ g.label }}**: [`{{ source }}_{{ g.uid }}.dbml`]({{ source }}_{{ g.uid }}.dbml)
{% endfor %}{% endif %}

**Danh sách bảng:**

| STT | Thực thể | Tên bảng | Mô tả |
|---|---|---|---|
{% for e in unique_entities -%}
| {{ loop.index }} | {{ e.silver_entity }} | {{ e.silver_table }} | {{ e.description }} |
{% endfor %}

{% for e in entities %}
### 2.{{ idx }}.{{ loop.index + 1 }} Bảng {{ e.silver_entity }}{% if e.is_shared %} — {{ e.source_system }}.{{ e.source_table }}{% endif %}

- **Mô tả:** {{ e.description }}
- **Tên vật lý:** {{ e.silver_table }}
- **Đường dẫn trên kho dữ liệu:**
- **Các trường partition:**
- **Thời gian lưu trữ:** 5 năm
- **Định dạng lưu trữ:** Iceberg

| STT | Tên trường | Tên cột | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả | Schema.Table | Source Field Name | ETL Rules |
|---|---|---|---|---|---|---|---|---|---|---|---|
{% for a in e.attributes -%}
| {{ loop.index }} | {{ a.attribute_name }} | {{ a.silver_column }} | {{ a.data_domain | data_domain_to_sql }} | {{ a.nullable | x_or_blank }} | {{ a.is_primary_key | x_or_blank }} | {{ a | pk_fk_label }} | {{ a | default_value(source) }} | {{ a.description }} | {{ a.source_system }}.{{ a.source_table }} | {{ a.source_column_name }} | {{ a | etl_rule }} |
{% endfor %}

#### 2.{{ idx }}.{{ loop.index + 1 }}.1 Constraint

**Khóa chính (Primary Key):**

{% if e.primary_keys -%}
| Tên trường | Tên cột |
|---|---|
{% for pk in e.primary_keys -%}
| {{ pk.attribute_name }} | {{ pk.silver_column }} |
{% endfor %}
{% else -%}
*Không có Primary Key.*
{% endif %}

**Khóa phụ (Foreign Key):**

{% if e.constraints -%}
| Tên trường | Tên cột | Bảng tham chiếu | Trường tham chiếu | Cột tham chiếu |
|---|---|---|---|---|
{% for c in e.constraints -%}
| {{ c.field }} | {{ c.col }} | {{ c.ref_table }} | {{ c.ref_field }} | {{ c.ref_col }} |
{% endfor %}
{% else -%}
*Không có Foreign Key.*
{% endif %}

{% endfor %}
