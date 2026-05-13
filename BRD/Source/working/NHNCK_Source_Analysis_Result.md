# NHNCK — Phân tích nghiệp vụ theo vòng đời người hành nghề

> **Phân hệ:** Quản lý giám sát người hành nghề chứng khoán (NHNCK)
> **Mục tiêu:** Hiểu khái niệm nghiệp vụ và tương quan giữa các thực thể theo vòng đời NHN.
> **Phạm vi:** Khảo sát CSDL nguồn (SQL Server).
>
> **Nguyên tắc:**
> - Chỉ khảo sát quan hệ FK **mang ý nghĩa nghiệp vụ** giữa các entity chính, không bao gồm FK đến bảng danh mục (`Dm*`).
> - Không khảo sát phân bố PII, không khảo sát data quality rule (null %, orphan FK, format check).
> - Mỗi bước trong vòng đời có: khái niệm → quan hệ → checklist câu hỏi → query gợi ý → diễn giải ý nghĩa.

---

## Sơ đồ vòng đời NHN

```
    ┌─────────────────────────────────────────────────────────────────┐
    │                                                                 │
    │   [1] NHN đăng ký                                               │
    │        │                                                        │
    │        │ tạo hồ sơ                                              │
    │        ▼                                                        │
    │   [2] Hồ sơ  ─────────────► [3] Thi sát hạch                    │
    │        │                          │                             │
    │        │ duyệt                    │ kết quả thi                  │
    │        ▼                          │                             │
    │   [4] Chứng chỉ ◄─────────────────┘                             │
    │        │                                                        │
    │        │ active → đi hành nghề                                  │
    │        ▼                                                        │
    │   [5] Công tác                                                  │
    │        │                                                        │
    │        │ (có thể)                                               │
    │        ▼                                                        │
    │   [6] Vi phạm ─────► thu hồi CC → quay lại [2] hồ sơ cấp lại    │
    │                                                                 │
    └─────────────────────────────────────────────────────────────────┘
```

## Bảng tổng quan thực thể và cardinality kỳ vọng

| # | Thực thể | Bảng nguồn | Quan hệ với NHN | Ghi chú |
|---|---|---|---|---|
| 1 | NHN (master) | `DvcNguoiHanhNghe` | — | Gốc của mọi quan hệ |
| 2 | Hồ sơ | `DvcHoSo` + `_TaiLieu`, `_LichSu`, `_ChuyenMon`, `_KinhNghiem` | 1 NHN — N hồ sơ | Có thể nộp nhiều hồ sơ theo thời gian |
| 3 | Kết quả thi | `DvcThiSatHach_ChiTiet` (+ `DvcThiSatHach`) | 1 NHN — N kết quả thi | Có thể thi nhiều lần, nhiều loại CC |
| 4 | Chứng chỉ | `DvcSoChungChi` | 1 NHN — N chứng chỉ | Có thể có nhiều loại CC |
| 5 | Công tác | `DvcNguoiHanhNghe_CongTac` + `DvcToChuc_BaoCao` | 1 NHN — N giai đoạn công tác | Khai báo + báo cáo từ tổ chức |
| 6 | Vi phạm | `DvcViPham` + `DvcNguoiHanhNghe_KyLuat` | 1 NHN — N vi phạm | *(chưa khảo sát đợt này)* |

## Quan hệ nghiệp vụ giữa các thực thể (không tính FK danh mục)

| Quan hệ | Bảng | Cột FK | Ý nghĩa nghiệp vụ |
|---|---|---|---|
| Hồ sơ ← thuộc về ← NHN | `DvcHoSo.DvcNguoiHanhNgheId` | | 1 NHN có N hồ sơ theo thời gian |
| Hồ sơ ← cấp ra → CC | `DvcHoSo.DvcSoChungChiId` | | Hồ sơ được duyệt sinh ra CC |
| Hồ sơ cấp lại ← gắn CC cũ → CC | `DvcHoSo.DvcSoChungChiCuId` | | Hồ sơ cấp lại liên kết CC cũ bị thu hồi |
| CC ← của ← NHN | `DvcSoChungChi.DvcNguoiHanhNgheId` | | 1 NHN có N CC (theo loại) |
| Kết quả thi ← của ← NHN | `DvcThiSatHach_ChiTiet.DvcNguoiHanhNgheId` | | 1 NHN có N lần thi; có thể NULL với thí sinh lần đầu |
| Công tác ← của ← NHN | `DvcNguoiHanhNghe_CongTac.DvcNguoiHanhNgheId` | | 1 NHN có N giai đoạn công tác |
| Báo cáo tổ chức ← về ← NHN | `DvcToChuc_BaoCao.DvcNguoiHanhNgheId` | | N báo cáo định kỳ/biến động |
| Vi phạm ← của ← NHN | `DvcViPham.DvcNguoiHanhNgheId` | | *(chưa khảo sát)* |

---

# Bước 1 — Người hành nghề chứng khoán (NHN)

## Khái niệm

NHN là cá nhân được/đang xin cấp chứng chỉ hành nghề chứng khoán do UBCKNN cấp. NHN là thực thể gốc — mọi hoạt động khác (hồ sơ, thi, CC, công tác, vi phạm) đều quy về 1 NHN cụ thể.

NHN có thể ở các trạng thái tổng quát:
- Đã đăng ký nhưng chưa có CC nào (thí sinh)
- Có CC nhưng chưa hành nghề (chưa gắn tổ chức)
- Đang hành nghề tại 1 tổ chức
- Không còn hành nghề (CC thu hồi / không gắn tổ chức)

## Quan hệ với các bước khác

- → **Bước 2 (Hồ sơ):** 1 NHN có N hồ sơ
- → **Bước 3 (Thi):** 1 NHN có N kết quả thi
- → **Bước 4 (CC):** 1 NHN có N CC
- → **Bước 5 (Công tác):** 1 NHN có N công tác
- → **Bước 6 (Vi phạm):** 1 NHN có N vi phạm

## Checklist câu hỏi nghiệp vụ

- [ ] Tổng số NHN trong hệ thống?
- [ ] Khoảng thời gian NHN được tạo (từ khi nào → nay)?
- [ ] Tốc độ tăng trưởng NHN theo năm?
- [ ] Bao nhiêu NHN đang gắn với tổ chức (`DmToChucId NOT NULL`), bao nhiêu không gắn?
- [ ] Phân bố theo loại chứng chỉ thường quan tâm (`DmTrinhDoId` nếu có liên quan)?
## Câu lệnh gợi ý

```sql
-- Q1. Tổng số NHN
SELECT COUNT(*) AS tong_nhn FROM DvcNguoiHanhNghe;

-- Q2. Khoảng thời gian
SELECT MIN(NgayTao) AS nhn_dau_tien, MAX(NgayTao) AS nhn_moi_nhat
FROM DvcNguoiHanhNghe;

-- Q3. Tăng trưởng theo năm
SELECT YEAR(NgayTao) AS nam, COUNT(*) AS so_nhn_moi
FROM DvcNguoiHanhNghe
WHERE NgayTao IS NOT NULL
GROUP BY YEAR(NgayTao)
ORDER BY nam;

-- Q4. Gắn với tổ chức?
SELECT
    CASE WHEN DmToChucId IS NULL THEN 'Không gắn tổ chức' ELSE 'Có tổ chức' END AS trang_thai,
    COUNT(*) AS cnt
FROM DvcNguoiHanhNghe
GROUP BY CASE WHEN DmToChucId IS NULL THEN 'Không gắn tổ chức' ELSE 'Có tổ chức' END;
```

## Diễn giải & gợi ý kết luận

**Kết quả thực tế đã khảo sát:**
- Tổng 14,879 NHN, dữ liệu từ 2013-11-05 đến 2026-03-02 (hơn 12 năm)
- **34.27% NHN không gắn tổ chức** (5,099 người) — con số lớn cần làm rõ nghiệp vụ

**Câu hỏi nghiệp vụ cần xác nhận với BA:**

1. **NHN không gắn tổ chức** nghĩa là gì? Có các khả năng:
   - Đã từng hành nghề nhưng đã nghỉ/chấm dứt HĐLĐ
   - Đã có CC nhưng chưa từng hành nghề
   - Dữ liệu cũ chưa update
   → Cần clarify để hiểu đúng trạng thái hành nghề của NHN

   TL:
   - Có 2 bản ghi NHNH không gắn với tổ chức: 1 bản ghi từ 2017 không được update thông tin công tác, 1 bản ghi đã hoàn thành công tác
   - Có nhiều NHN không gắn tổ chức, có CC, chưa từng hành nghề

2. Nếu NHN không gắn tổ chức có CC đang sử dụng → mâu thuẫn nghiệp vụ? Cần check cross-reference với Bước 4 (CC) và Bước 5 (Công tác).

    TL: Không có trường hợp này

3. Trạng thái "đang hành nghề" được xác định từ đâu — cột `TrangThai` của NHN hay suy ra từ `DmToChucId NOT NULL`?

    TL: Có 4 bảng ghi TrangThai = 0 mà vẫn đang công tác
    - 1 bản ghi tạo 2016 nghi vấn chưa được update
    - 2 bản ghi tạo 2023 không có thông tin công tác từ ngày nào đến ngày nào
    - 1 bản ghi tạo 2025 có thông tin từ ngày, không có thông tin đến ngày -> theo BA bảo đây là đang công tác (không tin lắm)

---

# Bước 2 — Hồ sơ cấp phép

## Khái niệm

Hồ sơ là đơn đề nghị NHN nộp cho UBCKNN để xin cấp, cấp lại, thu hồi CCHN. Mỗi hồ sơ có một loại (`LoaiHoSo`): Cấp mới / Cấp lại / Gia hạn / Thu hồi. Hồ sơ có workflow trạng thái và khi duyệt thành công sẽ gắn với 1 CC được cấp.

Một hồ sơ gồm: thông tin chính (bảng `DvcHoSo`) + tài liệu đính kèm + nhật ký xử lý + khai chuyên môn + khai kinh nghiệm.

## Quan hệ với các bước khác

- ← **Bước 1 (NHN):** Mỗi hồ sơ thuộc về 1 NHN (`DvcNguoiHanhNgheId`)
- → **Bước 4 (CC):** Hồ sơ được duyệt gắn với CC qua `DvcSoChungChiId`
- ← **Bước 4 (CC cũ):** Hồ sơ cấp lại gắn với CC cũ qua `DvcSoChungChiCuId` và `DmChungChiCuId`
- ← **Bước 3 (Thi):** Gián tiếp — NHN phải có kết quả thi đạt trước khi nộp hồ sơ cấp mới (không có FK trực tiếp từ hồ sơ sang kết quả thi)

## Checklist câu hỏi nghiệp vụ

- [ ] Tổng số hồ sơ? Growth theo năm?
- [ ] Phân bố theo `LoaiHoSo` (Cấp mới, Cấp lại, ...)
- [ ] Phân bố theo `DmChungChiId` (MGCK / PTTC / QLQ)
- [ ] Phân bố theo trạng thái xử lý (`DmTrangThaiId`) — tỷ lệ đã duyệt, đang xử lý, từ chối
- [ ] **1 NHN có bao nhiêu hồ sơ?** — phân bố 1, 2, 3, ≥4 hồ sơ
- [ ] **Hồ sơ cấp lại có luôn gắn với CC cũ không?** — consistency check của business rule
- [ ] **Hồ sơ đã cấp có luôn gắn với CC mới không?**
- [ ] Thời gian TB từ `NgayNop` đến `NgayCap` (thời gian xử lý)?
- [ ] Avg số tài liệu / hồ sơ? Avg số log / hồ sơ?
- [ ] `ViPham` = 1 có ý nghĩa gì? Có liên quan đến Bước 6 không?

## Câu lệnh gợi ý

```sql
-- Q1. Tổng hồ sơ, growth
SELECT COUNT(*) AS tong_ho_so,
       MIN(NgayNop) AS ho_so_dau, MAX(NgayNop) AS ho_so_cuoi
FROM DvcHoSo;

SELECT YEAR(NgayNop) AS nam, COUNT(*) AS cnt
FROM DvcHoSo WHERE NgayNop IS NOT NULL
GROUP BY YEAR(NgayNop) ORDER BY nam;

-- Q2. Phân bố LoaiHoSo
SELECT LoaiHoSo, COUNT(*) AS cnt,
       CAST(ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS DECIMAL(5,2)) AS pct
FROM DvcHoSo GROUP BY LoaiHoSo ORDER BY cnt DESC;

-- Q3. Phân bố DmChungChiId
SELECT DmChungChiId, COUNT(*) AS cnt,
       CAST(ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS DECIMAL(5,2)) AS pct
FROM DvcHoSo GROUP BY DmChungChiId;

-- Q4. Phân bố trạng thái
SELECT DmTrangThaiId, COUNT(*) AS cnt,
       CAST(ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS DECIMAL(5,2)) AS pct
FROM DvcHoSo GROUP BY DmTrangThaiId ORDER BY cnt DESC;

-- Q5. 1 NHN có bao nhiêu hồ sơ
SELECT so_ho_so, COUNT(*) AS so_nhn
FROM (
    SELECT DvcNguoiHanhNgheId, COUNT(*) AS so_ho_so
    FROM DvcHoSo
    WHERE DvcNguoiHanhNgheId IS NOT NULL
    GROUP BY DvcNguoiHanhNgheId
) x
GROUP BY so_ho_so
ORDER BY so_ho_so;

-- Q6. Hồ sơ cấp lại có gắn CC cũ không?
-- (LoaiHoSo = 2,3 = các loại cấp lại — cần xác nhận giá trị enum)
SELECT
    LoaiHoSo,
    SUM(CASE WHEN DvcSoChungChiCuId IS NOT NULL THEN 1 ELSE 0 END) AS co_cc_cu,
    SUM(CASE WHEN DvcSoChungChiCuId IS NULL THEN 1 ELSE 0 END) AS khong_cc_cu
FROM DvcHoSo
GROUP BY LoaiHoSo;

-- Q7. Hồ sơ đã cấp có gắn CC mới không?
-- (Cần biết DmTrangThaiId nào là 'Đã cấp')
SELECT
    DmTrangThaiId,
    SUM(CASE WHEN DvcSoChungChiId IS NOT NULL THEN 1 ELSE 0 END) AS co_cc_moi,
    SUM(CASE WHEN DvcSoChungChiId IS NULL THEN 1 ELSE 0 END) AS khong_cc_moi
FROM DvcHoSo
GROUP BY DmTrangThaiId
ORDER BY DmTrangThaiId;

-- Q8. Thời gian xử lý TB
SELECT
    AVG(DATEDIFF(DAY, NgayNop, NgayCap)) AS avg_ngay_xu_ly,
    MIN(DATEDIFF(DAY, NgayNop, NgayCap)) AS min_ngay,
    MAX(DATEDIFF(DAY, NgayNop, NgayCap)) AS max_ngay
FROM DvcHoSo
WHERE NgayNop IS NOT NULL AND NgayCap IS NOT NULL;

-- Q9. Avg tài liệu, log / hồ sơ
SELECT
    (SELECT CAST(COUNT(*) AS FLOAT) FROM DvcHoSo_TaiLieu) /
    NULLIF((SELECT CAST(COUNT(*) AS FLOAT) FROM DvcHoSo), 0) AS avg_tai_lieu_per_ho_so,
    (SELECT CAST(COUNT(*) AS FLOAT) FROM DvcHoSo_LichSu) /
    NULLIF((SELECT CAST(COUNT(*) AS FLOAT) FROM DvcHoSo), 0) AS avg_log_per_ho_so;

-- Q10. ViPham flag
SELECT ViPham, COUNT(*) AS cnt FROM DvcHoSo GROUP BY ViPham;
```

## Diễn giải & gợi ý kết luận

**Kết quả thực tế đã khảo sát:**
- Tổng **16,842 hồ sơ**, **16,467 chứng chỉ đã cấp**
- Phân bố `LoaiHoSo`: `0` = 98.3%, `1` = 1.54%, `2` = 0.17% — **Cấp mới chiếm tuyệt đối**
- Phân bố `DmChungChiId`: MGCK 60.14%, PTTC 20.39%, QLQ 19.48%
- Phân bố trạng thái: Trạng thái `7` = 97.83% (đã xử lý xong), `1` = 0.71%, `2` = 0.67%, còn lại 9 giá trị khác
- `ViPham = 1`: **chỉ 1 case** trong toàn bộ 16,842 hồ sơ → cờ gần như không dùng
- Avg 7.35 tài liệu / hồ sơ, avg 3.08 log / hồ sơ

**Câu hỏi nghiệp vụ cần xác nhận với BA:**

1. **Enum `LoaiHoSo`** — hiện có 3 giá trị (`0`, `1`, `2`) nhưng nghiệp vụ có ≥5 loại (Cấp mới / Cấp lại do thu hồi / Cấp lại do mất / Gia hạn / Thu hồi). Cần confirm:
   - `0`, `1`, `2` tương ứng những loại nào?
   - Tại sao chỉ có 3 giá trị thay vì ≥5?

   TL:
   - `0`: Hồ sơ cấp chứng chỉ, `1`: Hồ sơ cấp lại chứng chỉ PTTC, `2`: Hồ sơ chuyển đổi chứng chỉ QLQ
   - Không có thông tin nào cung cấp nghiệp vụ có ≥5 loại

2. **`DmTrangThaiId` có 9 giá trị** — cần mapping đầy đủ. Trạng thái `7` chiếm 97.83% — có phải "Đã cấp"? Các trạng thái còn lại?
    
    TL: Có bảng DmTrangThai có map đủ

3. **Cấp mới chiếm 98.3%** — trong hệ thống 12 năm mà hồ sơ cấp lại chỉ 1.7%, liệu có phản ánh đúng thực tế hay cấp lại được xử lý ngoài hệ thống?

    TL: Dữ liệu thực nên phản ánh đúng thực tế

4. **`ViPham` flag chỉ có 1 case** — cờ này có còn dùng không? Nếu vi phạm được lưu ở `DvcViPham` (Bước 6) thì cờ này thừa.

    TL: Có 1 bản ghi ViPham = 1 nhưng vẫn được cấp chứng chỉ (cùng NgayCap)

5. Hồ sơ cấp lại (LoaiHoSo = 1, 2) có luôn gắn với CC cũ không? Nếu có case không gắn → nghiệp vụ xử lý thế nào?

    TL: LoaiHoSo = 1 là cấp lại không gắn với CC cũ, cấp lại đúng số CC cũ

---

# Bước 3 — Thi sát hạch

## Khái niệm

Thi sát hạch là điều kiện cấp CCHN. Có 2 cấp dữ liệu:
- **Đợt thi (`DvcThiSatHach`):** 1 đợt tổ chức thi, gắn với 1 quyết định tổ chức thi
- **Kết quả thi (`DvcThiSatHach_ChiTiet`):** kết quả cá nhân của từng thí sinh trong đợt

Thí sinh thi **cùng lúc 2 phần**: Luật và Chuyên môn. Phải đạt cả 2 mới đạt tổng kết.

Đặc điểm quan trọng: **thí sinh có thể chưa phải là NHN đã đăng ký** — lần đầu đi thi chưa có record trong `DvcNguoiHanhNghe`, dẫn đến `DvcNguoiHanhNgheId` NULL.

## Quan hệ với các bước khác

- → **Bước 1 (NHN):** Kết quả thi gắn với NHN qua `DvcNguoiHanhNgheId` (nullable — thí sinh lần đầu chưa có master)
- → **Bước 2 (Hồ sơ):** Không có FK trực tiếp. Gián tiếp: NHN thi đạt → nộp hồ sơ cấp mới

## Checklist câu hỏi nghiệp vụ

- [ ] Tổng số đợt thi? Số đợt/năm?
- [ ] Tổng số kết quả thi? Avg thí sinh/đợt?
- [ ] Phân bố theo loại CC (`DmChungChiId`)?
- [ ] **Tỷ lệ pass tổng thể** (KetQua = Đạt)?
- [ ] Tỷ lệ pass phần Luật vs phần Chuyên môn — có lệch không?
- [ ] **Tỷ lệ thí sinh lần đầu** (không có `DvcNguoiHanhNgheId`)?
- [ ] **1 NHN đã thi bao nhiêu lần mới đạt?** — phân bố số lần thi
- [ ] Điểm trung bình, min, max?
- [ ] Khoảng thời gian TB giữa 2 lần thi của 1 NHN?

## Câu lệnh gợi ý

```sql
-- Q1. Tổng đợt thi, số đợt/năm
SELECT COUNT(*) AS tong_dot FROM DvcThiSatHach;

SELECT YEAR(ts.NgayTao) AS nam, COUNT(*) AS so_dot
FROM DvcThiSatHach ts
GROUP BY YEAR(ts.NgayTao) ORDER BY nam;

-- Q2. Tổng kết quả thi, avg thí sinh/đợt
SELECT
    COUNT(*) AS tong_ket_qua,
    CAST(COUNT(*) AS FLOAT) / NULLIF(COUNT(DISTINCT DvcThiSatHachId), 0) AS avg_thi_sinh_per_dot
FROM DvcThiSatHach_ChiTiet;

-- Q3. Phân bố loại CC
SELECT DmChungChiId, COUNT(*) AS cnt,
       CAST(ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS DECIMAL(5,2)) AS pct
FROM DvcThiSatHach_ChiTiet GROUP BY DmChungChiId;

-- Q4. Tỷ lệ pass
SELECT
    SUM(CASE WHEN KetQua = 1 THEN 1 ELSE 0 END) AS pass,
    SUM(CASE WHEN KetQua = 0 THEN 1 ELSE 0 END) AS fail,
    CAST(SUM(CASE WHEN KetQua = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS pass_rate_pct
FROM DvcThiSatHach_ChiTiet;

-- Q5. Tỷ lệ pass Luật vs Chuyên môn
SELECT
    CAST(SUM(CASE WHEN KetQuaLuat = N'Đạt' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS pass_luat_pct,
    CAST(SUM(CASE WHEN KetQuaChuyenMon = N'Đạt' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS pass_cm_pct
FROM DvcThiSatHach_ChiTiet;

-- Q6. Tỷ lệ thí sinh lần đầu
SELECT
    SUM(CASE WHEN DvcNguoiHanhNgheId IS NULL THEN 1 ELSE 0 END) AS lan_dau,
    SUM(CASE WHEN DvcNguoiHanhNgheId IS NOT NULL THEN 1 ELSE 0 END) AS da_co_master,
    CAST(SUM(CASE WHEN DvcNguoiHanhNgheId IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS lan_dau_pct
FROM DvcThiSatHach_ChiTiet;

-- Q7. 1 NHN thi bao nhiêu lần
SELECT so_lan_thi, COUNT(*) AS so_nhn
FROM (
    SELECT DvcNguoiHanhNgheId, COUNT(*) AS so_lan_thi
    FROM DvcThiSatHach_ChiTiet
    WHERE DvcNguoiHanhNgheId IS NOT NULL
    GROUP BY DvcNguoiHanhNgheId
) x
GROUP BY so_lan_thi
ORDER BY so_lan_thi;

-- Q8. Điểm distribution
SELECT
    AVG(CAST(DiemLuat AS FLOAT)) AS avg_luat,
    MIN(DiemLuat) AS min_luat, MAX(DiemLuat) AS max_luat,
    AVG(CAST(DiemChuyenMon AS FLOAT)) AS avg_cm,
    MIN(DiemChuyenMon) AS min_cm, MAX(DiemChuyenMon) AS max_cm
FROM DvcThiSatHach_ChiTiet;

-- Q9. Số lần thi để đạt (chỉ NHN đã đạt)
WITH lan_thi_per_nhn AS (
    SELECT DvcNguoiHanhNgheId, COUNT(*) AS so_lan,
           SUM(CASE WHEN KetQua = 1 THEN 1 ELSE 0 END) AS so_lan_dat
    FROM DvcThiSatHach_ChiTiet
    WHERE DvcNguoiHanhNgheId IS NOT NULL
    GROUP BY DvcNguoiHanhNgheId
)
SELECT so_lan, COUNT(*) AS so_nhn_da_dat
FROM lan_thi_per_nhn
WHERE so_lan_dat >= 1
GROUP BY so_lan
ORDER BY so_lan;
```

## Diễn giải & gợi ý kết luận

**Kết quả thực tế đã khảo sát:**
- **36 đợt thi**, **7,576 kết quả thi sát hạch**
- Phân bố loại CC: MGCK 69.43%, PTTC 17.94%, QLQ 12.63%
- **Tỷ lệ pass tổng thể: 86.13%** — cao
- **`DvcNguoiHanhNgheId` NULL 100%** — không có kết quả thi nào link với master NHN!
- Điểm scale 0-30 (không phải 0-100): avg Luật 24.80, avg CM 24.18; P75 ≈ 27-28
- `KetQuaLuat`, `KetQuaChuyenMon` kiểu `nvarchar "Đạt"/"Không đạt"`, `KetQua` là `INT` 0/1
- `SoBaoDanh` không match pattern `MGCK-N`/`PTTC-N`/`QLQ-N`

**Câu hỏi nghiệp vụ cần xác nhận với BA:**

1. **Nghiêm trọng nhất — `DvcNguoiHanhNgheId` NULL 100%** trong 7,576 kết quả thi. Nghĩa là **không có cách nào biết 1 NHN đã thi bao nhiêu lần**. Cần:
   - Nghiệp vụ link kết quả thi với NHN dựa trên gì? `SoCmt` trong kết quả thi và trong master NHN?
   - Có phải do kết quả thi được nhập trước khi tạo NHN (thí sinh mới chưa đăng ký)?
   - Sau khi NHN đăng ký, có backfill `DvcNguoiHanhNgheId` vào kết quả thi cũ không? → Xem chừng là không.

   TL:
   - Đã thử link qua Socmt, map được ~74%
   - 4991 NHN có kết quả thi trước khi tạo, 685 NHN có kết quả thi sau khi tại
   - Không backfill


2. **Điểm scale 0-30** — khác với kỳ vọng thông thường 0-100. Cần confirm:
   - 30 là max? Hay có case > 30?
   - Ngưỡng đạt là bao nhiêu? (avg 24-25 với pass rate 86% → có thể ngưỡng là 20)

   TL:
   - Không có quy chuẩn đánh giá Đạt hay Không Đạt cho điểm thi

3. **`KetQuaLuat`, `KetQuaChuyenMon` dùng text `"Đạt"/"Không đạt"`** nhưng `KetQua` dùng `INT 0/1` — inconsistency trong design. Có nên thống nhất?

    TL: Hỏi ý kiến design

4. **MGCK chiếm 69%** trong thi nhưng Hồ sơ MGCK chiếm 60% (Bước 2) — có thể do thí sinh MGCK có nhiều lần thi hơn (fail nhiều hơn)?

    TL: Thông tin này không cần thiết

5. **Chuyển đổi enum `KetQua`:** nếu migrate sang nguồn mới, Luật/CM có nên chuyển thành INT 0/1 giống KetQua tổng?

    TL: Hỏi ý kiến design

---

# Bước 4 — Chứng chỉ hành nghề (CC)

## Khái niệm

CC là giấy phép hành nghề do UBCKNN cấp. Có 3 loại: MGCK (Môi giới CK), PTTC (Phân tích tài chính), QLQ (Quản lý quỹ).

1 NHN có thể sở hữu nhiều CC khác loại, nhưng chỉ 1 CC đang hoạt động cho mỗi loại. CC có vòng đời 4 trạng thái: **Chưa sử dụng → Đang sử dụng → Thu hồi / Hủy**.

CC là **output của hồ sơ** (Bước 2) và là **điều kiện của công tác** (Bước 5). CC bị thu hồi thường do vi phạm (Bước 6).

## Quan hệ với các bước khác

- ← **Bước 2 (Hồ sơ):** Mỗi CC sinh ra từ 1 hồ sơ (relation qua `DvcHoSo.DvcSoChungChiId`)
- → **Bước 2 (Hồ sơ cấp lại):** CC thu hồi là input của hồ sơ cấp lại (relation qua `DvcHoSo.DvcSoChungChiCuId`)
- ← **Bước 1 (NHN):** 1 NHN có N CC (qua `DvcSoChungChi.DvcNguoiHanhNgheId`)
- → **Bước 5 (Công tác):** CC Đang SD là điều kiện cho công tác (không có FK trực tiếp)

## Checklist câu hỏi nghiệp vụ

- [ ] Tổng số CC đã cấp? So với tổng hồ sơ — tỷ lệ duyệt?
- [ ] Phân bố theo loại CC (MGCK / PTTC / QLQ)?
- [ ] Phân bố theo trạng thái (Chưa SD / Đang SD / Thu hồi / Hủy)?
- [ ] **1 NHN sở hữu bao nhiêu CC?** — phân bố 1, 2, 3 CC
- [ ] **Có NHN nào có ≥2 CC cùng loại?** — nếu có, mâu thuẫn business rule "1 loại - 1 CC active"
- [ ] CC "Thu hồi" có luôn gắn với Quyết định thu hồi (`DmQuyetDinhThuHoiId`)?
- [ ] CC cấp trước năm nào thường không có `DmQuyetDinhCapId`? (thời điểm hệ thống bắt đầu lưu QĐ)
- [ ] `ChoPhepCapLai` flag có phân bố thế nào? Liên quan trạng thái CC?
- [ ] **Thời gian TB từ hồ sơ → cấp CC là bao lâu?**

## Câu lệnh gợi ý

```sql
-- Q1. Tổng CC, tỷ lệ duyệt
SELECT
    (SELECT COUNT(*) FROM DvcSoChungChi) AS tong_cc,
    (SELECT COUNT(*) FROM DvcHoSo) AS tong_ho_so,
    CAST((SELECT COUNT(*) FROM DvcSoChungChi) * 100.0 /
        NULLIF((SELECT COUNT(*) FROM DvcHoSo), 0) AS DECIMAL(5,2)) AS ty_le_duyet_pct;

-- Q2. Phân bố loại CC
SELECT DmChungChiId, COUNT(*) AS cnt,
       CAST(ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS DECIMAL(5,2)) AS pct
FROM DvcSoChungChi GROUP BY DmChungChiId;

-- Q3. Phân bố trạng thái
SELECT TrangThai, COUNT(*) AS cnt,
       CAST(ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS DECIMAL(5,2)) AS pct
FROM DvcSoChungChi GROUP BY TrangThai ORDER BY cnt DESC;

-- Q4. 1 NHN có bao nhiêu CC
SELECT so_cc, COUNT(*) AS so_nhn
FROM (
    SELECT DvcNguoiHanhNgheId, COUNT(*) AS so_cc
    FROM DvcSoChungChi
    GROUP BY DvcNguoiHanhNgheId
) x
GROUP BY so_cc
ORDER BY so_cc;

-- Q5. NHN có ≥2 CC cùng loại
SELECT DvcNguoiHanhNgheId, DmChungChiId, COUNT(*) AS so_cc
FROM DvcSoChungChi
GROUP BY DvcNguoiHanhNgheId, DmChungChiId
HAVING COUNT(*) >= 2
ORDER BY so_cc DESC;

-- Q6. CC Thu hồi có QĐ không?
-- (TrangThai = 2 là Thu hồi — cần confirm)
SELECT
    TrangThai,
    SUM(CASE WHEN DmQuyetDinhThuHoiId IS NOT NULL THEN 1 ELSE 0 END) AS co_qd_thu_hoi,
    SUM(CASE WHEN DmQuyetDinhThuHoiId IS NULL THEN 1 ELSE 0 END) AS khong_qd,
    SUM(CASE WHEN NgayThuHoi IS NOT NULL THEN 1 ELSE 0 END) AS co_ngay_thu_hoi
FROM DvcSoChungChi
GROUP BY TrangThai;

-- Q7. CC cấp không có QĐ theo năm
SELECT YEAR(NgayCap) AS nam,
       COUNT(*) AS tong,
       SUM(CASE WHEN DmQuyetDinhCapId IS NULL THEN 1 ELSE 0 END) AS khong_qd_cap,
       CAST(SUM(CASE WHEN DmQuyetDinhCapId IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS khong_qd_pct
FROM DvcSoChungChi
WHERE NgayCap IS NOT NULL
GROUP BY YEAR(NgayCap)
ORDER BY nam;

-- Q8. ChoPhepCapLai
SELECT ChoPhepCapLai, TrangThai, COUNT(*) AS cnt
FROM DvcSoChungChi
GROUP BY ChoPhepCapLai, TrangThai
ORDER BY TrangThai, ChoPhepCapLai;

-- Q9. Thời gian hồ sơ → cấp CC
SELECT
    AVG(DATEDIFF(DAY, h.NgayNop, cc.NgayCap)) AS avg_ngay,
    MIN(DATEDIFF(DAY, h.NgayNop, cc.NgayCap)) AS min_ngay,
    MAX(DATEDIFF(DAY, h.NgayNop, cc.NgayCap)) AS max_ngay
FROM DvcHoSo h
JOIN DvcSoChungChi cc ON h.DvcSoChungChiId = cc.Id
WHERE h.NgayNop IS NOT NULL AND cc.NgayCap IS NOT NULL;
```

## Diễn giải & gợi ý kết luận

**Kết quả thực tế đã khảo sát:**
- **16,467 CC đã cấp** / 16,842 hồ sơ → tỷ lệ duyệt gần 100% (hoặc có hồ sơ chưa xử lý xong)
- Phân bố trạng thái CC: `1` Đang SD 94.7%, `3` Hủy 2.5%, `2` Thu hồi 1.4%, `0` Chưa SD 0.2%
- **Tổng CC > NHN có tổ chức** (16,467 vs ~9,780 NHN có tổ chức): có nhiều NHN có CC nhưng không gắn tổ chức — confirm với kết quả Bước 1 (34% NHN không tổ chức)

**Câu hỏi nghiệp vụ cần xác nhận với BA:**

1. **Enum `TrangThai` CC** — 4 giá trị (0, 1, 2, 3):
   - `0` = Chưa sử dụng
   - `1` = Đang sử dụng
   - `2` = Thu hồi
   - `3` = Hủy
   - Phân biệt "Thu hồi" vs "Hủy" là gì? Thu hồi = kỷ luật, Hủy = nghiệp vụ khác?

    TL:
    - `0`: Không hành nghề chứng khoán trong 3 năm liên tục, Bị mất CCHNCK, sai chứng chỉ, Vi phạm điểm b khoản 2 Điều 98 Luật Chứng khoán số 54/2019/QH14 được sửa đổi, bổ sung bởi Luật số 56/2024/QH15, Về việc thu hồi Chứng chỉ hành nghề Môi giới chứng khoán của ông Huỳnh Minh Mẫn, Đồng thời làm việc cho công ty chứng khoán và công ty quản lý quỹ, Vi phạm điểm b khoản 2 Điều 98 Luật Chứng khoán số 54/2019/QH14 được sửa đổi, bổ sung bởi Luật số 56/2024/QH15.
    - `1`: Dữ liệu null
    - `2`: Dữ liệu null 99% và 1 bản ghi "V/v hủy bỏ chứng chỉ hành nghề chứng khoán của Vụ Quản lý kinh doanh chứng khoán - UBCKNN ban hành - do Phó chủ tịch Phạm Văn Hoàng ký"
    - `3`: V/v hủy bỏ chứng chỉ hành nghề chứng khoán của Vụ Quản lý kinh doanh chứng khoán - UBCKNN ban hành - do Phó chủ tịch Phạm Văn Hoàng ký; Hủy bỏ chứng chỉ hành nghề chứng khoán theo Quyết định số 268/QĐ-UBCK ngày 10/04/2018 của Chủ tịch UBCKNN; Theo Quyết định số 268/QĐ-UBCK; Theo Quyết định số 268/QĐ-UBCK; Không nộp lệ phí cấp trong thời hạn quy định

2. **CC "Chưa sử dụng" chỉ 0.2%** — có phải CC được cấp xong là ngay lập tức chuyển sang "Đang SD"? Vậy trạng thái "Chưa sử dụng" có còn ý nghĩa hay là dead state?

    TL: Không có trường nào phản ảnh việc CC có sử dụng hay không, chỉ có thông tin hiệu lực của CC

3. **CC "Đang SD" chiếm 94.7%** — nghĩa là gần như toàn bộ NHN đã được cấp CC đều đang active. Nhưng Bước 1 cho thấy 34% NHN không gắn tổ chức → **có thể CC "Đang SD" không đồng nghĩa "đang hành nghề"**. Clarify: trạng thái CC phụ thuộc vào gì (cấp phép pháp lý) vs trạng thái công tác (thực tế làm việc)?

4. **Bao nhiêu NHN có ≥2 CC khác loại?** Kết quả Q4 sẽ cho biết pattern phổ biến — 1 NHN có thường có cả 3 loại CC hay chỉ 1 loại?

5. **CC cấp trước khi hệ thống lưu QĐ** — CC cũ nhất cấp từ năm nào? Có CC nào không gắn `DmQuyetDinhCapId` do migrate từ hệ thống cũ?

    TL: CC luôn được gắn với DmQuyetDinhCapId

6. **`ChoPhepCapLai` flag** — khi nào bật, khi nào tắt? Có phải phụ thuộc trạng thái CC (Thu hồi do vi phạm thì không cho cấp lại)?

    TL: Flag luôn bằng 1
---

# Bước 5 — Công tác

## Khái niệm

Công tác là lịch sử làm việc của NHN tại các tổ chức sử dụng NHNCK (CTCK, QLQ, Ngân hàng). Có 2 nguồn dữ liệu:
- **NHN khai báo (`DvcNguoiHanhNghe_CongTac`):** khai khi nộp hồ sơ hoặc cập nhật
- **Tổ chức báo cáo (`DvcToChuc_BaoCao`):** báo cáo định kỳ hàng tháng hoặc biến động

Business rule: NHN có CC Đang SD + có HĐLĐ với tổ chức sử dụng NHNCK → "Đang hành nghề". Chấm dứt HĐLĐ → "Chưa hành nghề".

## Quan hệ với các bước khác

- ← **Bước 1 (NHN):** Công tác của NHN (qua `DvcNguoiHanhNgheId`)
- ← **Bước 4 (CC):** Công tác yêu cầu NHN có CC Đang SD (không FK trực tiếp, business rule)
- → **Bước 6 (Vi phạm):** Vi phạm xảy ra trong quá trình công tác

## Checklist câu hỏi nghiệp vụ

- [ ] Tổng số giai đoạn công tác (`DvcNguoiHanhNghe_CongTac`)? Tổng báo cáo (`DvcToChuc_BaoCao`)?
- [ ] **1 NHN có bao nhiêu giai đoạn công tác?** — phân bố
- [ ] Phân bố theo tổ chức — top 10 tổ chức có nhiều NHN
- [ ] **Có NHN nào làm 2 tổ chức cùng lúc** (overlap `TuNgay`-`DenNgay`)?
- [ ] `DenNgay IS NULL` — bao nhiêu % "đang làm"? So sánh với CC "Đang SD"
- [ ] Phân bố `Loai` báo cáo (Định kỳ / Biến động)?
- [ ] Avg số báo cáo / (NHN + tổ chức) per tháng?
- [ ] **Khoảng thời gian TB 1 giai đoạn công tác?**
- [ ] NHN có CC Đang SD nhưng không có công tác active nào?

## Câu lệnh gợi ý

```sql
-- Q1. Tổng giai đoạn công tác, báo cáo
SELECT
    (SELECT COUNT(*) FROM DvcNguoiHanhNghe_CongTac) AS tong_cong_tac,
    (SELECT COUNT(*) FROM DvcToChuc_BaoCao) AS tong_bao_cao;

-- Q2. 1 NHN có bao nhiêu giai đoạn công tác
SELECT so_giai_doan, COUNT(*) AS so_nhn
FROM (
    SELECT DvcNguoiHanhNgheId, COUNT(*) AS so_giai_doan
    FROM DvcNguoiHanhNghe_CongTac
    GROUP BY DvcNguoiHanhNgheId
) x
GROUP BY so_giai_doan
ORDER BY so_giai_doan;

-- Q3. Top tổ chức
SELECT TOP 10 DmToChucId, COUNT(*) AS so_cong_tac,
              COUNT(DISTINCT DvcNguoiHanhNgheId) AS so_nhn
FROM DvcNguoiHanhNghe_CongTac
GROUP BY DmToChucId
ORDER BY so_cong_tac DESC;

-- Q4. Overlap — NHN làm 2 tổ chức cùng lúc
SELECT a.DvcNguoiHanhNgheId, COUNT(*) AS so_cap_overlap
FROM DvcNguoiHanhNghe_CongTac a
JOIN DvcNguoiHanhNghe_CongTac b
    ON a.DvcNguoiHanhNgheId = b.DvcNguoiHanhNgheId
   AND a.Id < b.Id
   AND a.TuNgay < ISNULL(b.DenNgay, '9999-12-31')
   AND ISNULL(a.DenNgay, '9999-12-31') > b.TuNgay
GROUP BY a.DvcNguoiHanhNgheId
ORDER BY so_cap_overlap DESC;

-- Q5. DenNgay NULL
SELECT
    SUM(CASE WHEN DenNgay IS NULL THEN 1 ELSE 0 END) AS dang_lam,
    SUM(CASE WHEN DenNgay IS NOT NULL THEN 1 ELSE 0 END) AS da_ket_thuc,
    CAST(SUM(CASE WHEN DenNgay IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS dang_lam_pct
FROM DvcNguoiHanhNghe_CongTac;

-- Q6. Loai báo cáo
SELECT Loai, COUNT(*) AS cnt,
       CAST(ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS DECIMAL(5,2)) AS pct
FROM DvcToChuc_BaoCao GROUP BY Loai;

-- Q7. Báo cáo theo tháng/năm
SELECT YEAR(NgayBaoCao) AS nam, MONTH(NgayBaoCao) AS thang, COUNT(*) AS cnt
FROM DvcToChuc_BaoCao
WHERE NgayBaoCao IS NOT NULL
GROUP BY YEAR(NgayBaoCao), MONTH(NgayBaoCao)
ORDER BY nam DESC, thang DESC;

-- Q8. Thời gian TB giai đoạn công tác (đã kết thúc)
SELECT
    AVG(DATEDIFF(DAY, TuNgay, DenNgay)) AS avg_ngay,
    AVG(DATEDIFF(DAY, TuNgay, DenNgay)) / 365.0 AS avg_nam
FROM DvcNguoiHanhNghe_CongTac
WHERE DenNgay IS NOT NULL AND TuNgay IS NOT NULL;

-- Q9. NHN có CC Đang SD nhưng không có công tác active
SELECT COUNT(DISTINCT cc.DvcNguoiHanhNgheId) AS so_nhn_co_cc_khong_cong_tac
FROM DvcSoChungChi cc
WHERE cc.TrangThai = 1 /* Đang SD */
  AND NOT EXISTS (
      SELECT 1 FROM DvcNguoiHanhNghe_CongTac ct
      WHERE ct.DvcNguoiHanhNgheId = cc.DvcNguoiHanhNgheId
        AND ct.DenNgay IS NULL
  );
```

## Diễn giải & gợi ý kết luận

**Kết quả thực tế đã khảo sát:**
- **9,508 giai đoạn công tác**, **33,281 báo cáo tổ chức**
- **`TuNgay` max = 2918-02-01** → dữ liệu lỗi nhập
- `DenNgay NULL: 81.86%` → hầu hết giai đoạn công tác được nhập với `DenNgay` bỏ trống
- `DmChucVuId NULL 100%` — cột FK không dùng, thay bằng `ChucVu` text
- `Loai` báo cáo 4 giá trị: `2` (44.36%), `1` (37.04%), `0` (14.76%), `3` (3.83%)
- **17 NHN có overlap period** (1 người max 10 cặp overlap)
- **16 case `NgayThoiViec < NgayTiepNhan`** trong báo cáo — vi phạm logic

**Câu hỏi nghiệp vụ cần xác nhận với BA:**

1. **`DenNgay NULL 81.86%`** — con số rất cao, khó giải thích:
   - Nghĩa là "đang làm" (81% NHN đang active)? 
   - Hay là "không rõ / chưa cập nhật" (NHN đã nghỉ nhưng chưa ghi nhận)?
   - Cần so sánh với CC Đang SD 94.7%: nếu `DenNgay NULL` = đang làm, tại sao chỉ 82% trong khi CC Đang SD là 95%?

   TL:
   - DenNgay Null, TuNgay Not Null: vẫn đang công tác tại đơn vị đó
   - DenNgay Null, TuNgay Null: BA không rõ là do dữ liệu lỗi hay là hệ thống cũ chưa cập nhật

2. **Lỗi dữ liệu `TuNgay = 2918`** — rule scrub khi migrate?

    TL: Dữ liệu lỗi, khả năng là 2018

3. **`DmChucVuId` NULL 100%** — cột FK chết, thay bằng text `ChucVu` không chuẩn hóa. Danh mục `DmChucVu` có còn dùng không? Rule chuẩn hóa text này thành FK?

    TL: Dữ liệu lỗi

4. **Enum `Loai` báo cáo** 4 giá trị — 2 loại nghiệp vụ chính là "Định kỳ" và "Biến động", còn 2 giá trị khác là gì?
   - `0`, `1`, `2`, `3` tương ứng nghiệp vụ nào?

   TL: DB không có bảng danh mục loại báo cáo

5. **Overlap period 17 NHN** — có cho phép 1 NHN làm 2 tổ chức song song?
   - Nếu có: rule nghiệp vụ?
   - Nếu không: đây là data error cần dedup

   TL: Tại 1 thời điểm 1 NHN không thể làm 2 tổ chức

6. **Mâu thuẫn `NgayThoiViec < NgayTiepNhan`** (16 case) — rule xử lý khi migrate (scrub hay giữ nguyên)?

    TL: Dữ liệu lỗi

7. **NHN có CC Đang SD nhưng không có công tác active** (Q9) — rất có khả năng tồn tại (vì 34% NHN không gắn tổ chức, xem Bước 1). Nghĩa là CC có thể "Đang SD" về mặt pháp lý nhưng NHN không hành nghề thực tế. Nghiệp vụ xử lý case này thế nào — có nên auto-suspend CC?

    TL: Không nên auto-suspend vì dữ liệu chưa đáng tin cậy
---

# Bước 6 — Vi phạm & Kỷ luật

## Khái niệm

Vi phạm là hành vi NHN vi phạm quy định pháp luật chứng khoán. Kết quả vi phạm có thể dẫn đến kỷ luật (cảnh cáo, thu hồi CC, đình chỉ). Thu hồi CC do vi phạm → NHN có thể nộp hồ sơ cấp lại sau thời hạn.

Có 2 bảng:
- **`DvcViPham`:** ghi nhận vụ vi phạm (thường gắn với quyết định xử phạt)
- **`DvcNguoiHanhNghe_KyLuat`:** ghi nhận kỷ luật của NHN (có thể là kết quả của vi phạm)

## Quan hệ với các bước khác

- ← **Bước 1 (NHN):** Vi phạm của NHN
- → **Bước 4 (CC thu hồi):** Vi phạm → thu hồi CC (qua `DmQuyetDinh`)
- → **Bước 2 (Hồ sơ cấp lại):** Sau thu hồi, NHN có thể nộp hồ sơ cấp lại

## Checklist câu hỏi nghiệp vụ

- [ ] Tổng vi phạm? Growth theo năm?
- [ ] **Tỷ lệ NHN đã từng vi phạm?** — số NHN có ≥1 record / tổng NHN
- [ ] Phân bố loại vi phạm?
- [ ] **1 NHN có tối đa bao nhiêu vi phạm?**
- [ ] Vi phạm có gắn với quyết định xử phạt (`DmQuyetDinh`) không?
- [ ] Quan hệ giữa vi phạm và CC thu hồi — tỷ lệ vi phạm dẫn đến thu hồi CC?
- [ ] Sau thu hồi, có bao nhiêu NHN nộp hồ sơ cấp lại?
- [ ] Khoảng thời gian TB từ thu hồi → cấp lại?

## Câu lệnh gợi ý

> ⚠️ Bước này chưa được khảo sát đợt trước. Query dưới là skeleton.

```sql
-- Q1. Tổng vi phạm
SELECT COUNT(*) AS tong_vi_pham FROM DvcViPham;
SELECT COUNT(*) AS tong_ky_luat FROM DvcNguoiHanhNghe_KyLuat;

-- Q2. Tỷ lệ NHN đã từng vi phạm
SELECT
    (SELECT COUNT(DISTINCT DvcNguoiHanhNgheId) FROM DvcViPham) AS nhn_co_vi_pham,
    (SELECT COUNT(*) FROM DvcNguoiHanhNghe) AS tong_nhn,
    CAST((SELECT COUNT(DISTINCT DvcNguoiHanhNgheId) FROM DvcViPham) * 100.0 /
        NULLIF((SELECT COUNT(*) FROM DvcNguoiHanhNghe), 0) AS DECIMAL(5,2)) AS ty_le_pct;

-- Q3. Growth vi phạm theo năm
-- (Cần biết cột ngày chính của DvcViPham — thường là NgayViPham hoặc NgayTao)
SELECT YEAR(NgayTao) AS nam, COUNT(*) AS cnt
FROM DvcViPham
WHERE NgayTao IS NOT NULL
GROUP BY YEAR(NgayTao) ORDER BY nam;

-- Q4. 1 NHN có bao nhiêu vi phạm
SELECT so_vi_pham, COUNT(*) AS so_nhn
FROM (
    SELECT DvcNguoiHanhNgheId, COUNT(*) AS so_vi_pham
    FROM DvcViPham
    GROUP BY DvcNguoiHanhNgheId
) x
GROUP BY so_vi_pham
ORDER BY so_vi_pham;

-- Q5. Vi phạm → CC thu hồi
-- (Join vi phạm với CC qua DvcNguoiHanhNgheId + time window)
SELECT
    (SELECT COUNT(*) FROM DvcSoChungChi WHERE TrangThai = 2 /* Thu hồi */) AS cc_thu_hoi,
    (SELECT COUNT(DISTINCT vp.DvcNguoiHanhNgheId)
     FROM DvcViPham vp
     WHERE EXISTS (
         SELECT 1 FROM DvcSoChungChi cc
         WHERE cc.DvcNguoiHanhNgheId = vp.DvcNguoiHanhNgheId
           AND cc.TrangThai = 2
     )) AS nhn_vi_pham_va_bi_thu_hoi;

-- Q6. Sau thu hồi, có hồ sơ cấp lại không?
SELECT
    cc.Id AS cc_thu_hoi_id,
    cc.NgayThuHoi,
    h.Id AS ho_so_cap_lai_id,
    h.NgayNop,
    DATEDIFF(DAY, cc.NgayThuHoi, h.NgayNop) AS so_ngay
FROM DvcSoChungChi cc
LEFT JOIN DvcHoSo h ON h.DvcSoChungChiCuId = cc.Id
WHERE cc.TrangThai = 2
ORDER BY cc.NgayThuHoi DESC;
```

## Diễn giải & gợi ý kết luận

**Trạng thái khảo sát:** Chưa khảo sát trong đợt này. Dựa vào dữ liệu đã biết từ các bước khác:
- CC bị thu hồi + hủy: 1.4% + 2.5% = 3.9% (tương đương ~640 CC)
- Tương ứng ~640 vi phạm → kỳ vọng tổng vi phạm khoảng vài trăm đến 1,000

**Câu hỏi nghiệp vụ cần khảo sát và xác nhận với BA:**

1. **Phân biệt `DvcViPham` và `DvcNguoiHanhNghe_KyLuat`:**
   - Vi phạm là sự kiện vi phạm pháp luật
   - Kỷ luật là hậu quả/chế tài áp dụng cho NHN
   - 1 vi phạm sinh ra 1 kỷ luật, hay có thể có quan hệ N:N?
   - Có FK trực tiếp giữa 2 bảng không?

   TL:
   - Chỉ có 1 bản ghi vi phạm sinh ra kỷ luật
   - Join qua trường DvcNguoiHanhNgheId

2. **Kỷ luật trong bảng `DvcNguoiHanhNghe_CongTac`** (cột `KyLuat` text) **vs** bảng `DvcNguoiHanhNghe_KyLuat` — 2 nguồn khác nhau cho cùng concept? Source of truth là gì?

    TL: DvcNguoiHanhNghe_CongTac.KyLuat chỉ có giá trị "Null" và "Không". Bảng DvcNguoiHanhNghe_KyLuat chi tiết hơn

3. **Mối liên hệ vi phạm ↔ CC thu hồi:**
   - Có phải tất cả CC thu hồi đều do vi phạm?
   - Có CC thu hồi do lý do khác (tự nguyện, hết hạn, v.v.)?
   - `DvcSoChungChi.LyDoThuHoi` chứa lý do — có thể categorize?

   TL:
   - Không phải, có trường hợp CC thu hồi do không hành nghề 3 năm liên tục
   - Hiện tại data chỉ có thu hồi do nằm trong danh sách người vi phạm
   - Dữ liệu free-text

4. **Vi phạm lặp lại:** Có NHN vi phạm nhiều lần không? Rule áp dụng kỷ luật khi tái phạm?

    TL: Dữ liệu chưa có NHN nào tái vi phạm

5. **Trường `DvcHoSo.ViPham` flag** (ở Bước 2, chỉ 1 case) — có ý nghĩa gì? Có thể cần loại bỏ nếu đã có bảng vi phạm riêng.

    TL: Không có bảng danh mục định nghĩa
---

# Phân tích xuyên vòng đời

## Cardinality thực tế giữa các bước

Sau khi khảo sát, tổng hợp lại cardinality thực tế quan sát được:

| Quan hệ | Cardinality kỳ vọng | Cardinality thực tế | Ghi chú |
|---|---|---|---|
| NHN → Hồ sơ | 1 : N | 14,879 NHN : 16,842 hồ sơ → avg 1.13 hồ sơ/NHN | Hồ sơ/NHN rất gần 1:1 |
| NHN → CC | 1 : N | 14,879 NHN : 16,467 CC → avg 1.11 CC/NHN | Hầu hết NHN có 1 CC |
| NHN → Kết quả thi | 1 : N | Không link được (NULL 100%) | **Không khảo sát được** |
| NHN → Công tác | 1 : N | 14,879 NHN : 9,508 giai đoạn → avg 0.64 | Không phải mọi NHN đều có công tác |
| NHN → Báo cáo tổ chức | 1 : N | 14,879 NHN : 33,281 báo cáo → avg 2.24 | Báo cáo định kỳ |
| Hồ sơ → CC | 1 : 0..1 | 16,842 hồ sơ : 16,467 CC → 375 hồ sơ không cấp CC | Tỷ lệ từ chối ~2.2% |

## Mâu thuẫn và bất thường cần làm rõ với BA

1. **Kết quả thi không link với NHN master** (`DvcNguoiHanhNgheId` NULL 100%) — không thể trả lời câu hỏi "NHN đã thi bao nhiêu lần mới đạt". Cần làm rõ kiến trúc hiện tại.

2. **34% NHN không gắn tổ chức** nhưng **94.7% CC trạng thái "Đang SD"** — 2 số liệu mâu thuẫn nếu giả định CC Đang SD = đang hành nghề. Cần BA làm rõ trạng thái CC vs trạng thái công tác.

3. **Hồ sơ cấp mới chiếm 98.3%** — cấp lại chỉ 1.7% trong 12 năm. Không phù hợp nghiệp vụ thông thường (CC có thời hạn, mất mát, v.v.). Có thể cấp lại được xử lý ngoài hệ thống?

4. **`DenNgay NULL 81.86%`** trong công tác — nghiệp vụ "đang làm" hay "không rõ"?

5. **Enum không khớp tài liệu:**
   - `LoaiHoSo` có 3 giá trị thực tế nhưng nghiệp vụ có ≥5 loại
   - `LoaiQuanHe` có enum thực tế 0,2,3,4,5,6,7,8,9 (thiếu 1) — khác tài liệu (1-6)
   - `Loai` báo cáo có 4 giá trị — nghiệp vụ thường chỉ 2 (Định kỳ, Biến động)

6. **Cột FK không dùng:**
   - `DmChucVuId` NULL 100% — chết, chỉ dùng text `ChucVu`
   - `LoaiDangKy` = 0 cho 100% — cột chết

## Checklist tổng hợp câu hỏi cho BA

### Dữ liệu lỗi
1. `TuNgay = 2918`, `NamSinh = 2079`, `NgayNop = 2026-12-11` (tương lai) → rule scrub?
2. 16 case `NgayThoiViec < NgayTiepNhan` → giữ hay scrub?

### Enum mapping
3. `LoaiHoSo`: 0, 1, 2 tương ứng loại nào? (nghiệp vụ có ≥5 loại)
4. `DmTrangThaiId`: 9 giá trị khác nhau — mapping đầy đủ?
5. `LoaiQuanHe`: 0, 7, 8, 9 ngoài tài liệu (1-6) nghĩa là gì?
6. `Loai` báo cáo: 0, 1, 2, 3 tương ứng nghiệp vụ nào?
7. `DmChungChi`: 1, 2, 3 tương ứng QLQ/MGCK/PTTC theo thứ tự nào?
8. `KetQuaLuat`/`KetQuaChuyenMon` dùng text "Đạt"/"Không đạt", `KetQua` dùng INT — thống nhất thế nào?

### Quan hệ nghiệp vụ
9. NHN không gắn tổ chức (34%) — trạng thái nghiệp vụ là gì?
10. NHN có CC Đang SD nhưng không có công tác active — xử lý?
11. `DenNgay NULL` = đang làm hay không rõ?
12. NHN làm 2 tổ chức cùng lúc — có cho phép không?

### Luồng nghiệp vụ
13. Kết quả thi không link với NHN master — rule backfill?
14. Hồ sơ cấp lại có luôn gắn CC cũ không?
15. Hồ sơ đã cấp có luôn gắn CC mới không?
16. Tại sao hồ sơ cấp lại chỉ 1.7% — cấp lại có được xử lý ngoài hệ thống?

### Cờ/thuộc tính không rõ
17. `ViPham` flag trong hồ sơ (chỉ 1 case) — còn dùng không?
18. `KhaiThac` flag — ý nghĩa?
19. `CapLaiHSM` — ý nghĩa?
20. `LoaiDangKy` = 0 cho 100% — cột chết?
21. `DmChucVuId` NULL 100% — cột chết?
22. `ChoPhepCapLai` trên CC — khi nào bật/tắt?

### Vi phạm & kỷ luật
23. `DvcViPham` vs `DvcNguoiHanhNghe_KyLuat` — quan hệ?
24. `KyLuat` text trong công tác vs bảng `DvcNguoiHanhNghe_KyLuat` — source of truth?
25. Vi phạm ↔ CC thu hồi — categorize lý do thu hồi?

---

# Phụ lục

## A. Bảng không khảo sát trong tài liệu này

| Bảng | Lý do |
|---|---|
| `DvcNguoiHanhNghe_LichSu` | Snapshot full, không có quan hệ nghiệp vụ mới |
| `DvcHoSo_NguoiHanhNghe` | Snapshot hồ sơ-cá nhân, đã có qua FK |
| `DvcHoSo_TaiLieu_LichSu`, `DvcHoSo_BoSung`, `DvcHoSo_QuyetDinh` | Bảng phụ, không mang concept nghiệp vụ riêng |
| `DvcThuTuc`, `DvcBieuMau`, `DvcVanBan` | Content management, không thuộc vòng đời NHN |
| Các bảng danh mục `Dm*` | Reference data, FK đến chúng không mang ý nghĩa nghiệp vụ |

## B. Glossary

| Viết tắt | Đầy đủ |
|---|---|
| UBCKNN | Ủy ban Chứng khoán Nhà nước |
| NHN / NHNCK | Người hành nghề chứng khoán |
| CC / CCHN | Chứng chỉ hành nghề |
| CTCK | Công ty Chứng khoán |
| QLQ | Công ty Quản lý Quỹ |
| MGCK | Môi giới chứng khoán |
| PTTC | Phân tích tài chính |
| HĐLĐ | Hợp đồng lao động |
| QĐ | Quyết định |
| MCĐT | Một cửa điện tử |
| BPMC | Bộ phận Một cửa |
| LĐCM | Lãnh đạo chuyên môn |
| LĐUB | Lãnh đạo Ủy ban |

## C. Checklist tổng hợp

### Đã khảo sát
- [x] Bước 1 — NHN: tổng số, phân bố, trạng thái cơ bản
- [x] Bước 2 — Hồ sơ: tổng số, phân bố loại, trạng thái, tỷ lệ duyệt
- [x] Bước 3 — Thi: tổng, tỷ lệ pass, phát hiện `DvcNguoiHanhNgheId` NULL 100%
- [x] Bước 4 — CC: tổng, trạng thái, quan hệ với hồ sơ
- [x] Bước 5 — Công tác: tổng, `DenNgay` NULL, overlap

### Cần khảo sát bổ sung
- [ ] Bước 2 Q5: 1 NHN có bao nhiêu hồ sơ (phân bố)
- [ ] Bước 2 Q8: Thời gian xử lý hồ sơ → cấp CC
- [ ] Bước 3 Q9: Số lần thi để 1 NHN đạt
- [ ] Bước 4 Q4: 1 NHN có bao nhiêu CC (phân bố)
- [ ] Bước 4 Q5: NHN có ≥2 CC cùng loại
- [ ] Bước 4 Q9: Thời gian hồ sơ → cấp CC
- [ ] Bước 5 Q9: NHN có CC Đang SD không có công tác
- [ ] Bước 6 (toàn bộ): Vi phạm & kỷ luật

### Cần làm rõ với BA (25 câu hỏi trong phần "Checklist tổng hợp câu hỏi")

## D. Lịch sử cập nhật

| Ngày | Nội dung |
|---|---|
| 2026-04-21 | Viết lại theo cấu trúc vòng đời NHN, focus quan hệ nghiệp vụ |
