import random
import string
import os
import csv
import time
from locust import HttpUser, task, constant_throughput, events
from urllib.parse import quote
import gevent
import locust.stats


locust.stats.CSV_STATS_INTERVAL_SEC = 0.5  # Adjust this as needed for more frequent updates
locust.stats.CSV_STATS_FLUSH_INTERVAL_SEC = 2  # Determines how often the data is flushed to disk


# Environment variables
EXECUTION_TIME = int(os.getenv("TEST_EXECUTION_TIME", 10))  # execution time in seconds
TARGET_REQ_AMOUNT = int(os.getenv("REQ_AMOUNT", 1))
REQUEST_PATH = os.getenv("REQUEST_PATH", "/api/test")
TEST_APPLICATION = os.getenv("TEST_APPLICATION", "camelcase")
THREAD_COUNT = int(os.getenv("NUM_USERS", 1))
TEST_TYPE = os.getenv("TEST_TYPE", "continuous")
CSV_SENTENCES_FILE = os.getenv("CSV_SENTENCES_FILE", "./test_sentences.csv")
HOST = os.getenv("HOST", "http://localhost:8080")
def log_test_configuration():
    log_message = (
        f"Executing load test with the following configuration:\n"
        f"- Test Execution Time: {EXECUTION_TIME} seconds\n"
        f"- Target Request Amount: {TARGET_REQ_AMOUNT}\n"
        f"- Request Path: {REQUEST_PATH}\n"
        f"- Test Application: {TEST_APPLICATION}\n"
        f"- Thread Count: {THREAD_COUNT}\n"
        f"- Test Type: {TEST_TYPE}\n"
        f"- CSV Sentences File: {CSV_SENTENCES_FILE}\n"
        f"- Host: {HOST}\n"
    )
    print(log_message)
HEADERS = {
            "User-Agent": "curl/8.1.2",
            "Accept": "*/*"
}
start_time = time.time()  

class TestUser(HttpUser):
    sentences = []
    host = HOST

    def on_start(self):
        # Load sentences from CSV
        with open(CSV_SENTENCES_FILE, mode='r') as file:
            reader = csv.reader(file)
            # URL-encode each sentence as it's read from the file
            self.sentences = [quote(row[0]) for row in reader]  
        print(f"Loaded {len(self.sentences)} sentences.")

    def wait_time(self):
        if TEST_TYPE == "continuous":
            throughput_per_user = TARGET_REQ_AMOUNT / (EXECUTION_TIME * THREAD_COUNT)
            # Create the callable and then immediately call it
            wait_function = constant_throughput(throughput_per_user)
            print(f"throughput: {throughput_per_user}")
            return wait_function(self)
        else:
            # For load test, return a very small or zero wait time
            return 0



    def param(self):
        if TEST_APPLICATION == "camelcase":
            return f"?text={random.choice(self.sentences)}"
        else:
            return f"?number={random.randint(99999, 999999)}"

    @task
    def perform_task(self):
        if TEST_TYPE == "continuous":
            self.execute_continuous_task()
        else:
            self.execute_load_task()
        

    def execute_continuous_task(self):
        fullRequestPath = REQUEST_PATH + self.param()
        print(f"Sending request to {fullRequestPath}")
        self.client.get(fullRequestPath,headers=HEADERS, timeout=30)

    def execute_load_task(self):
        # Send requests in a while loop for load test
        request_count = 0
        while request_count < max(1,TARGET_REQ_AMOUNT/THREAD_COUNT):
            fullRequestPath = REQUEST_PATH + self.param()
            fullURL = self.host + fullRequestPath
            print(f"Sending request to {fullURL}")
            self.client.get(fullRequestPath,headers=HEADERS, timeout=30)
            request_count += 1
        print(f"Sent {request_count} requests.")
        time.sleep(EXECUTION_TIME)
        # time_to_sleep = max(0, EXECUTION_TIME - (time.time() - start_time))
        # time.sleep(time_to_sleep)


@events.request.add_listener
def my_request_handler(request_type, name, response_time, response_length, response,
                       context, exception, start_time, url, **kwargs):
    if exception:
        print(f"Request to {name} failed with exception {exception}")
    else:
        print(f"Successfully made a request to: {name}")
        print(f"The response was {response.text}")


# Print test configuration log
log_test_configuration()


