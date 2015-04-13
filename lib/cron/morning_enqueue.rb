# Test for enqueueing weekly emails jobs on Saturday
if pdt_day == SATURDAY
  base = "script/run_weekly_email_report.rb"
  options = " --enqueue_later --account 3,10"
  recipient = " --to \"kwu+emailtest@newrelic.com\""
  test_email = [base, options, recipient].join("")

  Async::Command::Bulk.new(test_email).enqueue
end

WeeklyEmailReportJob.new(account.id).enqueue_at(local_1am(tz))
