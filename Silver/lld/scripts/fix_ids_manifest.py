import csv, io, sys

path = r'c:\Users\linhl_ufzmt5s\OneDrive\One - UBCK\Design\ubck_atomic_design\Silver\lld\manifest.csv'

with open(path, encoding='utf-8-sig', newline='') as f:
    content = f.read().replace('\r\n', '\n').replace('\r', '\n')

rows = list(csv.reader(io.StringIO(content)))
header = rows[0]

# Remove old IDS rows
kept = [r for r in rows[1:] if r and r[0] != 'IDS']
sys.stderr.write(f'Removed {len(rows)-1-len(kept)} IDS rows, kept {len(kept)}\n')

new_rows = [
    ['IDS','af_profiles','Audit Firm','T1','attr_IDS_af_profiles.csv'],
    ['IDS','report_catalog','Financial Report Catalog','T1','attr_IDS_report_catalog.csv'],
    ['IDS','rrow','Financial Report Row Template','T1','attr_IDS_rrow.csv'],
    ['IDS','rcol','Financial Report Column Template','T1','attr_IDS_rcol.csv'],
    ['IDS','rep_forms','Periodic Report Form','T1','attr_IDS_rep_forms.csv'],
    ['IDS','rep_row','Periodic Report Form Row Template','T1','attr_IDS_rep_row.csv'],
    ['IDS','rep_column','Periodic Report Form Column Template','T1','attr_IDS_rep_column.csv'],
    ['IDS','notifications','Disclosure Notification','T1','attr_IDS_notifications.csv'],
    ['IDS','forms','Disclosure Form Definition','T1','attr_IDS_forms.csv'],
    ['IDS','company_profiles','Public Company','T2','attr_IDS_company_profiles.csv'],
    ['IDS','company_detail','Public Company','T2','attr_IDS_company_profiles.csv'],
    ['IDS','stock_holders','Stock Holder','T2','attr_IDS_stock_holders.csv'],
    ['IDS','stock_holders','Involved Party Postal Address','T2','attr_IDS_stock_holders_IP_Postal_Address.csv'],
    ['IDS','stock_holders','Involved Party Electronic Address','T2','attr_IDS_stock_holders_IP_Electronic_Address.csv'],
    ['IDS','af_legal_representative','Audit Firm Legal Representative','T2','attr_IDS_af_legal_representative.csv'],
    ['IDS','af_approval','Audit Firm Approval','T2','attr_IDS_af_approval.csv'],
    ['IDS','af_auditor_approval','Auditor Approval','T2','attr_IDS_af_auditor_approval.csv'],
    ['IDS','noti_config','Disclosure Notification Config','T2','attr_IDS_noti_config.csv'],
    ['IDS','legal_representative','Public Company Legal Representative','T3','attr_IDS_legal_representative.csv'],
    ['IDS','company_relationship','Public Company Related Entity','T3','attr_IDS_company_relationship.csv'],
    ['IDS','state_capital','Public Company State Capital','T3','attr_IDS_state_capital.csv'],
    ['IDS','foreign_owner_limit','Public Company Foreign Ownership Limit','T3','attr_IDS_foreign_owner_limit.csv'],
    ['IDS','identity','Involved Party Alternative Identification','T3','attr_IDS_identity_IP_Alt_Identification.csv'],
    ['IDS','account_numbers','Stock Holder Trading Account','T3','attr_IDS_account_numbers.csv'],
    ['IDS','holder_relationship','Stock Holder Relationship','T3','attr_IDS_holder_relationship.csv'],
    ['IDS','stock_controls','Stock Control','T3','attr_IDS_stock_controls.csv'],
    ['IDS','af_warning','Audit Firm Warning','T3','attr_IDS_af_warning.csv'],
    ['IDS','af_sanctions','Audit Firm Sanction','T3','attr_IDS_af_sanctions.csv'],
    ['IDS','capital_mobilization','Public Company Capital Mobilization','T4','attr_IDS_capital_mobilization.csv'],
    ['IDS','company_add_capital','Public Company Capital Increase','T4','attr_IDS_company_add_capital.csv'],
    ['IDS','company_securities_issuance','Public Company Securities Offering','T4','attr_IDS_company_securities_issuance.csv'],
    ['IDS','company_tender_offer','Public Company Tender Offer','T4','attr_IDS_company_tender_offer.csv'],
    ['IDS','company_treasury_stocks','Public Company Treasury Stock Activity','T4','attr_IDS_company_treasury_stocks.csv'],
    ['IDS','company_inspection','Public Company Inspection','T4','attr_IDS_company_inspection.csv'],
    ['IDS','company_penalize','Public Company Penalty','T4','attr_IDS_company_penalize.csv'],
]

all_rows = kept + new_rows

out = io.StringIO()
w = csv.writer(out, lineterminator='\r\n')
w.writerow(header)
w.writerows(all_rows)

with open(path, 'w', encoding='utf-8-sig', newline='') as f:
    f.write(out.getvalue())

sys.stderr.write(f'Done: {len(all_rows)} rows total ({len(new_rows)} IDS rows added)\n')
