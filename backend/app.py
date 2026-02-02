from flask import Flask, jsonify, request, abort
import pymysql
import os
from dotenv import load_dotenv

# load the configuration file
load_dotenv()

app = Flask(__name__)

# Secure database connection 
def get_db_connection():
    return pymysql.connect(
        host=os.getenv('DB_HOST'),
        user=os.getenv('DB_USER'),
        password=os.getenv('DB_PASSWORD'),
        db=os.getenv('DB_NAME'),
        port=int(os.getenv('DB_PORT', 3306)),
        cursorclass=pymysql.cursors.DictCursor
    )

