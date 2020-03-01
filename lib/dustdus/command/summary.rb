module Dustdus
  class Command < Thor
    desc 'summary', 'say hello!'

    def summary

      diff    = $stdin.readlines
      patches = GitDiffParser.parse(diff.join)

      summarize = patches.reduce({}) do |summary, p|
        file_path = p.file.split('/')
        name = file_path[0]
        if summary[name.to_sym].nil?
          summary[name.to_sym] = {
              app:   false,
              lib:   false,
              other: false,
              gem:   false
          }
        end
        dir = file_path[1]
        case dir
        when "app"
          summary[name.to_sym][:app] = true
        when "lib"
          summary[name.to_sym][:lib] = true
        when "Gemfile"
          summary[name.to_sym][:gem] = true
        else
          summary[name.to_sym][:other] = true
        end
        summary
      end

      # 変更のあるアプリ名
      puts "# 変更のあるアプリ"
      summarize.keys.each { |name| puts "* #{name}" }

      # 変更のあるアプリ - 詳細

      puts ""
      puts "| App name | model | lib | other |"
      puts "| -------- | ----- | --- | ----- |"
      summarize.each do |key, s|
        puts "| #{key} | #{s[:app]} | #{s[:lib]} | #{s[:other]} |"
      end

    end
  end
end