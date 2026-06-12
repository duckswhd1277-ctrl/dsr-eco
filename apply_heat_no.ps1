# HEAT NO 자동 적용 스크립트

$file1Path = "C:\Users\Admin\Desktop\정리파일(수출).xls"
$file2Path = "C:\Users\Admin\Desktop\OT 열처리.xls"
$outputPath = "C:\Users\Admin\Desktop\정리파일(수출)_HEAT처리.xls"

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "🔄 HEAT NO 자동 적용 프로세스" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false

try {
    # 1. OT 열처리 파일 읽기
    Write-Host "`n[1/4] OT 열처리 파일 읽기 중..." -ForegroundColor Yellow
    $wb2 = $excel.Workbooks.Open($file2Path)
    $ws2 = $wb2.ActiveSheet

    $otData = @{}
    $rows2 = $ws2.UsedRange.Rows.Count

    # OT 파일 헤더 위치 확인
    $otManufCol = 6  # 제조번호
    $otHeatCol = 9   # HEAT NO

    for ($row = 2; $row -le $rows2; $row++) {
        $manuf = $ws2.Cells.Item($row, $otManufCol).Text
        $heat = $ws2.Cells.Item($row, $otHeatCol).Text

        if ($manuf) {
            if (-not $otData.ContainsKey($manuf)) {
                $otData[$manuf] = $heat
            }
        }

        if ($row % 50 -eq 0) {
            Write-Host "  처리 중: $row / $rows2" -ForegroundColor Gray
        }
    }

    Write-Host "  ✅ OT 열처리 데이터 로드 완료: $($otData.Count)개 항목" -ForegroundColor Green
    $wb2.Close($false)

    # 2. 정리파일(수출) 파일 열기
    Write-Host "`n[2/4] 정리파일(수출) 복사 중..." -ForegroundColor Yellow
    Copy-Item $file1Path $outputPath
    Write-Host "  ✅ 백업 생성 완료" -ForegroundColor Green

    # 3. 복사본 열고 수정
    Write-Host "`n[3/4] 정리파일 수정 중..." -ForegroundColor Yellow
    $wb1 = $excel.Workbooks.Open($outputPath)
    $ws1 = $wb1.ActiveSheet

    $origManufCol = 2   # 제조번호
    $origHeatCol = 26   # 비고2(HEAT)

    $rows1 = $ws1.UsedRange.Rows.Count
    $matchCount = 0
    $totalRows = 0

    for ($row = 2; $row -le $rows1; $row++) {
        $manuf = $ws1.Cells.Item($row, $origManufCol).Text

        if ($manuf) {
            $totalRows++
            if ($otData.ContainsKey($manuf)) {
                $ws1.Cells.Item($row, $origHeatCol).Value = $otData[$manuf]
                $matchCount++
            }
        }

        if ($row % 1000 -eq 0) {
            Write-Host "  진행률: $row / $rows1 (매칭: $matchCount)" -ForegroundColor Gray
        }
    }

    Write-Host "  ✅ 수정 완료: 총 $totalRows행 중 매칭 $matchCount건" -ForegroundColor Green

    # 4. 저장
    Write-Host "`n[4/4] 파일 저장 중..." -ForegroundColor Yellow
    $wb1.Save()
    $wb1.Close($false)
    Write-Host "  ✅ 파일 저장 완료: $outputPath" -ForegroundColor Green

    Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "📊 최종 결과" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "  📌 정리파일 총 항목: $rows1 행" -ForegroundColor White
    Write-Host "  ✅ HEAT NO 입력 완료: $matchCount 개" -ForegroundColor Green
    Write-Host "  💾 출력 파일: $outputPath" -ForegroundColor Cyan
    Write-Host ""

} catch {
    Write-Host "`n❌ 오류 발생: $_" -ForegroundColor Red
} finally {
    $excel.Quit()
}

Write-Host "완료! 파일을 확인해주세요." -ForegroundColor Green
