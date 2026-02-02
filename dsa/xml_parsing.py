import xml.etree.ElementTree as ET
import json
import re
from datetime import datetime
import os

#paths for the files 
script_dir = os.path.dirname(os.path.abspath(__file__)) 
xml_file_path = os.path.join(script_dir, "..", "data", "modified_sms_v2.xml")
json_file_path = os.path.join(script_dir, "..", "data", "parsed_transactions.json")

# ensure that the folder are there 
folder = os.path.dirname(json_file_path)
os.makedirs(folder, exist_ok=True) 

#parse the xml file
tree = ET.parse(xml_file_path)
root = tree.getroot()

transactions = []
transaction_id = 1

for sms in root.findall("sms"):
    body = sms.get("body")
    date = sms.get("date")

    if not body or "transaction id" not in body.lower():
        continue


    tx_id_match = re.search(r"Transaction Id:\s*(\d+)", body, re.IGNORECASE)
    amount_match = re.search(r"(\d+)\s*RWF", body)
    sender_match = re.search(r"from ([A-Za-z\s]+)", body)
    receiver_match = re.search(r"to ([A-Za-z\s]+)", body)
    fee_match = re.search(r"fee[:\s]*(\d+)\s*RWF", body, re.IGNORECASE)
    receiver_number_match = re.search(r"\((\*+[\d]+)\)", body)  # e.g., (*********013)

    if not (tx_id_match and amount_match and sender_match):
        continue

    external_ref = tx_id_match.group(1)
    amount = int(amount_match.group(1))
    sender = sender_match.group(1).strip() if sender_match else "Unknown Sender"
    receiver = receiver_match.group(1).strip() if receiver_match else None
    fee = int(fee_match.group(1)) if fee_match else None
    receiver_number = receiver_number_match.group(1) if receiver_number_match else None


    body_lower = body.lower()
    if "received" in body_lower:
        tx_type = "P2P_RECEIVE"
    elif "paid" in body_lower:
        tx_type = "P2P_SEND"
    elif "withdrawn" in body_lower:
        tx_type = "WITHDRAWAL"
    elif "deposited" in body_lower:
        tx_type = "DEPOSIT"
    elif "airtime" in body_lower:
        tx_type = "AIRTIME_PURCHASE"
    else:
        tx_type = "OTHER"


    transaction_date = datetime.fromtimestamp(int(date) / 1000).strftime("%Y-%m-%dT%H:%M:%S")

    transactions.append({
        "id": transaction_id,
        "external_reference": external_ref,
        "amount": amount,
        "sender": sender,
        "receiver": receiver,
        "fee": fee,
        "receiver_number": receiver_number,
        "type": tx_type,
        "date": transaction_date
    })
    transaction_id += 1


with open(json_file_path, "w") as json_file:
    json.dump(transactions, json_file, indent=4)


if os.path.exists(json_file_path):
    print(f"Transactions have been successfully saved to: {json_file_path}")
    print("Files in this folder:", os.listdir(folder))
else:
    print("File was not saved.")
