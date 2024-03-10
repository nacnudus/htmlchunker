# frozen_string_literal: true

require 'spec_helper'
require './html_chunker'

describe HTMLChunker do
  describe '#chunk' do
    it 'chunks HTML with headings and content in the correct order' do
      html = '<h1>Heading 1</h1><p>Content 1</p><h2>Heading 1.1</h2><p>Content 1.1</p>'
      expected_json = ['<h1>Heading 1</h1><p>Content 1</p>',
                       '<h1>Heading 1</h1><h2>Heading 1.1</h2><p>Content 1.1</p>'].to_json

      chunker = HTMLChunker.new(html)
      parsed_json = chunker.chunk

      expect(parsed_json).to eq expected_json
    end

    it 'handles nested headings with different levels correctly' do
      html = '<h1>Heading 1</h1><h2>Heading 1.1</h2><p>Content 1.1</p><h1>Heading 2</h1>'
      expected_json = ['<h1>Heading 1</h1>', '<h1>Heading 1</h1><h2>Heading 1.1</h2><p>Content 1.1</p>',
                       '<h1>Heading 2</h1>'].to_json

      chunker = HTMLChunker.new(html)
      parsed_json = chunker.chunk

      expect(parsed_json).to eq expected_json
    end

    it 'handles multiple consecutive headings of the same level' do
      html = '<h2>Heading 2.1</h2><h2>Heading 2.2</h2>'
      expected_json = ['<h2>Heading 2.1</h2>', '<h2>Heading 2.2</h2>'].to_json

      chunker = HTMLChunker.new(html)
      parsed_json = chunker.chunk

      expect(parsed_json).to eq expected_json
    end

    it 'removes nested headings and their content when a higher-level heading is encountered' do
      html = '<h1>Heading 1</h1><h2>Heading 1.1</h2><h1>Heading 1.2</h1>'
      expected_json = ['<h1>Heading 1</h1>','<h1>Heading 1</h1><h2>Heading 1.1</h2>','<h1>Heading 1.2</h1>'].to_json

      chunker = HTMLChunker.new(html)
      parsed_json = chunker.chunk

      expect(parsed_json).to eq expected_json
    end
  end
end
