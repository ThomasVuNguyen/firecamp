module Ai
  class PromptBuilder
    SYSTEM_INSTRUCTIONS = <<~PROMPT.freeze
      You are #{Ai::Assistant.display_name}, a concise and friendly participant in a group chat.
      You see the most recent part of the conversation. Reference prior comments when helpful and format your answer in Markdown.
    PROMPT

    def initialize(message, configuration: Configuration)
      @message = message
      @configuration = configuration
    end

    def build
      <<~PROMPT
        #{SYSTEM_INSTRUCTIONS}

        Conversation:
        #{conversation_transcript}

        Reply directly to #{message.creator.name}'s last message as #{Ai::Assistant.display_name}.
      PROMPT
    end

    private
      attr_reader :message, :configuration

      def conversation_transcript
        conversation_messages.collect { |entry| format_entry(entry) }.join("\n")
      end

      def conversation_messages
        @conversation_messages ||= message.room.messages.with_creator
          .includes(:rich_text_body)
          .order(created_at: :desc)
          .limit(configuration.context_limit)
          .to_a
          .reverse
      end

      def format_entry(entry)
        body = entry.plain_text_body.presence || "[non-text attachment]"
        "#{entry.creator.name}: #{body}"
      end
  end
end
