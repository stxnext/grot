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
            constructor: (config) ->
                for field of config
                    if typeof @[field] != 'undefined' and typeof @[field] != 'function'
                        @[field] = config[field]

                super

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
            initPos: null

            constructor: (config) ->
                for field of config
                    if typeof @[field] != 'undefined' and typeof @[field] != 'function'
                        @[field] = config[field]

                super

                if !config.initPos
                    @initPos = {x: 0, y: 0}

                @canvas.setSize(@width, @height)

            updateHandler: (event) ->
                @currentScale = @renderManager.currentScale
                @scale {x: @currentScale, y: @currentScale}

                width = (@getWidth() + @initPos.x) * @currentScale
                height = (@getHeight() + @initPos.y) * @currentScale

                @canvas.setSize(width, height)
                @batchDraw()

            centerLayer: ->
                @canvas._canvas.style.left = ((@renderManager.stage.getWidth() - @getWidth() * @renderManager.currentScale) / 2) + 'px'


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

            widgets: {}

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

            getWindowSize: ->
                return [window.innerWidth, window.innerHeight]

            calculateScaleUnit: ->
                [width, height] = @getWindowSize()

                scale = if width < height? then width / @baseWindowSize.width
                else height / @baseWindowSize.height

                return Number(scale.toFixed(2))

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


        class @Game
            constructor: ->
                window.onresize = @update.bind(@)
                if !!window.ondeviceorientation
                    window.ondeviceorientation = @update.bind(@)

            update: ->
                @renderManager.update.call @renderManager


window.GrotEngine = new Engine
window.Grot = {}
