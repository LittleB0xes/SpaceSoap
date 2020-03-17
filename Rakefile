def split_args key, should_throw = true
  if !ARGV.join(" ").include?(" -- ") && !ARGV.join(" ").include?(" =") && should_throw
      raise <<-S

* Error
rake #{ARGV.join(" ")}
Arguments to the rake task need to be seperated by a \"--\" between the task name and arguments.
For example rake default -- --arg1=value

S
  else
    result = Hash[ARGV.join(" ")
                      .split(" -- ").last
                      .split("--").reject { |l| l.strip.length == 0 }
                      .map { |l| [l.split("=").first.strip, l.split("=")[1..-1].join("=").strip] }]

    if !result[key] && should_throw
      raise <<-S

* Error
rake #{ARGV.join(" ")}
Argument --#{key}= was not supplied.
Arguments to the rake task need to be seperated by a \"--\" between the task name and arguments.
For example rake default -- --arg1=value

S
    end

    result[key]
  end
end

# usage
task :commit do
  message = split_args('message')
  email = split_args('email', false) || 'no email provided'
  sh "git add ."
  sh "git commit -m \"#{message} by #{email}\""
end

desc "This is the default rake task"
task :default do
  puts "hello world"
  sh "git status"
end

desc "This is the step one"
task :step_one do
  puts "step one"
end

task :step_two do
  puts "step one"
end

task :step_three do
  puts "step three"
end
