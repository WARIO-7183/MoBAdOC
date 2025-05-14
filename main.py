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
<html lang=\"en\">
<head>
    <meta charset=\"UTF-8\">
    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
    <title>HI Health</title>
    <style>
        body, html {
            height: 100%;
            margin: 0;
            padding: 0;
            background: #181C23;
            color: #fff;
            font-family: 'Segoe UI', Arial, sans-serif;
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
        }
        .container {
            width: 340px;
            height: 700px;
            background: #232733;
            border-radius: 32px;
            box-shadow: 0 8px 32px rgba(0,0,0,0.45);
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            position: relative;
        }
        .top-bar {
            position: absolute;
            top: 0; left: 0; right: 0;
            height: 48px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 18px;
        }
        .back-arrow {
            font-size: 22px;
            color: #fff;
            cursor: pointer;
        }
        .signal {
            width: 32px;
            height: 8px;
            border-radius: 4px;
            background: #444;
            margin-left: auto;
        }
        .mic-outer {
            margin-top: 80px;
            margin-bottom: 40px;
            position: relative;
            width: 220px;
            height: 220px;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .progress-ring {
            position: absolute;
            top: 0; left: 0;
            width: 220px;
            height: 220px;
            z-index: 1;
        }
        .mic-btn {
            width: 120px;
            height: 120px;
            border-radius: 50%;
            background: linear-gradient(145deg, #232733 60%, #2e3340 100%);
            border: none;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 4px 24px #0008;
            cursor: pointer;
            z-index: 2;
            transition: background 0.2s;
        }
        .mic-btn.recording {
            background: linear-gradient(145deg, #1e90ff 60%, #00e0ff 100%);
        }
        .mic-btn svg {
            width: 54px;
            height: 54px;
            fill: #fff;
        }
        .status {
            margin: 24px 0 0 0;
            color: #b0b6c3;
            font-size: 18px;
            text-align: center;
            min-height: 28px;
        }
        .mic-btn-small {
            margin-top: 60px;
            width: 64px;
            height: 64px;
            border-radius: 50%;
            background: #232733;
            border: 2px solid #1e90ff;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 2px 8px #0006;
            cursor: pointer;
            transition: background 0.2s;
        }
        .mic-btn-small svg {
            width: 32px;
            height: 32px;
            fill: #1e90ff;
        }
    </style>
</head>
<body>
    <div class=\"container\">
        <div class=\"top-bar\">
            <span class=\"back-arrow\">&#8592;</span>
            <div class=\"signal\"></div>
        </div>
        <div class=\"mic-outer\">
            <svg class=\"progress-ring\" width=\"220\" height=\"220\">
                <circle r=\"100\" cx=\"110\" cy=\"110\" fill=\"none\" stroke=\"#22293a\" stroke-width=\"16\"/>
                <circle id=\"progressArc\" r=\"100\" cx=\"110\" cy=\"110\" fill=\"none\" stroke=\"#1e90ff\" stroke-width=\"12\" stroke-linecap=\"round\" stroke-dasharray=\"628\" stroke-dashoffset=\"628\"/>
            </svg>
            <button class=\"mic-btn\" id=\"recordBtn\">
                <svg viewBox=\"0 0 24 24\"><path d=\"M12 16a4 4 0 0 0 4-4V7a4 4 0 0 0-8 0v5a4 4 0 0 0 4 4zm5-4a1 1 0 1 1 2 0 6 6 0 0 1-6 6v2h3a1 1 0 1 1 0 2H7a1 1 0 1 1 0-2h3v-2a6 6 0 0 1-6-6 1 1 0 1 1 2 0 4 4 0 0 0 8 0z\"/></svg>
            </button>
        </div>
        <div class=\"status\" id=\"status\">Tap the mic to start recording</div>
        <button class=\"mic-btn-small\" id=\"recordBtnSmall\" style=\"display:none\">
            <svg viewBox=\"0 0 24 24\"><path d=\"M12 16a4 4 0 0 0 4-4V7a4 4 0 0 0-8 0v5a4 4 0 0 0 4 4zm5-4a1 1 0 1 1 2 0 6 6 0 0 1-6 6v2h3a1 1 0 1 1 0 2H7a1 1 0 1 1 0-2h3v-2a6 6 0 0 1-6-6 1 1 0 1 1 2 0 4 4 0 0 0 8 0z\"/></svg>
        </button>
    </div>
    <script>
        let mediaRecorder;
        let audioChunks = [];
        const recordBtn = document.getElementById('recordBtn');
        const recordBtnSmall = document.getElementById('recordBtnSmall');
        const status = document.getElementById('status');
        const progressArc = document.getElementById('progressArc');
        let progressInterval;
        let progress = 0;
        function animateProgress(start, end, duration) {
            let startTime = null;
            function animate(time) {
                if (!startTime) startTime = time;
                const elapsed = time - startTime;
                const percent = Math.min(elapsed / duration, 1);
                const value = start + (end - start) * percent;
                progressArc.setAttribute('stroke-dashoffset', 628 - 628 * value);
                if (percent < 1) {
                    requestAnimationFrame(animate);
                }
            }
            requestAnimationFrame(animate);
        }
        function startProgress() {
            progress = 0;
            progressArc.setAttribute('stroke-dashoffset', 628);
            progressInterval = setInterval(() => {
                progress += 0.01;
                if (progress > 1) progress = 1;
                progressArc.setAttribute('stroke-dashoffset', 628 - 628 * progress);
            }, 50);
        }
        function stopProgress() {
            clearInterval(progressInterval);
            animateProgress(progress, 1, 400);
        }
        async function setupRecording() {
            try {
                const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
                mediaRecorder = new MediaRecorder(stream);
                mediaRecorder.ondataavailable = (event) => {
                    audioChunks.push(event.data);
                };
                mediaRecorder.onstop = async () => {
                    stopProgress();
                    recordBtn.classList.remove('recording');
                    recordBtnSmall.style.display = 'none';
                    status.textContent = 'Processing...';
                    try {
                        const audioBlob = new Blob(audioChunks, { type: 'audio/wav' });
                        const formData = new FormData();
                        formData.append('audio', audioBlob);
                        const response = await fetch('/talk', {
                            method: 'POST',
                            body: formData
                        });
                        if (response.ok) {
                            const audioResponse = await response.blob();
                            const audioUrl = URL.createObjectURL(audioResponse);
                            const audio = new Audio(audioUrl);
                            audio.play();
                            status.textContent = 'AI response playing...';
                            audio.onended = () => {
                                status.textContent = 'Tap the mic to start recording';
                            };
                        } else {
                            throw new Error('Failed to process audio');
                        }
                    } catch (error) {
                        status.textContent = 'Error: ' + error.message;
                    }
                    audioChunks = [];
                };
            } catch (error) {
                status.textContent = 'Error accessing microphone: ' + error.message;
            }
        }
        async function handleRecordClick() {
            if (!mediaRecorder) {
                await setupRecording();
            }
            if (mediaRecorder.state === 'inactive') {
                // Start recording
                audioChunks = [];
                mediaRecorder.start();
                recordBtn.classList.add('recording');
                status.textContent = 'Recording... Tap again to stop';
                startProgress();
                recordBtnSmall.style.display = 'block';
            } else {
                // Stop recording
                mediaRecorder.stop();
                status.textContent = 'Processing your request...';
            }
        }
        recordBtn.addEventListener('click', handleRecordClick);
        recordBtnSmall.addEventListener('click', handleRecordClick);
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
                {"role": "system", "content": "You are a helpful HI health assistant."},
                {"role": "user", "content": user_text},
            ]
        )
        reply_text = chat.choices[0].message.content

        # 3️⃣ TTS
        speech = client.audio.speech.create(
            model="tts-1",
            voice="shimmer",
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
