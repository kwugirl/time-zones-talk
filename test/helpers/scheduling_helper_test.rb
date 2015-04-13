require 'test_helper'

class SchedulingHelperTest < ActionView::TestCase

  # attempt #1
  # context "enqueue time" do
  #   setup do
  #     saturday_pt = DateTime.parse("1th May 2015 10:05:00 AM -07:00")
  #     Timecop.freeze(saturday_pt)
  #   end

  #   should "be the next Monday 1:01am local time of its primary admin (west of UTC)" do
  #     binding.pry
  #     local_tz = ActiveSupport::TimeZone["Mountain Time (US & Canada)"]
  #     expected = DateTime.parse("6th Apr 2015 01:01:00 AM -06:00")

  #     assert_equal expected, local_1am(local_tz)
  #   end

  #   should "be the next Monday 1:01am local time of its primary admin (east of UTC)" do
  #     local_tz = ActiveSupport::TimeZone["Bangkok"]
  #     expected = DateTime.parse("6th Apr 2015 01:01:00 AM +07:00")

  #     assert_equal expected, local_1am(local_tz)
  #   end
  # end

  # attempt #2
  context "enqueue time" do
    context "during U.S. standard time" do
      setup do
        saturday_pt = DateTime.parse("8th Feb 2014 10:05:00 AM -08:00")
        Timecop.freeze(saturday_pt)
      end

      should "be the next Monday 1:01am local time (west of UTC)" do
        local_tz = ActiveSupport::TimeZone["Mountain Time (US & Canada)"]

        expected = DateTime.parse("10th Feb 2014 01:01:00 AM -07:00")
        assert_equal "Monday", Date::DAYNAMES[expected.wday]

        assert_equal expected, local_1am(local_tz)
      end

      should "be the next Monday 1:01am local time (east of UTC)" do
        local_tz = ActiveSupport::TimeZone["Bangkok"]

        expected = DateTime.parse("10th Feb 2014 01:01:00 AM +07:00")
        assert_equal "Monday", Date::DAYNAMES[expected.wday]

        assert_equal expected, local_1am(local_tz)
      end
    end

    context "during U.S. daylight savings" do
      setup do
        saturday_pt = DateTime.parse("7th Jun 2014 10:05:00 AM -07:00")
        Timecop.freeze(saturday_pt)
      end

      should "be the next Monday 1:01am local time (west of UTC)" do
        local_tz = ActiveSupport::TimeZone["Mountain Time (US & Canada)"]

        expected = DateTime.parse("9th Jun 2014 01:01:00 AM -06:00")
        assert_equal "Monday", Date::DAYNAMES[expected.wday]

        assert_equal expected, local_1am(local_tz)
      end

      should "be the next Monday 1:01am local time (east of UTC)" do
        local_tz = ActiveSupport::TimeZone["Bangkok"]

        expected = DateTime.parse("9th Jun 2014 01:01:00 AM +07:00")
        assert_equal "Monday", Date::DAYNAMES[expected.wday]

        assert_equal expected, local_1am(local_tz)
      end
    end

    context "when run on different days of the week" do
      setup do
        @samoa_tz = ActiveSupport::TimeZone["American Samoa"]
        @wellington_tz = ActiveSupport::TimeZone["Wellington"]
      end

      should "be the next day when run on late Sunday night" do
        sunday_night = DateTime.parse("1st Jun 2014 11:30:00 PM #{@samoa_tz.formatted_offset}")
        Timecop.freeze(sunday_night)
        assert_equal "Sunday", Date::DAYNAMES[@samoa_tz.now.wday]

        # It's already Monday in the customer account's time zone before the report runs
        assert_equal "Monday", Date::DAYNAMES[@wellington_tz.now.wday]

        local_tz = ActiveSupport::TimeZone[@wellington_tz.name]

        expected = DateTime.parse("2nd Jun 2014 01:01:00 AM +12:00")
        assert_equal "Monday", Date::DAYNAMES[expected.wday]

        assert_equal expected, local_1am(local_tz)
      end

      should "be the same week when still Monday somewhere" do
        monday = DateTime.parse("2nd Jun 2014 11:30:00 PM #{@samoa_tz.formatted_offset}")
        Timecop.freeze(monday)
        assert_equal "Monday", Date::DAYNAMES[@samoa_tz.now.wday]

        local_tz = ActiveSupport::TimeZone[@wellington_tz.name]

        expected = DateTime.parse("2nd Jun 2014 01:01:00 AM +12:00")
        assert_equal "Monday", Date::DAYNAMES[expected.wday]

        assert_equal expected, local_1am(local_tz)
      end

      should "be the next week when run on Tuesday" do
        tuesday = DateTime.parse("3rd Jun 2014 00:30:00 AM #{@samoa_tz.formatted_offset}")
        Timecop.freeze(tuesday)
        assert_equal "Tuesday", Date::DAYNAMES[@samoa_tz.now.wday]

        local_tz = ActiveSupport::TimeZone[@wellington_tz.name]

        expected = DateTime.parse("9th Jun 2014 01:01:00 AM +12:00")
        assert_equal "Monday", Date::DAYNAMES[expected.wday]

        assert_equal expected, local_1am(local_tz)
      end
    end
  end
end
