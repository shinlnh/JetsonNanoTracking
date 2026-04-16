param(
    [ValidateSet("pure", "yolo", "all")]
    [string]$Mode = "pure"
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = (Resolve-Path (Join-Path $scriptDir "..")).Path
$bash = Get-Command bash -ErrorAction SilentlyContinue

if (-not $bash) {
    Write-Error "bash is required. On Jetson Nano, run: bash jetson/setup_and_run_real_video_tests.sh $Mode"
    exit 1
}

$env:PROJECT_ROOT = $repoRoot
& $bash.Source (Join-Path $scriptDir "setup_and_run_real_video_tests.sh") $Mode

if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}
