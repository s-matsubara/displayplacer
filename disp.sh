#!/usr/bin/env bash

set -e

if ! type "displayplacer" >/dev/null 2>&1; then
  brew tap jakehilborn/jakehilborn
  brew install displayplacer
fi

if ! type "rg" >/dev/null 2>&1; then
  brew install ripgrep
fi

input=$(displayplacer list | tail -n1)

array=()
while IFS= read -r line; do
  array+=("${line}")
done < <(echo "${input}" | rg -oP '"[^"]*"' | sed 's/^"//; s/"$//')

if [ "${#array[@]}" -lt 2 ]; then
  echo "No external display present."
  exit 0
fi

mainInfo=${array[0]}
screenInfo=${array[1]}

mainWidth=$(echo "${mainInfo}" | rg -oP 'res:\K\d+(?=x)')
mainHeight=$(echo "${mainInfo}" | rg -oP 'res:\d+x\K\d+')

screenId=$(echo "${screenInfo}" | rg -oP 'id:\K[0-9A-Fa-f-]+')
screenWidth=$(echo "${screenInfo}" | rg -oP 'res:\K\d+(?=x)')
screenHeight=$(echo "${screenInfo}" | rg -oP 'res:\d+x\K\d+')

if [[ ${mainWidth} -le ${screenWidth} ]]; then
  width=$(((screenWidth-mainWidth)/2))
else
  width=$(((mainWidth-screenWidth)/2))
fi

displayplacer "${mainInfo}" "id:${screenId} res:${screenWidth}x${screenHeight} hz:60 color_depth:8 enabled:true scaling:off origin:(-${width},-${mainHeight}) degree:0"

exit 0
