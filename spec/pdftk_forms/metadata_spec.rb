require 'spec_helper'

describe PdftkForms::Metadata do
    before(:all) do
      @pdftk = PdftkForms::Wrapper.new
    end
  context "new" do
    before(:all) do
      @temp_file = @pdftk.dump_data(path_to_pdf('metadata.pdf'))
      @data_info = PdftkForms::Metadata.new(@temp_file)
    end

    it "should create a PdftkForms::Metadata object" do
      @data_info.should be_kind_of(PdftkForms::Metadata)
    end

    it "should retrieve Infos" do
      @default_infos = {"Creator" => "Scribus 1.3.3.13svn", "Producer" => "ActivePdftk", "Author" => "Elmatou", "Title" => "Metadata Test file", "Keywords" => "pdftk metadata bookmarks pagelabel", "CreationDate" => "D:20110615000000", "ModDate" => "D:20110615000001"}
      @data_info.infos.each do |info|
        info.should be_kind_of(PdftkForms::Metadata::Info)
        info.is_valid?.should be_true
        info.value.should == @default_infos[info.key]
      end
      @data_info.infos.count.should == 7
    end

    it "should retrieve the number of pages" do
      @data_info.pages.should == 4
    end

    it "should retrieve ids" do
      @data_info.pdf_ids.should == ["62819f2d3497b8ee3e31889dfd4e7ae5", "62819f2d3497b8ee3e31889dfd4e7ae5"]
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
  
  context "read" do
    before do
      @string_io = @pdftk.dump_data(path_to_pdf('metadata.pdf'))
      @data_info = PdftkForms::Metadata.new(@string_io)
    end

    it "should prepare a formatted string." do
      @data_info.to_s.should == @string_io.string
    end
  end

  context "edit informations" do
    before do
      @data_info = PdftkForms::Metadata.new(@pdftk.dump_data(path_to_pdf('metadata.pdf')))

      @data_info.info_set("Producer", "Testing")
      @data_info.info_set("Author", "SuperTest")
      @data_info.info_set("ModDate", "D:20110615111111")
      @data_info.info_set("CreationDate", "D:20110615222222")
      @data_info.info_delete("Title")
      @data_info.info_set("Keywords", "Metadata keywords")
    end

    it "should set/add/delete some" do
      @updated_info = PdftkForms::Metadata.new(@data_info.to_s)

      @updated_info.info_get("Producer").value.should == "Testing"
      @updated_info.info_get("Author").value.should == "SuperTest"
      @updated_info.info_get("ModDate").value.should == "D:20110615111111"
      @updated_info.info_get("CreationDate").value.should == "D:20110615222222"
      @updated_info.info_get("Title").should == nil
      @updated_info.info_get("Keywords").value.should == "Metadata keywords"
    end

    it "should update them in the pdf" do
      @pdftk.update_info(path_to_pdf('metadata.pdf'), StringIO.new(@data_info.to_s), :output => @new_pdf = StringIO.new)
      @new_pdf.rewind
      @updated_info = PdftkForms::Metadata.new(@pdftk.dump_data(@new_pdf))

      @updated_info.info_get("Producer").value.should == "Testing"
      @updated_info.info_get("Author").value.should == "SuperTest"
      @updated_info.info_get("ModDate").value.should == "D:20110615111111"
      @updated_info.info_get("CreationDate").value.should == "D:20110615222222"
      @updated_info.info_get("Title").should == nil
      @updated_info.info_get("Keywords").value.should == "Metadata keywords"
    end
  end

#  context "prepare specs" do
#    before do
#      @data_info = PdftkForms::Metadata.new(@pdftk.dump_data(path_to_pdf('metadata.pdf')))
#    end
#
#    it "should prepare my test file" do
#      @data_info.info_set("Producer", "ActivePdftk")
#      @data_info.info_set("Author", "Elmatou")
#      @data_info.info_set("Title", "Metadata Test file")
#      @data_info.info_set("ModDate", "D:20110615000001")
#      @data_info.info_set("CreationDate", "D:20110615000000")
#      @data_info.info_set("Keywords", "pdftk metadata bookmarks pagelabel")
#
#      @data_info.pdf_ids = ["1cd5c16169d6593c78aa499b67d2d51e", "12819f2d3497b8ee3e31889dfd4e7ae5"]
#      @data_info.add_bookmark("First Page !", 1, 1)
#      @data_info.add_bookmark("Last Page !", 2, 4)
#      @data_info.add_page_label(1, 1, "LowercaseRomanNumerals")
#
#      @pdftk.update_info(path_to_pdf('metadata.pdf'), StringIO.new(@data_info.to_s), :output => path_to_pdf('metadata2.pdf'))
#    end
#  end
end