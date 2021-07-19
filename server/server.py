import pyautogui
from PIL import Image
from flask import Flask, jsonify, request
import json
from removebg import RemoveBg
import base64
from werkzeug.serving import WSGIRequestHandler
import os

response = ''
response2 = ''
responseLast = ''
app = Flask(__name__)


@app.route('/photoBase64', methods=['GET', 'POST'])
def nameRoute():
    global response
    global response2
    global responseLast

    if (request.method == 'POST'):
        request_data = request.data
        request_data = json.loads(request_data.decode('utf-8'))
        photoBase64 = request_data['photoBase64']
        response = f'{photoBase64}'

        return jsonify({'encoded_string': response})
    else:
        rmbg = RemoveBg("MFMSGJJoUAu6jSrVV4tRX38A", "error.log")
        rmbg.remove_background_from_base64_img(response)
        with open("no-bg.png", "rb") as image_file:
            encoded_string = base64.b64encode(image_file.read())
        response2 = f''
        response2 = f'{encoded_string}'
        try:
            os.remove("no-bg.png")
        except:
            print("An exception occurred")
        return jsonify({'encoded_string': response2})


@app.route('/imgLast', methods=['POST'])
def nameRoute1():
    request_data = request.data
    request_data = json.loads(request_data.decode('utf-8'))
    imgLast = request_data['imgLast']
    ngBgImgLast = request_data['noBgImgLast']

    f = open("noBgImageLast.png", "wb")
    f.write(base64.b64decode(imgLast))
    f.close()
    f = open("noBgImageLast1.png", "wb")
    f.write(base64.b64decode(ngBgImgLast))
    f.close()

    image = Image.open('noBgImageLast.png')

    resized_noBgImageLast = image.resize((450, 450))
    resized_noBgImageLastRotate = resized_noBgImageLast.rotate(angle=270)

    resized_noBgImageLastRotate.save("noBgImageLast.png")
    konumOrta = pyautogui.locateCenterOnScreen('noBgImageLast.png', confidence=0.6)
    foto = pyautogui.locateOnScreen('foto.png')

    image = Image.open('noBgImageLast1.png')
    resized_noBgImageLast1 = image.resize((222, 481))
    resized_noBgImageLast1.save("noBgImageLast1.png")

    pyautogui.moveTo(foto)
    pyautogui.dragTo(konumOrta.x, konumOrta.y, 0.2, button='left')
    return 'Ok'


if __name__ == "__main__":
    WSGIRequestHandler.protocol_version = "HTTP/1.1"
    app.run(debug=True)
