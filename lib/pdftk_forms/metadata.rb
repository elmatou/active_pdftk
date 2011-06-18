module PdftkForms
#  Represents Data infos on a particular PDF
  class Metadata

    class NotValid < StandardError
    end

    class << self
      def build(template, options = {})
        @wrapper = Wrapper.new(options)
        new(@wrapper.dump_data(template), @wrapper)
      end
    end

#    For now only infos are editable, others metadata are 'readonly' :-(
    attr_accessor :infos
    attr_reader :pdf_ids, :pages, :bookmarks, :page_labels

#    See metadata_content.rb to see types of data handled by this class
    def initialize(string, wrapper = nil)
      # set a intern wrapper instance if externaly provided
      @wrapper = wrapper

      # assert the input is a rewinded StringIO
      string = StringIO.new(string) if string.is_a? String
      string.rewind

      @infos, @bookmarks, @page_labels, @pdf_ids = [], [], [], []
      info = Info.new
      bookmark = Bookmark.new
      page_label = PageLabel.new
      

      string.each do |line|
        line.scan(/^(\w+): (.*)$/) do |key, value|
          case key
            when /^PdfID/ then
              @pdf_ids.push value

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

    def save
      @wrapper.update_info(@template, StringIO.new(to_s)) if @wrapper
    end

#    Please provide a camelized string like "DataInfo" for +key+ (and not "data_info")
#    Or we could use the Rails helper (but I don't want to rewrite it...)

    def info_get(key)
      @infos.detect {|f| f.key == key.to_s}
    end
    
    def info_set(key, value)
      f = info_get(key)
      if f.nil?
        @infos << Info.new(key, value)
      else
        f.value = value
      end
    end

    def info_delete(key)
      @infos.delete_if {|x| x.key == key.to_s}
    end



#    def add_bookmark(title, level, page, before = nil)
#      @bookmarks << Bookmark.new(title, level, page)
#    end
#
#    def rm_bookmark(title = nil, level = nil, page = nil)
#      # lookup the bookmark by one or more of his attributes and remove it.
#    end

#  #TODO  check in PDF reference if a page can have more than one page label ?
#    def add_page_label(new_index, start, num_style)
#      @page_labels << PageLabel.new(new_index, start, num_style)
#    end
#
#    def rm_page_label(from, to = nil)
# #TODO     lookup the page label by a given page and remove it.
#    end
  end
end
