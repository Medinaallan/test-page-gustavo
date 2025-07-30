# Script PowerShell para corregir TODOS los enlaces "Shop This" con los product IDs correctos

$productMappings = @{
    "Maison Rouge" = "maison-rouge"
    "Red House" = "red-house"
    "St. Louis Cathedral in Full Color" = "st-louis-cathedral-full-color"
    "Curve Appeal" = "curve-appeal"
    "Quartet" = "quartet"
    "Canary" = "canary"
    "Vieux Carré Balconies" = "vieux-carre-balconies"
    "Edifice Bleu" = "edifice-bleu"
    "Lafittes Blacksmith House Blue Hue" = "lafittes-blacksmith-blue"
    "Lafitte's Blacksmith Shop" = "lafittes-blacksmith-shop"
    "Mardi Gras" = "mardi-gras"
    "Maya's House" = "mayas-house"
    "Red & Yellow Houses" = "red-yellow-houses"
    "Shades of Blue" = "shades-of-blue"
    "St. Louis Cathedral Lite Sky" = "st-louis-lite-sky"
    "St. Louis in Full Color" = "st-louis-full-color"
    "Tree House 1" = "tree-house-1"
    "Tree House 2" = "tree-house-2"
    "Yellow Shotgun" = "yellow-shotgun"
    "Autumn Trees" = "autumn-trees"
    "Julia Street" = "julia-street"
    "Plantation Stroll" = "plantation-stroll"
    "Bourbon Street" = "bourbon-street"
    "Esplanade Street" = "esplanade-street"
    "Madison Street" = "madison-street"
    "French Quarter" = "french-quarter"
    "Orleans" = "orleans"
    "Jackson Square" = "jackson-square"
    "St. Louis Cathedral" = "st-louis-cathedral"
    "Side Walk Stroll" = "side-walk-stroll"
    "Blue Showers" = "blue-showers"
    "Elisa's House" = "elisas-house"
    "Rainy Day" = "rainy-day"
    "Woods" = "woods"
}

$galleryFile = "gallery.html"
$content = Get-Content $galleryFile -Raw

Write-Host "Iniciando correccion de enlaces Shop This..." -ForegroundColor Yellow

$replacements = 0

foreach ($productName in $productMappings.Keys) {
    $productId = $productMappings[$productName]
    
    # Buscar el patron especifico para este producto
    $pattern = 'data-name="' + [regex]::Escape($productName) + '"[\s\S]*?<a class="btn btn-xs btn-success" href="/shop\.html">Shop This</a>'
    
    if ($content -match $pattern) {
        # Reemplazar con el enlace correcto
        $replacement = $matches[0] -replace 'href="/shop\.html"', "href=""/shop.html?product=$productId"""
        $content = $content -replace [regex]::Escape($matches[0]), $replacement
        $replacements++
        Write-Host "Corregido: $productName -> $productId" -ForegroundColor Green
    } else {
        Write-Host "No encontrado: $productName" -ForegroundColor Red
    }
}

# Guardar el archivo
Set-Content $galleryFile $content -Encoding UTF8

Write-Host "Completado! Se corrigieron $replacements enlaces." -ForegroundColor Cyan
Write-Host "Archivo actualizado: $galleryFile" -ForegroundColor Cyan
