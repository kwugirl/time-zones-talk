module SchedulingHelper
  # attempt #1
  def local_1am(account_time_zone)
    dt = DateTime.parse("Monday, 1:01")
    local_time_zone = account_time_zone || ActiveSupport::TimeZone['Pacific Time (US & Canada)']

    local_time_zone.local_to_utc(dt)
  end

  # attempt #2
  def local_1am(account_time_zone)
    last_day_globally = ActiveSupport::TimeZone['International Date Line West'].today
    days_until_monday = (8 - last_day_globally.wday) % 7
    next_monday = last_day_globally + days_until_monday

    local_timezone = account_time_zone || ActiveSupport::TimeZone['Pacific Time (US & Canada)']
    current_tz_offset = local_timezone.now.formatted_offset

    DateTime.parse("#{next_monday} 01:01:00 AM #{current_tz_offset}")
  end
end
