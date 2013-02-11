window.TableStakesLib = {} unless window.TableStakesLib
class window.TableStakesLib.Column

  constructor: (options) ->
    if options?
      for key of options
        @[key] = options[key]
