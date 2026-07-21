# DTM_TT_Entities — Data Mart: Phân hệ Thanh Tra (TT)

**Phạm vi:** 15 Datamart entities — 7 Fact + 4 Dim (2 Conformed reuse + 2 mới) + 4 Tác nghiệp

---

## Cụm 1: Tab TỔNG QUAN — Thống kê chung, xu hướng theo tháng, cơ cấu vi phạm (Nhóm 1–3)

```mermaid
erDiagram
    Calendar_Date_Dimension ||--o{ Fact_Inspection_Team_Activity : " "
    Inspection_Team_Dimension ||--o{ Fact_Inspection_Team_Activity : " "
```

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Fact Inspection Team Activity | Fact — Event | new | 1 đoàn thanh tra | 1 row per `INSPECTION_TEAM` | K_TT_1–6b (Nhóm 1), K_TT_7–9 (Nhóm 2), K_TT_9b–15 (Nhóm 3) |
| Calendar Date Dimension | Dimension | reuse | Lịch ngày | 1 row / ngày | — |
| Inspection Team Dimension | Dimension | new | Thuộc tính mô tả đoàn thanh tra | 1 row / đoàn thanh tra | — |

---

## Cụm 1b: Tab KIỂM TRA — Thống kê chung, xu hướng theo tháng, cơ cấu kiểm tra (Nhóm 6–8)

```mermaid
erDiagram
    Calendar_Date_Dimension ||--o{ Fact_Examination_Team_Activity : " "
    Examination_Team_Dimension ||--o{ Fact_Examination_Team_Activity : " "
```

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Fact Examination Team Activity | Fact — Event | new | 1 vụ việc kiểm tra | 1 row per `EXAMINATION_TEAM` | K_TT_24–29b (Nhóm 6), K_TT_30–32 (Nhóm 7), K_TT_32b–44k (Nhóm 8) |
| Calendar Date Dimension | Dimension | reuse | Lịch ngày | 1 row / ngày | — |
| Examination Team Dimension | Dimension | new | Thuộc tính mô tả vụ việc kiểm tra | 1 row / vụ việc kiểm tra | — |

---

## Cụm 1c: Tab TỔNG QUAN — Cơ cấu vi phạm theo đối tượng (Nhóm 4)

```mermaid
erDiagram
    Calendar_Date_Dimension ||--o{ Fact_Inspection_Team_Target_Activity : " "
```

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Fact Inspection Team Target Activity | Fact — Event | new | 1 đoàn thanh tra × 1 đối tượng — tách riêng để tránh fanout so với Fact Inspection Team Activity | 1 row per `INSPECTION_TEAM` × `INSPECTION_TEAM_TARGET` (N:1) | K_TT_16–23b (Nhóm 4) |
| Calendar Date Dimension | Dimension | reuse | Lịch ngày (join qua Inspection Team) | 1 row / ngày | — |

---

## Cụm 1d: Tab KIỂM TRA — Cơ cấu kiểm tra theo đối tượng (Nhóm 9)

```mermaid
erDiagram
    Calendar_Date_Dimension ||--o{ Fact_Examination_Team_Target_Activity : " "
```

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Fact Examination Team Target Activity | Fact — Event | new | 1 vụ kiểm tra × 1 đối tượng — tách riêng để tránh fanout so với Fact Examination Team Activity. Đóng O_TT_7 | 1 row per `EXAMINATION_TEAM` × `EXAMINATION_TEAM_TARGET` (N:1) | K_TT_45–54, K_TT_49b (Nhóm 9) |
| Calendar Date Dimension | Dimension | reuse | Lịch ngày (join qua Examination Team) | 1 row / ngày | — |

---

## Cụm 2: Tab TỔNG QUAN — Danh sách vụ việc Thanh tra (Nhóm 5)

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Inspection Case List | Tác nghiệp | new | Danh sách đoàn thanh tra × đối tượng — latest state. Không reuse `securities_company_compliance_history` (module QLKD, khác table_type/mục đích) | 1 row per `INSPECTION_TEAM` × `INSPECTION_TEAM_TARGET` (N:1) | Nhóm 5 (TT) |

---

## Cụm 2b: Tab KIỂM TRA — Danh sách vụ việc Kiểm tra (Nhóm 10)

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Examination Case List | Tác nghiệp | new | Danh sách vụ kiểm tra × đối tượng — latest state | 1 row per `EXAMINATION_TEAM` × `EXAMINATION_TEAM_TARGET` (N:1) | Nhóm 10 (KT) |

---

## Cụm 3: Tab XỬ PHẠT — Thống kê chung, xu hướng theo tháng (Nhóm 11–12)

```mermaid
erDiagram
    Calendar_Date_Dimension ||--o{ Fact_Penalty_Decision : " "
```

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Fact Penalty Decision | Fact — Event | new | 1 quyết định xử phạt | 1 row per `PENALTY_DECISION` | K_TT_55–60, K_TT_55b (Nhóm 11, 12) |
| Calendar Date Dimension | Dimension | reuse | Lịch ngày | 1 row / ngày | — |

---

## Cụm 3b: Tab XỬ PHẠT — Cơ cấu xử phạt theo loại hành vi + Báo cáo hoạt động vi phạm TTCK (Nhóm 13, STT 20)

```mermaid
erDiagram
    Calendar_Date_Dimension ||--o{ Fact_Penalty_Decision_Subject_Behavior : " "
```

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Fact Penalty Decision Subject Behavior | Fact — Event | new | 1 QĐ × 1 đối tượng × 1 hành vi — 4-way join. Đóng O_TT_8 | 1 row per `PENALTY_DECISION` × `PENALTY_DECISION_SUBJECT` × `PENALTY_DECISION_SUBJECT_BEHAVIOR` × `VIOLATION_BEHAVIOR` | K_TT_60b–72k (Nhóm 13), K_TT_88c, K_TT_89–100c (Báo cáo STT 20 — reuse) |
| Calendar Date Dimension | Dimension | reuse | Lịch ngày (join qua Penalty Decision) | 1 row / ngày | — |

---

## Cụm 3c: Tab XỬ PHẠT — Cơ cấu xử phạt theo đối tượng (Nhóm 14)

```mermaid
erDiagram
    Calendar_Date_Dimension ||--o{ Fact_Penalty_Decision_Subject : " "
```

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Fact Penalty Decision Subject | Fact — Event | new | 1 QĐ × 1 đối tượng. Đóng O_TT_9 | 1 row per `PENALTY_DECISION` × `PENALTY_DECISION_SUBJECT` (N:1) | K_TT_72l, K_TT_73–80 (Nhóm 14) |
| Calendar Date Dimension | Dimension | reuse | Lịch ngày (join qua Penalty Decision) | 1 row / ngày | — |

---

## Cụm 3d: Tab XỬ PHẠT — Danh sách quyết định xử phạt (Nhóm 15)

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Penalty Decision List | Tác nghiệp | new | Danh sách QĐ × đối tượng — latest state | 1 row per `PENALTY_DECISION` × `PENALTY_DECISION_SUBJECT` (N:1) | Nhóm 15 (XP) |

---

## Cụm 4: Tab ĐƠN THƯ — KPI card, biểu đồ xu hướng, cơ cấu, danh sách chi tiết (Nhóm 16–19)

| Datamart Entity | Loại | Reuse | Mô tả | Grain | KPI |
|---|---|---|---|---|---|
| Petition List | Tác nghiệp | new | Đơn thư — latest state. Serve cả KPI aggregate (Nhóm 16–18) lẫn danh sách chi tiết (Nhóm 19). Đóng O_TT_10 | 1 row per `PETITION` | Nhóm 16–19 (ĐT), K_TT_80b–88b |

---

## Tổng quan toàn bộ mô hình

```mermaid
erDiagram
    Calendar_Date_Dimension ||--o{ Fact_Inspection_Team_Activity : " "
    Inspection_Team_Dimension ||--o{ Fact_Inspection_Team_Activity : " "
    Calendar_Date_Dimension ||--o{ Fact_Examination_Team_Activity : " "
    Examination_Team_Dimension ||--o{ Fact_Examination_Team_Activity : " "
    Calendar_Date_Dimension ||--o{ Fact_Inspection_Team_Target_Activity : " "
    Calendar_Date_Dimension ||--o{ Fact_Examination_Team_Target_Activity : " "
    Calendar_Date_Dimension ||--o{ Fact_Penalty_Decision : " "
    Calendar_Date_Dimension ||--o{ Fact_Penalty_Decision_Subject_Behavior : " "
    Calendar_Date_Dimension ||--o{ Fact_Penalty_Decision_Subject : " "
```

**Bảng tổng hợp:**

| Datamart Entity | Loại | Reuse | Grain | Source Atomic | KPI phục vụ |
|---|---|---|---|---|---|
| Calendar Date Dimension | Dim — Conformed | reuse | 1 ngày | `cdr_dt` | — |
| Classification Dimension | Dim — Conformed | reuse | 1 (Scheme, Code) | `cv` | — (không nhóm nào tham chiếu, giữ vì Conformed toàn hệ thống) |
| Inspection Team Dimension | Dim — Reference per module | new | 1 đoàn thanh tra | `inspection_team` | — |
| Examination Team Dimension | Dim — Reference per module | new | 1 vụ việc kiểm tra | `examination_team` | — |
| Fact Inspection Team Activity | Fact — Event | new | 1 đoàn thanh tra | `inspection_team` | K_TT_1–6b, K_TT_7–9, K_TT_9b–15 |
| Fact Examination Team Activity | Fact — Event | new | 1 vụ việc kiểm tra | `examination_team` | K_TT_24–29b, K_TT_30–32, K_TT_32b–44k |
| Fact Inspection Team Target Activity | Fact — Event | new | 1 đoàn × 1 đối tượng | `inspection_team` / `inspection_team_target` | K_TT_16–23b |
| Fact Examination Team Target Activity | Fact — Event | new | 1 vụ × 1 đối tượng | `examination_team` / `examination_team_target` | K_TT_45–54, K_TT_49b |
| Fact Penalty Decision | Fact — Event | new | 1 QĐXP | `penalty_decision` | K_TT_55–60, K_TT_55b |
| Fact Penalty Decision Subject Behavior | Fact — Event | new | 1 QĐ × 1 đối tượng × 1 hành vi | `penalty_decision` / `penalty_decision_subject` / `pd_subject_behavior` / `violation_behavior` | K_TT_60b–72k, K_TT_88c, K_TT_89–100c |
| Fact Penalty Decision Subject | Fact — Event | new | 1 QĐ × 1 đối tượng | `penalty_decision` / `penalty_decision_subject` | K_TT_72l, K_TT_73–80 |
| Inspection Case List | Tác nghiệp | new | 1 đoàn × 1 đối tượng (latest) | `inspection_team` / `inspection_team_target` | Nhóm 5 |
| Examination Case List | Tác nghiệp | new | 1 vụ × 1 đối tượng (latest) | `examination_team` / `examination_team_target` | Nhóm 10 |
| Penalty Decision List | Tác nghiệp | new | 1 QĐ × 1 đối tượng (latest) | `penalty_decision` / `penalty_decision_subject` / `violation_case` | Nhóm 15 |
| Petition List | Tác nghiệp | new | 1 đơn thư (latest) | `petition` | Nhóm 16–19, K_TT_80b–88b |
