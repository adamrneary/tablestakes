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

    it 'open first node and children visible', (done)->
        console.log 'test work'
        td = $('td.expandable:first')
        selector = browser.query('td.expandable')
        browser.fire 'click', selector, ->
            assert td.hasClass('collapsible')
            assert td.parent().next().find('.indent3').length is 1
            done()

    it 'fold first node and children hide', (done)->
        td = $('td.collapsible:first')
        selector = browser.query('td.collapsible')
        browser.fire 'click', selector, ->
            assert td.hasClass('expandable')
            assert td.parent().next().find('.indent3').length is 0
            done()
