shared_examples_for "sorted index" do
  describe "when retrieving" do
    it "should be sorted by default" do
      model_sym = model.name.underscore.to_sym
      c = create(model_sym, :name => 'c')
      b = create(model_sym, :name => 'b')
      d = create(model_sym, :name => 'd')
      a = create(model_sym, :name => 'a')

      model.all.should == [a,b,c,d]
    end
  end
end
