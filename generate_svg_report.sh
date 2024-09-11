#!/bin/bash

# Directory containing the SVG files
SVG_DIR="generated_logos"

# Output HTML file
HTML_REPORT="logo_variations_report.html"

# Start the HTML file
cat << EOF > "$HTML_REPORT"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Logo Color Variations Report</title>
    <style>
        body { 
            font-family: Arial, sans-serif; 
            margin: 20px; 
            background-color: #f0f0f0;
        }
        h1 { 
            color: #333; 
            text-align: center;
        }
        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
            gap: 20px;
            padding: 20px;
        }
        .card {
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            overflow: hidden;
            transition: transform 0.3s ease;
        }
        .card:hover {
            transform: translateY(-5px);
        }
        .card img {
            width: 100%;
            height: 200px;
            object-fit: contain;
            background-color: #f8f8f8;
        }
        .card-content {
            padding: 15px;
        }
        .variation-name {
            font-weight: bold;
            margin-bottom: 10px;
        }
        .color-box {
            display: inline-block;
            width: 20px;
            height: 20px;
            margin-right: 5px;
            vertical-align: middle;
            border: 1px solid #ddd;
        }
    </style>
</head>
<body>
    <h1>Logo Color Variations Report</h1>
    <div class="grid">
EOF

# Function to extract colors from SVG file
extract_colors() {
    local file=$1
    local color1=$(sed -n 's/.*\.fill-black { fill: \(#[0-9A-Fa-f]\{6\}\).*/\1/p' "$file")
    local color2=$(sed -n 's/.*\.fill-grey { fill: \(#[0-9A-Fa-f]\{6\}\).*/\1/p' "$file")
    local color3=$(sed -n 's/.*\.stroke-white { stroke: \(#[0-9A-Fa-f]\{6\}\).*/\1/p' "$file")
    echo "$color1 $color2 $color3"
}

# Loop through all SVG files in the directory
for file in "$SVG_DIR"/*.svg; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        variation="${filename%.*}"
        
        # Extract colors
        read -r color1 color2 color3 <<< $(extract_colors "$file")
        
        # Add a card to the grid
        cat << EOF >> "$HTML_REPORT"
        <div class="card">
            <img src="$file" alt="$variation">
            <div class="card-content">
                <div class="variation-name">$variation</div>
                <div><span class="color-box" style="background-color: $color1;"></span>$color1</div>
                <div><span class="color-box" style="background-color: $color2;"></span>$color2</div>
                <div><span class="color-box" style="background-color: $color3;"></span>$color3</div>
            </div>
        </div>
EOF
    fi
done

# Close the HTML file
cat << EOF >> "$HTML_REPORT"
    </div>
</body>
</html>
EOF

echo "HTML report generated: $HTML_REPORT"
echo "Open this file in a web browser to view all variations."