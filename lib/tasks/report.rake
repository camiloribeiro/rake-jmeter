#encoding: UTF-8
REPORTS = %w[
  ThreadsStateOverTime
  ResponseTimesOverTime
  LatenciesOverTime
  ResponseCodesPerSecond
  ResponseTimesDistribution
  ResponseTimesPercentiles
  ThroughputVsThreads
]

desc 'Generates a report from a JTL file'
task :report, :jtl do |t, args|
  jtl = File.expand_path(args.jtl)
  raise "#{jtl} does not exist" unless File.exists?(jtl)
  acc_file = "config/#{(File.basename(jtl, '.jtl').split('_')[0..-3]).join('_')}_acc.rb"
  require "./#{acc_file}"

  out_dir = File.expand_path(File.join('reports', File.basename(jtl, '.jtl')))
  FileUtils.mkdir_p out_dir
  puts "Before the symlink..."
  symlink_log = File.join('reports', (File.basename(jtl, '.jtl').split('_')[0..-3]).join('_'))
  File.delete(symlink_log) if File.exists?(symlink_log)
  File.symlink(out_dir, symlink_log)

  Rake::Task['report:percentiles'].invoke jtl, out_dir
  Rake::Task['report:percentiles:below_threshold'].invoke File.join(out_dir, 'ResponseTimesPercentiles.csv')
  Rake::Task['report:averages'].invoke jtl, out_dir
  Rake::Task['report:st_deviation'].invoke jtl, out_dir
  Rake::Task['report:summary'].invoke out_dir
  Rake::Task['report:pngs'].invoke jtl, out_dir
  Rake::Task['report:overTime'].invoke
  Rake::Task['report:return_console'].invoke out_dir
end

namespace :report do

  task :overTime do
    writeReportTime
  end


  task :pngs, :jtl, :out_dir do |t, args|
    REPORTS.each do |report|
      jmeter_cmd :jtl => File.expand_path(args.jtl),
        :out_dir => File.expand_path(args.out_dir),
        :report => report,
        :report_type => :png,
        :width => 940,
        :height => 500,
        :aggregate => ENV.has_key?('AGGREGATE')
    end
  end

  task :averages, :jtl, :out_dir do |t, args|
    jmeter_cmd :jtl => File.expand_path(args.jtl),
      :report => 'AggregateReport',
      :report_type => :csv,
      :out_dir => File.expand_path(args.out_dir),
      :aggregate => false
  end

  task 'return_console', :out_dir do |t, args|
    puts (  "#{args.out_dir}/Summary.html")
   # Launchy.open "#{args.out_dir}/Summary.html" 
   # puts 0 if @issues.size == 0
   # puts "ERROR, see report" if @issues.size != 0
  end

  task :st_deviation, :jtl, :out_dir do |t, args|
    jmeter_cmd :jtl => File.expand_path(args.jtl),
      :report => 'StandardDeviationReport',
      :report_type => :csv,
      :out_dir => File.expand_path(args.out_dir),
      :aggregate => false
  end

  task :percentiles, :jtl, :out_dir do |t, args|
    jmeter_cmd :jtl => File.expand_path(args.jtl),
      :report => 'ResponseTimesPercentiles',
      :report_type => :csv,
      :out_dir => File.expand_path(args.out_dir),
      :aggregate => false
  end

  task 'percentiles:below_threshold', :file do |t, args|
    file = File.expand_path args.file
    raise "#{file} does not exist!" unless File.exists?(file)

    data = CSV.read(file, :headers => true, :converters => [:numeric]).map &:to_hash

    open(File.expand_path(File.join(File.dirname(file), 'PercentileBelowThreshold.csv')), 'w') do |f|
      f.puts 'Transaction,percentile_1,percentile_2,percentile_3,percentile_4,percentile_5'
      totals = [0, 0, 0, 0, 0]
      cols = data.first.keys.size - 1
      (data.first.keys - ['Percentiles']).each do |col|
        totals[0] += (percentile_1 = data.select {|row| row[col] < @percentile_1 if row }.last['Percentiles'] / 100 rescue 0) / cols
        totals[1] += (percentile_2 = data.select {|row| row[col] < @percentile_2 if row }.last['Percentiles'] / 100 rescue 0) / cols
        totals[2] += (percentile_3 = data.select {|row| row[col] < @percentile_3 if row }.last['Percentiles'] / 100 rescue 0) / cols
        totals[3] += (percentile_4 = data.select {|row| row[col] < @percentile_4 if row }.last['Percentiles'] / 100 rescue 0) / cols
        totals[4] += (percentile_5 = data.select {|row| row[col] < @percentile_5 if row }.last['Percentiles'] / 100 rescue 0) / cols
        f.puts [col, percentile_1, percentile_2, percentile_3, percentile_4, percentile_5].join(',')
      end
      f.puts ['TOTAL', *totals].join(',')
    end
  end

  def link_to_newrelic_server(account_id, id, tstamp)
    start_time = tstamp.to_i
    end_time = tstamp.to_i + (30 * 60)

    "https://rpm.newrelic.com/accounts/#{account_id}/servers/#{id}?tw%5Bstart%5D=#{start_time}&tw%5Bend%5D=#{end_time}"
  end

  def link_to_newrelic_app(account_id, id, tstamp)
    start_time = tstamp.to_i
    end_time = tstamp.to_i + (30 * 60)

    "https://rpm.newrelic.com/accounts/#{account_id}/applications/#{id}?tw%5Bstart%5D=#{start_time}&tw%5Bend%5D=#{end_time}"
  end

  task 'summary', :out_dir do |t, args|
    require 'date'
    require 'time'
    out_dir = args.out_dir
    raise "#{out_dir} does not exist!" unless File.exists?(out_dir)

    percentiles_below_threshold = CSV.read(File.join(out_dir, 'PercentileBelowThreshold.csv'), :headers => true, :converters => [:numeric]).map &:to_hash
    aggregate = CSV.read(File.join(out_dir, 'AggregateReport.csv'), :headers => true, :converters => [:numeric]).map &:to_hash
    st_deviation = CSV.read(File.join(out_dir, 'StandardDeviationReport.csv'), :headers => true, :converters => [:numeric]).map &:to_hash
    tstamp = Time.parse(DateTime.parse(File.basename(out_dir).split(/_/)[-2,2].join).to_s)



    @build_number = Time.new

    md = <<-MKD
# #{@project_name} – #{File.basename(out_dir).split(/_/)[0, 2].join(' ')}

* Executed at #{tstamp.strftime '%d/%m/%y, às %H:%M'}
* JMeter log: `#{File.basename out_dir}.jtl`

## Summary

Result Table:

Page|Requests|AVG|Median|Std Deviation|% Deviation|Minimum|90%|Maximum|Throughput|% error|#{@percentile_1_label}|#{@percentile_2_label}|#{@percentile_3_label}|#{@percentile_4_label}|#{@percentile_5_label}
----|--------|---|------|-------------|-----------|-------|---|-------|----------|-------|---------|------|------|------|------
MKD
    aggregate.each do |agg|
      summary = agg.merge(percentiles_below_threshold.find {|pbt| pbt['Transaction'] == agg['sampler_label']} || {})
      summary['standard_deviation'] = st_deviation.find{|s| s['sampler_label'] == agg['sampler_label']}['standard_deviation_report_stddev'] || 0

      @date = DateTime.now 
      # redis.set("build:page:median_report_line", median_report_line)
      md << [
        summary['sampler_label'],
        aggregate_report_line(summary),
        average_report_line(summary),
        median_report_line(summary),
        stdeviation_report_line(summary),
        percent_deviation_report_line(summary),
        max_min_report_line(summary),
        percentile_report_line(summary),
        max_max_report_line(summary),
        throughput_report_line(summary),
        error_rate_report_line(summary),
        percentile_1_report_line(summary),
        percentile_2_report_line(summary),
        percentile_3_report_line(summary),
        percentile_4_report_line(summary),
        percentile_5_report_line(summary),
      ].map {|s|  s}.join('|')
      md << "\n"
    end

    md << <<-MKD

## Thread Distribution (Thread State Over Time)

![Distribuição das threads](ThreadsStateOverTime.png)

## Response Time

![Tempos de Resposta](ResponseTimesOverTime.png)

## Latency Time

![Tempos de Latência](LatenciesOverTime.png)

# Response types

![Status das respostas](ResponseCodesPerSecond.png)

# Response time distribution

![Distribuição de tempos de resposta](ResponseTimesDistribution.png)

# Response time percentils

![Percentis de tempos de resposta](ResponseTimesPercentiles.png)

Issues:

Issue|Label|Item|Expected|Real
-----|-----|----|--------|----
MKD
    @issues.each do |issue|
      md << [issue.id,
        issue.label,
        issue.item,
        issue.expected,
        issue.real
        ].map {|s| s}.join('|')
      md << "\n"
    end

  md << "There is not issues in this report :D" if(@issues.size == 0)
 md << <<-MKD

  MKD

    open(File.join(out_dir, 'Summary.html'), 'w') do |f|
      f.write '<!DOCTYPE html><html><head><meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>'
      f.write '<link rel="stylesheet" href="http://getbootstrap.com/2.3.2/assets/css/bootstrap.css"/>'
      f.write "<style>h1,h2,h3,h4 { margin-bottom: .5em; margin-top: .5em; }</style><title>#{@project_name} - Performance Test Summary</title></head><body>"
      f.write '<div>'
      f.write Redcarpet::Markdown.new(Redcarpet::Render::HTML, :tables => true, :autolink => true).render(md)
      f.write '<script>document.getElementsByTagName("table")[0].setAttribute("class", "table table-bordered table-striped")</script>'
      f.write '<script>document.getElementsByTagName("table")[1].setAttribute("class", "table table-bordered table-striped")</script>'
      f.write '</div></body></html>'
    end
  end

  def jmeter_cmd(options)
    jtl = options.delete :jtl
    report = options.delete :report
    report_type = options.delete :report_type
    out_dir = options.delete :out_dir
    aggregate = options.delete :aggregate
    width = options.delete :width
    height = options.delete :height

    sh <<-CMD
      java -Xmx1024m -XX:MaxPermSize=256m -Dfile.encoding=UTF-8 -Djava.awt.headless=true -jar ./jmeter/2.9/lib/ext/CMDRunner.jar \
        --tool Reporter \
        --generate-#{report_type} #{File.expand_path File.join(out_dir, report)}.#{report_type} \
        --input-jtl #{File.expand_path jtl} \
        --plugin-type #{report} \
        --aggregate-rows #{!aggregate || %w[ResponseCodesPerSecond ThroughputVsThreads].include?(report) ? 'no' : 'yes'} \
        #{"--paint-gradient no" if report_type == :png} \
        #{"--width #{width}" if width} \
        #{"--height #{height}" if height}
    CMD
  end

  def aggregate_report_line(summary) 
    number_samples = summary['aggregate_report_count']
    saveData(summary['sampler_label'], "Number of Requests", number_samples)
    if number_samples < @min_samplers  
      desc_issue(@min_samplers, number_samples, "Number of samplers", summary['sampler_label']) 
      "<b>#{number_samples}</b>"
    else 
      number_samples
    end
  end

  def average_report_line(summary) 
    avg = summary['average']
    saveData(summary['sampler_label'], "Average Response Time", avg)
    if avg > @max_avg_time
      desc_issue(@max_avg_time, avg, "Average", summary['sampler_label']) 
      "<b>#{avg}</b>"
    else 
      avg
    end
  end

  def median_report_line(summary) 
    median = summary['aggregate_report_median']
    saveData(summary['sampler_label'], "Median", median)
    if median > @max_median
      desc_issue(@max_median, median, "Median", summary['sampler_label']) 
      "<b>#{median}</b>"
    else 
      median
    end
  end

  def stdeviation_report_line(summary) 
    std_deviation = ( "%.2f" % summary['standard_deviation']).to_f
    saveData(summary['sampler_label'], "Standard Deviation", std_deviation)
    if std_deviation > @max_standard_deviation
      desc_issue(@max_avg_time, std_deviation, "Std. Deviation", summary['sampler_label']) 
      "<b>#{std_deviation}</b>"
    else 
      std_deviation
    end
  end

  def percent_deviation_report_line(summary) 
    percentile_deviation = ( "%.2f" % ((summary['standard_deviation'] / summary['aggregate_report_max']) * 100)).to_f
    saveData(summary['sampler_label'], "Percent Deviation", percentile_deviation)
    if percentile_deviation > @max_percentile_deviation
      desc_issue(@max_percentile_deviation, percentile_deviation, "% Deviation", summary['sampler_label']) 
      "<b>#{percentile_deviation}</b>"
    else 
      percentile_deviation
    end
  end

  def max_min_report_line(summary) 
    min = summary["aggregate_report_min"]
    saveData(summary['sampler_label'], "Min Response Time", min )
    if min > @max_min_time
      desc_issue(@max_min_time, min, "Min Time", summary['sampler_label']) 
      "<b>#{min}</b>"
    else 
      min
    end
  end

  def max_max_report_line(summary) 
    max = summary["aggregate_report_max"]
    saveData(summary['sampler_label'], "Max Response Time", max)
    if max > @max_max_time
      desc_issue(@max_max_time, max, "Max Time", summary['sampler_label']) 
      "<b>#{max}</b>"
    else 
      max
    end
  end

  def percentile_report_line(summary) 
    line90 = summary["aggregate_report_90%_line"]
    saveData(summary['sampler_label'], "90% Percentile", line90)
    if line90 > @max_90
      desc_issue(@max_90, line90, "90% Line", summary['sampler_label']) 
      "<b>#{line90}</b>"
    else 
      line90
    end
  end

  def throughput_report_line(summary) 
    throughput = ("%.2f" % summary["aggregate_report_rate"]).to_f
    saveData(summary['sampler_label'], "Throughput", throughput)
    if throughput < @min_throughput
      desc_issue(@min_throughput, throughput, "Min Throughtput", summary['sampler_label']) 
      "<b>#{throughput}</b>"
    else 
      throughput
    end
  end

  def error_rate_report_line(summary) 
    error_rating = ("%.2f" %  (summary["aggregate_report_error%"] * 100)).to_f
    saveData(summary['sampler_label'], "Error Rating", error_rating)
    if error_rating > @max_error_rate
      desc_issue(@max_error_rate, error_rating, "% Error", summary['sampler_label']) 
      "<b>#{error_rating}</b>"
    else 
      error_rating
    end
  end

  def percentile_1_report_line(summary) 
    line_real = (summary["percentile_1"] * 100)
    saveData(summary['sampler_label'], @percentile_1_label, line_real)
    line_expected = @min_response_time_under_percentile_1
    if line_real < line_expected
      desc_issue(line_expected, line_real, @percentile_1_label , summary['sampler_label']) 
      "<b>#{ "%.4f" % line_real}</b>"
    else 
      line_real
    end
  end

  def percentile_2_report_line(summary) 
    line_real = (summary["percentile_2"] * 100 )
    saveData(summary['sampler_label'], @percentile_2_label, line_real)
    line_expected = @min_response_time_under_percentile_2
    if line_real < line_expected
      desc_issue(line_expected, line_real, @percentile_2_label , summary['sampler_label']) 
      "<b>#{ "%.4f" % line_real}</b>"
    else 
      line_real
    end
  end

  def percentile_3_report_line(summary) 
    line_real = (summary["percentile_3"] * 100 )
    saveData(summary['sampler_label'], @percentile_3_label, line_real)
    line_expected = @min_response_time_under_percentile_3
    if line_real < line_expected
      desc_issue(line_expected, line_real, @percentile_3_label , summary['sampler_label']) 
      "<b>#{ "%.4f" % line_real}</b>"
    else 
      line_real
    end
  end

  def percentile_4_report_line(summary) 
    line_real = (summary["percentile_4"] * 100)
    saveData(summary['sampler_label'], @percentile_4_label, line_real)
    line_expected = @min_response_time_under_percentile_4
    if line_real < line_expected
      desc_issue(line_expected, line_real, @percentile_4_label , summary['sampler_label']) 
      "<b>#{ "%.4f" % line_real}</b>"
    else 
      line_real
    end
  end

  def percentile_5_report_line(summary) 
    line_real = (summary["percentile_5"] * 100)
    saveData(summary['sampler_label'], @percentile_5_label, line_real)
    line_expected = @min_response_time_under_percentile_5
    if line_real < line_expected
      desc_issue(line_expected, line_real, @percentile_5_label , summary['sampler_label']) 
      "<b>#{ "%.4f" % line_real}</b>"
    else 
      line_real
    end
  end

  def saveData(file, key, value)
    file = "#{file.gsub(/\s+/, "_")}"
    file = "./data/#{file}.csv"
    File.open(file, "r").each_line do |line|
      if(line =~ /^#{key}/)
        text = File.read(file)
        text = text.gsub(line, line.gsub("\n",("|'#{@date}':#{value.to_s}\n")))
        File.open(file, "w")  {|newFile| newFile.puts text} 
      end
    end  
  end

  def writeReportTime
    page = '<!-- You are free to copy and use this sample in accordance with the terms of the Apache license (http://www.apache.org/licenses/LICENSE-2.0.html) --> <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"> <html xmlns="http://www.w3.org/1999/xhtml"> <head> <meta charset="utf-8"> <title>Performance Report</title> <meta name="viewport" content="width=device-width, initial-scale=1.0"> <meta name="description" content=""> <meta name="author" content=""> <!-- Le styles --> <link href="bootstrap/css/bootstrap.css" rel="stylesheet"> <style> body { padding-top: 60px; /* 60px to make the container go all the way to the bottom of the topbar */ } </style> <!-- HTML5 shim, for IE6-8 support of HTML5 elements --> <!--[if lt IE 9]> <script src="../assets/js/html5shiv.js"></script> <![endif]--> <!-- Fav and touch icons --> <link rel="apple-touch-icon-precomposed" sizes="144x144" href="../assets/ico/apple-touch-icon-144-precomposed.png"> <link rel="apple-touch-icon-precomposed" sizes="114x114" href="../assets/ico/apple-touch-icon-114-precomposed.png"> <link rel="apple-touch-icon-precomposed" sizes="72x72" href="../assets/ico/apple-touch-icon-72-precomposed.png"> <link rel="apple-touch-icon-precomposed" href="../assets/ico/apple-touch-icon-57-precomposed.png"> <link rel="shortcut icon" href="../assets/ico/favicon.png"> <script type="text/javascript" src="https://www.google.com/jsapi"></script> <script src="./chartkick.js"></script> </head>'
    page += '<body> <div class="navbar navbar-inverse navbar-fixed-top"> <div class="navbar-inner"> <div class="container"> <button type="button" class="btn btn-navbar" data-toggle="collapse" data-target=".nav-collapse"> <span class="icon-bar"></span> <span class="icon-bar"></span> <span class="icon-bar"></span> </button> <a class="brand" id="project_name" href="#"></a> <div class="nav-collapse collapse"> <ul class="nav"> <script> for (var i = 0; i < name_resource.length; i++) { document.write("<li><a href="#" onclick="updatePage("+i+");">"+name_resource[i]+"</a></li>"); } </script> </ul> </div><!--/.nav-collapse --> </div> </div> </div> <div class="container">' 
    page += "<div><H2>Pagina X</h2>"

    File.open("data/Home_Page.csv", "r").each_line do |line|
      name = line.split("|")[0]
      data = line.slice(line.index("|")+1..-1)
      page += addChart(name, data)
    end
    page += '</div>' 
    page += ' <!-- /container --> </body>' 

    File.open("myFile.html", 'w') { |file| file.write(page)}
  end

  def addChart(name, data)
    require "chartkick"
    include Chartkick
    allTuples = ""
    fragment = "<h3>#{name}</h3>"
    fragment << "<div id='#{name}' style='height: 300px; text-align: center; color: #999; line-height: 300px; font-size: 14px; font-family: 'Lucida Grande', 'Lucida Sans Unicode', Verdana, Arial, Helvetica, sans-serif;'>"
    fragment << "Loading..."
    fragment << "</div><script type='text/javascript'>"
    fragment << "new Chartkick.LineChart('#{name}',[ {'name':'#{name}', 'data':{ "
    arr = data.split("|").each do |row| 
      tuple = row.split(":")
      tuple = [tuple[0], tuple[1].to_i].to_a
      allTuples = tuple if allTuples.nil?
      [allTuples,tuple].to_a
    end
    fragment << arr.join(",")
    fragment << "}}]);</script>"
  end
end
