require 'spec_helper'

describe 'Helpers' do
  it 'should render properly' do
    response = render 'spec'
    expect(response.gsub(/[ \n\t]/, '')).to eq(File.read(File.expand_path('../answers/spec.html', __FILE__)).strip)
  end
end
