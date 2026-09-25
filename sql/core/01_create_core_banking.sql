CREATE TABLE IF NOT EXISTS customer (
	customer_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	national_id VARCHAR(50) NOT NULL UNIQUE,
	first_name VARCHAR(100) NOT NULL,
	last_name VARCHAR(100) NOT NULL,
	email VARCHAR(255) UNIQUE,
	phone VARCHAR(50),
	birth_date DATE NOT NULL,
	country VARCHAR(50) NOT NULL,
	city VARCHAR(100) NOT NULL,
	segment VARCHAR(50) NOT NULL
		CHECK (segment IN ('RETAIL', 'PREMIUM', 'PRIVATE')),

	risk_category VARCHAR(100) NOT NULL
		CHECK (risk_category IN ('LOW', 'MEDIUM', 'HIGH')),

	created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

	CONSTRAINT chk_customer_birth_date
		CHECK (birth_date < CURRENT_DATE)
);

CREATE TABLE IF NOT EXISTS branch (
	branch_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	branch_code VARCHAR(100) NOT NULL UNIQUE,
	name VARCHAR(100) NOT NULL,
	country VARCHAR(50) NOT NULL,
	city VARCHAR(100) NOT NULL,
	created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS currency(
	currency_code CHAR(3) PRIMARY KEY,
	currency_name VARCHAR(30),
	symbol VARCHAR(30)
);

CREATE TABLE IF NOT EXISTS product(
	product_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	product_code VARCHAR(255) NOT NULL,
	product_name VARCHAR(100) NOT NULL,
	product_type VARCHAR(100) NOT NULL,
		CHECK (product_type IN ('SAVINGS', 'CHECKING', 'CREDIT_CARD', 'PERSONAL_LOAN')),
	
	interest_rate NUMERIC,
	created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP	
);

CREATE TABLE IF NOT EXISTS account(
	account_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	account_number VARCHAR(255),
	customer_id BIGINT NOT NULL,
	product_id BIGINT NOT NULL,
	branch_id BIGINT NOT NULL,
	currency_code CHAR(3) NOT NULL,
	balance NUMERIC NOT NULL,
	status VARCHAR(100) NOT NULL,
	opened_at DATE NOT NULL,
	created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

	CONSTRAINT fk_account_customer
	FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
	
	CONSTRAINT fk_account_product
	FOREIGN KEY (product_id) REFERENCES product(product_id),

	CONSTRAINT fk_account_branch
	FOREIGN KEY (branch_id) REFERENCES branch(branch_id),

	CONSTRAINT fk_account_currency
	FOREIGN KEY (currency_code) REFERENCES currency(currency_code)
);

CREATE TABLE IF NOT EXISTS card(
	card_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	card_number VARCHAR(255) NOT NULL UNIQUE,
	account_id BIGINT NOT NULL,
	card_type VARCHAR(100) NOT NULL,
	status VARCHAR(100) NOT NULL,
	expiration_date DATE NOT NULL,
	credit_limit NUMERIC NOT NULL,
	created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,	

	CONSTRAINT fk_card_account
	FOREIGN KEY (account_id) REFERENCES account(account_id)
);

CREATE TABLE IF NOT EXISTS merchant(
	merchant_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	merchant_code VARCHAR(255) NOT NULL,
	merchant_name VARCHAR(100) NOT NULL,
	category VARCHAR(100) NOT NULL,
	country VARCHAR(100) NOT NULL,
	city VARCHAR(100) NOT NULL,
	created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS bank_transaction(
	transaction_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	account_id BIGINT NOT NULL,
	merchant_id BIGINT NULL,
	transaction_type VARCHAR(100),
		CHECK(transaction_type IN('DEPOSIT', 'WITHDRAWAL', 'TRANSFER', 'CARD_PAYMENT')),
	
	amount NUMERIC NULL,
	currency_code CHAR(3) NOT NULL,
	status VARCHAR(100),
		CHECK(status IN('PENDING', 'COMPLETED', 'DECLINED', 'REVERSED')),
	
	transaction_timestamp TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
	created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

	CONSTRAINT fk_transaction_account
	FOREIGN KEY (account_id) REFERENCES account(account_id),

	CONSTRAINT fk_transaction_merchant
	FOREIGN KEY (merchant_id) REFERENCES merchant(merchant_id),

	CONSTRAINT fk_transaction_currency
	FOREIGN KEY (currency_code) REFERENCES currency(currency_code) 
);

CREATE TABLE IF NOT EXISTS loan(
	loan_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	customer_id BIGINT NOT NULL,
	product_id BIGINT NOT NULL,
	currency_code CHAR(3) NOT NULL,
	principal_amount NUMERIC NOT NULL,
	interest_rate NUMERIC NOT NULL,
	start_date DATE NOT NULL,
	end_date DATE NOT NULL,
	status VARCHAR(100) NOT NULL,
	created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

	CONSTRAINT fk_loan_customer
	FOREIGN KEY (customer_id) REFERENCES customer(customer_id),

	CONSTRAINT fk_loan_product 
	FOREIGN KEY (product_id) REFERENCES product(product_id),

	CONSTRAINT fk_loan_currency
	FOREIGN KEY (currency_code) REFERENCES currency(currency_code)
);

CREATE TABLE IF NOT EXISTS loan_payment(
	loan_payment_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	loan_id BIGINT NOT NULL,
	amount NUMERIC NOT NULL,
	payment_date TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
	created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

	CONSTRAINT fk_loan_payment_loan
	FOREIGN KEY (loan_id) REFERENCES loan(loan_id)
);

/*-----------------------------------------------------------------------------------------------*/

BEGIN;
ALTER TABLE currency ADD CONSTRAINT chk_currency_code
CHECK (currency_code IN ('CRC', 'USD','EUR'));
COMMIT;

ALTER TABLE product 
ADD CONSTRAINT uc_product_code UNIQUE (product_code);

BEGIN;
ALTER TABLE account 
ADD CONSTRAINT uc_account_number UNIQUE (account_number);
ALTER TABLE account
ALTER COLUMN account_number SET NOT NULL;
COMMIT;

ALTER TABLE merchant 
ADD CONSTRAINT uc_merchant_code UNIQUE (merchant_code);

ALTER TABLE bank_transaction
ALTER COLUMN status SET NOT NULL;

ALTER TABLE bank_transaction
ALTER COLUMN transaction_type SET NOT NULL;

BEGIN;
ALTER TABLE bank_transaction
	ALTER COLUMN amount SET NOT NULL;

ALTER TABLE bank_transaction ADD CONSTRAINT chk_transaction_amount
	CHECK(amount > 0);
COMMIT;

BEGIN;
ALTER TABLE loan ADD CONSTRAINT chk_principal_amount
	CHECK(principal_amount > 0);
ALTER TABLE loan ADD CONSTRAINT chk_end_date
	CHECK(end_date >= start_date);
COMMIT;

ALTER TABLE loan_payment ADD CONSTRAINT chk_loan_payment_amount
	CHECK(amount > 0);

/*-----------------------------------------------------------------------------------------------*/

BEGIN;

ALTER TABLE account
ADD CONSTRAINT chk_account_status
CHECK(status IN ('ACTIVE', 'BLOCKED', 'CLOSED', 'SUSPENDED'));

ALTER TABLE card
ADD CONSTRAINT chk_card_type
CHECK(card_type IN ('DEBIT', 'CREDIT'));

ALTER TABLE card
ADD CONSTRAINT chk_card_status
CHECK(status IN ('ACTIVE', 'BLOCKED', 'EXPIRED', 'CANCELLED'));

ALTER TABLE loan
ADD CONSTRAINT chk_loan_status
CHECK(status IN ('PENDING', 'ACTIVE', 'PAID', 'DEFAULTED', 'CANCELLED'));

COMMIT;

BEGIN;

ALTER TABLE account
ALTER COLUMN balance TYPE NUMERIC(18,2);

ALTER TABLE card
ALTER COLUMN credit_limit TYPE NUMERIC(18,2);

ALTER TABLE bank_transaction
ALTER COLUMN amount TYPE NUMERIC(18,2);

ALTER TABLE loan
ALTER COLUMN principal_amount TYPE NUMERIC(18,2);

ALTER TABLE loan
ALTER COLUMN interest_rate TYPE NUMERIC(7,4);

ALTER TABLE loan_payment
ALTER COLUMN amount TYPE NUMERIC(18,2);

ALTER TABLE product
ALTER COLUMN interest_rate TYPE NUMERIC(7,4);

COMMIT;

/*-----------------------------------------------------------------------------------------------*/

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN 
	NEW.updated_at = CURRENT_TIMESTAMP;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

BEGIN;

CREATE TRIGGER trg_customer_updated_at
BEFORE UPDATE ON customer
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_account_updated_at
BEFORE UPDATE ON account
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_bank_transaction_updated_at
BEFORE UPDATE ON bank_transaction
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_branch_updated_at
BEFORE UPDATE ON branch
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_card_updated_at
BEFORE UPDATE ON card
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_loan_updated_at
BEFORE UPDATE ON loan
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_product_updated_at
BEFORE UPDATE ON product
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_merchant_updated_at
BEFORE UPDATE ON merchant
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_loan_payment_updated_at
BEFORE UPDATE ON loan_payment
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

COMMIT;


