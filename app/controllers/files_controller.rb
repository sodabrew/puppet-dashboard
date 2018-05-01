class FilesController < ApplicationController
  before_action :deny_unless_file_bucket_enabled

  def diff
    file1 = params[:file1]
    file2 = params[:file2]

    [file1, file2].each do |md5|
      unless is_md5?(md5)
        render plain: "Invalid md5: #{md5.inspect}", status: 400
        return
      end
    end

    url = "https://#{SETTINGS.file_bucket_server}:#{SETTINGS.file_bucket_port}/production/file_bucket_file/md5/#{file1}?diff_with=#{file2}"
    safe_get(url)
  end

  def show
    file = params[:file]
    unless is_md5?(file)
      render plain: "Invalid md5: #{file.inspect}", status: 400
      return
    end

    url = "https://#{SETTINGS.file_bucket_server}:#{SETTINGS.file_bucket_port}/production/file_bucket_file/md5/#{file}"
    safe_get(url)
  end

  private
  def deny_unless_file_bucket_enabled
    unless SETTINGS.use_file_bucket_diffs
      render plain: 'File bucket diffs have been disabled', status: 403
      return
    end
  end

  def safe_get(url)
    render plain: PuppetHttps.get(url, 's')
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
    render html: ActionController::Base.helpers.sanitize(text), status: e.response.code
  rescue Errno::ECONNREFUSED => e
    text = "<p>Could not connect to your filebucket server at #{SETTINGS.file_bucket_server}:#{SETTINGS.file_bucket_port}</p>
       <p>#{e}</p>"
    render html: ActionController::Base.helpers.sanitize(text), status: 500
  rescue => e
    render plain: "#{e}", status: 500
  end

  def file_params
    params.require[:files].permit(:file, :file1, :file2)
  end
end
