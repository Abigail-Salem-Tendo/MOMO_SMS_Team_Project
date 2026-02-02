"""
This is a script that will compare the different times of
linear search and dictionary search
"""
import time

#the sample data set goes here;

#Linear search method
def linear_search(transaction_list, target_id):
    """This function searches for a transaction using its id"""
    for transaction in transaction_list:
        if transaction["id"] == target_id:
            return transaction
    return None