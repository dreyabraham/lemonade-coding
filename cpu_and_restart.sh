#!/bin/bash

# Service name of Apache
SERVICE_NAME="apache2"

# Threshold for CPU usage
CPU_THRESHOLD=80

# Time interval for monitoring (in seconds)
CHECK_INTERVAL=30

# Function to get average CPU usage over 1 minute
get_cpu_usage() {
  # Extract CPU idle percentage from top command and calculate usage
  CPU_IDLE=$(top -b -n 1 | grep "Cpu(s)" | awk '{print $8}' | cut -d '.' -f 1)
  CPU_USAGE=$((100 - CPU_IDLE))
  echo $CPU_USAGE
}

# Function to restart the Apache service
restart_service() {
  echo "$(date): CPU usage is $CPU_USAGE%, restarting $SERVICE_NAME..."
  sudo systemctl restart $SERVICE_NAME
  if [ $? -eq 0 ]; then
    echo "$(date): Successfully restarted $SERVICE_NAME."
  else
    echo "$(date): Failed to restart $SERVICE_NAME."
  fi
}

# Infinite monitoring loop
while true; do
  CPU_USAGE=$(get_cpu_usage)
  
  # Check if CPU usage exceeds the threshold
  if [ "$CPU_USAGE" -ge "$CPU_THRESHOLD" ]; then
    restart_service
  else
    echo "$(date): CPU usage is $CPU_USAGE%, no action needed."
  fi

  # Wait before checking again
  sleep $CHECK_INTERVAL
done
