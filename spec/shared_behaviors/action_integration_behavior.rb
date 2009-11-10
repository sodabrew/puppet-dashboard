shared_examples_for "a successful action" do
  it 'should successfully render' do
    do_request
    response.should be_success
  end
end

shared_examples_for "an embeddable action" do
  it 'should successfully render' do
    do_request
    response.should be_success
  end

  it 'should not use a layout' do
    do_request
    response.layout.should be_nil
  end
end

shared_examples_for "a redirecting action" do
  it 'should redirect' do
    do_request
    response.should be_redirect
  end
end
