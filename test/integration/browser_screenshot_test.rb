require "system_test_case"

class BrowserScreenshotTest < SystemTestCase
  def test_screenshot_without_changes
    visit "/"
    screenshot "index"
  end

  def test_screenshot_with_changes
    visit "/index-changed.html"
    screenshot "index"
    assert_screenshot_error_for("index")
  end

  def test_window_size_should_resize_browser_window_in_setup
    assert_equal [800, 600], window_size
  end

  def test_screenshot_with_hide_caret_enabled
    Capybara::Screenshot.hide_caret = true

    visit "/"
    fill_in "First Field:", with: "Test Input With Hide Caret"
    screenshot "index-hide_caret-enabled"
  ensure
    Capybara::Screenshot.hide_caret = nil
  end

  def test_screenshot_with_hide_caret_disabled
    Capybara::Screenshot.hide_caret = false

    visit "/"
    fill_in "First Field:", with: "Test Input Without Hide Caret"

    # Hide caret is flaky issue, let's give more tries to take stable screenshot
    screenshot "index-hide_caret-disabled", wait: Capybara.default_max_wait_time * 5
  ensure
    Capybara::Screenshot.hide_caret = nil
  end

  def test_screenshot_with_blur_active_element_enabled
    Capybara::Screenshot.blur_active_element = true

    visit "/"
    fill_in "First Field:", with: "Test Input With Hide Caret"
    screenshot "index-blur_active_element-enabled"
  ensure
    Capybara::Screenshot.blur_active_element = nil
  end

  def test_screenshot_with_blur_active_element_disabled
    Capybara::Screenshot.blur_active_element = false

    visit "/"
    fill_in "First Field:", with: "Test Input Without Hide Caret"
    screenshot "index-blur_active_element-disabled"
  ensure
    Capybara::Screenshot.blur_active_element = nil
  end

  def test_screenshot_selected_element
    visit "/"

    screenshot "cropped_screenshot", crop: [0, 100, 100, 200]
  end

  private

  def window_size
    if page.driver.respond_to?(:window_size)
      return page.driver.window_size(page.driver.current_window_handle)
    end

    page.driver.browser.manage.window.size.to_a
  end

  def assert_screenshot_error_for(screenshot_name)
    assert_equal 1, @test_screenshots.length, "expecting to have just one difference"
    assert_equal screenshot_name, @test_screenshots[0][1], "index screenshot should have difference for changed page"
  end

  # TODO: Add test for stability to await while image are loading
  # TODO: Allow to run tests for browser which was selected by ENV: chrome, firefox, cuprite and other
end
