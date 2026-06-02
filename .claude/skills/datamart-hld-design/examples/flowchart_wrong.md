# Flowchart — Các pattern sai cần tránh

## SAI 1 — Node Staging dùng dấu chấm trong ID

```
❌ Sai:
    subgraph SRC["Staging"]
        FMS.RPTVALUES
        ECAT.ECAT_29_HolidayInfo
    end

✅ Đúng:
    subgraph SRC["Staging"]
        FMS_RPTVALUES["FMS.RPTVALUES"]
        ECAT_ECAT_29_HolidayInfo["ECAT.ECAT_29_HolidayInfo"]
    end
```

**Vấn đề:** Dấu chấm trong node ID bị mermaid parse như CSS class selector (`.RPTVALUES`) — node không hiển thị, edge bị đứt. Phải dùng `ID["label"]` syntax: ID không có dấu chấm, label hiển thị có dấu chấm.

---

## SAI 2 — Chia subgraph Staging theo hệ thống nguồn

```
❌ Sai:
    subgraph SRC_FMS["Staging (FMS)"]
        FMS_RPTVALUES["FMS.RPTVALUES"]
    end
    subgraph SRC_ECAT["Staging (ECAT)"]
        ECAT_ECAT_29_HolidayInfo["ECAT.ECAT_29_HolidayInfo"]
    end

✅ Đúng:
    subgraph SRC["Staging"]
        FMS_RPTVALUES["FMS.RPTVALUES"]
        ECAT_ECAT_29_HolidayInfo["ECAT.ECAT_29_HolidayInfo"]
    end
```

**Vấn đề:** Quy tắc bắt buộc là 1 subgraph Staging duy nhất label `"Staging"`. Prefix table name (`FMS.`, `ECAT.`) đã đủ thể hiện hệ thống nguồn — không cần chia block con.

---

## SAI 3 — Bỏ qua tầng Atomic

```
❌ Sai:
flowchart LR
    subgraph SRC["Staging"]
        FMS_RPTVALUES["FMS.RPTVALUES"]
    end
    subgraph GOLD["Datamart"]
        fct_fms_snpst["Fact FMS Snapshot"]
    end
    FMS_RPTVALUES --> fct_fms_snpst

✅ Đúng:
flowchart LR
    subgraph SRC["Staging"]
        FMS_RPTVALUES["FMS.RPTVALUES"]
    end
    subgraph SIL["Atomic"]
        Report_Import_Value["Report Import Value"]
    end
    subgraph GOLD["Datamart"]
        fct_fms_snpst["Fact FMS Snapshot"]
    end
    FMS_RPTVALUES --> Report_Import_Value
    Report_Import_Value --> fct_fms_snpst
```

**Vấn đề:** Bắt buộc 3 subgraph kể cả khi source map gần như thẳng. Tầng Atomic là contract giữa Staging và Datamart — bỏ qua làm mất lineage truy vết.

---

## SAI 4 — Thiếu Calendar Date Dimension trong Cụm có Fact

```
❌ Sai:
    subgraph SRC["Staging"]
        FMS_RPTVALUES["FMS.RPTVALUES"]
        %% Thiếu ECAT.ECAT_29_HolidayInfo
    end
    subgraph SIL["Atomic"]
        Report_Import_Value["Report Import Value"]
        %% Thiếu Calendar Date
    end
    subgraph GOLD["Datamart"]
        fct_fms_snpst["Fact FMS Snapshot"]
        %% Thiếu Calendar Date Dimension
    end

✅ Đúng: Calendar Date phải có đủ 3 tầng:
    - Staging: ECAT_ECAT_29_HolidayInfo["ECAT.ECAT_29_HolidayInfo"]
    - Atomic:  Calendar_Date["Calendar Date"]
    - Datamart: cdr_dt_dim["Calendar Date Dimension"]
```

**Vấn đề:** Mọi Cụm có Fact bắt buộc có Calendar Date Dimension. Thiếu → Fact không có FK date → không thể filter/slicer theo thời gian.

---

## SAI 5 — Vẽ Classification Value có nguồn Staging

```
❌ Sai:
    subgraph SRC["Staging"]
        FIMS_INVESTOR_TYPE["FIMS.INVESTOR_TYPE"]
    end
    subgraph SIL["Atomic"]
        Classification_Value["Classification Value"]
    end
    FIMS_INVESTOR_TYPE --> Classification_Value

✅ Đúng:
    subgraph SIL["Atomic"]
        Classification_Value["Classification Value"]
    end
    %% Không vẽ node trong Staging cho Classification Value
    Classification_Value --> ivsr_tp_dim
```

**Vấn đề:** Classification Value là entity tổng hợp danh mục từ nhiều nguồn — không map 1-1 từ bảng nguồn đơn lẻ. Chỉ vẽ node trong subgraph Atomic.
