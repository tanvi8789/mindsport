from flask import Flask, render_template, request, jsonify
from flask_cors import CORS  # Add this import
from models.database import DatabaseManager
from models.session_manager import SessionManager
from utils.token_manager import TokenManager
import json
from datetime import datetime
from bson import ObjectId

app = Flask(__name__)

# ========== CORS CONFIGURATION ==========
# Configure CORS properly for Flutter
CORS(app, resources={
    r"/api/*": {
        "origins": "*",  # Allow all origins for testing
        "methods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        "allow_headers": ["Content-Type", "Authorization"],
        "expose_headers": ["Content-Type"],
        "supports_credentials": False,
        "max_age": 3600
    }
})

# Or for more restrictive setup during development:
# CORS(app, origins=["http://localhost:3000", "http://127.0.0.1:3000",
#                    "http://10.0.2.2:3000", "http://192.168.1.*"])

db_manager = DatabaseManager()
session_manager = SessionManager()
token_manager = TokenManager()

# ========== HELPER MIDDLEWARE ==========


@app.after_request
def after_request(response):
    """Add CORS headers to all responses"""
    # These headers will help with Flutter debugging
    response.headers.add('Access-Control-Allow-Origin', '*')
    response.headers.add('Access-Control-Allow-Headers',
                         'Content-Type,Authorization')
    response.headers.add('Access-Control-Allow-Methods',
                         'GET,PUT,POST,DELETE,OPTIONS')
    response.headers.add('Access-Control-Allow-Credentials', 'true')
    response.headers.add(
        'Cache-Control', 'no-cache, no-store, must-revalidate')
    response.headers.add('Pragma', 'no-cache')
    response.headers.add('Expires', '0')
    return response


@app.route('/')
def index():
    """Serve the main chat interface"""
    return render_template('index.html')


@app.route('/api/chat', methods=['POST', 'OPTIONS'])
def chat():
    """Main chat endpoint with CORS support"""
    # Handle preflight OPTIONS request
    if request.method == 'OPTIONS':
        return jsonify({}), 200

    try:
        data = request.get_json()
        user_id = data.get('user_id', '001')
        session_id = data.get('session_id')
        message = data.get('message', '').strip()

        if not message:
            return jsonify({"error": "Message cannot be empty"}), 400

        # Create user if doesn't exist
        db_manager.create_user(user_id)

        # Create new session if no session_id provided
        if not session_id:
            session_name = session_manager.generate_session_name(message)
            session_id = db_manager.create_session(user_id, session_name)
            print(f"🆕 Created new session: {session_id} - {session_name}")

        # Get current session messages
        current_messages = db_manager.get_session_messages(session_id)
        print(f"💬 Current session has {len(current_messages)} messages")

        # Get vector store stats
        vector_stats = session_manager.vector_store.get_collection_stats()
        print(f"📊 Vector store stats: {vector_stats}")

        # Perform semantic search for relevant context from ALL sessions
        semantic_context = session_manager.vector_store.get_relevant_context(
            message, user_id, session_id, max_results=5
        )

        print(
            f"🎯 Found {len(semantic_context)} relevant messages from historical sessions")

        # Build complete context
        context = session_manager.build_context(
            current_messages, semantic_context, message)

        # Generate response
        assistant_response = session_manager.generate_response(context)

        # Calculate tokens
        user_tokens = token_manager.count_tokens(message)
        assistant_tokens = token_manager.count_tokens(assistant_response)

        # Save messages to database
        user_message_data = db_manager.save_message(
            session_id, user_id, message, "user", user_tokens)
        assistant_message_data = db_manager.save_message(
            session_id, user_id, assistant_response, "assistant", assistant_tokens)

        # Save USER message to vector store for future semantic search
        session_manager.vector_store.add_message(
            message_data=user_message_data,
            content=message,
            user_id=user_id,
            session_id=session_id,
            role="user"
        )

        # Also save ASSISTANT message to vector store
        session_manager.vector_store.add_message(
            message_data=assistant_message_data,
            content=assistant_response,
            user_id=user_id,
            session_id=session_id,
            role="assistant"
        )

        # Update session timestamp
        db_manager.update_session_timestamp(session_id)

        return jsonify({
            "session_id": session_id,
            "response": assistant_response,
            "user_id": user_id,
            "tokens_used": user_tokens + assistant_tokens,
            "historical_context_used": len(semantic_context),
            "vector_store_stats": vector_stats
        })

    except Exception as e:
        print(f"❌ Chat endpoint error: {e}")
        return jsonify({"error": str(e)}), 500


@app.route('/api/sessions/<user_id>', methods=['GET'])
def get_sessions(user_id):
    """Get all sessions for a user"""
    try:
        sessions = db_manager.get_user_sessions(user_id)

        # Convert sessions to proper JSON
        formatted_sessions = []
        for session in sessions:
            # Convert ObjectId to string
            session['_id'] = str(session['_id'])

            # Convert dates to ISO format
            if 'created_at' in session and session['created_at']:
                if isinstance(session['created_at'], datetime):
                    session['created_at'] = session['created_at'].isoformat()
                elif isinstance(session['created_at'], ObjectId):
                    # Extract timestamp from ObjectId
                    session['created_at'] = datetime.fromtimestamp(
                        session['created_at'].generation_time.timestamp()
                    ).isoformat()

            if 'updated_at' in session and session['updated_at']:
                if isinstance(session['updated_at'], datetime):
                    session['updated_at'] = session['updated_at'].isoformat()
                elif isinstance(session['updated_at'], ObjectId):
                    session['updated_at'] = datetime.fromtimestamp(
                        session['updated_at'].generation_time.timestamp()
                    ).isoformat()

            formatted_sessions.append(session)

        return jsonify({"sessions": formatted_sessions})
    except Exception as e:
        print(f"❌ Error in get_sessions: {e}")
        return jsonify({"error": str(e)}), 500


@app.route('/api/messages/<session_id>', methods=['GET'])
def get_messages(session_id):
    """Get messages for a specific session"""
    try:
        messages = db_manager.get_session_messages(session_id)

        # Convert messages to proper JSON
        formatted_messages = []
        for message in messages:
            # Convert ObjectId to string
            message['_id'] = str(message['_id'])

            # Convert timestamp to ISO format
            if 'timestamp' in message and message['timestamp']:
                if isinstance(message['timestamp'], datetime):
                    message['timestamp'] = message['timestamp'].isoformat()
                elif isinstance(message['timestamp'], ObjectId):
                    # Extract timestamp from ObjectId
                    message['timestamp'] = datetime.fromtimestamp(
                        message['timestamp'].generation_time.timestamp()
                    ).isoformat()

            formatted_messages.append(message)

        return jsonify({"messages": formatted_messages})
    except Exception as e:
        print(f"❌ Error in get_messages: {e}")
        return jsonify({"error": str(e)}), 500


@app.route('/api/debug/vector-store', methods=['GET', 'OPTIONS'])
def debug_vector_store():
    """Debug endpoint to check vector store contents"""
    if request.method == 'OPTIONS':
        return jsonify({}), 200

    try:
        user_id = request.args.get('user_id', '001')
        stats = session_manager.vector_store.get_collection_stats()

        # Get sample messages from vector store
        sample_results = session_manager.vector_store.collection.get(
            where={"user_id": user_id},
            limit=5
        )

        return jsonify({
            "vector_store_stats": stats,
            "sample_messages": sample_results
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# ========== HEALTH CHECK ENDPOINT ==========


@app.route('/api/health', methods=['GET'])
def health_check():
    """Simple health check endpoint for testing"""
    return jsonify({
        "status": "healthy",
        "message": "Flask server is running",
        "timestamp": datetime.now().isoformat()
    })


if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=True, port=5000)
