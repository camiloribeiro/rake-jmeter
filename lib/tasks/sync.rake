require 'rubygems/package'
namespace :sync do

  desc 'Sync all nodes'
  task :run do
    STRESS_SERVERS_EXTERNAL.each do |machine|
      puts "[INFO][#{Time.now.to_i}] Copying files to #{machine.name}..."
      cmd = "rsync -zavuSH --delete --exclude='*.jtl' --exclude='.git' --exclude='*.swp' --exclude='*.log' --exclude='*.png' . #{machine.name}:#{@project_dir}"
      ENV['DRY'] ? puts(cmd) : sh(cmd)
    end
  end

  desc 'Download and extracts the last version of Jmeter with all the plugins needed'
  task :install do
    puts "Downloading JMeter binaries from: #{@jmeter_binaries}" 
    curl = Curl::Easy.new(@jmeter_binaries)
    curl.perform
    puts "Download complete" 
    
    puts "Extracting files" 
    Gem::Package::TarReader.new( Zlib::GzipReader.open "./jmeter.tgz") do |tar|
      destination = "./"
      dest = nil
      tar.each do |entry|
        if entry.full_name == "././@LongLink" 
          dest = File.join destination, entry.read.strip
          next
        end
        dest ||= File.join destination, entry.full_name
        if entry.directory?
          FileUtils.rm_rf dest unless File.directory? dest
          FileUtils.mkdir_p dest, :mode => entry.header.mode, :verbose => false
        elsif entry.file?
          FileUtils.rm_rf dest unless File.file? dest
          File.open dest, "wb" do |f|
            f.print entry.read
          end
          FileUtils.chmod entry.header.mode, dest, :verbose => false
        elsif entry.header.typeflag == '2' #Symlink!
          File.symlink entry.header.linkname, dest
        end
        dest = nil
      end
    end
  end
end
