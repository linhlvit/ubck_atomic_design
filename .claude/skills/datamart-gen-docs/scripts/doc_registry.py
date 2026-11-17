"""Registry dùng chung của skill datamart-gen-docs — NGUỒN SỰ THẬT DUY NHẤT cho:

  • bản mẫu (template) hiện hành của 2 quyển PTTK / TKCSLD,
  • danh sách + thứ tự + tên 11 phân hệ Datamart theo template v1.2,
  • 5 tầng luồng ETL của PTTK mục 3.1 và tên schema (dtm / dwh_prod).

Mọi script khác trong skill (build_docx.py, update_q5_with_datamart_modules.py, merge_md.py,
render_datamart_md.py, pttk_facts.py) import từ đây — KHÔNG khai lại danh sách module hay đường dẫn
template ở script riêng. Khi đổi bản mẫu: chép file .docx vào docs/templates/sample/ rồi sửa
TEMPLATE_CANDIDATES bên dưới (bản mới đứng đầu), không sửa ở nơi khác.

Bản mẫu hiện hành (2026-11-17, bản Viettel review v1.2 — có kèm comment review của LaMT và
'Viettel Solution Review'; bảng đối chiếu comment → quy tắc skill ở SKILL.md mục "Comment review v1.2"):
  PTTK   : Viettel_Review_UBCKNN_Tai_lieu_phan_tich_thiet_ke_v1.2_202611114.docx
  TKCSLD : Viettel_Review_UBCKNN_Thiet_ke_co_so_du_lieu_v1.2_20261112_final.docx
File .docx bị .gitignore (không commit) — mỗi máy tự chép vào docs/templates/sample/.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[4]
SKILL_DIR = REPO_ROOT / ".claude" / "skills" / "datamart-gen-docs"
TEMPLATE_DIR = REPO_ROOT / "docs" / "templates" / "sample"
OUTPUT_DIR = REPO_ROOT / "docs" / "output" / "datamart"

# ---------------------------------------------------------------------------------------------
# 1. Bản mẫu — phần tử ĐẦU là bản hiện hành; các phần tử sau là fallback (bản cũ) khi máy chưa có bản mới
# ---------------------------------------------------------------------------------------------
PTTK_TEMPLATE_NAME = "Viettel_Review_UBCKNN_Tai_lieu_phan_tich_thiet_ke_v1.2_202611114.docx"
TKCSLD_TEMPLATE_NAME = "Viettel_Review_UBCKNN_Thiet_ke_co_so_du_lieu_v1.2_20261112_final.docx"

TEMPLATE_CANDIDATES: dict[str, list[Path]] = {
    "pttk": [
        TEMPLATE_DIR / PTTK_TEMPLATE_NAME,
        TEMPLATE_DIR / "UBCKNN_Q5_Tai_lieu_phan_tich_thiet_ke_v1.1_20260828.docx",
        SKILL_DIR / "UBCKNN_Q5_Tai lieu phan tich thiet ke_v1.0_20260429.docx",
        TEMPLATE_DIR / "UBCKNN_Q5_Tai lieu phan tich thiet ke_Template.docx",
    ],
    "tkcsld": [
        TEMPLATE_DIR / TKCSLD_TEMPLATE_NAME,
        SKILL_DIR / "reference" / "UBCKNN_Thiet ke co so du lieu_Template.docx",
        TEMPLATE_DIR / "UBCKNN_Thiet ke co so du lieu_Template.docx",
    ],
}


def current_template(doc_type: str) -> Path:
    """Đường dẫn bản mẫu HIỆN HÀNH (có thể chưa tồn tại trên máy)."""
    return TEMPLATE_CANDIDATES[doc_type.lower()][0]


def find_template(doc_type: str, custom: Path | None = None, warn: bool = True) -> Path | None:
    """Bản mẫu dùng được: `custom` nếu có, không thì bản đầu tiên tồn tại trong TEMPLATE_CANDIDATES.

    In cảnh báo ra stderr khi phải lùi về bản cũ — tài liệu sinh ra sẽ lệch style/cấu trúc bản v1.2.
    """
    import sys

    if custom is not None and Path(custom).exists():
        return Path(custom)
    cands = TEMPLATE_CANDIDATES[doc_type.lower()]
    for i, p in enumerate(cands):
        if p.exists():
            if i > 0 and warn:
                print(
                    f"[WARN] Chưa có bản mẫu hiện hành {cands[0].name} trong {TEMPLATE_DIR} — "
                    f"đang lùi về bản cũ {p.name}.",
                    file=sys.stderr,
                )
            return p
    return None


# ---------------------------------------------------------------------------------------------
# 2. 11 phân hệ Datamart — thứ tự = số mục 3.1.X của PTTK và thứ tự chương OLAP của TKCSLD (template v1.2)
# ---------------------------------------------------------------------------------------------
@dataclass(frozen=True)
class Module:
    code: str          # mã module trong repo (thư mục Datamart/lld/{code}, docs/output/datamart/{code})
    idx: int           # X của mục 3.1.X (PTTK)
    pttk_name: str     # phần đuôi tiêu đề PTTK: "3.1.X  Luồng đồng bộ dữ liệu cho nhóm báo cáo {pttk_name}"
    tkcsld_name: str   # phần đuôi tiêu đề TKCSLD: "3. KHO DỮ LIỆU (OLAP) — {tkcsld_name}"
    flat_prefix: str   # tiền tố bảng phẳng ClickHouse: dwh_prod.{flat_prefix}_*_flat


MODULES: list[Module] = [
    Module("TT", 1, "hoạt động thanh tra", "Hoạt động Thanh tra", "tt"),
    Module("NHNCK", 2, "người hành nghề chứng khoán", "Người hành nghề", "nhnck"),
    Module("NDTNN", 3, "nhà đầu tư nước ngoài", "Quản lý NĐTNN", "ndtnn"),
    Module("QLCB", 4, "quản lý chào bán", "Quản lý chào bán", "qlcb"),
    Module("GSDC", 5, "giám sát công ty đại chúng", "Giám sát Công ty Đại chúng", "gsdc"),
    Module("GSTT", 6, "giám sát thị trường", "Giám sát Thị trường", "gstt"),
    Module("QLQ", 7, "công ty quản lý quỹ (AMC)", "Công ty Quản lý Quỹ (AMC)", "qlq"),
    Module("QLKD", 8, "hoạt động công ty chứng khoán", "Hoạt động Công ty Chứng khoán", "qlkd"),
    Module("PTTT", 9, "phân tích thị trường", "Phân tích thị trường", "pttt"),
    Module("TKNB", 10, "thống kê thị trường", "Thống kê Thị trường", "tknb"),
    Module("VP", 11, "văn phòng", "Văn phòng", "vp"),
]
MODULE_BY_CODE: dict[str, Module] = {m.code: m for m in MODULES}
MODULE_ALIASES = {"FMS": "QLQ"}  # mã cũ → mã hiện hành


def get_module(code: str) -> Module:
    code = code.upper()
    code = MODULE_ALIASES.get(code, code)
    if code not in MODULE_BY_CODE:
        raise KeyError(
            f"Module '{code}' chưa có trong doc_registry.MODULES — thêm vào registry + reference/module_names_vi.md "
            "(hỏi Data Modeler số mục 3.1.X và tên tiếng Việt) trước khi sinh tài liệu."
        )
    return MODULE_BY_CODE[code]


def pttk_module_heading(mod: Module) -> str:
    """Tiêu đề Heading 3 của module trong PTTK — đúng dạng template v1.2 (chữ thường, 2 dấu cách sau số mục)."""
    return f"3.1.{mod.idx}  Luồng đồng bộ dữ liệu cho nhóm báo cáo {mod.pttk_name}"


# ---------------------------------------------------------------------------------------------
# 3. Luồng ETL 5 tầng của PTTK mục 3.1 (comment review #535, #536, #524–#534 trên template PTTK v1.2)
# ---------------------------------------------------------------------------------------------
SCHEMA_DATAMART = "dtm"        # Datamart Fact/Dim trên Lakehouse (Spark/Iceberg)
SCHEMA_CLICKHOUSE = "dwh_prod"  # bảng phẳng phục vụ khai thác trên ClickHouse: dwh_prod.{phân hệ}_*_flat

# tên subgraph mermaid, đúng thứ tự trái → phải
FLOW_TIERS: list[str] = ["Staging", "ODS", "Atomic", "Datamart", "ClickHouse"]

# (nhãn in trong tài liệu, tầng nguồn, tầng đích) — nhãn là dòng "*{nhãn}:*" trong Markdown PTTK
FLOW_STEPS: list[tuple[str, str, str]] = [
    ("Staging → ODS", "Staging", "ODS"),
    ("ODS → Atomic", "ODS", "Atomic"),
    ("Atomic → Datamart", "Atomic", "Datamart"),
    ("Datamart → ClickHouse", "Datamart", "ClickHouse"),
]
FLOW_STEP_LABELS: list[str] = [s[0] for s in FLOW_STEPS]
# Nhãn 3 tầng của bản tài liệu cũ (≤ v1.2): script ghép quyển vẫn ĐỌC được nhưng in cảnh báo cần nâng lên 5 tầng
LEGACY_FLOW_STEP_LABELS: list[str] = ["Staging → Atomic"]


# ODS là bản 1:1 của Staging (Data Modeler chốt 2026-11-17): mỗi bảng Staging có ĐÚNG 1 bảng ODS cùng cấu trúc,
# không gộp/tách bảng, không có bảng ODS nào thiếu bảng Staging tương ứng. Tài liệu không đặt tên vật lý riêng
# cho ODS — node ODS mang đúng tên bảng Staging, thêm tiền tố tầng.
def ods_label(staging_label: str) -> str:
    """Nhãn node ODS của bảng Staging 'SRC.TABLE' → 'ODS.SRC.TABLE'."""
    return f"ODS.{staging_label}"


def ods_node_id(staging_node_id: str) -> str:
    """ID node mermaid ODS của node Staging 'SRC_TABLE' → 'ODS_SRC_TABLE'."""
    return f"ODS_{staging_node_id}"

# 7 dòng của mục "3.1.X.1 Thông tin chung luồng đồng bộ" — (khóa trong etl_job_info.yaml, nhãn in trong tài liệu)
JOB_INFO_FIELDS: list[tuple[str, str]] = [
    ("ten_job", "Tên job"),
    ("nguon_du_lieu", "Nguồn dữ liệu (Hệ thống nguồn)"),
    ("cach_thuc_dong_bo", "Cách thức truy xuất đồng bộ dữ liệu"),
    ("tan_suat", "Tần suất đồng bộ dữ liệu"),
    ("dung_luong", "Dung lượng dữ liệu sẽ thực hiện đồng bộ"),
    ("thoi_gian_luu_tru", "Thời gian lưu trữ dữ liệu"),
    ("thu_muc_luu_tru", "Thư mục lưu trữ dữ liệu trên kho dữ liệu"),
]
JOB_INFO_PATH = SKILL_DIR / "reference" / "etl_job_info.yaml"

# Ranh giới mục 3.1 trong quyển PTTK: (tiêu đề mở, tiền tố tiêu đề đóng) — bản v1.2 trước, bản Q5 cũ sau
PTTK_SECTION_ANCHORS: list[tuple[str, str]] = [
    ("Nhóm chức năng ETL", "Nhóm chức năng tích hợp dữ liệu"),
    ("Phân hệ ETL", "Phân hệ tích hợp dữ liệu"),
]


if __name__ == "__main__":  # python doc_registry.py → in trạng thái bản mẫu + danh sách module
    import sys

    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")
    for t in ("pttk", "tkcsld"):
        cur = current_template(t)
        print(f"{t.upper():7s} bản mẫu hiện hành: {cur.name}  [{'CÓ' if cur.exists() else 'THIẾU — chép vào ' + str(TEMPLATE_DIR)}]")
    print(f"Luồng ETL: {' → '.join(FLOW_TIERS)}  (Datamart = schema {SCHEMA_DATAMART}, ClickHouse = schema {SCHEMA_CLICKHOUSE})")
    for m in MODULES:
        print(f"  3.1.{m.idx:<2d} {m.code:6s} PTTK: {m.pttk_name:34s} TKCSLD: {m.tkcsld_name}")
