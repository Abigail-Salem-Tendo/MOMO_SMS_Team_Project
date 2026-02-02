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
@require_auth # basic auth
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


if __name__ == '__main__':
    app.run(debug=True)