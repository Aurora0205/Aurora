require 'test_helper'

class Aurora::YmlTest < ActiveSupport::TestCase
  test "truth" do
    assert_kind_of Module, Aurora
  end

  # outline: whether autora can register with the minimum settings
  # expected value: registerd 3 datas
  test "nothing" do
    Aurora.execute("test/data/yml/function/nothing_conf.yml")
    assert_equal 3, Pref.all.count
  end

  # outline: whether autora can register with the same model
  # expected value: registerd 6 datas
  test "same model" do
    Aurora.execute("test/data/yml/function/same_model_conf.yml")
    assert_equal 6, Pref.all.count
  end

  # outline: whether 'autoincrement' works
  # expected value: registerd 6 datas
  #                 registed autoincrement_id
  test "autoincrement_id" do
    Aurora.execute("test/data/yml/function/nothing_conf.yml")
    assert_equal 3, Pref.all.count
    assert_equal true, Pref.where(id: 1).present?
    assert_equal true, Pref.where(id: 2).present?
    assert_equal true, Pref.where(id: 3).present?
    Aurora.execute("test/data/yml/function/nothing_conf.yml")
    assert_equal 6, Pref.all.count
    assert_equal true, Pref.where(id: 4).present?
    assert_equal true, Pref.where(id: 5).present?
    assert_equal true, Pref.where(id: 6).present?
  end

  # outline: whether 'autoincrement = false' works
  # expected value: registerd 3 datas
  #                 registed autoincrement_id
  test "no autoincrement_id" do
    Aurora.execute("test/data/yml/function/no_autoincrement.yml")
    assert_equal 3, Pref.all.count
    assert_equal true, Pref.where(id: 100).present?
    assert_equal true, Pref.where(id: 101).present?
    assert_equal true, Pref.where(id: 102).present?
  end

  # outline: whether autora can register with the setting array 
  # expected value: registerd 3 datas
  #                 registerd ["北海道", "青森県", "岩手県"]
  test "insert setting array" do
    Aurora.execute("test/data/yml/function/array_insert.yml")
    assert_equal 3, Pref.all.count
    assert_equal true, Pref.where(name: "北海道").present?
    assert_equal true, Pref.where(name: "青森県").present?
    assert_equal true, Pref.where(name: "岩手県").present?
  end

  # outline: whether autora can register with the setting string
  # expected value: registerd 3 datas
  #                 registerd "北海道"
  test "insert setting string" do
    Aurora.execute("test/data/yml/function/string_insert.yml")
    
    assert_equal 3, Pref.all.count
    assert_equal 3, Pref.where(name: "北海道").count
  end

  # outline: whether 'add_id' works
  # expected value: registerd 3 datas
  #                 registerd ["北海道_1", "青森県_2", "岩手県_3"]
  test "add_id option" do
    Aurora.execute("test/data/yml/option/add_id_conf.yml")
    assert_equal 3, Pref.all.count
    assert_equal true, Pref.where(name: "北海道_0").present?
    assert_equal true, Pref.where(name: "青森県_1").present?
    assert_equal true, Pref.where(name: "岩手県_2").present?
  end

  # outline: whether autora can register with the foreign key
  # expected value: registerd 6 datas(pref: 3, member: 3)
  test "foreign_key" do
    Aurora.execute("test/data/yml/function/foreign_key_insert.yml")
    assert_equal 3, Pref.all.count
    assert_equal 3, Member.all.count
    assert_equal Pref.all.pluck(:id), Member.all.pluck(:pref_id)
  end

  # outline: whether autora can register with the expression_expansion
  # expected value: registerd 3 datas
  #                 created_at: DateTime.parse("1997/02/05")
  test "expression_expansion" do
    Aurora.execute("test/data/yml/function/expression_expansion.yml")
    assert_equal 3, Pref.all.count
    assert_equal true, Pref.where(name: "北海道").present?
    assert_equal true, Pref.where(name: "青森県").present?
    assert_equal true, Pref.where(name: "岩手県").present?
    assert_equal 3, Pref.where(created_at: DateTime.parse("1997/02/05")).count
  end

  # outline: whether 'default seeder function' works
  # expected value: registerd 3 datas
  test "default seeder" do
    Aurora.execute("test/data/yml/function/default_seeder.yml")
    assert_equal 3, TestModel.all.count
  end

  # outline: whether 'maked function' works
  # expected value: registerd 3 datas
  test "maked" do
    Aurora.execute("test/data/yml/function/maked/once.yml")
    assert_equal 2, Member.all.count
    assert_equal true, Member.where(name: "北海道").present?
    assert_equal true, Member.where(name: "青森県").present?
  end

  # outline: whether 'maked function' works when written twice in a row
  # expected value: registerd 3 datas
  test "maked(twice)" do
    Aurora.execute("test/data/yml/function/maked/twice.yml")
    assert_equal 4, Member.all.count
    assert_equal true, Member.where(name: "北海道").present?
    assert_equal true, Member.where(name: "青森県").present?
    assert_equal true, Member.where(name: "秋田県").present?
    assert_equal true, Member.where(name: "茨城県").present?
  end
end