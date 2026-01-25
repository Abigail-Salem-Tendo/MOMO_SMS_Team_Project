insert ignore into transaction_categories (category_id, category_name) values (1, 'P2P'), (2, 'MERCHANT'), (3, 'BILLS'), (4, 'AIRTIME'), (5, 'DEPOSIT'), (6, 'WITHDRAWAL');

insert ignore into users (user_id, name, phone_number, created_at) values
(1, 'Jane Smith', '*********013', '2024-05-10 16:30:51'),
(2, 'Samuel Carter', '250791666666', '2024-05-11 20:34:47'),
(3, 'Airtime', 'Unknown', '2024-05-12 11:41:28'),
(4, 'Agent Sophia', '250790777777', '2024-05-26 02:10:27'),
(5, 'Bundles and Packs', 'Unknown', '2024-11-12 23:47:47'),
(6, 'ESICIA LTD', 'Unknown', '2024-09-21 15:49:01'),
(7, 'Bank', 'BANK', '2024-05-11 18:43:49');

insert ignore into transactions (transaction_id, transaction_date, amount, fees, category_id, status, raw_message, created_at) values
(1, '2024-05-10 16:30:51', 2000, 0, 1, 'COMPLETED', 'You have received 2000 RWF from Jane Smith (*********013) on your mobile money account at 2024-05-10 16:30:51.', '2026-01-25 17:26:48'),
(2, '2024-11-12 23:47:47', 5000, 0, 3, 'FAILED', '*143*TxId:16803066185*S*Your payment of 5000 RWF to Bundles and Packs with token has failed at 2024-11-12 23:47:47.', '2026-01-25 17:26:48'),
(3, '2024-05-12 11:41:28', 2000, 0, 4, 'COMPLETED', '*162*TxId:13913173274*S*Your payment of 2000 RWF to Airtime with token has been completed at 2024-05-12 11:41:28.', '2026-01-25 17:26:48'),
(4, '2024-05-26 02:10:27', 20000, 350, 6, 'COMPLETED', 'You... via agent: Agent Sophia (250790777777), withdrawn 20000 RWF from your mobile money account at 2024-05-26 02:10:27.', '2026-01-25 17:26:48'),
(5, '2024-05-11 18:43:49', 40000, 0, 5, 'COMPLETED', '*113*R*A bank deposit of 40000 RWF has been added to your mobile money account at 2024-05-11 18:43:49.', '2026-01-25 17:26:48'),
(6, '2024-09-21 15:49:01', 14200, 0, 2, 'FAILED', '*143*R*Y''ello, the transaction with amount 14200 RWF for ESICIA LTD... failed at 2024-09-21 15:49:01.', '2026-01-25 17:26:48'),
(7, '2024-05-11 20:34:47', 10000, 100, 1, 'COMPLETED', '*165*S*10000 RWF transferred to Samuel Carter (250791666666) from 36521838 at 2024-05-11 20:34:47.', '2026-01-25 17:26:48');

insert ignore into user_transactions (user_transaction_id, transaction_id, user_id, role, balance_after) values
(1, 1, 1, 'RECEIVER', 2000),
(2, 2, 5, 'SENDER', NULL),
(3, 3, 3, 'SENDER', 25280),
(4, 4, 4, 'SENDER', 6400),
(5, 5, 7, 'RECEIVER', 40400),
(6, 6, 6, 'SENDER', NULL),
(7, 7, 2, 'SENDER', 28300);

insert ignore into system_logs (log_id, transaction_id, log_level, status, message, created_at) values
(1, 1, 'INFO', 'SUCCESS', 'P2P Receive from Jane Smith processed', '2024-05-10 16:30:51'),
(2, 2, 'ERROR', 'FAILED', 'Payment to Bundles and Packs failed at gateway', '2024-11-12 23:47:47'),
(3, 3, 'INFO', 'SUCCESS', 'Airtime purchase confirmed', '2024-05-12 11:41:28'),
(4, 4, 'INFO', 'SUCCESS', 'Agent withdrawal completed via Agent Sophia', '2024-05-26 02:10:27'),
(5, 5, 'INFO', 'SUCCESS', 'Bank deposit added to balance', '2024-05-11 18:43:49'),
(6, 6, 'ERROR', 'FAILED', 'Merchant payment to ESICIA LTD failed', '2024-09-21 15:49:01'),
(7, 7, 'INFO', 'SUCCESS', 'P2P Transfer to Samuel Carter successful', '2024-05-11 20:34:47');