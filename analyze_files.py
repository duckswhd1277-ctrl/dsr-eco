import pandas as pd
import os

file1 = r"C:\Users\Admin\Desktop\정리파일(수출).xls"
file2 = r"C:\Users\Admin\Desktop\OT 열처리.xls"

print(f"파일 존재 확인:")
print(f"정리파일(수출).xls: {os.path.exists(file1)}")
print(f"OT 열처리.xls: {os.path.exists(file2)}")

if os.path.exists(file1):
    df1 = pd.read_excel(file1)
    print("\n" + "="*80)
    print("📄 정리파일(수출).xls")
    print("="*80)
    print(f"열: {list(df1.columns)}")
    print(f"행 수: {len(df1)}")
    print("\n첫 10행:")
    print(df1.head(10).to_string())

if os.path.exists(file2):
    df2 = pd.read_excel(file2)
    print("\n" + "="*80)
    print("📄 OT 열처리.xls")
    print("="*80)
    print(f"열: {list(df2.columns)}")
    print(f"행 수: {len(df2)}")
    print("\n첫 10행:")
    print(df2.head(10).to_string())
