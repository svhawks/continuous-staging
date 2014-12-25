require 'json'
require 'spec_helper'
require_relative '../../../lib/providers/bitbucket'

describe Providers::Bitbucket do
  let(:payload) { JSON.parse(BITBUCKET_JSON) }
  subject { described_class.new(payload) }

  it 'parses branch' do
    expect(subject.branch).to eql('master')
  end
end
