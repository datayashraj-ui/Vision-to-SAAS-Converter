import { useEffect } from 'react';
import Layout from '../components/Layout';
import MessageList from '../components/MessageList';
import ChatInput from '../components/ChatInput';
import { useConversation } from '../hooks/useConversation';

export default function Chat() {
  const {
    messages,
    isLoading,
    startConversation,
    sendMessage,
  } = useConversation();

  useEffect(() => {
    // Start a new conversation when component mounts
    startConversation();
  }, [startConversation]);

  return (
    <Layout>
      <div className="flex flex-col h-[calc(100vh-64px)]">
        {/* Header */}
        <div className="bg-white border-b border-gray-200 px-4 py-4">
          <div className="max-w-4xl mx-auto">
            <h1 className="text-2xl font-bold text-gray-900">
              Blueprint Conversation
            </h1>
            <p className="text-sm text-gray-600 mt-1">
              Describe your SaaS idea and I'll create production-ready specifications
            </p>
          </div>
        </div>

        {/* Message History */}
        <MessageList messages={messages} isLoading={isLoading} />

        {/* Input */}
        <ChatInput
          onSendMessage={sendMessage}
          disabled={isLoading}
          placeholder="Describe your SaaS idea in detail..."
        />
      </div>
    </Layout>
  );
}
