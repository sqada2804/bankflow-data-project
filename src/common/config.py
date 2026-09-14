import os

from dotenv import load_dotenv

load_dotenv()

class Settings:
    APP_ENV = os.getenv("APP_ENV", "development")
    LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO")

    POSTGRES_HOST = os.getenv("POSTGRES_HOST", "localhost")
    POSTGRES_PORT = int(os.getenv("POSTGRES_PORT", "5432"))
    POSTGRES_DB = os.getenv("POSTGRES_DB", "bankflow-core")
    POSTGRES_USER = os.getenv("POSTGRES_USER", "bankflow")
    POSTGRES_PASSWORD = os.getenv("POSTGRES_PASSWORD")

    DATA_SCALE = os.getenv("DATA_SCALE", "small")
    RANDOM_SEED = int(os.getenv("RANDOM_SEED", "42"))

sett = Settings();
