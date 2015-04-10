require 'test_helper'

class SchedulingHelperTest < ActionView::TestCase

  # attempt #1
  context "enqueue time" do
    setup do
      saturday_pt = DateTime.parse("1th May 2015 10:05:00 AM -07:00")
      Timecop.freeze(saturday_pt)
    end

    should "be the next Monday 1:01am local time of its primary admin (west of UTC)" do
      local_time_zone = ActiveSupport::TimeZone["Mountain Time (US & Canada)"]
      expected_timestamp = DateTime.parse("6th Apr 2015 01:01:00 AM -06:00")

      assert_equal expected_timestamp, local_1am(local_time_zone)
    end

    should "be the next Monday 1:01am local time of its primary admin (east of UTC)" do
      local_time_zone = ActiveSupport::TimeZone["Bangkok"]
      expected_timestamp = DateTime.parse("6th Apr 2015 01:01:00 AM +07:00")

      assert_equal expected_timestamp, local_1am(local_time_zone)
    end
  end

  # attempt #2
  context "enqueue time" do
    context "during U.S. daylight savings" do
      setup do
        saturday_pt = DateTime.parse("7th Jun 2014 10:05:00 AM -07:00")
        Timecop.freeze(saturday_pt)
      end

      should "be the next Monday 1:01am local time of its primary admin (west of UTC)" do
        local_time_zone = ActiveSupport::TimeZone["Mountain Time (US & Canada)"]

        expected_timestamp = DateTime.parse("9th Jun 2014 01:01:00 AM -06:00")
        assert_equal "Monday", Date::DAYNAMES[expected_timestamp.wday]

        assert_equal expected_timestamp, local_1am(local_time_zone)
      end

      should "be the next Monday 1:01am local time of its primary admin (east of UTC)" do
        local_time_zone = ActiveSupport::TimeZone["Bangkok"]

        expected_timestamp = DateTime.parse("9th Jun 2014 01:01:00 AM +07:00")
        assert_equal "Monday", Date::DAYNAMES[expected_timestamp.wday]

        assert_equal expected_timestamp, local_1am(local_time_zone)
      end
    end

    context "during U.S. standard time" do
      setup do
        saturday_pt = DateTime.parse("8th Feb 2014 10:05:00 AM -08:00")
        Timecop.freeze(saturday_pt)
      end

      should "be the next Monday 1:01am local time of its primary admin" do
        local_time_zone = ActiveSupport::TimeZone["Mountain Time (US & Canada)"]

        expected_timestamp = DateTime.parse("10th Feb 2014 01:01:00 AM -07:00")
        assert_equal "Monday", Date::DAYNAMES[expected_timestamp.wday]

        assert_equal expected_timestamp, local_1am(local_time_zone)
      end
    end

    context "when run on different days of the week" do
      setup do
        @hawaii_tz = ActiveSupport::TimeZone["Hawaii"]
        @wellington_tz = ActiveSupport::TimeZone["Wellington"]
      end

      should "be the next day when run on late Sunday night" do
        sunday_night = DateTime.parse("1st Jun 2014 11:30:00 PM #{@hawaii_tz.formatted_offset}")
        Timecop.freeze(sunday_night)
        assert_equal "Sunday", Date::DAYNAMES[@hawaii_tz.now.wday]

        # It's already Monday in the customer account's time zone before the report runs
        assert_equal "Monday", Date::DAYNAMES[@wellington_tz.now.wday]

        local_time_zone = ActiveSupport::TimeZone[@wellington_tz.name]

        expected_timestamp = DateTime.parse("2nd Jun 2014 01:01:00 AM +12:00")
        assert_equal "Monday", Date::DAYNAMES[expected_timestamp.wday]

        assert_equal expected_timestamp, local_1am(local_time_zone)
      end

      should "be a week later when run on Monday" do
        monday = DateTime.parse("2nd Jun 2014 11:30:00 PM #{@hawaii_tz.formatted_offset}")
        Timecop.freeze(monday)
        assert_equal "Monday", Date::DAYNAMES[@hawaii_tz.now.wday]

        local_time_zone = ActiveSupport::TimeZone[@wellington_tz.name]

        expected_timestamp = DateTime.parse("9th Jun 2014 01:01:00 AM +12:00")
        assert_equal "Monday", Date::DAYNAMES[expected_timestamp.wday]

        assert_equal expected_timestamp, local_1am(local_time_zone)
      end
    end
  end
end
