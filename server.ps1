param(
    [int]$Port = 8080,
    [string]$RootDirectory = "public"
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$webRoot = Join-Path $scriptDir $RootDirectory

if (-not (Test-Path $webRoot)) {
    Write-Error "Web root folder '$webRoot' does not exist."
    exit 1
}

$listener = New-Object System.Net.HttpListener
$prefix = "http://localhost:$Port/"
$listener.Prefixes.Add($prefix)

try {
    $listener.Start()
} catch {
    Write-Error "Failed to start listener on $prefix : $_"
    exit 1
}

Write-Host "===========================================================" -ForegroundColor Green
Write-Host "  FinWise Campus Banking Web Server Running!               " -ForegroundColor Cyan
Write-Host "  URL: $prefix                                             " -ForegroundColor Yellow
Write-Host "  Serving files from: $webRoot                             " -ForegroundColor Gray
Write-Host "  Press Ctrl+C to stop the server                          " -ForegroundColor Gray
Write-Host "===========================================================" -ForegroundColor Green
Write-Output "READY: $prefix"

$mimeTypes = @{
    ".html" = "text/html; charset=utf-8"
    ".htm"  = "text/html; charset=utf-8"
    ".css"  = "text/css; charset=utf-8"
    ".js"   = "application/javascript; charset=utf-8"
    ".json" = "application/json; charset=utf-8"
    ".png"  = "image/png"
    ".jpg"  = "image/jpeg"
    ".jpeg" = "image/jpeg"
    ".gif"  = "image/gif"
    ".svg"  = "image/svg+xml"
    ".ico"  = "image/x-icon"
}

while ($listener.IsListening) {
    try {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response

        $rawUrl = $request.Url.LocalPath.TrimStart('/')
        if ([string]::IsNullOrWhiteSpace($rawUrl) -or $rawUrl -eq "index.html") {
            $rawUrl = "login.html"
        }

        # Normalize relative path
        $filePath = Join-Path $webRoot $rawUrl
        if (-not (Test-Path $filePath) -and (Test-Path "$filePath.html")) {
            $filePath = "$filePath.html"
        }

        if (Test-Path $filePath -PathType Leaf) {
            $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
            $contentType = if ($mimeTypes.ContainsKey($ext)) { $mimeTypes[$ext] } else { "application/octet-stream" }
            $response.ContentType = $contentType
            $response.StatusCode = 200

            $bytes = [System.IO.File]::ReadAllBytes($filePath)
            $response.ContentLength64 = $bytes.Length
            $response.OutputStream.Write($bytes, 0, $bytes.Length)
        } else {
            $response.StatusCode = 404
            $errBytes = [System.Text.Encoding]::UTF8.GetBytes("<h1>404 Not Found</h1><p>File not found: $rawUrl</p>")
            $response.ContentType = "text/html; charset=utf-8"
            $response.ContentLength64 = $errBytes.Length
            $response.OutputStream.Write($errBytes, 0, $errBytes.Length)
        }

        $response.OutputStream.Close()
    } catch {
        # Catch client disconnects or interruptions
    }
}
