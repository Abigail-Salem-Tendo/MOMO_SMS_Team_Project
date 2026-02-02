import xml.etree.ElementTree as ET
import json
import re
from datetime import datetime
import os

# path to the files 
script_dir = os.path.dirname(os.path.abspath(__file__))
xml_file_path = os.path.join(script_dir, "..", "data", "modified_sms_v2.xml")
json_file_path = os.path.join(script_dir, "..", "data", "parsed_transactions.json")

# ensure that the folder for the data exists
folder = os.path.dirname(json_file_path)
os.makedirs(folder, exist_ok=True)

# parsing the XML file
tree = ET.parse(xml_file_path)
root = tree.getroot()

transactions = []
transaction_id = 1

for sms in root.findall("sms"):
    body = sms.get("body")
    date = sms.get("date")

    if not body:
        continue

    # getting the external reference (TxId or Transaction Id)
    tx_id_match = re.search(r"(?:TxId|TxID|Transaction Id)[:\s]*([0-9]+)", body, re.IGNORECASE)
    external_ref = tx_id_match.group(1) if tx_id_match else None

    # the transaction amount
    amount_match = re.search(r"([0-9]{1,3}(?:,?[0-9]{3})*|[0-9]+)\s*RWF", body)
    amount = int(amount_match.group(1).replace(",", "")) if amount_match else None

    # the fees imposed on the transaction
    fee_match = re.search(r"fee[:\s]*(\d+)\s*RWF", body, re.IGNORECASE)
    fee = int(fee_match.group(1)) if fee_match else None

    # senderand receiver numbers
    sender_number_match = re.search(r"from\s+(\*?\+?\d+)", body, re.IGNORECASE)
    receiver_number_match = re.search(r"to\s+(\*?\+?\d+)", body, re.IGNORECASE)
    sender_number = sender_number_match.group(1) if sender_number_match else None
    receiver_number = receiver_number_match.group(1) if receiver_number_match else None

    # sender and receiver names
    def extract_name(keyword):
        pattern = rf"{keyword}\s+([A-Za-z\s\.]+)"
        match = re.search(pattern, body)
        if match:
            name_candidate = match.group(1).strip()
            # removing the numbers after the name based on the xml data structure
            name_candidate = re.sub(r"\d+", "", name_candidate).strip()
            return name_candidate if name_candidate else None
        return None

    sender_name = extract_name("from")
    receiver_name = extract_name("to")

    # Transaction Type & Category
    body_lower = body.lower()
    if "received" in body_lower:
        category = "P2P_RECEIVE"
    elif "paid" in body_lower:
        category = "P2P_SEND"
    elif "withdrawn" in body_lower:
        category = "WITHDRAWAL"
    elif "deposited" in body_lower:
        category = "DEPOSIT"
    elif "airtime" in body_lower:
        category = "AIRTIME_PURCHASE"
    else:
        category = "OTHER"

    # Convert timestamp
    transaction_date = datetime.fromtimestamp(int(date) / 1000).strftime("%Y-%m-%dT%H:%M:%S")

    transactions.append({
        "id": transaction_id,
        "external_reference": external_ref,
        "amount": amount,
        "sender_name": sender_name,
        "sender_number": sender_number,
        "receiver_name": receiver_name,
        "receiver_number": receiver_number,
        "fee": fee,
        "category": category,
        "date": transaction_date
    })

    transaction_id += 1

# saving to JSON file
with open(json_file_path, "w") as json_file:
    json.dump(transactions, json_file, indent=4)

# confirmation message
if os.path.exists(json_file_path):
    print(f"Transactions successfully saved to: {json_file_path}")
    print("To view the file, change the directory to the data folder and open parsed_transactions.json")
else:
    print("File was not saved")
  