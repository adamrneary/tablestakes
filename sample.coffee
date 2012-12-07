
$(document).ready ->
    d3.text "genes.csv", (text) ->
        genes = d3.csv.parse text

        geneExpressionModel = new Backbone.Model
        geneExpressionModel.set conditionNames: getConditionNames(genes)
        geneExpressionModel.set geneNames: genes.map((gene) -> gene.gene_name)
        geneExpressionModel.set geneExpressions: getGeneExpressions(genes, geneExpressionModel.get "conditionNames")
        geneExpressionModel.set extent: d3.extent($.map(geneExpressionModel.get("geneExpressions"), (item)-> item )) # flatten matrix
        geneExpressionModel.set clusters: genes.map (gene) -> gene.cluster
        geneExpressionModel.set clusterColor: d3.scale.category20()

        heatmap = new Heatmap(el: "#heatmap", model: geneExpressionModel)

Heatmap = Backbone.View.extend
    initialize: ->
        @render()
    render: -> 
        geneExpressions = @model.get "geneExpressions"
        conditionNames = @model.get "conditionNames"
        geneNames = @model.get "geneNames"
        extent = @model.get "extent"
        clusters = @model.get "clusters"
        clusterColor = @model.get "clusterColor"

        heatmapColor = d3.scale.linear().domain([-1.5,0,1.5]).range(["#278DD6","#fff","#d62728"])
        textScaleFactor = 15
        conditionNamesMargin = d3.max(conditionNames.map((conditionName) -> conditionName.length))
        geneNamesMargin = d3.max(geneNames.map((geneName) -> geneName.length))
        margin =
            top: conditionNamesMargin*textScaleFactor 
            right: 150 
            bottom: conditionNamesMargin*textScaleFactor 
            left: geneNamesMargin*textScaleFactor
        cell_size = 30        
        width = cell_size*geneExpressions[0].length
        height = cell_size*geneNames.length

        heatmap = d3.select(@el).append("svg")
            .attr("width", width + margin.right + margin.left)
            .attr("height", height + margin.top + margin.bottom)
            .attr("id","heatmap")
          .append("g")
            .attr("transform", "translate(" + margin.left + "," + margin.top + ")")    

        x = d3.scale.ordinal().domain(d3.range(geneExpressions[0].length)).rangeBands([0, width])
        y = d3.scale.ordinal().domain(d3.range(geneNames.length)).rangeBands([0, height])

        columns = heatmap.selectAll(".column")
            .data(conditionNames)
          .enter().append("g")
            .attr("class", "column")
            .attr("transform", (d, i) -> "translate(" + x(i) + ")rotate(-90)" )

        # Add condition names (top)
        columns.append("text")
            .attr("x", 6)
            .attr("y", x.rangeBand() / 2)
            .attr("dy", "-.5em") # .32em before rotating
            .attr("dx", ".5em") 
            .attr("text-anchor", "start")
            .text((d, i) -> conditionNames[i] )
            .attr("transform","rotate(45)")
            
        getRow = (row) ->
            cell = d3.select(this).selectAll(".cell")
                .data(row)
              .enter().append("rect")
                .attr("class", "cell")
                .attr("x", (d,i)  -> x(i))
                .attr("width", x.rangeBand())
                .attr("height", x.rangeBand())
                .text((d) -> d)
                .style("fill", (d)  -> heatmapColor(d))

        rows = heatmap.selectAll(".row")
            .data(geneExpressions)
          .enter().append("g")
            .attr("class", "row")
            .attr("name", (d,i) -> "gene_" + i)
            .attr("transform", (d, i)  -> "translate(0," + y(i) + ")")
            .each(getRow)

        # Add gene names
        rows.append("text")
            .attr("x", -6)
            .attr("y", x.rangeBand() / 2)
            .attr("dy", ".32em")
            .attr("text-anchor", "end")
            .text((d, i) -> geneNames[i])

         
getGeneExpressions = (genes, conditionNames) ->
getGeneExpressions = (genes, conditionNames) ->
    genes.map (gene) ->
        conditionNames.map (condition) ->
            +gene[condition] # make numeric


getConditionNames = (genes) ->
    Object.keys(genes[0]).filter (columnName) ->
        !columnName.match(/cluster/) && isNumber(genes[1][columnName])

isNumber = (n) ->
    !isNaN(parseFloat(n)) and isFinite(n)
###
