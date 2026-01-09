import Layout from '../components/Layout';

export default function Chat() {
  return (
    <Layout>
      <div className="bg-gray-50 min-h-full">
        <div className="max-w-4xl mx-auto p-8">
          <h1 className="text-3xl font-bold text-gray-900 mb-4">
            Blueprint Conversation
          </h1>
          <p className="text-gray-600 mb-8">
            Conversational interface will be built in Phase 2
          </p>
          <div className="bg-white border border-gray-200 rounded-lg p-6">
            <p className="text-gray-500 italic">
              Chat interface placeholder - Phase 2 will implement the full conversational system
            </p>
          </div>
        </div>
      </div>
    </Layout>
  );
}
