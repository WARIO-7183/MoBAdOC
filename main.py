from flask import Flask, request, jsonify, send_file, Response
import tempfile, os
from openai import OpenAI
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

app = Flask(__name__)

# Initialize OpenAI client with API key from environment variable
client = OpenAI(api_key=os.getenv('OPENAI_API_KEY'))

HTML_PAGE = """<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>WhatsApp Call — AIDOC</title>
  <style>
    /* full‐screen bg */
    body, html {
      margin: 0; padding: 0;
      width: 100%; height: 100%;
      background: #000 url('https://i.imgur.com/3ZRjF5T.png') center/cover no-repeat;
      font-family: 'Segoe UI', sans-serif;
      color: #fff;
      display: flex; align-items: center; justify-content: center;
    }
    /* call container */
    .call-container {
      position: relative;
      width: 360px; height: 780px;
      background: rgba(0,0,0,0.6);
      border-radius: 40px;
      overflow: hidden;
      box-shadow: 0 8px 24px rgba(0,0,0,0.7);
    }
    /* top status bar */
    .status-bar {
      height: 44px; padding: 0 12px;
      display: flex; align-items: center; justify-content: space-between;
      font-size: 14px;
    }
    .status-left { display: flex; align-items: center; gap: 6px; }
    .signal, .wifi, .battery {
      width: 18px; height: 12px;
      background: rgba(255,255,255,0.8);
      border-radius: 2px;
    }
    .time { font-weight: 500; }
    /* contact info */
    .contact-info {
      margin-top: 8px;
      text-align: center;
    }
    .contact-name { font-size: 22px; font-weight: 600; }
    .encrypted { font-size: 12px; color: rgba(255,255,255,0.7); }
    /* avatar circle */
    .avatar {
      width: 220px; height: 220px;
      background: rgba(255,255,255,0.2);
      border-radius: 50%;
      margin: 24px auto 40px;
    }
    /* controls */
    .controls {
      position: absolute; bottom: 32px; left: 0; right: 0;
      display: flex; justify-content: space-around;
      padding: 0 24px;
    }
    .btn {
      width: 60px; height: 60px;
      background: rgba(255,255,255,0.15);
      border-radius: 50%;
      display: flex; align-items: center; justify-content: center;
      font-size: 26px; cursor: pointer;
      transition: background 0.2s;
    }
    .btn:hover { background: rgba(255,255,255,0.25); }
    .btn.end {
      background: #E74C3C;
    }
    .btn.end:hover { background: #C0392B; }
  </style>
</head>
<body>
  <div class="call-container">
    <div class="status-bar">
      <div class="status-left">
        <div class="signal"></div>
        <div class="wifi"></div>
      </div>
      <div class="time">16:54</div>
      <div class="battery"></div>
    </div>

    <div class="contact-info">
      <div class="contact-name">AIDOC</div>
      <div class="encrypted">End-to-end encrypted</div>
    </div>

    <div class="avatar"></div>

    <div class="controls">
      <div class="btn" title="Keypad">&#8942;</div>
      <div class="btn" title="Video">&#128249;</div>
      <div class="btn" title="Speaker">&#128266;</div>
      <div class="btn" title="Mute">&#128263;</div>
      <div class="btn end" id="endCallBtn" title="End call">&#128222;</div>
    </div>
  </div>

  <script>
    document.getElementById('endCallBtn').onclick = () => {
      document.querySelector('.contact-name').textContent = 'Call ended';
      document.querySelector('.encrypted').style.display = 'none';
    };
  </script>
</body>
</html>"""
    

@app.route('/')
def index():
    return Response(HTML_PAGE, mimetype='text/html')

@app.route('/talk', methods=['POST'])
def talk():
    if 'audio' not in request.files:
        return jsonify({'error': 'No audio uploaded'}), 400

    audio_file = request.files['audio']
    with tempfile.NamedTemporaryFile(delete=False, suffix='.wav') as tmp:
        audio_path = tmp.name
        audio_file.save(audio_path)

    print(f"Received audio file: {audio_path}, size: {os.path.getsize(audio_path)} bytes")

    try:
        # 1️⃣ Transcribe
        with open(audio_path, "rb") as audio_f:
            transcript = client.audio.transcriptions.create(
                model="whisper-1",
                file=audio_f,
                response_format="text"
            )
        user_text = transcript

        # 2️⃣ Chat
        chat = client.chat.completions.create(
            model="gpt-4o",
            messages=[
                {"role": "system", "content": "You are a helpful assistant."},
                {"role": "user", "content": user_text},
            ]
        )
        reply_text = chat.choices[0].message.content

        # 3️⃣ TTS
        speech = client.audio.speech.create(
            model="tts-1",
            voice="alloy",
            input=reply_text
        )

        tts_path = tempfile.NamedTemporaryFile(delete=False, suffix='.mp3').name
        with open(tts_path, 'wb') as out:
            out.write(speech.content)

        return send_file(tts_path, mimetype="audio/mpeg")

    except Exception as e:
        return jsonify({'error': str(e)}), 500

    finally:
        if os.path.exists(audio_path):
            os.remove(audio_path)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
