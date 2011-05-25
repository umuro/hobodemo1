if (Gem.available? 'ci_reporter') && (Gem.available? 'rcov')
  require 'ci/reporter/rake/test_unit'
  require 'rcov/rcovtask'
   
  namespace :hudson do
    def report_path
      "hudson/reports"
    end
   
    task :all => [:report_setup] do
      Rake::Task['hudson:test'].invoke
      Rake::Task['hudson:coverage'].invoke
    end
   
    task :test => ['ci:setup:testunit'] do
      Rake::Task['test'].invoke
    end
   
    task :coverage
    %w[unit functional integration].each do |target|
      namespace :coverage do
        Rcov::RcovTask.new(target) do |t|
          t.libs << "test"
          t.test_files = FileList["test/#{target}/**/*_test.rb"]
          t.output_dir = "#{report_path}/rcov"
          t.verbose = true
          t.rcov_opts << '--rails --aggregate coverage.data'
        end
      end
      task :coverage => "hudson:coverage:#{target}"
    end
   
    task :report_setup do
      rm_rf 'converage'
      rm_rf 'coverage.data'
      rm_rf report_path
   
      ENV['CI_REPORTS'] = %{#{report_path}/tests}
    end
   
  end
end
