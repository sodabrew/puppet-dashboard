# USAGE: Your `describe` block must define a `model` method that returns the
# ActiveRecord model class to use for describing this behavior.

shared_examples_for "with search by q and tag" do
  describe "when searching" do
    before :each do
      SETTINGS.stubs(:use_external_node_classification).returns(true)
      model_sym = model.name.underscore.to_sym
      @for_tag = create(model_sym, :name => 'for_tag')
      @for_q = create(model_sym, :name => 'for_q')
      create(model_sym, :name => 'without_search')
    end

    describe "without a search" do
      before { get :index }
      subject { assigns[model.name.tableize] }

      it "returns all node groupes" do
        should match_array(model.all)
      end
    end

    describe "with a 'tag' search" do
      before { get :index, params: { tag: 'for_tag' } }
      subject { assigns[model.name.tableize] }

      it "returns node groupes whose name contains the term" do
        subject.all?{|item| item.name.include?('for_tag')}.should be true
      end

      it "does not return node groups whose name does not contain the term" do
        subject.any?{|item| item.name.include?('for_q')}.should be false
      end
    end

    describe "with a 'q' search" do
      before { get :index, params: { q: 'for_q' } }
      subject { assigns[model.name.tableize] }

      it "returns node groupes whose name contains the term" do
        subject.all?{|item| item.name.include?('for_q')}.should be true
      end

      it "does not return node groups whose name does not contain the term" do
        subject.any?{|item| item.name.include?('for_tag')}.should be false
      end
    end
  end
end

shared_examples_for "without JSON pagination" do
  describe "without JSON pagination" do
    describe "GET index" do
      describe "as HTML" do
        before do
          SETTINGS.stubs(:use_external_node_classification).returns(true)
          get :index, as: :html
        end
        subject { assigns[model.name.tableize] }

        it "will paginate" do
          should respond_to(:paginate)
        end
      end

      describe "as JSON" do
        before { get :index, as: :json }
        subject { assigns[model.name.tableize] }

        it "does not paginate" do
          should_not be_a_kind_of(WillPaginate::Collection)
        end
      end

      describe "as YAML" do
        before { get :index, as: :yaml }
        subject { assigns[model.name.tableize] }

        it "does not paginate" do
          should_not be_a_kind_of(WillPaginate::Collection)
        end
      end
    end
  end
end

