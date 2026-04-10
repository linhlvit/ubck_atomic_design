# Dashboard Theo dõi Nhân sự Hành nghề

## 1. Chỉ số tổng quan (Key Metrics)
Dưới đây là các chỉ số quan trọng được trích xuất từ bảng `FCT_SP_CERTIFICATE_SNAP`.

| Tổng người hành nghề | CC cấp mới (YTD) | CCHN đang hoạt động | Bị thu hồi | Cảnh báo NHNCK |
| :---: | :---: | :---: | :---: | :---: |
| **12,450** | **1,230** | <span style="color:green">**10,890**</span> | <span style="color:red">**320**</span> | <span style="color:orange">**85**</span> |

---

## 2. Biểu đồ Phân tích (Visualizations)

### A. Trình độ chuyên môn
**Source:** `FCT_SP_PERSON_SNAP` $\rightarrow$ `DIM_SP_PERSON`

```mermaid
pie title Trình độ chuyên môn
    "Tiến sĩ" : 8
    "Thạc sĩ" : 35
    "Đại học" : 57