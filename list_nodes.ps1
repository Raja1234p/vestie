$json = Get-Content -Path "c:\Users\hp\StudioProjects\Vestie\figma_node_data.json" -Raw -Encoding Unicode | ConvertFrom-Json
foreach ($prop in $json.nodes.psobject.properties) {
    Write-Host "Node Key: $($prop.Name) - Screen Name: $($prop.Value.document.name)"
}
