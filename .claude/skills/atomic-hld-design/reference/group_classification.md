# Group chuẩn cho mục 7f. Bảng ngoài scope

Danh sách group dùng trong cột "Nhóm" của mục 7f HLD Overview. Group nhất quán toàn dự án.

| Group | Khi nào dùng |
|---|---|
| `Intermediate` | Bảng trung gian không có lifecycle độc lập |
| `Junction` | Pure junction table không có business attribute |
| `Cascade drop` | Drop theo bảng anchor đã loại |
| `Operational / System` | Hạ tầng IT, log, config, phân quyền |
| `Audit Log nguồn` | Bảng lịch sử kỹ thuật (history, OldValue/NewValue) |
| `Snapshot nguồn` | Bảng snapshot (IsBefore + blob) |
| `Reference Data` | Danh mục thuần (Code + Name) → Classification Value |
| `Form Metadata` | Metadata định nghĩa form/field |
| `Shared Entity` | Dùng shared entity từ source khác |
| `Isolated` | Không FK đến/từ bảng nghiệp vụ nào |
| `Hệ thống / Phân quyền` | IT infrastructure |
| `Chưa có cột` | Chưa có thông tin cột nguồn |
| `UI metadata` | Cấu hình hiển thị UI |

## Quy tắc bổ sung group mới

Group mới phải bổ sung vào file này trước khi dùng trong HLD Overview, để mọi source sau dùng nhất quán.

## Lý do chuẩn cho cột "Lý do ngoài scope"

| Tình huống | Lý do viết |
|---|---|
| Không FK đến/từ bất kỳ bảng nghiệp vụ nào | `Không có quan hệ FK đến bảng nghiệp vụ nào trong scope` |
| Bảng danh mục thuần túy (Code + Name) | `Không có FK inbound từ bảng nghiệp vụ — xử lý thành Classification Value` |
| Dữ liệu thu thập tại source gốc khác | `Dữ liệu gốc tại [SOURCE] — thu thập tại source gốc, không qua [hệ thống hiện tại]` |
| Hạ tầng IT / phân quyền / config | `Operational/system data — không có giá trị nghiệp vụ` |
| Audit Log nguồn (OldValue/NewValue) | `Audit Log nguồn — cơ chế ghi lịch sử đặc thù source system, không phải sự kiện nghiệp vụ` |
| Snapshot nguồn (IsBefore + blob) | `Snapshot nguồn — không phải entity nghiệp vụ Atomic` |
| Cascade từ bảng đã drop | `Cascade drop từ [anchor_table]` |
