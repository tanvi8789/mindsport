import tiktoken

class TokenManager:
    def __init__(self):
        self.encoding = tiktoken.get_encoding("cl100k_base")
    
    def count_tokens(self, text):
        """Count tokens in text"""
        return len(self.encoding.encode(text))
    
    def truncate_messages_to_token_limit(self, messages, max_tokens=5000):
        """Truncate messages to fit within token limit"""
        total_tokens = 0
        truncated_messages = []
        
        # Add messages from the end until we hit the token limit
        for message in reversed(messages):
            message_tokens = self.count_tokens(message["content"])
            if total_tokens + message_tokens <= max_tokens:
                truncated_messages.insert(0, message)
                total_tokens += message_tokens
            else:
                break
                
        return truncated_messages, total_tokens