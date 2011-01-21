class FilesController < ApplicationController
  def diff
    unless SETTINGS.use_file_bucket_diffs
      render :text => "File bucket diffs have been disabled", :content_type => 'text/plain', :status => 403
      return
    end

    [params[:file1], params[:file2]].each do |md5|
      unless is_md5?(md5)
        render :text => "Invalid md5: #{md5.inspect}", :content_type => 'text/plain', :status => 400
        return
      end
    end
    url = "https://#{SETTINGS.file_bucket_server}:#{SETTINGS.file_bucket_port}/production/file_bucket_file/md5/#{params[:file1]}?diff_with=#{params[:file2]}"
    diff = PuppetHttps.get(url, 's')
    render :text => diff, :content_type => 'text/plain'
  end
end
