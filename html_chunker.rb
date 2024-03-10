# frozen_string_literal: true

require 'json'
require 'nokogiri'

class HTMLChunker
  def initialize(html)
    @doc = Nokogiri::HTML.fragment(html)
    @headings_stack = []
    @levels_stack = []
    @content_stack = []
    @previous_level = 0
    @output_html = []
  end

  def chunk
    @doc.children.each do |node|
      if node.is_a?(Nokogiri::XML::Element) && node.name.match?(/h[1-6]/)
        flush_content
        handle_heading(node)
      else
        @content_stack.push(node)
      end
    end
    flush_content
    @output_html.to_json
  end

  private

  def handle_heading(heading)
    level = heading.name[1].to_i

    # Remove any siblings and their descendants from the stack
    if level <= @previous_level
      @headings_stack.pop until @levels_stack.pop == level
      @headings_stack.pop
    end

    @headings_stack.push(heading)
    @levels_stack.push(level)
    @content_stack = @headings_stack.map(&:clone)
    @previous_level = level
  end

  def flush_content
    return if @content_stack.empty?

    html = @content_stack.map(&:to_s).join
    @output_html.push(html)
    @content_stack.clear
  end
end
