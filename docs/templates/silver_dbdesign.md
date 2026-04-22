---
title: UBCKNN — Thiết kế Cơ sở Dữ liệu Silver Lakehouse
generated_at: {{ generated_at }}
---

# ỦY BAN CHỨNG KHOÁN NHÀ NƯỚC

## TÀI LIỆU THIẾT KẾ CƠ SỞ DỮ LIỆU

**Phiên bản:** 1.0
**Phạm vi:** Silver Lakehouse — {{ sources | length }} source: {{ sources | join(", ") }}
**Ngày phát hành:** {{ generated_at }}

---

# TRANG KÝ NHẬN

*N/A — sẽ in/ký tay khi bàn giao chính thức.*

---

# LỊCH SỬ THAY ĐỔI

| Ngày | Phiên bản | Mô tả |
|---|---|---|
| {{ generated_at }} | 1.0 | Tự động sinh từ skill silver-gen-docs |

---

# 1. GIỚI THIỆU

## 1.1 Mục đích

Tài liệu mô tả thiết kế Silver Layer trong kiến trúc Medallion (Bronze/Silver/Gold) của lakehouse UBCK. Silver chuẩn hóa dữ liệu nguồn theo BCV (Business Concept Vocabulary) — chuẩn hóa 3NF, gom nhóm theo 9 Data Concept và 15 Core Object.

## 1.2 Phạm vi

Áp dụng cho **{{ sources | length }} hệ thống nguồn**: {{ sources | join(", ") }}.

Tổng số Silver entities: **{{ total_entities }}**. Tổng số attribute: **{{ grand_total_attrs }}**.

## 1.3 Tài liệu liên quan

| # | Tên | Nguồn |
|---|---|---|
| 1 | HLD Silver per source | `Silver/hld/{SOURCE}_HLD_Overview.md` + `_Tier{N}.md` |
| 2 | LLD Silver per entity | `Silver/lld/{SOURCE}/attr_*.csv` |
| 3 | Master entity registry | `Silver/hld/silver_entities.csv` |
| 4 | Master attribute registry | `Silver/lld/silver_attributes.csv` |
| 5 | BCV vocabulary | `knowledge/` |

---

# 2. CƠ SỞ DỮ LIỆU (OLTP)

> **Quy ước:** Mỗi phân hệ §2.X tương ứng 1 source nguồn. Silver entities được liệt kê dưới phân hệ tương ứng, kèm Source Table mapping.

{% for src_data in sources_data %}
{{ src_data.fragment }}
{% endfor %}

---

# 3. KHO DỮ LIỆU (OLAP)

*Sẽ thiết kế ở Gold layer (tài liệu riêng). Silver layer (tài liệu này) tập trung vào chuẩn hóa nguồn theo BCV — chưa phải dimensional model.*

---

# 4. THIẾT KẾ TỆP TIN

*Không cập nhật cho Silver — giữ template gốc UBCK.*

---

# 5. THIẾT KẾ MÃ

*Không cập nhật cho Silver — giữ template gốc UBCK.*

---

# 6. THIẾT KẾ VẬT LÝ

## 6.1 Lưu trữ

- **Engine:** Databricks SQL / Spark SQL trên Delta Lake.
- **Format:** Parquet (Delta protocol).
- **Vị trí:** `s3://ubck-silver/{source_lower}/{entity_snake_case}/`.

## 6.2 Partition

- **Fact Append / Snapshot:** partition theo `data_date` (column ETL injected).
- **Fundamental:** không partition — chuyển update theo SCD pattern.

## 6.3 Retention (TBD — chưa chốt với DBA)

| Tier | Storage class | Thời gian giữ |
|---|---|---|
| Hot | S3 Standard | 90 ngày |
| Warm | S3 IA | 1 năm |
| Cold | S3 Glacier | 5 năm |

---

# 7. PHỤ LỤC

## 7.1 Tổng hợp Classification Value

| Source | Scheme | Code | Name | Source type | Source table | Used in entities |
|---|---|---|---|---|---|---|
{% for c in all_classifications -%}
| {{ c.source }} | {{ c.scheme_code }} | {{ c.code }} | {{ c.name }} | {{ c.source_type }} | {{ c.source_table }} | {{ c.used_in_entities }} |
{% endfor %}

## 7.2 Pending design

| Source | Source table | Source column | Mô tả | Lý do | Hành động |
|---|---|---|---|---|---|
{% for p in all_pendings -%}
| {{ p.source_system }} | {{ p.source_table }} | {{ p.source_column }} | {{ p.description }} | {{ p.reason }} | {{ p.action }} |
{% endfor %}
