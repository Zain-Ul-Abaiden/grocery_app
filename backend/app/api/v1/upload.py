import os
import uuid
import shutil
from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File
from app.core.security import get_current_admin
from app.models.user import User

router = APIRouter(prefix="/upload", tags=["Uploads"])

UPLOAD_DIR = "uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)

@router.post("/image", status_code=status.HTTP_201_CREATED)
async def upload_image(
    file: UploadFile = File(...),
    admin: User = Depends(get_current_admin)
):
    """
    Upload an image. Admin only.
    Returns the URL to the uploaded image.
    """
    if not file.content_type.startswith("image/"):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="File provided is not an image."
        )

    ext = file.filename.split(".")[-1]
    filename = f"{uuid.uuid4()}.{ext}"
    file_path = os.path.join(UPLOAD_DIR, filename)

    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    return {"url": f"/static/uploads/{filename}"}
