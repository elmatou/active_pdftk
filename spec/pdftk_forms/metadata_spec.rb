require 'spec_helper'
#TODO implement tests with a full pdf file.
#Add pages, Bookmarks, page_labels

describe PdftkForms::Metadata do
    before(:all) do
      @pdftk = PdftkForms::Wrapper.new
    end
  context "new" do
    before(:all) do
      @temp_file = @pdftk.dump_data(path_to_pdf('fields.pdf'))
      @data_info = PdftkForms::Metadata.new(@temp_file)
    end

    it "should create a PdftkForms::Metadata object" do
      @data_info.should be_kind_of(PdftkForms::Metadata)
    end

    it "should retrieve Infos" do
      @data_info.infos.each do |info|
        info.should be_kind_of(PdftkForms::Metadata::Info)
        info.is_valid?.should be_true
      end
      @data_info.infos.count.should == 5
    end

    it "should retrieve the number of pages" do
      @data_info.pages.should == 1
    end

    it "should retrieve ids" do
      @data_info.pdf_ids.should == ["6cac1734f454cee9944c0531b475f11", "f3adcb7a648b4a1eb3a96021add55cc2"]
    end

    it "should retrieve bookmarks" do
      @data_info.bookmarks.each do |bookmark|
        bookmark.should be_kind_of(PdftkForms::Metadata::Bookmark)
        bookmark.is_valid?.should be_true
      end
      @data_info.bookmarks.count.should == 0
    end

    it "should retrieve page labels" do
      @data_info.page_labels.each do |page_label|
        page_label.should be_kind_of(PdftkForms::Metadata::PageLabel)
        page_label.is_valid?.should be_true
      end
      @data_info.page_labels.count.should == 0
    end
  end
  context "edit" do
    before do
      @string_io = @pdftk.dump_data(path_to_pdf('fields.pdf'))
      @data_info = PdftkForms::Metadata.new(@string_io)
    end

    it "should prepare a formatted string." do
      @data_info.to_s.should == @string_io.string
    end

    it "should update things" do
      @data_info.infos.first.value = "Updated value"
#      @data_info.bookmarks.first.title = "Updated Title"

      @updated_info = PdftkForms::Metadata.new(@data_info.to_s)
      
      @updated_info.infos.first.value.should == "Updated value"
#      @updated_info.bookmarks.first.title.should = "Updated Title"
    end

    it "should add some things" do
      @data_info.add_info("Modifier", "ActivePdfTK")
      @data_info.add_bookmark("First Page !", 1, 1)
      @data_info.add_page_label(1, 1, "LowercaseRomanNumerals")
#      puts @data_info.to_s
    end

  end
end