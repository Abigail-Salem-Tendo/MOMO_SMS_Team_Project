from functools import wraps
from flask import request, jsonify
import base64
import os
from dotenv import load_dotenv

#Basic Authentication implementation 
load_dotenv()

def require_auth(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        auth_header = request.headers.get('Authorization')
        
        # 1. Check if Auth header exists
        if not auth_header:
            return jsonify({"error": "Unauthorized", "message": "Authentication required"}), 401
        
        try:
            # 2. Decoding credentials
            auth_type, encoded_creds = auth_header.split(" ")
            if auth_type != "Basic":
                raise ValueError
            
            decoded_bytes = base64.b64decode(encoded_creds)
            decoded_str = decoded_bytes.decode('utf-8')
            username, password = decoded_str.split(":")
            
            # 3. Validate Credentials against .env variables linking to our DB 
            valid_user = os.getenv('DB_USER')
            valid_pass = os.getenv('DB_PASSWORD')

            if username == valid_user and password == valid_pass:
                return f(*args, **kwargs)
            else:
                return jsonify({"error": "Unauthorized", "message": "Invalid credentials"}), 401
                
        except Exception:
            return jsonify({"error": "Bad Request", "message": "Invalid Authorization header"}), 400
            
    return decorated