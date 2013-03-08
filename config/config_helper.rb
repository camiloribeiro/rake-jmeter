@issues = []

class Issue < Struct.new(:id, :item, :expected, :real, :label); end

def desc_issue(expected, real, item, label)
  @issues.push Issue.new(@issues.size + 1,item, expected, real, label)
end

