describe PdftkForms::Metadata::Info do
  context "new" do
    before(:all) do
      @title = PdftkForms::Metadata::Info.new('Title', 'My title')
    end

    it "should create the object" do
      @title.should be_kind_of(PdftkForms::Metadata::Info)
      @title.key.should == 'Title'
      @title.value.should == 'My title'
    end
  end

  context "is_valid?" do
    before(:all) do
      @title = PdftkForms::Metadata::Info.new('Title', 'My title')
    end

    it "should be valid" do
      @title.is_valid?.should be_true
    end

    it "should be not valid with an empty key" do
      @title.key = nil
      @title.is_valid?.should be_false
      @title.key = ""
      @title.is_valid?.should be_false
    end

    it "should be not valid with an empty value" do
      @title.value = ""
      @title.is_valid?.should be_false
      @title.value = nil
      @title.is_valid?.should be_false
    end
  end

  context "to_s" do
    before(:all) do
      @title = PdftkForms::Metadata::Info.new('Title', 'My title')
    end

    it "should be print with the correct format" do
      @title.to_s.should == "InfoKey: Title\nInfoValue: My title\n"
    end

    it "should raise a PdftkForms::Metadata::NotValid exception " do
      @title.value = nil
      expect{ @title.to_s }.to raise_error(PdftkForms::Metadata::NotValid)
    end
  end

  context "to_h" do
    before(:all) do
      @title = PdftkForms::Metadata::Info.new('Title', 'My title')
    end
    
    it "should be the expected Hash" do
      @title.to_h.should == {"Title"=>"My title"}
    end
  end
end






describe PdftkForms::Metadata::Bookmark do
  context "new" do
    before(:all) do
      @bookmark = PdftkForms::Metadata::Bookmark.new('My title', 1, 1)
    end

    it "should create the object" do
      @bookmark.should be_kind_of(PdftkForms::Metadata::Bookmark)
      @bookmark.title.should == 'My title'
      @bookmark.level.should == 1
      @bookmark.page_number.should == 1
    end
  end

  context "is_valid?" do
    before(:all) do
      @bookmark = PdftkForms::Metadata::Bookmark.new('My title', 1, 1)
    end

    it "should be valid" do
      @bookmark.is_valid?.should be_true
    end

    it "should be not valid with an empty title" do
      @bookmark.title = ""
      @bookmark.is_valid?.should be_false
      @bookmark.title = nil
      @bookmark.is_valid?.should be_false
    end
    
    it "should be not valid with an empty level" do
      @bookmark.level = nil
      @bookmark.is_valid?.should be_false
    end

    it "should be not valid with an empty page_number" do
      @bookmark.page_number = nil
      @bookmark.is_valid?.should be_false
    end
  end

  context "to_s" do
    before(:all) do
      @bookmark = PdftkForms::Metadata::Bookmark.new('My title', 1, 1)
    end

    it "should be print with the correct format" do
      @bookmark.to_s.should == "BookmarkTitle: My title\nBookmarkLevel: 1\nBookmarkPageNumber: 1\n"
    end

    it "should raise a PdftkForms::Metadata::NotValid exception " do
      @bookmark.page_number = nil
      expect{ @bookmark.to_s }.to raise_error(PdftkForms::Metadata::NotValid)
    end
  end

  context "to_h" do
    before(:all) do
      @bookmark = PdftkForms::Metadata::Bookmark.new('My title', 1, 1)
    end

    it "should be the expected Hash" do
      @bookmark.to_h.should == {:title=>"My title", :level=>1, :page_number=>1}
    end
  end
end





describe PdftkForms::Metadata::PageLabel do
  context "new" do
    before(:all) do
      @label = PdftkForms::Metadata::PageLabel.new(1, 1, 'LowercaseRomanNumerals')
    end

    it "should create the object" do
      @label.should be_kind_of(PdftkForms::Metadata::PageLabel)
      @label.new_index.should == 1
      @label.start.should == 1
      @label.num_style.should == 'LowercaseRomanNumerals'
    end
  end

  context "is_valid?" do
    before(:all) do
      @label = PdftkForms::Metadata::PageLabel.new(1, 1, 'LowercaseRomanNumerals')
    end

    it "should be valid" do
      @label.is_valid?.should be_true
    end

    it "should be not valid with an empty new_index" do
      @label.new_index = nil
      @label.is_valid?.should be_false
    end

    it "should be not valid with an empty start" do
      @label.start = nil
      @label.is_valid?.should be_false
    end
    
    it "should be not valid with an empty num_style" do
      @label.num_style = ""
      @label.is_valid?.should be_false
      @label.num_style = nil
      @label.is_valid?.should be_false
    end
  end

  context "to_s" do
    before(:all) do
      @label = PdftkForms::Metadata::PageLabel.new(1, 1, 'LowercaseRomanNumerals')
    end

    it "should be print with the correct format" do
      @label.to_s.should == "PageLabelNewIndex: 1\nPageLabelStart: 1\nPageLabelNumStyle: LowercaseRomanNumerals\n"
    end

    it "should raise a PdftkForms::Metadata::NotValid exception " do
      @label.num_style = nil
      expect{ @label.to_s }.to raise_error(PdftkForms::Metadata::NotValid)
    end
  end

  context "to_h" do
    before(:all) do
      @label = PdftkForms::Metadata::PageLabel.new(1, 1, 'LowercaseRomanNumerals')
    end

    it "should be the expected Hash" do
      @label.to_h.should == {:new_index=>1, :start=>1, :num_style=>"LowercaseRomanNumerals"}
    end
  end
end
