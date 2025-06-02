"use client"

import { useState } from "react"
import Link from "next/link"
import { Copy, Check } from "lucide-react"
import { Button } from "@/components/ui/button"

export default function TofuPilotShLanding() {
  const [copied, setCopied] = useState(false)
  const installCommand = "curl -fsSL https://tofupilot.sh/install | bash"

  const copyToClipboard = async () => {
    await navigator.clipboard.writeText(installCommand)
    setCopied(true)
    setTimeout(() => setCopied(false), 2000)
  }

  return (
    <div className="min-h-screen bg-black text-lime-400 font-mono p-4 md:p-8 flex items-center justify-center">
      <div className="container mx-auto max-w-3xl">
        {/* ASCII Art Banner with correct colors */}
        <div className="mb-8 text-center">
          <pre className="inline-block text-left text-lg md:text-xl">
            <span className="text-blue-500">╭</span> <span className="text-yellow-500">✈</span>{" "}
            <span className="text-blue-500">╮</span>
            {"\n"}<span className="text-white">[•ᴗ•]</span> <span className="text-white">TofuPilot.sh</span>
          </pre>
        </div>

        {/* Simple Terminal Box */}
        <div className="bg-zinc-950 border border-zinc-800 rounded-lg p-6 mb-8">
          <div className="space-y-4">
            <div className="text-white text-lg">TofuPilot Self-Hosting Installer</div>

            <div className="bg-zinc-900 rounded p-3 flex items-center justify-between">
              <code className="text-white">$ {installCommand}</code>
              <Button
                size="sm"
                variant="ghost"
                onClick={copyToClipboard}
                className="text-zinc-400 hover:text-white hover:bg-zinc-800"
              >
                {copied ? <Check className="w-4 h-4" /> : <Copy className="w-4 h-4" />}
              </Button>
            </div>

            <div className="text-zinc-400 text-sm">Deploy TofuPilot on your own infrastructure with one command.</div>
          </div>
        </div>

        {/* Simple Navigation Links */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4 text-center">
          <Link
            href="https://tofupilot.com"
            target="_blank"
            rel="noopener noreferrer"
            className="bg-zinc-950 border border-zinc-800 rounded-lg p-4 hover:border-lime-400 transition-colors"
          >
            <div className="text-white font-bold">Main Platform</div>
            <div className="text-lime-400 text-sm">tofupilot.com</div>
          </Link>

          <Link
            href="https://tofupilot.com/docs"
            target="_blank"
            rel="noopener noreferrer"
            className="bg-zinc-950 border border-zinc-800 rounded-lg p-4 hover:border-blue-400 transition-colors"
          >
            <div className="text-white font-bold">Documentation</div>
            <div className="text-blue-400 text-sm">tofupilot.com/docs</div>
          </Link>

          <Link
            href="https://tofupilot.com/careers"
            target="_blank"
            rel="noopener noreferrer"
            className="bg-zinc-950 border border-zinc-800 rounded-lg p-4 hover:border-purple-400 transition-colors"
          >
            <div className="text-white font-bold">Careers</div>
            <div className="text-purple-400 text-sm">tofupilot.com/careers</div>
          </Link>
        </div>
      </div>
    </div>
  )
}
