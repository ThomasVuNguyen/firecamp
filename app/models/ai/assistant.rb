module Ai
  class Assistant
    DISPLAY_NAME = "Campfire AI".freeze
    EMAIL = "campfire-ai@system.firecamp".freeze

    class << self
      def user
        User.find_or_create_by!(email_address: EMAIL) do |user|
          user.name = DISPLAY_NAME
          user.role = :bot
          user.bot_token = User.generate_bot_token
        end
      end

      def display_name
        DISPLAY_NAME
      end

      def ensure_presence!
        ensure_membership_for_all_rooms!
      end

      def ensure_membership!(room)
        room.memberships.find_or_create_by!(user: user)
      end

      def ensure_membership_for_all_rooms!
        Room.find_each { |room| ensure_membership!(room) }
      end

      def mentioned_in?(message)
        return false if message.creator_id == user.id

        message.mentionees.exists?(user.id)
      end

      def handle_mention(message)
        if Ai::Configuration.enabled?
          Ai::RespondToMessageJob.perform_later(message.id)
        else
          inform_configuration_missing(message.room)
        end
      end

      private
        def inform_configuration_missing(room)
          room.messages.create!(
            creator: user,
            body: missing_configuration_notice
          ).tap(&:broadcast_create)
        end

        def missing_configuration_notice
          "I'm ready to help as soon as you configure the AI assistant API key in your .env file."
        end
    end
  end
end
