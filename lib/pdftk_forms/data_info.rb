module PdftkForms
  # Represents Data infos on a particular PDF
  class DataInfo
    attr_reader :infos, :bookmarks, :page_labels, :pdf_ids, :pages
    
#  InfoKey: Creator
#  InfoValue: FrameMaker 7.0
#  InfoKey: Title
#  InfoValue: PDF Reference, version 1.6
#  InfoKey: Producer
#  InfoValue: Acrobat Distiller 6.0.1 for Macintosh
#  InfoKey: Author
#  InfoValue: Adobe Systems Incorporated
#  InfoKey: Subject
#  InfoValue: Adobe Portable Document Format (PDF)
#  InfoKey: ModDate
#  InfoValue: D:20041114163850-08'00'
#  InfoKey: CreationDate
#  InfoValue: D:20041114084116Z
#  PdfID0: b1f99718e2a92cc112fbf8b233fb
#  PdfID1: b2f1dbee369e11d9b9510393c97fd8
#  NumberOfPages: 1236
#  BookmarkTitle: PDF Reference
#  BookmarkLevel: 1
#  BookmarkPageNumber: 1
#  BookmarkTitle: Contents
#  BookmarkLevel: 2
#  BookmarkPageNumber: 3
#  BookmarkTitle: Figures
#  BookmarkLevel: 2
#  BookmarkPageNumber: 7
#  BookmarkTitle: Tables
#  BookmarkLevel: 2
#  BookmarkPageNumber: 11
#  .....
#  PageLabelNewIndex: 1
#  PageLabelStart: 1
#  PageLabelNumStyle: LowercaseRomanNumerals
#  PageLabelNewIndex: 23
#  PageLabelStart: 1
#  PageLabelNumStyle: DecimalArabicNumerals

    def self.import(template, wrapper_statements = {})
      @pdftk = Wrapper.new(wrapper_statements)
      @template = template
      new(@pdftk.dump_data(template))
    end

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
            when /^Info/ then
              info.key = value if key =~ /Key$/
              info.value = value if key =~ /Value$/
              if info.is_valid?
                @infos << info
                info = Info.new
              end
            when /^PdfID/ then
              @pdf_ids.push value
            when /^NumberOfPages/ then
              @pages = value.to_i
            when /^Bookmark/ then
              bookmark.title = value if key =~ /Title$/
              bookmark.level = value if key =~ /Level$/
              bookmark.page_number = value if key =~ /PageNumber$/
              if bookmark.is_valid?
                @bookmarks << bookmark
                bookmark = Bookmark.new
              end
#              bookmark.store key.scan(/^Bookmark([^\b]+)\b/).to_s, value
            when /^PageLabel/ then
              page_label.new_index = value if key =~ /NewIndex$/
              page_label.start = value if key =~ /Start$/
              page_label.num_style = value if key =~ /NumStyle$/
              if page_label.is_valid?
                @page_labels << page_label
                page_label = PageLabel.new
              end
#              page_label.store key.scan(/^PageLabel([^\b]+)\b/).to_s, value
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

    # Please provide a camelized string like "DataInfo" for +key+ (and not "data_info")
    #
    def add_info(key, value)
      @infos << Info.new(key, value)
    end

    def rm_info(key)
#      @infos.delete(key.to_s)
    end

    def add_bookmark(title, level, page, before = nil)
      @infos << Bookmark.new(title, level, page)
    end

    def rm_bookmark(title, level, page)

    end

    def add_page_label(new_index, start, num_style)
      @page_labels << PageLabel.new(new_index, start, num_style)
    end

    def rm_page_label(new_index, start, num_style)

    end

    class Info
      attr_accessor :key, :value

      def initialize(key = nil, value = nil)
        @key = key
        @value = value
      end

      def to_s
<<STRING
InfoKey: #{@key}
InfoValue: #{@value}
STRING
      end

      def to_h
        {@key => @value}
      end

      def is_valid?
        !(@key.nil? || @value.nil?)
      end

    end

    class Bookmark
      attr_accessor :title, :level, :page_number

      def initialize(title = nil, level = nil, page_number = nil)
#        raise (ArgumentError, "level cannot be null or negative") if level <= 0
#        raise (ArgumentError, "page cannot be null or negative") if page_number <= 0
        @title = title
        @level = level
        @page_number = page_number
      end

      def to_s
<<STRING
BookmarkTitle: #{@title}
BookmarkLevel: #{@level}
BookmarkPageNumber: #{@page_number}
STRING
      end

      def to_h
        {:title => @title, :level => @level, :page_number => @page_number}
      end

      def is_valid?
        !(@title.nil? || @level.nil? || @page_number.nil?)
      end

      def create_sibling(title, page_number)
        new(title, @level, page_number)
      end

      def create_child(title, page_number)
        new(title, @level + 1, page_number)
      end

      def create_parent(title, page_number)
        @level == 0 ? nil : new(title, @level - 1, page_number)
      end
    end
    
    class PageLabel
      attr_accessor :new_index, :start, :num_style

      def initialize(new_index = nil, start = nil, num_style = nil)
        @new_index = new_index
        @start = start
        @num_style = num_style
      end

      def to_s
<<STRING
PageLabelNewIndex: #{@new_index}
PageLabelStart: #{@start}
PageLabelNumStyle: #{@num_style}
STRING
      end

      def to_h
        {:new_index => @new_index, :start => @start, :num_style => @num_style}
      end
      
      def is_valid?
        !(@new_index.nil? || @start.nil? || @num_style.nil?)
      end
    end
  end
end
