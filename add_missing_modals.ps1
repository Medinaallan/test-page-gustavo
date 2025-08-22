# Script para generar todos los modales faltantes
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

Write-Host "Modales requeridos: $($modalIds.Count)"

# Verificar qué modales ya existen
$existingModals = @()
$existingPattern = 'id="([^"]*-modal)"'
$existingMatches = [regex]::Matches($shopContent, $existingPattern)

foreach ($match in $existingMatches) {
    $existingId = $match.Groups[1].Value
    if ($existingModals -notcontains $existingId) {
        $existingModals += $existingId
    }
}

Write-Host "Modales existentes: $($existingModals.Count)"

# Encontrar modales faltantes
$missingModals = @()
foreach ($modalId in $modalIds) {
    if ($existingModals -notcontains $modalId) {
        $missingModals += $modalId
    }
}

Write-Host "Modales faltantes: $($missingModals.Count)"

# Generar HTML para modales faltantes
$newModalsHtml = ""

foreach ($modalId in $missingModals) {
    $productName = ($modalId -replace '-modal', '' -replace '-', ' ').ToLower()
    $productName = (Get-Culture).TextInfo.ToTitleCase($productName)
    
    $modalHtml = @"

    <!-- $productName Modal -->
    <div id="$modalId" class="modal">
      <div class="modal-content">
        <span class="close" onclick="closeModal('$modalId')">&times;</span>
        <div class="modal-product">
          <div class="modal-product-image">
            <img src="images/placeholder.jpg" alt="$productName">
          </div>
          <div class="modal-product-info">
            <h3 class="modal-product-title">$productName</h3>
            
            <div class="responsive-tabs-classic">
              <ul class="resp-tabs-list">
                <li class="resp-tab-active" onclick="showTab(this, '$($modalId.Replace('-modal', ''))-desc')">Description</li>
                <li onclick="showTab(this, '$($modalId.Replace('-modal', ''))-shipping')">Shipping Options</li>
                <li onclick="showTab(this, '$($modalId.Replace('-modal', ''))-delivery')">Delivery & Returns</li>
              </ul>
              
              <div class="resp-tabs-container">
                <div id="$($modalId.Replace('-modal', ''))-desc" class="resp-tab-content-active">High-quality canvas print of $productName artwork. Professional grade printing with vibrant colors and sharp details.</div>
                <div id="$($modalId.Replace('-modal', ''))-shipping" class="resp-tab-content">
                  <p><strong>Standard Shipping:</strong> 5-7 business days - `$8.00</p>
                  <p><strong>Express Shipping:</strong> 2-3 business days - `$15.00</p>
                </div>
                <div id="$($modalId.Replace('-modal', ''))-delivery" class="resp-tab-content">
                  <p><strong>Returns:</strong> 30-day return policy</p>
                  <p><strong>Delivery:</strong> Carefully packaged to prevent damage</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
"@
    $newModalsHtml += $modalHtml
}

# Encontrar donde insertar los nuevos modales (antes del final del body)
$insertPoint = $shopContent.LastIndexOf("</body>")

if ($insertPoint -gt 0) {
    $newShopContent = $shopContent.Substring(0, $insertPoint) + $newModalsHtml + "`r`n  " + $shopContent.Substring($insertPoint)
    
    # Guardar el archivo actualizado
    $newShopContent | Out-File "shop_with_modals.html" -Encoding UTF8
    
    Write-Host "Archivo actualizado con todos los modales guardado como shop_with_modals.html"
} else {
    Write-Host "No se pudo encontrar el punto de inserción"
}

Write-Host ""
Write-Host "Modales faltantes que se agregaron:"
foreach ($modal in $missingModals) {
    Write-Host "- $modal"
}
