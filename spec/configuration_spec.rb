require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Using the Configuration Model", :reset_redis => true do
  before(:each) do
    Ohm.redis.flushdb
    @appconf_string = {:name => "mystringconf", :format => "string", :body => "some_var"}
    @appconf_json = {:name => "myjsonconf", :format => "json", :body => @appconf_string.to_json}
    @appconf_missing_name = @appconf_string.reject {|k, v| k == :name}
    @appconf_missing_format = @appconf_string.reject {|k, v| k == :format}
    @appconf_missing_body = @appconf_string.reject {|k, v| k == :body}
  end
  after(:each) do
    Ohm.redis.flushdb
  end

  describe "should" do
    it "create a new Configuration" do
      c = Noah::Configuration.create(@appconf_string)
      c.valid?.should == true
      c.is_new?.should == true
      b = Noah::Configuration[c.id]
      b.should == c
    end
    it "create a new Configuration via find_or_create" do
      c = Noah::Configuration.find_or_create(@appconf_string)
      c.valid?.should == true
      c.is_new?.should == true
      a = Noah::Configuration[c.id]
      a.should == c
    end
    it "update an existing Configuration via find_or_create" do
      c = Noah::Configuration.find_or_create(@appconf_string)
      c.valid?.should == true
      c.is_new?.should == true
      sleep(3)
      c.body = "some_other_var"
      c.save
      c.body.should == "some_other_var"
      c.is_new?.should == false
    end
    it "delete an existing Configuration" do
      a = Noah::Configuration.find_or_create(@appconf_string)
      b = Noah::Configuration.find(@appconf_string).first
      b.should == a
      a.delete
      c = Noah::Configuration.find(@appconf_string).first
      c.nil?.should == true
    end
    it "return all Configurations" do
      a = Noah::Configuration.find_or_create(@appconf_string)
      b = Noah::Configuration.find_or_create(@appconf_json)
      c = Noah::Configurations.all
      c.size.should == 2
      c.member?(a).should == true
      c.member?(b).should == true
    end
  end

  describe "should not" do
    it "create a new Configuration without a name" do
      a = Noah::Configuration.create(@appconf_missing_name)
      a.valid?.should == false
      a.errors.should == [[:name, :not_present]]
    end
    it "create a new Configuration without a format" do
      a = Noah::Configuration.create(@appconf_missing_format)
      a.valid?.should == false
      a.errors.should == [[:format, :not_present]]
    end
    it "create a new Configuration without a body" do
      a = Noah::Configuration.create(@appconf_missing_body)
      a.valid?.should == false
      a.errors.should == [[:body, :not_present]]
    end
    it "create a duplicate Configuration" do
      a = Noah::Configuration.create(@appconf_string)
      b = Noah::Configuration.create(@appconf_string)
      b.errors.should == [[:name, :not_unique]]
    end
  end

end
