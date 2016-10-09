require 'spec_helper'

class TestCleric
  include Cleric

end

# describe Cleric do
  # context "when included in other class" do
  #   it "should include the Cleric module" do
  #     cleric = TestCleric.new
  #     expect(cleric).to be_kind_of Cleric
  #   end
  # end
  #
  # context "when initialize" do
  #   it "should generate cleric instance with no parameters" do
  #     cleric = TestCleric.new
  #     expect(cleric).to be_instance_of TestCleric
  #   end

    # it "should generate cleric instance with only db parameters" do
    #   cleric = TestCleric.new(:db => 'Wechat_db')
    #   expect(cleric).to be_instance_of TestCleric
    # end

    # it "should generate cleric instance with only ssh parameters" do
    #   cleric = TestCleric.new(:ssh => 'Wechat_ssh')
    #   expect(cleric).to be_instance_of TestCleric
    # end
    #
    # it "should generate cleric instance with both db and ssh parameters" do
    #   cleric = TestCleric.new(:ssh => 'Wechat_ssh',:db => 'Wechat_db')
    #   expect(cleric).to be_instance_of TestCleric
    # end

  # end

# end
