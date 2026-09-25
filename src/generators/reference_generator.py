from src.common.database import get_connection
from src.common.logger import get_logger

logger = get_logger(__name__)

CURRENCIES = [
    ('CRC', 'Costa Rican Colon', '₡'),
    ('USD', 'US Dollar', '$'),
    ('EUR', 'Euro', '€')
]

def generate_currencies() -> None:
    query = """
        INSERT INTO currency (
            currency_code,
            currency_name,
            symbol
        )
        VALUES (%s, %s, %s)
        ON CONFLICT (currency_code)
        DO UPDATE SET 
            currency_name = EXCLUDED.currency_name,
            symbol = EXCLUDED.symbol;
    """

    with get_connection() as conn:
        with conn.cursor() as cursor:
            cursor.executemany(query, CURRENCIES)
    logger.info("Currencies generated succesfully")

BRANCHES = [
    ("BR-001", "San José Central", "Costa Rica", "San José"),
    ("BR-002", "Alajuela Central", "Costa Rica", "Alajuela"),
    ("BR-003", "Heredia Central", "Costa Rica", "Heredia"),
    ("BR-004", "Cartago Central", "Costa Rica", "Cartago"),
    ("BR-005", "Liberia Central", "Costa Rica", "Liberia")
]

def generate_branches() -> None:
    query = """
        INSERT INTO branch (
        branch_code,
        name,
        country,
        city
    )
    VALUES (%s, %s, %s, %s)
    ON CONFLICT (branch_code)
    DO UPDATE SET
        name = EXCLUDED.name,
        country = EXCLUDED.country,
        city = EXCLUDED.city
    """

    with get_connection() as conn:
        with conn.cursor() as cursor:
            cursor.executemany(query, BRANCHES)
    logger.info("Branches generated successfully")

if __name__ == "__main__":
    generate_currencies()
    generate_branches()