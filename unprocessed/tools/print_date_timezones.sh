#!/bin/bash
# This script prints a date in multiple time zones.
# This could be done better/fancier with Python and Babel maybe? Or maybe look into Ruby i18n? I dunno. It'd be nice for it to print in the locale's language and format.

input_date=${1:-'now'}

timezones=(
    "America/Los_Angeles"
    "America/Phoenix"
    "America/Chicago"
    "America/New_York"
    "Etc/UTC"
    "Asia/Kolkata"
    )

for timezone in "${timezones[@]}"; do
  local_date=$(TZ="$timezone" date -d "$input_date")
  echo "${local_date} ${timezone}"
done
