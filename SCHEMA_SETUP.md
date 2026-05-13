# Schema Setup Guide — BRD YAML Validation

## Tổng quan

Để đảm bảo các file YAML BRD được ghi và đọc nhất quán:
- **`schemas/brd_source.schema.json`** — định nghĩa cấu trúc BRD YAML
- **`schemas/registry.json`** — danh sách tất cả schema types hỗ trợ
- **VS Code settings** — cấu hình validation realtime

---

## 1. VS Code Setup — YAML Validation

### Cài đặt extension

1. Cài **YAML extension** (Red Hat) trong VS Code:
   - Mở VS Code → Extensions (`Ctrl+Shift+X`)
   - Tìm "YAML" → cài `YAML` của Red Hat
   - Tìm "JSON Schema Store" → cài `JSON Schema Store Catalog` (optional, hỗ trợ lookup schema)

2. **Hoặc dùng Prettier** + **YAML** nếu bạn dùng format code

### Cấu hình `.vscode/settings.json`

Tại gốc repo, tạo hoặc edit `.vscode/settings.json`:

```json
{
  "yaml.schemas": {
    "schemas/brd_source.schema.json": [
      "BRD/Source/brd_*.yaml"
    ]
  },
  "yaml.validate": true,
  "yaml.format.enable": true,
  "editor.formatOnSave": true,
  "[yaml]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode",
    "editor.formatOnSave": true
  }
}
```

**Giải thích:**
- `yaml.schemas`: map schema file → file pattern
  - Schema `brd_source.schema.json` sẽ validate tất cả file `BRD/Source/brd_*.yaml`
- `yaml.validate`: bật validation
- `editor.formatOnSave`: tự động format YAML khi save (tuỳ chọn)

### Kiểm tra cấu hình

1. Mở một file `BRD/Source/brd_ThanhTra.yaml`
2. Nếu cấu hình đúng, bạn sẽ thấy:
   - **Autocomplete** khi gõ field names (ví dụ: `scope_status`, `related_tables`)
   - **Error squiggly** (đường sóng đỏ) nếu giá trị không match schema (ví dụ: `scope_status: invalid_value`)
   - **Hover hints** giải thích mỗi field

### Ví dụ: Schema validation trong hành động

```yaml
brd_entries:
  - brd_id: BRD-SRC-ThanhTra-TT_KE_HOACH
    brd_name: "Design Atomic từ nguồn ThanhTra bảng TT_KE_HOACH"
    type: Theo Source
    ba_email: invalid-email      # ❌ VS Code báo lỗi: not a valid email
    steward_email: username@ubck.com.vn
    content:
      table_meaning: "Kế hoạch thanh tra"
      functional_group: "B.1 Hoạt động thanh tra"
      scope_status: invalid_scope # ❌ VS Code báo lỗi: must be 'in_scope' or 'out_of_scope'
      scope_reason: null
      related_tables: []
      notes: null
      data_volume_hint: null
      refresh_frequency: null
```

---

## 2. CLI Validation — Validate từ command line

Nếu bạn muốn validate tất cả file BRD YAML mà không cần VS Code:

### Cài đặt `ajv-cli` (AJV — JSON Schema validator)

```bash
npm install -g ajv-cli
```

### Validate một file

```bash
ajv validate -s schemas/brd_source.schema.json -d "BRD/Source/brd_ThanhTra.yaml" --data-type yaml
```

### Validate tất cả file BRD

```bash
for file in BRD/Source/brd_*.yaml; do
  echo "Validating $file..."
  ajv validate -s schemas/brd_source.schema.json -d "$file" --data-type yaml || echo "  ❌ Failed: $file"
done
```

---

## 3. Web App Integration

### Đọc Schema từ code

Web app của bạn có thể:

1. **Load registry** để xác định schema type:
   ```javascript
   const registry = require('./schemas/registry.json');
   const brdSchema = registry.schema_types.find(s => s.type === 'brd_source');
   ```

2. **Load schema file**:
   ```javascript
   const brdSourceSchema = require('./schemas/brd_source.schema.json');
   ```

3. **Validate YAML khi load** (dùng thư viện như `ajv`):
   ```javascript
   import Ajv from 'ajv';
   const ajv = new Ajv();
   const validate = ajv.compile(brdSourceSchema);
   const isValid = validate(yamlData);
   if (!isValid) console.log(validate.errors);
   ```

4. **Parse và render** các BRD entries

### Cấu trúc web app

```
web-app/
  ├── pages/
  │   ├── BRDViewer.tsx          # Hiển thị danh sách BRD, filter by source
  │   ├── BRDDetail.tsx           # Chi tiết một BRD entry
  │   └── BRDEditor.tsx           # Edit BRD YAML (with live validation)
  ├── hooks/
  │   ├── useBRDLoader.ts         # Load & parse BRD YAML
  │   └── useSchemaValidator.ts   # Validate dùng JSON Schema
  ├── utils/
  │   ├── yamlParser.ts           # Parse YAML ↔ JS object
  │   └── schemaLoader.ts         # Load schema từ registry
  └── components/
      ├── BRDTable.tsx            # Render danh sách BRD entry
      └── RelatedTablesGraph.tsx   # Vẽ graph quan hệ bảng
```

---

## 4. Thêm schema mới (khi cần)

Khi bạn tạo loại YAML mới (ví dụ: Data Model):

1. **Tạo schema file**: `schemas/data_model.schema.json`
2. **Thêm vào registry.json**:
   ```json
   {
     "type": "data_model",
     "label": "Data Model Design",
     "schema_file": "schemas/data_model.schema.json",
     "file_pattern": "DataModel/ldm_*.yaml"
   }
   ```
3. **Update `.vscode/settings.json`**:
   ```json
   "yaml.schemas": {
     "schemas/brd_source.schema.json": ["BRD/Source/brd_*.yaml"],
     "schemas/data_model.schema.json": ["DataModel/ldm_*.yaml"]
   }
   ```

---

## 5. Troubleshooting

| Vấn đề | Giải pháp |
|--------|----------|
| VS Code không validate YAML | Kiểm tra: extension Red Hat YAML cài chưa, settings.json đúng path, restart VS Code |
| Schema file không tìm thấy | Schema file phải ở đường dẫn relative từ workspace root (ví dụ: `schemas/brd_source.schema.json`) |
| Error "not a valid email" | Kiểm tra email format: phải có `@` và domain |
| Autocomplete không hoạt động | Bật `yaml.suggestParents` trong settings: `"yaml.suggestParents": true` |
| YAML file không được recognize | Kiểm tra file extension: phải là `.yaml` (không `.yml`) |

---

## 6. Best Practices

✅ **DO:**
- Dùng schema validation — nó giúp phát hiện lỗi sớm
- Cấu hình VS Code settings tập trung (`.vscode/settings.json`) để dễ share cho team
- Thêm `schema_type` vào header YAML file nếu muốn web app tự xác định loại file
- Comment các field phức tạp trong YAML file để giúp người khác hiểu

❌ **DON'T:**
- Bỏ schema validation khi viết YAML
- Dùng file `.yml` — chỉ dùng `.yaml` (tuân theo quy ước)
- Thay đổi schema mà không cập nhật registry
- Hack YAML bằng cách thêm field không khai báo trong schema

---

## References

- [JSON Schema Draft-07](https://json-schema.org/draft/2019-09/json-schema-validation.html)
- [Red Hat YAML Extension](https://github.com/redhat-developer/vscode-yaml)
- [AJV JSON Schema Validator](https://github.com/ajv-validator/ajv)
