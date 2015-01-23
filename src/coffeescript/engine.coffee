###
Game engine.

Here we store all abstract classes of which
will be used by game to draw stage, layers etc.

###

class Engine
    constructor: ->

        # Assign  @ (actually this) to 'engine' variable for quicker
        # access between classes


        engine = @
        cfg = window.cfg


        ###
        Widget class

        This class is inherited by every widged used across the game.
        By widgets we understand any objects made from one ore more
        groups of objects (Shapes, Labels etc.)


        ###
        class @Widget extends Kinetic.Group
            margins: null
            currentScale: null
            layer: null

            constructor: (config) ->
                for field of config
                    if typeof @[field] != 'undefined' and typeof @[field] != 'function'
                        @[field] = config[field]

                if !config.margins
                    @margins = {x: 0, y: 0}

                super

                @on 'update', @updateHandler

            getCurrentX: ->
                return  @margins.x * @currentScale

            getCurrentY: ->
                return @margins.y * @currentScale

            rePosition: ->
                @x(@getCurrentX())
                @y(@getCurrentY())
                return ([@x(), @y()])

            updateHandler: (event) ->
                if @layer
                    @currentScale = @layer.currentScale
                    @rePosition()

            scale: (scale) ->
                if @group?
                    @group.scale {x: scale, y: scale}
                else
                    scale = {x: scale, y: scale}
                    super

            centerElement: (element) ->
                # place label in center of widget
                element.offsetX(element.width()/2)
                element.offsetY(element.height()/2)


        ###
        Layer class

        This class is inherited by every layer used across the game.
        By layers we understand spearate canvases generated on the page
        that can contain multiple widgets, groups, shapes ect.

        ###
        class @Layer extends Kinetic.Layer
            renderManager: null
            currentScale: null
            margins: null

            constructor: (config) ->
                for field of config
                    if typeof @[field] != 'undefined' and typeof @[field] != 'function'
                        @[field] = config[field]

                super

                if !config.margins
                    @margins = {x: 0, y: 0}

            updateHandler: (event) ->
                @currentScale = @renderManager.currentScale
                @scale {x: @currentScale, y: @currentScale}

                @rePosition()

                width = ((@getWidth() * @currentScale) || @parent.getWidth()) + @getCurrentX()
                height = ((@getHeight() * @currentScale) || @parent.getHeight()) + @getCurrentY()

                @canvas.setSize(width, height)
                @batchDraw()

            getCurrentX: ->
                return if typeof @margins.x is 'number' then @margins.x * @currentScale
                else
                    precentage = (@margins.x.match(/\d+/) || [0])[0] / 100
                    (@parent.getWidth() - @getWidth() * @currentScale) * precentage

            getCurrentY: ->
                return if typeof @margins.y is 'number' then @margins.y * @currentScale
                else
                    precentage = (@margins.x.match(/\d+/) || [0])[0] / 100
                    (@parent.getHeight() - @getHeight() * @currentScale) * precentage

            rePosition: ->
                @x(@getCurrentX())
                @y(@getCurrentY())
                return ([@x(), @y()])

        ###
        RenderManager class

        This class contains all basic logic necessary for rendering layers
        and keeping them up to date. HIt is heart of the game.

        ###
        class @RenderManager
            cfg: cfg
            baseScale: if cfg.baseScale? then cfg.baseScale else 1
            baseWindowSize: if cfg.baseWindowSize? then cfg.baseWindowSize else null
            currentScale: null
            stage: null
            showPreview: false

            constructor: ->
                if not @baseWindowSize?
                    [width, height] = @getWindowSize()
                    @baseWindowSize =
                        width: width
                        height: height

                if not @currentScale?
                    @currentScale = @calculateScaleUnit()

                layers = @stage.getLayers()
                for layer in layers
                    layer.on('update', layer.updateHandler)
                    layer.fire 'update'

                @updateMargin()

            getWindowSize: ->
                return [window.innerWidth, window.innerHeight]

            calculateScaleUnit: ->
                [maxWidth, maxHeight] = @getWindowSize()
                previewHeight = if @showPreview then cfg.previewHeight else 0

                width = 600
                height = 900 + previewHeight

                #check if current height is larger than max
                if (height > maxHeight)
                    ratio = maxHeight / height
                    height = maxHeight
                    width = width * ratio

                #check if the current width is larger than the max
                if (width > maxWidth)
                    ratio = maxWidth / width
                    width = maxWidth
                    height = height * ratio

                scaleXValue = width / 600
                scaleYValue = height / (900 + previewHeight)
                scale = Math.min(scaleXValue, scaleYValue)

                return Number(scale.toFixed(2))

            updateMargin: ->
                maxWidth = 0
                layers = @stage.getLayers()
                for layer in layers
                    console.log layer.canvas.width
                    console.log window.getPixelRatio
                    maxWidth = Math.max(maxWidth, layer.canvas.width / window.getPixelRatio)

                marginWidth = Math.ceil((@getWindowSize()[0] - maxWidth)/2)
                marginWidth = Math.max(marginWidth, 0)
                @stage.getContainer().style.marginLeft = marginWidth + 'px'

            centerLayer: (layer) ->
                layer.offsetX(-(@stage.getWidth() - layer.getWidth()) / 2)

            adaptStage: () ->
                [width, height] = @getWindowSize()
                @stage.setHeight height
                @stage.setWidth width

            update: ->
                # called after windows resize

                @currentScale = @calculateScaleUnit()
                @adaptStage()

                layers = @stage.getLayers()
                for layer in layers
                    layer.fire 'update'

                @stage.fire 'onStageUpdated'

                @updateMargin()


        class @Game
            constructor: ->
                window.onresize = @update.bind(@)
                if !!window.ondeviceorientation
                    window.ondeviceorientation = @update.bind(@)

            update: ->
                @renderManager.update.call @renderManager


window.GrotEngine = new Engine
window.Grot = {}
