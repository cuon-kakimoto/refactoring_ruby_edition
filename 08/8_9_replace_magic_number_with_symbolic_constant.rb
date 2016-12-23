class Physical
  GRAVITATIONAL_CONSTANT = 9.81
  def potential_energy(mass, height)
    # OPTIMIZE: シンボル定数を利用
    # mass * 9.81 * height
    mass * GRAVITATIONAL_CONSTANT * height
  end
end

require 'test/unit'
class PhysicalTest < Test::Unit::TestCase
  def test_potential_energy
    p = Physical.new
    assert_in_delta 981, p.potential_energy(10, 10)
  end
end
