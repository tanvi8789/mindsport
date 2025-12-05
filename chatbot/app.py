from flask import Flask, render_template, request, jsonify
from flask_cors import CORS
from models.database import DatabaseManager
from models.session_manager import SessionManager
from utils.token_manager import TokenManager
from datetime import datetime
from bson import ObjectId

app = Flask(__name__)

# ===================== CORS CONFIG ======================
CORS(app, resources={
    r"/api/*": {
        "origins": "*",
        "methods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        "allow_headers": ["Content-Type", "Authorization"],
        "expose_headers": ["Content-Type"],
        "supports_credentials": False,
        "max_age": 3600
    }
})

db_manager = DatabaseManager()
session_manager = SessionManager()
token_manager = TokenManager()

# ========================================================
# Add headers to every response
# ========================================================


@app.after_request
def after_request(response):
    response.headers.add('Access-Control-Allow-Origin', '*')
    response.headers.add('Access-Control-Allow-Headers',
                         'Content-Type, Authorization')
    response.headers.add('Access-Control-Allow-Methods',
                         'GET, PUT, POST, DELETE, OPTIONS')
    return response

# ========================================================
# Home Route
# ========================================================


@app.route('/')
def index():
    return render_template('index.html')

# ========================================================
# 🔥 MAIN CHAT ENDPOINT (Mood-aware SessionManager)
# ========================================================


@app.route('/api/chat', methods=['POST', 'OPTIONS'])
def chat():
    # Preflight CORS
    if request.method == 'OPTIONS':
        return jsonify({}), 200

    try:
        data = request.get_json()

        # Extract fields from frontend
        user_id = data.get('user_id', '001')  # default for testing
        session_id = data.get('session_id')
        message = data.get('message', '').strip()

        if not message:
            return jsonify({"error": "Message cannot be empty"}), 400

        # Ensure user exists
        db_manager.create_user(user_id)

        # Create session if none exists
        if not session_id:
            session_name = session_manager.generate_session_name(message)
            session_id = db_manager.create_session(user_id, session_name)
            print(f"🆕 New session: {session_id} - {session_name}")

        # Load chat history for this session
        current_messages = db_manager.get_session_messages(session_id)
        print(f"💬 Loaded {len(current_messages)} past messages")

        # Get semantic context from vector store
        semantic_context = session_manager.vector_store.get_relevant_context(
            message, user_id, session_id, max_results=5
        )
        print(f"📚 {len(semantic_context)} relevant historical items found")

        # ====================================================
        # 🔥 FIXED — Pass user_id into session manager so mood works
        # ====================================================
        context = session_manager.build_context(
            current_messages,
            semantic_context,
            message,
            user_id  # <-- This enables today's mood
        )

        # Generate AI response
        assistant_response = session_manager.generate_response(context)

        # Token usage calculation
        user_tokens = token_manager.count_tokens(message)
        assistant_tokens = token_manager.count_tokens(assistant_response)

        # Save messages into MongoDB
        user_msg_data = db_manager.save_message(
            session_id, user_id, message, "user", user_tokens
        )
        assistant_msg_data = db_manager.save_message(
            session_id, user_id, assistant_response, "assistant", assistant_tokens
        )

        # Save to vector store
        session_manager.vector_store.add_message(
            message_data=user_msg_data,
            content=message,
            user_id=user_id,
            session_id=session_id,
            role="user"
        )
        session_manager.vector_store.add_message(
            message_data=assistant_msg_data,
            content=assistant_response,
            user_id=user_id,
            session_id=session_id,
            role="assistant"
        )

        # Update session last modified timestamp
        db_manager.update_session_timestamp(session_id)

        return jsonify({
            "session_id": session_id,
            "response": assistant_response,
            "user_id": user_id,
            "tokens_used": user_tokens + assistant_tokens,
            "historical_context_used": len(semantic_context)
        })

    except Exception as e:
        print(f"❌ Chat error: {e}")
        return jsonify({"error": str(e)}), 500

# ========================================================
# Get all sessions for a user
# ========================================================


@app.route('/api/sessions/<user_id>', methods=['GET'])
def get_sessions(user_id):
    try:
        sessions = db_manager.get_user_sessions(user_id)
        formatted = []

        for session in sessions:
            session['_id'] = str(session['_id'])

            # Convert timestamps
            if isinstance(session.get('created_at'), datetime):
                session['created_at'] = session['created_at'].isoformat()

            if isinstance(session.get('updated_at'), datetime):
                session['updated_at'] = session['updated_at'].isoformat()

            formatted.append(session)

        return jsonify({"sessions": formatted})

    except Exception as e:
        print(f"❌ Error fetching sessions: {e}")
        return jsonify({"error": str(e)}), 500

# ========================================================
# Get all messages for a session
# ========================================================


@app.route('/api/messages/<session_id>', methods=['GET'])
def get_messages(session_id):
    try:
        messages = db_manager.get_session_messages(session_id)
        formatted = []

        for msg in messages:
            msg['_id'] = str(msg['_id'])

            if isinstance(msg.get('timestamp'), datetime):
                msg['timestamp'] = msg['timestamp'].isoformat()

            formatted.append(msg)

        return jsonify({"messages": formatted})

    except Exception as e:
        print(f"❌ Error fetching messages: {e}")
        return jsonify({"error": str(e)}), 500

# ========================================================
# Debug Vector Store
# ========================================================


@app.route('/api/debug/vector-store', methods=['GET', 'OPTIONS'])
def debug_vector_store():
    if request.method == 'OPTIONS':
        return jsonify({}), 200

    try:
        user_id = request.args.get('user_id', '001')
        stats = session_manager.vector_store.get_collection_stats()

        sample = session_manager.vector_store.collection.get(
            where={"user_id": user_id},
            limit=5
        )

        return jsonify({
            "vector_store_stats": stats,
            "sample_messages": sample
        })

    except Exception as e:
        return jsonify({"error": str(e)}), 500

# ========================================================
# Health Check
# ========================================================


@app.route('/api/health', methods=['GET'])
def health_check():
    return jsonify({
        "status": "healthy",
        "message": "Flask server is running",
        "timestamp": datetime.now().isoformat()
    })


# ========================================================
# Run Server
# ========================================================
if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=True, port=5000)
