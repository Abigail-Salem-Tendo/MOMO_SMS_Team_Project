"""
This is a script that will compare the different times of
linear search and dictionary search
"""
import time
from xml_parsing import parse_sms_xml

#the sample data set goes here;

#Linear search method
def linear_search(transaction_list, target_id):
    """This function searches for a transaction using its id"""
    for transaction in transaction_list:
        if transaction["id"] == target_id:
            return transaction
    return None

#testing
if __name__ == "__main__":
    data = parse_sms_xml("modified_sms_v2.xml")

    #find and id
    if data:
        test_id = data[0]["id"]
        print(f"search for : {test_id}")
        start = time.perf_counter()
        result = linear_search(data, test_id)
        end = time.perf_counter()

        if result:
            print(f"Found Transaction! Body: {result['body'][:50]}...")
            print(f"Time taken: {end - start:.8f}s")