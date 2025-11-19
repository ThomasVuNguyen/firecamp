module Ai
  class Responder
    def initialize(message, client: Ai::Client.new, prompt_builder: nil)
      @message = message
      @client = client
      @prompt_builder = prompt_builder || Ai::PromptBuilder.new(message)
    end

    def call
      response = client.complete(prompt_builder.build)
      return if response.blank?

      reply = message.room.messages.create!(
        creator: Ai::Assistant.user,
        body: Ai::MarkdownRenderer.render(response)
      )

      reply.broadcast_create
    end

    private
      attr_reader :message, :client, :prompt_builder
  end
end
