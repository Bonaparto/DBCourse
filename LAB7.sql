1. Large objects are stored as a large object:
a) blob: binary large object - object is a large collection of
uninterpreted binary data.

b)clob: character large object - object is a large collection of
character data.


2. A role has priveleges which allow various actions in database,
and user can be given some roles.

CREATE ROLE accountant LOGIN;
CREATE ROLE administrator LOGIN;
CREATE ROLE support LOGIN;

GRANT SELECT ON accounts, transactions TO accountant;
GRANT ALL ON accounts, transactions, customers TO administrator;
GRANT SELECT, INSERT, UPDATE, DELETE ON accounts, transactions, customers to support;

CREATE USER administrator1 WITH PASSWORD 'admin1';
CREATE USER administrator2 WITH PASSWORD 'admin2';
CREATE USER accountant1 WITH PASSWORD 'accountant';
CREATE USER support1 WITH PASSWORD 'supporter';

GRANT administrator to administrator1, administrator2;
GRANT accountant to accountant1;
GRANT support to support1;

REVOKE administrator FROM administrator2;


3.

ALTER TABLE transactions ADD CONSTRAINT currency_check CHECK(src_account = dst_account);
ALTER TABLE transactions ADD CONSTRAINT src_not_null CHECK(src_account NOT NULL);
ALTER TABLE transactions ADD CONSTRAINT dst_not_null CHECK(dst_account NOT NULL);
ALTER TABLE transactions ADD CONSTRAINT date_not_null CHECK(date NOT NULL);
ALTER TABLE transactions ADD CONSTRAINT amount_not_null CHECK(amount NOT NULL);
ALTER TABLE transactions ADD CONSTRAINT status_not_null CHECK(status NOT NULL);

4.

CREATE type Cur as (currency VARCHAR(3));

DROP TYPE Cur;

ALTER TABLE accounts
ALTER currency TYPE cur USING currency::Cur;

5.

CREATE UNIQUE INDEX single_currency
ON accounts (currency);

CREATE INDEX cur_bal_search
ON accounts (currency, balance);

6.

DO $$
    DECLARE
        new_balance integer;
    BEGIN
        INSERT INTO transactions VALUES (7, now(), 'RS88012', 'NK90123', 100, 'init');
        UPDATE accounts SET balance = balance - 100
        WHERE account_id = 'NK90123';
        SELECT balance INTO new_balance FROM accounts
        WHERE account_id = 'NK90123';
        IF new_balance < 0 THEN
            UPDATE accounts SET balance = balance + 100
            WHERE account_id = 'NK90123';
            UPDATE transactions SET status = 'rollback'
            WHERE id = 6;
            RAISE NOTICE 'Not enough money on the balance.';
        ELSE
            UPDATE accounts SET balance = balance + 100
            WHERE account_id = 'RS88012';
            UPDATE transactions SET status = 'commited'
            WHERE id = 6;
        END IF;
    COMMIT;
END $$;
