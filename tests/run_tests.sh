curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "$curr_dir/init.sh"

files=$( find "$TESTS" -name "test_*" -type f )
for file in "$files "; do
    bash -c "$file"
done
