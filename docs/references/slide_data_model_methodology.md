# Phương pháp Thiết kế Data Model
## Silver/Atomic Layer — Căn cứ và Tiêu chuẩn Quốc tế

Trả lời câu hỏi: Phương pháp thiết kế có đúng không? Có chuẩn quốc tế không? Có lạc hậu không?

---

# Thiết kế Silver layer cần trả lời 2 câu hỏi độc lập

| Câu hỏi | Ý nghĩa | Framework |
|---|---|---|
| **WHAT** to model | Đối tượng này là gì? Ý nghĩa nghiệp vụ? | IBM BCV/KAFS · FIBO |
| **HOW** to store | Tổ chức dữ liệu vật lý thế nào? | Data Vault 2.0 · 3NF |

> Hai câu hỏi **độc lập nhau** — chọn WHAT không ràng buộc HOW, và ngược lại

**Không thuộc Silver layer:**
- Kimball Dimensional → Gold/Data Mart
- BIAN → Service/API architecture
- One Big Table → Gold layer

---

# Bức tranh tổng thể — Các Framework

## WHAT to model — Vocabulary Standards
Định nghĩa *ý nghĩa nghiệp vụ* của từng đối tượng dữ liệu

**IBM BCV/KAFS** — thương mại, ~14,450 terms, Basel/FATCA/AML sẵn
**FIBO** — open source, EDM Council + OMG, chuẩn W3C OWL

## HOW to store — Storage Patterns
Tổ chức dữ liệu vật lý trên lakehouse

**Data Vault 2.0** — phổ biến nhất trong banking, Hub/Link/Satellite
**3NF** — đơn giản hơn, phù hợp ít nguồn
**Anchor Modeling** — học thuật, ít dùng thực tế

> *"The Silver Layer has more 3rd-Normal Form like data models, and Data Vault-like models can be used in this layer."*
> — Databricks (tác giả Medallion Architecture)

---

# IBM 9 Data Concepts — 30+ năm, vẫn là chuẩn ngành

## Lịch sử hình thành

- **~1988** — Roger Evernden phát triển Information FrameWork tại Westpac Bank (Úc)
- **1992** — IBM thương mại hóa → FSDM (Financial Services Data Model)
- **1995** — 42 ngân hàng cấp license trên toàn cầu
- **1996** — Công bố trên IBM Systems Journal (Vol. 35, No. 1)
- **2006** — IFW Poster v8: 9 Concepts + 15 Core Objects
- **2020+** — KAFS: thế hệ kế tiếp, cloud-native, tích hợp AI

## Tại sao không lạc hậu?

Bản chất nghiệp vụ ngân hàng **không thay đổi** theo thời gian.
Một khoản vay năm 1990 hay 2026 vẫn là:
`Arrangement` (hợp đồng) giữa `Involved Party` (các bên), theo `Condition` (lãi suất), phát sinh `Transaction` (giải ngân/thu nợ)

---

# 9 Data Concepts → 15 BCV Core Objects

| Data Concept | BCV Core Objects (chuẩn IBM) |
|---|---|
| Involved Party | Involved Party |
| Arrangement | Arrangement |
| Product | Product |
| Condition | Condition |
| Location | Location |
| Classification | Common · Group · Accounting |
| Event | Transaction · Communication · Event · Business Activity |
| Resource Item | Property · Documentation |
| Business Direction Item | Business Direction |

> **Lưu ý:** Đây là tầng **ngữ nghĩa** — không phải thiết kế bảng vật lý.
> Cách tổ chức bảng thực tế là quyết định của dự án, không bị IBM ràng buộc.

---

# IBM KAFS — Semantic Vocabulary, không phải Physical Schema

## FSDM/BDW cũ vs KAFS mới

| Tiêu chí | FSDM/BDW (1992-2015) | KAFS (2020+) |
|---|---|---|
| Mục tiêu | Physical DDL schema cứng | Semantic vocabulary linh hoạt |
| Triển khai | On-premises, monolithic | Cloud-native, modular |
| Regulatory | Không có | Basel · FATCA · AML · GDPR sẵn |
| Format | SQL DDL | SKOS/RDF/OWL — chuẩn W3C |

## IBM phát biểu chính thức

> *"The business vocabulary itself is a logical construct **independent of any specific physical database schema**."*

> *"Independent of any one application — used in a holistic capacity across all business information."*

**Ý nghĩa:** KAFS cung cấp vocabulary để đặt tên đúng — physical design (1 bảng hay nhiều bảng, partition thế nào) là quyết định của dự án.

---

# FIBO — Tiêu chuẩn Mở Song song

## Cùng mục tiêu với IBM BCV, khác cách tiếp cận

| Tiêu chí | IBM BCV/KAFS | FIBO |
|---|---|---|
| Tổ chức | IBM (thương mại) | EDM Council + OMG (open source) |
| Chi phí | Có phí license | Miễn phí, GitHub public |
| Format | SKOS (RDF) | OWL (W3C standard) |
| Phù hợp khi | Cần IBM ecosystem | Không muốn vendor lock-in |

## Ngân hàng đang tham gia FIBO

Citigroup · Deutsche Bank · Goldman Sachs · Wells Fargo · State Street · Credit Suisse · Nordea · Mizuho

> *"FIBO provides a type of Rosetta stone to help unlock the complexity of financial transactions."*
> — Wells Fargo (Chair, EDM Council FIBO initiative)

**Nguồn:** https://edmcouncil.org/financial-industry-business-ontology/

---

# Storage Patterns — Lựa chọn HOW to store

| Tiêu chí | Data Vault 2.0 | 3NF | Anchor Modeling |
|---|---|---|---|
| Historization | Tích hợp sẵn | Tự implement SCD | Tích hợp sẵn |
| Query complexity | Trung bình | Thấp | Rất cao |
| Schema flexibility | Cao — additive | Trung bình | Rất cao |
| Tooling/ecosystem | Tốt (dbt, Spark) | Tốt | Kém |
| **Phổ biến banking** | **Rất cao** | Trung bình | Thấp |

## Decision Rule

> *"Few sources, need clarity → 3NF. Many sources, need audit → Data Vault."*
> — Matillion (https://www.matillion.com/blog/3nf-vs-data-vault)

> *"3NF excels at standardization, while Data Vault supports flexibility and parallel development."*
> — ERStudio (https://erstudio.com/blog/modern-data-warehouse-architecture/)

---

# Phương pháp Áp dụng trong Dự án

## Công thức kết hợp

```
IBM BCV 9 Concepts        →  WHAT: ý nghĩa nghiệp vụ của từng entity
        +
3NF Normalized Entities   →  HOW: cấu trúc chuẩn hóa, loại bỏ redundancy
        +
SCD Type 2 / SCD Type 4A  →  HOW: lưu lịch sử thay đổi theo thời gian
        =
Atomic/Silver Layer chuẩn banking
```

## 3 Nguyên tắc cốt lõi

**1. Độc lập với source system**
Thiết kế theo nghiệp vụ ngân hàng, không theo cấu trúc hệ thống nguồn.
Nếu source system thay đổi → chỉ thay ETL mapping, không thiết kế lại Silver.

**2. Vocabulary chuẩn quốc tế**
Mỗi entity/attribute có tên theo IBM BCV term — không tự đặt tên tùy ý.

**3. BPI-driven design**
KAFS BPI catalog làm checklist để đảm bảo Silver đủ grain tính metric Gold.

---

# Benchmark — Tiêu chuẩn Quốc tế đang được Áp dụng

## FIBO — Ngân hàng tham gia chính thức

| Ngân hàng | Vai trò | Nguồn |
|---|---|---|
| **Citigroup** | Dẫn dắt phát triển module Business & Commerce | https://edmcouncil.org/financial-industry-business-ontology/ |
| **Wells Fargo** | Chair EDM Council FIBO initiative | https://edmcouncil.org/frameworks/industry-models/fibo/ |
| **State Street** | Triển khai PoC thực tế (interest-rate swaps) | https://www.americanbanker.com/bank-technology/state-street-tests-a-rosetta-stone-for-bank-databases-1090193-1.html |
| **Deutsche Bank** | FIBO contributor | https://edmcouncil.org/financial-industry-business-ontology/ |
| **Goldman Sachs** | FIBO contributor | https://globalfintechseries.com/featured/financial-information-business-ontology-fibo-architecture-use-cases-and-implementation-challenges/ |

## IBM Banking Data Warehouse

| Tổ chức | Triển khai | Nguồn |
|---|---|---|
| **Capital Bank of Jordan** | IBM Cloud Pak + BDW, hợp nhất 2 ngân hàng | https://www.ibm.com/case-studies/capital-bank |
| **HSBC** | IBM watsonx.data partnership | https://www.ibm.com/new/product-blog/how-bud-financial-built-a-data-intelligence-platform-on-ibm-watsonx-data/ |

> **Lưu ý:** Phần lớn ngân hàng lớn không công bố chi tiết kiến trúc nội bộ.
> Danh sách trên là các tổ chức có **tài liệu công khai** xác nhận.

---

# Kết luận — 3 Câu hỏi, 3 Câu trả lời

## Phương pháp có chuẩn quốc tế không?
✅ **Có** — IBM BCV/KAFS (30+ năm, 100+ ngân hàng) và FIBO (EDM Council + OMG, W3C standard) đều là tiêu chuẩn quốc tế được công nhận. Không có ngân hàng lớn nào thiết kế Silver layer mà không có vocabulary standard.

## Có lạc hậu không?
✅ **Không** — 9 Data Concepts bất biến vì bản chất nghiệp vụ ngân hàng không đổi. KAFS là thế hệ kế tiếp đang được IBM hiện đại hóa lên cloud-native và tích hợp AI/watsonx.

## Ngân hàng khác đang làm gì?
✅ **Cùng hướng** — Citigroup, Wells Fargo, State Street, Deutsche Bank đang dùng/đóng góp FIBO. HSBC, Capital Bank dùng IBM BDW/watsonx. Databricks chính thức khuyến nghị 3NF và Data Vault cho Silver layer.

---

# Tài liệu Tham khảo

- **Databricks — Medallion Architecture:** https://www.databricks.com/blog/what-is-medallion-architecture
- **Databricks — Data Vault on Lakehouse:** https://www.databricks.com/blog/2022/06/24/prescriptive-guidance-for-implementing-a-data-vault-model-on-the-databricks-lakehouse-platform.html
- **IBM KAFS:** https://www.ibm.com/products/knowledge-accelerators
- **IBM SKOS Vocabulary v8.9:** https://www.ibm.com/support/pages/ibm-banking-and-financial-markets-business-vocabulary-v89-skos-format
- **FIBO / FIB-DM:** https://spec.edmcouncil.org/fibo/page/data-model
- **EDM Council FIBO:** https://edmcouncil.org/financial-industry-business-ontology/
- **State Street FIBO PoC:** https://www.americanbanker.com/bank-technology/state-street-tests-a-rosetta-stone-for-bank-databases-1090193-1.html
- **Capital Bank IBM Case Study:** https://www.ibm.com/case-studies/capital-bank
- **Matillion — 3NF vs Data Vault:** https://www.matillion.com/blog/3nf-vs-data-vault
- **ERStudio — Modern DWH Architecture:** https://erstudio.com/blog/modern-data-warehouse-architecture/
