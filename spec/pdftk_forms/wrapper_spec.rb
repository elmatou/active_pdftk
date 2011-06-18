require 'spec_helper'

describe PdftkForms::Wrapper do
  context "new" do
    it "should instantiate the object." do
      @pdftk = PdftkForms::Wrapper.new
      @pdftk.should be_an_instance_of(PdftkForms::Wrapper)
    end

    it "should pass the defaults statements to the call instance." do
      path = PdftkForms::Call.new.locate_pdftk
      @pdftk = PdftkForms::Wrapper.new(:path => path, :operation => {:fill_form => 'a.fdf'}, :options => { :flatten => false, :owner_pw => 'bar', :user_pw => 'baz', :encrypt  => :'40bit'})
      @pdftk.default_statements.should == {:path => path, :operation => {:fill_form => 'a.fdf'}, :options => { :flatten => false, :owner_pw => 'bar', :user_pw => 'baz', :encrypt  => :'40bit'}}
    end
  end

  context "operation :" do
    before do
      @pdftk = PdftkForms::Wrapper.new
    end

    context "dump_data_fields" do
      it "should call #pdftk on @call" do
        PdftkForms::Call.any_instance.should_receive(:pdftk).with({:input => path_to_pdf('fields.pdf'), :operation => :dump_data_fields_utf8})
        @pdftk.dump_data_fields(path_to_pdf('fields.pdf'))
        @pdftk = PdftkForms::Wrapper.new
        PdftkForms::Call.any_instance.should_receive(:pdftk).with({:input => path_to_pdf('fields.pdf'), :operation => :dump_data_fields_utf8, :options => {:encrypt  => :'40bit'}})
        @pdftk.dump_data_fields(path_to_pdf('fields.pdf'), :options => {:encrypt  => :'40bit'})
      end

      it "should output the fdf as a string" do
        @pdftk.dump_data_fields(path_to_pdf('fields.pdf')).should be_kind_of(StringIO)
      end

      it "should output to a file" do
        @pdftk.dump_data_fields(path_to_pdf('fields.pdf'), :output => path_to_pdf('dump_data_fields.txt'))
        File.unlink(path_to_pdf('dump_data_fields.txt')).should == 1
      end
    end

    context "fill_form" do
      it "should fill the field of the pdf" do
        @pdftk.fill_form(path_to_pdf('fields.pdf'), {'text_not_required' => 'Running specs'}, :output => path_to_pdf('filled_spec.pdf'))
        temp = @pdftk.dump_data_fields(path_to_pdf('filled_spec.pdf'))
        temp.rewind
        temp.read.should match(/FieldValue: Running specs/)
        File.unlink(path_to_pdf('filled_spec.pdf')).should == 1
      end
    end

    context "dump_data/update_info" do
      it "should dump file info of the pdf" do
        @temp_file = @pdftk.dump_data(path_to_pdf('fields.pdf'))
        File.new(path_to_pdf('fields.data')).read.should == @temp_file.string
      end

      it "should update file info of the pdf" do
        @s_info = @pdftk.dump_data(path_to_pdf('fields.pdf'))
        @s_info.string = @s_info.string.gsub('InfoValue: Untitled', 'InfoValue: Data Updated')
        @pdftk.update_info(path_to_pdf('fields.pdf'), @s_info, :output => @s_out = StringIO.new)
        @s_out.rewind
        @pdftk.dump_data(@s_out).string.should == @s_info.string
      end
    end

    context "attach_files/unpack_files" do
      it "should bind the file ine the pdf" do
        @pdftk.attach_files(path_to_pdf('fields.pdf'), path_to_pdf('attached_file.txt'), :output => path_to_pdf('fields.pdf.attached'))
        File.unlink(path_to_pdf('attached_file.txt')).should == 1
      end

      it "should retrieve the file" do
        @pdftk.unpack_files(path_to_pdf('fields.pdf.attached'), path_to_pdf(''))
        File.unlink(path_to_pdf('fields.pdf.attached')).should == 1
      end
    end

    context "generate_fdf" do
      it "should call #pdftk on @call" do
        PdftkForms::Call.any_instance.should_receive(:pdftk).with({:input => path_to_pdf('fields.pdf'), :operation => :generate_fdf})
        @pdftk.generate_fdf(path_to_pdf('fields.pdf'))
        @pdftk = PdftkForms::Wrapper.new
        PdftkForms::Call.any_instance.should_receive(:pdftk).with({:input => path_to_pdf('fields.pdf'), :operation => :generate_fdf, :options => {:encrypt  => :'40bit'}})
        @pdftk.generate_fdf(path_to_pdf('fields.pdf'), :options => {:encrypt  => :'40bit'})
      end

      it "should output the fdf as a string" do
        @pdftk.generate_fdf(path_to_pdf('fields.pdf')).should be_kind_of(StringIO)
      end

      it "should output to a file" do
        @pdftk.generate_fdf(path_to_pdf('fields.pdf'), :options => {:encrypt  => :'40bit'}, :output => path_to_pdf('fields.fdf'))
        File.unlink(path_to_pdf('fields.fdf')).should == 1
      end
    end

    context "burst" do
      it "should call #pdtk on @call" do
        PdftkForms::Call.any_instance.should_receive(:pdftk).with({:input => path_to_pdf('fields.pdf'), :operation => :burst})
        @pdftk.burst(path_to_pdf('fields.pdf'))
        @pdftk = PdftkForms::Wrapper.new
        PdftkForms::Call.any_instance.should_receive(:pdftk).with({:input => path_to_pdf('fields.pdf'), :operation => :burst, :options => {:encrypt  => :'40bit'}})
        @pdftk.burst(path_to_pdf('fields.pdf'), :options => {:encrypt  => :'40bit'})
      end
      
      it "should put a file in the system tmpdir when no output location given" do
        @pdftk.burst(path_to_pdf('fields.pdf'))
        File.unlink(File.join(Dir.tmpdir, 'pg_0001.pdf')).should == 1
      end

      it "should put a file in the system tmpdir when no output location given but a page name format given" do
        @pdftk.burst(path_to_pdf('fields.pdf'), :output => 'page_%02d.pdf')
        File.unlink(File.join(Dir.tmpdir, 'page_01.pdf')).should == 1
      end

      it "should put a file in the specified path" do
        @pdftk.burst(path_to_pdf('fields.pdf'), :output => path_to_pdf('page_%02d.pdf').to_s)
        File.unlink(path_to_pdf('page_01.pdf')).should == 1
      end
    end

    context "background" do
      it "should call #pdtk on @call" do
        PdftkForms::Call.any_instance.should_receive(:pdftk).with({:input => path_to_pdf('a.pdf'), :operation => {:background => path_to_pdf('b.pdf')}})
        @pdftk.background(path_to_pdf('a.pdf'), path_to_pdf('b.pdf'))
        @pdftk = PdftkForms::Wrapper.new
        PdftkForms::Call.any_instance.should_receive(:pdftk).with({:input => path_to_pdf('a.pdf'), :operation => {:background => path_to_pdf('b.pdf')}, :options => {:encrypt  => :'40bit'}})
        @pdftk.background(path_to_pdf('a.pdf'), path_to_pdf('b.pdf'), :options => {:encrypt  => :'40bit'})
      end
      
      it "should output the generated pdf" do
        @pdftk.background(path_to_pdf('a.pdf'), path_to_pdf('b.pdf'), :output => path_to_pdf('background.pdf'))
        File.unlink(path_to_pdf('background.pdf')).should == 1
      end
    end

    context "multibackground" do
      it "should call #pdtk on @call" do
        PdftkForms::Call.any_instance.should_receive(:pdftk).with({:input => path_to_pdf('a.pdf'), :operation => {:multibackground => path_to_pdf('b.pdf')}})
        @pdftk.background(path_to_pdf('a.pdf'), path_to_pdf('b.pdf'), :multi => true)
        @pdftk = PdftkForms::Wrapper.new
        PdftkForms::Call.any_instance.should_receive(:pdftk).with({:input => path_to_pdf('a.pdf'), :operation => {:multibackground => path_to_pdf('b.pdf')}, :options => {:encrypt  => :'40bit'}})
        @pdftk.background(path_to_pdf('a.pdf'), path_to_pdf('b.pdf'), :multi => true, :options => {:encrypt  => :'40bit'})
      end
    end

    context "stamp" do
      it "should call #pdtk on @call" do
        PdftkForms::Call.any_instance.should_receive(:pdftk).with({:input => path_to_pdf('a.pdf'), :operation => {:stamp => path_to_pdf('b.pdf')}})
        @pdftk.stamp(path_to_pdf('a.pdf'), path_to_pdf('b.pdf'))
        @pdftk = PdftkForms::Wrapper.new
        PdftkForms::Call.any_instance.should_receive(:pdftk).with({:input => path_to_pdf('a.pdf'), :operation => {:stamp => path_to_pdf('b.pdf')}, :options => {:encrypt  => :'40bit'}})
        @pdftk.stamp(path_to_pdf('a.pdf'), path_to_pdf('b.pdf'), :options => {:encrypt  => :'40bit'})
      end
      
      it "should output the generated pdf" do
        @pdftk.stamp(path_to_pdf('a.pdf'), path_to_pdf('b.pdf'), :output => path_to_pdf('stamp.pdf'))
        File.unlink(path_to_pdf('stamp.pdf')).should == 1
      end
    end

    context "multistamp" do
      it "should call #pdtk on @call" do
        PdftkForms::Call.any_instance.should_receive(:pdftk).with({:input => path_to_pdf('a.pdf'), :operation => {:multistamp => path_to_pdf('b.pdf')}})
        @pdftk.stamp(path_to_pdf('a.pdf'), path_to_pdf('b.pdf'), :multi => true)
        @pdftk = PdftkForms::Wrapper.new
        PdftkForms::Call.any_instance.should_receive(:pdftk).with({:input => path_to_pdf('a.pdf'), :operation => {:multistamp => path_to_pdf('b.pdf')}, :options => {:encrypt  => :'40bit'}})
        @pdftk.stamp(path_to_pdf('a.pdf'), path_to_pdf('b.pdf'), :multi => true, :options => {:encrypt  => :'40bit'})
      end
    end

    context "cat" do
      it "should call #pdftk on @call" do
        PdftkForms::Call.any_instance.should_receive(:pdftk).with({:input => {'a.pdf' => 'foo', 'b.pdf' => nil}, :operation => {:cat => [{:pdf => 'a.pdf'}, {:pdf => 'b.pdf', :start => 1, :end => 'end', :orientation => 'N', :pages => 'even'}]}})
        @pdftk.cat([{:pdf => 'a.pdf', :pass => 'foo'}, {:pdf => 'b.pdf', :start => 1, :end => 'end', :orientation => 'N', :pages => 'even'}])
      end
      
      it "should output the generated pdf" do
        @pdftk.cat([{:pdf => path_to_pdf('a.pdf'), :pass => 'foo'}, {:pdf => path_to_pdf('b.pdf'), :start => 1, :end => 'end', :orientation => 'N', :pages => 'even'}], :output => path_to_pdf('cat.pdf'))
        File.unlink(path_to_pdf('cat.pdf')).should == 1
      end
    end

    context "shuffle" do
      it "should call #pdftk on @call" do
        PdftkForms::Call.any_instance.should_receive(:pdftk).with({:input => {'a.pdf' => 'foo', 'b.pdf' => nil}, :operation => {:shuffle => [{:pdf => 'a.pdf'}, {:pdf => 'b.pdf', :start => 1, :end => 'end', :orientation => 'N', :pages => 'even'}]}})
        @pdftk.shuffle([{:pdf => 'a.pdf', :pass => 'foo'}, {:pdf => 'b.pdf', :start => 1, :end => 'end', :orientation => 'N', :pages => 'even'}])
      end
      
      it "should output the generated pdf" do
        @pdftk.shuffle([{:pdf => path_to_pdf('a.pdf'), :pass => 'foo'}, {:pdf => path_to_pdf('b.pdf'), :start => 1, :end => 'end', :orientation => 'N', :pages => 'even'}], :output => path_to_pdf('shuffle.pdf'))
        File.unlink(path_to_pdf('shuffle.pdf')).should == 1
      end
    end
  end
end
