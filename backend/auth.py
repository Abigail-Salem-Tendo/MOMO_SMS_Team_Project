from functools import wraps
from flask import request, jsonify
import base64
import os
from dotenv import load_dotenv

load_dotenv()

def require_auth(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        auth_header = request.headers.get('Authorization')
        
        # DEBUGGING : header?
        if not auth_header:
            print("DEBUG: No Authorization header received.")
            return jsonify({"error": "Unauthorized", "message": "Authentication required"}), 401
        
        try:
            # 2. Decode credentials
            auth_type, encoded_creds = auth_header.split(" ")
            
            # DEBUG 2: Check auth type
            if auth_type != "Basic":
                print(f"DEBUG: Wrong Auth Type. Received: {auth_type}")
                raise ValueError
            
            decoded_bytes = base64.b64decode(encoded_creds)
            decoded_str = decoded_bytes.decode('utf-8')
            
            # Handle edge case where password might be empty
            if ":" not in decoded_str:
                 print("DEBUG: Decoded string does not contain a colon.")
                 raise ValueError
                 
            username, password = decoded_str.split(":", 1)
            
            # 3. Load Env Vars
            valid_user = os.getenv('DB_USER')
            valid_pass = os.getenv('DB_PASSWORD')

            # DEBUGGING
            print("-" * 30)
            print(f"DEBUG: INPUT Username: '{username}'")
            print(f"DEBUG: ENV   Username: '{valid_user}'")
            print(f"DEBUG: INPUT Password: '{password}'")
            print(f"DEBUG: ENV   Password: '{valid_pass}'")
            print("-" * 30)

            # Check for missing env vars
            if valid_user is None or valid_pass is None:
                print("CRITICAL ERROR: .env variables DB_USER or DB_PASSWORD are NOT loaded (None). Check your .env path.")
                return jsonify({"error": "Server Error", "message": "Configuration missing"}), 500

            # 4. Strict Comparison

            if username == valid_user and password == valid_pass:
                print("DEBUG: Access Granted.")
                return f(*args, **kwargs)
            else:
                print("DEBUG: Access Denied (Mismatch).")
                return jsonify({"error": "Unauthorized", "message": "Invalid credentials"}), 401
                
        except Exception as e:
            print(f"DEBUG: Exception occurred: {e}")
            return jsonify({"error": "Bad Request", "message": "Invalid Authorization header"}), 400
            
    return decorated