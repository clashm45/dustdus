module Dustdus
  class Command < Thor
    desc 'summary', 'say hello!'

    def summary
      diff    = $stdin.readlines
      patches = GitDiffParser.parse(diff.join)

      summarize = summarize(patches)
      app_names(summarize)
      details(summarize)
      gemfile(summarize)
      db_changed(summarize)
    end

    private

    def summarize(patches)
      patches.reduce({}) do |summary, p|
        file_path = p.file.split('/')
        name      = file_path[0]
        if name.include?('.')
          next summary # 拡張子付きファイルはスキップ
        end

        if summary[name.to_sym].nil?
          summary[name.to_sym] = {
              app:   false,
              lib:   false,
              other: false,
              gem:   false,
              db:    []
          }
        end
        dir = file_path[1]
        case dir
        when "app"
          summary[name.to_sym][:app] = true
        when "lib"
          summary[name.to_sym][:lib] = true
        when "db"
          summary[name.to_sym][:db] << p.file
        when "Gemfile"
          summary[name.to_sym][:gem]     = true
          summary[name.to_sym][:gemfile] = p # 変更のあったGemfile Patch
        else
          summary[name.to_sym][:other] = true
        end
        summary
      end
    end

    def app_names(summarize)
      # 変更のあるアプリ名
      puts "# 変更のあるアプリ"
      summarize.keys.each { |name| puts "* #{name}" }
      puts ""
    end

    def details(summarize)
      # 変更のあるアプリ - 詳細
      key_length = summarize.map { |key, s| key.to_s.length }.max
      puts "| #{"App name".ljust(key_length, ' ')} | model | lib   | other |"
      puts "| #{"--------".ljust(key_length, '-')} | ----- | ----- | ----- |"
      summarize.each do |key, s|
        k_name      = key.to_s.ljust(key_length, ' ')
        app_check   = s[:app] ? 'true ' : '-    '
        lib_check   = s[:lib] ? 'true ' : '-    '
        other_check = s[:other] ? 'true ' : '-    '
        puts "| #{k_name} | #{app_check} | #{lib_check} | #{other_check} |"
      end
      puts ""
    end

    def gemfile(summarize)
      puts "# Gemfile changed list"
      summarize.each do |key, s|
        puts "* #{key.to_s}"
        if s[:gem]
          if s[:gemfile].changed_lines.length > 0
            puts "  * changed lines"
            s[:gemfile].changed_lines.select { |l| l.content.include?('gem') }.each do |l|
              puts "    * #{l.number} : #{l.content}"
            end
          end
          if s[:gemfile].removed_lines.length > 0
            puts "  * removed lines"
            s[:gemfile].removed_lines.select { |l| l.content.include?('gem') }.each do |l|
              puts "    * #{l.number} : #{l.content}"
            end
          end
        else
          puts "  * no change"
        end
      end
      puts ""
    end

    def db_changed(summarize)
      puts "# db changed list"
      summarize.each do |key, s|
        puts "* #{key.to_s}"
        if s[:db].length > 0
          s[:db].each { |m| puts "    * #{m}" }
        end
      end
    end
  end

end