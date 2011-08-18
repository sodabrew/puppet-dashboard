require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ReportsHelper do
  describe "#popup_md5s" do
    before do
      SETTINGS.stubs(:use_file_bucket_diffs).returns(true)
      @text = "content changed '{md5}b84b7c77fb71f0d945f186513a09e185' to '{md5}d28d2d3560fa76f0dbb1a452f8c38169'"
    end

    it "should make anything that looks like an md5 into a filebucket link" do
      helper.popup_md5s(@text).gsub(/\s/, '').should == <<-HEREDOC.gsub(/\s/, '')
        content changed '<a
          class=\"popup-md5\"
          href=\"#\"
          onclick=\"display_file_popup( '/files/show?file=b84b7c77fb71f0d945f186513a09e185'); return false;\">
          {md5}b84b7c77fb71f0d945f186513a09e185
        </a>' to '<a
          class=\"popup-md5\"
          href=\"#\"
          onclick=\"display_file_popup('/files/show?file=d28d2d3560fa76f0dbb1a452f8c38169'); return false;\">
          {md5}d28d2d3560fa76f0dbb1a452f8c38169
        </a>'
      HEREDOC
    end

    it "should make the link text be a label if it's passed in" do
      helper.popup_md5s(@text, :label => 'foo').gsub(/\s/, '').should == <<-HEREDOC.gsub(/\s/, '')
        content changed '<a
          class=\"popup-md5\"
          href=\"#\"
          onclick=\"display_file_popup( '/files/show?file=b84b7c77fb71f0d945f186513a09e185'); return false;\">
          foo
        </a>' to '<a
          class=\"popup-md5\"
          href=\"#\"
          onclick=\"display_file_popup('/files/show?file=d28d2d3560fa76f0dbb1a452f8c38169'); return false;\">
          foo
        </a>'
      HEREDOC
    end

    it "should not link md5s if they're in the excluded list" do
      helper.popup_md5s(@text, :exclude_md5s => ['{md5}d28d2d3560fa76f0dbb1a452f8c38169']).gsub(/\s/, '').should == <<-HEREDOC.gsub(/\s/, '')
        content changed '<a
          class=\"popup-md5\"
          href=\"#\"
          onclick=\"display_file_popup( '/files/show?file=b84b7c77fb71f0d945f186513a09e185'); return false;\">
          {md5}b84b7c77fb71f0d945f186513a09e185
        </a>' to '{md5}d28d2d3560fa76f0dbb1a452f8c38169'
      HEREDOC
    end
  end
end
