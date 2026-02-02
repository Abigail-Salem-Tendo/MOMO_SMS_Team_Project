API REPORT

DOCUMENTATION OF ENDPOINTS
(TESTS OF THESE ENDPOINTS HAVE BEEN UPLOADED IN THE FORM OF IMAGES)
1. Retrieval Endpoints (Read)GET /list-transactions
Description: Returns a full list of all transactions in the system. It joins four tables (transactions, transaction_categories, and users twice) to provide a complete human-readable overview.
Success Response: 200 OK
Key Fields Returned: * sender & receiver: The actual names of the parties involved.
transaction_category: The descriptive name of the category (e.g., "Airtime").
raw_message: The original SMS content for verification.
GET /transaction-details/<int:transaction_id>
Description: Retrieves every detail of a specific transaction using its unique primary key.
Success Response: 200 OK
Error Response: 404 Not Found if the transaction ID does not exist.
2. Creation Endpoint (Create)POST /create-transaction
Description: Processes a new transaction. This endpoint does not create new users; instead, it maps the transaction to existing sender_id and receiver_id found in the users table then also the maps category_id  that exists and found in the transaction_categories 
.
Request Body (JSON):
JSON
{
  "external_ref_id": "16803066185",
  "transaction_date": "2024-11-12 23:47:47",
  "amount": 5000.00,
  "category_id": 4,
  "sender_id": 1,
  "receiver_id": 12,
  "status": "FAILED",
  "raw_message": "...SMS Body..."
}
Database Logic: 1.  Inserts into transactions table.
2.  Creates two entries in user_transactions (one for the SENDER, one for the RECEIVER).
Success Response: 201 Created
3. Update Endpoint (Update)PUT /update-transaction/<int:tx_id>
Description: Updates the audit trail for a specific transaction. This is used to change the generic failure message to a specific business reason (e.g., "Airtime Loan") and update the log level.
Request Body (JSON):
JSON
{
  "log_level": "ERROR",
  "status": "FAILED",
  "message": "Failed due to an airtime loan that isn't paid yet"
}
Database Logic: Updates the status, log_level, and message columns in the system_logs table for the matching transaction_id.
Success Response: 200 OK
4. Deletion Endpoint (Delete)DELETE /delete-transaction/<int:tx_id>
Description: Completely removes a transaction and all its associated data.
Referential Integrity Logic: To avoid Foreign Key constraint errors, the API deletes records in this specific order:
Delete from system_logs.
Delete from user_transactions (removes the mappings to users).
Delete from transactions (the parent record).
Success Response: 200 OK
Error Response: 404 Not Found if the transaction ID does not exist.