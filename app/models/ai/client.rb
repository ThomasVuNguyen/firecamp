require "net/http"
require "json"

module Ai
  class Client
    def initialize(configuration: Configuration)
      @configuration = configuration
      @endpoint = build_endpoint
    end

    def complete(prompt)
      response = http_request(prompt_payload(prompt))
      return unless response.is_a?(Net::HTTPSuccess)

      parse_response(response.body)
    rescue StandardError => error
      Rails.logger.error("[ai] CloudRift completion failed: #{error.class} #{error.message}")
      nil
    end

    private
      attr_reader :configuration, :endpoint

      def build_endpoint
        base = configuration.api_base.to_s.strip
        base = "#{base}/" unless base.ends_with?("/")
        URI.join(base, "chat/completions")
      end

      def http_client
        @http_client ||= begin
          http = Net::HTTP.new(endpoint.host, endpoint.port)
          http.use_ssl = endpoint.scheme == "https"
          http.open_timeout = 5
          http.read_timeout = 120
          http
        end
      end

      def prompt_payload(prompt)
        {
          model: configuration.model_id,
          messages: [
            {
              role: "user",
              content: prompt
            }
          ],
          temperature: configuration.temperature,
          top_p: configuration.top_p,
          max_tokens: configuration.max_tokens,
          stop: configuration.stop_sequences,
          stream: false
        }.merge(configuration.additional_request_fields).compact
      end

      def http_request(body)
        request = Net::HTTP::Post.new(endpoint.request_uri)
        request["Authorization"] = "Bearer #{configuration.api_key}"
        request["Content-Type"] = "application/json"
        request.body = JSON.generate(body)

        response = http_client.request(request)

        unless response.is_a?(Net::HTTPSuccess)
          Rails.logger.error("[ai] CloudRift completion failed: HTTP #{response.code} #{response.body}")
        end

        response
      end

      def parse_response(body)
        data = JSON.parse(body)
        choices = Array(data["choices"])

        text = choices.map { |choice| choice.dig("message", "content") }.compact.join("\n").strip
        text.presence
      end
  end
end
