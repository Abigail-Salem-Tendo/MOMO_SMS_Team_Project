from flask import Flask, jsonify, request, abort
import pymysql
import os
from dotenv import load_dotenv

# importing auth
from auth import require_auth

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


# GET all transactions with all their info
@app.route('/transactions', methods=['GET'])

@require_auth # basic auth

def get_all_transactions():
    try:
        connection = get_db_connection()
    except pymysql.MySQLError as e:
        abort(500, description=f"Database connection failed: {e}")
    try:
        with connection.cursor() as cursor:
            sql = """
                select 
                    t.transaction_id, t.external_ref_id, t.transaction_date,
                    tc.category_name as transaction_category,
                    u_sender.name as sender, u_sender.entity_type as sender_entity_type,
                    t.amount,
                    u_receiver.name as receiver, u_receiver.entity_type as receiver_entity_type,
                    t.status, t.raw_message
                from transactions t
                join transaction_categories tc on t.category_id = tc.category_id
                join user_transactions ut_s on t.transaction_id = ut_s.transaction_id and ut_s.role = 'SENDER'
                join users u_sender on ut_s.user_id = u_sender.user_id
                join user_transactions ut_r on t.transaction_id = ut_r.transaction_id and ut_r.role = 'RECEIVER'
                join users u_receiver on ut_r.user_id = u_receiver.user_id;
            """
            cursor.execute(sql)
            result = cursor.fetchall()
        return jsonify(result), 200
    finally:
        connection.close()


# GET a specific transaction by using its transaction_ID and get all info related to that transaction
@app.route('/transactions/<int:transaction_id>', methods=['GET'])
@require_auth # basic auth#
def get_transaction_by_id(transaction_id):
    try:
        connection = get_db_connection()
    except pymysql.MySQLError as e:
        abort(500, description=f"Database connection failed: {e}")
    try:
        with connection.cursor() as cursor:
            sql = """
                select 
                    t.transaction_id, t.external_ref_id, t.transaction_date,
                    tc.category_name as transaction_category,
                    u_sender.name as sender, u_sender.entity_type as sender_entity_type,
                    t.amount,
                    u_receiver.name as receiver, u_receiver.entity_type as receiver_entity_type,
                    t.status, t.raw_message
                from transactions t
                join transaction_categories tc on t.category_id = tc.category_id
                join user_transactions ut_s on t.transaction_id = ut_s.transaction_id and ut_s.role = 'SENDER'
                join users u_sender on ut_s.user_id = u_sender.user_id
                join user_transactions ut_r on t.transaction_id = ut_r.transaction_id and ut_r.role = 'RECEIVER'
                join users u_receiver on ut_r.user_id = u_receiver.user_id
                where t.transaction_id = %s;
            """
            cursor.execute(sql, (transaction_id,))
            result = cursor.fetchone()
        if result:
            return jsonify(result), 200
        else:
            abort(404, description="Transaction not found")
    finally:
        connection.close()

# POST a new transaction (Creation of a new transaction)
@app.route('/transactions', methods=['POST'])
def create_transaction():
    # Get the JSON data sent in the request body
    if not request.is_json:
        return jsonify({"error": "Expected JSON body"}), 415

    data = request.json
    
    # Validate the required fields are present
    required_fields = ['transaction_date', 'amount', 'category_id', 'sender_id', 'receiver_id', 'status']
    if not data or not all(k in data for k in required_fields):
        return jsonify({"error": "Missing required fields"}), 400
    
    connection = get_db_connection()
    if not connection:
        return jsonify({"error": "Database connection failed"}), 500

    try:
        with connection.cursor() as cursor:
            # Insert the main transaction record into transactions table
            transaction_sqlscript = """
                INSERT INTO transactions 
                (external_ref_id, transaction_date, amount, fees, category_id, status, raw_message) 
                VALUES (%s, %s, %s, %s, %s, %s, %s)
            """
            cursor.execute(transaction_sqlscript, (
                data.get('external_ref_id'),
                data['transaction_date'], 
                data['amount'], 
                data.get('fees', 0.0),
                data['category_id'], 
                data.get('status', 'SUCCESS'), 
                data.get('raw_message')
            ))
            
            # Get the new genereted transaction ID to use in user_transactions table
            created_transactionId = cursor.lastrowid

            # Insert a record into user_transactions to link the sender to this transaction.
            sender_sqlscript = """
                INSERT INTO user_transactions (transaction_id, user_id, role, balance_after)
                VALUES (%s, %s, 'SENDER', %s)
            """
            cursor.execute(sender_sqlscript, (
                created_transactionId, 
                data['sender_id'], 
                data.get('sender_balance_after')
            ))

            # Insert a record into user_transactions to link the receiver to this transaction.
            receiver_sqlscript = """
                INSERT INTO user_transactions (transaction_id, user_id, role, balance_after)
                VALUES (%s, %s, 'RECEIVER', %s)
            """
            cursor.execute(receiver_sqlscript, (
                created_transactionId, 
                data['receiver_id'], 
                data.get('receiver_balance_after')
            ))

        connection.commit()
        return jsonify({
            "message": "Transaction created successfully",
            "transaction_id": created_transactionId
        }), 201

    except Exception as e:
        # If any error occurs,remove all changes made during this transaction.
        connection.rollback()

        return jsonify({"error": "Transaction failed", "details": str(e)}), 500
    finally:
        connection.close()


if __name__ == '__main__':
    app.run(debug=True)