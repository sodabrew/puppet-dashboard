require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. spec_helper]))

describe '/nodes/show' do
  before :each do
  end

  def do_render
    render '/nodes/show'
  end

  it 'should render successfully' do
    do_render
  end
end
