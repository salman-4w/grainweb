require 'test_helper'

class PendingLadingTest < ActiveSupport::TestCase
  test 'new object should be initialized with default values' do
    customer = Customer.find_by_cust_id('USGSA')
    lading = PendingLading.default(customer)
    assert_equal Date.today.to_time.to_i, lading.lading_date.to_time.to_i
    assert lading.draft
    assert !lading.deleted
    assert_equal customer, lading.shipper_customer
    assert_equal customer.cust_id, lading.shipper
  end

  test 'should create not draft lading' do
    with_transaction_rollback do
      assert_difference 'PendingLading.count' do
        lading = create_lading(:draft => false)
        assert !lading.new_record?, "#{lading.errors.full_messages.to_sentence}"
        assert !lading.draft
      end
    end
  end

  test 'lading num should be generated and should be great or equal 600001' do
    with_transaction_rollback do
      assert_difference 'PendingLading.count' do
        lading = create_lading(:draft => false)
        assert !lading.new_record?, "#{lading.errors.full_messages.to_sentence}"
        assert lading.lading_num.to_i >= 600001
      end
    end
  end

  test 'should require lading date' do
    with_transaction_rollback do
      assert_no_difference 'PendingLading.count' do
        lading = create_lading(:lading_date => nil)
        assert !lading.errors[:lading_date].empty?
      end
    end
  end

  test 'should require date only for not draft objects' do
    with_transaction_rollback do
      assert_no_difference 'PendingLading.count' do
        lading = create_lading(:lading_date => nil, :draft => false)
        assert !lading.errors[:lading_date].empty?
      end
    end
  end

  test 'should require grain loaded only for not draft objects' do
    with_transaction_rollback do
      assert_no_difference 'PendingLading.count' do
        lading = create_lading(:grain_loaded => nil, :draft => false)
        assert !lading.errors[:grain_loaded].empty?
      end
    end
  end

  test 'should not require grain loaded when the commodity was assigned' do
    with_transaction_rollback do
      assert_difference 'PendingLading.count' do
        lading = create_lading(:grain_loaded => nil, :commodity => Commodity.find(16), :draft => false)
        assert !lading.new_record?, "#{lading.errors.full_messages.to_sentence}"
        assert !lading.draft
      end
    end
  end

  test 'should not require carr ID' do
    with_transaction_rollback do
      assert_difference 'PendingLading.count' do
        lading = create_lading(:carr_id => nil, :draft => false)
        assert !lading.new_record?, "#{lading.errors.full_messages.to_sentence}"
      end
    end
  end

  test 'should not require load ticket number' do
    with_transaction_rollback do
      assert_difference 'PendingLading.count' do
        lading = create_lading(:load_tick_num => nil, :draft => false)
        assert !lading.new_record?, "#{lading.errors.full_messages.to_sentence}"
      end
    end
  end

  test 'should not require driver license number' do
    with_transaction_rollback do
      assert_difference 'PendingLading.count' do
        lading = create_lading(:driver_license_num => nil, :draft => false)
        assert !lading.new_record?, "#{lading.errors.full_messages.to_sentence}"
      end
    end
  end

  test 'should not require driver name' do
    with_transaction_rollback do
      assert_difference 'PendingLading.count' do
        lading = create_lading(:driver_name => nil, :draft => false)
        assert !lading.new_record?, "#{lading.errors.full_messages.to_sentence}"
      end
    end
  end

  test 'should not require driver license state' do
    with_transaction_rollback do
      assert_difference 'PendingLading.count' do
        lading = create_lading(:driver_license_state => nil, :draft => false)
        assert !lading.new_record?, "#{lading.errors.full_messages.to_sentence}"
      end
    end
  end

  test 'should not require load gross weight' do
    with_transaction_rollback do
      assert_difference 'PendingLading.count' do
        lading = create_lading(:load_gross_weight => nil, :draft => false)
        assert !lading.new_record?, "#{lading.errors.full_messages.to_sentence}"
      end
    end
  end

  test 'load gross weight can be a blank string' do
    with_transaction_rollback do
      assert_difference 'PendingLading.count' do
        lading = create_lading(:load_gross_weight => '')
        assert !lading.new_record?, "#{lading.errors.full_messages.to_sentence}"
      end
    end
  end

  test 'load gross weight should have correct number format' do
    with_transaction_rollback do
      assert_no_difference 'PendingLading.count' do
        lading = create_lading(:load_gross_weight => 'xxxxx')
        assert !lading.errors[:load_gross_weight].empty?
      end
    end
  end

  test 'should not require load tare weight' do
    with_transaction_rollback do
      assert_difference 'PendingLading.count' do
        lading = create_lading(:load_tare_weight => nil, :draft => false)
        assert !lading.new_record?, "#{lading.errors.full_messages.to_sentence}"
      end
    end
  end

  test 'load tare weight should have correct number format' do
    with_transaction_rollback do
      assert_no_difference 'PendingLading.count' do
        lading = create_lading(:load_tare_weight => 'xxxxx')
        assert !lading.errors[:load_tare_weight].empty?
      end
    end
  end

  test 'should not require load net weight' do
    with_transaction_rollback do
      assert_difference 'PendingLading.count' do
        lading = create_lading(:load_net_weight => nil, :draft => false)
        assert !lading.new_record?, "#{lading.errors.full_messages.to_sentence}"
      end
    end
  end

  test 'load net weight should have correct number format' do
    with_transaction_rollback do
      assert_no_difference 'PendingLading.count' do
        lading = create_lading(:load_net_weight => 'xxxxx')
        assert !lading.errors[:load_net_weight].empty?
      end
    end
  end

  test 'should not require load bus weight' do
    with_transaction_rollback do
      assert_difference 'PendingLading.count' do
        lading = create_lading(:load_bus_weight => nil, :draft => false)
        assert !lading.new_record?, "#{lading.errors.full_messages.to_sentence}"
      end
    end
  end

  test 'load bus weight should have correct number format' do
    with_transaction_rollback do
      assert_no_difference 'PendingLading.count' do
        lading = create_lading(:load_bus_weight => 'xxxxx')
        assert !lading.errors[:load_bus_weight].empty?
      end
    end
  end

  test 'should require shipper' do
    with_transaction_rollback do
      assert_no_difference 'PendingLading.count' do
        lading = create_lading(:shipper_customer => nil)
        assert !lading.errors[:shipper_customer].empty?
      end
    end
  end

  test 'should require commodity only for not draft objects' do
    with_transaction_rollback do
      assert_no_difference 'PendingLading.count' do
        lading = create_lading(:grain_loaded => nil, :commodity => nil, :draft => false)
        assert !lading.errors[:commodity].empty?
      end
    end
  end

  private
  def create_lading(options = {})
    customer = Customer.find_by_cust_id('USGSA')
    PendingLading.create({
      :lading_date => Date.today,
      :shipper_customer => customer,
      :draft => true,
      :grain_loaded => 16,
      :load_tick_num => 'TICK_NUM',
      :carr_id => 'USGSA',
      :driver_license_num => 'IDONTKNOWFORMAT',
      :driver_name => 'Bill Joel',
      :driver_license_state => 'AL',
      :load_gross_weight => 1,
      :load_tare_weight => 1,
      :load_net_weight => 1,
      :load_bus_weight => 1
    }.merge(options))
  end
end
