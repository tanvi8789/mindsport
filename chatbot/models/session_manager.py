from langchain_ollama import ChatOllama
from langchain.prompts import PromptTemplate
from utils.token_manager import TokenManager
from utils.embeddings import VectorStoreManager
import requests


class SessionManager:
    def __init__(self):
        self.token_manager = TokenManager()
        self.vector_store = VectorStoreManager()
        self.llm = self._initialize_llm()
        self.prompt_template = self._create_prompt_template()

    def _initialize_llm(self):
        """Initialize the Ollama model"""
        try:
            llm = ChatOllama(
                model="mistral",
                temperature=0.7,
                top_p=0.95,
                num_ctx=4096,
                timeout=30
            )

            # Test connection
            llm.invoke("Hello")
            print("✅ Ollama connection successful")
            return llm

        except Exception as e:
            print(f"❌ LLM initialization failed: {e}")
            print("Make sure Ollama is running and model is installed.")
            return MockLLM()

    # -----------------------------------------------------------
    # Utility: generate a session name from first message
    # -----------------------------------------------------------
    def generate_session_name(self, first_message):
        """
        Create a short session name from the user's first message.
        App uses this when creating a new session in app.py.
        """
        if not first_message:
            return "New session"
        words = first_message.strip().split()
        # take up to first 10 words joined, cap length to 50 chars
        name = " ".join(words[:10])
        if len(name) > 50:
            name = name[:47].rstrip() + "..."
        return name

    # -----------------------------------------------------------
    # 🔥 FETCH TODAY'S MOOD FROM BACKEND
    # -----------------------------------------------------------
    def get_todays_mood(self, user_id):
        """Fetch today's mood from the Node backend"""
        try:
            url = f"https://mindsport-backend.onrender.com/api/moods/today/{user_id}"
            response = requests.get(url, timeout=5)

            if response.status_code == 200:
                data = response.json()

                if isinstance(data, dict) and data.get("message") == "No mood logged for today.":
                    return None

                return data
            else:
                print("⚠️ Mood API returned error:", response.text)
                return None

        except Exception as e:
            print("❌ Error fetching mood:", e)
            return None

    # -----------------------------------------------------------
    # 🔥 PROMPT TEMPLATE INCLUDING TODAY'S MOOD
    # -----------------------------------------------------------
    def _create_prompt_template(self):
        template = """
You are a compassionate mental health assistant specialized in helping athletes.

User's mood today:
{todays_mood}

Context from previous conversations:
{historical_context}

Current conversation history:
{conversation_history}

User: {user_message}
Assistant:"""

        return PromptTemplate(
            template=template,
            input_variables=[
                "historical_context",
                "conversation_history",
                "user_message",
                "todays_mood"
            ]
        )

    # -----------------------------------------------------------
    # 🔥 BUILD CONTEXT INCLUDING TODAY’S MOOD
    # -----------------------------------------------------------
    def build_context(self, current_messages, semantic_context, user_message, user_id):
        """Build context for LLM"""

        # Fetch today's mood
        mood_data = self.get_todays_mood(user_id)

        if mood_data:
            todays_mood = (
                f"Mood: {mood_data.get('mood', 'N/A')}, "
                f"Reason: {mood_data.get('reason', 'N/A')}, "
                f"Sleep: {mood_data.get('sleep', 'N/A')}/10, "
                f"Physical: {mood_data.get('physical', 'N/A')}/10"
            )
        else:
            todays_mood = "No mood logged for today."

        # Build conversation history
        conversation_history = ""
        for msg in current_messages:
            role = "User" if msg.get("role") == "user" else "Assistant"
            # ensure content exists
            content = msg.get("content", "")
            conversation_history += f"{role}: {content}\n"

        # Build historical semantic context
        historical_context = ""
        if semantic_context:
            historical_context = "Insights from previous sessions:\n"
            for i, ctx in enumerate(semantic_context):
                content = ctx.get("content", "")
                historical_context += f"{i+1}. {content}\n"

        return {
            "historical_context": historical_context,
            "conversation_history": conversation_history,
            "user_message": user_message,
            "todays_mood": todays_mood
        }

    # -----------------------------------------------------------
    # 🔥 LLM RESPONSE
    # -----------------------------------------------------------
    def generate_response(self, context):
        try:
            prompt = self.prompt_template.format(**context)
            response = self.llm.invoke(prompt)

            if hasattr(response, "content"):
                return response.content.strip()
            return str(response).strip()

        except Exception as e:
            print(f"❌ LLM Error: {e}")
            return "I'm here for you — can you tell me more about what you're feeling?"


class MockLLM:
    """Fallback model when Ollama is unavailable"""

    def invoke(self, prompt):
        responses = [
            "I'm here for you. Tell me more.",
            "That sounds tough. I'm listening.",
            "I understand. What happened?",
        ]
        import random
        return responses[random.randint(0, len(responses)-1)]
