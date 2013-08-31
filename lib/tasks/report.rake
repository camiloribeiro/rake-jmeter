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
  Rake::Task['report:return_console'].invoke out_dir
end

namespace :report do

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
      f.puts 'Transaction,s05,2s,4s,6s,8s'
      totals = [0, 0, 0, 0, 0]
      cols = data.first.keys.size - 1
      (data.first.keys - ['Percentiles']).each do |col|
        totals[0] += (s05 = data.select {|row| row[col] < 500.0 if row }.last['Percentiles'] / 100 rescue 0) / cols
        totals[1] += (s2 = data.select {|row| row[col] < 2000.0 if row }.last['Percentiles'] / 100 rescue 0) / cols
        totals[2] += (s4 = data.select {|row| row[col] < 4000.0 if row }.last['Percentiles'] / 100 rescue 0) / cols
        totals[3] += (s6 = data.select {|row| row[col] < 6000.0 if row }.last['Percentiles'] / 100 rescue 0) / cols
        totals[4] += (s8 = data.select {|row| row[col] < 8000.0 if row }.last['Percentiles'] / 100 rescue 0) / cols
        f.puts [col, s05, s2, s4, s6, s8].join(',')
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

    md = <<-MKD
# #{@project_name} – #{File.basename(out_dir).split(/_/)[0, 2].join(' ')}

* Executed at #{tstamp.strftime '%d/%m/%y, às %H:%M'}
* JMeter log: `#{File.basename out_dir}.jtl`

## Summary

Result Table:

Page|Requests|AVG|Median|Std Deviation|% Deviation|Minimum|90%|Maximum|Throughput|% error|% < 500ms|% < 2s|% < 4s|% < 6s|% < 8s
----|--------|---|------|-------------|-----------|-------|---|-------|----------|-------|---------|------|------|------|------
MKD
    aggregate.each do |agg|
      summary = agg.merge(percentiles_below_threshold.find {|pbt| pbt['Transaction'] == agg['sampler_label']} || {})
      summary['standard_deviation'] = st_deviation.find{|s| s['sampler_label'] == agg['sampler_label']}['standard_deviation_report_stddev'] || 0

      md << [
        summary['sampler_label'],
        aggregate_report_line(summary),
        average_report_line(summary),
        median_report_line(summary),
        stdeviation_report_line(summary),
        percent_deviation_report_line(summary),
        max_min_report_line(summary),
        percentil_report_line(summary),
        max_max_report_line(summary),
        throughput_report_line(summary),
        error_rate_report_line(summary),
        s05_report_line(summary),
        s2_report_line(summary),
        s4_report_line(summary),
        s6_report_line(summary),
        s8_report_line(summary),
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
      if number_samples < @min_samplers  
        desc_issue(@min_samplers, number_samples, "Number of samplers", summary['sampler_label']) 
        "<b>#{number_samples}</b>"
      else 
        number_samples
      end
  end

  def average_report_line(summary) 
      avg = summary['average']
      if avg > @max_avg_time
        desc_issue(@max_avg_time, avg, "Average", summary['sampler_label']) 
        "<b>#{avg}</b>"
      else 
        avg
      end
  end

  def median_report_line(summary) 
      median = summary['aggregate_report_median']
      if median > @max_median
        desc_issue(@max_median, median, "Median", summary['sampler_label']) 
        "<b>#{median}</b>"
      else 
        median
      end
  end

  def stdeviation_report_line(summary) 
      std_deviation = ( "%.2f" % summary['standard_deviation']).to_f
      if std_deviation > @max_standard_deviation
        desc_issue(@max_avg_time, std_deviation, "Std. Deviation", summary['sampler_label']) 
        "<b>#{std_deviation}</b>"
      else 
        std_deviation
      end
  end

  def percent_deviation_report_line(summary) 
      percentil_deviation = ( "%.2f" % ((summary['standard_deviation'] / summary['aggregate_report_max']) * 100)).to_f
      if percentil_deviation > @max_percentil_deviation
        desc_issue(@max_percentil_deviation, percentil_deviation, "% Deviation", summary['sampler_label']) 
       "<b>#{percentil_deviation}</b>"
      else 
        percentil_deviation
      end
  end

  def max_min_report_line(summary) 
      min = summary["aggregate_report_min"]
      if min > @max_min_time
        desc_issue(@max_min_time, min, "Min Time", summary['sampler_label']) 
        "<b>#{min}</b>"
      else 
        min
      end
  end

  def max_max_report_line(summary) 
      max = summary["aggregate_report_max"]
      if max > @max_max_time
        desc_issue(@max_max_time, max, "Max Time", summary['sampler_label']) 
        "<b>#{max}</b>"
      else 
        max
      end
  end

  def percentil_report_line(summary) 
      line90 = summary["aggregate_report_90%_line"]
      if line90 > @max_90
        desc_issue(@max_90, line90, "90% Line", summary['sampler_label']) 
        "<b>#{line90}</b>"
      else 
        line90
      end
  end

  def throughput_report_line(summary) 
      throughput = ("%.2f" % summary["aggregate_report_rate"]).to_f
      if throughput < @min_throughput
        desc_issue(@min_throughput, throughput, "Min Throughtput", summary['sampler_label']) 
        "<b>#{throughput}</b>"
      else 
        throughput
      end
  end

  def error_rate_report_line(summary) 
      error_rating = ("%.2f" %  (summary["aggregate_report_error%"] * 100)).to_f
      if error_rating > @max_error_rate
        desc_issue(@max_error_rate, error_rating, "% Error", summary['sampler_label']) 
        "<b>#{error_rating}</b>"
      else 
        error_rating
      end
  end

  def s05_report_line(summary) 
     line_real = (summary["s05"] * 100)
     line_expected = @min_response_time_under_500ms
     if line_real < line_expected
        desc_issue(line_expected, line_real, "Under 0.5s", summary['sampler_label']) 
        "<b>#{ "%.2f" % line_real}</b>"
      else 
       line_real
      end
  end

  def s2_report_line(summary) 
     line_real = (summary["2s"] * 100 )
     line_expected = @min_response_time_under_2s
     if line_real < line_expected
        desc_issue(line_expected, line_real, "Under 2s", summary['sampler_label']) 
        "<b>#{ "%.2f" % line_real}</b>"
      else 
        line_real
      end
  end

  def s4_report_line(summary) 
     line_real = (summary["4s"] * 100 )
     line_expected = @min_response_time_under_4s
     if line_real < line_expected
        desc_issue(line_expected, line_real, "Under 4s", summary['sampler_label']) 
        "<b>#{ "%.2f" % line_real}</b>"
      else 
        line_real
      end
  end

  def s6_report_line(summary) 
     line_real = (summary["6s"] * 100)
     line_expected = @min_response_time_under_6s
     if line_real < line_expected
        desc_issue(line_expected, line_real, "Under 6s", summary['sampler_label']) 
        "<b>#{ "%.2f" % line_real}</b>"
      else 
        line_real
      end
  end

  def s8_report_line(summary) 
     line_real = (summary["8s"] * 100)
     line_expected = @min_response_time_under_8s
     if line_real < line_expected
        desc_issue(line_expected, line_real, "Under 8s", summary['sampler_label']) 
        "<b>#{ "%.2f" % line_real}</b>"
      else 
       line_real
      end
  end
end
