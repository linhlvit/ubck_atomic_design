## {{ source }} — {{ source_desc }}

### Các mô hình quan hệ dữ liệu

![Mô hình quan hệ dữ liệu {{ source }}]({{ source }}/fragments/{{ source }}_diagram.png)

**Danh sách bảng:**

| STT | Tên bảng | Mô tả |
|---|---|---|
{% for e in unique_entities -%}
| {{ loop.index }} | {{ e.atomic_table }} | {{ e.description }} |
{% endfor %}

{% for ue in unique_entities %}
{% set grp = entities | selectattr("atomic_entity", "equalto", ue.atomic_entity) | list %}
### Bảng {{ ue.atomic_table }}

{% if ue.is_shared %}
{% for e in grp %}
#### Từ {{ e.source_system }}.{{ e.source_table }}

| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
{% for a in e.attributes -%}
| {{ loop.index }} | {{ a.atomic_column }} | {{ a | display_data_type }} | {{ a.nullable | x_or_blank }} | {{ a.is_primary_key | x_or_blank }} | {{ a | pk_fk_label }} | {{ a | default_value(source) }} | {{ a.description }} |
{% endfor %}

**Khóa chính (Primary Key):**

{% if e.primary_keys -%}
| Tên trường |
|---|
{% for pk in e.primary_keys -%}
| {{ pk.atomic_column }} |
{% endfor %}
{% else -%}
*Không có Primary Key.*
{% endif %}

**Khóa phụ (Foreign Key):**

{% if e.constraints -%}
| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
{% for c in e.constraints -%}
| {{ c.col }} | {{ c.ref_table_physical }} | {{ c.ref_col }} |
{% endfor %}
{% else -%}
*Không có Foreign Key.*
{% endif %}

**Index:** N/A

**Trigger:** N/A

{% endfor %}
{% else %}
{% set e = grp[0] %}
| STT | Tên trường | Kiểu dữ liệu và độ dài | Nullable | Unique | P/F Key | Mặc định | Mô tả |
|---|---|---|---|---|---|---|---|
{% for a in e.attributes -%}
| {{ loop.index }} | {{ a.atomic_column }} | {{ a | display_data_type }} | {{ a.nullable | x_or_blank }} | {{ a.is_primary_key | x_or_blank }} | {{ a | pk_fk_label }} | {{ a | default_value(source) }} | {{ a.description }} |
{% endfor %}

#### Constraint

**Khóa chính (Primary Key):**

{% if e.primary_keys -%}
| Tên trường |
|---|
{% for pk in e.primary_keys -%}
| {{ pk.atomic_column }} |
{% endfor %}
{% else -%}
*Không có Primary Key.*
{% endif %}

**Khóa phụ (Foreign Key):**

{% if e.constraints -%}
| Tên trường | Bảng tham chiếu | Cột tham chiếu |
|---|---|---|
{% for c in e.constraints -%}
| {{ c.col }} | {{ c.ref_table_physical }} | {{ c.ref_col }} |
{% endfor %}
{% else -%}
*Không có Foreign Key.*
{% endif %}

#### Index

N/A

#### Trigger

N/A

{% endif %}
{% endfor %}

### Stored Procedure/Function

N/A

### Package

N/A
