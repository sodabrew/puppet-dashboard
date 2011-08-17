require 'spec_helper'

describe ReportsHelper do
  describe 'popup_md5s' do
    describe 'when SETTINGS.use_file_bucket_diffs is disabled' do
      before :each do
        SETTINGS.stubs(:use_file_bucket_diffs).returns(false)
      end

      it "should not link the original file's checksum to the file-bucket when contents have changed" do
        helper.popup_md5s(
          "content changed '{md5}acbd18db4cc2f85cedef654fccc4a4d8' to '{md5}37b51d194a7513e45b56f6524f2d51f2'"
        ).should == "content changed '{md5}acbd18db4cc2f85cedef654fccc4a4d8' to '{md5}37b51d194a7513e45b56f6524f2d51f2'"
      end

      it "should not link new files checksums to the file-bucket" do
        helper.popup_md5s(
          "defined content as '{md5}37b51d194a7513e45b56f6524f2d51f2'"
        ).should == "defined content as '{md5}37b51d194a7513e45b56f6524f2d51f2'"
      end
    end

    describe 'when SETTINGS.use_file_bucket_diffs is enabled' do
      before :each do
        SETTINGS.stubs(:use_file_bucket_diffs).returns(true)
      end

      it "should link the original file's checksum to the file-bucket when contents have changed" do
        helper.popup_md5s(
          "content changed '{md5}acbd18db4cc2f85cedef654fccc4a4d8' to '{md5}37b51d194a7513e45b56f6524f2d51f2'"
        ).should == "content changed '<a class=\"popup-md5\" href=\"#\" onclick=\"display_file_popup('/files/show?file=acbd18db4cc2f85cedef654fccc4a4d8'); return false;\">{md5}acbd18db4cc2f85cedef654fccc4a4d8</a>' to '{md5}37b51d194a7513e45b56f6524f2d51f2'"
      end

      it "should not link new files checksums to the file-bucket" do
        helper.popup_md5s(
          "defined content as '{md5}37b51d194a7513e45b56f6524f2d51f2'"
        ).should == "defined content as '{md5}37b51d194a7513e45b56f6524f2d51f2'"
      end
    end
  end
end
