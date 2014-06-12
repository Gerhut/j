window.j = j = (args...) ->

  typeOf = (obj) ->
    return Object::toString.call(obj)
      .match(/^\[object\s(\w+)\]$/)[1]

  loadFuncs = []
  document.addEventListener('DOMContentLoaded', ->
    loadFunc() for loadFunc in loadFuncs
    loadFuncs = null
  )

  onload = (func) ->
    if loadFuncs is null
      func()
    else
      loadFuncs.push func

  elements = undefined

  map = (func) ->
    hasRet = no
    rets = for element in elements
      ret = func element
      unless ret is undefined
        hasRet = yes
      ret

    if hasRet then rets

  doArg = (arg) ->
    switch typeOf arg
      when 'Function'
        if elements?
          map arg
        else
          onload arg
      when 'Object'
        for key, value of arg
          [key, mthName, key] = key.match(/^([a-z]*)(.*)$/)
          key = key[0].toLowerCase() + key[1..] if key.length > 0
          ret = map (element) ->
            j.mth[mthName]? element, key, value
        ret
      when 'String'
        switch arg[0]
          when '+'
            elements = (elements || []).concat Array::slice.call document.querySelectorAll arg[1..]
            return
          else
            elements = Array::slice.call document.querySelectorAll arg
            return

  jo = (args...) ->
    for arg in args
      ret = doArg arg
    ret || jo

  jo args...

j.mth =
  s: (element, key, value) ->
    if value is null
      return element.style[key]
    else
      element.style[key] = value
      return

  a: (element, key, value) ->
    if value is null
      return element.getAttribute(key)
    else
      element.setAttribute(key, value)
      return

  html: (element, key, value) ->
    if value is null
      return element.innerHTML
    else
      element.innerHTML = value
      return
