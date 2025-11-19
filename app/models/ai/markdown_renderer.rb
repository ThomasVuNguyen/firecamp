require "commonmarker"

module Ai
  class MarkdownRenderer
    OPTIONS = %i[DEFAULT].freeze
    EXTENSIONS = %i[table strikethrough autolink tagfilter tasklist].freeze

    class << self
      def render(text)
        return "" if text.blank?

        Commonmarker.commonmark_to_html(text.to_s)
      end
    end
  end
end
