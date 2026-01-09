import { useState, useCallback } from 'react';
import { Message, Conversation, ConversationState } from '../types/conversation';
import { v4 as uuidv4 } from 'uuid';

export function useConversation() {
  const [state, setState] = useState<ConversationState>({
    currentConversation: null,
    isLoading: false,
    error: null,
  });

  const startConversation = useCallback(() => {
    const newConversation: Conversation = {
      id: uuidv4(),
      messages: [],
      createdAt: new Date(),
      updatedAt: new Date(),
    };
    setState((prev) => ({
      ...prev,
      currentConversation: newConversation,
      error: null,
    }));
  }, []);

  const addMessage = useCallback((role: 'user' | 'assistant', content: string) => {
    setState((prev) => {
      if (!prev.currentConversation) return prev;

      const newMessage: Message = {
        id: uuidv4(),
        role,
        content,
        timestamp: new Date(),
      };

      return {
        ...prev,
        currentConversation: {
          ...prev.currentConversation,
          messages: [...prev.currentConversation.messages, newMessage],
          updatedAt: new Date(),
        },
      };
    });
  }, []);

  const sendMessage = useCallback(async (content: string) => {
    // Add user message immediately
    addMessage('user', content);

    // TODO Phase 3: Call Claude API for vision validation
    // For now, mock response
    setState((prev) => ({ ...prev, isLoading: true }));

    setTimeout(() => {
      addMessage(
        'assistant',
        'Thank you for sharing your SaaS idea! Vision validation will be implemented in Phase 3. For now, I\'m acknowledging your message.'
      );
      setState((prev) => ({ ...prev, isLoading: false }));
    }, 1000);
  }, [addMessage]);

  const clearConversation = useCallback(() => {
    setState({
      currentConversation: null,
      isLoading: false,
      error: null,
    });
  }, []);

  return {
    conversation: state.currentConversation,
    messages: state.currentConversation?.messages || [],
    isLoading: state.isLoading,
    error: state.error,
    startConversation,
    sendMessage,
    clearConversation,
  };
}
