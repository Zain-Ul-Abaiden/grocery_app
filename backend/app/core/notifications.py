import firebase_admin
from firebase_admin import credentials, messaging
from app.core.config import settings

# In a real app, you would initialize this with your service account JSON key:
# cred = credentials.Certificate("path/to/serviceAccountKey.json")
# firebase_admin.initialize_app(cred)
# For MVP we will just stub the notification sending.

def send_push_notification(fcm_token: str, title: str, body: str):
    """
    Sends a push notification via Firebase Cloud Messaging.
    """
    if not fcm_token:
        print(f"Skipping notification for '{title}' - no FCM token provided.")
        return
        
    try:
        # message = messaging.Message(
        #     notification=messaging.Notification(
        #         title=title,
        #         body=body,
        #     ),
        #     token=fcm_token,
        # )
        # response = messaging.send(message)
        # print('Successfully sent message:', response)
        print(f"STUB: Sent push notification to {fcm_token} -> {title}: {body}")
    except Exception as e:
        print(f"Error sending push notification: {e}")
