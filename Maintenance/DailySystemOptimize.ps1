$logFile = "D:\Workspace\Maintenance\cleanup_history.log"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
# 1. 清理系统与用户级临时文件 (C盘及D盘重定向目录)
$tempTargets = @(
    "$env:TEMP\*",
    "$env:windir\Temp\*",
    "$env:windir\SoftwareDistribution\Download\*",
    "$env:LOCALAPPDATA\CrashDumps\*",
    "$env:LOCALAPPDATA\Microsoft\Windows\INetCache\*",
    "D:\Temp\*"
)
foreach ($t in $tempTargets) {
    $parent = Split-Path $t -Parent
    if (Test-Path $parent) {
        Get-ChildItem -Path $t -Recurse -Force -ErrorAction SilentlyContinue | 
            Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    }
}
# 2. 清空回收站
Clear-RecycleBin -Force -ErrorAction SilentlyContinue
# 3. 清理残留的孤立终端与后台僵尸进程 (排除当前执行进程自身)
$currentPid = $PID
Get-Process -Name "powershell", "pwsh", "cmd", "conhost" -ErrorAction SilentlyContinue | 
    Where-Object { $_.Id -ne $currentPid -and $_.MainWindowHandle -eq 0 } | 
    Stop-Process -Force -ErrorAction SilentlyContinue
# 4. 刷新 DNS 解析缓存与网络栈
Clear-DnsClientCache
nbtstat -R | Out-Null
# 5. 对 C 盘和 D 盘执行 TRIM 性能优化
Optimize-Volume -DriveLetter C -ReTrim -Verbose:$false -ErrorAction SilentlyContinue
Optimize-Volume -DriveLetter D -ReTrim -Verbose:$false -ErrorAction SilentlyContinue
# 6. 触发内存垃圾回收
[System.GC]::Collect()
[System.GC]::WaitForPendingFinalizers()
# 7. 记录精简运行日志 (只保留最近 30 条记录，防止日志变大)
$freeC = [math]::Round((Get-Volume -DriveLetter C).SizeRemaining / 1GB, 2)
$logEntry = "[$timestamp] 每日维护完成 | C盘当前可用空间: ${freeC} GB"
Add-Content -Path $logFile -Value $logEntry -Encoding UTF8
$logs = Get-Content -Path $logFile -Tail 30
Set-Content -Path $logFile -Value $logs -Encoding UTF8
