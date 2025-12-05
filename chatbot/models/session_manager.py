from langchain_ollama import ChatOllama
from langchain.schema import HumanMessage, AIMessage
from langchain.prompts import PromptTemplate
from utils.token_manager import TokenManager
from utils.embeddings import VectorStoreManager
import re


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
                model="mistral",       # make sure you did: ollama pull mistral
                temperature=0.7,
                top_p=0.95,
                num_ctx=4096,
                timeout=30  # Add timeout for better error handling
            )

            # Test the connection
            test_response = llm.invoke("Hello")
            print("✅ Ollama connection successful")
            return llm

        except Exception as e:
            print(f"❌ LLM initialization failed: {e}")
            print("💡 Make sure Ollama is running: `ollama serve`")
            print("💡 And Mistral is pulled: `ollama pull mistral`")
            return MockLLM()

    def _create_prompt_template(self):
        """Create the mental health assistant prompt template"""
        template = """You are a compassionate mental health assistant specialized in helping athletes. 
You provide supportive, empathetic, and professional guidance while maintaining confidentiality.

Context from previous conversations:
{historical_context}

Current conversation history:
{conversation_history}

User: {user_message}
Assistant:"""

        return PromptTemplate(
            template=template,
            input_variables=["historical_context",
                             "conversation_history", "user_message"]
        )

    def generate_session_name(self, first_message):
        """Generate session name from first message"""
        words = first_message.split()[:10]
        session_name = " ".join(words)
        if len(session_name) > 50:
            session_name = session_name[:47] + "..."
        return session_name

    def build_context(self, current_messages, semantic_context, user_message):
        """Build the complete context for the LLM"""
        # Format conversation history
        conversation_history = ""
        for msg in current_messages:
            role = "User" if msg["role"] == "user" else "Assistant"
            conversation_history += f"{role}: {msg['content']}\n"

        # Format historical context
        historical_context = ""
        if semantic_context:
            historical_context = "Relevant insights from previous conversations:\n"
            for ctx in semantic_context:
                historical_context += f"- {ctx['content']}\n"

        return {
            "historical_context": historical_context,
            "conversation_history": conversation_history,
            "user_message": user_message
        }

    def generate_response(self, context):
        """Generate response using LLM"""
        try:
            prompt = self.prompt_template.format(**context)

            # Invoke the model - ChatOllama returns an AIMessage object
            response = self.llm.invoke(prompt)

            # Extract content from AIMessage object
            if hasattr(response, 'content'):
                return response.content.strip()
            else:
                # Fallback if it's not the expected type
                return str(response).strip()

        except Exception as e:
            print(f"❌ LLM Error: {e}")
            return "I'm here to support you. Could you tell me more about what you're experiencing?"

    def build_context(self, current_messages, semantic_context, user_message):
        """Build the complete context for the LLM"""
        # Format conversation history
        conversation_history = ""
        for msg in current_messages:
            role = "User" if msg["role"] == "user" else "Assistant"
            conversation_history += f"{role}: {msg['content']}\n"

        # Format historical context
        historical_context = ""
        if semantic_context:
            historical_context = "Relevant insights from previous conversations:\n"
            for i, ctx in enumerate(semantic_context):
                historical_context += f"{i+1}. {ctx['content']}\n"
            print(
                f"📚 Using {len(semantic_context)} historical context messages")
        else:
            print("📚 No historical context available")

        print(
            f"💭 Current conversation history: {len(current_messages)} messages")
        print(f"🎯 User message: {user_message[:100]}...")

        return {
            "historical_context": historical_context,
            "conversation_history": conversation_history,
            "user_message": user_message
        }


class MockLLM:
    """Mock LLM for testing when Ollama isn't available"""

    def invoke(self, prompt):
        # Provide more varied responses for testing
        responses = [
            "I understand this is challenging. As your mental health assistant, I'm here to support you through this. Many athletes face similar pressures, and it's completely normal to feel this way. Let's work through this together.",
            "Thank you for sharing that with me. It takes courage to open up about these feelings. Remember that many successful athletes experience similar challenges. What strategies have helped you cope in the past?",
            "I hear you, and I want you to know that your feelings are valid. The pressure of competition can be overwhelming at times. Let's explore some techniques to manage this stress together.",
            "That sounds really difficult. As an athlete, you're constantly pushing your limits, both physically and mentally. It's important to acknowledge these feelings rather than suppress them. Would you like to talk more about what specifically is troubling you?"
        ]
        import random
        return responses[random.randint(0, len(responses)-1)]
