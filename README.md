# Team DevStrike

## Project Description
This project processes MoMo SMS data provided in XML format. The system extracts, cleans, and categorizes transaction data, stores it in a relational database, and presents analytics through a simple frontend dashboard.

The system:
 - parses raw SMS data from an XML file
 - Converts it into structured stransaction records 
 -  Provides CRUD API endpoints to access the data 
 - Secures endpoints using HTTP basic Authentication
 - demonstrates data structure efficiency

The goal is to demonstrate enterprise-level fullstack development skills, including backend data processing, database management, and frontend visualization.

## Team Members
- Liliane Uwase
- Bonane Niyigena
- Abigail Salem Tendo
- Brian Kiguru Mahui
- Maxime Hirwa


### Added features
 
 
  #### Data parsing 
  the data that is provided in an XML file (modified_sms_v2.xml) is parsed and converted into JSON objects using a python script. 
   Each SMS contains transaction details such as: 
   - Transaction type 
   - Amount 
   - Sender 
   - Receiver 
   - Transaction reference ID
   - Timestamp
  
    * set up and runnign the data parser 
      - requirements 
       . python 3 

    steps 
    1. clone the repository using git clone command
    2. cd directory to the repository MOMO_SMS_Team_Project
    3. cd to dsa 
    4. run xml_parsing.py 
       - python3 xml_parsing.py 
    5. after running the file the parsed transaction data will be saved in the parsed_transactions.json file 

## REST API endpoint run instructions
To run the API endpoints, you need to first have;
### 1. Prerequisites
- 'Python 3.x'
- 'MySQL 8.x'
- 'Database credentials (Aiven or Local)'

### 2. Install Dependencies
```bash
python -m venv venv
source venv/bin/activate        # Windows: venv\Scripts\activate
pip install flask pymysql python-dotenv
```

### 3. Environment Configuration (.env)

The application reads database credentials from a .env file using python-dotenv. This .env is to be created in the root of the respository
Required Environment Variables
```bash
DB_HOST="host"
DB_PORT="port-number"
DB_USER="username"
DB_PASSWORD="password"
DB_NAME="database name"
```

### 4. Starting the application
```bash
cd backend
python app.py
```
The application will start on:
```bash
http://127.0.0.1:5000
```

### Using curl or Postman or any other tool for API testing
Here are the ednpoints;
- GET /list-transactions → list all transactions

- GET /transaction-details/{id} → view one transaction details

- POST /create-transaction → add a new transaction

- PUT /update-transaction/{id} → update an existing record

- DELETE /delete-transaction/{id} → delete a record.
 

#### Authentication and security 

All API endpoints are protected using HTTP Basic Authentication 
for more detailed explained checkout the documentation file in docs/api_docs.md

#### Data structures and Algorithms 
to ensure that our system remains scalable as transaction volume grows, we implemented a performance test to compare the search efficiencies of linear and optimized data structures.
- Linear search (O(n)): This iterates through the transaction list. The performance degrades as the dataset size increases.
- Dictionary Lookup (O(1)): This method implements a Hash Map to jump directly to the data using its ID, ensuring constant-time performance regardless of the dataset size.

##### Steps to run the comparison
1. Ensure the data exists by running the parser

2. In the dsa directory run the comparison script: 

    `python3 dsa_comparison.py`

3. The results will display the total execution time for both methods, proving the efficiency of the O(1) approach


#### Testing 
the API can be tested using:
 . Postman 
 . curl 
 
screenshots of requests are available in the screenshots directory


## System Architecture

- the diagram below shows how raw MoMo SMS XML data is processed through multiple ETL stages, stored in a relational database, and visualized through a web-based dashboard.

Architecture diagram: https://drive.google.com/file/d/1vIbDJC-reycJXF7FDjH24iFLt8KMcxBq/view?usp=sharing


## Scrum Board
Project board: https://trello.com/b/A1phIJrH/devstrike

. link to the task sheet for Database Design and implemementation assignment
https://docs.google.com/spreadsheets/d/1xv2X56_YN_ZU_v4iM236iwAVSosTLOHUO1d4qKlY998/edit?usp=sharing 
 
. link to the task sheet for Building and Securing a rest API Assignment 
https://docs.google.com/spreadsheets/d/1OLwYX9TlVBnChjtfsYgVIoET9MHnx9YxS-ybb8BZQt0/edit?usp=sharing






