import os
import requests
from prometheus_client import start_http_server, Gauge
import time

# Environment variables
RABBITMQ_HOST = os.getenv("RABBITMQ_HOST", "localhost")
RABBITMQ_USER = os.getenv("RABBITMQ_USER", "guest")
RABBITMQ_PASSWORD = os.getenv("RABBITMQ_PASSWORD", "guest")
RABBITMQ_API_URL = f"http://{RABBITMQ_HOST}:15672/api/queues"

# Prometheus metrics
METRICS = {
    "messages": Gauge(
        "rabbitmq_individual_queue_messages",
        "Total number of messages in the queue",
        ["host", "vhost", "name"],
    ),
    "messages_ready": Gauge(
        "rabbitmq_individual_queue_messages_ready",
        "Number of messages ready for delivery",
        ["host", "vhost", "name"],
    ),
    "messages_unacknowledged": Gauge(
        "rabbitmq_individual_queue_messages_unacknowledged",
        "Number of unacknowledged messages",
        ["host", "vhost", "name"],
    ),
}

def fetch_metrics():
    """Fetch metrics from RabbitMQ API and update Prometheus metrics."""
    try:
        response = requests.get(RABBITMQ_API_URL, auth=(RABBITMQ_USER, RABBITMQ_PASSWORD))
        response.raise_for_status()
        queues = response.json()

        for queue in queues:
            host = RABBITMQ_HOST
            vhost = queue["vhost"]
            name = queue["name"]

            METRICS["messages"].labels(host, vhost, name).set(queue.get("messages", 0))
            METRICS["messages_ready"].labels(host, vhost, name).set(queue.get("messages_ready", 0))
            METRICS["messages_unacknowledged"].labels(host, vhost, name).set(queue.get("messages_unacknowledged", 0))

    except Exception as e:
        print(f"Error fetching metrics: {e}")

def main():
    """Main function to start the Prometheus exporter."""
    # Start Prometheus exporter server
    start_http_server(8000)
    print("Prometheus RabbitMQ Exporter started on port 8000")

    # Periodically fetch metrics
    while True:
        fetch_metrics()
        time.sleep(15)

if __name__ == "__main__":
    main()
