-- ============================================================
-- PII Encryption Function — CHẠY TRƯỚC mọi 02_populate_*.sql
-- Giai đoạn: Datamart (MinIO) -> flat ClickHouse
-- Nguồn yêu cầu: docs/output/Đề Xuất Danh Mục Dữ Liệu Nhạy Cảm.docx.md (AES-256-CBC)
-- Registry cột PII: system/rules/pii_columns.yaml (Gate 8 D28 kiểm mọi flat)
-- ============================================================
-- fn_pii_encrypt(v, key_hex) = Base64( IV || AES-256-CBC-PKCS(v, key) ),   IV = SHA-256( Base64(key) || v )[0..15]
--
-- Hiện thực lại bằng ClickHouse của macro dbt `encrypt_cbc_deterministic` (Spark SQL `aes_encrypt`):
--     base64(aes_encrypt(CAST(col AS STRING), get_pii_key('enc'), 'CBC', 'PKCS',
--            substring(unhex(sha2(concat(base64(get_pii_key('enc')), CAST(col AS STRING)), 256)), 1, 16)))
-- Cùng khóa + cùng giá trị gốc => cùng chuỗi Base64 ở cả Spark (dbt) lẫn ClickHouse (flat), nên so khớp/join chéo tầng được.
--
--   v        : String hoặc Nullable(String). NULL -> NULL (xử lý NULL mặc định của ClickHouse, kiểu cột flat giữ nguyên;
--              tương đương `CASE WHEN col IS NULL THEN NULL` của macro). Chuỗi rỗng được mã hóa thành 1 khối 16 byte.
--   key_hex  : 64 ký tự hex = 32 byte (AES-256). Là byte của get_pii_key('enc') ở phía dbt.
--
-- Bố cục output: Base64( 16 byte IV | ciphertext ) — đúng bố cục `aes_encrypt` CBC của Spark (Spark gắn IV vào đầu output,
-- `aes_decrypt(unbase64(x), key, 'CBC', 'PKCS')` đọc lại IV từ 16 byte đầu). Bỏ IV khỏi output thì bộ giải mã Spark/ứng dụng
-- theo macro dbt sẽ giải mã sai.
--
-- Quyết định thiết kế:
--   1. DETERMINISTIC theo giá trị: IV không cố định mà được suy ra từ chính giá trị gốc và khóa (kiểu SIV). Cùng giá trị -> cùng
--      ciphertext nên filter `= :cccd`, join giữa các bảng flat, GROUP BY / DISTINCT và ORDER BY của ReplacingMergeTree vẫn đúng.
--      Hai giá trị khác nhau luôn có IV khác nhau => CBC không còn lộ tiền tố chung như IV cố định. Đánh đổi còn lại: lộ quan hệ
--      bằng nhau (ai thấy ciphertext biết hai dòng cùng giá trị).
--   2. Mã hóa LẠI cả cột đã mã hóa từ nguồn (2 lớp): ứng dụng phải giải mã 2 lần cho các cột đó.
--   3. Khóa là THAM SỐ RUNTIME lấy từ Vault/KMS (ClickHouse không có get_pii_key), tuyệt đối không ghi vào repo hay vào định nghĩa
--      hàm. Bộ chạy ETL truyền tham số theo cơ chế native hoặc secret store và che giá trị trong system.query_log
--      (query_masking_rules). Ai chạy được hàm với khóa đều giải mã được: cấp quyền EXECUTE cho tài khoản ETL, không cấp rộng.
--   4. Xoay khóa: flat được TRUNCATE + INSERT mỗi lần nạp nên chỉ cần đổi tham số và nạp lại toàn bộ (kèm ứng dụng đổi khóa giải
--      mã cùng lúc). Đổi khóa là đổi luôn IV nên mọi ciphertext đổi. CBC không có xác thực toàn vẹn (không HMAC) vì tài liệu chưa yêu cầu.
--   5. IV lấy từ `unhex(substring(hex(SHA256(...)), 1, 32))` = 16 byte đầu của digest, chỉ dùng hàm có tài liệu rõ về byte nhị phân.
--
-- Phía BI: tham số người dùng gõ vào để so khớp cột PII (VD :cccd) phải mã hóa cùng khóa bằng chính hàm này trước khi so sánh.
-- Giá trị chọn từ danh sách đã lấy từ cột flat thì là ciphertext sẵn, không cần mã hóa lại.
--
-- Đổi định nghĩa hàm: DROP FUNCTION fn_pii_encrypt ON CLUSTER 'my_cluster'; rồi chạy lại file này, sau đó nạp lại toàn bộ flat.
-- Bản cũ (v, key_hex, iv_hex) nếu đã tạo ở môi trường nào thì BẮT BUỘC drop: CREATE ... IF NOT EXISTS sẽ giữ nguyên bản cũ.
-- ============================================================

CREATE FUNCTION IF NOT EXISTS fn_pii_encrypt ON CLUSTER 'my_cluster' AS
    (v, key_hex) ->
        base64Encode(
            concat(
                unhex(substring(hex(SHA256(concat(base64Encode(unhex(key_hex)), toString(v)))), 1, 32)),
                encrypt('aes-256-cbc', toString(v), unhex(key_hex),
                        unhex(substring(hex(SHA256(concat(base64Encode(unhex(key_hex)), toString(v)))), 1, 32)))
            )
        );


-- ------------------------------------------------------------
-- Kiểm thử thủ công (khóa giả 32 byte 'K', không phải khóa thật). Chạy từng câu rồi so với kết quả mong đợi.
-- ------------------------------------------------------------
-- 1) Known-answer — phải khớp TỪNG KÝ TỰ (vector tính từ macro bằng Python, tests/test_pii_flat.py kiểm lại):
-- WITH hex(repeat('K', 32)) AS k
-- SELECT fn_pii_encrypt('NGUYEN VAN A', k) = 'iQHFdRKpgwP1etaeajNnWhcirpT1rdQUocamw1vVXjo=' AS ok_name,
--        fn_pii_encrypt('038090012345', k) = 'e5wPMAE4v0AS9vZ54EMwnthdEajrTIZEA4RqSLC7ZDE=' AS ok_id,
--        fn_pii_encrypt('', k)             = '1w6LEUpT2rI1nDtumVUzD0se4YbHX0Q4uNeyJjNAlLc=' AS ok_empty;   -- cả 3 = 1
--
-- 2) Đối chiếu chéo với Spark — chạy macro gốc trên cùng khóa/giá trị, kết quả phải đúng như câu 1:
-- SELECT base64(aes_encrypt('NGUYEN VAN A', repeat('K', 32), 'CBC', 'PKCS',
--                           substring(unhex(sha2(concat(base64(repeat('K', 32)), 'NGUYEN VAN A'), 256)), 1, 16)));
--
-- 3) Vòng mã hóa - giải mã (IV nằm ở 16 byte đầu, giống aes_decrypt của Spark):
-- WITH hex(repeat('K', 32)) AS k, base64Decode(fn_pii_encrypt('NGUYEN VAN A', k)) AS raw
-- SELECT decrypt('aes-256-cbc', substring(raw, 17), unhex(k), substring(raw, 1, 16)) AS plain;   -- plain = 'NGUYEN VAN A'
--
-- 4) Deterministic và IV theo từng giá trị (hai giá trị chung tiền tố phải cho IV khác nhau, tức 16 byte đầu khác nhau):
-- WITH hex(repeat('K', 32)) AS k
-- SELECT fn_pii_encrypt('038090012345', k) = fn_pii_encrypt('038090012345', k) AS same,                       -- 1
--        substring(base64Decode(fn_pii_encrypt('0380900123451', k)), 1, 16)
--            != substring(base64Decode(fn_pii_encrypt('0380900123452', k)), 1, 16) AS iv_differs;             -- 1
--
-- 5) NULL giữ nguyên NULL, kiểu cột không đổi:
-- WITH hex(repeat('K', 32)) AS k
-- SELECT fn_pii_encrypt(CAST(NULL AS Nullable(String)), k) AS n, toTypeName(n);   -- NULL, Nullable(String)
