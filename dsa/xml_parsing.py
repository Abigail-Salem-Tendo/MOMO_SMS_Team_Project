""" 
parsing the xml file in python
convert sms records from xml to list of dictionaries
"""

import xml.etree.ElementTree as ET


def parse_sms_xml(file_path):
    tree = ET.parse(file_path)
    root = tree.getroot()
    transactions = []

    for sms in root.findall("sms"):
        transaction = {
            "id": sms.get("date"),
            "sender": sms.get("address"),
            "body": sms.get("body"),
            "readable_date": sms.get("readable_date")
        }
        transactions.append(transaction)
    return transactions
    #
    # for sms in root.findall("sms"):
    #     transaction = {
    #         "id": int(sms.find("id").text),
    #         "type": sms.find("type").text,
    #         "amount": int(sms.find("amount").text),
    #         "sender": sms.find("sender").text,
    #         "receiver": sms.find("receiver").text,
    #         "timestamp": sms.find("timestamp").text
    #     }
    #     transactions.append(transaction)
    #
    # return transactions

if __name__ == "__main__":
    data = parse_sms_xml("modified_sms_v2.xml")
    for record in data:
        print(record)
        





