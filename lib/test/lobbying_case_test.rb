require './test/xpair_unit_test'

class LobbyingCaseFunctionalTest < XpairUnitTest

  def setup
    
  end
  
  def test
    bill_type = Type.new("lob:Bill") 
    s0 = bill_type.instances
    ethanol_bills = s0.refine{|rf| rf.keyword_match("ethanol")}
    incomes = ethanol_bills.pivot(:relations: ["lob:income"])
    incomes_by_bill = incomes.group{|gf| gf.by_domain(ethanol_bills)}
    sum_incomes_by_bill = incomes_by_bill.map{|mf| mf.sum}
    #CORRECT
    ranked_bills = incomes_by_bill.rank{|r| r.by_image }
    ranked_bills
    
  end

end