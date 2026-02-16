Write-Host "=== DC DEMOTION READINESS CHECK ===" -ForegroundColor Cyan

Write-Host "`n[1] FSMO Roles" -ForegroundColor Cyan
netdom query fsmo

Write-Host "`n[2] Global Catalogs" -ForegroundColor Cyan
Get-ADForest | Select-Object -ExpandProperty GlobalCatalogs

Write-Host "`n[3] Replication Summary" -ForegroundColor Cyan
repadmin /replsummary

Write-Host "`n[4] DNS Health" -ForegroundColor Cyan
dcdiag /test:DNS

Write-Host "`n[5] SYSVOL Check" -ForegroundColor Cyan
dcdiag /test:SYSVOLCHECK

Write-Host "`n[6] Domain Controllers" -ForegroundColor Cyan
Get-ADDomainController -Filter * | Select-Object HostName, IPv4Address, IsGlobalCatalog, OperationMasterRoles

Write-Host "`n[7] DNS Clients (manual check reminder)" -ForegroundColor Cyan
Write-Host "Ensure all servers/clients now use DC25 as primary DNS before demotion." -ForegroundColor Yellow

Write-Host "`n=== READINESS CHECK COMPLETE ===" -ForegroundColor Green
Write-Host "If FSMO roles are all on DC25, replication is healthy, and DNS/SYSVOL tests pass, you are safe to demote the 2022 DC." -ForegroundColor Green
