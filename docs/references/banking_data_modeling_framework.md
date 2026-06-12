# Banking Silver/Atomic Layer — Design Frameworks và Vocabulary Standards

**Cập nhật lần cuối:** 2026-06-01
**Phạm vi:** Kim chỉ nam thiết kế Silver/Atomic layer — độc lập với source system

---

## 0. Bản đồ tổng thể — Các Framework và Vai trò

Thiết kế Silver/Atomic layer cần trả lời 2 câu hỏi độc lập nhau:

| Câu hỏi | Framework giải quyết | Ghi chú |
|---|---|---|
| **WHAT** to model — *ý nghĩa nghiệp vụ của đối tượng là gì?* | IBM BCV/KAFS, FIBO | Semantic vocabulary — chọn 1 làm chuẩn tham chiếu |
| **HOW** to store — *tổ chức dữ liệu vật lý như thế nào?* | Data Vault 2.0, 3NF, Anchor Modeling | Storage pattern — có thể kết hợp tùy trường hợp |

Hai câu hỏi này **độc lập**: chọn IBM BCV làm vocabulary không ràng buộc phải dùng Data Vault để lưu trữ, và ngược lại.

**Các framework KHÔNG thuộc Silver layer:**
- **BIAN** (Banking Industry Architecture Network) — framework cho service/API domain, không phải data model. Chỉ liên quan gián tiếp qua định nghĩa business object.
- **Kimball Dimensional Modeling** — thiết kế cho Gold/Data Mart (Star Schema), không phải Silver.
- **One Big Table (OBT)** — denormalized, phù hợp Gold, không Silver.

---

## 1. IBM 9 Data Concepts (BCV)

**Kết luận nhanh:** Không lạc hậu ở tầng khái niệm — vẫn là kim chỉ nam thiết kế. Lạc hậu ở công cụ triển khai vật lý (BDW/FSDM). KAFS là thế hệ kế tiếp thay thế tooling, không thay thế concepts.

**Lịch sử hình thành:**

| Mốc | Sự kiện |
|---|---|
| ~1988 | Roger Evernden phát triển Information FrameWork (IFW) tại Westpac Bank (Úc) |
| 1992 | IBM thương mại hóa IFW → FSDM (Financial Services Data Model) |
| 1995 | 42 ngân hàng đã cấp license IBM FSDM |
| 1996 | Roger Evernden công bố IFW trên IBM Systems Journal (Vol. 35, No. 1) |
| 2006 | IBM phát hành IFW Poster v8 — bản đồ chuẩn 9 Data Concepts + 15 Core Objects |
| 2020+ | Kế thừa dưới dạng KAFS tích hợp Cloud Pak for Data |

**9 Data Concepts và ánh xạ sang 15 Core Objects chuẩn IBM:**

| # | Data Concept | Mô tả | 15 BCV Core Objects |
|---|---|---|---|
| 1 | Involved Party | Mọi thực thể tham gia nghiệp vụ | **Involved Party** |
| 2 | Arrangement | Thỏa thuận/hợp đồng giữa các bên | **Arrangement** |
| 3 | Product | Template/định nghĩa sản phẩm | **Product** |
| 4 | Condition | Quy tắc định giá, biểu phí, điều khoản | **Condition** |
| 5 | Location | Địa lý, địa chỉ vật lý | **Location** |
| 6 | Classification | Dữ liệu tham chiếu, danh mục | **Common**, **Group**, **Accounting** |
| 7 | Event | Sự kiện nghiệp vụ đã xảy ra | **Transaction**, **Communication**, **Event**, **Business Activity** |
| 8 | Resource Item | Tài sản hữu hình/vô hình | **Property**, **Documentation** |
| 9 | Business Direction Item | Kế hoạch, ngân sách, mục tiêu | **Business Direction** |

> **Lưu ý quan trọng:** 15 BCV Core Objects là danh sách chuẩn của IBM — đây là tầng *concept* (ngữ nghĩa). Cách triển khai vật lý thành bảng/entity cụ thể là lựa chọn của từng dự án. Ví dụ: `Involved Party` là 1 Core Object, nhưng khi thiết kế Atomic có thể tách thành nhiều entity vật lý (địa chỉ, liên lạc, giấy tờ định danh...) — đây là *pattern thiết kế*, không phải Core Object mới.

**Lý do vẫn còn giá trị:** Các khái niệm này phản ánh bản chất bất biến của nghiệp vụ ngân hàng. Một khoản vay năm 1990 hay 2026 vẫn là `Arrangement` giữa hai `Involved Party`, theo `Condition` lãi suất, phát sinh `Transaction` giải ngân/thu nợ.

**Nguồn:**
- IFW 1996 paper: https://dl.acm.org/doi/10.1147/sj.351.0037
- CIO Wiki IFW: https://cio-wiki.org/wiki/Information_Framework_(IFW)

---

## 2. IBM KAFS (Knowledge Accelerator for Financial Services)

**Kết luận nhanh:** KAFS kế thừa hoàn toàn 9 Data Concepts, chuyển từ physical schema sang semantic vocabulary layer. Với Databricks/Delta Lake, dùng BCV vocabulary làm kim chỉ nam — không cần deploy IBM tooling.

**"Semantic layer" có nghĩa gì trong ngữ cảnh KAFS:**

FSDM/BDW thế hệ cũ quy định cứng *bảng nào, trường nào* (physical DDL) — ai dùng FSDM là phải theo đúng schema đó. KAFS chuyển sang tầng *ngữ nghĩa*: định nghĩa concept và attribute ở tầng business, **không ràng buộc vào physical schema cụ thể**.

IBM phát biểu chính thức:
> *"The business terms in the Business Core Vocabulary can represent a vital business layer that provides a consistent set of terms that can be used by both business and technical teams to describe the information in their physical environment — the **business vocabulary itself is a logical construct independent of any specific physical database schema.**"*

> *"The Knowledge Accelerator for Financial Services is **independent of any one application** which allows it to be used in a holistic capacity across all business information."*

Phân biệt 3 tầng trong KAFS:

| Tầng | Là gì | Ví dụ |
|---|---|---|
| **Concept** | Ý nghĩa nghiệp vụ của một đối tượng, được định nghĩa bằng ngôn ngữ tự nhiên | `Lending Arrangement` — hợp đồng trong đó ngân hàng đặt tài sản vào rủi ro để thu phí từ khách hàng |
| **Attribute (Property term)** | Thuộc tính nghiệp vụ của concept, mô tả đặc điểm cụ thể | `Maturity Date`, `Current Utilization Amount`, `Loan Repayment Frequency` |
| **Physical design** | Lựa chọn của tổ chức/dự án — KAFS không quy định | 1 bảng Delta hay nhiều bảng, có partition không, lưu dư thừa bao nhiêu |

**Quan hệ type_of là kế thừa ontology, không phải foreign key:**

`Loan Arrangement` là `type_of Finance Service Arrangement` — không có nghĩa là 2 bảng có FK với nhau. Đây là **ontological inheritance** (kế thừa thuộc tính của concept cha). Khi thiết kế entity `Loan Arrangement` trên Atomic, tất cả attributes của các concept cha (`Finance Service Arrangement`, `Account Arrangement`, `Arrangement`) đều có thể áp dụng — team quyết định attribute nào cần lưu vật lý, không bị ép tạo bảng cha-con riêng.

```
Arrangement  ──type_of──▶  Finance Service Arrangement  ──type_of──▶  Loan Arrangement
(82 attrs)                  (139 attrs)                                (49 attrs trực tiếp)
                                                                       + kế thừa tất cả từ cha
```

**KAFS dùng định dạng SKOS (không phải DDL):**

IBM phát hành BCV dưới dạng file SKOS (Simple Knowledge Organization System — chuẩn W3C RDF), không phải SQL DDL. File `IBM_Banking_And_Financial_Markets_Business_Vocabulary_v89.skos` là machine-readable ontology — đây là bằng chứng rõ nhất rằng đây là vocabulary, không phải physical schema.

**Nguồn chính thức:**
- IBM Cloud Pak for Data — What is KAFS: https://dataplatform.cloud.ibm.com/docs/content/kaaas/overview/kafs.html
- IBM SKOS vocabulary v8.9: https://www.ibm.com/support/pages/ibm-banking-and-financial-markets-business-vocabulary-v89-skos-format
- IBM Community Blog (Karen Madera): https://community.ibm.com/community/user/blogs/karen-madera1/2020/08/07/building-an-extensible-business-vocabulary
- IBM Data Science in Practice (Medium): https://medium.com/ibm-data-ai/build-a-curated-business-vocabulary-for-your-data-fabric-9a2cddb8666c

**Chuỗi kế thừa:**

```
IFW (1988)
  └── FSDM/BDW (1992-2015): Physical schema, 9 Data Concepts, 7,400+ định nghĩa
        └── BFMDW v8.x (2015-2020): Logical model, SKOS export
              └── KAFS (2020+): Semantic layer, Cloud Pak for Data,
                                Watson Knowledge Catalog, AI metadata enrichment
```

**Kiến trúc KAFS — 6 Layer:**

| Layer | Nội dung | Số lượng |
|---|---|---|
| Business Core Vocabulary (BCV) | Thuật ngữ từ 9 Data Concepts | ~14,450 terms |
| Categories | Nhóm phân loại | 480 categories |
| Classifications | Phân loại dữ liệu cấp cao | 22 classifications |
| Reference Data Sets | Bộ dữ liệu tham chiếu chuẩn | 850 sets |
| Data Classes | Lớp phân loại dữ liệu | 76 additional classes |
| Business Performance Indicators (BPI) | KPI/metric chuẩn ngành | Included |

**So sánh BDW/FSDM vs KAFS:**

| Tiêu chí | IBM BDW/FSDM (cũ) | IBM KAFS (mới) |
|---|---|---|
| Mục tiêu | Physical data warehouse schema | Semantic vocabulary + governance |
| Triển khai | On-premises, monolithic | Cloud-native, modular |
| Governance | Không có | Watson Knowledge Catalog |
| Regulatory | Không tag sẵn | Modular Business Scopes (Basel, GDPR, FATCA, CCAR, AML) |
| Format | Relational DDL | SKOS (RDF/OWL) — machine-readable |
| Tính modular | All-or-nothing | Import từng Business Scope tùy chọn |

**Business Scopes có trong KAFS:**
- Credit & Lending
- Payments & Clearing
- Risk Management
- Regulatory Compliance (CCAR, Basel III/IV, GDPR, FATCA, AML)
- Customer Experience Management
- Wealth Management

**Nguồn:**
- KAFS docs: https://dataplatform.cloud.ibm.com/docs/content/ka/overview/kafs.html
- IBM Knowledge Accelerators: https://www.ibm.com/products/knowledge-accelerators

---

## 3. Cách tiếp cận IBM: Term chuẩn → BPI → Regulatory Scope

**Kết luận nhanh:** Top-down ontology-first — chuẩn hóa vocabulary trước, map sang BPI, gắn regulatory scope. Cách tiếp cận đúng về kiến trúc, các ngân hàng lớn (HSBC, Deutsche Bank) dùng làm reference model rồi adapt vào platform riêng.

**Ba tầng:**

**Tầng 1 — Standardized Term (BCV):**
Mọi khái niệm nghiệp vụ có một định nghĩa duy nhất. Ví dụ: "Customer" / "Client" / "Party" → đều là `Involved Party` với subtypes khác nhau. Loại bỏ ambiguity giữa các bộ phận: Risk dùng `Actual Exposure At Default`, Finance dùng `Current Utilization Amount` — cả hai đều là IBM BCV terms chuẩn, đều part_of `Finance Service Arrangement`, và team biết rõ chúng mô tả khía cạnh khác nhau của cùng một `Arrangement` concept.

**Tầng 2 — Business Performance Indicators (BPI):**
KPI/metric chuẩn ngành định nghĩa dựa trên BCV terms. Ý nghĩa: Gold layer metrics tham chiếu BPI catalog thay vì tự định nghĩa from scratch.

**Tầng 3 — Regulatory Scope Tagging:**
Mỗi BCV term được tag regulatory scope → khi map cột dữ liệu vào BCV term, tự động kế thừa regulatory obligations. Ví dụ: `tax_identification_number` → `Tax Identification` (BCV) → FATCA Scope → tự động vào data lineage FATCA.

**Ưu/nhược điểm:**

| Ưu điểm | Nhược điểm |
|---|---|
| Semantic consistency toàn tổ chức | Chi phí adoption cao, cần governance tooling |
| Regulatory automation | Vendor lock-in nếu dùng IBM tooling |
| BPI reusability giữa các dự án | Rigidity — khó điều chỉnh cho đặc thù quốc gia |
| Source-system agnostic | Overhead cho tổ chức nhỏ (80% terms thừa) |

---

## 4. Data Vault 2.0 — Ưu điểm và Hạn chế

**Kết luận nhanh:** Tốt nhất về storage pattern và historization cho Silver layer. Hạn chế lớn nhất: không có business vocabulary — không biết Hub này đại diện BCV concept gì. IBM BCV lấp đầy khoảng trống đó.

**Cấu trúc Data Vault 2.0:**

| Thành phần | Chức năng | Banking example |
|---|---|---|
| Hub | Business key + load metadata | HUB_CUSTOMER (CIF number) |
| Link | Quan hệ giữa các Hub | LNK_CUSTOMER_ACCOUNT |
| Satellite | Descriptive attributes + history | SAT_CUSTOMER_DEMOGRAPHICS |
| Bridge | Resolve M:N paths | BRG_ACCOUNT_PRODUCT |
| PIT (Point-in-Time) | Snapshot tại thời điểm | PIT_CUSTOMER_20260101 |
| Business Vault | Computed/derived attributes | BV_CUSTOMER_RISK_SCORE |

**Ưu điểm cho banking:**
- Full auditability: mọi thay đổi có timestamp, đáp ứng Basel/AML audit
- Additive integration: thêm source mới = thêm Satellites, không ảnh hưởng pipeline hiện tại
- Multi-source consolidation: Hub dùng business key → tự nhiên hợp nhất Customer từ nhiều source (core banking, CRM, KYC)
- No delete: soft-delete, full history

**Hạn chế:**

1. **Thiếu business vocabulary (hạn chế lớn nhất):** Định nghĩa *cách lưu trữ* nhưng không định nghĩa *ý nghĩa nghiệp vụ*. `HUB_CUSTOMER` và `HUB_COUNTERPARTY` — Data Vault không biết cả hai đều là `Involved Party`. IBM BCV biết.

2. **Query complexity cao:** Một query đơn giản cần JOIN Hub + PIT + 3-5 Satellites.

3. **Steep learning curve:** Hash Keys, Ghost Records, Zero-Records — khác hoàn toàn 3NF quen thuộc.

4. **Late-arriving data:** CDC từ core banking thường out-of-order, cần logic phức tạp thêm.

**Best practice kết hợp:**

```
IBM BCV 9 Concepts  (WHAT to model — semantic layer)
        +
3NF Normalized Entities  (HOW to structure)
        +
SCD Type 2 / SCD Type 4A  (HOW to historize)
        =
Atomic/Silver Layer chuẩn banking
```

**Nguồn:**
- Databricks — Implementing Data Vault on Lakehouse (prescriptive guide): https://www.databricks.com/blog/2022/06/24/prescriptive-guidance-for-implementing-a-data-vault-model-on-the-databricks-lakehouse-platform.html
- 7Rivers — Unifying Data Vault and Medallion Architecture: https://7riversinc.com/insights/unifying-strengths-how-data-vault-and-the-medallion-architecture-accelerate-enterprise-data-success/

---

## 5. FIBO — Alternative Vocabulary cho IBM BCV/KAFS

**Kết luận nhanh:** FIBO là tiêu chuẩn semantic mở (open source) do EDM Council và OMG duy trì — alternative quan trọng với IBM BCV/KAFS. Khác biệt cốt lõi: FIBO là cộng đồng, IBM KAFS là sản phẩm thương mại.

| Tiêu chí | IBM BCV/KAFS | FIBO |
|---|---|---|
| Tổ chức quản lý | IBM (thương mại) | EDM Council + OMG (cộng đồng, open source) |
| Định dạng | SKOS (RDF/OWL) | OWL (Web Ontology Language — W3C standard) |
| Chi phí | Có phí license (Cloud Pak for Data) | Miễn phí, GitHub public |
| Độ phủ | Banking, Insurance, Capital Markets | Chủ yếu Financial Services, Capital Markets |
| Tích hợp tooling | Watson Knowledge Catalog | Protégé, TopBraid, bất kỳ OWL-compatible tool |
| Ngân hàng đang dùng | HSBC, Deutsche Bank (adapt nội bộ) | Citigroup, Goldman Sachs, Wells Fargo (contributor) |
| Phù hợp khi | Cần tích hợp IBM ecosystem | Cần open standard, không muốn vendor lock-in |

**Quan hệ FIBO và IBM BCV:** Hai bộ vocabulary độc lập, phủ nhiều khái niệm trùng nhau. IBM BCV dùng 9 Data Concepts làm taxonomy gốc; FIBO dùng OWL class hierarchy phức tạp hơn nhưng mạnh hơn về formal logic. Thực tế: các ngân hàng thường chọn một trong hai làm chuẩn tham chiếu, không dùng song song.

**Nguồn:**
- FIBO Data Model (FIB-DM) — ~3,074 normative entities: https://spec.edmcouncil.org/fibo/page/data-model
- Banking Data Model scope của FIB-DM (Loans, Accounts, Payments): https://bankontology.com/banking-data-model/
- FIBO trong thực tế — JPMorgan, Bank of England, FCA: http://graphwise.ai/blog/the-power-of-ontologies-and-knowledge-graphs-practical-examples-from-the-financial-industry/
- FIBO GitHub (open source): https://github.com/edmcouncil/fibo

---

## 6. 3NF và Anchor Modeling — Storage Patterns Khác

**Kết luận nhanh:** 3NF là nền tảng lý thuyết mà mọi approach đều dựa vào. Anchor Modeling là alternative cực đoan hơn Data Vault nhưng ít được dùng trong thực tế.

### 3NF (Third Normal Form)

3NF là **nguyên tắc chuẩn hóa nền tảng**, không phải một framework hoàn chỉnh cho Silver layer. Nó loại bỏ redundancy bằng cách đảm bảo mỗi attribute chỉ phụ thuộc vào primary key — không phụ thuộc vào attribute khác.

Vai trò trong Medallion:
- Là **baseline** mà cả Data Vault lẫn IBM BCV đều áp dụng ngầm
- Khi Silver layer không dùng Data Vault (đơn giản hơn, ít nguồn hơn) → 3NF là lựa chọn thực tế
- Hạn chế: không có cơ chế historization tích hợp sẵn → phải tự implement SCD

### Anchor Modeling

Anchor Modeling là storage pattern cực kỳ normalized (6NF) — mỗi attribute là một bảng riêng. Ưu điểm lý thuyết: schema thay đổi không cần alter table. Thực tế:
- **Ít được dùng** do query complexity quá cao và thiếu tooling hỗ trợ
- Data Vault 2.0 giải quyết được hầu hết vấn đề mà Anchor Modeling nhắm tới nhưng thực tế hơn

**Nguồn:**
- Matillion — 3NF vs Data Vault (so sánh chi tiết, có decision rule): https://www.matillion.com/blog/3nf-vs-data-vault
- ERStudio — Silver layer: 3NF hoặc Data Vault tùy nhu cầu governance: https://erstudio.com/blog/modern-data-warehouse-architecture/
- Wikipedia — Anchor Modeling: https://en.wikipedia.org/wiki/Anchor_modeling

---

## 7. Bảng So sánh Tổng hợp

Tất cả các framework theo 2 trục — WHAT (vocabulary) và HOW (storage):

**Trục WHAT — Vocabulary/Semantic Standards:**

| Tiêu chí | IBM BCV/KAFS | FIBO |
|---|---|---|
| Tổ chức quản lý | IBM (thương mại) | EDM Council + OMG (open source) |
| Số lượng terms | ~14,450 | Hàng nghìn, liên tục mở rộng |
| BPI linkage | Có sẵn | Không có sẵn — tự build |
| Regulatory scope tagging | Modular (Basel, FATCA, AML) | Có thông qua FIBO regulatory extensions |
| Format | SKOS (RDF) | OWL (mạnh hơn về formal logic) |
| Vendor dependency | IBM tooling | Không — open standard |
| **Vai trò** | **Kim chỉ nam WHAT — proprietary** | **Kim chỉ nam WHAT — open standard** |

**Trục HOW — Storage Patterns:**

| Tiêu chí | Data Vault 2.0 | 3NF | Anchor Modeling |
|---|---|---|---|
| Historization | Tích hợp sẵn (Satellite) | Phải tự implement SCD | Tích hợp sẵn (6NF temporal) |
| Query complexity | Trung bình (Hub+Sat join) | Thấp | Rất cao (quá nhiều bảng) |
| Schema flexibility | Cao — additive | Trung bình | Rất cao |
| Tooling/ecosystem | Tốt (dbt, Spark) | Tốt | Kém |
| Phổ biến trong banking | **Rất cao** | Trung bình | Thấp |
| **Vai trò** | **HOW — lựa chọn chính** | **HOW — đơn giản hơn** | **HOW — học thuật** |

> **Kết hợp thực tế:** Vocabulary (IBM BCV hoặc FIBO) + Storage pattern (Data Vault 2.0 hoặc 3NF) — chọn độc lập theo nhu cầu dự án, không ràng buộc nhau.

**Dẫn chứng từ nguồn chính thức:**

Databricks (tác giả Medallion Architecture) phát biểu chính thức về Silver layer:
> *"The Silver Layer has more 3rd-Normal Form like data models, and Data Vault-like, write-performant data models can be used in this layer."*
— [Databricks: What is Medallion Architecture](https://www.databricks.com/blog/what-is-medallion-architecture)

ERStudio phát biểu:
> *"The silver layer can be implemented in 3NF or Data Vault, depending on governance and flexibility needs. 3NF excels at standardization and governance, while Data Vault supports flexibility and parallel development."*
— [ERStudio: Modern Data Warehouse Architecture](https://erstudio.com/blog/modern-data-warehouse-architecture/)

Matillion về decision rule:
> *"Few sources, need clarity → 3NF. Many sources, need audit → Data Vault."*
— [Matillion: 3NF vs Data Vault](https://www.matillion.com/blog/3nf-vs-data-vault)

---

## 8. Khuyến nghị Áp dụng

**Nguyên tắc cốt lõi: Atomic layer thiết kế độc lập với source system.**

BCV concept `Arrangement` tồn tại vì ngân hàng có hợp đồng với khách hàng — không phải vì source system có bảng tên đó. Nếu source system thay đổi, Atomic layer không cần thay đổi thiết kế, chỉ thay đổi ETL mapping.

1. **Dùng IBM BCV 9 Concepts làm blueprint, không deploy IBM tooling** — mỗi Atomic entity thuộc đúng một trong 15 BCV Core Objects, đặt tên theo IBM term, không theo tên bảng nguồn.

2. **Tra cứu IBM term trước khi đặt tên entity/attribute** — dùng KAFS BCV vocabulary làm nguồn tham chiếu đầu tiên, không suy luận từ tên bảng nguồn.

3. **Dùng KAFS BPI catalog làm checklist thiết kế Gold layer** — đảm bảo Atomic đủ grain và attribute để tính được các metric chuẩn ngành mà không cần quay lại source.

4. **Ưu tiên triển khai theo dependency giữa BCV Concepts:**

| Ưu tiên | BCV Core Object | Lý do ưu tiên |
|---|---|---|
| 1 | Involved Party | Foundation — mọi entity khác đều tham chiếu đến Party |
| 2 | Product | Template định nghĩa sản phẩm, Arrangement phụ thuộc |
| 3 | Arrangement | Entity trung tâm của nghiệp vụ ngân hàng |
| 4 | Condition | Phụ thuộc Arrangement và Product |
| 5 | Transaction / Event | Phụ thuộc Arrangement |
| 6 | Property | Tài sản đảm bảo, phụ thuộc Arrangement |
| 7 | Common / Group | Reference data — dùng chung, xây dựng song song |

5. **Xây dựng Internal Business Vocabulary (IBV)** dựa trên KAFS — bổ sung terms đặc thù từng quốc gia/tổ chức (NHNN, CIC, regulatory local), lưu trong metadata layer song song với BCV terms chuẩn IBM.
