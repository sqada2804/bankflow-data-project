import logging

from src.common.config import sett


def get_logger(name: str) -> logging.Logger:
    logging.basicConfig(
        level=sett.LOG_LEVEL,
        format="%(asctime)s | %(levelname)s | %(name)s | %(message)s"
    )
    return logging.getLogger(name)