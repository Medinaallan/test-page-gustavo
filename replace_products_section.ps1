# Script para reemplazar la sección de productos en shop.html
$shopContent = Get-Content "shop.html" -Raw
$cleanProducts = Get-Content "clean_products.html" -Raw

# Encontrar el inicio de la sección de productos
$startPattern = '<!-- Shop Grid View-->\s*<div class="range range-xs-center">\s*<!-- Nouvelle Bleu -->'
$endPattern = '</div>\s*</div>\s*</div>\s*</main>'

$startMatch = [regex]::Match($shopContent, $startPattern)
$endMatch = [regex]::Match($shopContent, $endPattern)

if ($startMatch.Success -and $endMatch.Success) {
    # Construir el nuevo contenido
    $beforeProducts = $shopContent.Substring(0, $startMatch.Index)
    $afterProducts = $shopContent.Substring($endMatch.Index)
    
    # Crear la nueva sección de productos
    $newProductsSection = @"
<!-- Shop Grid View-->
              <div class="range range-xs-center">$cleanProducts
              </div>
            </div>
        </div>
      </main>
"@
    
    # Combinar todo
    $newShopContent = $beforeProducts + $newProductsSection + $afterProducts.Substring($endMatch.Length)
    
    # Guardar el nuevo archivo
    $newShopContent | Out-File "shop_with_all_products.html" -Encoding UTF8
    
    Write-Host "Nuevo shop.html creado con todos los productos"
    
} else {
    Write-Host "No se encontraron los patrones de inicio o fin"
    Write-Host "Start found: $($startMatch.Success)"
    Write-Host "End found: $($endMatch.Success)"
}

# Verificar el número de productos en el nuevo archivo
if (Test-Path "shop_with_all_products.html") {
    $productCount = (Get-Content "shop_with_all_products.html" | Select-String 'class="product-card"').Count
    Write-Host "Productos en el nuevo archivo: $productCount"
}
