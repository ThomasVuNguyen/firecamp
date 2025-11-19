require "test_helper"

class MessageTest < ActiveSupport::TestCase
  include ActionCable::TestHelper, ActiveJob::TestHelper

  test "creating a message enqueues to push later" do
    assert_enqueued_jobs 1, only: [ Room::PushMessageJob ] do
      create_new_message_in rooms(:designers)
    end
  end

  test "all emoji" do
    assert Message.new(body: "😄🤘").plain_text_body.all_emoji?
    assert_not Message.new(body: "Haha! 😄🤘").plain_text_body.all_emoji?
    assert_not Message.new(body: "🔥\nmultiple lines\n💯").plain_text_body.all_emoji?
    assert_not Message.new(body: "🔥 💯").plain_text_body.all_emoji?
  end

  test "mentionees" do
    message = Message.new room: rooms(:pets), body: "<div>Hey #{mention_attachment_for(:david)}</div>", creator: users(:jason), client_message_id: "earth"
    assert_equal [ users(:david) ], message.mentionees

    message_with_duplicate_mentions = Message.new room: rooms(:pets), body: "<div>Hey #{mention_attachment_for(:david)} #{mention_attachment_for(:david)}</div>", creator: users(:jason), client_message_id: "earth"
    assert_equal [ users(:david) ], message.mentionees

    message_mentioning_a_non_member = Message.new room: rooms(:pets), body: "<div>Hey #{mention_attachment_for(:kevin)}</div>", creator: users(:jason), client_message_id: "earth"
    assert_equal [], message_mentioning_a_non_member.mentionees
  end

  test "mentioning the AI assistant enqueues a response when configured" do
    Ai::Configuration.stubs(:enabled?).returns(true)

    assert_enqueued_with(job: Ai::RespondToMessageJob) do
      rooms(:pets).messages.create!(
        creator: users(:jason),
        body: "<div>Ping #{mention_attachment_for(Ai::Assistant.user)}</div>",
        client_message_id: "ai-mention"
      )
    end
  end

  test "mentioning the AI assistant without credentials posts a reminder" do
    Ai::Configuration.stubs(:enabled?).returns(false)

    assert_difference -> { rooms(:pets).messages.count }, 2 do
      rooms(:pets).messages.create!(
        creator: users(:jason),
        body: "<div>Ping #{mention_attachment_for(Ai::Assistant.user)}</div>",
        client_message_id: "ai-reminder"
      )
    end

    reminder = rooms(:pets).messages.order(:created_at).last
    assert_equal Ai::Assistant.user, reminder.creator
    assert_match "configure the AI assistant API key", reminder.plain_text_body
  end

  private
    def create_new_message_in(room)
      room.messages.create!(creator: users(:jason), body: "Hello", client_message_id: "123")
    end
end
