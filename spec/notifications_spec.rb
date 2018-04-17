describe Notifications do
  it "has a version number" do
    expect(Notifications::VERSION).not_to be nil
  end
end

describe Notifications::Action do
  describe "normalize" do
    it "should return a two element array with the action string and human-readable action text in that order" do
      action_n = 'Default'
      action_t = 'Sample text describing default action'
      action = Notifications::Action.new(action_n, action_t)
      ray = action.normalize
      expect(ray.length).to eql(2)
      expect(ray[0]).to eql(action_n)
      expect(ray[1]).to eql(action_t)
    end
  end
end

describe Notifications::ActionList do
  describe ".length" do
    it "should return the number of elements in the Notifications::ActionList" do
      al = Notifications::ActionList.new
      al << Notifications::Action.new('Test1', 'text')
      expect(al.length).to eql(1)
    end
  end

  describe "<< and []" do
    it "should append and retrieve actions respectively" do
      al = Notifications::ActionList.new
      al << Notifications::Action.new('Test1','text')
      expect(al.length).to eql(1)
      expect(al[0].action).to eql('Test1')
      al << Notifications::Action.new('Test2','text2')
      expect(al.length).to eql(2)
      expect(al[1].action).to eql('Test2')
    end
  end

  describe ".pack" do
    it "should compact the Notifications::Action elements into sequential lists of action strings and action descriptions end to end" do
      al = Notifications::ActionList.new
      r_texts = []
      junk_desc = 'fefef'
      (1..5).each do |indx|
        r_text = (0..10).map { ('a'..'z').to_a[rand(26)] }.join
        description = junk_desc + indx.to_s
        r_texts << r_text
        al << Notifications::Action.new(r_text, description)
      end

      pack = al.pack
      expect(pack.length).to eql(al.length * 2)

      pack.each_with_index { |ele, indx|
        if indx.even? then
          expect(ele).to eql(r_texts[indx / 2])
        else
          expect(ele).to eql(junk_desc + ((indx + 1) / 2).to_s)
        end
      }
    end
  end
end
