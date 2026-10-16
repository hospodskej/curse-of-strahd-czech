#!/usr/bin/env ruby
# frozen_string_literal: true

# Reassembles translated chunks into the vault and checks that the Czech
# text kept the Markdown/Obsidian structure of the English original.
#
#   ruby tools/join.rb <vault_dir> <work_dir> [--check]
#
# A note is written only when every NNN.en.md has a matching NNN.cs.md.
# English stat blocks stashed by tools/split.rb are put back in place.
# With --check nothing is written; structural problems are just reported.

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

def structure(text)
  {
    "headings" => text.lines.grep(/\A#+ /).map { |l| l[/\A#+/] },
    "callouts" => text.scan(/^>\s*\[!([a-z-]+)\]/).flatten,
    "table rows" => text.lines.count { |l| l =~ /\A(>\s*)?\|/ },
    "embeds" => text.scan(/!\[\[[^\]]+\]\]/),
    "link targets" => text.scan(/(?<!!)\[\[([^\]|#]*)/).flatten.sort,
    "stat blocks" => text.scan(/<!--STATBLOCK:\d+-->/),
    "block ids" => text.scan(/\^[A-Za-z0-9-]+\s*$/).map(&:strip).sort
  }
end

def compare(en, cs)
  a = structure(en)
  b = structure(cs)
  a.keys.reject { |k| a[k] == b[k] }.map do |k|
    k == "table rows" ? "#{k}: #{a[k]} vs #{b[k]}" : "#{k} differ"
  end
end

vault, work, flag = ARGV
abort "usage: join.rb <vault_dir> <work_dir> [--check]" unless vault && work
check_only = flag == "--check"
problems = 0

Dir[File.join(work, "*", "SOURCE")].map { |s| File.dirname(s) }.sort.each do |dir|
  note = File.read(File.join(dir, "SOURCE")).strip
  en_files = Dir[File.join(dir, "*.en.md")].sort
  done = en_files.select { |f| File.exist?(f.sub(".en.md", ".cs.md")) }
  status = "#{done.size}/#{en_files.size}"

  done.each do |en_file|
    cs_file = en_file.sub(".en.md", ".cs.md")
    compare(File.read(en_file), File.read(cs_file)).each do |msg|
      problems += 1
      puts "  ! #{File.basename(dir)}/#{File.basename(cs_file)}: #{msg}"
    end
  end

  if done.size == en_files.size && !check_only
    text = done.map { |f| File.read(f.sub(".en.md", ".cs.md")) }.join
    text = text.gsub(/<!--STATBLOCK:(\d+)-->/) do
      File.read(File.join(dir, "statblocks", "#{Regexp.last_match(1)}.html"))
    end
    File.write(File.join(vault, note), text)
    puts "#{status} written  #{note}"
  else
    puts "#{status}          #{note}"
  end
end

exit(problems.zero? ? 0 : 1)
