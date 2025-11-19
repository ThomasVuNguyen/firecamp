module Ai
  class RespondToMessageJob < ApplicationJob
    queue_as :default

    discard_on ActiveJob::DeserializationError

    def perform(message_id)
      message = Message.find_by(id: message_id)
      return unless message
      return unless Ai::Assistant.mentioned_in?(message)

      Ai::Responder.new(message).call
    end
  end
end
