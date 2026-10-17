#!/usr/bin/env ruby
# frozen_string_literal: true

# Adds a clickable table of contents to the top of notes.
#
#   ruby tools/toc.rb <note.md>...
#
# The contents box is an expanded Obsidian callout listing the note's
# top-level (#) and second-level (##) headings as [[#Heading]] links. It sits
# between <!-- obsah --> markers, so running the script again replaces it.

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

START = "<!-- obsah -->"
FINISH = "<!-- /obsah -->"
LEVELS = 2

# Obsidian heading links can't contain these characters.
def anchor(heading)
  heading.gsub(/[*_`]/, "").gsub(/[#|^\[\]]/, " ").squeeze(" ").strip
end

def toc(text)
  items = text.lines.filter_map do |line|
    next unless (m = line.match(/\A(#+) (.+)/))

    level = m[1].size
    next if level > LEVELS

    name = anchor(m[2])
    "> #{'  ' * (level - 1)}- [[##{name}|#{name}]]"
  end
  return nil if items.empty?

  [START, "> [!abstract]+ **Obsah**", *items, FINISH, ""].join("\n")
end

ARGV.each do |path|
  text = File.read(path)
  text = text.sub(/\A#{Regexp.escape(START)}.*?#{Regexp.escape(FINISH)}\n\n?/m, "")
  block = toc(text)
  next unless block

  File.write(path, "#{block}\n#{text}")
  puts "#{path}: #{block.lines.count - 3} odkazů"
end
