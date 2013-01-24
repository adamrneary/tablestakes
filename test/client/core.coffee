table = null

describe "Table: ", ->
    it 'window.tablestakes is function', (done)->
        assert window.TablesStakes
        assert typeof window.TablesStakes is 'function'
        done()

    it 'constructor', (done)->
        table = new window.TablesStakes
        assert table
        done()
