import csv, io, sys

path = r'c:\Users\linhl_ufzmt5s\OneDrive\One - UBCK\Design\ubck_atomic_design\Silver\hld\silver_entities.csv'

with open(path, encoding='utf-8-sig') as f:
    rows = list(csv.reader(f))

header = rows[0]
data = rows[1:]

# Update shared entities source_tables
for r in data:
    if r[2] == 'Audit Firm' and r[4] == 'approved':
        r[6] = r[6] + ', IDS.af_profiles'
    if r[2] == 'Involved Party Alternative Identification' and r[4] == 'approved':
        r[6] = r[6] + ', IDS.identity'
    if r[2] == 'Involved Party Postal Address' and r[4] == 'approved':
        r[6] = r[6] + ', IDS.stock_holders'
    if r[2] == 'Involved Party Electronic Address' and r[4] == 'approved':
        r[6] = r[6] + ', IDS.stock_holders, IDS.af_profiles'

# New IDS entities
new_rows = [
    ['Involved Party', '[Involved Party] Involved Party Role', 'Audit Firm Legal Representative', 'Fundamental', 'draft',
     'Nguoi dai dien phap luat cua cong ty kiem toan -- chuc vu va ngay bo nhiem/ket thuc nhiem ky. FK to Audit Firm.',
     'IDS.af_legal_representative'],
    ['Documentation', '[Documentation] Government Registration Document', 'Audit Firm Approval', 'Fundamental', 'draft',
     'Quyet dinh chap thuan/dinh chi cong ty kiem toan tu BTC va UBCKNN -- so van ban/ngay/noi dung. Gop 2 co quan. FK to Audit Firm.',
     'IDS.af_approval'],
    ['Documentation', '[Documentation] Government Registration Document', 'Auditor Approval', 'Fundamental', 'draft',
     'Quyet dinh chap thuan/dinh chi kiem toan vien tu BTC va UBCKNN -- chung chi hanh nghe/nam chap thuan. FK to Audit Firm.',
     'IDS.af_auditor_approval'],
    ['Business Activity', '[Business Activity] Conduct Violation', 'Audit Firm Warning', 'Fact Append', 'draft',
     'Nhac nho tu BTC hoac UBCKNN den cong ty kiem toan hoac kiem toan vien -- so van ban va noi dung. FK nullable: Audit Firm Approval hoac Auditor Approval.',
     'IDS.af_warning'],
    ['Business Activity', '[Business Activity] Conduct Violation', 'Audit Firm Sanction', 'Fact Append', 'draft',
     'Xu phat hanh chinh doi voi cong ty kiem toan hoac kiem toan vien -- quyet dinh va noi dung xu phat. FK nullable: Audit Firm Approval hoac Auditor Approval.',
     'IDS.af_sanctions'],
    ['Involved Party', '[Involved Party] Individual', 'Public Company Legal Representative', 'Fundamental', 'draft',
     'Nguoi dai dien phap luat va nguoi CBTT cua cong ty dai chung -- representative_role_code phan biet 2 vai tro. FK to Public Company.',
     'IDS.legal_representative'],
    ['Involved Party', '[Involved Party] Involved Party Relationship', 'Public Company Related Entity', 'Fundamental', 'draft',
     'Cong ty me/con/lien ket cua cong ty dai chung -- ten/MST/von/ty le so huu/thoi han hieu luc. FK to Public Company.',
     'IDS.company_relationship'],
    ['Arrangement', '[Arrangement]', 'Public Company State Capital', 'Fundamental', 'draft',
     'Thong tin so huu nha nuoc trong cong ty dai chung -- ten dai dien nha nuoc va ty le so huu. FK to Public Company.',
     'IDS.state_capital'],
    ['Condition', '[Condition] Criterion', 'Public Company Foreign Ownership Limit', 'Fundamental', 'draft',
     'Gioi han ty le so huu nuoc ngoai cua cong ty dai chung -- max_owner_rate va khoang thoi gian ap dung. FK to Public Company.',
     'IDS.foreign_owner_limit'],
    ['Business Activity', '[Business Activity]', 'Public Company Capital Mobilization', 'Fact Append', 'draft',
     'Tang von truoc khi thanh cong ty dai chung -- tong von cuoi nam va hinh thuc tang. Grain: 1 nam x 1 cong ty. FK to Public Company.',
     'IDS.capital_mobilization'],
    ['Business Activity', '[Business Activity]', 'Public Company Capital Increase', 'Fact Append', 'draft',
     'Tang von dieu le sau khi thanh cong ty dai chung -- von cuoi nam tai chinh va so dot tang. FK to Public Company.',
     'IDS.company_add_capital'],
    ['Business Activity', '[Business Activity]', 'Public Company Securities Offering', 'Fact Append', 'draft',
     'Hoat dong chao ban/phat hanh chung khoan -- loai CK/ke hoach/ket qua thuc te theo tung hinh thuc. FK to Public Company.',
     'IDS.company_securities_issuance'],
    ['Business Activity', '[Business Activity]', 'Public Company Tender Offer', 'Fact Append', 'draft',
     'Chao mua cong khai -- ben chao mua/so luong du kien/ket qua/ty le so huu truoc-sau. FK to Public Company.',
     'IDS.company_tender_offer'],
    ['Transaction', '[Event] Transaction', 'Public Company Treasury Stock Activity', 'Fact Append', 'draft',
     'Giao dich co phieu quy theo nam -- so luong mua/ban va so dot. FK to Public Company.',
     'IDS.company_treasury_stocks'],
    ['Business Activity', '[Business Activity] Audit Investigation', 'Public Company Inspection', 'Fact Append', 'draft',
     'Thanh tra/kiem tra cong ty dai chung -- loai/so quyet dinh/don vi chu tri/bien ban. FK to Public Company.',
     'IDS.company_inspection'],
    ['Business Activity', '[Business Activity] Conduct Violation', 'Public Company Penalty', 'Fact Append', 'draft',
     'Xu phat hanh chinh cong ty dai chung hoac nha dau tu lien quan -- hanh vi vi pham va quyet dinh xu phat. FK to Public Company.',
     'IDS.company_penalize'],
    ['Involved Party', '[Involved Party] Individual', 'Stock Holder', 'Fundamental', 'draft',
     'Co dong giao dich -- ca nhan hoac to chuc nam giu co phan cong ty dai chung. Grain: co dong x cong ty. FK to Public Company.',
     'IDS.stock_holders'],
    ['Arrangement', '[Arrangement] Securities Account', 'Stock Holder Trading Account', 'Fundamental', 'draft',
     'Tai khoan giao dich chung khoan cua co dong tai CTCK -- so tai khoan va trang thai. FK to Stock Holder.',
     'IDS.account_numbers'],
    ['Involved Party', '[Involved Party] Involved Party Relationship', 'Stock Holder Relationship', 'Fundamental', 'draft',
     'Quan he giua cac co dong giao dich -- loai quan he/thoi han/trang thai. FK to Stock Holder x 2.',
     'IDS.holder_relationship'],
    ['Condition', '[Condition]', 'Stock Control', 'Fundamental', 'draft',
     'Han che chuyen nhuong co phieu cua co dong -- so luong bi han che/thoi gian/loai han che. FK to Stock Holder.',
     'IDS.stock_controls'],
    ['Condition', '[Condition]', 'Disclosure Form Definition', 'Fundamental', 'draft',
     'Dinh nghia loai ho so/tin CBTT -- loai form/quy trinh duyet/nghiep vu. Master entity cua vong doi CBTT. Self-join parent_form_id.',
     'IDS.forms'],
    ['Condition', '[Condition]', 'Financial Report Catalog', 'Fundamental', 'draft',
     'Danh muc bao cao tai chinh -- loai bao cao/nam/scope hop nhat/loai hinh doanh nghiep. Master entity FK tu Financial Report Row/Column Template.',
     'IDS.report_catalog'],
    ['Condition', '[Condition]', 'Financial Report Row Template', 'Fundamental', 'draft',
     'Dinh nghia hang trong bieu mau BCTC -- ma hang/ten/cong thuc/thu tu. FK to Financial Report Catalog.',
     'IDS.rrow'],
    ['Condition', '[Condition]', 'Financial Report Column Template', 'Fundamental', 'draft',
     'Dinh nghia cot trong bieu mau BCTC -- ma cot/ten/cong thuc/thu tu. FK to Financial Report Catalog.',
     'IDS.rcol'],
    ['Condition', '[Condition]', 'Periodic Report Form', 'Fundamental', 'draft',
     'Bieu mau bao cao dinh ky (thuong nien/quy/thang) cho CBTT. Master entity FK tu Periodic Report Form Row/Column Template. Self-join.',
     'IDS.rep_forms'],
    ['Condition', '[Condition]', 'Periodic Report Form Row Template', 'Fundamental', 'draft',
     'Dinh nghia hang trong bieu mau bao cao dinh ky -- ten/thu tu/kieu du lieu. FK to Periodic Report Form.',
     'IDS.rep_row'],
    ['Condition', '[Condition]', 'Periodic Report Form Column Template', 'Fundamental', 'draft',
     'Dinh nghia cot trong bieu mau bao cao dinh ky -- ten/thu tu/cong thuc. FK to Periodic Report Form.',
     'IDS.rep_column'],
    ['Communication', '[Communication] Notification', 'Disclosure Notification', 'Fact Append', 'draft',
     'Instance thong bao CBTT gui di -- noi dung/tieu de/ngay gui/trang thai. Grain: 1 lan gui thong bao. FK to Disclosure Form Definition.',
     'IDS.notifications'],
    ['Condition', '[Condition] Criterion', 'Disclosure Notification Config', 'Fundamental', 'draft',
     'Cau hinh thong bao CBTT -- kenh gui/he thong nhan/nguoi quan ly. FK to Disclosure Notification.',
     'IDS.noti_config'],
]

all_rows = data + new_rows
all_rows.sort(key=lambda r: (r[0], r[2]))

out = io.StringIO()
w = csv.writer(out, lineterminator='\n')
w.writerow(header)
w.writerows(all_rows)
content = out.getvalue()

with open(path, 'w', encoding='utf-8-sig') as f:
    f.write(content)

sys.stderr.write(f'Done: {len(all_rows)} data rows written ({len(new_rows)} new IDS entities added)\n')
