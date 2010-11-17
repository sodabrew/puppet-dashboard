describe "sorted index", :shared => true do
  describe "when retrieving" do
    it "should be sorted by default" do
      c = model.generate! :name => "c"
      b = model.generate! :name => "b"
      d = model.generate! :name => "d"
      a = model.generate! :name => "a"

      model.all.should == [a,b,c,d]
    end
  end
end
