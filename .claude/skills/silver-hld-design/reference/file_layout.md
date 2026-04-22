# File Layout — HLD outputs

## File HLD do người thiết kế tạo

| File | Vai trò |
|---|---|
| `Silver/hld/{SOURCE}_HLD_Tier{N}.md` | Detail design cho 1 Tier — chứa mục 6a–6f |
| `Silver/hld/{SOURCE}_HLD_Overview.md` | Tổng hợp toàn bộ Tier — chứa mục 7a–7f |

## File auto-generated bởi script

| File | Sinh bởi | Source-of-truth |
|---|---|---|
| `Silver/hld/silver_entities.csv` | `aggregate_silver.py` | manifest.csv + attr_*.csv + silver_entities.csv (description preserve) |
| `Silver/hld/silver_out_of_scope.csv` | `aggregate_out_of_scope.py` | Mục 7f của tất cả `{SOURCE}_HLD_Overview.md` |

## File config / metadata (Silver/lld/)

| File | Vai trò | Encoding |
|---|---|---|
| `Silver/lld/manifest.csv` | Mapping source_table → silver_entity → lld_file | UTF-8 with BOM |
| `Silver/lld/ref_shared_entity_classifications.csv` | Danh mục Classification Value scheme toàn dự án | UTF-8 with BOM |
| `Silver/lld/pending_design.csv` | Cột nguồn chưa map / pending decision | UTF-8 with BOM |

## Encoding chuẩn

Mọi file CSV trong dự án dùng **UTF-8 with BOM** (`utf-8-sig` trong Python). Lý do: Excel/Windows tool nhận diện đúng tiếng Việt khi mở trực tiếp; script Python đọc với `utf-8-sig` strip BOM tự động.

| File | Encoding |
|---|---|
| `silver_entities.csv` | UTF-8 with BOM |
| `silver_out_of_scope.csv` | UTF-8 with BOM |
| `manifest.csv` (LLD) | UTF-8 with BOM |
| `ref_shared_entity_classifications.csv` | UTF-8 with BOM |
| `pending_design.csv` | UTF-8 with BOM |
| `attr_*.csv` (LLD) | UTF-8 with BOM |

Sau Write/Edit nếu cần kiểm tra/strip BOM dư thừa, dùng:

```bash
python Silver/lld/scripts/strip_bom.py {path}
```
