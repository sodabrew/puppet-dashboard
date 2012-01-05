module ReportsHelper
  def popup_md5s( string, options = {} )
    if SETTINGS.use_file_bucket_diffs
      # file_md5sums will contain an array of md5sums if the string being
      # scanned is a filebucket message.
      file_md5sums = string.scan(/\{md5\}[a-fA-F0-9]{32}/)

      # if we are working with a filebucket message, hyperlink the word "changed"
      # to the diff between both files, and any md5s to the corresponding files
      # in the filebucket.
      if file_md5sums.length == 2
        original_file_md5sum, new_file_md5sum = file_md5sums[0], file_md5sums[1]
        string.gsub(/changed/, link_to_function( "\\&", "display_file_popup('#{url_for :controller => :files, :action => :diff, :file1 => original_file_md5sum.sub('{md5}',''), :file2 => new_file_md5sum.sub('{md5}','')}')", :class => 'popup-md5')).gsub(/\{md5\}[a-fA-F0-9]{32}/) do |match|
          if options[:exclude_md5s] and options[:exclude_md5s].include? match
            match
          else
            link_to_function options[:label] || match, "display_file_popup('#{url_for :controller => :files, :action => :show, :file => match.sub('{md5}','')}')", :class => 'popup-md5'
          end
        end
      else
        string
      end
    else
      string
    end
  end
end
