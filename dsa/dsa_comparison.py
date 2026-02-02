"""
This is a script that will compare the different times of
linear search and dictionary search
"""
import time
import json
import os

from dsa.xml_parsing import json_file_path

#the sample data set goes here;
json_file_path = os.path.join("..", "data", "parsed_transactions.json")

def load_data():
    with open(json_file_path) as json_file:
        return json.load(json_file)

#Linear search method
def linear_search(transaction_list, target_id):
    """This function searches for a transaction using its id"""
    for transaction in transaction_list:
        if transaction["id"] == target_id:
            return transaction
    return None

#testing the linear search function
if __name__ == "__main__":
    data = load_data()

    #find and id
    if data:
        test_id = data[-1]["id"]
        iterations = 100000
        print(f"search for : {test_id}")

        #testing the linear
        start = time.perf_counter()
        for _ in range(iterations):
            linear_search(data, test_id)
        end = time.perf_counter() - start
        print(f"search : end time: {end:.8f}s")