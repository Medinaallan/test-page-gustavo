# Script simple para crear productos HTML limpios desde gallery.html
$galleryContent = Get-Content "gallery.html" -Raw

# Extraer todos los productos usando data-name como referencia
$namePattern = 'data-name="([^"]*)"'
$dimensionPattern = 'data-dimensions="([^"]*)"'
$imagePattern = 'data-image="([^"]*)"'
$pricePattern = 'data-price="([^"]*)"'

$nameMatches = [regex]::Matches($galleryContent, $namePattern)
$dimensionMatches = [regex]::Matches($galleryContent, $dimensionPattern)
$imageMatches = [regex]::Matches($galleryContent, $imagePattern)
$priceMatches = [regex]::Matches($galleryContent, $pricePattern)

Write-Host "Nombres encontrados: $($nameMatches.Count)"
Write-Host "Dimensiones encontradas: $($dimensionMatches.Count)" 
Write-Host "Imágenes encontradas: $($imageMatches.Count)"
Write-Host "Precios encontrados: $($priceMatches.Count)"

$products = @()
for ($i = 0; $i -lt $nameMatches.Count; $i++) {
    if ($i -lt $dimensionMatches.Count -and $i -lt $imageMatches.Count -and $i -lt $priceMatches.Count) {
        $name = $nameMatches[$i].Groups[1].Value
        $dimensions = $dimensionMatches[$i].Groups[1].Value -replace '&quot;', '"'
        $image = $imageMatches[$i].Groups[1].Value -replace '\.\./', ''
        $price = $priceMatches[$i].Groups[1].Value
        
        $products += @{
            Name = $name
            Dimensions = $dimensions
            Price = $price
            Image = $image
        }
    }
}

Write-Host "Productos procesados: $($products.Count)"

# Generar HTML limpio
$htmlProducts = ""

foreach ($product in $products) {
    $safeId = $product.Name.ToLower() -replace '[^a-z0-9]', '-' -replace '--+', '-'
    $safeName = $product.Name -replace "'", ""
    
    # Determinar si tiene dos tamaños
    $hasTwoSizes = $product.Dimensions -match "&|Two Sizes"
    $safeDimensions = $product.Dimensions -replace '"', '&quot;' -replace '&', '&amp;'
    
    if ($hasTwoSizes) {
        $priceDisplay = "Size 1: `$$($product.Price) | Size 2: `$28.00"
        $buttonHtml = @"
                        <button class="big" onclick="openModal('$safeId-modal')">Details</button>
                        <button class="big" onclick="showDualPriceOptions('$safeName', '$safeDimensions', '$($product.Image)', '$($product.Price)', '28.00', '$priceDisplay')" style="background: linear-gradient(135deg, #ffc439 0%, #ffb700 100%); border: 2px solid #e6a800; color: #003087; flex: 1;">
                          <i class="fab fa-paypal"></i>
                          Choose Size
                        </button>
"@
    } else {
        $priceDisplay = "`$$($product.Price)"
        $buttonHtml = @"
                        <button class="big" onclick="openModal('$safeId-modal')">Details</button>
                        <form target="paypal" action="https://www.paypal.com/cgi-bin/webscr" method="post" class="paypal-form">
                          <button type="submit" class="paypal-button">
                            <i class="fab fa-paypal"></i>
                            Add to Cart
                          </button>
                          <input type="hidden" name="add" value="1">
                          <input type="hidden" name="cmd" value="_cart">
                          <input type="hidden" name="business" value="gustavo54@att.net">
                          <input type="hidden" name="item_name" value="Canvas Print: $safeName ($($product.Dimensions))">
                          <input type="hidden" name="amount" value="$($product.Price)">
                          <input type="hidden" name="shipping" value="8.00">
                          <input type="hidden" name="no_shipping" value="2">
                        </form>
"@
    }
    
    $productHtml = @"
                
                <!-- $($product.Name) -->
                <div class="cell-xs-8 cell-sm-6 cell-lg-4 offset-top-41 offset-md-top-50">
                  <div class="product-card">
                    <div class="product-image">
                      <img class="img-responsive product-image-area" src="$($product.Image)" alt="$($product.Name)"/>
                    </div>
                    <div class="product-info">
                      <div class="product-title offset-top-4 text-primary">$($product.Name)</div>
                      <div class="product-dimensions offset-top-4">$($product.Dimensions)</div>
                      <div class="product-price offset-top-10">$priceDisplay</div>
                      <div class="product-buttons offset-top-15">
$buttonHtml
                      </div>
                    </div>
                  </div>
                </div>
"@
    $htmlProducts += $productHtml
}

# Guardar productos limpios
$htmlProducts | Out-File "clean_products.html" -Encoding UTF8

Write-Host "Productos limpios guardados en clean_products.html"
