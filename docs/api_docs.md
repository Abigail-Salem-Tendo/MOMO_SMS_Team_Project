MoMo Transactions API – Security & Endpoint Report

Introduction to API Security

For the MoMo Transactions API, security is not optional — it is a core requirement.

The system handles sensitive financial data, including:

User balances

Personally Identifiable Information (PII)

Transaction history

Without proper safeguards, these endpoints would be vulnerable to:

Unauthorized data scraping

Data manipulation

Fraudulent activity

To mitigate these risks, the application implements a middleware-based security model using HTTP Basic Authentication.




Security Architecture (Middleware Gatekeeper)

Authentication is enforced through a require_auth decorator that acts as a gatekeeper for all protected routes.

How it works
1. Interception

Every request to protected endpoints (e.g., /transactions) is intercepted before reaching the core business logic.

2. Validation

The middleware:

Extracts the Authorization header

Decodes Base64 credentials

Validates them against secure environment variables stored in .env

Avoids hardcoded credentials

3. Enforcement

If credentials are missing or invalid:
401 Unauthorized
The request is immediately rejected.

Only authenticated administrators can access or modify transaction data.

API Endpoint Documentation

Tests for all endpoints are available as screenshots in the repository.

Retrieval Endpoints (READ)
GET /list-transactions

Description
Returns a complete list of all transactions.

Database Join

transactions

transaction_categories

users (joined twice for sender and receiver)

Response: 200 OK

Key fields returned

sender – sender name

receiver – receiver name

transaction_category – category description (e.g., Airtime)

raw_message – original SMS content for verification

GET /transaction-details/<transaction_id>

Description
Retrieves full details of a specific transaction.

Responses

200 OK – found

404 Not Found – invalid transaction ID

Creation Endpoint (CREATE)
POST /create-transaction

Description
Creates a new transaction using existing users and categories.

⚠️ Does not create new users.

Request Body (JSON)
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

Database Logic

Insert into transactions

Insert two rows into user_transactions

SENDER mapping

RECEIVER mapping

Response: 201 Created

Update Endpoint (UPDATE)
PUT /update-transaction/<tx_id>

Description
Updates the audit trail and system logs for a transaction.

Used to:

Modify failure reasons

Change log levels

Update status messages

Request Body (JSON)
{
  "log_level": "ERROR",
  "status": "FAILED",
  "message": "Failed due to an airtime loan that isn't paid yet"
}
Database Logic

Updates the following fields in system_logs:

status

log_level

message

Response: 200 OK

Deletion Endpoint (DELETE)
DELETE /delete-transaction/<tx_id>

Description
Permanently removes a transaction and all related data.

Referential Integrity Strategy

To prevent foreign key errors, deletion occurs in this order:

Delete from system_logs

Delete from user_transactions

Delete from transactions

Responses

200 OK – deleted

404 Not Found – transaction not found

⚠️ Basic Authentication Limitations

While HTTP Basic Authentication blocks casual unauthorized access, it should be considered minimum viable security.

For financial systems, it introduces serious risks.

Limitations
1. Credential Interception Risk

Credentials are only Base64 encoded (not encrypted).
Without HTTPS, they can be easily decoded via network sniffing (MITM attacks).

2. High Attack Surface

Passwords are sent with every request, increasing compromise probability.

3. No Granular Permissions

Basic Auth is binary:

Admin

Not admin

Cannot support roles like:

Auditor (read-only)

Operator (write-only)

4. No Session Revocation

Cannot log out or revoke a compromised session without changing the system password.

🚀 Recommended Upgrade
Modern Alternatives
OAuth 2.0

Best for third-party delegated access
(e.g., “Login with Google”)

JSON Web Tokens (JWT)

Stateless, token-based authentication

Recommendation: Adopt JWT

JWT is the most suitable next step for this API.

Why JWT?
Stateless Scalability

No DB lookup per request

Token validated cryptographically

Lower latency and server load

Reduced Credential Exposure

Password sent only once at login

Temporary tokens expire automatically (e.g., 15 min)

Embedded Permissions

JWT payload can include:
{
  "role": "admin",
  "permissions": ["read", "write"]
}

This enables instant role-based authorization without extra queries.

Summary

Current State:

Middleware protection

Basic Auth

Secure environment variables




DSA COMPARISON
Data Structures & Algorithms (DSA Integration)
Overview:
The purpose of this analysis was to compare the efficiency of two data handling methods: Linear Search and Dictionary Search (Hash-Map Indexing). This was done to ensure that the system can handle large volumes of transaction data without performance degradation.

We used a dataset of over 1600 parsed transactions, and to get good results, we conducted a test by searching for the same record 100,000 times. To simulate the worst-case scenario, where algorithms are most heavily tested, we searched for the last record in the dataset.

Comparative results;

Method              Complexity     Total Time (100000 runs)   Performance
Linear Search          O(n)            ~10.69s                Inefficient for Large data
Dictionary Search      O(1)            ~0.02s                 More optimized for large datasets


Key Findings
Linear Search (O(n)): The execution time of approximately 10secons shows the inefficiency of iterating through lists for every request. As a dataset grows, the search time will increase linearly, which has the potential to cause API timeouts.
Dictionary Search (O(n)): By pre-indexing IDs into a Hash Map, we were able to retrieve information almost immediately. The search time remains constant regardless of whether the dataset contains 20 records or 10000 records.
Conclusion
Based on these results, we implemented the dictionary-based lookup for all the transaction retrieval endpoints. This ensures that the application provides a seamless user experience by maintaining high speed as the transactions grow over time.
