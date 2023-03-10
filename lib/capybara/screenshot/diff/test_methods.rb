# frozen_string_literal: true

require "English"
require "capybara"
require "action_controller"
require "action_dispatch"
require "active_support/core_ext/string/strip"
require "pathname"

require_relative "drivers"
require_relative "image_compare"
require_relative "vcs"
require_relative "browser_helpers"
require_relative "region"

require_relative "screenshot_matcher"

# Add the `screenshot` method to ActionDispatch::IntegrationTest
module Capybara
  module Screenshot
    module Diff
      module TestMethods
        def initialize(*)
          super
          @screenshot_counter = nil
          @screenshot_group = nil
          @screenshot_section = nil
          @test_screenshot_errors = nil
          @test_screenshots = []
        end

        def build_full_name(name)
          if @screenshot_counter
            name = format("%02i_#{name}", @screenshot_counter)
            @screenshot_counter += 1
          end

          File.join(*group_parts.push(name.to_s))
        end

        def screenshot_dir
          File.join(*([Screenshot.screenshot_area] + group_parts))
        end

        def screenshot_section(name)
          @screenshot_section = name.to_s
        end

        def screenshot_group(name)
          @screenshot_group = name.to_s
          @screenshot_counter = @screenshot_group.present? ? 0 : nil
          return unless Screenshot.active? && name.present?

          FileUtils.rm_rf screenshot_dir
        end

        def schedule_match_job(job)
          (@test_screenshots ||= []) << job
          true
        end

        def group_parts
          parts = []
          parts << @screenshot_section if @screenshot_section.present?
          parts << @screenshot_group if @screenshot_group.present?
          parts
        end

        def screenshot(name, skip_stack_frames: 0, **options)
          return false unless Screenshot.active?

          screenshot_full_name = build_full_name(name)
          job = build_screenshot_matches_job(screenshot_full_name, options)

          return false unless job

          test_caller = caller(skip_stack_frames)

          if Screenshot::Diff.delayed
            schedule_match_job([test_caller] + job)
          else
            error_msg = assert_image_not_changed(job.first, job.last)
            if error_msg
              error = ASSERTION.new(error_msg)
              error.set_backtrace(caller(2))
              raise error
            end
          end
        end

        def assert_image_not_changed(name, comparison)
          result = comparison.different?

          # Cleanup after comparisons
          if !result && comparison.base_image_path.exist?
            FileUtils.mv(comparison.base_image_path, comparison.image_path, force: true)
          else
            FileUtils.rm_rf(comparison.base_image_path)
          end

          return unless result

          "Screenshot does not match for '#{name}' #{comparison.error_message}"
        end

        private

        def build_screenshot_matches_job(screenshot_full_name, options)
          ScreenshotMatcher
            .new(screenshot_full_name, options)
            .build_screenshot_matches_job
        end
      end
    end
  end
end
