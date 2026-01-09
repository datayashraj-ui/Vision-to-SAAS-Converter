import { Link } from 'react-router-dom';

export default function Home() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 flex items-center justify-center px-4">
      <div className="max-w-4xl text-center">
        <h1 className="text-5xl font-bold text-gray-900 mb-6">
          SaaS Architecture Blueprint Generator
        </h1>
        <p className="text-xl text-gray-700 mb-4">
          Transform your business ideas into production-ready technical specifications
        </p>
        <p className="text-lg text-gray-600 mb-8">
          AI-powered research, decision simulation, and comprehensive blueprints that force
          coding tools to build real full-stack SaaS products—not demos.
        </p>
        <Link
          to="/chat"
          className="inline-block bg-indigo-600 text-white px-8 py-4 rounded-lg text-lg font-semibold hover:bg-indigo-700 transition-colors"
        >
          Start New Blueprint
        </Link>
        <div className="mt-12 grid grid-cols-1 md:grid-cols-3 gap-6 text-left">
          <div className="bg-white p-6 rounded-lg shadow-md">
            <h3 className="font-bold text-lg mb-2">Vision Validation</h3>
            <p className="text-gray-600">Logical consistency checks with educational feedback</p>
          </div>
          <div className="bg-white p-6 rounded-lg shadow-md">
            <h3 className="font-bold text-lg mb-2">Autonomous Research</h3>
            <p className="text-gray-600">GitHub, Product Hunt, academic papers, and best practices</p>
          </div>
          <div className="bg-white p-6 rounded-lg shadow-md">
            <h3 className="font-bold text-lg mb-2">Production-Ready Specs</h3>
            <p className="text-gray-600">Complete blueprints with 10 test cases guaranteeing real functionality</p>
          </div>
        </div>
      </div>
    </div>
  );
}
