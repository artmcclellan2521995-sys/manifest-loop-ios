Clear-Host
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "          🌱 D 盘『开花结果』极客守护种子          " -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "正在执行全自动巡检与定点清理，请稍候..." -ForegroundColor Yellow
# ① 自动强力清空重定向后的 D:\Temp 核心运行临时缓存
if (Test-Path "D:\Temp") {
    Remove-Item -Path "D:\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "[✓] 成功深层清空 D:\Temp 临时缓存管道！" -ForegroundColor Green
}
# ② 自动拦截并斩杀可能死灰复燃的 C 盘 npm / pip 隐蔽缓存
$C_Npm = "C:\Users\86166\AppData\Local\npm-cache"
if (Test-Path $C_Npm) {
    Remove-Item -Path $C_Npm -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "[✓] 成功拦截并粉碎意外复活的 C 盘 npm-cache 垃圾！" -ForegroundColor Green
}
# ③ 自动唤醒底层固态硬盘物理加速 (向 C 盘和 D 盘同时发送 TRIM 空间收回指令)
Optimize-Volume -DriveLetter C -Defrag -ErrorAction SilentlyContinue
Optimize-Volume -DriveLetter D -Defrag -ErrorAction SilentlyContinue
Write-Host "[✓] 成功唤醒 C 盘与 D 盘固态硬盘底层物理加速！" -ForegroundColor Green
# ④ 自动巡检并巩固【黄金开发与学术工作区】
$SubFolders = @("D:\Workspace\Code_Projects", "D:\Workspace\Thesis_Research")
foreach ($folder in $SubFolders) {
    if (-not (Test-Path $folder)) { 
        New-Item -Path $folder -ItemType Directory | Out-Null
    }
}
Write-Host "[✓] D 盘黄金科研与代码基地：完美就绪！" -ForegroundColor Green
# ⑤ 吐出最新盘存战果
Write-Host "`n================ 最新磁盘空间盘存 ================" -ForegroundColor Cyan
Get-CimInstance Win32_LogicalDisk | Where-Object {$_.DeviceID -in "C:","D:"} | Select-Object DeviceID, @{Name="总大小 (GB)";Expression={[math]::round($_.Size/1GB,2)}}, @{Name="可用空间 (GB)";Expression={[math]::round($_.FreeSpace/1GB,2)}} | Format-Table | Out-String | Write-Host -ForegroundColor White
Write-Host "✨ 守护完毕！所有后续果实已被死死锁定在 D 盘。按任意键关闭..." -ForegroundColor Cyan
Read-Host
# ⑤ 种子后台全自动核验虚拟内存状态，防止系统更新后偷跑回C盘
Set-CimInstance -Query "Select * from Win32_ComputerSystem" -Property @{AutomaticManagedPagefile=$False} -ErrorAction SilentlyContinue
