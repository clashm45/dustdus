module Dustdus
  class Command < Thor
    desc 'hello', 'say hello!'

    def hello(name = "")
      puts "Hello! #{name}"

      hh = $stdin.readlines
      puts "====="
      pp hh
    end
  end
end