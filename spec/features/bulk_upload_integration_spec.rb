require 'spec_helper'
include LoginHelper
include BulkUploadHelper

feature 'CSV file upload works' do
  before :each do
    login_test_user
  end


  context 'GET /bulk_upload/start_upload' do

    it 'should upload the given file' do

      visit '/bulk_upload/start_upload'
      attach_file 'CSV file', Rails.root.join('spec',
                                              'fixtures',
                                              'files',
                                              'bulk_upload',
                                              'sample_yields.csv')
      click_button 'Upload'
      page.should have_content 'Uploaded file: sample_yields.csv'
    end


    it 'should not give an error when the citation chosen interactively but treatment is not', js: true do
      visit '/bulk_upload/start_upload'
      attach_file 'CSV file', Rails.root.join('spec',
                                              'fixtures',
                                              'files',
                                              'bulk_upload',
                                              'sample_yields_with_treatment_but_no_citation.csv')
      click_button 'Upload'

      choose_citation_from_dropdown('Adams')

      page.should_not have_content 'Select a Citation'
      page.should have_content 'Specify '
      click_link 'Specify'
      click_button 'Confirm'
      page.should have_content 'Verify Upload Specifications and Data-Set References'
      click_button 'Insert Data'
      page.should_not have_selector('.alert-error')

      # do clean-up
      visit '/yields?search=Adams'
      first(:xpath, "//a[@alt = 'delete']").click
      # If we're using Selenium, we have to deal with the modal dialogue:
      if page.driver.is_a? Capybara::Selenium::Driver
        a = page.driver.browser.switch_to.alert
        a.accept
      end
    end

    it 'should successfully validate a file even when headings are not in canonical form' do
      visit '/bulk_upload/start_upload'
      attach_file 'CSV file', Rails.root.join('spec',
                                              'fixtures',
                                              'files',
                                              'bulk_upload',
                                              'data_validation',
                                              'fuzzily_matching_headings.csv')
      click_button 'Upload'
      page.should_not have_selector('.alert-error')
    end

    it 'should successfully insert data from a file even when headings are not in canonical form' do
      visit '/bulk_upload/start_upload'
      attach_file 'CSV file', Rails.root.join('spec',
                                              'fixtures',
                                              'files',
                                              'bulk_upload',
                                              'data_validation',
                                              'fuzzily_matching_headings.csv')
      click_button 'Upload'
      click_link 'Specify'
      click_button 'Confirm'
      click_button 'Insert Data'
      first("div.alert-success").should have_content("Data from fuzzily_matching_headings.csv was successfully uploaded.")
    end


  end
end
