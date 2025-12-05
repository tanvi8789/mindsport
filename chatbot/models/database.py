from pymongo import MongoClient
from datetime import datetime
import uuid


class DatabaseManager:
    def __init__(self, mongo_uri="mongodb://localhost:27017/", db_name="mindsport-mistral"):
        self.client = MongoClient(mongo_uri)
        self.db = self.client[db_name]
        self.users = self.db.users
        self.sessions = self.db.sessions
        self.messages = self.db.messages

    def create_user(self, user_id):
        """Create a new user if doesn't exist"""
        if not self.users.find_one({"user_id": user_id}):
            self.users.insert_one({
                "user_id": user_id,
                "created_at": datetime.utcnow()
            })

    def create_session(self, user_id, session_name):
        """Create a new session"""
        session_id = str(uuid.uuid4())
        session_data = {
            "session_id": session_id,
            "user_id": user_id,
            "session_name": session_name,
            "created_at": datetime.utcnow(),
            "updated_at": datetime.utcnow()
        }
        self.sessions.insert_one(session_data)
        return session_id

    def save_message(self, session_id, user_id, content, role, tokens):
        """Save message to database"""
        message_data = {
            "message_id": str(uuid.uuid4()),
            "session_id": session_id,
            "user_id": user_id,
            "content": content,
            "role": role,  # "user" or "assistant"
            "timestamp": datetime.utcnow(),
            "tokens": tokens
        }
        self.messages.insert_one(message_data)
        return message_data

    def get_user_sessions(self, user_id):
        """Get all sessions for a user"""
        return list(self.sessions.find(
            {"user_id": user_id},
            sort=[("updated_at", -1)]
        ))

    def get_session_messages(self, session_id, limit=100):
        """Get messages for a specific session"""
        return list(self.messages.find(
            {"session_id": session_id},
            sort=[("timestamp", 1)]
        ).limit(limit))

    def update_session_timestamp(self, session_id):
        """Update session's last activity timestamp"""
        self.sessions.update_one(
            {"session_id": session_id},
            {"$set": {"updated_at": datetime.utcnow()}}
        )
