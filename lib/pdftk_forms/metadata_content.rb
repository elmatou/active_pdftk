module PdftkForms
#    These subclasses of Metadata represent all kind of stuffs you can find in a PDF as Metadata
#    They have to respond at least to #new, #is_valid?, and #to_s
  class Metadata

#  NumberOfPages is an Integer, no object is created for it
#  NumberOfPages: 1236

#  PdfId is a String, no object is created for it
#  PdfID0: b1f99718e2a92cc112fbf8b233fb
#  PdfID1: b2f1dbee369e11d9b9510393c97fd8


#  Known keys are : Title, Author, Subject, Keywords, Creator, Producer, CreationDate, ModDate, Trapped
#  InfoKey: Creator
#  InfoValue: FrameMaker 7.0
#  InfoKey: CreationDate
#  InfoValue: D:20041114084116Z
    class Info
      attr_accessor :key, :value

      def initialize(key = nil, value = nil)
        @key, @value = key, value
      end

      def to_s
        raise(NotValid, "Cannot print invalid info object") unless is_valid?
<<STRING
InfoKey: #{@key}
InfoValue: #{@value}
STRING
      end

      def to_h
        {@key => @value}
      end

      def is_valid?
        !(@key.nil? || @key.empty? || @value.nil? || @value.empty?)
      end
    end

#  BookmarkTitle: PDF Reference
#  BookmarkLevel: 1
#  BookmarkPageNumber: 1
    class Bookmark
      attr_accessor :title, :level, :page_number

      def initialize(title = nil, level = nil, page_number = nil)
#            raise (ArgumentError, "level cannot be null or negative") if level <= 0
#            raise (ArgumentError, "page cannot be null or negative") if page_number <= 0
        @title, @level, @page_number = title, level, page_number
      end

      def to_s
        raise(NotValid, "Cannot print invalid info object") unless is_valid?
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
        !(@title.nil? || @title.empty? || @level.nil? || @page_number.nil?)
      end

#      def create_sibling(title, page_number)
#        new(title, @level, page_number)
#      end

#      def create_child(title, page_number)
#        new(title, @level + 1, page_number)
#      end

#      def create_parent(title, page_number)
#        @level <= 1 ? nil : new(title, @level - 1, page_number)
#      end
    end


#  Known Styles are : LowercaseRomanNumerals, DecimalArabicNumerals
#  PageLabelNewIndex: 1
#  PageLabelStart: 1
#  PageLabelNumStyle: LowercaseRomanNumerals
    class PageLabel
      attr_accessor :new_index, :start, :num_style

      def initialize(new_index = nil, start = nil, num_style = nil)
        @new_index, @start, @num_style = new_index, start, num_style
      end

      def to_s
        raise(NotValid, "Cannot print invalid info object") unless is_valid?
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
        !(@new_index.nil? || @start.nil? || @num_style.nil? || @num_style.empty?)
      end
    end
  end
end