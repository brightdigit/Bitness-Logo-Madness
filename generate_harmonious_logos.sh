#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status.

# Original SVG file
ORIGINAL_SVG="logo.svg"

# Directory to store generated SVGs
OUTPUT_DIR="generated_logos"

# Ensure the output directory exists
mkdir -p "$OUTPUT_DIR"

# Function to generate a random color
random_color() {
    printf "#%02X%02X%02X" $((RANDOM % 256)) $((RANDOM % 256)) $((RANDOM % 256))
}

# Function to adjust hue (improved version)
adjust_hue() {
    local color=$1
    local adjustment=$2
    local r=$((16#${color:1:2}))
    local g=$((16#${color:3:2}))
    local b=$((16#${color:5:2}))
    
    # Ensure the adjustment is within the valid range
    adjustment=$((adjustment % 256))
    if [ $adjustment -lt 0 ]; then
        adjustment=$((adjustment + 256))
    fi
    
    # Rotate RGB values
    local new_r=$(( (r + adjustment) % 256 ))
    local new_g=$(( (g + adjustment) % 256 ))
    local new_b=$(( (b + adjustment) % 256 ))
    
    printf "#%02X%02X%02X" $new_r $new_g $new_b
}

# Function to generate a harmonious color scheme
generate_color_scheme() {
    local base_color=$(random_color)
    local scheme_type=$((RANDOM % 3))
    local color2 color3
    
    case $scheme_type in
        0)  # Complementary
            color2=$(adjust_hue "$base_color" 128)
            color3="#FFFFFF"  # Keep white for stroke
            echo "Complementary $base_color $color2 $color3"
            ;;
        1)  # Analogous
            color2=$(adjust_hue "$base_color" 30)
            color3=$(adjust_hue "$base_color" -30)
            echo "Analogous $base_color $color2 $color3"
            ;;
        2)  # Triadic
            color2=$(adjust_hue "$base_color" 85)
            color3=$(adjust_hue "$base_color" 170)
            echo "Triadic $base_color $color2 $color3"
            ;;
    esac
}

# Function to check if a color is valid
is_valid_color() {
    [[ $1 =~ ^#[0-9A-Fa-f]{6}$ ]]
}

# Function to get the next available file number
get_next_file_number() {
    local max_number=0
    for file in "$OUTPUT_DIR"/logo_variation_*.svg; do
        if [ -f "$file" ]; then
            number=$(echo "$file" | sed -n 's/.*logo_variation_\([0-9]*\)\.svg/\1/p')
            if [ "$number" -gt "$max_number" ]; then
                max_number=$number
            fi
        fi
    done
    echo $((max_number + 1))
}

# Get the starting counter
counter=$(get_next_file_number)

echo "Starting from variation number $counter"

# Main loop
while true; do
    # Generate new harmonious colors
    read -r scheme_type color1 color2 color3 <<< $(generate_color_scheme)

    # Check if colors are valid
    if ! is_valid_color "$color1" || ! is_valid_color "$color2" || ! is_valid_color "$color3"; then
        echo "Error: Invalid color generated."
        echo "Scheme: $scheme_type"
        echo "Color1: $color1 (Valid: $(is_valid_color "$color1" && echo "Yes" || echo "No"))"
        echo "Color2: $color2 (Valid: $(is_valid_color "$color2" && echo "Yes" || echo "No"))"
        echo "Color3: $color3 (Valid: $(is_valid_color "$color3" && echo "Yes" || echo "No"))"
        continue
    fi

    # Create a new filename
    new_file="${OUTPUT_DIR}/logo_variation_${counter}.svg"

    # Create a new SVG with updated colors
    sed \
        -e "s/\.fill-black { fill: #[0-9A-Fa-f]\{6\}; }/\.fill-black { fill: $color1; }/" \
        -e "s/\.fill-grey { fill: #[0-9A-Fa-f]\{6\}; }/\.fill-grey { fill: $color2; }/" \
        -e "s/\.stroke-white { stroke: #[0-9A-Fa-f]\{6\}; }/\.stroke-white { stroke: $color3; }/" \
        "$ORIGINAL_SVG" > "$new_file"

    # Check if the new file was created and has content
    if [ ! -s "$new_file" ]; then
        echo "Error: Failed to create or populate $new_file"
        exit 1
    fi

    echo "Created new SVG: $new_file"
    echo "$scheme_type scheme with colors: Color1=$color1, Color2=$color2, Stroke=$color3"

    # Display the first few lines of the generated SVG
    head -n 10 "$new_file"

    # Increment the counter
    ((counter++))
done