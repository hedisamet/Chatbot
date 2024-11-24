FROM python:3.8-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 5000

CMD ["python", "flask_server.py"]

#docker build -t chatbot:latest .
#docker tag chatbot melekbadreddine/chatbot:latest
#docker push  melekbadreddine/chatbot:latest
