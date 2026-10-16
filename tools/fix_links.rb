#!/usr/bin/env ruby
# frozen_string_literal: true

# Keeps Obsidian links working after translation.
#
#   ruby tools/fix_links.rb <vault_dir> <work_dir>
#
# File names stay English, but headings are translated, so every
# [[Note#Heading]] anchor that points into a translated note is rewritten to
# the Czech heading (English and Czech headings are paired by position).
# In translated notes, links without a visible label also get a Czech one:
#   [[Arc J - The Stolen Gem]]        -> [[Arc J - The Stolen Gem|Oblouk J – Ukradený drahokam]]
#   [[Bestiary#Vampire Spawn]]        -> [[Bestiary#Upíří zplozenec|Upíří zplozenec]]
# Labels that are just an English note title or heading are swapped for Czech.
# Czech note titles come from tools/titles.tsv. Unresolvable anchors are reported.

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

def norm(heading)
  heading.tr("’‘", "''").tr("“”", '""').gsub(/[*_`]/, "").gsub(/[#|^\[\]]/, " ")
         .squeeze(" ").strip.downcase
end

def clean(heading)
  heading.gsub(/[*_`]/, "").gsub(/[#|^\[\]]/, " ").squeeze(" ").strip
end

def headings(text)
  text.lines.grep(/\A#+ /).map { |l| l.sub(/\A#+ /, "").strip }
end

vault, work = ARGV
abort "usage: fix_links.rb <vault_dir> <work_dir>" unless vault && work

titles = File.readlines(File.join(__dir__, "titles.tsv"), chomp: true)
             .reject { |l| l.empty? || l.start_with?("#") }
             .to_h { |l| l.split("\t", 2) }

# basename => { normalized English heading => Czech heading }
anchor_map = {}
translated = []
Dir[File.join(work, "*", "SOURCE")].map { |s| File.dirname(s) }.sort.each do |dir|
  note = File.read(File.join(dir, "SOURCE")).strip
  en_files = Dir[File.join(dir, "*.en.md")].sort
  next unless en_files.all? { |f| File.exist?(f.sub(".en.md", ".cs.md")) }

  en = headings(en_files.map { |f| File.read(f) }.join)
  cs = headings(en_files.map { |f| File.read(f.sub(".en.md", ".cs.md")) }.join)
  if en.size != cs.size
    warn "heading count differs in #{note} (#{en.size} vs #{cs.size}); skipped"
    next
  end
  map = {}
  en.zip(cs).each { |e, c| map[norm(e)] ||= clean(c) }
  anchor_map[File.basename(note, ".md")] = map
  translated << note
end

unresolved = Hash.new(0)
changed = 0

Dir.glob("**/*.md", base: vault).sort.each do |rel|
  next if rel.start_with?("tools/", "_other/") || rel == "GLOSAR.md" || rel == "README.md"

  path = File.join(vault, rel)
  own = File.basename(rel, ".md")
  in_czech = translated.include?(rel)
  original = File.read(path)

  updated = original.lines.map do |line|
    table = line.sub(/\A>\s*/, "").start_with?("|")
    line.gsub(/(!?)\[\[([^\]]+?)\]\]/) do
      embed = Regexp.last_match(1)
      inner = Regexp.last_match(2)
      target, sep, label = inner.partition(/\\?\|/)
      target_backslash = target.end_with?("\\")
      target = target.chomp("\\")
      file, *anchors = target.split("#", -1)
      base = File.basename(file.empty? ? own : file)

      cz_anchors = anchors.map do |a|
        next a if a.start_with?("^") || a.empty?

        map = anchor_map.fetch(base, {})
        cz = map[norm(a)] || map.values.find { |v| norm(v) == norm(a) }
        unresolved["#{base}##{a}"] += 1 if anchor_map.key?(base) && cz.nil?
        cz || a
      end

      new_target = ([file] + cz_anchors).join("#")
      # Labels left in English (a note title or the anchored heading) get the Czech text.
      if in_czech && !label.empty?
        english_title = titles.keys.find { |t| norm(t) == norm(label) }
        if english_title
          label = titles[english_title]
        elsif anchors.any? && norm(anchors.last) == norm(label) && cz_anchors.last != anchors.last
          label = cz_anchors.last
        end
      end
      if sep.empty? && embed.empty? && in_czech
        label = if cz_anchors.any? && !cz_anchors.last.start_with?("^")
                  cz_anchors.last
                else
                  titles[base]
                end
        sep = table ? "\\|" : "|" if label
      end
      sep = "\\|" if target_backslash && sep == "|"
      "#{embed}[[#{new_target}#{sep}#{label}]]"
    end
  end.join

  next if updated == original

  File.write(path, updated)
  changed += 1
end

puts "translated notes: #{translated.size}, files updated: #{changed}"
unless unresolved.empty?
  puts "unresolved anchors (left as is):"
  unresolved.sort.each { |k, n| puts "  #{k} (#{n}x)" }
end
