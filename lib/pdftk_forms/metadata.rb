module PdftkForms
#  Represents Data infos on a particular PDF
  class Metadata

    class NotValid < StandardError
    end

    attr_reader :infos, :bookmarks, :page_labels, :pdf_ids, :pages

#    See metadata_content.rb to see types of data handled by this class

    def initialize(string)
      @infos, @bookmarks, @page_labels, @pdf_ids = [], [], [], []
      info = Info.new
      bookmark = Bookmark.new
      page_label = PageLabel.new
      
      string = StringIO.new(string) if string.is_a? String
      string.rewind
      raw_string = string.each do |line|
        line.scan(/^(\w+): (.*)$/) do |key, value|
          case key
            when /^PdfID/ then
              @pdf_ids.push value.to_i

            when /^NumberOfPages/ then
              @pages = value.to_i

            when /^Info/ then
              info.key = value if key =~ /Key$/
              info.value = value if key =~ /Value$/
              if info.is_valid?
                @infos << info
                info = Info.new
              end

            when /^Bookmark/ then
              bookmark.title = value if key =~ /Title$/
              bookmark.level = value if key =~ /Level$/
              bookmark.page_number = value if key =~ /PageNumber$/
              if bookmark.is_valid?
                @bookmarks << bookmark
                bookmark = Bookmark.new
              end

            when /^PageLabel/ then
              page_label.new_index = value if key =~ /NewIndex$/
              page_label.start = value if key =~ /Start$/
              page_label.num_style = value if key =~ /NumStyle$/
              if page_label.is_valid?
                @page_labels << page_label
                page_label = PageLabel.new
              end
          end
        end
      end
    end

    def to_s
      @infos.collect { |i| i.to_s }.join('') +
      @pdf_ids.to_enum(:each_with_index).collect {|item, index| "PdfID#{index}: #{item}\n" }.join('') +
      "NumberOfPages: #{@pages}\n" +
      @bookmarks.collect { |i| i.to_s }.join('') +
      @page_labels.collect { |i| i.to_s }.join('')
    end

#    def save(validation = false)
#      @pdftk.update_info(@template, StringIO.new(to_s)) if @pdftk
#    end

#    Please provide a camelized string like "DataInfo" for +key+ (and not "data_info")
#    Or we could use the Rails helper (but I don't want to rewrite it...)
    def add_info(key, value)
      @infos << Info.new(key, value)
    end

    def rm_info(key)
      @infos.delete_if {|x| x.key key.to_s}
    end

    def add_bookmark(title, level, page, before = nil)
      @bookmarks << Bookmark.new(title, level, page)
    end

    def rm_bookmark(title = nil, level = nil, page = nil)
      # lookup the bookmark by one or more of his attributes and remove it.
    end

    # check in PDF reference if a page can have more than one page label ?
    def add_page_label(new_index, start, num_style)
      @page_labels << PageLabel.new(new_index, start, num_style)
    end

    def rm_page_label(from, to = nil)
      # lookup the page label by a given page and remove it.
    end
  end
end
