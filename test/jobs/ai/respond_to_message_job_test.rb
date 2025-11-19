require "test_helper"

class Ai::RespondToMessageJobTest < ActiveJob::TestCase
  test "creates a response from the AI assistant" do
    Ai::Configuration.stubs(:enabled?).returns(true)

    body = "<div>Hello #{mention_attachment_for(Ai::Assistant.user)}</div>"
    message = rooms(:pets).messages.create!(
      creator: users(:jason),
      body: body,
      client_message_id: "ai-job"
    )

    Ai::Client.stubs(:new).returns(stub(complete: "Sure, let's do it."))

    Message.any_instance.expects(:broadcast_create).at_least_once

    assert_difference -> { rooms(:pets).messages.where(creator: Ai::Assistant.user).count }, 1 do
      Ai::RespondToMessageJob.perform_now(message.id)
    end

    response = rooms(:pets).messages.order(:created_at).last
    assert_equal Ai::Assistant.user, response.creator
    assert_equal "Sure, let's do it.", response.plain_text_body
  end
end
