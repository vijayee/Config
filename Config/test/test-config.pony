use ".."
use "ponytest"
class iso _TestConfig is UnitTest
  fun name(): String => "Testing Config"
  fun apply(t: TestHelper) =>
    let config: Config val = recover val
      let config': Config = Config
      config'("name") = "test"
      config'("age") = I64(22)
      config'("hometown") = [1;2;3;4;5;6;7]
      config'
    end
    try
      t.assert_true((config("age")? as I64) == 22)
      t.assert_true((config("name")? as String) == "test")
      t.assert_array_eq[U8]((config("hometown")? as Array[U8] val), [1;2;3;4;5;6;7])
    else
      t.fail("Key not found")
    end
