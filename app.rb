# frozen_string_literal: true

require 'json'
require 'nokogiri'
require 'pandoc-ruby'

class Parser
  def initialize(html)
    @doc = Nokogiri::HTML.fragment(html)
    @headings_stack = []
    @levels_stack = []
    @content_stack = []
    @previous_level = 0
    @output_html = []
  end

  def parse
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
    @headings_stack.pop until @levels_stack.pop <= level if level <= @previous_level

    @headings_stack.push(heading)
    @levels_stack.push(level)
    @content_stack = @headings_stack.map(&:clone)
    @previous_level = level
  end

  def flush_content
    html = @content_stack.map(&:to_s).join("\n")
    @output_html.push(html)
    @content_stack.clear
  end
end

# Example usage

html = File.read('example.html')
parser = Parser.new(html)
puts(parser.parse)
