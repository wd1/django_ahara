from django.conf import settings
from twilio.rest import Client


def send_sms(number, text):

    client = Client(settings.TWILIO_ACCOUNT_SID, settings.TWILIO_AUTH_TOKEN)

    message = client.messages.create(
        to=number,
        body=text,
        # from_='+18643852455',
        messaging_service_sid=settings.TWILIO_MESSAGE_SID
    )

    print(message.sid)
