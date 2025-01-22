import asyncio
from azure.iot.device.aio import IoTHubDeviceClient
import RPi.GPIO as GPIO


GPIO.setmode(GPIO.BCM)
relay_pin = 18  
GPIO.setup(relay_pin, GPIO.OUT)

conn_str = ""
device_client = IoTHubDeviceClient.create_from_connection_string(conn_str)

async def twin_patch_listener(device_client):
    while True:
        twin_patch = await device_client.receive_twin_desired_properties_patch()
        print("Twin patch received:", twin_patch)
        
        
        if 'status' in twin_patch:
            if twin_patch['status'] == 'on':
                GPIO.output(relay_pin, GPIO.LOW)  # Turn the relay on
                print("Switch turned ON.")
            elif twin_patch['status'] == 'off':
                GPIO.output(relay_pin, GPIO.HIGH)  # Turn the relay off
                print("Switch turned OFF.")

async def main():
    await device_client.connect()
    listeners = asyncio.gather(twin_patch_listener(device_client))
    await listeners

if __name__ == "__main__":
    asyncio.run(main())


### iot_relay_control.py