from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    PROJECT_NAME: str = "SRE Portfolio"
    DATA_PATH: str = "api/data/projects.json"
    ASSETS_BUCKET: str = "portfolio-assets-sre-portfoliox"

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")


settings = Settings()
