#!/bin/bash

# Create crazy folder with random files and subfolders (with nested contents)

target_dir="$(pwd)/crazy_folder"
mkdir -p "$target_dir"
cd "$target_dir" || exit 1

# Set locale to avoid illegal byte issues on macOS
export LC_CTYPE=C
export LANG=C

# Use shuf or fallback to gshuf
SHUF_CMD=$(command -v shuf || command -v gshuf)
if [ -z "$SHUF_CMD" ]; then
  echo "❌ 'shuf' or 'gshuf' not found. Install coreutils (e.g., 'brew install coreutils')"
  exit 1
fi

total_items=250
patterns=("!@#\$%^&*()_" "weird name" "çø∂€_ƒïłę" "über_ßtrang3" "😜🔥_file" "123___***" "__random__\$\$\$")
similar_base="similar_pattern_"
count=0

generate_random_file() {
  local dir=$1
  local name="${similar_base}$($SHUF_CMD -n1 -e x y z X Y Z)_$((RANDOM % 999))"
  local safe_name=$(echo "$name" | tr -d '\n')
  LC_CTYPE=C tr -dc 'A-Za-z0-9!@#$%^&*()_+=' < /dev/urandom | head -c $((RANDOM % 300 + 20)) > "$dir/$safe_name"
}

generate_random_folder_content() {
  local base_dir=$1
  local nested_items=$((RANDOM % 4 + 2))  # 2–5 items inside
  for j in $(seq 1 $nested_items); do
    if (( RANDOM % 2 == 0 )); then
      # Create random file in folder
      generate_random_file "$base_dir"
    else
      # Create nested folder with files
      nested_folder_name="$($SHUF_CMD -n1 -e "${patterns[@]}")_deep_$((RANDOM % 999))"
      mkdir -p "$base_dir/$nested_folder_name"
      generate_random_file "$base_dir/$nested_folder_name"
    fi
  done
}

while (( count < total_items )); do
  if (( RANDOM % 10 < 8 )); then
    # Create file (80% chance)
    if (( RANDOM % 5 == 0 )); then
      name="${similar_base}$($SHUF_CMD -n1 -e a b c d e)_$((RANDOM % 1000))"
    else
      name="$($SHUF_CMD -n1 -e "${patterns[@]}")_$((RANDOM % 100000))"
    fi
    safe_name=$(echo "$name" | tr -d '\n')
    LC_CTYPE=C tr -dc 'A-Za-z0-9!@#$%^&*()_+=' < /dev/urandom | head -c $((RANDOM % 500 + 20)) > "$safe_name"
    ((count++))
  else
    # Create a top-level folder (20% chance)
    folder_name="$($SHUF_CMD -n1 -e "${patterns[@]}")_folder_$((RANDOM % 100000))"
    mkdir "$folder_name"
    generate_random_folder_content "$folder_name"
    ((count++))
  fi
done

echo "✅ Created $total_items top-level crazy files/folders in '$target_dir'"
echo "⚡  Some folders include nested random files and subfolders."
