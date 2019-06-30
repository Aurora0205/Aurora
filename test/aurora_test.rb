require 'test_helper'

class Aurora::Test < ActiveSupport::TestCase
  test "truth" do
    assert_kind_of Module, Aurora
  end

  # outline: whether autora can register with the minimum settings
  # expected value: registerd 3 datas
  test "nothing" do
    Aurora.execute("test/data/function/nothing_conf.toml")
    assert_equal 3, Pref.all.count
  end

  # outline: whether autora can register with the same model
  # expected value: registerd 6 datas
  test "same model" do
    Aurora.execute("test/data/function/same_model_conf.toml")
    assert_equal 6, Pref.all.count
  end

  # outline: whether 'autoincrement' works
  # expected value: registerd 6 datas
  #                 registed autoincrement_id
  test "autoincrement_id" do
    Aurora.execute("test/data/function/nothing_conf.toml")
    assert_equal 3, Pref.all.count
    assert_equal true, Pref.where(id: 1).present?
    assert_equal true, Pref.where(id: 2).present?
    assert_equal true, Pref.where(id: 3).present?
    Aurora.execute("test/data/function/nothing_conf.toml")
    assert_equal 6, Pref.all.count
    assert_equal true, Pref.where(id: 4).present?
    assert_equal true, Pref.where(id: 5).present?
    assert_equal true, Pref.where(id: 6).present?
  end

  # outline: whether 'autoincrement = false' works
  # expected value: registerd 3 datas
  #                 registed autoincrement_id
  test "no autoincrement_id" do
    Aurora.execute("test/data/function/no_autoincrement.toml")
    assert_equal 3, Pref.all.count
    assert_equal true, Pref.where(id: 100).present?
    assert_equal true, Pref.where(id: 101).present?
    assert_equal true, Pref.where(id: 102).present?
  end
  
  # outline: whether autora can register with the setting array 
  # expected value: registerd 3 datas
  #                 registerd ["北海道", "青森県", "岩手県"]
  test "insert setting array" do
    Aurora.execute("test/data/function/array_insert.toml")
    assert_equal 3, Pref.all.count
    assert_equal true, Pref.where(name: "北海道").present?
    assert_equal true, Pref.where(name: "青森県").present?
    assert_equal true, Pref.where(name: "岩手県").present?
  end

  # outline: whether autora can register with the setting string
  # expected value: registerd 3 datas
  #                 registerd "北海道"
  test "insert setting string" do
    Aurora.execute("test/data/function/string_insert.toml")
    assert_equal 3, Pref.all.count
    assert_equal 3, Pref.where(name: "北海道").count
  end

  # outline: whether 'add_id' works
  # expected value: registerd 3 datas
  #                 registerd ["北海道_1", "青森県_2", "岩手県_3"]
  test "add_id option" do
    Aurora.execute("test/data/option/add_id_conf.toml")
    assert_equal 3, Pref.all.count
    assert_equal true, Pref.where(name: "北海道_0").present?
    assert_equal true, Pref.where(name: "青森県_1").present?
    assert_equal true, Pref.where(name: "岩手県_2").present?
  end
end
