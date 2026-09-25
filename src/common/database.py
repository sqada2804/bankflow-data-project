import psycopg

from src.common.config import sett

def get_connection():
    return psycopg.connect(
        host=sett.POSTGRES_HOST,
        port=sett.POSTGRES_PORT,
        dbname=sett.POSTGRES_DB,
        user=sett.POSTGRES_USER,
        password=sett.POSTGRES_PASSWORD,
        connect_timeout=5
    )