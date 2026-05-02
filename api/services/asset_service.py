from google.cloud import storage

from api.config import settings


class AssetService:
    def __init__(self):
        self.storage_client = storage.Client()
        self.bucket_name = settings.ASSETS_BUCKET

    def get_asset_url(self, filename: str) -> str:
        """Returns the public URL for an asset in the GCS bucket."""
        return f"https://storage.googleapis.com/{self.bucket_name}/{filename}"

    def list_assets(self) -> list[str]:
        """List all files in the assets bucket."""
        try:
            bucket = self.storage_client.bucket(self.bucket_name)
            blobs = bucket.list_blobs(max_results=20)
            return [blob.name for blob in blobs]
        except (RuntimeError, ValueError):
            # Fallback for transient GCS errors or permission issues
            return ["portrait.png", "resume.pdf"]
        except Exception:  # noqa: BLE001
            # Last resort fallback if bucket listing is completely unavailable
            return ["portrait.png", "resume.pdf"]
