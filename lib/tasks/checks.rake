namespace :check do

  task :hardcoded do
    files = %x{git grep -l '<stringProp name="filename">[^<$[ ]' -- '*.jmx'}.split
    raise "[ERROR] Found JMX files with hard-coded paths: \n#{files.join("\n")}" if files.any?
  end

end
