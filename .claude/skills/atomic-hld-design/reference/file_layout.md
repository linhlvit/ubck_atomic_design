# File Layout — HLD outputs

## File HLD do người thiết kế tạo

| File | Vai trò |
|---|---|
| `DataModel/working/Atomic/hld/{SOURCE}_HLD_Tier{N}.md` | Detail design cho 1 Tier — chứa mục 6a–6f |
| `DataModel/working/Atomic/hld/{SOURCE}_HLD_Overview.md` | Tổng hợp toàn bộ Tier — chứa mục 7a–7f |

## File auto-generated bởi script

| File | Sinh bởi | Source-of-truth |
|---|---|---|
| `DataModel/working/Atomic/hld/atomic_entities.yaml` | `aggregate_atomic.py` | manifest.yaml + lld_*.yaml + atomic_entities.yaml (description preserve) |
| `DataModel/working/Atomic/hld/atomic_out_of_scope.yaml` | `aggregate_out_of_scope.py` | Mục 7f của tất cả `{SOURCE}_HLD_Overview.md` |

## File config / metadata (DataModel/working/Atomic/lld/)

| File | Vai trò | Encoding |
|---|---|---|
| `DataModel/working/Atomic/lld/manifest.yaml` | Mapping source_table → atomic_entity → lld_file | UTF-8 |
| `DataModel/working/Atomic/lld/classification_schemes.yaml` | Danh mục Classification Value scheme toàn dự án | UTF-8 |
| `DataModel/working/Atomic/lld/pending_design.yaml` | Cột nguồn chưa map / pending decision | UTF-8 |

## Encoding chuẩn

File YAML dùng **UTF-8** (không BOM). File CSV còn lại dùng **UTF-8 with BOM** (`utf-8-sig` trong Python).

| File | Encoding |
|---|---|
| `atomic_entities.yaml` | UTF-8 with BOM |
| `atomic_out_of_scope.yaml` | UTF-8 with BOM |
| `manifest.yaml` (LLD) | UTF-8 |
| `classification_schemes.yaml` | UTF-8 |
| `pending_design.yaml` | UTF-8 |
| `lld_*.yaml` (LLD per table) | UTF-8 |

Sau Write/Edit nếu cần kiểm tra/strip BOM dư thừa trên file CSV, dùng:

```bash
python DataModel/working/Atomic/lld/scripts/strip_bom.py {path}
```
