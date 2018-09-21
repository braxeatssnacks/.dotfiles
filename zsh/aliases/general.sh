function superscript_number {
  NUMBERS=(⁰ ¹ ² ³ ⁴ ⁵ ⁶ ⁷ ⁸ ⁹)
  input=$1
  output=""
  for (( i=0; i<${#input}; i++ )); do
    char="${input:$i:1}"
    arr_index=$((char + 1))
    output="${output}${NUMBERS[$arr_index]}"
  done
  echo $output
}
