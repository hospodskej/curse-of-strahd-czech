#!/usr/bin/env ruby
# frozen_string_literal: true

# Splits English notes into translation-sized chunks.
#
#   ruby tools/split.rb <vault_dir> <work_dir> <note.md>...
#
# Each note is cut at heading lines into chunks of roughly MAX_WORDS words,
# written as <work_dir>/<slug>/NNN.en.md. Stat blocks stay in English, so they
# are moved out to <slug>/statblocks/NNN.html and replaced by a placeholder
# comment that tools/join.rb swaps back. Translations go next to the chunks
# as NNN.cs.md.

require "fileutils"

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

MAX_WORDS = 2000
STATBLOCK_OPEN = '<div class="statblock"'

def slug(path)
  path.sub(/\.md\z/, "").gsub(/[^A-Za-z0-9]+/, "_")
end

# Returns [text with placeholders, [stat block html...]], matching nested divs.
def extract_statblocks(text)
  blocks = []
  out = +""
  pos = 0
  while (start = text.index(STATBLOCK_OPEN, pos))
    depth = 0
    cursor = start
    # A few source stat blocks lack their closing tag; they end at the next heading.
    limit = text.index(/\n+#/, start) || text.size
    loop do
      next_open = text.index("<div", cursor)
      next_close = text.index("</div>", cursor)
      if next_close.nil? || next_close > limit
        cursor = limit
        break
      elsif next_open && next_open < next_close
        depth += 1
        cursor = next_open + 4
      else
        depth -= 1
        cursor = next_close + 6
        break if depth.zero?
      end
    end
    blocks << text[start...cursor]
    out << text[pos...start] << format("<!--STATBLOCK:%03d-->", blocks.size)
    pos = cursor
  end
  [out << text[pos..], blocks]
end

def split_note(text)
  chunks = []
  current = []
  words = 0
  text.each_line do |line|
    if line.start_with?("#") && words >= MAX_WORDS
      chunks << current.join
      current = []
      words = 0
    end
    current << line
    words += line.split.size
  end
  chunks << current.join unless current.empty?
  chunks
end

vault, work, *notes = ARGV
abort "usage: split.rb <vault_dir> <work_dir> <note.md>..." if notes.empty?

notes.each do |note|
  text, blocks = extract_statblocks(File.read(File.join(vault, note)))
  dir = File.join(work, slug(note))
  FileUtils.mkdir_p(File.join(dir, "statblocks"))
  File.write(File.join(dir, "SOURCE"), note)
  blocks.each_with_index do |html, i|
    File.write(File.join(dir, "statblocks", format("%03d.html", i + 1)), html)
  end
  chunks = split_note(text)
  chunks.each_with_index do |chunk, i|
    File.write(File.join(dir, format("%03d.en.md", i + 1)), chunk)
  end
  puts "#{note}: #{chunks.size} chunks, #{blocks.size} stat blocks"
end
