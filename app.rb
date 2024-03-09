require 'nokogiri'
require 'pandoc-ruby'

class Parser
  def initialize(html)
    @doc = Nokogiri::HTML.fragment(html)
    @headings_stack = []
    @content_stack = []
  end

  def parse
    @doc.children.each do |node|
      case node
      when Nokogiri::XML::Text
        @content_stack.push(node)
      when Nokogiri::XML::Element
        if node.name.match?(/h[1-6]/)
          handle_heading(node)
        else
          @content_stack.push(node)
        end
      end
    end
    flush_content if !@content_stack.empty?
  end

  private

  def heading_level(heading)
    if heading.nil?
      return 0
    end
    heading.name[1].to_i
  end

  def handle_heading(heading)
    flush_content if !@content_stack.empty?

    level = heading_level(heading)
    last_level = heading_level(@headings_stack.last) || 0

    if level < last_level
      pop_headings_until_level(level - 1)
      @headings_stack.push(heading)
    elsif level == last_level
      @headings_stack.pop
      @headings_stack.push(heading)
    elsif level > last_level || @headings_stack.empty?
      @headings_stack.push(heading)
    end

    @content_stack = @headings_stack.map(&:clone)
  end


  def flush_content
    html = @content_stack.map(&:to_s).join("\n")

    # Extract plain text
    text = PandocRuby.convert(html, { from: :html, to: :plain }, "--wrap=none").chomp.gsub(/(\r?\n)+/, "\n")

    puts ">---"
    puts text
    puts "<---\n\n"
    @content_stack.clear
  end

  def pop_headings_until_level(target_level)
    while heading_level(@headings_stack.last) > target_level && !@headings_stack.empty?
      @headings_stack.pop
    end
  end
end

# Example usage

html = File.read("example.html")
parser = Parser.new(html)
parser.parse
