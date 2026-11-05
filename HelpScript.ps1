[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^ocid1\.')]
    [string]$CompartmentId
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not (Get-Command oci -ErrorAction SilentlyContinue)) {
    throw 'No se encontro OCI CLI. Instalala y ejecuta "oci setup config" antes de usar este script.'
}

Write-Host 'Formas disponibles:' -ForegroundColor Cyan
$shapeList = oci compute shape list --compartment-id $CompartmentId --all | ConvertFrom-Json
$shapeList.data |
    Select-Object shape, @{Name = 'memory_in_gbs'; Expression = { $_.'memory-in-gbs' } }, ocpus |
    Sort-Object shape |
    Format-Table -AutoSize

Write-Host 'Imagenes recientes de Oracle Linux 8:' -ForegroundColor Cyan
$imageList = oci compute image list --compartment-id $CompartmentId --all | ConvertFrom-Json
$imageList.data |
    Where-Object {
        $_.'operating-system' -eq 'Oracle Linux' -and
        $_.'operating-system-version' -like '8*'
    } |
    Sort-Object 'time-created' -Descending |
    Select-Object -First 10 id, 'display-name', 'operating-system-version', 'time-created' |
    Format-Table -AutoSize
