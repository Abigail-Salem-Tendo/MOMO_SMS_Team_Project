# Team DevStrike

## Project Description
This project processes MoMo SMS data provided in XML format. The system extracts, cleans, and categorizes transaction data, stores it in a relational database, and presents analytics through a simple frontend dashboard.

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

#### REST API

#### Authentication and security 


#### Data structures and Algorithms 


#### Testing 



## System Architecture

- the diagram below shows how raw MoMo SMS XML data is processed through multiple ETL stages, stored in a relational database, and visualized through a web-based dashboard.

Architecture diagram: https://drive.google.com/file/d/1vIbDJC-reycJXF7FDjH24iFLt8KMcxBq/view?usp=sharing


## Scrum Board
Project board: https://trello.com/b/A1phIJrH/devstrike

link to the task sheet 
https://docs.google.com/spreadsheets/d/1xv2X56_YN_ZU_v4iM236iwAVSosTLOHUO1d4qKlY998/edit?usp=sharing




