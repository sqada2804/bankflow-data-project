from src.common.config import sett


def test_default_env():
    assert sett.APP_ENV is not None

def test_postgres_port_is_int():
    assert isinstance(sett.POSTGRES_PORT, int)

def test_data_scale_exists():
    assert sett.DATA_SCALE in {"small", "medium", "large"}