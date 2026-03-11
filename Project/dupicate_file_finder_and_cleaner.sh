#!/bin/bash

# Simple Duplicate File Finder
# No complex features, just basic functionality

echo "==================================="
echo "Simple Duplicate File Finder"
echo "==================================="

# Ask for directory to scan
echo "Enter directory to scan (e.g., /home/user or . for current):"
read SCAN_DIR

if [ ! -d "$SCAN_DIR" ]; then
    echo "Error: Directory does not exist!"
    exit 1
fi

echo "Scanning $SCAN_DIR for duplicate files..."
echo ""

# Create temp files
TEMP_DIR="/tmp/duplicate_finder_$$"
mkdir -p "$TEMP_DIR"
SIZE_FILE="$TEMP_DIR/sizes.txt"
HASH_FILE="$TEMP_DIR/hashes.txt"
DUPLICATE_FILE="$TEMP_DIR/duplicates.txt"

# Step 1: Find all files and their sizes
echo "Step 1: Finding all files..."
find "$SCAN_DIR" -type f -readable 2>/dev/null | while read file; do
    size=$(stat -c %s "$file" 2>/dev/null)
    echo "$size|$file" >> "$SIZE_FILE"
done

total_files=$(wc -l < "$SIZE_FILE")
echo "Found $total_files files"
echo ""

# Step 2: Find files with same size
echo "Step 2: Looking for files with same size..."
cut -d'|' -f1 "$SIZE_FILE" | sort | uniq -d > "$TEMP_DIR/duplicate_sizes.txt"

size_count=$(wc -l < "$TEMP_DIR/duplicate_sizes.txt")
echo "Found $size_count file sizes that have duplicates"
echo ""

# Step 3: For each duplicate size, check if files are identical
echo "Step 3: Checking MD5 hashes..."

# Clear hash file
> "$HASH_FILE"

# Process each size that has duplicates
while read size; do
    # Find all files with this size
    grep "^$size|" "$SIZE_FILE" | cut -d'|' -f2- > "$TEMP_DIR/files_with_size_$size.txt"
    
    # Calculate MD5 for each file
    while read file; do
        if [ -f "$file" ]; then
            md5=$(md5sum "$file" | cut -d' ' -f1)
            echo "$md5|$file" >> "$HASH_FILE"
        fi
    done < "$TEMP_DIR/files_with_size_$size.txt"
done < "$TEMP_DIR/duplicate_sizes.txt"

# Step 4: Find duplicate hashes
echo "Step 4: Identifying duplicate files..."
cut -d'|' -f1 "$HASH_FILE" | sort | uniq -d > "$TEMP_DIR/duplicate_hashes.txt"

duplicate_count=$(wc -l < "$TEMP_DIR/duplicate_hashes.txt")
echo "Found $duplicate_count groups of duplicate files"
echo ""

# Step 5: Display results
echo "==================================="
echo "DUPLICATE FILES FOUND:"
echo "==================================="

group_num=1
total_duplicates=0
total_space=0

while read hash; do
    echo ""
    echo "Group $group_num (Hash: $hash):"
    
    # Find all files with this hash
    grep "^$hash|" "$HASH_FILE" | cut -d'|' -f2- > "$TEMP_DIR/group_$group_num.txt"
    
    file_count=0
    while read file; do
        file_count=$((file_count + 1))
        echo "  $file"
    done < "$TEMP_DIR/group_$group_num.txt"
    
    # Get file size
    first_file=$(head -1 "$TEMP_DIR/group_$group_num.txt")
    if [ -f "$first_file" ]; then
        size=$(stat -c %s "$first_file")
        size_hr=$(numfmt --to=iec "$size" 2>/dev/null || echo "$size bytes")
        echo "  Each file size: $size_hr"
        echo "  Total files: $file_count"
        
        total_duplicates=$((total_duplicates + file_count))
        wasted=$((size * (file_count - 1)))
        total_space=$((total_space + wasted))
    fi
    
    group_num=$((group_num + 1))
done < "$TEMP_DIR/duplicate_hashes.txt"

echo ""
echo "==================================="
echo "SUMMARY:"
echo "Total duplicate groups: $((group_num - 1))"
echo "Total duplicate files: $total_duplicates"
total_space_hr=$(numfmt --to=iec "$total_space" 2>/dev/null || echo "$total_space bytes")
echo "Total wasted space: $total_space_hr"
echo "==================================="

# Ask if user wants to delete
if [ $((group_num - 1)) -gt 0 ]; then
    echo ""
    echo "Do you want to delete duplicates? (yes/no)"
    read DELETE_ANSWER
    
    if [ "$DELETE_ANSWER" = "yes" ]; then
        echo ""
        echo "Deleting duplicates..."
        deleted=0
        freed=0
        
        for i in $(seq 1 $((group_num - 1))); do
            group_file="$TEMP_DIR/group_$i.txt"
            
            # Keep first file, delete rest
            keep_file=$(head -1 "$group_file")
            echo "Keeping: $keep_file"
            
            # Delete remaining files
            tail -n +2 "$group_file" | while read file; do
                if [ -f "$file" ]; then
                    size=$(stat -c %s "$file")
                    rm "$file"
                    echo "  Deleted: $file"
                    deleted=$((deleted + 1))
                    freed=$((freed + size))
                fi
            done
        done
        
        freed_hr=$(numfmt --to=iec "$freed" 2>/dev/null || echo "$freed bytes")
        echo ""
        echo "Deleted $deleted files"
        echo "Freed $freed_hr"
    else
        echo "No files deleted"
    fi
fi

# Cleanup
echo ""
echo "Cleaning up..."
rm -rf "$TEMP_DIR"
echo "Done!"