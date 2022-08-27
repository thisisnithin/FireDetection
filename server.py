import json
import requests
import threading
import websockets
import asyncio
from imageai.Detection.Custom import CustomObjectDetection, CustomVideoObjectDetection
import os
import cv2
from PIL import Image
import urllib.request
import numpy as np
import matplotlib.pyplot as plt
import tensorflow as tf
import pathlib
import socket
import sys

#import ssl
execution_path = os.getcwd()
gpu_options = tf.GPUOptions(allow_growth=True)
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.bind(('192.168.0.106', 6969))
s.listen(5)
print('Listening....')
ip = ''
if sys.argv[2] == '0':
    print('Connecting to client')
    while True:
        client, addr = s.accept()
        ip = client.recv(1024)
        ip = ip.decode('utf-8')
        break
else:
    ip = '183.82.181.215'
print(f'Recieved ip {ip}')
s.close()

# Python script 8765 to start a websocket server on LAN wifi/port number .
lan_ip = sys.argv[1]
message = ''
#lock = threading.Lock()

data = requests.get('http://api.ipstack.com/'+ip +
                    '?access_key=7d0e0642b88c21497c80bbb570f74bbc')
data = json.loads(data.text)
lat = data['latitude']
longt = data['longitude']
lat = str(lat)
longt = str(longt)
location = data['city']
print(f'Location is {location}')


def fire_detect(lock):
    global message
    global lat
    global longt
    detector = CustomObjectDetection()
    detector.setModelTypeAsYOLOv3()
    detector.setModelPath(detection_model_path=os.path.join(
        execution_path, "detection_model-ex-33--loss-4.97.h5"))
    detector.setJsonPath(configuration_json=os.path.join(
        execution_path, "detection_config.json"))
    detector.loadModel()

    stream = urllib.request.urlopen('http://192.168.0.106:8000/video_feed')
    total_bytes = b''
    while(True):
        global message
        global lat
        global longt
        lock.acquire()
        total_bytes += stream.read(20000)
        b = total_bytes.find(b'\xff\xd9')
        if not b == -1:
            a = total_bytes.find(b'\xff\xd8')
            jpg = total_bytes[a:b+2]
            total_bytes = total_bytes[b+2:]
            img = cv2.imdecode(np.fromstring(
                jpg, dtype=np.uint8), cv2.IMREAD_COLOR)
            detections = detector.detectObjectsFromImage(input_type="array", input_image=img,
                                                         output_type='array',
                                                         minimum_percentage_probability=40)
            cv2.imshow('img', detections[0])
            # print(detections[0])
            if detections[1]:
                message = 'fire,' + lat + ',' + longt
            else:
                message = 'no fire,' + lat + ',' + longt
        lock.release()
        k = cv2.waitKey(1)
        if k == 27:
            exit()
    cv2.release()
    cv2.destroyAllWindows()


def fire_detect1(lock):
    global message
    global lat
    global longt
    detector = CustomObjectDetection(cylider="true")
    detector.setModelTypeAsYOLOv3()
    detector.setModelPath(detection_model_path=os.path.join(
        execution_path, "detection_model-ex-33--loss-4.97.h5"))
    detector.setJsonPath(configuration_json=os.path.join(
        execution_path, "detection_config.json"))
    detector.loadModel()

    # <=== Represents Wired Connection (Change to 0 for camera input)
    cap = cv2.VideoCapture('fires4.mp4')
    while(True):
        global message
        global lat
        global longt
        lock.acquire()
        ret, img = cap.read()
        detections = detector.detectObjectsFromImage(input_type="array", input_image=img,
                                                     output_type='array',
                                                     minimum_percentage_probability=40)
        cv2.imshow('img', detections[0])
        if detections[1]:
            message = 'fire,' + lat + ',' + longt + "Level 4"
        else:
            message = 'no fire,' + lat + ',' + longt
        lock.release()
        k = cv2.waitKey(1)
        if k == 27:
            exit()
    cv2.release()
    cv2.destroyAllWindows()


# async function that performs io with client
async def fire_notification(websocket, path):
    global message
    # clients.append(websocket)
    print(f'Client connected from {websocket}!')
    while True:
        await websocket.send(message)
        #print(f"> sent notification {message}")

'''
async def location_notification(websocket,path):
    await websocket.send('37.7510,-97.8220')
'''


# this function starts the server and listens for multiple client connections.
async def start_notification_server():
    lock = threading.RLock()
    if sys.argv[2] == '0':
        t = threading.Thread(target=fire_detect, args=(lock,))
        t.daemon = True
        t.start()
    else:
        t = threading.Thread(target=fire_detect1, args=(lock,))
        t.daemon = True
        t.start()
    #ssl_context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
    #localhost_pem = pathlib.Path(__file__).with_name("localhost.pem")
    # ssl_context.load_cert_chain(localhost_pem)
    server = await websockets.serve(fire_notification, lan_ip, 9999)

    print('Server started...')

    return server
'''
async def start_location_server():
    server = await websockets.serve(location_notification, lan_ip, 9998)
    return server
'''


notification_server = start_notification_server()
#location_server = start_location_server()
# asyncio.get_event_loop().run_until_complete(location_server)
asyncio.get_event_loop().run_until_complete(notification_server)

asyncio.get_event_loop().run_forever()
