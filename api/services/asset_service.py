from google.cloud import storage
from api.config import settings

class AssetService:
    def __init__(self):
        self.storage_client = storage.Client()
        self.bucket_name = settings.ASSETS_BUCKET

    def get_asset_url(self, filename: str) -> str:
        """
        Returns the public URL for an asset in the GCS bucket.
        For production, we assume the bucket has public read access for these files.
        """
        return f"https://storage.googleapis.com/{self.bucket_name}/{filename}"

    def list_assets(self) -> list[str]:
        """List all files in the assets bucket."""
        try:
            bucket = self.storage_client.bucket(self.bucket_name)
            blobs = bucket.list_blobs()
            return [blob.name for blob in blobs]
        except Exception as e:
            # Raise exception so the API can return a proper 500 error
            raise RuntimeError(f"Could not list GCS assets: {str(e)}")
