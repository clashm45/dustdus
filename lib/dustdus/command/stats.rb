require 'git_diff_parser'
require 'io/console'

module Dustdus
  class Command < Thor
    desc 'stats', 'statistics'

    def stats(name = "")
      # diff = STDIN.noecho(&:readlines)
      diff = $stdin.readlines
      patches = GitDiffParser.parse(diff.join)

      patches_map = patches.map do |p|
        {
            file:    p.file,
            change:  p.changed_lines.length.to_s,
            removed: p.removed_lines.length.to_s
        }
      end

      max_filename = patches_map.map { |o| o[:file].length }.max
      max_change   = patches_map.map { |o| o[:change].length }.max
      max_removed  = patches_map.map { |o| o[:removed].length }.max

      patches_map.each do |p|
        message = p[:file].ljust(max_filename, ' ')
        change  = p[:change].ljust(max_change, ' ')
        removed = p[:removed].ljust(max_removed, ' ')
        puts "#{message} | change:#{change}, removed:#{removed}"
      end

    end
  end
end
