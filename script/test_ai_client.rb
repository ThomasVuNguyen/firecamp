#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require "dotenv"
require "json"
require "net/http"
require "uri"

Dotenv.load(".env")

def presence(value)
  value if value && !value.strip.empty?
end

def env!(key)
  value = presence(ENV[key])
  abort "Missing #{key} in environment/.env" unless value
  value
end

def float_env(key)
  value = presence(ENV[key])
  value&.to_f
end

def integer_env(key, default)
  Integer(ENV.fetch(key, default))
rescue ArgumentError, TypeError
  default
end

api_key = env!("AI_ASSISTANT_API_KEY")
api_base = ENV.fetch("AI_ASSISTANT_API_BASE", "https://inference.cloudrift.ai/v1")
model_id = ENV.fetch("AI_ASSISTANT_MODEL_ID", "deepseek-ai/DeepSeek-R1-0528")
prompt = presence(ARGV.join(" ")) || "Hello from Firecamp's AI test script."

stop_sequences = ENV["AI_ASSISTANT_STOP_SEQUENCES"].to_s.split(",").map(&:strip).reject(&:empty?)
extra_fields = begin
  raw = presence(ENV["AI_ASSISTANT_REQUEST_FIELDS"])
  raw ? JSON.parse(raw) : {}
rescue JSON::ParserError => e
  warn "Could not parse AI_ASSISTANT_REQUEST_FIELDS JSON (#{e.message}), ignoring."
  {}
end

base_uri = URI(api_base.end_with?("/") ? api_base : "#{api_base}/")
endpoint = URI.join(base_uri, "chat/completions")

payload = {
  model: model_id,
  messages: [
    {
      role: "user",
      content: prompt
    }
  ],
  temperature: float_env("AI_ASSISTANT_TEMPERATURE"),
  top_p: float_env("AI_ASSISTANT_TOP_P"),
  max_tokens: integer_env("AI_ASSISTANT_MAX_TOKENS", 4000),
  stop: stop_sequences.any? ? stop_sequences : nil,
  stream: false
}.merge(extra_fields).compact

http = Net::HTTP.new(endpoint.host, endpoint.port)
http.use_ssl = endpoint.scheme == "https"
http.open_timeout = 5
http.read_timeout = 120

request = Net::HTTP::Post.new(endpoint.request_uri)
request["Content-Type"] = "application/json"
request["Authorization"] = "Bearer #{api_key}"
request.body = JSON.generate(payload)

puts "Sending prompt to #{endpoint} using model #{model_id}..."

begin
  response = http.request(request)
rescue StandardError => e
  warn "[ai-test] HTTP request failed: #{e.class} #{e.message}"
  exit 1
end

unless response.is_a?(Net::HTTPSuccess)
  warn "[ai-test] Request failed: HTTP #{response.code} #{response.body}"
  exit 1
end

data = JSON.parse(response.body)
choices = Array(data["choices"])
text = choices.map { |choice| choice.dig("message", "content") }.compact.join("\n").strip

puts "\nAI response:"
puts "-" * 40
puts presence(text) || "[empty response]"
puts "-" * 40
puts "Usage: #{data["usage"] || {}}"
puts "Done."
