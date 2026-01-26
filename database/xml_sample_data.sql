-- DML: DATA FROM XML (modified_sms_v2.xml)
INSERT IGNORE INTO users (user_id, name, phone_number, entity_type) VALUES 
(1, 'My Device', '0788000000', 'SELF'),
(2, 'Jane Smith', '0788123013', 'INDIVIDUAL'),        
(3, 'Samuel Carter', '250791666666', 'INDIVIDUAL'),   
(4, 'Agent Sophia', '250790777777', 'AGENT'),         
(5, 'Airtime', 'MTN_AIRTIME', 'MERCHANT'),            
(6, 'Robert Brown', '0788999999', 'INDIVIDUAL');      


INSERT IGNORE INTO transactions (transaction_id, external_ref_id, transaction_date, amount, fees, category_id, raw_message) VALUES
(1, '76662021700', '2024-05-10 16:30:51', 2000.00, 0.00, 1, 'You have received 2000 RWF from Jane Smith (*********013) on your mobile money account at 2024-05-10 16:30:51.'),
(2, '51732411227', '2024-05-10 21:32:32', 600.00, 0.00, 2, 'TxId: 51732411227. Your payment of 600 RWF to Samuel Carter 95464 has been completed at 2024-05-10 21:32:32.'),
(3, '14098463509', '2024-05-26 02:10:27', 20000.00, 350.00, 4, 'You Abebe Chala CHEBUDIE have via agent: Agent Sophia (250790777777), withdrawn 20000 RWF from your mobile money account... Fee paid: 350 RWF.'),
(4, '13913173274', '2024-05-12 11:41:28', 2000.00, 0.00, 5, '*162*TxId:13913173274*S*Your payment of 2000 RWF to Airtime with token has been completed at 2024-05-12 11:41:28.'),
(5, '26614842768', '2024-05-12 17:58:15', 1000.00, 0.00, 2, 'TxId: 26614842768. Your payment of 1,000 RWF to Robert Brown 41193 has been completed at 2024-05-12 17:58:15.');

INSERT IGNORE INTO user_transactions (transaction_id, user_id, role, balance_after) VALUES
(1, 2, 'SENDER', NULL),
(1, 1, 'RECEIVER', 2000.00),
(2, 1, 'SENDER', 400.00),
(2, 3, 'RECEIVER', NULL),
(3, 1, 'SENDER', 6400.00),
(3, 4, 'RECEIVER', NULL),
(4, 1, 'SENDER', 25280.00),
(4, 5, 'RECEIVER', NULL),
(5, 1, 'SENDER', 9880.00),
(5, 6, 'RECEIVER', NULL);

INSERT INTO system_logs (transaction_id, log_level, status, message) VALUES
(1, 'INFO', 'COMPLETED', 'Parsed incoming P2P from XML batch.'),
(2, 'INFO', 'COMPLETED', 'Verified outgoing payment to Samuel.'),
(3, 'INFO', 'COMPLETED', 'Agent withdrawal verified successfully.'),
(4, 'INFO', 'COMPLETED', 'Airtime token generated.'),
(5, 'INFO', 'COMPLETED', 'Payment to Robert confirmed.');