### §2.{{ idx }} {{ source }} — {{ source_desc }}

#### §2.{{ idx }}.1 Các mô hình quan hệ dữ liệu

![ERD {{ source }}](erd_{{ source }}.png)

> Nguồn DBML: [`{{ source }}.dbml`]({{ source }}.dbml) — paste vào https://dbdiagram.io để render và screenshot.

**Danh sách bảng:**

| STT | Thực thể | Tên bảng | Mô tả |
|---|---|---|---|
{% for e in entities -%}
| {{ loop.index }} | {{ e.entity_name }} | {{ e.table_name }} | {{ e.description }} |
{% endfor %}

{% for e in entities %}
#### §2.{{ idx }}.{{ loop.index + 1 }} Bảng {{ e.entity_name }}

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
{% for a in e.attributes -%}
| {{ loop.index }} | {{ a.attribute_name }} | {{ a.data_domain | data_domain_to_sql }} | {{ a.nullable | x_or_blank }} | {{ a.is_primary_key | x_or_blank }} | {{ a | pk_fk_label }} | {{ a | default_value(source) }} | {{ a.description }} |
{% endfor %}

##### Constraint

{% if e.constraints -%}
| Trường | Bảng tham chiếu | Trường tham chiếu |
|---|---|---|
{% for c in e.constraints -%}
| {{ c.field }} | {{ c.ref_table }} | {{ c.ref_field }} |
{% endfor %}
{% else -%}
*Không có FK constraint.*
{% endif %}

##### Index

*Không áp dụng cho Silver.*

##### Trigger

*Không áp dụng cho Silver.*

{% endfor %}
