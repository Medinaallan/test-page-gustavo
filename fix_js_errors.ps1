# Script para arreglar todos los errores de JavaScript en shop.html
$shopPath = "shop.html"
$content = Get-Content $shopPath -Raw

# Arreglar las comillas en showDualPriceOptions
$content = $content -replace 'showDualPriceOptions\(([^)]+)\)', {
    param($match)
    $params = $match.Groups[1].Value
    # Reemplazar comillas dobles con &quot; en las dimensiones
    $params = $params -replace '(\d+)" x (\d+)"', '$1&quot; x $2&quot;'
    $params = $params -replace '(\d+)" x (\d+)" & (\d+)" x (\d+)"', '$1&quot; x $2&quot; &amp; $3&quot; x $4&quot;'
    return "showDualPriceOptions($params)"
}

# Arreglar nombres con apóstrofes en JavaScript
$content = $content -replace "showDualPriceOptions\('([^']*)'s([^']*)'", "showDualPriceOptions('`$1s`$2'"
$content = $content -replace "Pirate's", "Pirates"
$content = $content -replace "Lafitte's", "Lafittes"
$content = $content -replace "Lafitte_s", "Lafittes"
$content = $content -replace "katies", "Katies"
$content = $content -replace "Maya's", "Mayas"
$content = $content -replace "Elisa's", "Elisas"

# Arreglar IDs de modales problemáticos
$content = $content -replace "openModal\('([^']*--[^']*)\'\)", {
    param($match)
    $modalId = $match.Groups[1].Value
    $modalId = $modalId -replace '--', '-'
    return "openModal('$modalId')"
}

# Guardar el archivo corregido
$content | Out-File $shopPath -Encoding UTF8

Write-Host "Errores de JavaScript corregidos en shop.html"
