$addons = "C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns"
$repo   = "C:\Users\종민\repository\addon\pvpster"

# 단일 모듈: 리포 루트 자체를 AddOns\PvPster 로 symlink (BigWigs Packager 표준 구조)
$dst = "$addons\PvPster"

if (Test-Path $dst) {
    Remove-Item $dst -Recurse -Force
}

New-Item -ItemType Junction -Path $dst -Target $repo | Out-Null

$item = Get-Item $dst
Write-Host "[OK] PvPster -> $($item.Target)"
Write-Host "`n완료. WoW를 /reload 하세요."
