/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import React, { useState } from 'react';
import { motion } from 'motion/react';
import { Download, FolderTree, Github, Smartphone, Terminal, PackageOpen, CheckCircle2 } from 'lucide-react';

export default function App() {
  const [activeTab, setActiveTab] = useState<'overview' | 'export' | 'github'>('overview');

  return (
    <div className="min-h-screen bg-neutral-50 text-neutral-900 font-sans selection:bg-blue-200">
      <div className="max-w-4xl mx-auto px-6 py-12">
        
        {/* Header Section */}
        <motion.header 
          initial={{ opacity: 0, y: -20 }}
          animate={{ opacity: 1, y: 0 }}
          className="mb-12 text-center"
        >
          <div className="inline-flex items-center justify-center p-3 bg-blue-100 rounded-2xl mb-4 text-blue-600">
            <Smartphone size={32} />
          </div>
          <h1 className="text-4xl font-extrabold tracking-tight mb-3">WorkAudiobook Flutter Project</h1>
          <p className="text-lg text-neutral-600 max-w-2xl mx-auto">
            Your Flutter codebase has been generated successfully. Follow the instructions below to export the project to your local machine or compile the APK directly via GitHub Actions.
          </p>
        </motion.header>

        {/* Status Card */}
        <motion.div 
          initial={{ opacity: 0, scale: 0.95 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ delay: 0.1 }}
          className="bg-white rounded-2xl border border-neutral-200 shadow-sm p-6 mb-8 flex items-center justify-between"
        >
          <div className="flex items-center space-x-4">
            <div className="bg-green-100 text-green-700 p-2 rounded-full">
              <CheckCircle2 size={24} />
            </div>
            <div>
              <h2 className="font-semibold text-lg">Files Generated</h2>
              <p className="text-neutral-500 text-sm">Target path: <code className="bg-neutral-100 px-1 py-0.5 rounded">/root</code></p>
            </div>
          </div>
        </motion.div>

        {/* Tab Navigation */}
        <div className="flex space-x-2 mb-6 border-b border-neutral-200">
          <button 
            onClick={() => setActiveTab('overview')}
            className={`pb-3 px-4 text-sm font-medium transition-colors border-b-2 ${activeTab === 'overview' ? 'border-blue-600 text-blue-600' : 'border-transparent text-neutral-500 hover:text-neutral-700'}`}
          >
            Project Structure
          </button>
          <button 
            onClick={() => setActiveTab('export')}
            className={`pb-3 px-4 text-sm font-medium transition-colors border-b-2 ${activeTab === 'export' ? 'border-blue-600 text-blue-600' : 'border-transparent text-neutral-500 hover:text-neutral-700'}`}
          >
            Local Development
          </button>
          <button 
            onClick={() => setActiveTab('github')}
            className={`pb-3 px-4 text-sm font-medium transition-colors border-b-2 ${activeTab === 'github' ? 'border-blue-600 text-blue-600' : 'border-transparent text-neutral-500 hover:text-neutral-700'}`}
          >
            APK Build Pipeline
          </button>
        </div>

        {/* Tab Content */}
        <motion.div 
          key={activeTab}
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.2 }}
          className="bg-white rounded-2xl border border-neutral-200 shadow-sm p-8"
        >
          {activeTab === 'overview' && (
            <div>
              <h3 className="text-xl font-semibold mb-4 flex items-center gap-2">
                <FolderTree className="text-blue-500" /> Structure Overview
              </h3>
              <p className="text-neutral-600 mb-6">
                All logic replicating WorkAudiobook's magic (silence detection logic, phrase looping, playback controls) is implemented in Dart and packed into the root of the file system.
              </p>
              
              <div className="bg-neutral-900 text-neutral-200 rounded-xl p-5 font-mono text-sm leading-relaxed overflow-x-auto">
                <div className="text-blue-400 mb-1">/ (Root)</div>
                <div className="pl-4 border-l border-neutral-700 ml-2">
                  <div className="flex items-center gap-2 py-1"><PackageOpen size={14} className="text-neutral-400"/> pubspec.yaml <span className="text-neutral-500 text-xs ml-2">// Dependencies (just_audio, etc.)</span></div>
                  <div className="flex gap-2 py-1"><FolderTree size={14} className="text-yellow-500 mt-0.5"/> lib/</div>
                  <div className="pl-6 border-l border-neutral-700 ml-1">
                    <div className="text-blue-300 py-1">main.dart <span className="text-neutral-500 text-xs ml-2">// App UI & Initialization</span></div>
                    <div className="text-blue-300 py-1">audio_manager.dart <span className="text-neutral-500 text-xs ml-2">// Phrase looping & audio state</span></div>
                  </div>
                  <div className="flex gap-2 py-1"><FolderTree size={14} className="text-green-500 mt-0.5"/> android/</div>
                  <div className="pl-6 border-l border-neutral-700 ml-1 text-neutral-400 text-xs italic">
                    build.gradle, settings.gradle, app folder...
                  </div>
                  <div className="flex gap-2 py-1"><FolderTree size={14} className="text-neutral-400 mt-0.5"/> .github/</div>
                  <div className="pl-6 border-l border-neutral-700 ml-1">
                    <div className="text-blue-300 py-1">workflows/release.yml <span className="text-neutral-500 text-xs ml-2">// CI/CD APK packager</span></div>
                  </div>
                </div>
              </div>
            </div>
          )}

          {activeTab === 'export' && (
            <div>
              <h3 className="text-xl font-semibold mb-4 flex items-center gap-2">
                <Download className="text-blue-500" /> Downloading the API
              </h3>
              <ol className="relative border-l border-neutral-200 ml-3 space-y-6">
                <li className="pl-6">
                  <span className="absolute flex items-center justify-center w-6 h-6 bg-blue-100 rounded-full -left-3 ring-4 ring-white text-blue-600 text-xs font-bold">1</span>
                  <h4 className="font-semibold text-neutral-900">Export as ZIP</h4>
                  <p className="text-neutral-600 mt-1 text-sm">Navigate to the settings menu in Google AI Studio and select <strong>"Download as ZIP"</strong> to get your code.</p>
                </li>
                <li className="pl-6">
                  <span className="absolute flex items-center justify-center w-6 h-6 bg-blue-100 rounded-full -left-3 ring-4 ring-white text-blue-600 text-xs font-bold">2</span>
                  <h4 className="font-semibold text-neutral-900">Open in VS Code / Android Studio</h4>
                  <p className="text-neutral-600 mt-1 text-sm">Since files are already at the root, you can open the extracted folder directly with your IDE.</p>
                </li>
                <li className="pl-6">
                  <span className="absolute flex items-center justify-center w-6 h-6 bg-blue-100 rounded-full -left-3 ring-4 ring-white text-blue-600 text-xs font-bold">3</span>
                  <h4 className="font-semibold text-neutral-900">Run locally for development</h4>
                  <div className="mt-3 bg-neutral-900 text-neutral-200 rounded-lg p-3 font-mono text-sm inline-block w-full">
                    <div className="text-neutral-400"># Fetch dependencies</div>
                    <div className="mb-2 text-green-400">$ flutter pub get</div>
                    <div className="text-neutral-400"># Run the application on your physical device</div>
                    <div className="text-green-400">$ flutter run</div>
                  </div>
                </li>
              </ol>
            </div>
          )}

          {activeTab === 'github' && (
            <div>
              <h3 className="text-xl font-semibold mb-4 flex items-center gap-2">
                <Github className="text-neutral-800" /> Automated APK Building
              </h3>
              <p className="text-neutral-600 mb-6">
                A pre-configured GitHub action (<code>release.yml</code>) specifically tracks git tags to automatically build and release your APKs, avoiding large CI pipelines locally.
              </p>
              
              <div className="space-y-4">
                <div className="border border-neutral-200 rounded-xl p-4">
                  <h4 className="font-medium text-neutral-900 mb-2">1. Export to GitHub</h4>
                  <p className="text-sm text-neutral-600">Use the Google AI Studio <strong>Export to GitHub</strong> feature. The repository will be ready to build immediately.</p>
                </div>
                
                <div className="border border-neutral-200 rounded-xl p-4">
                  <h4 className="font-medium text-neutral-900 mb-2">2. Trigger the Build Pipeline</h4>
                  <p className="text-sm text-neutral-600 mb-3">To build an APK instantly, tag your commit and push it to origin:</p>
                  <div className="bg-neutral-100 p-2 rounded font-mono text-sm">
                    git tag v1.0.0<br/>
                    git push origin v1.0.0
                  </div>
                </div>

                <div className="border border-neutral-200 rounded-xl p-4 bg-blue-50/50">
                  <h4 className="font-medium text-blue-800 mb-2 text-sm flex items-center gap-1.5"><Terminal size={14} /> Production Note</h4>
                  <p className="text-sm text-blue-700">Once your keystore parameters are ready, uncomment the keystore injections in <code>.github/workflows/release.yml</code> to properly sign the released APK for Google Play submission.</p>
                </div>
              </div>
            </div>
          )}
        </motion.div>

      </div>
    </div>
  );
}

