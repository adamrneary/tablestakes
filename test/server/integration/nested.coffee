describe 'table nested', ->
    $ = null
    window = null
    browser = null
    before (done)->
        glob.zombie.visit glob.url+"#nested", (e,_browser)->
            browser = _browser
            window = browser.window
            $ = window.$
            done()

    it 'page rendered', (done)->
        header = $('#example_header').text()
        assert header is 'Nested', 'example-header '+header
        done()

    it 'table rendered', (done)->
        assert $('table.tablestakes')
        assert $('table.tablestakes tr').length > 1
        done()

    it 'fold first node', (done)->
        td = $('td.collapsible:first')
        selector = browser.query('td.collapsible')
        browser.fire 'click', selector, ->
            assert td.hasClass('expandable')
            done()

