use ".."
use "pony_test"
use  "random"

class TestNotify is ConfigNotify
  let _cb: {(Config val)} val
  new iso create(cb:  {(Config val)} val) =>
    _cb = cb
  fun ref apply(config: Config val) =>
    _cb(config)

actor TestReceiver
  var config: Config val
  let id: String
  let notify: TestNotify iso!
  let configService: ConfigService
  let t: TestHelper
  new create(t': TestHelper, config': Config val, configService': ConfigService, id': String) =>
    config = config'
    configService = configService'
    id = id'
    t = t'
    let notify' = TestNotify({(config: Config val)(testReceiver: TestReceiver tag = this) => testReceiver.updateConfig(config)} val)
    notify = notify'
    configService.subscribe(consume notify')
    if id == "Test Receiver 3" then
      configService.updateTransform({(config: Config) =>
        config("name") = "Main Thread"
        config
      } val)
    end
  be updateConfig(config': Config val) =>
    config = config'
    try
      t.log(id.string() + " reveived a config with name value of " + (config("name")? as String))
      t.assert_true((config("name")? as String) == "Main Thread")
      if id == "Test Receiver 3" then
        t.complete(true)
      end
    else
      t.fail("Invalid Key")
      t.complete(true)
    end

class iso _TestConfigService is UnitTest
  fun name(): String => "Testing Config Service"
  fun apply(t: TestHelper) =>
    t.long_test(5000000000)
    let config: Config val = recover val
      let config': Config = Config
      config'("name") = "test"
      config'("age") = I64(22)
      config'
    end
    let configService: ConfigService = ConfigService.fromConfig(config)
    let testRecevier1: TestReceiver = TestReceiver(t, config, configService, "Test Receiver 1")
    let testRecevier2: TestReceiver = TestReceiver(t, config, configService, "Test Receiver 2")
    let testRecevier3: TestReceiver = TestReceiver(t, config, configService, "Test Receiver 3")
