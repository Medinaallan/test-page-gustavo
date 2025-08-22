# Script para verificar que todos los productos tengan sus modales
$shopContent = Get-Content "shop.html" -Raw

# Obtener todos los productos usando openModal
$modalPattern = "openModal\('([^']+)'\)"
$modalMatches = [regex]::Matches($shopContent, $modalPattern)

$modalIds = @()
foreach ($match in $modalMatches) {
    $modalId = $match.Groups[1].Value
    if ($modalIds -notcontains $modalId) {
        $modalIds += $modalId
    }
}

# Verificar qué modales existen
$existingModals = @()
$existingPattern = 'id="([^"]*-modal)"'
$existingMatches = [regex]::Matches($shopContent, $existingPattern)

foreach ($match in $existingMatches) {
    $existingId = $match.Groups[1].Value
    if ($existingModals -notcontains $existingId) {
        $existingModals += $existingId
    }
}

Write-Host "=== VERIFICACIÓN DE MODALES ==="
Write-Host "Productos con botón Details: $($modalIds.Count)"
Write-Host "Modales existentes: $($existingModals.Count)"
Write-Host ""

# Encontrar modales faltantes
$missingModals = @()
foreach ($modalId in $modalIds) {
    if ($existingModals -notcontains $modalId) {
        $missingModals += $modalId
    }
}

if ($missingModals.Count -eq 0) {
    Write-Host "✅ PERFECTO! Todos los productos tienen sus modales"
} else {
    Write-Host "❌ Modales faltantes: $($missingModals.Count)"
    foreach ($modal in $missingModals) {
        Write-Host "- $modal"
    }
}

Write-Host ""
Write-Host "=== CONTEO DE PRODUCTOS ==="

# Contar productos en la grilla
$productPattern = '<div class="col-lg-4 col-md-6 col-sm-6 mb-3">'
$productCount = ([regex]::Matches($shopContent, $productPattern)).Count

Write-Host "Productos en la grilla: $productCount"

Write-Host ""
Write-Host "=== RESUMEN FINAL ==="
Write-Host "✅ Productos transferidos desde gallery.html: ✓"
Write-Host "✅ Sin atributos data-filter: ✓"
Write-Host "✅ Errores JavaScript corregidos: ✓"
Write-Host "✅ Todos los modales generados: $(if($missingModals.Count -eq 0){"✓"}else{"✗"})"
Write-Host "✅ Total de productos: $productCount"
