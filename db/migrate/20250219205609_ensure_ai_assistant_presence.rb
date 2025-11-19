class EnsureAiAssistantPresence < ActiveRecord::Migration[7.2]
  def up
    return unless tables_present?

    say_with_time "Ensuring #{Ai::Assistant.display_name} belongs to every room" do
      Ai::Assistant.ensure_presence!
    end
  end

  def down
    return unless table_exists?(:users) && table_exists?(:memberships)

    if (assistant = User.find_by(email_address: Ai::Assistant::EMAIL))
      Membership.where(user_id: assistant.id).delete_all
      assistant.destroy
    end
  end

  private
    def tables_present?
      %i[users rooms memberships].all? { |table_name| table_exists?(table_name) }
    end
end
