import chromadb
from sentence_transformers import SentenceTransformer
import uuid
from datetime import datetime


class VectorStoreManager:
    def __init__(self, persist_directory="./chroma_db"):
        self.client = chromadb.PersistentClient(path=persist_directory)
        self.collection = self.client.get_or_create_collection(
            name="mental_health_messages",
            metadata={"description": "Stored chat messages for semantic search"}
        )
        self.embedder = SentenceTransformer('all-MiniLM-L6-v2')

    def generate_unique_id(self, user_id, session_id, content, role):
        """Generate a unique ID based on content and timestamp"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S_%f")
        content_hash = hash(content + role) % 10000  # Include role in hash
        return f"{user_id}_{session_id}_{content_hash}_{timestamp}"

    def add_message(self, message_data, content, user_id, session_id, role="user"):
        """Add message to vector store with unique ID"""
        # Generate unique ID
        unique_id = self.generate_unique_id(user_id, session_id, content, role)

        metadata = {
            "user_id": user_id,
            "session_id": session_id,
            "message_id": message_data.get("message_id", "unknown"),
            "role": role,
            "timestamp": message_data.get("timestamp", datetime.utcnow()).isoformat(),
            "content_type": "chat_message"
        }

        try:
            # Check if similar content already exists to avoid duplicates
            existing = self.collection.get(ids=[unique_id])
            if not existing['ids']:
                self.collection.add(
                    documents=[content],
                    metadatas=[metadata],
                    ids=[unique_id]
                )
                print(f"✅ Added message to vector store: {unique_id}")
            else:
                print(f"⚠️ Message already exists: {unique_id}")

        except Exception as e:
            print(f"❌ Error adding to vector store: {e}")

        return unique_id

    def semantic_search(self, query, user_id, n_results=10):
        """Perform semantic search across ALL user messages"""
        try:
            # First, check how many documents we have for this user
            all_user_docs = self.collection.get(where={"user_id": user_id})
            total_user_docs = len(all_user_docs['ids'])

            print(
                f"🔍 Semantic search: User {user_id} has {total_user_docs} messages in vector store")

            if total_user_docs == 0:
                print("⚠️ No messages found for user in vector store")
                return {'documents': [[]], 'metadatas': [[]], 'distances': [[]]}

            # Adjust n_results to not exceed available documents
            safe_n_results = min(n_results, total_user_docs)

            print(
                f"🔍 Searching for {safe_n_results} results out of {total_user_docs} available")

            # Perform the search - remove the user_id filter to search across all content
            # but we'll filter results by user_id manually if needed
            results = self.collection.query(
                query_texts=[query],
                n_results=safe_n_results,
                # Remove the where clause to search across all messages
                # We'll filter by user_id in the results processing
            )

            # Filter results by user_id
            filtered_documents = []
            filtered_metadatas = []
            filtered_distances = []

            if results['documents'] and results['documents'][0]:
                for i, metadata in enumerate(results['metadatas'][0]):
                    if metadata.get('user_id') == user_id:
                        filtered_documents.append(results['documents'][0][i])
                        filtered_metadatas.append(metadata)
                        if results['distances'] and results['distances'][0]:
                            filtered_distances.append(
                                results['distances'][0][i])

            print(
                f"✅ Found {len(filtered_documents)} relevant messages from user's history")

            return {
                'documents': [filtered_documents],
                'metadatas': [filtered_metadatas],
                'distances': [filtered_distances]
            }

        except Exception as e:
            print(f"❌ Semantic search error: {e}")
            return {'documents': [[]], 'metadatas': [[]], 'distances': [[]]}

    def get_relevant_context(self, query, user_id, current_session_id, max_results=5):
        """Get semantically relevant context from ALL user sessions (excluding current)"""
        try:
            print(
                f"🔍 Getting context for user {user_id}, excluding session {current_session_id}")

            search_results = self.semantic_search(
                query, user_id, n_results=max_results * 3)

            # Check if we have any results
            if not search_results['documents'][0]:
                print("⚠️ No search results found")
                return []

            relevant_messages = []
            for doc, metadata in zip(search_results['documents'][0], search_results['metadatas'][0]):
                # Exclude messages from current session (they'll be included separately)
                if metadata.get('session_id') != current_session_id:
                    relevant_messages.append({
                        "content": doc,
                        "session_id": metadata.get('session_id'),
                        "role": metadata.get('role', 'user'),
                        "source": "historical"
                    })
                    print(
                        f"📝 Added historical context from session {metadata.get('session_id')}")

            print(
                f"✅ Returning {len(relevant_messages)} historical context messages")
            return relevant_messages[:max_results]

        except Exception as e:
            print(f"❌ Error getting relevant context: {e}")
            return []

    def get_collection_stats(self):
        """Get statistics about the vector store collection"""
        try:
            count = self.collection.count()
            return {
                "total_messages": count,
                "collection_name": self.collection.name
            }
        except Exception as e:
            return {"error": str(e)}
