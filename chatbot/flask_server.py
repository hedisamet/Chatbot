from flask import Flask, request, jsonify
import openai
import os
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)

# Set up OpenAI API
openai.api_type = "azure"
openai.api_base = "https://learnfromengineering.openai.azure.com/"
openai.api_version = "2023-09-15-preview"
openai.api_key = os.getenv("OPENAI_API_KEY")

# Define initial message
message_text = [
    {
        "role": "system",
        "content": (
            "Act as a psychotherapist, and I will act like a patient. "
            "I need you to help me apply the cognitive behavioral therapy method to reduce a patient's level of anxiety. "
            "When the chat starts with a greeting, ask: 'What is the main cause of your anxiety?' "
            "Based on the patient's responses, ask up to two follow-up questions at a time to gradually help them explore and challenge their thoughts and feelings. "
            "Be prepared to respond in Arabic, Tunisian Arabic, French, and English, depending on the language the user is speaking."
        )
    }
]

@app.route('/chat', methods=['POST'])
def chat():
    try:
        user_input = request.json['user_input']
        user_info = request.json.get('user_info', {})  # Extract user information if any

        message_text.append({"role": "user", "content": user_input})

        # Generate response considering user information
        ai_response = generate_response(user_input, user_info, message_text)

        # Add the AI's response to the conversation
        message_text.append({"role": "assistant", "content": ai_response})

        return jsonify({'ai_response': ai_response})
    except Exception as e:
        print(f"Error: {e}")
        return jsonify({'error': str(e)}), 500

def generate_response(user_input, user_info, message_text):
    # Append user information to the conversation history
    if user_info:
        user_info_message = {"role": "system", "content": f"User Info: {user_info}"}
        message_text.append(user_info_message)

    # Pass the updated conversation history to OpenAI for response generation
    completion = openai.ChatCompletion.create(
            engine="DeploymentGPT35T",  # Replace with your engine name
            messages=message_text,
            temperature=0.7,
            max_tokens=800,
            top_p=0.95,
            frequency_penalty=0,
            presence_penalty=0
    )

    # Extract the AI's response from the completion
    ai_response = completion.choices[0].message['content']

    return ai_response

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
