use "collections"
use "files"
use "ponytest"

interface ConfigNotify
  fun ref apply(config: Config val)

type ConfigVal is (Number | ByteSeq)
type Config is Map[String, (ConfigVal | Array[ConfigVal] val| Map[String, ConfigVal] val)]

actor ConfigService
  let subscribers: MapIs[ConfigNotify tag, ConfigNotify]
  var config: Config val
  let t: TestHelper

  new create(size: USize = 0, t': TestHelper) =>
    t = t'
    config = recover val Config(size) end
    subscribers = MapIs[ConfigNotify tag, ConfigNotify]

  be apply(notify: ConfigNotify iso) =>
    let notify': ConfigNotify ref = consume notify
    notify'(config)

  new fromConfig(config': Config val, t': TestHelper) =>
    t = t'
    config = config'
    subscribers = MapIs[ConfigNotify tag, ConfigNotify]
    emit()

  be subscribe(notify: ConfigNotify iso) =>
    let notify': ConfigNotify ref = consume notify
    subscribers(notify') = notify'

  be unsubscribe(notify: ConfigNotify tag) =>
    try subscribers.remove(notify)? end

  fun ref emit () =>
    t.log(subscribers.size().string())
    for notify in subscribers.values() do
      t.log("emitted")
      notify(config)
    end

  be update(key: String, value: ConfigVal) =>
    config = recover val
      let config' = Config(config.size())
      for pair in config.pairs() do
        config'(pair._1) = pair._2
      end
      config'(key) = value
      config'
    end
    emit()

  be updateBatch(pairs: Array[(String, ConfigVal)] val) =>
    config = recover val
      let config' = Config(config.size())
      for pair in config.pairs() do
        config'(pair._1) = pair._2
      end
      t.log("happened")
      for pair in pairs.values() do
        config'(pair._1) = pair._2
      end
      config'
    end
    emit()

  be updateTransform(transform: {(Config): Config} val) =>
    config = recover val
      let config' = Config(config.size())
      for pair in config.pairs() do
        config'(pair._1) = pair._2
      end
      transform(config')
    end
    emit()
