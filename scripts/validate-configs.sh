#!/bin/bash

# Validate all configurations

validate_butane() {
  local config_file=$1
  if ! butane --strict "$config_file" > /dev/null 2>&1; then
    echo "Validation failed for $config_file"
    return 1
  fi
  echo "Validation succeeded for $config_file"
  return 0
}

validate_all_configs() {
  local config_files=$(find systems -name "*.bu")
  local all_valid=true
  for config_file in $config_files; do
    if ! validate_butane "$config_file"; then
      all_valid=false
    fi
  done
  if [ "$all_valid" = true ]; then
    echo "All configurations are valid."
  else
    echo "Some configurations are invalid."
    exit 1
  fi
}

validate_all_configs
