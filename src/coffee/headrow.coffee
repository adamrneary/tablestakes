window.TableStakesLib = {} unless window.TableStakesLib
class window.TableStakesLib.HeadRow

  constructor: (options)->
    if options? then _.extend(@, options)
