require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe NodesController do
  describe '#edit' do
    before :each do
      @node = Node.generate!
    end

    def do_get
      get :edit, :id => @node.name
    end

    it 'should make the requested node available to the view' do
      do_get
      assigns[:node].should == @node
    end

    it 'should render the edit template' do
      do_get
      response.should render_template('edit')
    end
  end

  describe '#update' do
    before :each do
      @node = Node.generate!
      @params = { :id => @node.name, :node => @node.attributes }
    end

    def do_put
      put :update, @params
    end

    it 'should fail when an invalid node id is given' do
      @params[:id] = 'unknown'
      lambda { do_put }.should raise_error(ActiveRecord::RecordNotFound)
    end

    describe 'when a valid node id is given' do

      describe 'and the data provided would make the node invalid' do
        before :each do
          @params[:node]['name'] = nil
        end

        it 'should make the node available to the view' do
          do_put
          assigns[:node].should == @node
        end

        it 'should not save the node' do
          do_put
          Node.find(@node.id).name.should_not be_nil
        end

        it 'should have errors on the node' do
          do_put
          assigns[:node].errors[:name].should_not be_blank
        end

        it 'should render the update action' do
          do_put
          response.should render_template('update')
        end
      end

      describe 'and the data provided make the node valid' do
        it 'should note the update success in flash' do
          do_put
          flash[:notice].should match(/success/i)
        end

        it 'should update the node with the data provided' do
          @params[:node]['name'] = 'new name'
          do_put
          Node.find(@node.id).name.should == 'new name'
        end

        it 'should have a valid node' do
          do_put
          assigns[:node].should be_valid
        end
      end
    end
  end
end
