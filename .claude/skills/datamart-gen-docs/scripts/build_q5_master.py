"""Script tạo và biên dịch 1 quyển tài liệu Phân tích Thiết kế (Q5) duy nhất
cho toàn bộ 10 phân hệ Datamart theo chuẩn template UBCKNN Q5.
"""

from __future__ import annotations

import os
import re
import shutil
import subprocess
import sys
from pathlib import Path

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")
if hasattr(sys.stderr, "reconfigure"):
    sys.stderr.reconfigure(encoding="utf-8")

# Paths
REPO_ROOT = Path(__file__).resolve().parents[4]
OUTPUT_DIR = REPO_ROOT / "docs" / "output" / "datamart"
SCRIPTS_DIR = REPO_ROOT / ".claude" / "skills" / "datamart-gen-docs" / "scripts"
SKILL_DIR = REPO_ROOT / ".claude" / "skills" / "datamart-gen-docs"

# Ưu tiên bản mẫu Q5 hiện hành (đặt tại gốc thư mục skill); fallback về
# Template.docx chung nếu bản hiện hành chưa có mặt.
_TEMPLATE_CANDIDATES = [
    SKILL_DIR / "UBCKNN_Q5_Tai lieu phan tich thiet ke_v1.0_20260429.docx",
    REPO_ROOT / "docs" / "templates" / "sample" / "UBCKNN_Q5_Tai lieu phan tich thiet ke_Template.docx",
]
TEMPLATE_DOCX = next((p for p in _TEMPLATE_CANDIDATES if p.exists()), _TEMPLATE_CANDIDATES[0])

# Ensure pandoc in PATH
pandoc_appdata = Path(os.environ.get("LOCALAPPDATA", "C:/Users/ADMIN/AppData/Local")) / "Pandoc"
if pandoc_appdata.exists() and str(pandoc_appdata) not in os.environ.get("PATH", ""):
    os.environ["PATH"] = str(pandoc_appdata) + os.pathsep + os.environ.get("PATH", "")

MODULES = [
    ("TT", "1", "Hoạt động Thanh tra"),
    ("NHNCK", "2", "Người hành nghề"),
    ("NDTNN", "3", "Quản lý NĐTNN"),
    ("QLCB", "4", "Quản lý chào bán"),
    ("GSDC", "5", "Giám sát Công ty Đại chúng"),
    ("GSTT", "6", "Giám sát Thị trường"),
    ("QLQ", "7", "Công ty Quản lý Quỹ (AMC)"),
    ("QLKD", "8", "Hoạt động Công ty Chứng khoán"),
    ("PTTT", "9", "Phân tích thị trường"),
    ("TKNB", "10", "Thống kê Thị trường"),
]


def generate_q5_full_markdown() -> Path:
    """Tạo file Markdown hoàn chỉnh cho toàn bộ Quyển 5."""
    header_content = """# 1. GIỚI THIỆU

## 1.1 Mục đích
Tài liệu Phân tích Thiết kế Hệ thống (Quyển 5: Phân hệ Kho dữ liệu — Datamart Layer) cung cấp bức tranh chi tiết về luồng tích hợp, tổng hợp và đồng bộ dữ liệu (ETL / Data Pipeline) từ các hệ thống nguồn nghiệp vụ qua tầng Atomic (Silver) lên tầng Kho dữ liệu Datamart (Gold) phục vụ công tác báo cáo, thống kê, phân tích và giám sát chuyên môn của Ủy ban Chứng khoán Nhà nước (UBCKNN).

Tài liệu được xây dựng nhằm chuẩn hóa thiết kế kỹ thuật, làm căn cứ cho việc phát triển, kiểm thử, nghiệm thu và vận hành các luồng dữ liệu tự động trên nền tảng Kho dữ liệu tổng thể.

## 1.2 Phạm vi
Tài liệu bao quát toàn bộ 10 phân hệ dữ liệu Datamart nghiệp vụ trọng yếu của UBCKNN:
1. **Phân hệ Hoạt động Thanh tra (TT):** Đồng bộ dữ liệu hồ sơ thanh tra/kiểm tra, biên bản, kết luận, xử phạt vi phạm hành chính và đơn thư khiếu nại tố cáo.
2. **Phân hệ Người hành nghề (NHNCK):** Đồng bộ dữ liệu hồ sơ chứng chỉ hành nghề, sát hạch, quá trình hành nghề, miễn giảm và xử lý vi phạm người hành nghề chứng khoán.
3. **Phân hệ Quản lý Nhà đầu tư Nước ngoài (NDTNN):** Đồng bộ dữ liệu mã số giao dịch chứng khoán (MSGD), tài khoản vốn, danh mục nắm giữ, dòng vốn FII, trần sở hữu nước ngoài (ROOM) và chế độ báo cáo theo Thông tư 51.
4. **Phân hệ Quản lý Chào bán Chứng khoán (QLCB):** Đồng bộ dữ liệu đăng ký chào bán, phát hành cổ phiếu/trái phiếu, đợt chào bán, kết quả phát hành và hồ sơ cấp phép.
5. **Phân hệ Giám sát Công ty Đại chúng (GSDC):** Đồng bộ dữ liệu đăng ký công ty đại chúng, báo cáo tài chính định kỳ/bất thường, tình hình quản trị và nghĩa vụ công bố thông tin.
6. **Phân hệ Giám sát Thị trường (GSTT):** Đồng bộ dữ liệu giao dịch hàng ngày cổ phiếu, trái phiếu doanh nghiệp, cơ cấu sở hữu cổ đông lớn và phát hiện dấu hiệu bất thường.
7. **Phân hệ Công ty Quản lý Quỹ (QLQ/AMC):** Đồng bộ dữ liệu hồ sơ công ty QLQ, danh mục quỹ đầu tư, giá trị tài sản ròng (NAV), hợp đồng ủy thác danh mục và giao dịch nội bộ.
8. **Phân hệ Hoạt động Công ty Chứng khoán (QLKD):** Đồng bộ dữ liệu hồ sơ CTCK, mạng lưới chi nhánh, an toàn tài chính, chỉ tiêu kinh doanh, cổ đông, nhân sự và tuân thủ pháp luật.
9. **Phân hệ Phân tích Thị trường (PTTT):** Đồng bộ dữ liệu dòng tiền nhà đầu tư, khối lượng/giá trị giao dịch tự doanh, nước ngoài, cơ cấu nợ vay trái phiếu ngành và chỉ tiêu an toàn vĩ mô.
10. **Phân hệ Thống kê Thị trường (TKNB):** Đồng bộ các biểu mẫu báo cáo thống kê định kỳ toàn thị trường HNX, HOSE, VSD, UPCoM, phái sinh, chứng quyền có bảo đảm (CW) và niên giám thống kê.

## 1.3 Khái niệm và Thuật ngữ
- **UBCKNN:** Ủy ban Chứng khoán Nhà nước.
- **Data Warehouse (DWH):** Kho dữ liệu tổng thể phục vụ phân tích và quản trị dữ liệu.
- **Staging / Bronze Layer:** Vùng tiếp nhận dữ liệu thô từ các hệ thống tác nghiệp nguồn (THANHTRA, IDS, FIMS, ORDERTRADE, MDDS, ...).
- **Atomic / Silver Layer:** Tầng lưu trữ dữ liệu tích hợp chi tiết theo mô hình 3NF/Inmon, lưu giữ lịch sử và chuẩn hóa định danh thực thể.
- **Datamart / Gold Layer:** Tầng dữ liệu mô hình hóa dạng Chiều (Dimensional Model: Fact / Dimension / Operational Table) tối ưu cho truy vấn phân tích và báo cáo.
- **ETL / ELT:** Trích xuất (Extract), Chuyển đổi (Transform) và Nạp dữ liệu (Load).
- **Fact Table:** Bảng sự kiện lưu trữ các chỉ tiêu định lượng (measures/metrics) theo các chiều phân tích.
- **Dimension Table:** Bảng chiều lưu trữ các thuộc tính ngữ cảnh (context/descriptors) dùng để lọc, phân nhóm và drill-down.
- **Operational Table:** Bảng tác nghiệp lưu trữ trạng thái mới nhất (latest snapshot) phục vụ tra cứu nhanh.

## 1.4 Tài liệu Tham khảo
- Tài liệu Thiết kế Kiến trúc Tổng thể Hệ thống CNTT UBCKNN (High-Level Design - HLD).
- Tài liệu Đặc tả Thiết kế Chi tiết và Từ điển Thuộc tính (Low-Level Design - LLD).
- Quy chuẩn Tài liệu Phân tích Thiết kế UBCKNN Quyển 5 (Q5 — `UBCKNN_Q5_Tai lieu phan tich thiet ke_v1.0_20260429.docx`).
- Các văn bản quy phạm pháp luật liên quan: Luật Chứng khoán, các Nghị định và Thông tư hướng dẫn thi hành.

## 1.5 Bố cục Tài liệu
Tài liệu gồm 6 phần chính:
- **Phần 1 — Giới thiệu:** Mục đích, phạm vi, khái niệm và tài liệu tham khảo.
- **Phần 2 — Tổng quan Giải pháp:** Kiến trúc tổng thể và mô hình tương tác hệ thống.
- **Phần 3 — Thiết kế Chi tiết:** Chi tiết các luồng đồng bộ dữ liệu ETL cho 10 phân hệ Datamart.
- **Phần 4 — Thiết kế Dùng chung và Tái sử dụng:** Quy hoạch các bảng Dimension và Master Data dùng chung.
- **Phần 5 — Thiết kế Đảm bảo Tuân thủ Tiêu chuẩn Quản trị Dữ liệu:** Quản trị, bảo mật, chất lượng và quản lý metadata.
- **Phần 6 — Phụ lục:** Bảng tổng hợp đối soát và ma trận luồng dữ liệu.

---

# 2. TỔNG QUAN GIẢI PHÁP

## 2.1 Tổng quan Chức năng Kho Dữ liệu Datamart (Gold Layer)
Phân hệ Kho dữ liệu Datamart là lớp dữ liệu nghiệp vụ phục vụ trực tiếp cho các Dashboard điều hành, Báo cáo nghiệp vụ định kỳ/đột xuất và Công cụ khai thác dữ liệu tự phục vụ (Self-Service BI) của UBCKNN.

Các nhóm chức năng chính bao gồm:
- **Tổng hợp Chỉ tiêu Định kỳ:** Tự động tổng hợp số liệu giao dịch, giá trị tài sản ròng, vốn hóa, khối lượng, tỷ lệ an toàn tài chính theo chu kỳ Ngày, Tuần, Tháng, Quý, Năm.
- **Theo dõi Xu hướng & Biến động:** Cung cấp chuỗi thời gian (time-series) cho phép so sánh cùng kỳ, đánh giá tốc độ tăng trưởng và phát hiện biến động bất thường.
- **Hồ sơ 360° Đối tượng Quản lý:** Tổng hợp toàn diện thông tin một tổ chức phát hành, công ty chứng khoán, công ty quản lý quỹ hoặc người hành nghề qua nhiều góc nhìn (pháp lý, tài chính, giao dịch, thanh tra, xử phạt).
- **Hỗ trợ Báo cáo Tuân thủ:** Đáp ứng kịp thời các biểu mẫu thống kê theo quy định của Bộ Tài chính, Chính phủ và các tổ chức quốc tế (IOSCO, World Bank).

## 2.2 Mô hình Giao tiếp và Kiến trúc Luồng Dữ liệu
Kiến trúc luồng dữ liệu Kho dữ liệu tuân thủ mô hình xử lý đa tầng phân tách rõ ràng trách nhiệm:

1. **Tầng Nguồn (Source Systems):** Bao gồm các ứng dụng tác nghiệp chuyên ngành (THANHTRA, IDS, FIMS, STCK, CSC, ORDERTRADE, MDDS, TTLK, ...). Dữ liệu được trích xuất qua Change Data Capture (CDC), Database Replication hoặc Batch File transfer.
2. **Tầng Staging / Bronze:** Lưu trữ dữ liệu thô đúng nguyên trạng từ nguồn, đóng dấu thời gian tiếp nhận (ingestion timestamp) và phục vụ đối soát vết dữ liệu (audit trail).
3. **Tầng Atomic / Silver:** Thực hiện chuẩn hóa kiểu dữ liệu, loại bỏ trùng lặp (deduplication), ánh xạ mã phân loại (classification mapping), thiết lập quan hệ khóa ngoại (foreign key relationships) và áp dụng mô hình SCD Type 2 quản lý lịch sử biến động.
4. **Tầng Datamart / Gold:** Tổng hợp số liệu theo mô hình hình sao (Star Schema) gồm các bảng Fact và Dimension tối ưu cho các công cụ BI và người dùng cuối.

---

# 3. THIẾT KẾ CHI TIẾT

## 3.1 PHÂN HỆ ETL — LUỒNG ĐỒNG BỘ DỮ LIỆU CHO CÁC NHÓM BÁO CÁO DATAMART
"""

    footer_content = """---

# 4. THIẾT KẾ DÙNG CHUNG VÀ TÁI SỬ DỤNG

## 4.1 Quy hoạch Chiều Dùng chung (Conformed Dimensions)
Để đảm bảo tính nhất quán trên toàn hệ thống Kho dữ liệu, các bảng Dimension chuẩn được chia sẻ dùng chung giữa 10 phân hệ Datamart:
- **Calendar Date Dimension (`cdr_dt_dim`):** Chiều thời gian chuẩn hóa cấp ngày, bao gồm các thuộc tính ngày trong tuần, tháng, quý, năm, ngày làm việc, ngày nghỉ lễ thị trường chứng khoán.
- **Classification Dimensions:** Các bảng danh mục phân loại chuẩn (loại hình chứng chỉ, loại hình công ty, loại hình quỹ, trạng thái hồ sơ, phân loại thị trường).
- **Organization & Issuer Dimension:** Chiều thông tin tổ chức phát hành, công ty đại chúng, thành viên giao dịch dùng chung giữa Giám sát thị trường, Quản lý chào bán và Giám sát CTDC.

## 4.2 Tái sử dụng Tầng Atomic (Silver Reusability)
Các thực thể dữ liệu cốt lõi tại tầng Atomic (`securities_trade`, `public_company`, `inspection_case`, `broker_license`, `fund_management_company`, ...) được thiết kế chuẩn hóa 3NF để feed đồng thời cho nhiều Datamart khác nhau mà không làm nhân bản dữ liệu nguồn.

---

# 5. THIẾT KẾ ĐẢM BẢO TUÂN THỦ TIÊU CHUẨN QUẢN TRỊ DỮ LIỆU

## 5.1 Quản trị Dữ liệu (Data Governance)
- **Quyền sở hữu Dữ liệu (Data Ownership):** Mỗi nhóm thông tin Datamart được phân định rõ đơn vị nghiệp vụ chủ quản (Cục/Vụ chuyên môn tương ứng) chịu trách nhiệm về định nghĩa chỉ tiêu và tính chính xác của dữ liệu.
- **Từ điển Dữ liệu (Data Dictionary):** 100% các bảng và trường dữ liệu đều được định nghĩa rõ ràng về tên vật lý, tên logic, mô tả nghiệp vụ và quy tắc tính toán (ETL Rules).

## 5.2 Bảo mật và Phân quyền Dữ liệu (Data Security & RBAC)
- Phân quyền truy cập theo vai trò (Role-Based Access Control - RBAC) và theo phạm vi thẩm quyền của từng đơn vị nghiệp vụ thuộc UBCKNN.
- Ghi nhật ký truy vết (Audit Logging) toàn bộ quá trình truy cập, trích xuất và biến động dữ liệu.
- Mã hóa dữ liệu nhạy cảm ở trạng thái lưu trữ (Encryption at Rest) và trên đường truyền (Encryption in Transit).

## 5.3 Kiểm soát Chất lượng Dữ liệu (Data Quality Management)
Hệ thống thiết lập các chốt kiểm soát tự động trong pipeline ETL:
- **Kiểm tra Tính toàn vẹn (Completeness):** Xác thực số lượng bản ghi giữa Staging, Atomic và Datamart sau mỗi chu kỳ nạp.
- **Kiểm tra Tính duy nhất (Uniqueness):** Ràng buộc khóa chính (PK) và phát hiện duplicate records.
- **Kiểm tra Tính hợp lệ (Validity):** Ràng buộc miền giá trị, kiểm tra định dạng ngày tháng và khoảng giá trị số học hợp lệ.
- **Cơ chế Cảnh báo (Alerting):** Tự động phát thông báo khi có bản ghi lỗi (quarantine records) để quản trị viên xử lý kịp thời.

## 5.4 Quản lý Siêu dữ liệu và Dòng dữ liệu (Metadata & Lineage Management)
- Thiết lập sơ đồ dòng dữ liệu trực quan 3 tầng (Staging ➔ Atomic ➔ Datamart) cho 100% các nhóm thông tin báo cáo.
- Quản lý metadata tự động: Lưu trữ thông tin hệ thống nguồn, bảng nguồn, trường nguồn và công thức tính toán phục vụ tra cứu ngược (Reverse Lineage Tracing).

## 5.5 Lưu trữ và Vận hành (Data Retention & Operations)
- **Chiến lược Phân vùng (Partitioning Strategy):** Phân vùng các bảng Fact lớn theo thời gian (năm/tháng) để tối ưu hiệu năng truy vấn.
- **Lưu trữ Lịch sử (Data Retention):** Dữ liệu Datamart được lưu trữ tối thiểu 10 năm phục vụ công tác thanh tra, điều tra và phân tích dài hạn.
- **Vận hành Tự động (Orchestration):** Các luồng ETL được lập lịch và giám sát tập trung, có cơ chế retry tự động khi gặp sự cố mạng hoặc nguồn dữ liệu.

---

# 6. PHỤ LỤC

## 6.1 Tổng hợp Ma trận Quy mô 10 Phân hệ Datamart

| STT | Mã Phân hệ | Tên Phân hệ Nghiệp vụ | Số Luồng Nghiệp vụ | Số Diagram Flowchart | Số Bảng Physical | Số Cột Physical |
|---|---|---|---|---|---|---|
| 1 | **TT** | Hoạt động Thanh tra | 5 nhóm | 5 | 7 bảng | 51 cột |
| 2 | **NHNCK** | Người hành nghề | 10 nhóm | 10 | 12 bảng | 105 cột |
| 3 | **NDTNN** | Quản lý NĐTNN | 7 nhóm | 7 | 13 bảng | 98 cột |
| 4 | **QLCB** | Quản lý chào bán | 3 nhóm | 3 | 7 bảng | 86 cột |
| 5 | **GSDC** | Giám sát Công ty Đại chúng | 2 nhóm | 2 | 4 bảng | 55 cột |
| 6 | **GSTT** | Giám sát Thị trường | 3 nhóm | 3 | 7 bảng | 69 cột |
| 7 | **QLQ** | Công ty Quản lý Quỹ (AMC) | 11 nhóm | 11 | 14 bảng | 149 cột |
| 8 | **QLKD** | Hoạt động Công ty Chứng khoán | 18 nhóm | 18 | 23 bảng | 244 cột |
| 9 | **PTTT** | Phân tích thị trường | 10 nhóm | 10 | 15 bảng | 134 cột |
| 10 | **TKNB** | Thống kê Thị trường | 21 nhóm | 21 | 21 bảng | 152 cột |
| **Tổng** | **10 Phân hệ** | **Toàn bộ Kho Dữ liệu UBCKNN** | **90 nhóm** | **90** | **123 bảng** | **1,143 cột** |

"""

    # Đọc và merge 10 file PTTK
    module_sections = []
    for mod_code, mod_idx, mod_name in MODULES:
        p = OUTPUT_DIR / mod_code / f"DTM_{mod_code}_PTTK.md"
        if not p.exists():
            raise FileNotFoundError(f"Missing PTTK file: {p}")
        text = p.read_text(encoding="utf-8").strip()
        # Đảm bảo heading 3.1.X đúng
        old_m = re.search(r"^(#{1,2}\s+)3\.[12]\.(\d+)([\s\S]?)(.*)$", text, re.MULTILINE)
        if old_m:
            old_x = old_m.group(2)
            text = re.sub(
                r"3\.[12]\." + re.escape(old_x) + r"(?=[\.\s\n]|$)",
                f"3.1.{mod_idx}",
                text,
                flags=re.MULTILINE,
            )
        module_sections.append(text)

    body_content = "\n\n\\newpage\n\n".join(module_sections)

    full_text = header_content.strip() + "\n\n" + body_content.strip() + "\n\n" + footer_content.strip() + "\n"

    out_md = OUTPUT_DIR / "UBCKNN_Q5_Tai_lieu_phan_tich_thiet_ke_Datamart_v1.0.md"
    out_md.write_text(full_text, encoding="utf-8")
    print(f"Generated Q5 Master Markdown: {out_md} ({len(full_text):,} chars)")
    return out_md


def build_q5_docx(md_path: Path) -> Path:
    """Biên dịch Markdown sang DOCX với template Q5 và post-processing."""
    import sys
    sys.path.insert(0, str(SCRIPTS_DIR))
    import build_docx

    out_docx = OUTPUT_DIR / "UBCKNN_Q5_Tai_lieu_phan_tich_thiet_ke_Datamart_v1.0.docx"
    
    # Render mermaid nếu có mmdc
    md_text = md_path.read_text(encoding="utf-8")
    md_text_replaced, png_files = build_docx.render_mermaid_blocks(md_text, OUTPUT_DIR)

    import tempfile
    tmp_md = Path(tempfile.mktemp(suffix=".md"))
    tmp_md.write_text(md_text_replaced, encoding="utf-8")

    pandoc = shutil.which("pandoc")
    if not pandoc:
        pandoc_exe = pandoc_appdata / "pandoc.exe"
        if pandoc_exe.exists():
            pandoc = str(pandoc_exe)
        else:
            raise SystemExit("Pandoc not found!")

    tmp_docx = Path(tempfile.mktemp(suffix=".docx"))
    cmd = [
        pandoc,
        str(tmp_md),
        "--from", "markdown+pipe_tables+auto_identifiers",
        "--to", "docx",
        "--output", str(tmp_docx),
        "--resource-path", str(OUTPUT_DIR),
    ]
    if TEMPLATE_DOCX.exists():
        cmd.extend(["--reference-doc", str(TEMPLATE_DOCX)])

    try:
        res = subprocess.run(cmd, capture_output=True, text=True)
    finally:
        tmp_md.unlink(missing_ok=True)

    if res.returncode != 0:
        tmp_docx.unlink(missing_ok=True)
        raise SystemExit(f"Pandoc error:\n{res.stderr}")

    # Sanitize content types
    build_docx._sanitize_docx_package(tmp_docx)

    # Post process (portrait A4, Times New Roman, shading, col widths)
    build_docx.post_process_docx(tmp_docx, doc_type="pttk")

    # Copy sang output
    shutil.copy2(tmp_docx, out_docx)
    tmp_docx.unlink(missing_ok=True)

    for png in png_files:
        png.unlink(missing_ok=True)

    print(f"Generated Q5 Master DOCX: {out_docx} ({out_docx.stat().st_size:,} bytes)")
    return out_docx


def main():
    print("=== BẮT ĐẦU GỘM TOÀN BỘ 10 PHÂN HỆ THÀNH 1 QUYỂN Q5 DUY NHẤT ===")
    print(f"Template DOCX (--reference-doc): {TEMPLATE_DOCX} ({'tồn tại' if TEMPLATE_DOCX.exists() else 'KHÔNG TỒN TẠI'})")
    md_file = generate_q5_full_markdown()
    docx_file = build_q5_docx(md_file)
    print("\n=== HOÀN TẤT XUẤT BẢN QUYỂN 5 DUY NHẤT ===")
    print(f"File Markdown: {md_file}")
    print(f"File Word DOCX: {docx_file}")


if __name__ == "__main__":
    main()
