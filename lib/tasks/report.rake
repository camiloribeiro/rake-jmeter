REPORTS = %w[
  ThreadsStateOverTime
  ResponseTimesOverTime
  LatenciesOverTime
  ResponseCodesPerSecond
  ResponseTimesDistribution
  ResponseTimesPercentiles
  ThroughputVsThreads
  ThroughputOverTime
]

desc 'Generates a report from a JTL file'
task :report, :jtl do |t, args|
  jtl = File.expand_path(args.jtl)
  raise "#{jtl} does not exist" unless File.exists?(jtl)

  out_dir = File.expand_path(File.join('reports', File.basename(jtl, '.jtl')))
  FileUtils.mkdir_p out_dir

  Rake::Task['report:percentiles'].invoke jtl, out_dir
  Rake::Task['report:percentiles:below_threshold'].invoke File.join(out_dir, 'ResponseTimesPercentiles.csv')
  Rake::Task['report:averages'].invoke jtl, out_dir
  Rake::Task['report:summary'].invoke out_dir
  Rake::Task['report:pngs'].invoke jtl, out_dir
end

namespace :report do

  task :pngs, :jtl, :out_dir do |t, args|
    REPORTS.each do |report|
      puts "Printing report: #{report}"
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

    data = FasterCSV.read(file, :headers => true, :converters => [:numeric]).map &:to_hash

    open(File.expand_path(File.join(File.dirname(file), 'PercentileBelowThreshold.csv')), 'w') do |f|
      f.puts 'Transaction,2s,4s,6s,8s'
      totals = [0, 0, 0, 0]
      cols = data.first.keys.size - 1
      (data.first.keys - ['Percentiles']).each do |col|
        totals[0] += (s2 = data.select {|row| row[col] < 2000.0 if row }.last['Percentiles'] / 100 rescue 0) / cols
        totals[1] += (s4 = data.select {|row| row[col] < 4000.0 if row }.last['Percentiles'] / 100 rescue 0) / cols
        totals[2] += (s6 = data.select {|row| row[col] < 6000.0 if row }.last['Percentiles'] / 100 rescue 0) / cols
        totals[3] += (s8 = data.select {|row| row[col] < 8000.0 if row }.last['Percentiles'] / 100 rescue 0) / cols
        f.puts [col, s2, s4, s6, s8].join(',')
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

    percentiles_below_threshold = FasterCSV.read(File.join(out_dir, 'PercentileBelowThreshold.csv'), :headers => true, :converters => [:numeric]).map &:to_hash
    aggregate = FasterCSV.read(File.join(out_dir, 'AggregateReport.csv'), :headers => true, :converters => [:numeric]).map &:to_hash

    tstamp = Time.parse(DateTime.parse(File.basename(out_dir).split(/_/)[-2,2].join).to_s)

    md = <<-MKD
# #{PROJECT_NAME} – #{File.basename(out_dir).split(/_/)[0, 2].join(' ')}

## About the app

Lorem ipsum dolor sit amet. Link to NewRelic, Cacti or whatever. Put some of your favourite kitten pictures.

## About the test

* Ran on #{tstamp.strftime '%d/%m/%y, at %H:%M'}
* JMeter log file: `#{File.basename out_dir}.jtl`

## Summary

Page|Requests|Average|Median|Minimum|90%|Maximum|Throughput|% error|% < 2s|% < 4s|% < 6s|% < 8s
----|--------|-------|------|-------|---|-------|----------|-------|------|------|------|------
MKD
    aggregate.each do |agg|
      summary = agg.merge(percentiles_below_threshold.find {|pbt| pbt['Transaction'] == agg['sampler_label']} || {})
      md << [
        summary['sampler_label'],
        sprintf('%d',   summary['aggregate_report_count']),
        sprintf('%d',   summary['average']),
        sprintf('%d',   summary['aggregate_report_median']),
        sprintf('%d',   summary['aggregate_report_min']),
        sprintf('%d',   summary['aggregate_report_90%_line']),
        sprintf('%d',   summary['aggregate_report_max']),
        sprintf('%.3f', summary['aggregate_report_rate']),
        sprintf('%.3f', summary['aggregate_report_error%']),
        sprintf('%.1f', summary['2s'].to_f * 100),
        sprintf('%.1f', summary['4s'].to_f * 100),
        sprintf('%.1f', summary['6s'].to_f * 100),
        sprintf('%.1f', summary['8s'].to_f * 100),
      ].map {|s|  s}.join('|')
      md << "\n"
    end

    md << <<-MKD

## Threads State Over Time

![Threads State Over Time](ThreadsStateOverTime.png)

## Response Times Over Time

![Response Times Over Time](ResponseTimesOverTime.png)

## Latencies Over Time

![Latencies Over Time](LatenciesOverTime.png)

# Response Codes Per Second

![Response Codes Per Second](ResponseCodesPerSecond.png)

# Response Times Distribution

![Response Times Distribution](ResponseTimesDistribution.png)

# Response Times Percentiles

![Response Times Percentiles](ResponseTimesPercentiles.png)

MKD

    open(File.join(out_dir, 'Summary.html'), 'w') do |f|
      f.write '<!DOCTYPE html><html><head><meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>'
      f.write '<link rel="stylesheet" href="http://twitter.github.com/bootstrap/assets/css/bootstrap.css"/>'
      f.write '<style>h1,h2,h3,h4 { margin-bottom: .5em; margin-top: .5em; }</style><title>Performance Test Summary</title></head><body>'
      f.write '<div class="container">'
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
      java -Xmx1024m -XX:MaxPermSize=256m -Dfile.encoding=UTF-8 -Djava.awt.headless=true -jar ./jmeter/2.7/lib/ext/CMDRunner.jar \
        --tool Reporter \
        --generate-#{report_type} #{File.expand_path File.join(out_dir, report)}.#{report_type} \
        --input-jtl #{File.expand_path jtl} \
        --plugin-type #{report} \
        --aggregate-rows #{!aggregate || %w[ResponseCodesPerSecond ThroughputOverTime ThroughputVsThreads].include?(report) ? 'no' : 'yes'} \
        #{"--paint-gradient no" if report_type == :png} \
        #{"--width #{width}" if width} \
        #{"--height #{height}" if height}
    CMD
  end
end
