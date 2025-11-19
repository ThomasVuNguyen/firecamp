module Ai
  module Configuration
    extend self

    DEFAULT_API_BASE = "https://inference.cloudrift.ai/v1".freeze
    DEFAULT_MODEL_ID = "deepseek-ai/DeepSeek-R1-0528".freeze
    DEFAULT_MAX_TOKENS = 4000
    DEFAULT_CONTEXT_LIMIT = 30
    DEFAULT_LATENCY = "standard".freeze

    def enabled?
      return false if ENV["AI_ASSISTANT_ENABLED"] == "false"

      api_key.present?
    end

    def api_key
      ENV["AI_ASSISTANT_API_KEY"].to_s.strip
    end

    def api_base
      ENV.fetch("AI_ASSISTANT_API_BASE", DEFAULT_API_BASE)
    end

    def model_id
      ENV.fetch("AI_ASSISTANT_MODEL_ID", DEFAULT_MODEL_ID)
    end

    def max_tokens
      ENV.fetch("AI_ASSISTANT_MAX_TOKENS", DEFAULT_MAX_TOKENS).to_i
    end

    def context_limit
      ENV.fetch("AI_ASSISTANT_CONTEXT_LIMIT", DEFAULT_CONTEXT_LIMIT).to_i
    end

    def temperature
      ENV["AI_ASSISTANT_TEMPERATURE"].presence&.to_f
    end

    def top_p
      ENV["AI_ASSISTANT_TOP_P"].presence&.to_f
    end

    def stop_sequences
      ENV["AI_ASSISTANT_STOP_SEQUENCES"].to_s.split(",").map(&:strip).reject(&:blank?).presence
    end

    def additional_request_fields
      value = ENV["AI_ASSISTANT_REQUEST_FIELDS"].presence
      value ? JSON.parse(value) : {}
    rescue JSON::ParserError
      {}
    end

    def latency
      ENV["AI_ASSISTANT_LATENCY"].presence || DEFAULT_LATENCY
    end
  end
end
