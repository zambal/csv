Code.require_file "test_helper.exs", __DIR__

defmodule CSVTest do
  use ExUnit.Case

  @test_data1 """
# test data 1
#
mike, 35, music
eric, 24, fishing
susan, 26, books
"""

  @test_data2 """
# test data 2
#
\"mike\", \"35\", \"music\"
\"eric\", \"24\", \"fishing\"
\"susan\", \"26\", \"books\"
"""

  test "test_data1: to lists" do
    res = {:ok, [["mike", "35", "music"],
                 ["eric", "24", "fishing"],
                 ["susan", "26", "books"]]}
    assert(CSV.parse(@test_data1, text_delimiter: nil) == res)
  end

  test "test_data1: to keywords" do
    res = {:ok, [[name: "mike", age: "35", hobbies: "music"],
                 [name: "eric", age: "24", hobbies: "fishing"],
                 [name: "susan", age: "26", hobbies: "books"]]}
    assert(CSV.parse(@test_data1, text_delimiter: nil,
                     fields: [:name, :age, :hobbies]) == res)
  end

  test "test_data1: skip first 3 lines" do
    res = {:ok, [["eric", "24", "fishing"],
                 ["susan", "26", "books"]]}
    assert(CSV.parse(@test_data1, text_delimiter: nil,
                     skip_first_lines: 3) == res)
  end

  test "test_data2: to keywords" do
    res = {:ok, [[name: "mike", age: "35", hobbies: "music"],
                 [name: "eric", age: "24", hobbies: "fishing"],
                 [name: "susan", age: "26", hobbies: "books"]]}
    assert(CSV.parse(@test_data2, fields: [:name, :age, :hobbies]) == res)
  end

  test "test_data2: fields missing" do
    res = {:error, "Aborted: fields missing in line 3."}
    assert(CSV.parse(@test_data2, fields: [:name, :age, :hobbies, :address]) == res)
  end

  test "test_data2: too many fields" do
    res = {:error, "Aborted: too many fields in line 3."}
    assert(CSV.parse(@test_data2, fields: [:name, :age]) == res)
  end


end
