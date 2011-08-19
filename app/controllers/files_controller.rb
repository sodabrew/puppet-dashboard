class FilesController < ApplicationController
  before_filter :deny_unless_file_bucket_enabled

  def diff
    [params[:file1], params[:file2]].each do |md5|
      unless is_md5?(md5)
        render :text => "Invalid md5: #{md5.inspect}", :content_type => 'text/plain', :status => 400
        return
      end
    end

    url = "https://#{SETTINGS.file_bucket_server}:#{SETTINGS.file_bucket_port}/production/file_bucket_file/md5/#{params[:file1]}?diff_with=#{params[:file2]}"
    safe_get(url)
  end

  def show
    unless is_md5?(params[:file])
      render :text => "Invalid md5: #{params[:file].inspect}", :content_type => 'text/plain', :status => 400
      return
    end

    url = "https://#{SETTINGS.file_bucket_server}:#{SETTINGS.file_bucket_port}/production/file_bucket_file/md5/#{params[:file]}"
    safe_get(url)
  end

  private
  def deny_unless_file_bucket_enabled
    unless SETTINGS.use_file_bucket_diffs
      render :text => "File bucket diffs have been disabled", :content_type => 'text/plain', :status => 403
      return
    end
  end

  def safe_get(url)
    render :text => PuppetHttps.get(url, 's'), :content_type => 'text/plain'
  rescue Net::HTTPServerException => e
    if e.response.code == "403"
      text = "<p>Connection not authorized: #{e}</p>
        <p>You may not have generated your certificates.
        <a target=\"_blank\" href=\"http://links.puppetlabs.com/dashboard_generating_certs\">View documentation</a></p>"
    else
      text = "<p>File contents not available: #{e}</p>
        <p>Your agents may not be submitting files to a central filebucket.
        <a target=\"_blank\" href=\"http://links.puppetlabs.com/enabling_the_filebucket_viewer\">View documentation</a></p>"
    end
    render :text => text,
      :content_type => 'text/html',
      :status => e.response.code
  rescue Errno::ECONNREFUSED => e
    render :text =>
      "<p>Could not connect to your filebucket server at #{SETTINGS.file_bucket_server}:#{SETTINGS.file_bucket_port}</p>
       <p>#{e}</p>",
      :content_type => 'text/html',
      :status => 500
  rescue => e
    render :text => "#{e}", :content_type => 'text/plain', :status => 500
  end
end
